// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'KasKita';

  @override
  String get save => 'Simpan';

  @override
  String get cancel => 'Batal';

  @override
  String get reset => 'Reset';

  @override
  String get delete => 'Hapus';

  @override
  String get edit => 'Ubah';

  @override
  String get skip => 'Lewati';

  @override
  String get close => 'Tutup';

  @override
  String get switchThemeTooltip => 'Ganti Tema Terang / Gelap';

  @override
  String get switchLanguageTooltip => 'Ganti Bahasa (ID / EN)';

  @override
  String get phaseBadge => 'v0.4.0 • FASE 3';

  @override
  String get navHome => 'Beranda';

  @override
  String get navDebtBook => 'Buku Hutang';

  @override
  String get navSummary => 'Ringkasan';

  @override
  String get allWallets => 'Semua Dompet';

  @override
  String get addWallet => '+ Dompet';

  @override
  String get manageCategories => 'Kategori';

  @override
  String get transferAction => 'Transfer';

  @override
  String get walletTypeCash => 'Tunai';

  @override
  String get walletTypeBank => 'Bank';

  @override
  String get walletTypeEwallet => 'E-Wallet';

  @override
  String get onboardingTitle => 'Atur Saldo Awal Dompet Tunai?';

  @override
  String get onboardingSubtitle =>
      'Masukkan jumlah uang tunai yang Anda pegang saat ini, atau lewati untuk mulai dari Rp 0.';

  @override
  String get saveInitialBalance => 'Simpan Saldo Awal';

  @override
  String get addWalletTitle => 'Tambah Dompet Baru';

  @override
  String get editWalletTitle => 'Ubah Dompet';

  @override
  String get walletNameLabel => 'Nama Dompet';

  @override
  String get walletNameHint => 'Contoh: BCA, Mandiri, GoPay';

  @override
  String get walletTypeLabel => 'Tipe Dompet';

  @override
  String get initialBalanceLabel => 'SALDO AWAL DOMPET';

  @override
  String get transferTitle => 'Transfer Antar Dompet';

  @override
  String get transferSubtitle =>
      'Mutasi saldo internal tanpa mengotori grafik pengeluaran/pemasukan.';

  @override
  String get sourceWalletLabel => 'Dari Dompet (Asal)';

  @override
  String get targetWalletLabel => 'Ke Dompet (Tujuan)';

  @override
  String get transferAmountLabel => 'NOMINAL TRANSFER';

  @override
  String get transferNoteHint =>
      'Catatan transfer (opsional, misal: Tarik Tunai ATM)';

  @override
  String get transferSuccessMsg => 'Transfer antar dompet berhasil disimpan.';

  @override
  String get walletSavedMsg => 'Dompet berhasil disimpan.';

  @override
  String get categoryManagementTitle => 'Kelola Kategori Kas';

  @override
  String get expenseTab => 'Pengeluaran';

  @override
  String get incomeTab => 'Pemasukan';

  @override
  String get addCategoryHint => 'Nama kategori kustom baru...';

  @override
  String get addCategoryBtn => 'Tambah';

  @override
  String activeWalletsCount(int count) {
    return '$count Dompet Aktif';
  }

  @override
  String categoriesAndContactsCount(int categories, int contacts) {
    return '$categories Kategori • $contacts Kontak';
  }

  @override
  String get activeWalletBalanceLabel => 'SALDO DOMPET AKTIF';

  @override
  String selectedWalletBalanceLabel(String walletName) {
    return 'SALDO DOMPET ($walletName)';
  }

  @override
  String get safeToSpendLabel => 'Dana Aman Siap Pakai';

  @override
  String get netWorthLabel => 'Kekayaan Bersih';

  @override
  String get loadDemoData => 'Muat Data Contoh';

  @override
  String get resetDataToZero => 'Reset Data (Rp0)';

  @override
  String get emptyTransactionsTitle => 'Belum Ada Catatan Transaksi';

  @override
  String get emptyTransactionsSubtitle =>
      'Gunakan tombol Transfer di atas, tambah Dompet baru, atau ketuk \"Muat Data Contoh\" untuk melihat simulasi transaksi.';

  @override
  String get loadDemoDataNow => 'Muat Data Contoh Sekarang';

  @override
  String get quickRecord => 'Catat Cepat';

  @override
  String get quickInputTitle => 'Input Transaksi Satu Pintu (< 5 Detik)';

  @override
  String get transactionAmountLabel => 'NOMINAL TRANSAKSI';

  @override
  String walletOutflowLabel(String walletName, String amount) {
    return '$walletName • Kas Keluar: $amount';
  }

  @override
  String transferMutationLabel(String fromWallet, String toWallet) {
    return 'Transfer: $fromWallet -> $toWallet';
  }

  @override
  String get debtBookCategoryLabel => 'Buku Hutang';

  @override
  String get transferCategoryLabel => 'Mutasi Kas';

  @override
  String get nonCashLabel => 'Non-Tunai';

  @override
  String get tabDebtPlaceholderTitle => 'Modul Buku Hutang (Fase 4)';

  @override
  String get tabDebtPlaceholderSubtitle =>
      'Akan menampilkan direktori kontak, Saldo Bersih, Cicilan FIFO, Auto-Netting, Lunas Traktiran, dan Struk Gambar.';

  @override
  String get tabSummaryPlaceholderTitle =>
      'Modul Laporan & Pengaturan (Fase 5)';

  @override
  String get tabSummaryPlaceholderSubtitle =>
      'Akan menampilkan Grafik Bulanan, Rem Piutang, Kunci PIN/Biometrik, Backup/Restore Lokal, dan Update OTA.';

  @override
  String get badgeUnpaid => 'BELUM LUNAS';

  @override
  String get badgePartial => 'DICICIL';

  @override
  String get badgePaid => 'LUNAS';

  @override
  String get badgeGood => 'AMAN';

  @override
  String get badgeLate => 'TELAT';

  @override
  String get badgeWarning => 'PERHATIAN';

  @override
  String get defaultWalletCash => 'Dompet Tunai';

  @override
  String get catFoodDrink => 'Makan & Minum';

  @override
  String get catTransportFuel => 'Transport & BBM';

  @override
  String get catDailyShopping => 'Belanja Harian';

  @override
  String get catBillsQuota => 'Tagihan & Kuota';

  @override
  String get catEntertainment => 'Hiburan & Nongkrong';

  @override
  String get catOtherExpense => 'Lainnya';

  @override
  String get catSalary => 'Gaji / Upah';

  @override
  String get catBusiness => 'Hasil Usaha';

  @override
  String get catBonusGift => 'Bonus / Pemberian';

  @override
  String get catOtherIncome => 'Lainnya';

  @override
  String get errUnexpectedUiTitle => 'Terjadi kendala tampilan';

  @override
  String get errUnexpectedGeneral =>
      'Terjadi kesalahan yang tidak terduga. Silakan coba lagi.';

  @override
  String get errDatabaseOperation =>
      'Gagal memproses penyimpanan database lokal.';

  @override
  String get errAmountMustBePositive => 'Nominal harus lebih besar dari Rp 0.';

  @override
  String get errWalletRequired => 'Silakan pilih dompet terlebih dahulu.';

  @override
  String get errWalletNameRequired => 'Nama dompet tidak boleh kosong.';

  @override
  String get errDuplicateWalletName =>
      'Nama dompet sudah digunakan. Gunakan nama lain.';

  @override
  String get errCannotArchiveLastWallet =>
      'Tidak dapat menghapus/mengarsipkan satu-satunya dompet aktif.';

  @override
  String get errCategoryRequired =>
      'Silakan pilih kategori transaksi terlebih dahulu.';

  @override
  String get errCategoryNameRequired => 'Nama kategori tidak boleh kosong.';

  @override
  String get errContactRequired =>
      'Silakan pilih atau masukkan nama kontak teman.';

  @override
  String get errTransferSameWallet =>
      'Dompet asal dan dompet tujuan tidak boleh sama.';

  @override
  String get errInsufficientWalletBalance =>
      'Saldo dompet asal tidak mencukupi untuk transaksi ini.';

  @override
  String get errSplitAmountExceedsTotal =>
      'Total porsi talangan teman tidak boleh melebihi total bayar di kasir.';

  @override
  String get errTransactionLockedHasInstallments =>
      'Transaksi ini sudah memiliki riwayat cicilan. Batalkan cicilan terkait di Buku Hutang terlebih dahulu sebelum mengubah/menghapus transaksi awal.';

  @override
  String get errOverpaymentExceedsRemaining =>
      'Nominal pembayaran melebihi sisa tagihan yang belum lunas.';

  @override
  String get errDuplicateContactName =>
      'Nama kontak sudah terdaftar. Gunakan nama lain.';

  @override
  String errLendingCapExceededWarning(String limit) {
    return 'Perhatian: Total piutang aktif akan melewati batas Rem Piutang ($limit).';
  }

  @override
  String get errPinInvalid => 'PIN yang dimasukkan salah. Silakan coba lagi.';

  @override
  String get errBackupRestoreFailed =>
      'File cadangan tidak valid atau gagal dipulihkan.';

  @override
  String get errOtaCheckFailed =>
      'Gagal memeriksa pembaruan. Pastikan perangkat terhubung ke internet.';

  @override
  String get modeExpense => 'Pengeluaran';

  @override
  String get modeIncome => 'Pemasukan';

  @override
  String get modeReceivable => 'Piutang';

  @override
  String get modePayable => 'Hutang';

  @override
  String get modeTransfer => 'Transfer';

  @override
  String get selectWalletLabel => 'Dompet';

  @override
  String get selectCategoryLabel => 'Kategori';

  @override
  String get selectContactLabel => 'Kontak Teman';

  @override
  String get contactNameHint => 'Nama teman (pilih atau ketik baru)...';

  @override
  String get dueDateLabel => 'Jatuh Tempo';

  @override
  String get noDueDate => 'Tanpa Jatuh Tempo';

  @override
  String get transactionDateLabel => 'Tanggal';

  @override
  String get transactionNoteHint => 'Catatan transaksi (opsional)...';

  @override
  String get splitExpenseToggleTitle => 'Sekalian Talangi Teman?';

  @override
  String get splitExpenseToggleSubtitle =>
      'Pisahkan konsumsi murni Anda dari porsi piutang teman.';

  @override
  String get splitEqual5050 => 'Bagi Rata (50:50)';

  @override
  String get splitFriendShareLabel => 'Porsi Talangan Teman (Rp)';

  @override
  String splitSummaryText(
    String walletOut,
    String pureExpense,
    String contact,
    String friendShare,
  ) {
    return 'Kas Keluar: $walletOut -> Konsumsi Anda: $pureExpense | Piutang $contact: $friendShare';
  }

  @override
  String get editTransactionTitle => 'Detail & Ubah Transaksi';

  @override
  String get deleteTransactionConfirmTitle => 'Hapus Transaksi Ini?';

  @override
  String get deleteTransactionConfirmSubtitle =>
      'Saldo dompet dan buku hutang terkait akan dikembalikan (rollback) secara otomatis.';

  @override
  String get transactionSavedMsg => 'Catatan transaksi berhasil disimpan.';

  @override
  String get transactionDeletedMsg =>
      'Transaksi berhasil dihapus dan saldo telah dikembalikan.';

  @override
  String get subTabDaily => 'Harian';

  @override
  String get subTabCalendar => 'Kalender';

  @override
  String get subTabMonthly => 'Bulanan';

  @override
  String get summaryIncomeLabel => 'Pemasukan';

  @override
  String get summaryPureExpenseLabel => 'Konsumsi Murni';

  @override
  String get summaryNetDifferenceLabel => 'Selisih Bersih';

  @override
  String get weeklyBreakdownLabel => 'Rincian Mingguan';

  @override
  String weekRangeLabel(int week, String startDay, String endDay) {
    return 'Minggu $week (Tgl $startDay–$endDay)';
  }

  @override
  String selectedDateTransactionsLabel(String date) {
    return 'Transaksi $date';
  }

  @override
  String get noTransactionsInPeriodTitle =>
      'Belum Ada Transaksi di Periode Ini';

  @override
  String get noTransactionsInPeriodSubtitle =>
      'Ketuk tombol + Catat Cepat di kanan bawah untuk mencatat transaksi, atau ketuk Muat Data Contoh.';

  @override
  String get trxTypeReceivableOut => 'Piutang Keluar';

  @override
  String get trxTypeDebtIn => 'Hutang Masuk';

  @override
  String get trxTypeReceivableSettle => 'Terima Cicilan';

  @override
  String get trxTypePayableSettle => 'Bayar Hutang';

  @override
  String get nonConsumptionBookBadge => 'Buku Hutang (Bukan Konsumsi)';
}
