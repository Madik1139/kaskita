import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Komponen kartu reusable bergaya "Tactile Financial Ledger" (Anti-AI-Slop).
/// Menggunakan border tegas `1px solid` tanpa bayangan kabur berlebihan.
class TactileCard extends StatelessWidget {
  const TactileCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(14),
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 10,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color cardBg = backgroundColor ?? AppColors.surface(context);
    final Color cardBorder = borderColor ?? AppColors.border(context);

    final Widget content = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: cardBorder, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );

    return content;
  }
}

