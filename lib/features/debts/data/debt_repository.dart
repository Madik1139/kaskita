import 'dart:math' as math;
import 'package:sqflite/sqflite.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/date_formatter.dart';
import '../../transactions/data/transaction_repository.dart';
import '../models/debt_models.dart';
import 'debt_settlement_helper.dart';

/// Repository SQLite untuk Buku Hutang Pintar:
/// Direktori Kontak, Trust Badge Otomatis, Cicilan FIFO, Auto-Netting,
/// Lunas via Barang/Traktiran, dan Batas Rem Piutang (Lending Cap).
class DebtRepository {
  const DebtRepository(this._dbHelper);

  final DatabaseHelper _dbHelper;

  static const String _contactSummarySql = '''
    SELECT 
      c.id,
      c.name,
      c.phone_note,
      c.net_balance,
      c.trust_badge,
      c.late_count,
      (SELECT COUNT(*) FROM debts d WHERE d.contact_id = c.id AND d.status != 'PAID') AS open_debts_count,
      (SELECT MIN(d.due_date) FROM debts d WHERE d.contact_id = c.id AND d.status != 'PAID' AND d.debt_type = 'RECEIVABLE' AND d.due_date IS NOT NULL AND d.due_date != '') AS earliest_due_date
    FROM contacts c
  ''';

  Future<List<ContactSummaryModel>> getContactsSummary() async {
    final Database db = await _dbHelper.database;
    final List<Map<String, Object?>> rows = await db.rawQuery('''
      $_contactSummarySql
      ORDER BY ABS(c.net_balance) DESC, c.name COLLATE NOCASE ASC
    ''');
    return rows.map(ContactSummaryModel.fromJoinedMap).toList();
  }

  Future<ContactDetailStateModel> getContactDetail(int contactId) async {
    final Database db = await _dbHelper.database;
    final List<Map<String, Object?>> contactRows = await db.rawQuery(
      '''
      $_contactSummarySql
      WHERE c.id = ?
      LIMIT 1
      ''',
      <Object>[contactId],
    );
    if (contactRows.isEmpty) {
      throw const AppException(AppErrorCode.contactRequired);
    }
    final ContactSummaryModel contact =
        ContactSummaryModel.fromJoinedMap(contactRows.first);

    final List<Map<String, Object?>> activeDebtRows = await db.query(
      'debts',
      where: "contact_id = ? AND status != 'PAID'",
      whereArgs: <Object>[contactId],
      orderBy: 'created_at ASC, id ASC',
    );

    final List<Map<String, Object?>> paymentRows = await db.rawQuery(
      '''
      SELECT dp.*, d.note AS debt_note
      FROM debt_payments dp
      INNER JOIN debts d ON dp.debt_id = d.id
      WHERE d.contact_id = ?
      ORDER BY dp.payment_date DESC, dp.id DESC
      ''',
      <Object>[contactId],
    );

    return ContactDetailStateModel(
      contact: contact,
      activeDebts: activeDebtRows.map(DebtItemModel.fromMap).toList(),
      paymentHistory: paymentRows.map(DebtPaymentModel.fromMap).toList(),
    );
  }

  Future<int> getLendingCapLimit() async {
    final Database db = await _dbHelper.database;
    final List<Map<String, Object?>> rows = await db.query(
      'app_settings',
      where: 'setting_key = ?',
      whereArgs: <Object>[AppConstants.keyLendingCapLimit],
      limit: 1,
    );
    if (rows.isEmpty) {
      return AppConstants.defaultLendingCap;
    }
    return int.tryParse((rows.first['setting_value'] as String?) ?? '') ??
        AppConstants.defaultLendingCap;
  }

