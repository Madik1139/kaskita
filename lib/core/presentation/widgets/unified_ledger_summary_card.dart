import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../l10n/app_localizations.dart';
import '../../models/ledger_summary_model.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/tabular_currency_text.dart';
import '../../widgets/tactile_card.dart';

/// Kartu Buku Kas Terpadu (3 Indikator Utama: S_dompet, D_aman, W_bersih).
class UnifiedLedgerSummaryCard extends StatelessWidget {
  const UnifiedLedgerSummaryCard({
    required this.overview,
    super.key,
  });

  final LedgerOverviewState overview;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return TactileCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                StatusBadge(
                  label: l10n.activeWalletsCount(overview.walletCount),
                  icon: LucideIcons.wallet,
                ),
                StatusBadge(
                  label: l10n.categoriesAndContactsCount(
                    overview.categoryCount,
                    overview.contactCount,
                  ),
                  variant: BadgeVariant.mutation,
                  compact: true,
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.activeWalletBalanceLabel,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 4),
                TabularCurrencyText(
                  amount: overview.walletBalance,
                  fontSize: 28,
                ),
              ],
            ),
          ),
          const Divider(),
          IntrinsicHeight(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.safeToSpendLabel,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        TabularCurrencyText(
                          amount: overview.safeToSpend,
                          fontSize: 15,
                          semanticType: overview.safeToSpend >= 0
                              ? CurrencySemanticType.positive
                              : CurrencySemanticType.negative,
                        ),
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.netWorthLabel,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        TabularCurrencyText(
                          amount: overview.netWorth,
                          fontSize: 15,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
