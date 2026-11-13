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
  /// **'v0.3.0 • FASE 2'**
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
