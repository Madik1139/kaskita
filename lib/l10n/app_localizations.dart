import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In id, this message translates to:
  /// **'KasKita'**
  String get appTitle;

  /// No description provided for @save.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// No description provided for @reset.
  ///
  /// In id, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @delete.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In id, this message translates to:
  /// **'Ubah'**
  String get edit;

  /// No description provided for @skip.
  ///
  /// In id, this message translates to:
  /// **'Lewati'**
  String get skip;

  /// No description provided for @close.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get close;

  /// No description provided for @switchThemeTooltip.
  ///
  /// In id, this message translates to:
  /// **'Ganti Tema Terang / Gelap'**
  String get switchThemeTooltip;

  /// No description provided for @switchLanguageTooltip.
  ///
  /// In id, this message translates to:
  /// **'Ganti Bahasa (ID / EN)'**
  String get switchLanguageTooltip;

  /// No description provided for @phaseBadge.
  ///
  /// In id, this message translates to:
  /// **'v1.0.0'**
  String get phaseBadge;

  /// No description provided for @navHome.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get navHome;

  /// No description provided for @navDebtBook.
  ///
  /// In id, this message translates to:
  /// **'Buku Hutang'**
  String get navDebtBook;

  /// No description provided for @navSummary.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan'**
  String get navSummary;

  /// No description provided for @allWallets.
  ///
  /// In id, this message translates to:
  /// **'Semua Dompet'**
  String get allWallets;

  /// No description provided for @addWallet.
  ///
  /// In id, this message translates to:
  /// **'+ Dompet'**
  String get addWallet;

  /// No description provided for @manageCategories.
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get manageCategories;

  /// No description provided for @transferAction.
  ///
  /// In id, this message translates to:
  /// **'Transfer'**
  String get transferAction;

  /// No description provided for @walletTypeCash.
  ///
  /// In id, this message translates to:
  /// **'Tunai'**
  String get walletTypeCash;

  /// No description provided for @walletTypeBank.
  ///
  /// In id, this message translates to:
  /// **'Bank'**
  String get walletTypeBank;

  /// No description provided for @walletTypeEwallet.
  ///
  /// In id, this message translates to:
  /// **'E-Wallet'**
  String get walletTypeEwallet;

  /// No description provided for @onboardingTitle.
  ///
  /// In id, this message translates to:
  /// **'Atur Saldo Awal Dompet Tunai?'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Masukkan jumlah uang tunai yang Anda pegang saat ini, atau lewati untuk mulai dari Rp 0.'**
  String get onboardingSubtitle;

  /// No description provided for @saveInitialBalance.
  ///
  /// In id, this message translates to:
  /// **'Simpan Saldo Awal'**
  String get saveInitialBalance;

  /// No description provided for @addWalletTitle.
  ///
  /// In id, this message translates to:
  /// **'Tambah Dompet Baru'**
  String get addWalletTitle;

  /// No description provided for @editWalletTitle.
  ///
  /// In id, this message translates to:
  /// **'Ubah Dompet'**
  String get editWalletTitle;

  /// No description provided for @walletNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama Dompet'**
  String get walletNameLabel;

  /// No description provided for @walletNameHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: BCA, Mandiri, GoPay'**
  String get walletNameHint;

  /// No description provided for @walletTypeLabel.
  ///
  /// In id, this message translates to:
  /// **'Tipe Dompet'**
  String get walletTypeLabel;

  /// No description provided for @initialBalanceLabel.
  ///
  /// In id, this message translates to:
  /// **'SALDO AWAL DOMPET'**
  String get initialBalanceLabel;

  /// No description provided for @transferTitle.
  ///
  /// In id, this message translates to:
  /// **'Transfer Antar Dompet'**
  String get transferTitle;

  /// No description provided for @transferSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Mutasi saldo internal tanpa mengotori grafik pengeluaran/pemasukan.'**
  String get transferSubtitle;

  /// No description provided for @sourceWalletLabel.
  ///
  /// In id, this message translates to:
  /// **'Dari Dompet (Asal)'**
  String get sourceWalletLabel;

  /// No description provided for @targetWalletLabel.
  ///
  /// In id, this message translates to:
  /// **'Ke Dompet (Tujuan)'**
  String get targetWalletLabel;

  /// No description provided for @transferAmountLabel.
  ///
  /// In id, this message translates to:
  /// **'NOMINAL TRANSFER'**
  String get transferAmountLabel;

  /// No description provided for @transferNoteHint.
  ///
  /// In id, this message translates to:
  /// **'Catatan transfer (opsional, misal: Tarik Tunai ATM)'**
  String get transferNoteHint;

  /// No description provided for @transferSuccessMsg.
  ///
  /// In id, this message translates to:
  /// **'Transfer antar dompet berhasil disimpan.'**
  String get transferSuccessMsg;

  /// No description provided for @walletSavedMsg.
  ///
  /// In id, this message translates to:
  /// **'Dompet berhasil disimpan.'**
  String get walletSavedMsg;

  /// No description provided for @categoryManagementTitle.
  ///
  /// In id, this message translates to:
  /// **'Kelola Kategori Kas'**
  String get categoryManagementTitle;

  /// No description provided for @expenseTab.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran'**
  String get expenseTab;

  /// No description provided for @incomeTab.
  ///
  /// In id, this message translates to:
  /// **'Pemasukan'**
  String get incomeTab;

  /// No description provided for @addCategoryHint.
  ///
  /// In id, this message translates to:
  /// **'Nama kategori kustom baru...'**
  String get addCategoryHint;

  /// No description provided for @addCategoryBtn.
  ///
  /// In id, this message translates to:
  /// **'Tambah'**
  String get addCategoryBtn;

  /// No description provided for @activeWalletsCount.
  ///
  /// In id, this message translates to:
  /// **'{count} Dompet Aktif'**
  String activeWalletsCount(int count);

  /// No description provided for @categoriesAndContactsCount.
  ///
  /// In id, this message translates to:
  /// **'{categories} Kategori • {contacts} Kontak'**
  String categoriesAndContactsCount(int categories, int contacts);

  /// No description provided for @activeWalletBalanceLabel.
  ///
  /// In id, this message translates to:
  /// **'SALDO DOMPET AKTIF'**
  String get activeWalletBalanceLabel;

  /// No description provided for @selectedWalletBalanceLabel.
  ///
  /// In id, this message translates to:
  /// **'SALDO DOMPET ({walletName})'**
  String selectedWalletBalanceLabel(String walletName);

  /// No description provided for @safeToSpendLabel.
  ///
  /// In id, this message translates to:
  /// **'Dana Aman Siap Pakai'**
  String get safeToSpendLabel;

  /// No description provided for @netWorthLabel.
  ///
  /// In id, this message translates to:
  /// **'Kekayaan Bersih'**
  String get netWorthLabel;

  /// No description provided for @loadDemoData.
  ///
  /// In id, this message translates to:
  /// **'Muat Data Contoh'**
  String get loadDemoData;

  /// No description provided for @resetDataToZero.
  ///
  /// In id, this message translates to:
  /// **'Reset Data (Rp0)'**
  String get resetDataToZero;

  /// No description provided for @emptyTransactionsTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum Ada Catatan Transaksi'**
  String get emptyTransactionsTitle;

  /// No description provided for @emptyTransactionsSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Gunakan tombol Transfer di atas, tambah Dompet baru, atau ketuk \"Muat Data Contoh\" untuk melihat simulasi transaksi.'**
  String get emptyTransactionsSubtitle;

  /// No description provided for @loadDemoDataNow.
  ///
  /// In id, this message translates to:
  /// **'Muat Data Contoh Sekarang'**
  String get loadDemoDataNow;

  /// No description provided for @quickRecord.
  ///
  /// In id, this message translates to:
  /// **'Catat Cepat'**
  String get quickRecord;

  /// No description provided for @quickInputTitle.
  ///
  /// In id, this message translates to:
  /// **'Input Transaksi Satu Pintu (< 5 Detik)'**
  String get quickInputTitle;

  /// No description provided for @transactionAmountLabel.
  ///
  /// In id, this message translates to:
  /// **'NOMINAL TRANSAKSI'**
  String get transactionAmountLabel;

  /// No description provided for @walletOutflowLabel.
  ///
  /// In id, this message translates to:
  /// **'{walletName} • Kas Keluar: {amount}'**
  String walletOutflowLabel(String walletName, String amount);

  /// No description provided for @transferMutationLabel.
  ///
  /// In id, this message translates to:
  /// **'Transfer: {fromWallet} -> {toWallet}'**
  String transferMutationLabel(String fromWallet, String toWallet);

  /// No description provided for @debtBookCategoryLabel.
  ///
  /// In id, this message translates to:
  /// **'Buku Hutang'**
  String get debtBookCategoryLabel;

  /// No description provided for @transferCategoryLabel.
  ///
  /// In id, this message translates to:
  /// **'Mutasi Kas'**
  String get transferCategoryLabel;

  /// No description provided for @nonCashLabel.
  ///
  /// In id, this message translates to:
  /// **'Non-Tunai'**
  String get nonCashLabel;

  /// No description provided for @tabDebtPlaceholderTitle.
  ///
  /// In id, this message translates to:
  /// **'Modul Buku Hutang (Fase 4)'**
  String get tabDebtPlaceholderTitle;

  /// No description provided for @tabDebtPlaceholderSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Akan menampilkan direktori kontak, Saldo Bersih, Cicilan FIFO, Auto-Netting, Lunas Traktiran, dan Struk Gambar.'**
  String get tabDebtPlaceholderSubtitle;

  /// No description provided for @tabSummaryPlaceholderTitle.
  ///
  /// In id, this message translates to:
  /// **'Modul Laporan & Pengaturan (Fase 5)'**
  String get tabSummaryPlaceholderTitle;

  /// No description provided for @tabSummaryPlaceholderSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Akan menampilkan Grafik Bulanan, Rem Piutang, Kunci PIN/Biometrik, Backup/Restore Lokal, dan Update OTA.'**
  String get tabSummaryPlaceholderSubtitle;

  /// No description provided for @badgeUnpaid.
  ///
  /// In id, this message translates to:
  /// **'BELUM LUNAS'**
  String get badgeUnpaid;

  /// No description provided for @badgePartial.
  ///
  /// In id, this message translates to:
  /// **'DICICIL'**
  String get badgePartial;

  /// No description provided for @badgePaid.
  ///
  /// In id, this message translates to:
  /// **'LUNAS'**
  String get badgePaid;

  /// No description provided for @badgeGood.
  ///
  /// In id, this message translates to:
  /// **'AMAN'**
  String get badgeGood;

  /// No description provided for @badgeLate.
  ///
  /// In id, this message translates to:
  /// **'TELAT'**
  String get badgeLate;

  /// No description provided for @badgeWarning.
  ///
  /// In id, this message translates to:
  /// **'PERHATIAN'**
  String get badgeWarning;

  /// No description provided for @defaultWalletCash.
  ///
  /// In id, this message translates to:
  /// **'Dompet Tunai'**
  String get defaultWalletCash;

  /// No description provided for @catFoodDrink.
  ///
  /// In id, this message translates to:
  /// **'Makan & Minum'**
  String get catFoodDrink;

  /// No description provided for @catTransportFuel.
  ///
  /// In id, this message translates to:
  /// **'Transport & BBM'**
  String get catTransportFuel;

  /// No description provided for @catDailyShopping.
  ///
  /// In id, this message translates to:
  /// **'Belanja Harian'**
  String get catDailyShopping;

  /// No description provided for @catBillsQuota.
  ///
  /// In id, this message translates to:
  /// **'Tagihan & Kuota'**
  String get catBillsQuota;

  /// No description provided for @catEntertainment.
  ///
  /// In id, this message translates to:
  /// **'Hiburan & Nongkrong'**
  String get catEntertainment;

  /// No description provided for @catOtherExpense.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get catOtherExpense;

  /// No description provided for @catSalary.
  ///
  /// In id, this message translates to:
  /// **'Gaji / Upah'**
  String get catSalary;

  /// No description provided for @catBusiness.
  ///
  /// In id, this message translates to:
  /// **'Hasil Usaha'**
  String get catBusiness;

  /// No description provided for @catBonusGift.
  ///
  /// In id, this message translates to:
  /// **'Bonus / Pemberian'**
  String get catBonusGift;

  /// No description provided for @catOtherIncome.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get catOtherIncome;

  /// No description provided for @errUnexpectedUiTitle.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kendala tampilan'**
  String get errUnexpectedUiTitle;

  /// No description provided for @errUnexpectedGeneral.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan yang tidak terduga. Silakan coba lagi.'**
  String get errUnexpectedGeneral;

  /// No description provided for @errDatabaseOperation.
  ///
  /// In id, this message translates to:
  /// **'Gagal memproses penyimpanan database lokal.'**
  String get errDatabaseOperation;

  /// No description provided for @errAmountMustBePositive.
  ///
  /// In id, this message translates to:
  /// **'Nominal harus lebih besar dari Rp 0.'**
  String get errAmountMustBePositive;

  /// No description provided for @errWalletRequired.
  ///
  /// In id, this message translates to:
  /// **'Silakan pilih dompet terlebih dahulu.'**
  String get errWalletRequired;

  /// No description provided for @errWalletNameRequired.
  ///
  /// In id, this message translates to:
  /// **'Nama dompet tidak boleh kosong.'**
  String get errWalletNameRequired;

  /// No description provided for @errDuplicateWalletName.
  ///
  /// In id, this message translates to:
  /// **'Nama dompet sudah digunakan. Gunakan nama lain.'**
  String get errDuplicateWalletName;

  /// No description provided for @errCannotArchiveLastWallet.
  ///
  /// In id, this message translates to:
  /// **'Tidak dapat menghapus/mengarsipkan satu-satunya dompet aktif.'**
  String get errCannotArchiveLastWallet;

  /// No description provided for @errCategoryRequired.
  ///
  /// In id, this message translates to:
  /// **'Silakan pilih kategori transaksi terlebih dahulu.'**
  String get errCategoryRequired;

  /// No description provided for @errCategoryNameRequired.
  ///
  /// In id, this message translates to:
  /// **'Nama kategori tidak boleh kosong.'**
  String get errCategoryNameRequired;

  /// No description provided for @errContactRequired.
  ///
  /// In id, this message translates to:
  /// **'Silakan pilih atau masukkan nama kontak teman.'**
  String get errContactRequired;

  /// No description provided for @errTransferSameWallet.
  ///
  /// In id, this message translates to:
  /// **'Dompet asal dan dompet tujuan tidak boleh sama.'**
  String get errTransferSameWallet;

  /// No description provided for @errInsufficientWalletBalance.
  ///
  /// In id, this message translates to:
  /// **'Saldo dompet asal tidak mencukupi untuk transaksi ini.'**
  String get errInsufficientWalletBalance;

  /// No description provided for @errSplitAmountExceedsTotal.
  ///
  /// In id, this message translates to:
  /// **'Total porsi talangan teman tidak boleh melebihi total bayar di kasir.'**
  String get errSplitAmountExceedsTotal;

  /// No description provided for @errTransactionLockedHasInstallments.
  ///
  /// In id, this message translates to:
  /// **'Transaksi ini sudah memiliki riwayat cicilan. Batalkan cicilan terkait di Buku Hutang terlebih dahulu sebelum mengubah/menghapus transaksi awal.'**
  String get errTransactionLockedHasInstallments;

  /// No description provided for @errOverpaymentExceedsRemaining.
  ///
  /// In id, this message translates to:
  /// **'Nominal pembayaran melebihi sisa tagihan yang belum lunas.'**
  String get errOverpaymentExceedsRemaining;

  /// No description provided for @errDuplicateContactName.
  ///
  /// In id, this message translates to:
  /// **'Nama kontak sudah terdaftar. Gunakan nama lain.'**
  String get errDuplicateContactName;

  /// No description provided for @errLendingCapExceededWarning.
  ///
  /// In id, this message translates to:
  /// **'Perhatian: Total piutang aktif akan melewati batas Rem Piutang ({limit}).'**
  String errLendingCapExceededWarning(String limit);

  /// No description provided for @errPinInvalid.
  ///
  /// In id, this message translates to:
  /// **'PIN yang dimasukkan salah. Silakan coba lagi.'**
  String get errPinInvalid;

  /// No description provided for @errBackupRestoreFailed.
  ///
  /// In id, this message translates to:
  /// **'File cadangan tidak valid atau gagal dipulihkan.'**
  String get errBackupRestoreFailed;

  /// No description provided for @errOtaCheckFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memeriksa pembaruan. Pastikan perangkat terhubung ke internet.'**
  String get errOtaCheckFailed;

  /// No description provided for @modeExpense.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran'**
  String get modeExpense;

  /// No description provided for @modeIncome.
  ///
  /// In id, this message translates to:
  /// **'Pemasukan'**
  String get modeIncome;

  /// No description provided for @modeReceivable.
  ///
  /// In id, this message translates to:
  /// **'Piutang'**
  String get modeReceivable;

  /// No description provided for @modePayable.
  ///
  /// In id, this message translates to:
  /// **'Hutang'**
  String get modePayable;

  /// No description provided for @modeTransfer.
  ///
  /// In id, this message translates to:
  /// **'Transfer'**
  String get modeTransfer;

  /// No description provided for @selectWalletLabel.
  ///
  /// In id, this message translates to:
  /// **'Dompet'**
  String get selectWalletLabel;

  /// No description provided for @selectCategoryLabel.
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get selectCategoryLabel;

  /// No description provided for @selectContactLabel.
  ///
  /// In id, this message translates to:
  /// **'Kontak Teman'**
  String get selectContactLabel;

  /// No description provided for @contactNameHint.
  ///
  /// In id, this message translates to:
  /// **'Nama teman (pilih atau ketik baru)...'**
  String get contactNameHint;

  /// No description provided for @dueDateLabel.
  ///
  /// In id, this message translates to:
  /// **'Jatuh Tempo'**
  String get dueDateLabel;

  /// No description provided for @noDueDate.
  ///
  /// In id, this message translates to:
  /// **'Tanpa Jatuh Tempo'**
  String get noDueDate;

  /// No description provided for @transactionDateLabel.
  ///
  /// In id, this message translates to:
  /// **'Tanggal'**
  String get transactionDateLabel;

  /// No description provided for @transactionNoteHint.
  ///
  /// In id, this message translates to:
  /// **'Catatan transaksi (opsional)...'**
  String get transactionNoteHint;

  /// No description provided for @splitExpenseToggleTitle.
  ///
  /// In id, this message translates to:
  /// **'Sekalian Talangi Teman?'**
  String get splitExpenseToggleTitle;

  /// No description provided for @splitExpenseToggleSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pisahkan konsumsi murni Anda dari porsi piutang teman.'**
  String get splitExpenseToggleSubtitle;

  /// No description provided for @splitEqual5050.
  ///
  /// In id, this message translates to:
  /// **'Bagi Rata (50:50)'**
  String get splitEqual5050;

  /// No description provided for @splitFriendShareLabel.
  ///
  /// In id, this message translates to:
  /// **'Porsi Talangan Teman (Rp)'**
  String get splitFriendShareLabel;

  /// No description provided for @splitSummaryText.
  ///
  /// In id, this message translates to:
  /// **'Kas Keluar: {walletOut} -> Konsumsi Anda: {pureExpense} | Piutang {contact}: {friendShare}'**
  String splitSummaryText(
    String walletOut,
    String pureExpense,
    String contact,
    String friendShare,
  );

  /// No description provided for @editTransactionTitle.
  ///
  /// In id, this message translates to:
  /// **'Detail & Ubah Transaksi'**
  String get editTransactionTitle;

  /// No description provided for @deleteTransactionConfirmTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus Transaksi Ini?'**
  String get deleteTransactionConfirmTitle;

  /// No description provided for @deleteTransactionConfirmSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Saldo dompet dan buku hutang terkait akan dikembalikan (rollback) secara otomatis.'**
  String get deleteTransactionConfirmSubtitle;

  /// No description provided for @transactionSavedMsg.
  ///
  /// In id, this message translates to:
  /// **'Catatan transaksi berhasil disimpan.'**
  String get transactionSavedMsg;

  /// No description provided for @transactionDeletedMsg.
  ///
  /// In id, this message translates to:
  /// **'Transaksi berhasil dihapus dan saldo telah dikembalikan.'**
  String get transactionDeletedMsg;

  /// No description provided for @subTabDaily.
  ///
  /// In id, this message translates to:
  /// **'Harian'**
  String get subTabDaily;

  /// No description provided for @subTabCalendar.
  ///
  /// In id, this message translates to:
  /// **'Kalender'**
  String get subTabCalendar;

  /// No description provided for @subTabMonthly.
  ///
  /// In id, this message translates to:
  /// **'Bulanan'**
  String get subTabMonthly;

  /// No description provided for @summaryIncomeLabel.
  ///
  /// In id, this message translates to:
  /// **'Pemasukan'**
  String get summaryIncomeLabel;

  /// No description provided for @summaryPureExpenseLabel.
  ///
  /// In id, this message translates to:
  /// **'Konsumsi Murni'**
  String get summaryPureExpenseLabel;

  /// No description provided for @summaryNetDifferenceLabel.
  ///
  /// In id, this message translates to:
  /// **'Selisih Bersih'**
  String get summaryNetDifferenceLabel;

  /// No description provided for @weeklyBreakdownLabel.
  ///
  /// In id, this message translates to:
  /// **'Rincian Mingguan'**
  String get weeklyBreakdownLabel;

  /// No description provided for @weekRangeLabel.
  ///
  /// In id, this message translates to:
  /// **'Minggu {week} (Tgl {startDay}–{endDay})'**
  String weekRangeLabel(int week, String startDay, String endDay);

  /// No description provided for @selectedDateTransactionsLabel.
  ///
  /// In id, this message translates to:
  /// **'Transaksi {date}'**
  String selectedDateTransactionsLabel(String date);

  /// No description provided for @noTransactionsInPeriodTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum Ada Transaksi di Periode Ini'**
  String get noTransactionsInPeriodTitle;

  /// No description provided for @noTransactionsInPeriodSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Ketuk tombol + Catat Cepat di kanan bawah untuk mencatat transaksi, atau ketuk Muat Data Contoh.'**
  String get noTransactionsInPeriodSubtitle;

  /// No description provided for @trxTypeReceivableOut.
  ///
  /// In id, this message translates to:
  /// **'Piutang Keluar'**
  String get trxTypeReceivableOut;

  /// No description provided for @trxTypeDebtIn.
  ///
  /// In id, this message translates to:
  /// **'Hutang Masuk'**
  String get trxTypeDebtIn;

  /// No description provided for @trxTypeReceivableSettle.
  ///
  /// In id, this message translates to:
  /// **'Terima Cicilan'**
  String get trxTypeReceivableSettle;

  /// No description provided for @trxTypePayableSettle.
  ///
  /// In id, this message translates to:
  /// **'Bayar Hutang'**
  String get trxTypePayableSettle;

  /// No description provided for @nonConsumptionBookBadge.
  ///
  /// In id, this message translates to:
  /// **'Buku Hutang (Bukan Konsumsi)'**
  String get nonConsumptionBookBadge;

  /// No description provided for @debtHeaderReceivablesLabel.
  ///
  /// In id, this message translates to:
  /// **'Total Piutang di Teman'**
  String get debtHeaderReceivablesLabel;

  /// No description provided for @debtHeaderPayablesLabel.
  ///
  /// In id, this message translates to:
  /// **'Total Hutang Saya'**
  String get debtHeaderPayablesLabel;

  /// No description provided for @lendingCapBarTitle.
  ///
  /// In id, this message translates to:
  /// **'Batas Rem Piutang (Lending Cap)'**
  String get lendingCapBarTitle;

  /// No description provided for @editLendingCapTitle.
  ///
  /// In id, this message translates to:
  /// **'Atur Batas Rem Piutang'**
  String get editLendingCapTitle;

  /// No description provided for @editLendingCapSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Munculkan peringatan otomatis saat total uang yang tertahan di teman melewati batas ini.'**
  String get editLendingCapSubtitle;

  /// No description provided for @filterAllContacts.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get filterAllContacts;

  /// No description provided for @filterTheyOweMe.
  ///
  /// In id, this message translates to:
  /// **'Mereka Hutang'**
  String get filterTheyOweMe;

  /// No description provided for @filterIOweThem.
  ///
  /// In id, this message translates to:
  /// **'Saya Hutang'**
  String get filterIOweThem;

  /// No description provided for @filterOverdue.
  ///
  /// In id, this message translates to:
  /// **'Jatuh Tempo'**
  String get filterOverdue;

  /// No description provided for @addContactBtn.
  ///
  /// In id, this message translates to:
  /// **'+ Kontak'**
  String get addContactBtn;

  /// No description provided for @addContactTitle.
  ///
  /// In id, this message translates to:
  /// **'Tambah Kontak Teman'**
  String get addContactTitle;

  /// No description provided for @contactPhoneNoteLabel.
  ///
  /// In id, this message translates to:
  /// **'No. WhatsApp / Catatan Singkat (Opsional)'**
  String get contactPhoneNoteLabel;

  /// No description provided for @contactPhoneNoteHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: 0812-xxxx / Teman Kantor'**
  String get contactPhoneNoteHint;

  /// No description provided for @contactSavedMsg.
  ///
  /// In id, this message translates to:
  /// **'Kontak berhasil disimpan.'**
  String get contactSavedMsg;

  /// No description provided for @emptyContactsTitle.
  ///
  /// In id, this message translates to:
  /// **'Buku Hutang Masih Kosong'**
  String get emptyContactsTitle;

  /// No description provided for @emptyContactsSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Catat pinjaman/talangan baru melalui tombol + Catat Cepat, atau tambahkan kontak teman.'**
  String get emptyContactsSubtitle;

  /// No description provided for @contactStatusTheyOwe.
  ///
  /// In id, this message translates to:
  /// **'PIUTANG • Berhutang ke Anda'**
  String get contactStatusTheyOwe;

  /// No description provided for @contactStatusIOwe.
  ///
  /// In id, this message translates to:
  /// **'HUTANG • Anda Berhutang'**
  String get contactStatusIOwe;

  /// No description provided for @contactStatusSettled.
  ///
  /// In id, this message translates to:
  /// **'LUNAS • Saldo Bersih Rp 0'**
  String get contactStatusSettled;

  /// No description provided for @openDebtsCountLabel.
  ///
  /// In id, this message translates to:
  /// **'{count} tagihan aktif'**
  String openDebtsCountLabel(int count);

  /// No description provided for @contactDetailTitle.
  ///
  /// In id, this message translates to:
  /// **'Rincian Buku Hutang Kontak'**
  String get contactDetailTitle;

  /// No description provided for @settleOrPayBtn.
  ///
  /// In id, this message translates to:
  /// **'Bayar / Cicil'**
  String get settleOrPayBtn;

  /// No description provided for @shareInvoiceBtn.
  ///
  /// In id, this message translates to:
  /// **'Struk Gambar'**
  String get shareInvoiceBtn;

  /// No description provided for @activeDebtsSectionTitle.
  ///
  /// In id, this message translates to:
  /// **'TAGIHAN BELUM LUNAS'**
  String get activeDebtsSectionTitle;

  /// No description provided for @paymentHistorySectionTitle.
  ///
  /// In id, this message translates to:
  /// **'RIWAYAT CICILAN & PELUNASAN'**
  String get paymentHistorySectionTitle;

  /// No description provided for @noActiveDebtsText.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada tagihan aktif untuk kontak ini.'**
  String get noActiveDebtsText;

  /// No description provided for @noPaymentHistoryText.
  ///
  /// In id, this message translates to:
  /// **'Belum ada riwayat cicilan atau pelunasan.'**
  String get noPaymentHistoryText;

  /// No description provided for @initialAndRemainingLabel.
  ///
  /// In id, this message translates to:
  /// **'Awal: {initial} • Sisa: {remaining}'**
  String initialAndRemainingLabel(String initial, String remaining);

  /// No description provided for @settlementSheetTitleReceivable.
  ///
  /// In id, this message translates to:
  /// **'Terima Pembayaran / Cicilan Piutang'**
  String get settlementSheetTitleReceivable;

  /// No description provided for @settlementSheetTitlePayable.
  ///
  /// In id, this message translates to:
  /// **'Bayar / Cicil Hutang Anda'**
  String get settlementSheetTitlePayable;

  /// No description provided for @settlementMethodCash.
  ///
  /// In id, this message translates to:
  /// **'Tunai / Dompet'**
  String get settlementMethodCash;

  /// No description provided for @settlementMethodItemTreat.
  ///
  /// In id, this message translates to:
  /// **'Barang / Traktiran'**
  String get settlementMethodItemTreat;

  /// No description provided for @allocationModeFifo.
  ///
  /// In id, this message translates to:
  /// **'Otomatis FIFO (Terlama Dulu)'**
  String get allocationModeFifo;

  /// No description provided for @allocationModeSpecific.
  ///
  /// In id, this message translates to:
  /// **'Pilih Tagihan Spesifik'**
  String get allocationModeSpecific;

  /// No description provided for @recordTreatAsExpenseToggle.
  ///
  /// In id, this message translates to:
  /// **'Catat sebagai konsumsi pengeluaran harian?'**
  String get recordTreatAsExpenseToggle;

  /// No description provided for @recordTreatAsExpenseSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Jika dicentang, nilai traktiran masuk ke laporan konsumsi tanpa memotong saldo dompet.'**
  String get recordTreatAsExpenseSubtitle;

  /// No description provided for @payFullRemainingChip.
  ///
  /// In id, this message translates to:
  /// **'Lunasi Sisa ({amount})'**
  String payFullRemainingChip(String amount);

  /// No description provided for @settlementSuccessMsg.
  ///
  /// In id, this message translates to:
  /// **'Pelunasan / cicilan berhasil dicatat.'**
  String get settlementSuccessMsg;

  /// No description provided for @cancelPaymentConfirmTitle.
  ///
  /// In id, this message translates to:
  /// **'Batalkan Cicilan Ini?'**
  String get cancelPaymentConfirmTitle;

  /// No description provided for @cancelPaymentConfirmSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Sisa tagihan dan saldo dompet (jika tunai) akan dikembalikan seperti semula.'**
  String get cancelPaymentConfirmSubtitle;

  /// No description provided for @paymentCancelledMsg.
  ///
  /// In id, this message translates to:
  /// **'Cicilan berhasil dibatalkan dan saldo dikembalikan.'**
  String get paymentCancelledMsg;

  /// No description provided for @autoNettingBannerTitle.
  ///
  /// In id, this message translates to:
  /// **'Deteksi Saldo Silang (Auto-Netting)!'**
  String get autoNettingBannerTitle;

  /// No description provided for @autoNettingBannerSubtitle.
  ///
  /// In id, this message translates to:
  /// **'{contact} memiliki saldo berlawanan sebesar {oppositeAmount}. Potong langsung tanpa memindahkan uang?'**
  String autoNettingBannerSubtitle(String contact, String oppositeAmount);

  /// No description provided for @applyAutoNettingBtn.
  ///
  /// In id, this message translates to:
  /// **'Gunakan Auto-Netting'**
  String get applyAutoNettingBtn;

  /// No description provided for @invoiceHeaderTitle.
  ///
  /// In id, this message translates to:
  /// **'KASKITA • CATATAN BUKU HUTANG'**
  String get invoiceHeaderTitle;

  /// No description provided for @invoicePrintedDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal Cetak: {date}'**
  String invoicePrintedDate(String date);

  /// No description provided for @invoiceContactName.
  ///
  /// In id, this message translates to:
  /// **'Nama Kontak'**
  String get invoiceContactName;

  /// No description provided for @invoiceStatusLabel.
  ///
  /// In id, this message translates to:
  /// **'Status'**
  String get invoiceStatusLabel;

  /// No description provided for @invoiceRemainingTotal.
  ///
  /// In id, this message translates to:
  /// **'SISA TAGIHAN BERSIH'**
  String get invoiceRemainingTotal;

  /// No description provided for @invoiceUnpaidListTitle.
  ///
  /// In id, this message translates to:
  /// **'RINCIAN TAGIHAN BELUM LUNAS:'**
  String get invoiceUnpaidListTitle;

  /// No description provided for @invoiceRecentPaymentsTitle.
  ///
  /// In id, this message translates to:
  /// **'RIWAYAT PEMBAYARAN TERAKHIR:'**
  String get invoiceRecentPaymentsTitle;

  /// No description provided for @invoiceFooterText.
  ///
  /// In id, this message translates to:
  /// **'Dibuat otomatis melalui aplikasi KasKita'**
  String get invoiceFooterText;

  /// No description provided for @shareInvoiceActionBtn.
  ///
  /// In id, this message translates to:
  /// **'Bagikan Gambar Struk (PNG)'**
  String get shareInvoiceActionBtn;

  /// No description provided for @reportSectionTitle.
  ///
  /// In id, this message translates to:
  /// **'GRAFIK & LAPORAN BULANAN'**
  String get reportSectionTitle;

  /// No description provided for @monthlyComparisonTitle.
  ///
  /// In id, this message translates to:
  /// **'Konsumsi Murni vs Uang Tertahan (6 Bulan)'**
  String get monthlyComparisonTitle;

  /// No description provided for @legendPureExpense.
  ///
  /// In id, this message translates to:
  /// **'Konsumsi Murni'**
  String get legendPureExpense;

  /// No description provided for @legendReceivablesOut.
  ///
  /// In id, this message translates to:
  /// **'Tertahan di Teman (Piutang)'**
  String get legendReceivablesOut;

  /// No description provided for @categoryBreakdownTitle.
  ///
  /// In id, this message translates to:
  /// **'Rincian Pengeluaran per Kategori'**
  String get categoryBreakdownTitle;

  /// No description provided for @emptyReportChartText.
  ///
  /// In id, this message translates to:
  /// **'Belum ada data pengeluaran konsumsi pada bulan terpilih.'**
  String get emptyReportChartText;

  /// No description provided for @securitySectionTitle.
  ///
  /// In id, this message translates to:
  /// **'KEAMANAN & PENGINGAT JATUH TEMPO'**
  String get securitySectionTitle;

  /// No description provided for @appLockToggleTitle.
  ///
  /// In id, this message translates to:
  /// **'Kunci Aplikasi (PIN 6 Digit & Biometrik)'**
  String get appLockToggleTitle;

  /// No description provided for @appLockToggleSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Lindungi catatan keuangan saat aplikasi dibuka.'**
  String get appLockToggleSubtitle;

  /// No description provided for @changePinAction.
  ///
  /// In id, this message translates to:
  /// **'Ubah PIN'**
  String get changePinAction;

  /// No description provided for @setupPinTitle.
  ///
  /// In id, this message translates to:
  /// **'Atur PIN Keamanan 6 Digit'**
  String get setupPinTitle;

  /// No description provided for @enterPinSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Masukkan 6 digit angka PIN rahasia Anda.'**
  String get enterPinSubtitle;

  /// No description provided for @pinSetSuccessMsg.
  ///
  /// In id, this message translates to:
  /// **'PIN keamanan berhasil disimpan dan Kunci Aplikasi aktif.'**
  String get pinSetSuccessMsg;

  /// No description provided for @pinDisabledMsg.
  ///
  /// In id, this message translates to:
  /// **'Kunci Aplikasi dinonaktifkan.'**
  String get pinDisabledMsg;

  /// No description provided for @lockScreenTitle.
  ///
  /// In id, this message translates to:
  /// **'KasKita Terkunci'**
  String get lockScreenTitle;

  /// No description provided for @lockScreenSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Masukkan PIN 6 digit atau gunakan Sidik Jari / Wajah untuk membuka.'**
  String get lockScreenSubtitle;

  /// No description provided for @unlockWithBiometricBtn.
  ///
  /// In id, this message translates to:
  /// **'Buka dengan Biometrik'**
  String get unlockWithBiometricBtn;

  /// No description provided for @dueReminderToggleTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengingat Otomatis Jatuh Tempo (09.00)'**
  String get dueReminderToggleTitle;

  /// No description provided for @dueReminderToggleSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Jadwalkan notifikasi lokal H-1 dan Hari-H tagihan aktif.'**
  String get dueReminderToggleSubtitle;

  /// No description provided for @rescheduleRemindersBtn.
  ///
  /// In id, this message translates to:
  /// **'Sinkronkan Pengingat Sekarang'**
  String get rescheduleRemindersBtn;

  /// No description provided for @remindersScheduledMsg.
  ///
  /// In id, this message translates to:
  /// **'{count} pengingat jatuh tempo berhasil dijadwalkan.'**
  String remindersScheduledMsg(int count);

  /// No description provided for @dataBackupSectionTitle.
  ///
  /// In id, this message translates to:
  /// **'CADANGKAN & EKSPOR DATA LOKAL'**
  String get dataBackupSectionTitle;

  /// No description provided for @exportBackupJsonBtn.
  ///
  /// In id, this message translates to:
  /// **'Cadangkan (.JSON)'**
  String get exportBackupJsonBtn;

  /// No description provided for @exportBackupDbBtn.
  ///
  /// In id, this message translates to:
  /// **'Cadangkan (.DB)'**
  String get exportBackupDbBtn;

  /// No description provided for @restoreBackupBtn.
  ///
  /// In id, this message translates to:
  /// **'Pulihkan Cadangan (.JSON / .DB)'**
  String get restoreBackupBtn;

  /// No description provided for @exportCsvBtn.
  ///
  /// In id, this message translates to:
  /// **'Ekspor Laporan (.CSV)'**
  String get exportCsvBtn;

  /// No description provided for @backupExportedMsg.
  ///
  /// In id, this message translates to:
  /// **'File cadangan berhasil dibuat dan siap disimpan/dibagikan.'**
  String get backupExportedMsg;

  /// No description provided for @backupRestoredMsg.
  ///
  /// In id, this message translates to:
  /// **'Data berhasil dipulihkan! Seluruh buku kas telah disinkronkan.'**
  String get backupRestoredMsg;

  /// No description provided for @otaSectionTitle.
  ///
  /// In id, this message translates to:
  /// **'PEMBARUAN APLIKASI & TENTANG'**
  String get otaSectionTitle;

  /// No description provided for @currentVersionLabel.
  ///
  /// In id, this message translates to:
  /// **'Versi Terpasang'**
  String get currentVersionLabel;

  /// No description provided for @checkUpdateBtn.
  ///
  /// In id, this message translates to:
  /// **'Cek Pembaruan (GitHub OTA)'**
  String get checkUpdateBtn;

  /// No description provided for @checkingUpdateMsg.
  ///
  /// In id, this message translates to:
  /// **'Memeriksa rilis terbaru di GitHub...'**
  String get checkingUpdateMsg;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In id, this message translates to:
  /// **'Pembaruan Tersedia ({version})'**
  String updateAvailableTitle(String version);

  /// No description provided for @alreadyLatestVersionMsg.
  ///
  /// In id, this message translates to:
  /// **'Anda sudah menggunakan versi terbaru ({version}).'**
  String alreadyLatestVersionMsg(String version);

  /// No description provided for @downloadUpdateBtn.
  ///
  /// In id, this message translates to:
  /// **'Unduh / Buka Rilis'**
  String get downloadUpdateBtn;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
