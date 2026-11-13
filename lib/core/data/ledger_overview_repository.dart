import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../errors/app_exception.dart';
import '../models/ledger_summary_model.dart';

/// Repository yang menangani pembacaan ringkasan buku kas dan aksi Demo Data
/// sehingga lapisan UI bebas 100% dari pemanggilan SQLite langsung.
class LedgerOverviewRepository {
  const LedgerOverviewRepository(this._dbHelper);

  final DatabaseHelper _dbHelper;

  Future<LedgerOverviewState> fetchOverview() async {
    try {
      final Database db = await _dbHelper.database;

      final List<Map<String, Object?>> wallets = await db.query(
        'wallets',
        where: 'is_archived = 0',
      );
      final List<Map<String, Object?>> categories =
          await db.query('categories');
      final List<Map<String, Object?>> contacts = await db.query('contacts');
      final List<Map<String, Object?>> debts = await db.query(
        'debts',
        where: "status != 'PAID'",
      );
      final List<Map<String, Object?>> trxs = await db.rawQuery('''
        SELECT t.*, w.name AS wallet_name, c.name AS category_name
        FROM transactions t
        LEFT JOIN wallets w ON t.wallet_id = w.id
        LEFT JOIN categories c ON t.category_id = c.id
        ORDER BY t.trx_date DESC, t.id DESC
      ''');

      int totalWallet = 0;
      for (final Map<String, Object?> w in wallets) {
        totalWallet += (w['current_balance'] as int?) ?? 0;
      }

      int activeReceivables = 0;
      int activePayables = 0;
      for (final Map<String, Object?> d in debts) {
        final int rem = (d['remaining_amount'] as int?) ?? 0;
        if (d['debt_type'] == 'RECEIVABLE') {
          activeReceivables += rem;
        } else {
          activePayables += rem;
        }
      }

      return LedgerOverviewState(
        walletBalance: totalWallet,
        safeToSpend: totalWallet - activePayables,
        netWorth: totalWallet + activeReceivables - activePayables,
        walletCount: wallets.length,
        categoryCount: categories.length,
        contactCount: contacts.length,
        recentTransactions: trxs.map(LedgerPreviewItem.fromMap).toList(),
      );
    } catch (e) {
      throw AppException(
        AppErrorCode.databaseOperation,
        technicalDetails: e.toString(),
      );
    }
  }

  Future<void> seedDemoData() async {
    try {
      await _dbHelper.seedDemoData();
    } catch (e) {
      throw AppException(
        AppErrorCode.databaseOperation,
        technicalDetails: e.toString(),
      );
    }
  }

  Future<void> resetAllData() async {
    try {
      await _dbHelper.resetAllData();
    } catch (e) {
      throw AppException(
        AppErrorCode.databaseOperation,
        technicalDetails: e.toString(),
      );
    }
  }
}
