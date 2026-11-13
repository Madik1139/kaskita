import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kaskita/app.dart';
import 'package:kaskita/core/data/ledger_overview_repository.dart';
import 'package:kaskita/core/database/database_helper.dart';
import 'package:kaskita/core/theme/app_colors.dart';
import 'package:kaskita/features/debts/data/debt_repository.dart';
import 'package:kaskita/features/reports/data/report_repository.dart';
import 'package:kaskita/features/transactions/data/transaction_query_repository.dart';
import 'package:kaskita/features/transactions/data/transaction_repository.dart';
import 'package:kaskita/features/wallets/data/wallet_repository.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Fase 6: End-to-End QA, Optimasi Performa (<100ms), & Light/Dark UI', () {
    late Database db;
    late WalletRepository walletRepo;
    late TransactionRepository trxRepo;
    late TransactionQueryRepository queryRepo;
    late DebtRepository debtRepo;
    late ReportRepository reportRepo;

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
      debtRepo = DebtRepository(DatabaseHelper.instance);
      reportRepo = ReportRepository(DatabaseHelper.instance);

      await walletRepo.completeOnboarding(initialCashBalance: 10000000);
    });

    tearDown(() async {
      await db.close();
    });

    test(
      '1. Benchmark Kecepatan Query SQLite (150 transaksi) selalu < 100ms',
      () async {
        // Seed 150 transaksi beragam (pengeluaran, talangan, pemasukan, piutang)
        final DateTime baseMonth = DateTime(2026, 11, 1);
        for (int i = 0; i < 150; i++) {
          final int monthOffset = i % 6;
          final int day = (i % 27) + 1;
          final DateTime d = DateTime(
            baseMonth.year,
            baseMonth.month - monthOffset,
            day,
          );
          if (i % 5 == 0) {
            await trxRepo.recordTransaction(
              trxType: 'EXPENSE',
              walletId: 1,
              categoryId: 1,
              totalWalletAmount: 60000,
              trxDate: d,
              note: 'Makan Talangan #$i',
              isSplitTalangan: true,
              friendShareAmount: 30000,
              newContactName: 'Kontak ${(i % 8) + 1}',
            );
          } else if (i % 5 == 1) {
            await trxRepo.recordTransaction(
              trxType: 'INCOME',
              walletId: 1,
              categoryId: 7,
              totalWalletAmount: 150000,
              trxDate: d,
              note: 'Pemasukan #$i',
            );
          } else {
            await trxRepo.recordTransaction(
              trxType: 'EXPENSE',
              walletId: 1,
              categoryId: (i % 4) + 1,
              totalWalletAmount: 25000,
              trxDate: d,
              note: 'Pengeluaran #$i',
            );
          }
        }

        final Stopwatch swIndicators = Stopwatch()..start();
        await walletRepo.calculateIndicators();
        swIndicators.stop();
        expect(swIndicators.elapsedMilliseconds, lessThan(100));

        final Stopwatch swMonth = Stopwatch()..start();
        await queryRepo.getTransactionsByMonth(year: 2026, month: 11);
        swMonth.stop();
        expect(swMonth.elapsedMilliseconds, lessThan(100));

        final Stopwatch swDebts = Stopwatch()..start();
        await debtRepo.getContactsSummary();
        swDebts.stop();
        expect(swDebts.elapsedMilliseconds, lessThan(100));

        final Stopwatch swReports = Stopwatch()..start();
        await reportRepo.getSixMonthComparison(endPeriod: baseMonth);
        await reportRepo.getCategoryBreakdown(year: 2026, month: 11);
        swReports.stop();
        expect(swReports.elapsedMilliseconds, lessThan(100));
      },
    );

    testWidgets(
      '2. E2E UI QA: Navigasi 3 Tab, Bahasa ID/EN, Light/Dark Mode & Input Cepat (+)',
      (WidgetTester tester) async {
        // Gunakan ukuran layar ponsel standar agar responsif tanpa overflow
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.runAsync(() async {
          await LedgerOverviewRepository(DatabaseHelper.instance)
              .seedDemoData();
          await walletRepo.completeOnboarding(initialCashBalance: 500000);
        });

        await tester.pumpWidget(
          const ProviderScope(
            child: KasKitaApp(),
          ),
        );
        // Biarkan seluruh AsyncNotifier (SQLite FFI) selesai tanpa menggantung FakeAsync
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 500)),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Verifikasi Beranda (Light Mode awal) & NavigationBar tampil tanpa exception
        expect(find.text('KasKita'), findsOneWidget);
        expect(find.byType(NavigationBar), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Uji Toggle Tema (Light -> Dark Mode)
        final Finder themeBtn = find.byIcon(LucideIcons.moon);
        expect(themeBtn, findsOneWidget);
        await tester.tap(themeBtn);
        await tester.pump();
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        );
        for (int i = 0; i < 6; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        expect(find.byIcon(LucideIcons.sun), findsOneWidget);
        final BuildContext titleCtx =
            tester.element(find.text('KasKita'));
        expect(AppColors.isDark(titleCtx), isTrue);

        // Uji Toggle Bahasa (ID -> EN)
        await tester.tap(find.text('ID'));
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.text('EN'), findsOneWidget);

        // Berpindah ke Tab 2 (Buku Hutang / Debt Book)
        await tester.tap(find.byIcon(LucideIcons.bookUser));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        expect(tester.takeException(), isNull);

        // Berpindah ke Tab 3 (Ringkasan & Pengaturan / Summary)
        await tester.tap(find.byIcon(LucideIcons.chartColumn));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);

        // Kembali ke Tab 1 (Beranda) & buka Sheet Input Cepat (+)
        await tester.tap(find.byIcon(LucideIcons.wallet).last);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);

        // Tutup pohon widget dan tuntaskan timer watchdog sqflite di FakeAsync
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 11));
      },
    );
  });
}
