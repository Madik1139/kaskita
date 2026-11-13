import 'dart:math' as math;
import 'package:sqflite/sqflite.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/date_formatter.dart';
import '../../transactions/data/transaction_repository.dart';

/// Helper SQLite untuk operasi Auto-Netting dan Rollback Pembatalan Cicilan.
class DebtSettlementHelper {
  DebtSettlementHelper._();

  static Future<void> executeAutoNettingInTxn({
    required Transaction txn,
    required int contactId,
    required String newDebtType,
    required int amount,
    required DateTime date,
    String? note,
    DateTime? dueDate,
  }) async {
    if (amount <= 0) {
      throw const AppException(AppErrorCode.amountMustBePositive);
    }
    final String oppositeDebtType =
        newDebtType == 'RECEIVABLE' ? 'PAYABLE' : 'RECEIVABLE';
    final String isoDate = DateFormatter.toIsoDate(date);
    final String cleanNote = (note != null && note.trim().isNotEmpty)
        ? note.trim()
        : 'Potong Saldo Silang (Auto-Netting)';

    final List<Map<String, Object?>> oppositeDebts = await txn.query(
      'debts',
      where: "contact_id = ? AND debt_type = ? AND status != 'PAID'",
      whereArgs: <Object>[contactId, oppositeDebtType],
      orderBy: 'created_at ASC, id ASC',
    );

    int remainingToOffset = amount;
    for (final Map<String, Object?> row in oppositeDebts) {
      if (remainingToOffset <= 0) {
        break;
      }
      final int debtId = (row['id'] as int?) ?? 0;
      final int currentRem = (row['remaining_amount'] as int?) ?? 0;
      final int offsetAmount = math.min(remainingToOffset, currentRem);
      final int nextRem = currentRem - offsetAmount;

      await txn.update(
        'debts',
        <String, Object?>{
          'remaining_amount': nextRem,
          'status': nextRem == 0 ? 'PAID' : 'PARTIAL',
        },
        where: 'id = ?',
        whereArgs: <Object>[debtId],
      );

      await txn.insert('debt_payments', <String, Object?>{
        'debt_id': debtId,
        'payment_transaction_id': null,
        'settlement_method': 'AUTO_NETTING',
        'amount_paid': offsetAmount,
        'payment_date': isoDate,
        'note': cleanNote,
      });

      remainingToOffset -= offsetAmount;
    }

    if (remainingToOffset > 0) {
      await txn.insert('debts', <String, Object?>{
        'contact_id': contactId,
        'source_transaction_id': null,
        'debt_type': newDebtType,
        'principal_amount': remainingToOffset,
        'remaining_amount': remainingToOffset,
        'status': 'UNPAID',
        'due_date': dueDate != null ? DateFormatter.toIsoDate(dueDate) : null,
        'note': cleanNote,
      });
    }

    await TransactionRepository.recalculateContactBalance(txn, contactId);
  }

  static Future<void> cancelPaymentInTxn(
    Transaction txn,
    int paymentId,
  ) async {
    final List<Map<String, Object?>> payRows = await txn.query(
      'debt_payments',
      where: 'id = ?',
      whereArgs: <Object>[paymentId],
      limit: 1,
    );
    if (payRows.isEmpty) {
      return;
    }

    final Map<String, Object?> pay = payRows.first;
    final int debtId = (pay['debt_id'] as int?) ?? 0;
    final int amountPaid = (pay['amount_paid'] as int?) ?? 0;
    final int? payTrxId = pay['payment_transaction_id'] as int?;

    final List<Map<String, Object?>> debtRows = await txn.query(
      'debts',
      where: 'id = ?',
      whereArgs: <Object>[debtId],
      limit: 1,
    );
    if (debtRows.isEmpty) {
      return;
    }
    final Map<String, Object?> debt = debtRows.first;
    final int contactId = (debt['contact_id'] as int?) ?? 0;
    final int principal = (debt['principal_amount'] as int?) ?? 0;
    final int currentRem = (debt['remaining_amount'] as int?) ?? 0;
    final int restoredRem = math.min(principal, currentRem + amountPaid);

    await txn.update(
      'debts',
      <String, Object?>{
        'remaining_amount': restoredRem,
        'status': restoredRem == principal ? 'UNPAID' : 'PARTIAL',
      },
      where: 'id = ?',
      whereArgs: <Object>[debtId],
    );

    await txn.delete(
      'debt_payments',
      where: 'id = ?',
      whereArgs: <Object>[paymentId],
    );

    if (payTrxId != null) {
      final List<Map<String, Object?>> otherUses = await txn.query(
        'debt_payments',
        where: 'payment_transaction_id = ?',
        whereArgs: <Object>[payTrxId],
        limit: 1,
      );
      final List<Map<String, Object?>> trxRows = await txn.query(
        'transactions',
        where: 'id = ?',
        whereArgs: <Object>[payTrxId],
        limit: 1,
      );
      if (trxRows.isNotEmpty) {
        final Map<String, Object?> trx = trxRows.first;
        final int? walletId = trx['wallet_id'] as int?;
        final String trxType = (trx['trx_type'] as String?) ?? '';
        final int currentTrxAmt = (trx['total_wallet_amount'] as int?) ?? 0;

        if (walletId != null && amountPaid > 0) {
          final List<Map<String, Object?>> wRows = await txn.query(
            'wallets',
            where: 'id = ?',
            whereArgs: <Object>[walletId],
            limit: 1,
          );
          if (wRows.isNotEmpty) {
            final int wBal = (wRows.first['current_balance'] as int?) ?? 0;
            final int nextWBal = trxType == 'RECEIVABLE_SETTLE'
                ? wBal - amountPaid
                : wBal + amountPaid;
            await txn.update(
              'wallets',
              <String, Object?>{'current_balance': nextWBal},
              where: 'id = ?',
              whereArgs: <Object>[walletId],
            );
          }
        }

        if (otherUses.isEmpty) {
          await txn.delete(
            'transactions',
            where: 'id = ?',
            whereArgs: <Object>[payTrxId],
          );
        } else {
          await txn.update(
            'transactions',
            <String, Object?>{
              'total_wallet_amount': math.max(0, currentTrxAmt - amountPaid),
            },
            where: 'id = ?',
            whereArgs: <Object>[payTrxId],
          );
        }
      }
    }

    await TransactionRepository.recalculateContactBalance(txn, contactId);
  }
}
