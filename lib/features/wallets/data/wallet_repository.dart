import 'package:sqflite/sqflite.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/date_formatter.dart';
import '../models/wallet_model.dart';

class WalletRepository {
  const WalletRepository(this._dbHelper);

  final DatabaseHelper _dbHelper;

  Future<List<WalletModel>> getActiveWallets() async {
    final Database db = await _dbHelper.database;
    final List<Map<String, Object?>> rows = await db.query(
      'wallets',
      where: 'is_archived = 0',
      orderBy: 'id ASC',
    );
    return rows.map(WalletModel.fromMap).toList();
  }

  Future<FinancialIndicatorsModel> calculateIndicators({
    int? selectedWalletId,
  }) async {
    final Database db = await _dbHelper.database;
    final List<WalletModel> wallets = await getActiveWallets();
    final List<Map<String, Object?>> debtRows = await db.query(
      'debts',
      where: "status != 'PAID'",
    );

    int activeReceivables = 0;
    int activePayables = 0;
    for (final Map<String, Object?> row in debtRows) {
      final int rem = (row['remaining_amount'] as int?) ?? 0;
      if (row['debt_type'] == 'RECEIVABLE') {
        activeReceivables += rem;
      } else {
        activePayables += rem;
      }
    }

    return FinancialIndicatorsModel.calculate(
      wallets: wallets,
      activeReceivables: activeReceivables,
      activePayables: activePayables,
      selectedWalletId: selectedWalletId,
    );
  }

  Future<bool> isOnboardingPromptShown() async {
    final Database db = await _dbHelper.database;
    final List<Map<String, Object?>> rows = await db.query(
      'app_settings',
      where: 'setting_key = ?',
      whereArgs: <Object>[AppConstants.keyOnboardingPromptShown],
      limit: 1,
    );
    if (rows.isEmpty) {
      return false;
    }
    return rows.first['setting_value'] == '1';
  }

  Future<void> completeOnboarding({required int initialCashBalance}) async {
    if (initialCashBalance < 0) {
      throw const AppException(AppErrorCode.amountMustBePositive);
    }
    final Database db = await _dbHelper.database;
    await db.transaction((Transaction txn) async {
      final List<Map<String, Object?>> cashWallets = await txn.query(
        'wallets',
        where: "type = 'CASH' AND is_archived = 0",
        orderBy: 'id ASC',
        limit: 1,
      );
      if (cashWallets.isNotEmpty && initialCashBalance > 0) {
        final int cashId = (cashWallets.first['id'] as int?) ?? 1;
        await txn.update(
          'wallets',
          <String, Object?>{
            'initial_balance': initialCashBalance,
            'current_balance': initialCashBalance,
          },
          where: 'id = ?',
          whereArgs: <Object>[cashId],
        );
      }
      await txn.insert(
        'app_settings',
        <String, Object?>{
          'setting_key': AppConstants.keyOnboardingPromptShown,
          'setting_value': '1',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<WalletModel> createWallet({
    required String name,
    required String type,
    required int initialBalance,
  }) async {
    final String trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const AppException(AppErrorCode.walletNameRequired);
    }
    final Database db = await _dbHelper.database;
    final List<Map<String, Object?>> existing = await db.query(
      'wallets',
      where: 'LOWER(name) = LOWER(?) AND is_archived = 0',
      whereArgs: <Object>[trimmed],
    );
    if (existing.isNotEmpty) {
      throw const AppException(AppErrorCode.duplicateWalletName);
    }

    final int id = await db.insert('wallets', <String, Object?>{
      'name': trimmed,
      'type': type,
      'initial_balance': initialBalance,
      'current_balance': initialBalance,
      'is_archived': 0,
    });

    final List<Map<String, Object?>> created = await db.query(
      'wallets',
      where: 'id = ?',
      whereArgs: <Object>[id],
      limit: 1,
    );
    return WalletModel.fromMap(created.first);
  }

  Future<void> updateWallet({
    required int id,
    required String name,
    required String type,
    required int currentBalance,
  }) async {
    final String trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const AppException(AppErrorCode.walletNameRequired);
    }
    final Database db = await _dbHelper.database;
    final List<Map<String, Object?>> duplicate = await db.query(
      'wallets',
      where: 'LOWER(name) = LOWER(?) AND id != ? AND is_archived = 0',
      whereArgs: <Object>[trimmed, id],
    );
    if (duplicate.isNotEmpty) {
      throw const AppException(AppErrorCode.duplicateWalletName);
    }

    await db.update(
      'wallets',
      <String, Object?>{
        'name': trimmed,
        'type': type,
        'current_balance': currentBalance,
      },
      where: 'id = ?',
      whereArgs: <Object>[id],
    );
  }

  Future<void> archiveWallet(int id) async {
    final List<WalletModel> active = await getActiveWallets();
    if (active.length <= 1) {
      throw const AppException(AppErrorCode.cannotArchiveLastWallet);
    }
    final Database db = await _dbHelper.database;
    await db.update(
      'wallets',
      <String, Object?>{'is_archived': 1},
      where: 'id = ?',
      whereArgs: <Object>[id],
    );
  }

  /// Eksekusi Atomik Transfer Antar Dompet (`trx_type = 'TRANSFER'`).
  /// Tidak menambah pengeluaran atau pemasukan (`pure_consumption_amount = 0`).
  Future<void> transferBetweenWallets({
    required int sourceWalletId,
    required int targetWalletId,
    required int amount,
    required DateTime date,
    String? note,
  }) async {
    if (amount <= 0) {
      throw const AppException(AppErrorCode.amountMustBePositive);
    }
    if (sourceWalletId == targetWalletId) {
      throw const AppException(AppErrorCode.transferSameWallet);
    }

    final Database db = await _dbHelper.database;
    await db.transaction((Transaction txn) async {
      final List<Map<String, Object?>> sourceRows = await txn.query(
        'wallets',
        where: 'id = ? AND is_archived = 0',
        whereArgs: <Object>[sourceWalletId],
        limit: 1,
      );
      final List<Map<String, Object?>> targetRows = await txn.query(
        'wallets',
        where: 'id = ? AND is_archived = 0',
        whereArgs: <Object>[targetWalletId],
        limit: 1,
      );

      if (sourceRows.isEmpty || targetRows.isEmpty) {
        throw const AppException(AppErrorCode.walletRequired);
      }

      final WalletModel source = WalletModel.fromMap(sourceRows.first);
      final WalletModel target = WalletModel.fromMap(targetRows.first);

      if (source.currentBalance < amount) {
        throw const AppException(AppErrorCode.insufficientWalletBalance);
      }

      final String cleanNote = (note == null || note.trim().isEmpty)
          ? '${source.name} -> ${target.name}'
          : note.trim();

      await txn.insert('transactions', <String, Object?>{
        'wallet_id': sourceWalletId,
        'target_wallet_id': targetWalletId,
        'category_id': null,
        'trx_type': 'TRANSFER',
        'total_wallet_amount': amount,
        'pure_consumption_amount': 0,
        'note': cleanNote,
        'trx_date': DateFormatter.toIsoDate(date),
      });

      await txn.update(
        'wallets',
        <String, Object?>{'current_balance': source.currentBalance - amount},
        where: 'id = ?',
        whereArgs: <Object>[sourceWalletId],
      );

      await txn.update(
        'wallets',
        <String, Object?>{'current_balance': target.currentBalance + amount},
        where: 'id = ?',
        whereArgs: <Object>[targetWalletId],
      );
    });
  }
}

