import 'package:flutter/widgets.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/app_localizations_id.dart';

/// Extension & Helper untuk mempermudah akses `AppLocalizations` dan menerjemahkan
/// nama dompet/kategori bawaan database sesuai bahasa yang dipilih (`id` / `en`).
extension LocalizationBuildContextExtension on BuildContext {
  AppLocalizations get l10n =>
      AppLocalizations.of(this) ?? AppLocalizationsId();

  String get currentLanguageCode =>
      Localizations.maybeLocaleOf(this)?.languageCode ?? 'id';
}

class LocalizationHelper {
  LocalizationHelper._();

  /// Menerjemahkan nama dompet default (`Dompet Tunai`) jika bahasa Inggris dipilih.
  static String localizeWalletName(String rawName, AppLocalizations l10n) {
    if (rawName == 'Dompet Tunai') {
      return l10n.defaultWalletCash;
    }
    return rawName;
  }

  /// Menerjemahkan 10 nama kategori bawaan ke bahasa aktif (`id` atau `en`).
  /// Kategori kustom buatan pengguna ditampilkan apa adanya.
  static String localizeCategoryName(String? rawName, AppLocalizations l10n) {
    if (rawName == null || rawName.isEmpty) {
      return l10n.debtBookCategoryLabel;
    }
    switch (rawName) {
      case 'Makan & Minum':
        return l10n.catFoodDrink;
      case 'Transport & BBM':
        return l10n.catTransportFuel;
      case 'Belanja Harian':
        return l10n.catDailyShopping;
      case 'Tagihan & Kuota':
        return l10n.catBillsQuota;
      case 'Hiburan & Nongkrong':
        return l10n.catEntertainment;
      case 'Gaji / Upah':
        return l10n.catSalary;
      case 'Hasil Usaha':
        return l10n.catBusiness;
      case 'Bonus / Pemberian':
        return l10n.catBonusGift;
      case 'Lainnya':
        return l10n.catOtherExpense;
      default:
        return rawName;
    }
  }
}

