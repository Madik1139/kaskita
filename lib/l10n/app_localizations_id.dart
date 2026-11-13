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
  String get phase1Badge => 'v0.2.0 • FASE 1';

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
      'Ketuk \"Muat Data Contoh\" di atas untuk melihat pengelompokan tanggal ala Money Manager & Talangan Teman, atau tekan tombol (+) di bawah.';

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
  String get debtBookCategoryLabel => 'Buku Hutang';

  @override
  String get nonCashLabel => 'Non-Tunai';

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
  String get errAmountMustBePositive =>
      'Nominal transaksi harus lebih besar dari Rp 0.';

  @override
  String get errWalletRequired => 'Silakan pilih dompet terlebih dahulu.';

  @override
  String get errCategoryRequired =>
      'Silakan pilih kategori transaksi terlebih dahulu.';

  @override
  String get errContactRequired =>
      'Silakan pilih atau masukkan nama kontak teman.';

  @override
  String get errTransferSameWallet =>
      'Dompet asal dan dompet tujuan tidak boleh sama.';

  @override
  String get errInsufficientWalletBalance =>
      'Saldo dompet tidak mencukupi untuk transaksi ini.';

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
}
