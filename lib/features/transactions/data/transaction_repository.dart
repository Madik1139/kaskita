import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/errors/app_exception.dart';
import '../models/transaction_model.dart';
import 'transaction_rollback_helper.dart';

/// Repository SQLite untuk pencatatan transaksi cepat (< 5 detik),
/// Talangan Teman (Split Expense), dan Rollback Edit/Hapus.
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

    final int pureConsumption =
        TransactionRollbackHelper.computePureConsumption(
      trxType: trxType,
      totalWalletAmount: totalWalletAmount,
      isSplitTalangan: isSplitTalangan,
      friendShareAmount: friendShareAmount,
    );

    final bool requiresContact = isSplitTalangan ||
        trxType == 'RECEIVABLE_OUT' ||
        trxType == 'DEBT_IN';
    if (requiresContact &&
        contactId == null &&
        (newContactName == null || newContactName.trim().isEmpty)) {
      throw const AppException(AppErrorCode.contactRequired);
    }

    final Database db = await _dbHelper.database;
    return db.transaction<int>((Transaction txn) {
      return TransactionRollbackHelper.writeTransactionAndDebtInTxn(
        txn,
        trxType: trxType,
        walletId: walletId,
        totalWalletAmount: totalWalletAmount,
        pureConsumption: pureConsumption,
        trxDate: trxDate,
        categoryId: categoryId,
        note: note,
        isSplitTalangan: isSplitTalangan,
        friendShareAmount: friendShareAmount,
        contactId: contactId,
        newContactName: newContactName,
        dueDate: dueDate,
      );
    });
  }

  /// Menghapus transaksi beserta rollback otomatis saldo dompet & hutang.
  /// Ditolak jika transaksi talangan/hutang sudah memiliki cicilan masuk.
  Future<void> deleteTransaction(int transactionId) async {
    final Database db = await _dbHelper.database;
    await db.transaction((Transaction txn) async {
      await TransactionRollbackHelper.rollbackAndDeleteInTxn(
        txn,
        transactionId,
      );
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

      await TransactionRollbackHelper.rollbackAndDeleteInTxn(
        txn,
        transactionId,
      );

      final int pureConsumption =
          TransactionRollbackHelper.computePureConsumption(
        trxType: trxType,
        totalWalletAmount: totalWalletAmount,
        isSplitTalangan: isSplitTalangan,
        friendShareAmount: friendShareAmount,
      );

      await TransactionRollbackHelper.writeTransactionAndDebtInTxn(
        txn,
        fixedTransactionId: transactionId,
        trxType: trxType,
        walletId: walletId,
        totalWalletAmount: totalWalletAmount,
        pureConsumption: pureConsumption,
        trxDate: trxDate,
        categoryId: categoryId,
        note: note,
        isSplitTalangan: isSplitTalangan,
        friendShareAmount: friendShareAmount,
        contactId: contactId,
        newContactName: newContactName,
        dueDate: dueDate,
      );
    });
  }

  static Future<void> recalculateContactBalance(
    DatabaseExecutor txn,
    int contactId,
  ) =>
      TransactionRollbackHelper.recalculateContactBalance(txn, contactId);
}
