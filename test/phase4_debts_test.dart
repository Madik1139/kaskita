import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaskita/core/database/database_helper.dart';
import 'package:kaskita/core/errors/app_exception.dart';
import 'package:kaskita/features/debts/data/debt_repository.dart';
import 'package:kaskita/features/debts/models/debt_models.dart';
import 'package:kaskita/features/debts/presentation/widgets/clean_invoice_receipt_sheet.dart';
import 'package:kaskita/features/transactions/data/transaction_query_repository.dart';
import 'package:kaskita/features/transactions/data/transaction_repository.dart';
import 'package:kaskita/features/transactions/models/transaction_model.dart';
import 'package:kaskita/features/wallets/data/wallet_repository.dart';
import 'package:kaskita/features/wallets/models/wallet_model.dart';
import 'package:kaskita/l10n/app_localizations_id.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group(
      'Fase 4: Buku Hutang Pintar (FIFO, Auto-Netting, Lunas Traktiran, Trust Badge & Struk)',
      () {
    late Database db;
    late WalletRepository walletRepo;
    late TransactionRepository trxRepo;
    late DebtRepository debtRepo;

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

      await walletRepo.completeOnboarding(initialCashBalance: 500000);
    });

    tearDown(() async {
      await db.close();
    });

    test(
      '1. Algoritma Cicilan FIFO memotong tagihan terlama lebih dulu & dapat dibatalkan (Rollback)',
      () async {
        // Tagihan 1 (Terlama): Talangan makan Budi Rp 50.000
        await trxRepo.recordTransaction(
          trxType: 'EXPENSE',
          walletId: 1,
          categoryId: 1,
          totalWalletAmount: 100000,
          trxDate: DateTime(2026, 11, 1),
          note: 'Talangan Makan Siang',
          isSplitTalangan: true,
          friendShareAmount: 50000,
          newContactName: 'Budi Santoso',
        );

        // Tagihan 2 (Lebih baru): Pinjam tunai Budi Rp 100.000
        await trxRepo.recordTransaction(
          trxType: 'RECEIVABLE_OUT',
          walletId: 1,
          totalWalletAmount: 100000,
          trxDate: DateTime(2026, 11, 5),
          note: 'Pinjam Tunai BCA',
          newContactName: 'Budi Santoso',
        );

        final List<ContactSummaryModel> contactsBefore =
            await debtRepo.getContactsSummary();
        final int budiId = contactsBefore.first.id;
        expect(contactsBefore.first.netBalance, 150000);

        // Budi mencicil Rp 70.000 secara tunai (Otomatis FIFO)
        // Harus melunasi Tagihan 1 (Rp 50.000 -> PAID) dan memotong Tagihan 2 (Rp 20.000 -> sisa Rp 80.000 PARTIAL)
        await debtRepo.settleDebts(
          contactId: budiId,
          debtType: 'RECEIVABLE',
          amount: 70000,
          settlementMethod: 'CASH',
          walletId: 1,
          paymentDate: DateTime(2026, 11, 10),
          note: 'Cicilan Tunai Budi',
        );

        final ContactDetailStateModel detailAfterFifo =
            await debtRepo.getContactDetail(budiId);
        expect(detailAfterFifo.contact.netBalance, 80000);
        expect(detailAfterFifo.activeDebts.length, 1); // Hanya Tagihan 2 yang masih belum lunas
        expect(detailAfterFifo.activeDebts.first.remainingAmount, 80000);
        expect(detailAfterFifo.activeDebts.first.status, 'PARTIAL');
        expect(detailAfterFifo.paymentHistory.length, 2); // 2 alokasi pembayaran FIFO

        // Saldo Dompet: 500.000 - 100.000 - 100.000 + 70.000 = 370.000
        final FinancialIndicatorsModel ind =
            await walletRepo.calculateIndicators();
        expect(ind.totalWalletBalance, 370000);

        // Uji Batalkan salah satu bagian cicilan (Rp 20.000 pada Tagihan 2)
        final DebtPaymentModel secondAlloc = detailAfterFifo.paymentHistory
            .firstWhere((DebtPaymentModel p) => p.amountPaid == 20000);
        await debtRepo.cancelDebtPayment(secondAlloc.id);

        final ContactDetailStateModel detailAfterCancel =
            await debtRepo.getContactDetail(budiId);
        expect(detailAfterCancel.contact.netBalance, 100000);
        expect(detailAfterCancel.activeDebts.first.remainingAmount, 100000);
        expect(detailAfterCancel.activeDebts.first.status, 'UNPAID');
      },
    );

    test(
      '2. Auto-Netting (Potong Saldo Silang) & Lunas via Traktiran (Settle with Item)',
      () async {
        // Budi berhutang Rp 80.000 ke kita
        await trxRepo.recordTransaction(
          trxType: 'RECEIVABLE_OUT',
          walletId: 1,
          totalWalletAmount: 80000,
          trxDate: DateTime(2026, 11, 2),
          note: 'Pinjamkan ke Budi',
          newContactName: 'Budi Santoso',
        );
        final int budiId = (await debtRepo.getContactsSummary()).first.id;

        // Sekarang kita berhutang Rp 110.000 ke Budi menggunakan Auto-Netting!
        // Maka piutang Rp 80.000 lunas otomatis, dan muncul sisa hutang kita ke Budi Rp 30.000!
        await debtRepo.recordDebtWithAutoNetting(
          contactId: budiId,
          newDebtType: 'PAYABLE',
          amount: 110000,
          date: DateTime(2026, 11, 8),
          note: 'Titip Beli Tiket ke Budi (Auto-Netting)',
        );

        final ContactDetailStateModel afterNetting =
            await debtRepo.getContactDetail(budiId);
        expect(afterNetting.contact.netBalance, -30000); // Kita berhutang Rp 30.000
        expect(afterNetting.activeDebts.length, 1);
        expect(afterNetting.activeDebts.first.debtType, 'PAYABLE');
        expect(afterNetting.activeDebts.first.remainingAmount, 30000);

        // Lunasi sisa hutang Rp 30.000 via Barang/Traktiran & catat sebagai konsumsi pengeluaran harian
        final int walletBeforeTreat =
            (await walletRepo.calculateIndicators()).totalWalletBalance;

        await debtRepo.settleDebts(
          contactId: budiId,
          debtType: 'PAYABLE',
          amount: 30000,
          settlementMethod: 'ITEM_TREAT',
          paymentDate: DateTime(2026, 11, 12),
          recordTreatAsPersonalExpense: true,
          treatExpenseCategoryId: 1,
          note: 'Traktir Kopi Budi',
        );

        final ContactDetailStateModel afterTreat =
            await debtRepo.getContactDetail(budiId);
        expect(afterTreat.contact.netBalance, 0);
        expect(afterTreat.activeDebts.isEmpty, isTrue);

        // Saldo fisik dompet TIDAK berkurang karena pelunasan via traktiran/non-tunai
        final int walletAfterTreat =
            (await walletRepo.calculateIndicators()).totalWalletBalance;
        expect(walletAfterTreat, walletBeforeTreat);
      },
    );

    test(
      '3. Evaluasi Otomatis Trust Badge (GOOD, LATE, WARNING) & Batas Rem Piutang',
      () async {
        expect(
          ContactSummaryModel.evaluateTrustBadge(
            maxOverdueDays: 0,
            lateCount: 0,
          ),
          'GOOD',
        );
        expect(
          ContactSummaryModel.evaluateTrustBadge(
            maxOverdueDays: 4,
            lateCount: 0,
          ),
          'LATE',
        );
        expect(
          ContactSummaryModel.evaluateTrustBadge(
            maxOverdueDays: 9,
            lateCount: 0,
          ),
          'WARNING',
        );
        expect(
          ContactSummaryModel.evaluateTrustBadge(
            maxOverdueDays: 0,
            lateCount: 3,
          ),
          'WARNING',
        );

        await debtRepo.updateLendingCapLimit(750000);
        expect(await debtRepo.getLendingCapLimit(), 750000);
      },
    );

    testWidgets(
      '4. CleanInvoiceReceiptCard merender Struk Tagihan Bersih dengan lengkap',
      (WidgetTester tester) async {
        const ContactDetailStateModel sampleDetail = ContactDetailStateModel(
          contact: ContactSummaryModel(
            id: 1,
            name: 'Budi Santoso',
            phoneNote: '0812-3456-7890',
            netBalance: 130000,
            trustBadge: 'LATE',
            lateCount: 1,
            openDebtsCount: 2,
          ),
          activeDebts: <DebtItemModel>[
            DebtItemModel(
              id: 1,
              contactId: 1,
              debtType: 'RECEIVABLE',
              principalAmount: 50000,
              remainingAmount: 30000,
              status: 'PARTIAL',
              note: 'Talangan Makan Siang',
              createdAt: '2026-11-05',
            ),
            DebtItemModel(
              id: 2,
              contactId: 1,
              debtType: 'RECEIVABLE',
              principalAmount: 100000,
              remainingAmount: 100000,
              status: 'UNPAID',
              note: 'Pinjam Tunai',
              createdAt: '2026-11-10',
            ),
          ],
          paymentHistory: <DebtPaymentModel>[
            DebtPaymentModel(
              id: 1,
              debtId: 1,
              settlementMethod: 'CASH',
              amountPaid: 20000,
              paymentDate: '2026-11-08',
              note: 'Cicilan Tunai',
            ),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: CleanInvoiceReceiptCard(
                  detail: sampleDetail,
                  l10n: AppLocalizationsId(),
                  langCode: 'id',
                ),
              ),
            ),
          ),
        );

        expect(find.text('BUDI SANTOSO'), findsOneWidget);
        expect(find.text('Rp 130.000'), findsOneWidget);
        expect(find.textContaining('Talangan Makan Siang'), findsOneWidget);
        expect(find.textContaining('Cicilan Tunai'), findsOneWidget);
      },
    );

    test(
      '5. Auto-Netting dengan Dompet (Kasus Titipan Uang -> Beli Barang -> Tercatat di Beranda & Rollback)',
      () async {
        final TransactionQueryRepository queryRepo =
            TransactionQueryRepository(DatabaseHelper.instance);

        // Awalnya saldo Dompet Tunai (wallet 1) Rp 500.000
        // Teman menitip uang Rp 50.000 (DEBT_IN)
        await trxRepo.recordTransaction(
          trxType: 'DEBT_IN',
          walletId: 1,
          totalWalletAmount: 50000,
          trxDate: DateTime(2026, 11, 13),
          note: 'Titip uang dari Riko',
          newContactName: 'Riko',
        );

        final int rikoId = (await debtRepo.getContactsSummary())
            .firstWhere((ContactSummaryModel c) => c.name == 'Riko')
            .id;
        expect(
          (await walletRepo.calculateIndicators()).totalWalletBalance,
          550000,
        );

        // Beli nasi padang Rp 10.000 memakai Auto-Netting dengan Dompet Tunai (wallet 1)
        await debtRepo.recordDebtWithAutoNetting(
          contactId: rikoId,
          newDebtType: 'RECEIVABLE',
          amount: 10000,
          date: DateTime(2026, 11, 13),
          walletId: 1,
          note: 'Beli nasi padang titipan Riko',
        );

        // Saldo dompet berkurang Rp 10.000 -> Rp 540.000, dan sisa titipan (hutang) jadi -Rp 40.000
        expect(
          (await walletRepo.calculateIndicators()).totalWalletBalance,
          540000,
        );
        final ContactDetailStateModel afterBuy =
            await debtRepo.getContactDetail(rikoId);
        expect(afterBuy.contact.netBalance, -40000);

        // Mutasi PAYABLE_SETTLE Rp 10.000 harus muncul di Beranda (pureConsumption = 0)
        final List<TransactionItemModel> monthTrxs =
            await queryRepo.getTransactionsByMonth(year: 2026, month: 11);
        final TransactionItemModel settleTrx = monthTrxs.firstWhere(
          (TransactionItemModel t) => t.trxType == 'PAYABLE_SETTLE',
        );
        expect(settleTrx.totalWalletAmount, 10000);
        expect(settleTrx.pureConsumptionAmount, 0);
        expect(settleTrx.note, 'Beli nasi padang titipan Riko');

        // Skenario melebihi sisa titipan: bayar Rp 65.000 -> 40rb lunasi titipan + 25rb jadi piutang baru
        await debtRepo.recordDebtWithAutoNetting(
          contactId: rikoId,
          newDebtType: 'RECEIVABLE',
          amount: 65000,
          date: DateTime(2026, 11, 14),
          walletId: 1,
          note: 'Belanja tambahan Riko',
        );

        expect(
          (await walletRepo.calculateIndicators()).totalWalletBalance,
          475000,
        );
        final ContactDetailStateModel afterExcess =
            await debtRepo.getContactDetail(rikoId);
        expect(afterExcess.contact.netBalance, 25000);
        expect(afterExcess.activeDebts.length, 1);
        expect(afterExcess.activeDebts.first.debtType, 'RECEIVABLE');
        expect(afterExcess.activeDebts.first.remainingAmount, 25000);

        // Pembatalan cicilan PAYABLE_SETTLE pertama (Rp 10.000) harus mengembalikan dompet +10.000
        final int firstPaymentId = afterBuy.paymentHistory.first.id;
        await debtRepo.cancelDebtPayment(firstPaymentId);
        expect(
          (await walletRepo.calculateIndicators()).totalWalletBalance,
          485000,
        );
        final ContactDetailStateModel afterCancel =
            await debtRepo.getContactDetail(rikoId);
        expect(afterCancel.contact.netBalance, 15000);
      },
    );

    test(
      '6. Edit & Hapus Kontak: Update Nama/Catatan (cek duplikat) & Hapus Kontak beserta tagihan aktif tanpa mengubah saldo dompet',
      () async {
        final ContactSummaryModel andi = await debtRepo.createContact(
          name: 'Andi',
          phoneNote: '081111',
        );
        await debtRepo.createContact(name: 'Sinta');

        // Edit valid
        final ContactSummaryModel updatedAndi = await debtRepo.updateContact(
          id: andi.id,
          name: 'Andi Wijaya',
          phoneNote: '0812-9999',
        );
        expect(updatedAndi.name, 'Andi Wijaya');
        expect(updatedAndi.phoneNote, '0812-9999');

        // Edit ke nama yang sudah dipakai kontak lain -> AppErrorCode.duplicateContactName
        await expectLater(
          () => debtRepo.updateContact(id: andi.id, name: 'sinta'),
          throwsA(
            isA<AppException>().having(
              (AppException e) => e.code,
              'code',
              AppErrorCode.duplicateContactName,
            ),
          ),
        );

        // Catat piutang aktif ke Andi Wijaya Rp 75.000 (saldo dompet turun dari 500rb -> 425rb)
        await trxRepo.recordTransaction(
          trxType: 'RECEIVABLE_OUT',
          walletId: 1,
          totalWalletAmount: 75000,
          trxDate: DateTime(2026, 11, 13),
          note: 'Pinjam sementara',
          contactId: andi.id,
        );
        expect(
          (await walletRepo.calculateIndicators()).totalWalletBalance,
          425000,
        );

        // Hapus kontak Andi Wijaya meski masih ada piutang aktif
        await debtRepo.deleteContact(andi.id);

        final List<ContactSummaryModel> remaining =
            await debtRepo.getContactsSummary();
        expect(remaining.any((ContactSummaryModel c) => c.id == andi.id), isFalse);
        expect(
          (await db.query('debts', where: 'contact_id = ?', whereArgs: <Object>[andi.id])).isEmpty,
          isTrue,
        );

        // Saldo dompet & transaksi kas di Beranda tetap terjaga
        expect(
          (await walletRepo.calculateIndicators()).totalWalletBalance,
          425000,
        );
        final TransactionQueryRepository queryRepo =
            TransactionQueryRepository(DatabaseHelper.instance);
        final List<TransactionItemModel> monthTrxs =
            await queryRepo.getTransactionsByMonth(year: 2026, month: 11);
        expect(monthTrxs.length, 1);
      },
    );
  });
}

