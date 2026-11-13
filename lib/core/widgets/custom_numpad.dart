import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/localization_helper.dart';

/// Komponen Keypad Angka Terintegrasi (`4x4`) beserta Quick Nominal Chips
/// (`+10rb`, `+20rb`, `+50rb`, `+100rb`, `Reset`) untuk target input < 5 detik.
class CustomNumpad extends StatelessWidget {
  const CustomNumpad({
    required this.amount,
    required this.onAmountChanged,
    required this.onSubmit,
    super.key,
    this.submitLabel,
    this.maxAmount = 999999999999,
    this.showQuickChips = true,
  });

  final int amount;
  final ValueChanged<int> onAmountChanged;
  final VoidCallback? onSubmit;
  final String? submitLabel;
  final int maxAmount;
  final bool showQuickChips;

  void _appendDigits(String digits) {
    final String currentStr = amount == 0 ? '' : amount.toString();
    final String nextStr = '$currentStr$digits';
    final int? parsed = int.tryParse(nextStr);
    if (parsed != null && parsed <= maxAmount) {
      onAmountChanged(parsed);
    }
  }

  void _backspace() {
    if (amount <= 9) {
      onAmountChanged(0);
      return;
    }
    final String currentStr = amount.toString();
    final String nextStr = currentStr.substring(0, currentStr.length - 1);
    onAmountChanged(int.tryParse(nextStr) ?? 0);
  }

  void _addQuickAmount(int delta) {
    final int next = amount + delta;
    if (next <= maxAmount) {
      onAmountChanged(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (showQuickChips) ...<Widget>[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                _QuickChip(
                  label: '+10rb',
                  onTap: () => _addQuickAmount(10000),
                ),
                const SizedBox(width: 6),
                _QuickChip(
                  label: '+20rb',
                  onTap: () => _addQuickAmount(20000),
                ),
                const SizedBox(width: 6),
                _QuickChip(
                  label: '+50rb',
                  onTap: () => _addQuickAmount(50000),
                ),
                const SizedBox(width: 6),
                _QuickChip(
                  label: '+100rb',
                  onTap: () => _addQuickAmount(100000),
                ),
                const SizedBox(width: 6),
                _QuickChip(
                  label: context.l10n.reset,
                  isDanger: true,
                  onTap: () => onAmountChanged(0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        // Grid 4 Kolom x 4 Baris
        Row(
          children: <Widget>[
            Expanded(child: _KeyButton(label: '7', onTap: () => _appendDigits('7'))),
            const SizedBox(width: 6),
            Expanded(child: _KeyButton(label: '8', onTap: () => _appendDigits('8'))),
            const SizedBox(width: 6),
            Expanded(child: _KeyButton(label: '9', onTap: () => _appendDigits('9'))),
            const SizedBox(width: 6),
            Expanded(
              child: _KeyButton(
                icon: LucideIcons.delete,
                isSecondary: true,
                onTap: _backspace,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: <Widget>[
            Expanded(child: _KeyButton(label: '4', onTap: () => _appendDigits('4'))),
            const SizedBox(width: 6),
            Expanded(child: _KeyButton(label: '5', onTap: () => _appendDigits('5'))),
            const SizedBox(width: 6),
            Expanded(child: _KeyButton(label: '6', onTap: () => _appendDigits('6'))),
            const SizedBox(width: 6),
            Expanded(
              child: _KeyButton(
                label: '000',
                isSecondary: true,
                onTap: () => _appendDigits('000'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(child: _KeyButton(label: '1', onTap: () => _appendDigits('1'))),
                      const SizedBox(width: 6),
                      Expanded(child: _KeyButton(label: '2', onTap: () => _appendDigits('2'))),
                      const SizedBox(width: 6),
                      Expanded(child: _KeyButton(label: '3', onTap: () => _appendDigits('3'))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: _KeyButton(label: '0', onTap: () => _appendDigits('0')),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _KeyButton(label: '00', onTap: () => _appendDigits('00')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: SizedBox(
                height: 98,
                child: Material(
                  color: onSubmit != null
                      ? AppColors.accent(context)
                      : AppColors.surfaceSecondary(context),
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: onSubmit,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 8,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              LucideIcons.check,
                              size: 20,
                              color: onSubmit != null
                                  ? (AppColors.isDark(context)
                                      ? AppColors.darkBackground
                                      : Colors.white)
                                  : AppColors.textSecondary(context),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              submitLabel ?? context.l10n.save,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontSize: 12.5,
                                    height: 1.15,
                                    fontWeight: FontWeight.w700,
                                    color: onSubmit != null
                                        ? (AppColors.isDark(context)
                                            ? AppColors.darkBackground
                                            : Colors.white)
                                        : AppColors.textSecondary(context),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.label,
    required this.onTap,
    this.isDanger = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final Color fg = isDanger
        ? AppColors.negative(context)
        : AppColors.textPrimary(context);
    final Color bg = isDanger
        ? AppColors.negativeBg(context)
        : AppColors.surfaceSecondary(context);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border(context), width: 1),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: fg,
                  fontFeatures: AppTheme.tabularFigures,
                ),
          ),
        ),
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({
    required this.onTap,
    this.label,
    this.icon,
    this.isSecondary = false,
  });

  final String? label;
  final IconData? icon;
  final bool isSecondary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg = isSecondary
        ? AppColors.surfaceSecondary(context)
        : AppColors.surface(context);

    return SizedBox(
      height: 46,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border(context), width: 1),
            ),
            child: Center(
              child: icon != null
                  ? Icon(icon, size: 19, color: AppColors.textPrimary(context))
                  : Text(
                      label ?? '',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            fontFeatures: AppTheme.tabularFigures,
                          ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

