import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/date_formatter.dart';
import '../models/transaction_model.dart';

/// Repository SQLite untuk pencatatan transaksi cepat (< 5 detik),
/// Talangan Teman (Split Expense), Rollback Edit/Hapus, dan Rekapitulasi Periode.
class TransactionRepository {
  const TransactionRepository(this._dbHelper);

  final DatabaseHelper _dbHelper;

  Future<List<ContactOptionModel>> getContacts() async {
    final Database db = await _dbHelper.database;
    final List<Map<String, Object?>> rows = await db.query(
      'contacts',
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(ContactOptionModel.fromMap).toList();
  }

  /// Menyimpan transaksi baru (EXPENSE, Split Talangan, INCOME, RECEIVABLE_OUT, DEBT_IN)
  /// secara atomik di dalam satu transaksi database.
  Future<int> recordTransaction({
    required String trxType,
    required int walletId,
    required int totalWalletAmount,
    required DateTime trxDate,
    int? categoryId,
    String? note,
    bool isSplitTalangan = false,
    int friendShareAmount = 0,
    int? contactId,
    String? newContactName,
    DateTime? dueDate,
  }) async {
    if (totalWalletAmount <= 0) {
      throw const AppException(AppErrorCode.amountMustBePositive);
    }
    if ((trxType == 'EXPENSE' || trxType == 'INCOME') && categoryId == null) {
      throw const AppException(AppErrorCode.categoryRequired);
    }

    int pureConsumption = 0;
    if (trxType == 'EXPENSE') {
      if (isSplitTalangan) {
        if (friendShareAmount <= 0) {
          throw const AppException(AppErrorCode.amountMustBePositive);
        }
        if (friendShareAmount > totalWalletAmount) {
          throw const AppException(AppErrorCode.splitAmountExceedsTotal);
        }
        pureConsumption = totalWalletAmount - friendShareAmount;
      } else {
        pureConsumption = totalWalletAmount;
      }
    } else if (trxType == 'INCOME') {
      pureConsumption = totalWalletAmount;
    }

    final bool requiresContact = isSplitTalangan ||
        trxType == 'RECEIVABLE_OUT' ||
        trxType == 'DEBT_IN';
    if (requiresContact &&
        contactId == null &&
        (newContactName == null || newContactName.trim().isEmpty)) {
      throw const AppException(AppErrorCode.contactRequired);
    }

    final Database db = await _dbHelper.database;
    return db.transaction<int>((Transaction txn) async {
      final int currentWalletBalance = await _getWalletBalance(txn, walletId);
      final bool isOutflow =
          trxType == 'EXPENSE' || trxType == 'RECEIVABLE_OUT';
      if (isOutflow && currentWalletBalance < totalWalletAmount) {
        throw const AppException(AppErrorCode.insufficientWalletBalance);
      }

      final int nextWalletBalance = isOutflow
          ? currentWalletBalance - totalWalletAmount
          : currentWalletBalance + totalWalletAmount;

      await txn.update(
        'wallets',
        <String, Object?>{'current_balance': nextWalletBalance},
        where: 'id = ?',
        whereArgs: <Object>[walletId],
      );

      final String cleanNote = _resolveDefaultNote(
        rawNote: note,
        trxType: trxType,
        isSplitTalangan: isSplitTalangan,
        newContactName: newContactName,
      );

      final int trxId = await txn.insert('transactions', <String, Object?>{
        'wallet_id': walletId,
        'target_wallet_id': null,
        'category_id':
            (trxType == 'EXPENSE' || trxType == 'INCOME') ? categoryId : null,
        'trx_type': trxType,
        'total_wallet_amount': totalWalletAmount,
        'pure_consumption_amount': pureConsumption,
        'note': cleanNote,
        'trx_date': DateFormatter.toIsoDate(trxDate),
      });

      if (requiresContact) {
        final int resolvedContactId = await _resolveOrCreateContact(
          txn,
          contactId: contactId,
          newContactName: newContactName,
        );
        final int debtPrincipal =
            isSplitTalangan ? friendShareAmount : totalWalletAmount;
        final String debtType =
            trxType == 'DEBT_IN' ? 'PAYABLE' : 'RECEIVABLE';

        await txn.insert('debts', <String, Object?>{
          'contact_id': resolvedContactId,
          'source_transaction_id': trxId,
          'debt_type': debtType,
          'principal_amount': debtPrincipal,
          'remaining_amount': debtPrincipal,
          'status': 'UNPAID',
          'due_date':
              dueDate != null ? DateFormatter.toIsoDate(dueDate) : null,
          'note': cleanNote,
        });

        await recalculateContactBalance(txn, resolvedContactId);
      }

      return trxId;
    });
  }

  /// Menghapus transaksi beserta rollback otomatis saldo dompet & hutang.
  /// Ditolak jika transaksi talangan/hutang sudah memiliki cicilan masuk.
  Future<void> deleteTransaction(int transactionId) async {
    final Database db = await _dbHelper.database;
    await db.transaction((Transaction txn) async {
      await _rollbackAndDeleteInTxn(txn, transactionId);
    });
  }

  /// Memperbarui transaksi (Edit) dengan melakukan rollback transaksi lama
  /// lalu menyimpan nilai baru secara atomik.
  Future<void> updateTransaction({
    required int transactionId,
    required int walletId,
    required int totalWalletAmount,
    required DateTime trxDate,
    int? categoryId,
    String? note,
    bool isSplitTalangan = false,
    int friendShareAmount = 0,
    int? contactId,
    String? newContactName,
    DateTime? dueDate,
  }) async {
    if (totalWalletAmount <= 0) {
      throw const AppException(AppErrorCode.amountMustBePositive);
    }

    final Database db = await _dbHelper.database;
    await db.transaction((Transaction txn) async {
      final List<Map<String, Object?>> existingRows = await txn.query(
        'transactions',
        where: 'id = ?',
        whereArgs: <Object>[transactionId],
        limit: 1,
      );
      if (existingRows.isEmpty) {
        return;
      }
      final String trxType =
          (existingRows.first['trx_type'] as String?) ?? 'EXPENSE';

      // Rollback efek lama (akan melempar error jika sudah ada cicilan)
      await _rollbackAndDeleteInTxn(txn, transactionId);

      int pureConsumption = 0;
      if (trxType == 'EXPENSE') {
        if (isSplitTalangan) {
          if (friendShareAmount <= 0) {
            throw const AppException(AppErrorCode.amountMustBePositive);
          }
          if (friendShareAmount > totalWalletAmount) {
            throw const AppException(AppErrorCode.splitAmountExceedsTotal);
          }
          pureConsumption = totalWalletAmount - friendShareAmount;
        } else {
          pureConsumption = totalWalletAmount;
        }
      } else if (trxType == 'INCOME') {
        pureConsumption = totalWalletAmount;
      }

      final int currentWalletBalance = await _getWalletBalance(txn, walletId);
      final bool isOutflow =
          trxType == 'EXPENSE' || trxType == 'RECEIVABLE_OUT';
      if (isOutflow && currentWalletBalance < totalWalletAmount) {
        throw const AppException(AppErrorCode.insufficientWalletBalance);
      }

      await txn.update(
        'wallets',
        <String, Object?>{
          'current_balance': isOutflow
              ? currentWalletBalance - totalWalletAmount
              : currentWalletBalance + totalWalletAmount,
        },
        where: 'id = ?',
        whereArgs: <Object>[walletId],
      );

      final String cleanNote = _resolveDefaultNote(
        rawNote: note,
        trxType: trxType,
        isSplitTalangan: isSplitTalangan,
        newContactName: newContactName,
      );

      final int newTrxId = await txn.insert('transactions', <String, Object?>{
        'id': transactionId,
        'wallet_id': walletId,
        'target_wallet_id': null,
        'category_id':
            (trxType == 'EXPENSE' || trxType == 'INCOME') ? categoryId : null,
        'trx_type': trxType,
        'total_wallet_amount': totalWalletAmount,
        'pure_consumption_amount': pureConsumption,
        'note': cleanNote,
        'trx_date': DateFormatter.toIsoDate(trxDate),
      });

      final bool requiresContact = isSplitTalangan ||
          trxType == 'RECEIVABLE_OUT' ||
          trxType == 'DEBT_IN';
      if (requiresContact) {
        final int resolvedContactId = await _resolveOrCreateContact(
          txn,
          contactId: contactId,
          newContactName: newContactName,
        );
        final int debtPrincipal =
            isSplitTalangan ? friendShareAmount : totalWalletAmount;
        final String debtType =
            trxType == 'DEBT_IN' ? 'PAYABLE' : 'RECEIVABLE';

        await txn.insert('debts', <String, Object?>{
          'contact_id': resolvedContactId,
          'source_transaction_id': newTrxId,
          'debt_type': debtType,
          'principal_amount': debtPrincipal,
          'remaining_amount': debtPrincipal,
          'status': 'UNPAID',
          'due_date':
              dueDate != null ? DateFormatter.toIsoDate(dueDate) : null,
          'note': cleanNote,
        });

        await recalculateContactBalance(txn, resolvedContactId);
      }
    });
  }

  Future<void> _rollbackAndDeleteInTxn(
    Transaction txn,
    int transactionId,
  ) async {
    final List<Map<String, Object?>> trxRows = await txn.query(
      'transactions',
      where: 'id = ?',
      whereArgs: <Object>[transactionId],
      limit: 1,
    );
    if (trxRows.isEmpty) {
      return;
    }

    final Map<String, Object?> trx = trxRows.first;
    final String trxType = (trx['trx_type'] as String?) ?? 'EXPENSE';
    final int? walletId = trx['wallet_id'] as int?;
    final int? targetWalletId = trx['target_wallet_id'] as int?;
    final int amount = (trx['total_wallet_amount'] as int?) ?? 0;

    // Cek apakah transaksi memiliki item hutang/piutang terkait
    final List<Map<String, Object?>> linkedDebts = await txn.query(
      'debts',
      where: 'source_transaction_id = ?',
      whereArgs: <Object>[transactionId],
    );

    final Set<int> affectedContactIds = <int>{};
    for (final Map<String, Object?> debt in linkedDebts) {
      final int debtId = (debt['id'] as int?) ?? 0;
      final int principal = (debt['principal_amount'] as int?) ?? 0;
      final int remaining = (debt['remaining_amount'] as int?) ?? 0;
      final int? cId = debt['contact_id'] as int?;
      if (cId != null) {
        affectedContactIds.add(cId);
      }

      final List<Map<String, Object?>> payments = await txn.query(
        'debt_payments',
        where: 'debt_id = ?',
        whereArgs: <Object>[debtId],
        limit: 1,
      );
      if (payments.isNotEmpty || remaining < principal) {
        throw const AppException(
          AppErrorCode.transactionLockedHasInstallments,
        );
      }
    }

    // Cek juga apakah transaksi ini adalah transaksi pembayaran cicilan
    final List<Map<String, Object?>> asPayment = await txn.query(
      'debt_payments',
      where: 'payment_transaction_id = ?',
      whereArgs: <Object>[transactionId],
      limit: 1,
    );
    if (asPayment.isNotEmpty) {
      throw const AppException(AppErrorCode.transactionLockedHasInstallments);
    }

    // Rollback saldo dompet
    if (walletId != null && amount > 0) {
      final int currentBal = await _getWalletBalance(txn, walletId);
      if (trxType == 'EXPENSE' || trxType == 'RECEIVABLE_OUT') {
        await txn.update(
          'wallets',
          <String, Object?>{'current_balance': currentBal + amount},
          where: 'id = ?',
          whereArgs: <Object>[walletId],
        );
      } else if (trxType == 'INCOME' || trxType == 'DEBT_IN') {
        await txn.update(
          'wallets',
          <String, Object?>{'current_balance': currentBal - amount},
          where: 'id = ?',
          whereArgs: <Object>[walletId],
        );
      } else if (trxType == 'TRANSFER' && targetWalletId != null) {
        final int targetBal = await _getWalletBalance(txn, targetWalletId);
        await txn.update(
          'wallets',
          <String, Object?>{'current_balance': currentBal + amount},
          where: 'id = ?',
          whereArgs: <Object>[walletId],
        );
        await txn.update(
          'wallets',
          <String, Object?>{'current_balance': targetBal - amount},
          where: 'id = ?',
          whereArgs: <Object>[targetWalletId],
        );
      }
    }

    await txn.delete(
      'debts',
      where: 'source_transaction_id = ?',
      whereArgs: <Object>[transactionId],
    );
    await txn.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: <Object>[transactionId],
    );

    for (final int cId in affectedContactIds) {
      await recalculateContactBalance(txn, cId);
    }
  }

