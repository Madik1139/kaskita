import '../../l10n/app_localizations.dart';
import '../../l10n/app_localizations_en.dart';
import '../../l10n/app_localizations_id.dart';

/// Kode error terstandarisasi di seluruh lapisan Domain, Data (SQLite), dan UI.
/// Menjamin tidak ada pesan error yang di-hardcode dalam satu bahasa saja.
enum AppErrorCode {
  unexpectedGeneral,
  databaseOperation,
  amountMustBePositive,
  walletRequired,
  categoryRequired,
  contactRequired,
  transferSameWallet,
  insufficientWalletBalance,
  splitAmountExceedsTotal,
  transactionLockedHasInstallments,
  overpaymentExceedsRemaining,
  duplicateContactName,
  lendingCapExceededWarning,
  pinInvalid,
  backupRestoreFailed,
  otaCheckFailed,
}

/// Exception kustom KasKita yang membawa `AppErrorCode` agar dapat diterjemahkan
/// secara dinamis sesuai bahasa aktif (`id` atau `en`).
class AppException implements Exception {
  const AppException(
    this.code, {
    this.param,
    this.technicalDetails,
  });

  final AppErrorCode code;
  final String? param;
  final String? technicalDetails;

  /// Menerjemahkan `AppErrorCode` ke bahasa aktif menggunakan `AppLocalizations`.
  String toLocalizedMessage(AppLocalizations l10n) {
    switch (code) {
      case AppErrorCode.unexpectedGeneral:
        return l10n.errUnexpectedGeneral;
      case AppErrorCode.databaseOperation:
        return l10n.errDatabaseOperation;
      case AppErrorCode.amountMustBePositive:
        return l10n.errAmountMustBePositive;
      case AppErrorCode.walletRequired:
        return l10n.errWalletRequired;
      case AppErrorCode.categoryRequired:
        return l10n.errCategoryRequired;
      case AppErrorCode.contactRequired:
        return l10n.errContactRequired;
      case AppErrorCode.transferSameWallet:
        return l10n.errTransferSameWallet;
      case AppErrorCode.insufficientWalletBalance:
        return l10n.errInsufficientWalletBalance;
      case AppErrorCode.splitAmountExceedsTotal:
        return l10n.errSplitAmountExceedsTotal;
      case AppErrorCode.transactionLockedHasInstallments:
        return l10n.errTransactionLockedHasInstallments;
      case AppErrorCode.overpaymentExceedsRemaining:
        return l10n.errOverpaymentExceedsRemaining;
      case AppErrorCode.duplicateContactName:
        return l10n.errDuplicateContactName;
      case AppErrorCode.lendingCapExceededWarning:
        return l10n.errLendingCapExceededWarning(param ?? 'Rp 0');
      case AppErrorCode.pinInvalid:
        return l10n.errPinInvalid;
      case AppErrorCode.backupRestoreFailed:
        return l10n.errBackupRestoreFailed;
      case AppErrorCode.otaCheckFailed:
        return l10n.errOtaCheckFailed;
    }
  }

  /// Helper statis untuk menerjemahkan error apa pun (`AppException` maupun `Exception` umum)
  /// ke bahasa yang sedang dipilih pengguna.
  static String resolveError(Object error, AppLocalizations l10n) {
    if (error is AppException) {
      return error.toLocalizedMessage(l10n);
    }
    return l10n.errUnexpectedGeneral;
  }

  /// Fallback untuk Global Error Boundary ketika konteks widget belum memiliki `AppLocalizations`.
  static AppLocalizations fallbackL10n(String languageCode) {
    if (languageCode.toLowerCase().startsWith('en')) {
      return AppLocalizationsEn();
    }
    return AppLocalizationsId();
  }

  @override
  String toString() => 'AppException(${code.name})';
}

