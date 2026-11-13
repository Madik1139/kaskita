import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';

enum CurrencySemanticType {
  neutral,
  positive,
  negative,
  mutation,
  warning,
}

/// Widget reusable khusus untuk menampilkan nominal Rupiah dengan angka sejajar
/// (`FontFeature.tabularFigures()`) agar digit satuan, ribuan, dan jutaan lurus vertikal.
class TabularCurrencyText extends StatelessWidget {
  const TabularCurrencyText({
    required this.amount,
    super.key,
    this.fontSize = 15,
    this.fontWeight = FontWeight.w700,
    this.semanticType = CurrencySemanticType.neutral,
    this.showPlusSign = false,
    this.compact = false,
    this.customColor,
    this.textAlign,
  });

  final int amount;
  final double fontSize;
  final FontWeight fontWeight;
  final CurrencySemanticType semanticType;
  final bool showPlusSign;
  final bool compact;
  final Color? customColor;
  final TextAlign? textAlign;

  Color _resolveColor(BuildContext context) {
    if (customColor != null) {
      return customColor!;
    }
    switch (semanticType) {
      case CurrencySemanticType.positive:
        return AppColors.positive(context);
      case CurrencySemanticType.negative:
        return AppColors.negative(context);
      case CurrencySemanticType.mutation:
        return AppColors.mutation(context);
      case CurrencySemanticType.warning:
        return AppColors.warning(context);
      case CurrencySemanticType.neutral:
        return AppColors.textPrimary(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String text = compact
        ? CurrencyFormatter.formatCompact(amount, showSign: showPlusSign)
        : CurrencyFormatter.format(amount, showPlusSign: showPlusSign);

    return Text(
      text,
      textAlign: textAlign,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: _resolveColor(context),
            fontFeatures: AppTheme.tabularFigures,
            letterSpacing: fontSize >= 24 ? -0.5 : -0.1,
          ),
    );
  }
}

