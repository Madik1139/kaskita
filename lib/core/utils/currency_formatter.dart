import 'package:intl/intl.dart';

/// Utilitas pemformatan mata uang Rupiah untuk KasKita.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _idrFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final NumberFormat _numberOnlyFormat = NumberFormat.decimalPattern('id_ID');

  /// Format angka bulat ke format standar: `Rp 150.000` atau `-Rp 150.000`.
  static String format(int amount, {bool showPlusSign = false}) {
    final int absAmount = amount.abs();
    final String formatted = _idrFormat.format(absAmount);
    if (amount < 0) {
      return '-$formatted';
    }
    if (showPlusSign && amount > 0) {
      return '+$formatted';
    }
    return formatted;
  }

  /// Format angka tanpa simbol `Rp` (misal: `150.000`).
  static String formatDigitsOnly(int amount) {
    return _numberOnlyFormat.format(amount);
  }

  /// Format ringkas untuk sel kalender atau sumbu grafik (misal: `50rb`, `1,2jt`).
  static String formatCompact(int amount, {bool showSign = false}) {
    final int abs = amount.abs();
    final String sign = amount < 0
        ? '-'
        : (showSign && amount > 0)
            ? '+'
            : '';

    if (abs >= 1000000000) {
      final double val = abs / 1000000000;
      return '$sign${val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1).replaceAll('.', ',')}M';
    }
    if (abs >= 1000000) {
      final double val = abs / 1000000;
      return '$sign${val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1).replaceAll('.', ',')}jt';
    }
    if (abs >= 1000) {
      final int val = (abs / 1000).round();
      return '$sign${val}rb';
    }
    return '$sign$abs';
  }
}

