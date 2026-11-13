import 'package:sqflite/sqflite.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/date_formatter.dart';

/// Helper internal SQLite untuk rollback transaksi, validasi saldo dompet,
/// serta resolusi/rekalkulasi saldo bersih kontak saat edit atau hapus.
class TransactionRollbackHelper {
  TransactionRollbackHelper._();

  static int computePureConsumption({
    required String trxType,
    required int totalWalletAmount,
    required bool isSplitTalangan,
    required int friendShareAmount,
  }) {
    if (trxType == 'EXPENSE') {
      if (isSplitTalangan) {
        if (friendShareAmount <= 0) {
          throw const AppException(AppErrorCode.amountMustBePositive);
        }
        if (friendShareAmount > totalWalletAmount) {
          throw const AppException(AppErrorCode.splitAmountExceedsTotal);
        }
        return totalWalletAmount - friendShareAmount;
      }
      return totalWalletAmount;
    }
    if (trxType == 'INCOME') {
      return totalWalletAmount;
    }
    return 0;
  }

  static Future<void> rollbackAndDeleteInTxn(
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

    final List<Map<String, Object?>> asPayment = await txn.query(
      'debt_payments',
      where: 'payment_transaction_id = ?',
      whereArgs: <Object>[transactionId],
      limit: 1,
    );
    if (asPayment.isNotEmpty) {
      throw const AppException(AppErrorCode.transactionLockedHasInstallments);
    }

    if (walletId != null && amount > 0) {
      final int currentBal = await getWalletBalance(txn, walletId);
      if (trxType == 'EXPENSE' || trxType == 'RECEIVABLE_OUT') {
        await updateWalletBalance(txn, walletId, currentBal + amount);
      } else if (trxType == 'INCOME' || trxType == 'DEBT_IN') {
        await updateWalletBalance(txn, walletId, currentBal - amount);
      } else if (trxType == 'TRANSFER' && targetWalletId != null) {
        final int targetBal = await getWalletBalance(txn, targetWalletId);
        await updateWalletBalance(txn, walletId, currentBal + amount);
        await updateWalletBalance(txn, targetWalletId, targetBal - amount);
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

  static Future<int> getWalletBalance(Transaction txn, int walletId) async {
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

  static Future<void> updateWalletBalance(
    Transaction txn,
    int walletId,
    int nextBalance,
  ) async {
    await txn.update(
      'wallets',
      <String, Object?>{'current_balance': nextBalance},
      where: 'id = ?',
      whereArgs: <Object>[walletId],
    );
  }

  static Future<int> resolveOrCreateContact(
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

  static String resolveDefaultNote({
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

  static Future<int> writeTransactionAndDebtInTxn(
    Transaction txn, {
    int? fixedTransactionId,
    required String trxType,
    required int walletId,
    required int totalWalletAmount,
    required int pureConsumption,
    required DateTime trxDate,
    int? categoryId,
    String? note,
    required bool isSplitTalangan,
    required int friendShareAmount,
    int? contactId,
    String? newContactName,
    DateTime? dueDate,
  }) async {
    final int currentWalletBalance = await getWalletBalance(txn, walletId);
    final bool isOutflow =
        trxType == 'EXPENSE' || trxType == 'RECEIVABLE_OUT';
    if (isOutflow && currentWalletBalance < totalWalletAmount) {
      throw const AppException(AppErrorCode.insufficientWalletBalance);
    }

    final int nextWalletBalance = isOutflow
        ? currentWalletBalance - totalWalletAmount
        : currentWalletBalance + totalWalletAmount;
    await updateWalletBalance(txn, walletId, nextWalletBalance);

    final String cleanNote = resolveDefaultNote(
      rawNote: note,
      trxType: trxType,
      isSplitTalangan: isSplitTalangan,
      newContactName: newContactName,
    );

    final Map<String, Object?> payload = <String, Object?>{
      'id': ?fixedTransactionId,
      'wallet_id': walletId,
      'target_wallet_id': null,
      'category_id':
          (trxType == 'EXPENSE' || trxType == 'INCOME') ? categoryId : null,
      'trx_type': trxType,
      'total_wallet_amount': totalWalletAmount,
      'pure_consumption_amount': pureConsumption,
      'note': cleanNote,
      'trx_date': DateFormatter.toIsoDate(trxDate),
    };
    final int trxId = await txn.insert('transactions', payload);

    final bool requiresContact = isSplitTalangan ||
        trxType == 'RECEIVABLE_OUT' ||
        trxType == 'DEBT_IN';
    if (requiresContact) {
      final int resolvedContactId = await resolveOrCreateContact(
        txn,
        contactId: contactId,
        newContactName: newContactName,
      );
      final int debtPrincipal =
          isSplitTalangan ? friendShareAmount : totalWalletAmount;
      final String debtType = trxType == 'DEBT_IN' ? 'PAYABLE' : 'RECEIVABLE';

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
  }
}
