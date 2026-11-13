import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/providers/ledger_overview_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../core/widgets/custom_numpad.dart';
import '../../../../core/widgets/tabular_currency_text.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/wallet_provider.dart';

/// Modal Bottom Sheet Onboarding Saldo Awal Dompet Tunai (opsional saat pertama kali buka).
class OnboardingBalanceSheet extends ConsumerStatefulWidget {
  const OnboardingBalanceSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: false,
      builder: (_) => const OnboardingBalanceSheet(),
    );
  }

  @override
  ConsumerState<OnboardingBalanceSheet> createState() =>
      _OnboardingBalanceSheetState();
}

class _OnboardingBalanceSheetState
    extends ConsumerState<OnboardingBalanceSheet> {
  int _amount = 0;
  bool _isSaving = false;

  Future<void> _submitBalance(int value) async {
    if (_isSaving) {
      return;
    }
    setState(() => _isSaving = true);
    try {
      await ref.read(walletsProvider.notifier).completeOnboarding(value);
      await ref.read(ledgerOverviewProvider.notifier).refreshOverview();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        final String msg = AppException.resolveError(error, context.l10n);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Icon(
                LucideIcons.wallet,
                size: 20,
                color: AppColors.accent(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.onboardingTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(
                onPressed: _isSaving ? null : () => _submitBalance(0),
                child: Text(l10n.skip),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.onboardingSubtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          TactileCard(
            backgroundColor: AppColors.surfaceSecondary(context),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  '${l10n.initialBalanceLabel} (${l10n.defaultWalletCash.toUpperCase()})',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 4),
                TabularCurrencyText(
                  amount: _amount,
                  fontSize: 30,
                  semanticType: CurrencySemanticType.positive,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          CustomNumpad(
            amount: _amount,
            onAmountChanged: (int nextValue) =>
                setState(() => _amount = nextValue),
            submitLabel: l10n.save,
            onSubmit: () => _submitBalance(_amount),
          ),
        ],
      ),
    );
  }
}
