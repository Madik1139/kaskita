import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../l10n/app_localizations.dart';
import '../../errors/app_exception.dart';
import '../../theme/app_colors.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/custom_numpad.dart';
import '../../widgets/tabular_currency_text.dart';
import '../../widgets/tactile_card.dart';

/// Bottom Sheet untuk menguji CustomNumpad (< 5 detik) dan pesan error terlokalisasi.
class QuickInputPreviewSheet extends StatefulWidget {
  const QuickInputPreviewSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const QuickInputPreviewSheet(),
    );
  }

  @override
  State<QuickInputPreviewSheet> createState() => _QuickInputPreviewSheetState();
}

class _QuickInputPreviewSheetState extends State<QuickInputPreviewSheet> {
  int _draftAmount = 0;
  String? _inlineErrorText;

  void _handleSubmit(AppLocalizations l10n) {
    if (_draftAmount <= 0) {
      setState(() {
        _inlineErrorText = AppException.resolveError(
          const AppException(AppErrorCode.amountMustBePositive),
          l10n,
        );
      });
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  l10n.quickInputTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(LucideIcons.x, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TactileCard(
              backgroundColor: AppColors.surfaceSecondary(context),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    l10n.transactionAmountLabel,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 4),
                  TabularCurrencyText(
                    amount: _draftAmount,
                    fontSize: 28,
                    semanticType: CurrencySemanticType.negative,
                  ),
                ],
              ),
            ),
            if (_inlineErrorText != null) ...<Widget>[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.negativeBg(context),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.negative(context),
                    width: 1,
                  ),
                ),
                child: Text(
                  _inlineErrorText!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.negative(context),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            CustomNumpad(
              amount: _draftAmount,
              onAmountChanged: (int next) {
                setState(() {
                  _draftAmount = next;
                  _inlineErrorText = null;
                });
              },
              onSubmit: () => _handleSubmit(l10n),
            ),
          ],
        ),
      ),
    );
  }
}
