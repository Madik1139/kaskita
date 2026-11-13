import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';

/// Indikator 6 digit PIN & Keypad angka bergaya Tactile Financial Ledger.
class PinDigitDots extends StatelessWidget {
  const PinDigitDots({
    required this.length,
    this.maxDigits = 6,
    super.key,
  });

  final int length;
  final int maxDigits;

  @override
  Widget build(BuildContext context) {
    final Color accent = AppColors.accent(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(maxDigits, (int index) {
        final bool filled = index < length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 7),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: filled ? accent : AppColors.surfaceSecondary(context),
            shape: BoxShape.circle,
            border: Border.all(
              color: filled ? accent : AppColors.border(context),
              width: 1.5,
            ),
          ),
        );
      }),
    );
  }
}

class TactilePinKeypad extends StatelessWidget {
  const TactilePinKeypad({
    required this.onDigitTap,
    required this.onBackspaceTap,
    this.onBiometricTap,
    super.key,
  });

  final ValueChanged<String> onDigitTap;
  final VoidCallback onBackspaceTap;
  final VoidCallback? onBiometricTap;

  @override
  Widget build(BuildContext context) {
    const List<List<String>> rows = <List<String>>[
      <String>['1', '2', '3'],
      <String>['4', '5', '6'],
      <String>['7', '8', '9'],
      <String>['BIO', '0', 'DEL'],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rows.map((List<String> row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((String key) {
              if (key == 'BIO') {
                return _PinKeyButton(
                  onTap: onBiometricTap,
                  child: Icon(
                    LucideIcons.fingerprintPattern,
                    size: 22,
                    color: onBiometricTap != null
                        ? AppColors.accent(context)
                        : Colors.transparent,
                  ),
                );
              }
              if (key == 'DEL') {
                return _PinKeyButton(
                  onTap: onBackspaceTap,
                  child: Icon(
                    LucideIcons.delete,
                    size: 20,
                    color: AppColors.textPrimary(context),
                  ),
                );
              }
              return _PinKeyButton(
                onTap: () => onDigitTap(key),
                child: Text(
                  key,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _PinKeyButton extends StatelessWidget {
  const _PinKeyButton({
    required this.child,
    required this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (onTap == null) {
      return const SizedBox(width: 68, height: 54);
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 68,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: child,
      ),
    );
  }
}

