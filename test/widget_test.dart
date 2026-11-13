import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaskita/core/database/database_helper.dart';
import 'package:kaskita/core/errors/app_exception.dart';
import 'package:kaskita/core/utils/currency_formatter.dart';
import 'package:kaskita/core/utils/date_formatter.dart';
import 'package:kaskita/core/utils/localization_helper.dart';
import 'package:kaskita/core/widgets/custom_numpad.dart';
import 'package:kaskita/core/widgets/status_badge.dart';
import 'package:kaskita/core/widgets/tabular_currency_text.dart';
import 'package:kaskita/features/wallets/data/category_repository.dart';
import 'package:kaskita/features/wallets/data/wallet_repository.dart';
import 'package:kaskita/features/wallets/models/category_model.dart';
import 'package:kaskita/features/wallets/models/wallet_model.dart';
import 'package:kaskita/l10n/app_localizations_en.dart';
import 'package:kaskita/l10n/app_localizations_id.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('1. CurrencyFormatter & Bilingual DateFormatter Tests', () {
    test('Format Rupiah standar, tanda plus/minus, dan format ringkas', () {
      expect(CurrencyFormatter.format(150000), 'Rp 150.000');
      expect(CurrencyFormatter.format(50000, showPlusSign: true), '+Rp 50.000');
      expect(CurrencyFormatter.format(-25000), '-Rp 25.000');
      expect(CurrencyFormatter.formatCompact(50000), '50rb');
      expect(CurrencyFormatter.formatCompact(1500000), '1,5jt');
    });

    test(
      'Format Tanggal Gaya Money Manager mendukung Bahasa Indonesia (id) & Inggris (en)',
      () {
        final DateTime date = DateTime(2026, 8, 14); // Jumat, 14 Agu 2026
        expect(DateFormatter.toIsoDate(date), '2026-08-14');
        expect(DateFormatter.dayNumber(date), '14');
        expect(DateFormatter.shortDayName(date, localeCode: 'id'), 'Jum');
        expect(DateFormatter.shortDayName(date, localeCode: 'en'), 'Fri');
        expect(DateFormatter.mediumDate(date, localeCode: 'id'), '14 Agu 2026');
        expect(DateFormatter.mediumDate(date, localeCode: 'en'), '14 Aug 2026');
        expect(
          DateFormatter.fullMonthYear(date, localeCode: 'id'),
          'Agustus 2026',
        );
        expect(
          DateFormatter.fullMonthYear(date, localeCode: 'en'),
          'August 2026',
        );
      },
    );
  });

  group('2. Bilingual Localization (ID & EN) & Localized Error Messages Tests',
      () {
    test(
      'AppException menerjemahkan pesan error sesuai bahasa yang dipilih (ID vs EN)',
      () {
        final AppLocalizationsId l10nId = AppLocalizationsId();
        final AppLocalizationsEn l10nEn = AppLocalizationsEn();

        const AppException errZero =
            AppException(AppErrorCode.amountMustBePositive);
        expect(
          AppException.resolveError(errZero, l10nId),
          'Nominal harus lebih besar dari Rp 0.',
        );
        expect(
          AppException.resolveError(errZero, l10nEn),
          'Amount must be greater than Rp 0.',
        );

        const AppException errDupWallet =
            AppException(AppErrorCode.duplicateWalletName);
        expect(
          AppException.resolveError(errDupWallet, l10nId),
          contains('Nama dompet sudah digunakan'),
        );
        expect(
          AppException.resolveError(errDupWallet, l10nEn),
          contains('Wallet name is already in use'),
        );

        const AppException errLocked =
            AppException(AppErrorCode.transactionLockedHasInstallments);
        expect(
          AppException.resolveError(errLocked, l10nId),
          contains('sudah memiliki riwayat cicilan'),
        );
        expect(
          AppException.resolveError(errLocked, l10nEn),
          contains('already has installment records'),
        );
      },
    );

    test(
      'LocalizationHelper menerjemahkan Dompet Default & Kategori Bawaan (ID vs EN)',
      () {
        final AppLocalizationsId l10nId = AppLocalizationsId();
        final AppLocalizationsEn l10nEn = AppLocalizationsEn();

        expect(
          LocalizationHelper.localizeWalletName('Dompet Tunai', l10nId),
          'Dompet Tunai',
        );
        expect(
          LocalizationHelper.localizeWalletName('Dompet Tunai', l10nEn),
          'Cash Wallet',
        );
        expect(
          LocalizationHelper.localizeCategoryName('Makan & Minum', l10nId),
          'Makan & Minum',
        );
        expect(
          LocalizationHelper.localizeCategoryName('Makan & Minum', l10nEn),
          'Food & Drink',
        );
      },
    );
  });

  group('3. SQLite DatabaseHelper Schema, Seeding & DemoData Tests', () {
    late Database db;

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
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'Seeding awal membuat 1 Dompet Tunai, 10 Kategori Default, dan 5 Settings (termasuk app_locale)',
      () async {
        final List<Map<String, Object?>> wallets = await db.query('wallets');
        expect(wallets.length, 1);
        expect(wallets.first['name'], 'Dompet Tunai');
        expect(wallets.first['current_balance'], 0);

        final List<Map<String, Object?>> categories =
            await db.query('categories');
        expect(categories.length, 10);

        final List<Map<String, Object?>> settings =
            await db.query('app_settings');
        expect(settings.length, 5);
      },
    );

    test(
      'DemoDataSeeder mengisi transaksi, talangan teman, dan kontak lalu dapat di-reset',
      () async {
        await DatabaseHelper.instance.seedDemoData();

        final List<Map<String, Object?>> wallets = await db.query('wallets');
        expect(wallets.length, 3); // Dompet Tunai, BCA, GoPay

        final List<Map<String, Object?>> contacts = await db.query('contacts');
        expect(contacts.length, 2); // Riko & Budi

        final List<Map<String, Object?>> trxs = await db.query('transactions');
        expect(trxs.length, 4);

        final Map<String, Object?> talanganTrx = trxs.firstWhere(
          (Map<String, Object?> t) =>
              (t['note'] as String).contains('Talangan Riko'),
        );
        expect(talanganTrx['total_wallet_amount'], 60000);
        expect(talanganTrx['pure_consumption_amount'], 30000);

        await DatabaseHelper.instance.resetAllData();
        final List<Map<String, Object?>> resetTrxs =
            await db.query('transactions');
        expect(resetTrxs.isEmpty, isTrue);
      },
    );
  });

  group(
      '4. Fase 2: Multi-Dompet, Onboarding, Transfer Antar Dompet & Indikator',
      () {
    late Database db;
    late WalletRepository walletRepo;
    late CategoryRepository categoryRepo;

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
      categoryRepo = CategoryRepository(DatabaseHelper.instance);
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'Onboarding mengatur saldo awal Dompet Tunai & mencegah arsip dompet terakhir',
      () async {
        expect(await walletRepo.isOnboardingPromptShown(), isFalse);

        await walletRepo.completeOnboarding(initialCashBalance: 500000);
        expect(await walletRepo.isOnboardingPromptShown(), isTrue);

        final List<WalletModel> wallets = await walletRepo.getActiveWallets();
        expect(wallets.length, 1);
        expect(wallets.first.currentBalance, 500000);

        // Tidak boleh mengarsipkan satu-satunya dompet aktif
        expect(
          () => walletRepo.archiveWallet(wallets.first.id),
          throwsA(
            isA<AppException>().having(
              (AppException e) => e.code,
              'code',
              AppErrorCode.cannotArchiveLastWallet,
            ),
          ),
        );
      },
    );

    test(
      'Multi-Dompet CRUD & Transfer Antar Dompet menjaga Kekayaan Bersih tetap konsisten',
      () async {
        await walletRepo.completeOnboarding(initialCashBalance: 400000);
        final WalletModel bca = await walletRepo.createWallet(
          name: 'BCA',
          type: 'BANK',
          initialBalance: 1000000,
        );
        final int bcaId = bca.id;

        // Duplikat nama dompet ditolak
        expect(
          () => walletRepo.createWallet(
            name: 'bca',
            type: 'BANK',
            initialBalance: 0,
          ),
          throwsA(
            isA<AppException>().having(
              (AppException e) => e.code,
              'code',
              AppErrorCode.duplicateWalletName,
            ),
          ),
        );

        // Cek indikator sebelum transfer: Total = 1.400.000
        final FinancialIndicatorsModel before =
            await walletRepo.calculateIndicators();
        expect(before.totalWalletBalance, 1400000);
        expect(before.netWorth, 1400000);

        // Transfer Rp 250.000 dari BCA ke Dompet Tunai (id: 1)
        await walletRepo.transferBetweenWallets(
          sourceWalletId: bcaId,
          targetWalletId: 1,
          amount: 250000,
          date: DateTime(2026, 11, 13),
          note: 'Tarik Tunai ATM',
        );

        final List<WalletModel> activeAfter =
            await walletRepo.getActiveWallets();
        final WalletModel cashAfter =
            activeAfter.firstWhere((WalletModel w) => w.id == 1);
        final WalletModel bcaAfter =
            activeAfter.firstWhere((WalletModel w) => w.id == bcaId);
        expect(cashAfter.currentBalance, 650000); // 400rb + 250rb
        expect(bcaAfter.currentBalance, 750000); // 1jt - 250rb

        // Cek indikator sesudah transfer: Total & Kekayaan Bersih TIDAK BERUBAH (1.400.000)
        final FinancialIndicatorsModel afterAll =
            await walletRepo.calculateIndicators();
        expect(afterAll.totalWalletBalance, 1400000);
        expect(afterAll.netWorth, 1400000);

        // Filter khusus BCA menampilkan displayedWalletBalance = 750.000
        final FinancialIndicatorsModel afterBcaFilter =
            await walletRepo.calculateIndicators(selectedWalletId: bcaId);
        expect(afterBcaFilter.displayedWalletBalance, 750000);
        expect(afterBcaFilter.totalWalletBalance, 1400000);

        // Pastikan baris transaksi TRANSFER tercatat dengan pure_consumption_amount = 0
        final List<Map<String, Object?>> trxs = await db.query('transactions');
        expect(trxs.length, 1);
        expect(trxs.first['trx_type'], 'TRANSFER');
        expect(trxs.first['total_wallet_amount'], 250000);
        expect(trxs.first['pure_consumption_amount'], 0);
        expect(trxs.first['target_wallet_id'], 1);
      },
    );

    test('CategoryRepository dapat menambah & menghapus kategori kustom',
        () async {
      final CategoryModel customCat = await categoryRepo.createCustomCategory(
        name: 'Langganan Cloud',
        type: 'EXPENSE',
      );
      final List<CategoryModel> afterAdd =
          await categoryRepo.getCategoriesByType('EXPENSE');
      expect(
        afterAdd.any((CategoryModel c) => c.id == customCat.id),
        isTrue,
      );

      await categoryRepo.deleteCustomCategory(customCat.id);
      final List<CategoryModel> afterDelete =
          await categoryRepo.getCategoriesByType('EXPENSE');
      expect(
        afterDelete.any((CategoryModel c) => c.id == customCat.id),
        isFalse,
      );
    });
  });

  group('5. Core Reusable Widgets Tests', () {
    testWidgets(
      'CustomNumpad mendukung input cepat +10rb, +50rb, digit, dan Reset',
      (WidgetTester tester) async {
        int currentAmount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    children: <Widget>[
                      TabularCurrencyText(amount: currentAmount),
                      StatusBadge.fromTrustBadge('GOOD'),
                      CustomNumpad(
                        amount: currentAmount,
                        onAmountChanged: (int val) {
                          setState(() => currentAmount = val);
                        },
                        onSubmit: () {},
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('Rp 0'), findsOneWidget);
        expect(find.text('GOOD'), findsOneWidget);

        await tester.tap(find.text('+50rb'));
        await tester.pump();
        expect(currentAmount, 50000);
        expect(find.text('Rp 50.000'), findsOneWidget);

        await tester.tap(find.text('+10rb'));
        await tester.pump();
        expect(currentAmount, 60000);

        await tester.tap(find.text('Reset'));
        await tester.pump();
        expect(currentAmount, 0);
      },
    );
  });
}
