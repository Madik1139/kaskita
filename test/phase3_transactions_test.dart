import 'package:flutter_test/flutter_test.dart';
import 'package:kaskita/core/database/database_helper.dart';
import 'package:kaskita/core/errors/app_exception.dart';
import 'package:kaskita/features/transactions/data/transaction_query_repository.dart';
import 'package:kaskita/features/transactions/data/transaction_repository.dart';
import 'package:kaskita/features/transactions/models/transaction_model.dart';
import 'package:kaskita/features/wallets/data/wallet_repository.dart';
import 'package:kaskita/features/wallets/models/wallet_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Fase 3: Input Satu Pintu, Talangan Teman, Rollback & Money Manager',
      () {
    late Database db;
    late WalletRepository walletRepo;
    late TransactionRepository trxRepo;
    late TransactionQueryRepository queryRepo;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onConfigure: (Database d) async {
            await d.execute('PRAGMA foreign_keys = ON;');
          },
          onCreate: DatabaseHelper.createSchemaAndSeed,
        ),
      );
      DatabaseHelper.overrideForTest(db);
      walletRepo = WalletRepository(DatabaseHelper.instance);
      trxRepo = TransactionRepository(DatabaseHelper.instance);
      queryRepo = TransactionQueryRepository(DatabaseHelper.instance);

      // Mulai dengan Saldo Dompet Tunai Rp 500.000
      await walletRepo.completeOnboarding(initialCashBalance: 500000);
    });

    tearDown(() async {
      await db.close();
    });

    test(
      '1. Split Expense (Talangi Teman): memisahkan Kas Keluar vs Konsumsi Murni & membuat Piutang',
      () async {
        // Bayar makan Rp 60.000, talangi Riko Rp 30.000
        final int trxId = await trxRepo.recordTransaction(
          trxType: 'EXPENSE',
          walletId: 1,
          categoryId: 1,
          totalWalletAmount: 60000,
          trxDate: DateTime(2026, 11, 13),
          note: 'Makan Siang Bareng Riko',
          isSplitTalangan: true,
          friendShareAmount: 30000,
          newContactName: 'Riko Pratama',
        );

        expect(trxId, greaterThan(0));

        // Verifikasi indikator keuangan:
        // - Saldo Dompet Tunai: 500.000 - 60.000 = 440.000
        // - Piutang Aktif Riko: +30.000
        // - Kekayaan Bersih (Net Worth): 440.000 + 30.000 = 470.000 (hanya berkurang 30.000 konsumsi pribadi!)
        final FinancialIndicatorsModel indicators =
            await walletRepo.calculateIndicators();
        expect(indicators.totalWalletBalance, 440000);
        expect(indicators.activeReceivables, 30000);
        expect(indicators.netWorth, 470000);

        final List<ContactOptionModel> contacts = await trxRepo.getContacts();
        expect(contacts.length, 1);
        expect(contacts.first.name, 'Riko Pratama');
        expect(contacts.first.netBalance, 30000);

        // Verifikasi pengelompokan Harian & Bulanan Money Manager
        final List<TransactionItemModel> monthItems =
            await queryRepo.getTransactionsByMonth(year: 2026, month: 11);
        expect(monthItems.length, 1);
        expect(monthItems.first.totalWalletAmount, 60000);
        expect(monthItems.first.pureConsumptionAmount, 30000);
        expect(monthItems.first.isSplitTalangan, isTrue);

        final List<DailyTransactionGroupModel> groups =
            TransactionQueryRepository.groupTransactionsByDay(monthItems);
        expect(groups.length, 1);
        expect(groups.first.totalPureExpense, 30000);

        final List<MonthlySummaryModel> yearly =
            await queryRepo.getYearlyMonthlySummaries(year: 2026);
        final MonthlySummaryModel novSummary =
            yearly.firstWhere((MonthlySummaryModel m) => m.month == 11);
        expect(novSummary.totalPureExpense, 30000);
        expect(novSummary.weeks.isNotEmpty, isTrue);
      },
    );

    test(
      '2. Piutang Keluar (RECEIVABLE_OUT) & Hutang Masuk (DEBT_IN) tidak mengotori konsumsi murni',
      () async {
        // Pinjamkan Rp 100.000 ke Budi
        await trxRepo.recordTransaction(
          trxType: 'RECEIVABLE_OUT',
          walletId: 1,
          totalWalletAmount: 100000,
          trxDate: DateTime(2026, 11, 13),
          newContactName: 'Budi Santoso',
        );

        // Pinjam Rp 50.000 dari Andi
        await trxRepo.recordTransaction(
          trxType: 'DEBT_IN',
          walletId: 1,
          totalWalletAmount: 50000,
          trxDate: DateTime(2026, 11, 13),
          newContactName: 'Andi Wijaya',
        );

        // Saldo Dompet: 500.000 - 100.000 + 50.000 = 450.000
        // Dana Aman (Safe to Spend): 450.000 - 50.000 (Hutang ke Andi) = 400.000
        // Kekayaan Bersih: 450.000 + 100.000 - 50.000 = 500.000 (Tetap Rp 500.000!)
        final FinancialIndicatorsModel ind =
            await walletRepo.calculateIndicators();
        expect(ind.totalWalletBalance, 450000);
        expect(ind.safeToSpend, 400000);
        expect(ind.netWorth, 500000);
      },
    );

    test(
      '3. Rollback Safety: Edit & Hapus mengembalikan saldo, serta terkunci jika sudah ada cicilan',
      () async {
        final int trxId = await trxRepo.recordTransaction(
          trxType: 'EXPENSE',
          walletId: 1,
          categoryId: 1,
          totalWalletAmount: 80000,
          trxDate: DateTime(2026, 11, 13),
          isSplitTalangan: true,
          friendShareAmount: 40000,
          newContactName: 'Riko Pratama',
        );

        // Ubah transaksi menjadi Rp 50.000 (talangan Rp 20.000)
        await trxRepo.updateTransaction(
          transactionId: trxId,
          walletId: 1,
          categoryId: 1,
          totalWalletAmount: 50000,
          trxDate: DateTime(2026, 11, 13),
          isSplitTalangan: true,
          friendShareAmount: 20000,
          newContactName: 'Riko Pratama',
        );

        final FinancialIndicatorsModel afterEdit =
            await walletRepo.calculateIndicators();
        expect(afterEdit.totalWalletBalance, 450000); // 500rb - 50rb
        expect(afterEdit.activeReceivables, 20000);

        // Simulasikan ada cicilan masuk pada hutang tersebut -> transaksi harus terkunci!
        final List<Map<String, Object?>> debts = await db.query('debts');
        final int debtId = debts.first['id'] as int;
        await db.update(
          'debts',
          <String, Object?>{'remaining_amount': 10000, 'status': 'PARTIAL'},
          where: 'id = ?',
          whereArgs: <Object>[debtId],
        );

        await expectLater(
          trxRepo.deleteTransaction(trxId),
          throwsA(
            isA<AppException>().having(
              (AppException e) => e.code,
              'code',
              AppErrorCode.transactionLockedHasInstallments,
            ),
          ),
        );

        // Kembalikan status ke UNPAID lalu hapus transaksi -> saldo kembali penuh Rp 500.000
        await db.update(
          'debts',
          <String, Object?>{'remaining_amount': 20000, 'status': 'UNPAID'},
          where: 'id = ?',
          whereArgs: <Object>[debtId],
        );
        await trxRepo.deleteTransaction(trxId);

        final FinancialIndicatorsModel afterDelete =
            await walletRepo.calculateIndicators();
        expect(afterDelete.totalWalletBalance, 500000);
        expect(afterDelete.activeReceivables, 0);
      },
    );
  });
}
