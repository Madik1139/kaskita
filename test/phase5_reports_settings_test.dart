import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaskita/core/database/database_helper.dart';
import 'package:kaskita/core/errors/app_exception.dart';
import 'package:kaskita/features/debts/data/debt_repository.dart';
import 'package:kaskita/features/debts/models/debt_models.dart';
import 'package:kaskita/features/reports/data/report_repository.dart';
import 'package:kaskita/features/reports/models/report_models.dart';
import 'package:kaskita/features/settings/data/app_security_service.dart';
import 'package:kaskita/features/settings/data/backup_restore_service.dart';
import 'package:kaskita/features/settings/models/settings_models.dart';
import 'package:kaskita/features/transactions/data/transaction_repository.dart';
import 'package:kaskita/features/wallets/data/wallet_repository.dart';
import 'package:kaskita/features/wallets/models/wallet_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Fase 5: Reports, Backup/Restore, CSV, PIN Security & OTA Semver', () {
    late Database db;
    late WalletRepository walletRepo;
    late TransactionRepository trxRepo;
    late DebtRepository debtRepo;
    late ReportRepository reportRepo;
    late BackupRestoreService backupService;
    late AppSecurityService securityService;

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
      debtRepo = DebtRepository(DatabaseHelper.instance);
      reportRepo = ReportRepository(DatabaseHelper.instance);
      backupService = BackupRestoreService(DatabaseHelper.instance);
      securityService = AppSecurityService(DatabaseHelper.instance);

      await walletRepo.completeOnboarding(initialCashBalance: 1000000);
    });

    tearDown(() async {
      await db.close();
    });

    test(
      '1. ReportRepository memisahkan Konsumsi Murni vs Uang Tertahan (6 Bulan & Kategori)',
      () async {
        // Bulan Oktober 2026: Pengeluaran talangan Rp 100rb (konsumsi 40rb, piutang Riko 60rb)
        await trxRepo.recordTransaction(
          trxType: 'EXPENSE',
          walletId: 1,
          categoryId: 1,
          totalWalletAmount: 100000,
          trxDate: DateTime(2026, 10, 12),
          note: 'Makan Riko',
          isSplitTalangan: true,
          friendShareAmount: 60000,
          newContactName: 'Riko',
        );

        // Bulan November 2026:
        // - Kategori 1 konsumsi murni Rp 150.000
        // - Kategori 2 konsumsi murni Rp 50.000
        // - Piutang langsung (RECEIVABLE_OUT) Rp 200.000 (bukan konsumsi)
        await trxRepo.recordTransaction(
          trxType: 'EXPENSE',
          walletId: 1,
          categoryId: 1,
          totalWalletAmount: 150000,
          trxDate: DateTime(2026, 11, 5),
          note: 'Belanja Harian',
        );
        await trxRepo.recordTransaction(
          trxType: 'EXPENSE',
          walletId: 1,
          categoryId: 2,
          totalWalletAmount: 50000,
          trxDate: DateTime(2026, 11, 8),
          note: 'Transportasi',
        );
        await trxRepo.recordTransaction(
          trxType: 'RECEIVABLE_OUT',
          walletId: 1,
          totalWalletAmount: 200000,
          trxDate: DateTime(2026, 11, 10),
          note: 'Pinjamkan ke Riko',
          newContactName: 'Riko',
        );

        final List<MonthlyComparisonPoint> trend =
            await reportRepo.getSixMonthComparison(
          endPeriod: DateTime(2026, 11, 1),
        );
        expect(trend.length, 6);

        final MonthlyComparisonPoint octPoint = trend[4];
        expect(octPoint.year, 2026);
        expect(octPoint.month, 10);
        expect(octPoint.pureExpense, 40000);
        expect(octPoint.receivableLent, 60000);

        final MonthlyComparisonPoint novPoint = trend[5];
        expect(novPoint.year, 2026);
        expect(novPoint.month, 11);
        expect(novPoint.pureExpense, 200000);
        expect(novPoint.receivableLent, 200000);

        final List<CategoryBreakdownItem> breakdown =
            await reportRepo.getCategoryBreakdown(year: 2026, month: 11);
        expect(breakdown.length, 2);
        expect(breakdown.first.totalAmount, 150000);
        expect(breakdown.first.percentage, closeTo(75.0, 0.01));
        expect(breakdown[1].totalAmount, 50000);
        expect(breakdown[1].percentage, closeTo(25.0, 0.01));
      },
    );

    test(
      '2. Backup & Restore JSON menjaga integritas 100%, validasi skema, & ekspor CSV',
      () async {
        // Buat data transaksi & hutang
        await trxRepo.recordTransaction(
          trxType: 'EXPENSE',
          walletId: 1,
          categoryId: 1,
          totalWalletAmount: 120000,
          trxDate: DateTime(2026, 11, 12),
          note: 'Makan Bersama Andi',
          isSplitTalangan: true,
          friendShareAmount: 70000,
          newContactName: 'Andi',
        );

        final List<ContactSummaryModel> contactsBefore =
            await debtRepo.getContactsSummary();
        expect(contactsBefore.first.netBalance, 70000);

        final FinancialIndicatorsModel indBefore =
            await walletRepo.calculateIndicators();
        expect(indBefore.totalWalletBalance, 880000);

        // Ekspor JSON & CSV
        final String jsonBackup = await backupService.buildJsonBackupString();
        final String csvOutput = await backupService.buildTransactionsCsv();
        expect(csvOutput, contains('Makan Bersama Andi'));
        expect(csvOutput, contains('120000'));
        expect(csvOutput, contains('50000'));

        // Hapus seluruh data lalu pulihkan dari JSON
        await DatabaseHelper.instance.resetAllData();
        final FinancialIndicatorsModel indAfterReset =
            await walletRepo.calculateIndicators();
        expect(indAfterReset.totalWalletBalance, 0);

        await backupService.restoreFromJsonString(jsonBackup);

        final FinancialIndicatorsModel indRestored =
            await walletRepo.calculateIndicators();
        expect(indRestored.totalWalletBalance, 880000);
        expect(indRestored.activeReceivables, 70000);

        final List<ContactSummaryModel> contactsAfter =
            await debtRepo.getContactsSummary();
        expect(contactsAfter.length, 1);
        expect(contactsAfter.first.name, 'Andi');
        expect(contactsAfter.first.netBalance, 70000);

        // Uji validasi skema salah melempar AppException(backupRestoreFailed)
        await expectLater(
          () => backupService.restoreFromJsonString('{"app":"Other","schema_version":99}'),
          throwsA(
            isA<AppException>().having(
              (AppException e) => e.code,
              'code',
              AppErrorCode.backupRestoreFailed,
            ),
          ),
        );
      },
    );

    test(
      '3. AppSecurityService menyimpan PIN, memvalidasi PIN salah, serta tema & bahasa persisten',
      () async {
        await securityService.saveAppPin('258014');
        final AppSecurityConfigModel cfgActive =
            await securityService.getSecurityConfig();
        expect(cfgActive.appLockEnabled, isTrue);
        expect(cfgActive.hasPinConfigured, isTrue);

        expect(await securityService.verifyPin('258014'), isTrue);

        await expectLater(
          () => securityService.verifyPin('000000'),
          throwsA(
            isA<AppException>().having(
              (AppException e) => e.code,
              'code',
              AppErrorCode.pinInvalid,
            ),
          ),
        );

        await securityService.disableAppLock();
        final AppSecurityConfigModel cfgOff =
            await securityService.getSecurityConfig();
        expect(cfgOff.appLockEnabled, isFalse);

        // Uji persistensi Tema & Bahasa
        await securityService.saveThemeMode(ThemeMode.dark);
        await securityService.saveLocale(const Locale('en'));
        expect(await securityService.loadSavedThemeMode(), ThemeMode.dark);
        expect(
          (await securityService.loadSavedLocale()).languageCode,
          'en',
        );
      },
    );

    test(
      '4. OtaReleaseCheckResult.isNewerVersion membandingkan semver dengan benar',
      () {
        expect(OtaReleaseCheckResult.isNewerVersion('v0.6.0', '0.5.0'), isTrue);
        expect(
          OtaReleaseCheckResult.isNewerVersion('v0.6.1+7', '0.6.0'),
          isTrue,
        );
        expect(
          OtaReleaseCheckResult.isNewerVersion('v0.5.0', '0.5.0'),
          isFalse,
        );
        expect(
          OtaReleaseCheckResult.isNewerVersion('0.6.0+6', '0.6.0'),
          isFalse,
        );
        expect(
          OtaReleaseCheckResult.isNewerVersion('v1.0.0', '0.6.0'),
          isTrue,
        );
      },
    );
  });
}