  Future<int> _getWalletBalance(Transaction txn, int walletId) async {
    final List<Map<String, Object?>> rows = await txn.query(
      'wallets',
      columns: <String>['current_balance'],
      where: 'id = ?',
      whereArgs: <Object>[walletId],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw const AppException(AppErrorCode.walletRequired);
    }
    return (rows.first['current_balance'] as int?) ?? 0;
  }

  Future<int> _resolveOrCreateContact(
    Transaction txn, {
    int? contactId,
    String? newContactName,
  }) async {
    if (contactId != null) {
      return contactId;
    }
    final String trimmed = (newContactName ?? '').trim();
    if (trimmed.isEmpty) {
      throw const AppException(AppErrorCode.contactRequired);
    }

    final List<Map<String, Object?>> existing = await txn.query(
      'contacts',
      where: 'LOWER(name) = ?',
      whereArgs: <Object>[trimmed.toLowerCase()],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      return (existing.first['id'] as int?) ?? 1;
    }

    return txn.insert('contacts', <String, Object?>{
      'name': trimmed,
      'phone_note': '',
      'net_balance': 0,
      'trust_badge': 'GOOD',
      'late_count': 0,
    });
  }

  static Future<void> recalculateContactBalance(
    DatabaseExecutor txn,
    int contactId,
  ) async {
    final List<Map<String, Object?>> openDebts = await txn.query(
      'debts',
      where: "contact_id = ? AND status != 'PAID'",
      whereArgs: <Object>[contactId],
    );

    int receivable = 0;
    int payable = 0;
    for (final Map<String, Object?> row in openDebts) {
      final int rem = (row['remaining_amount'] as int?) ?? 0;
      if (row['debt_type'] == 'RECEIVABLE') {
        receivable += rem;
      } else {
        payable += rem;
      }
    }

    await txn.update(
      'contacts',
      <String, Object?>{'net_balance': receivable - payable},
      where: 'id = ?',
      whereArgs: <Object>[contactId],
    );
  }

  String _resolveDefaultNote({
    required String? rawNote,
    required String trxType,
    required bool isSplitTalangan,
    required String? newContactName,
  }) {
    final String trimmed = (rawNote ?? '').trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
    final String contactSuffix =
        (newContactName != null && newContactName.trim().isNotEmpty)
            ? ' (${newContactName.trim()})'
            : '';
    if (isSplitTalangan) {
      return 'Pengeluaran + Talangan$contactSuffix';
    }
    switch (trxType) {
      case 'INCOME':
        return 'Pemasukan Kas';
      case 'RECEIVABLE_OUT':
        return 'Pinjamkan ke Teman$contactSuffix';
      case 'DEBT_IN':
        return 'Pinjam dari Teman$contactSuffix';
      default:
        return 'Pengeluaran Kas';
    }
  }
}