  Future<void> updateLendingCapLimit(int newLimit) async {
    if (newLimit <= 0) {
      throw const AppException(AppErrorCode.amountMustBePositive);
    }
    final Database db = await _dbHelper.database;
    await db.insert(
      'app_settings',
      <String, Object?>{
        'setting_key': AppConstants.keyLendingCapLimit,
        'setting_value': newLimit.toString(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<ContactSummaryModel> createContact({
    required String name,
    String? phoneNote,
  }) async {
    final String trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const AppException(AppErrorCode.contactRequired);
    }
    final Database db = await _dbHelper.database;
    final List<Map<String, Object?>> dup = await db.query(
      'contacts',
      where: 'LOWER(name) = ?',
      whereArgs: <Object>[trimmed.toLowerCase()],
      limit: 1,
    );
    if (dup.isNotEmpty) {
      throw const AppException(AppErrorCode.duplicateContactName);
    }

    final int id = await db.insert('contacts', <String, Object?>{
      'name': trimmed,
      'phone_note': (phoneNote ?? '').trim(),
      'net_balance': 0,
      'trust_badge': 'GOOD',
      'late_count': 0,
    });
    final ContactDetailStateModel detail = await getContactDetail(id);
    return detail.contact;
  }

  /// Pelunasan / Cicilan Tagihan dengan Alokasi Otomatis FIFO (atau Pilih Tagihan Spesifik)
  /// serta dukungan Tunai (`CASH`) maupun Lunas via Barang/Traktiran (`ITEM_TREAT`).
  Future<void> settleDebts({
    required int contactId,
    required String debtType,
    required int amount,
    required String settlementMethod,
    required DateTime paymentDate,
    int? walletId,
    int? specificDebtId,
    bool recordTreatAsPersonalExpense = false,
    int? treatExpenseCategoryId,
    String? note,
  }) async {
    if (amount <= 0) {
      throw const AppException(AppErrorCode.amountMustBePositive);
    }
    if (settlementMethod == 'CASH' && walletId == null) {
      throw const AppException(AppErrorCode.walletRequired);
    }

    final Database db = await _dbHelper.database;
    await db.transaction((Transaction txn) async {
      final List<Map<String, Object?>> targetDebts = await txn.query(
        'debts',
        where: specificDebtId != null
            ? "id = ? AND contact_id = ? AND status != 'PAID'"
            : "contact_id = ? AND debt_type = ? AND status != 'PAID'",
        whereArgs: specificDebtId != null
            ? <Object>[specificDebtId, contactId]
            : <Object>[contactId, debtType],
        orderBy: 'created_at ASC, id ASC',
      );

      int totalRemainingAvailable = 0;
      for (final Map<String, Object?> row in targetDebts) {
        totalRemainingAvailable += (row['remaining_amount'] as int?) ?? 0;
      }
      if (amount > totalRemainingAvailable) {
        throw const AppException(AppErrorCode.overpaymentExceedsRemaining);
      }

      final String isoDate = DateFormatter.toIsoDate(paymentDate);
      final String cleanNote = (note != null && note.trim().isNotEmpty)
          ? note.trim()
          : (settlementMethod == 'ITEM_TREAT'
              ? 'Pelunasan via Traktiran / Barang'
              : (debtType == 'RECEIVABLE'
                  ? 'Terima Cicilan / Pelunasan'
                  : 'Bayar Cicilan Hutang'));

      int? paymentTrxId;
      if (settlementMethod == 'CASH' && walletId != null) {
        final List<Map<String, Object?>> wRows = await txn.query(
          'wallets',
          where: 'id = ?',
          whereArgs: <Object>[walletId],
          limit: 1,
        );
        if (wRows.isEmpty) {
          throw const AppException(AppErrorCode.walletRequired);
        }
        final int currentBalance =
            (wRows.first['current_balance'] as int?) ?? 0;
        if (debtType == 'PAYABLE' && currentBalance < amount) {
          throw const AppException(AppErrorCode.insufficientWalletBalance);
        }

        final int nextBalance = debtType == 'RECEIVABLE'
            ? currentBalance + amount
            : currentBalance - amount;
        await txn.update(
          'wallets',
          <String, Object?>{'current_balance': nextBalance},
          where: 'id = ?',
          whereArgs: <Object>[walletId],
        );

        paymentTrxId = await txn.insert('transactions', <String, Object?>{
          'wallet_id': walletId,
          'target_wallet_id': null,
          'category_id': null,
          'trx_type': debtType == 'RECEIVABLE'
              ? 'RECEIVABLE_SETTLE'
              : 'PAYABLE_SETTLE',
          'total_wallet_amount': amount,
          'pure_consumption_amount': 0,
          'note': cleanNote,
          'trx_date': isoDate,
        });
      } else if (settlementMethod == 'ITEM_TREAT' &&
          recordTreatAsPersonalExpense) {
        paymentTrxId = await txn.insert('transactions', <String, Object?>{
          'wallet_id': null,
          'target_wallet_id': null,
          'category_id': treatExpenseCategoryId ?? 1,
          'trx_type': 'EXPENSE',
          'total_wallet_amount': 0,
          'pure_consumption_amount': amount,
          'note': cleanNote,
          'trx_date': isoDate,
        });
      }

      int remainingToAllocate = amount;
      int newLateIncidents = 0;
      for (final Map<String, Object?> debtRow in targetDebts) {
        if (remainingToAllocate <= 0) {
          break;
        }
        final int debtId = (debtRow['id'] as int?) ?? 0;
        final int currentRem = (debtRow['remaining_amount'] as int?) ?? 0;
        final int allocated = math.min(remainingToAllocate, currentRem);
        final int nextRem = currentRem - allocated;
        final String nextStatus = nextRem == 0 ? 'PAID' : 'PARTIAL';

        await txn.update(
          'debts',
          <String, Object?>{
            'remaining_amount': nextRem,
            'status': nextStatus,
          },
          where: 'id = ?',
          whereArgs: <Object>[debtId],
        );

        await txn.insert('debt_payments', <String, Object?>{
          'debt_id': debtId,
          'payment_transaction_id': paymentTrxId,
          'settlement_method': settlementMethod,
          'amount_paid': allocated,
          'payment_date': isoDate,
          'note': cleanNote,
        });

        final String? dueStr = debtRow['due_date'] as String?;
        if (debtType == 'RECEIVABLE' &&
            dueStr != null &&
            dueStr.isNotEmpty &&
            isoDate.compareTo(dueStr) > 0) {
          newLateIncidents++;
        }

        remainingToAllocate -= allocated;
      }

      if (newLateIncidents > 0) {
        await txn.rawUpdate(
          'UPDATE contacts SET late_count = late_count + ? WHERE id = ?',
          <Object>[newLateIncidents, contactId],
        );
      }

      await TransactionRepository.recalculateContactBalance(txn, contactId);
    });
  }

  /// Saling Silang Saldo Otomatis (Auto-Netting).
  Future<void> recordDebtWithAutoNetting({
    required int contactId,
    required String newDebtType,
    required int amount,
    required DateTime date,
    String? note,
    DateTime? dueDate,
  }) async {
    final Database db = await _dbHelper.database;
    await db.transaction((Transaction txn) async {
      await DebtSettlementHelper.executeAutoNettingInTxn(
        txn: txn,
        contactId: contactId,
        newDebtType: newDebtType,
        amount: amount,
        date: date,
        note: note,
        dueDate: dueDate,
      );
    });
  }

  /// Membatalkan riwayat cicilan (`debt_payments`) dan mengembalikan sisa tagihan
  /// serta saldo dompet terkait.
  Future<void> cancelDebtPayment(int paymentId) async {
    final Database db = await _dbHelper.database;
    await db.transaction((Transaction txn) async {
      await DebtSettlementHelper.cancelPaymentInTxn(txn, paymentId);
    });
  }
}
