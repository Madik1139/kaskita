import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../features/wallets/models/wallet_model.dart';
import '../../../features/wallets/presentation/widgets/wallet_transfer_sheet.dart';
import '../../../features/wallets/providers/wallet_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../models/ledger_summary_model.dart';
import '../../theme/app_colors.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/tabular_currency_text.dart';
import '../../widgets/tactile_card.dart';

/// Kartu Buku Kas Terpadu (Unified Ledger Card):
/// Menampilkan Filter Pill Multi-Dompet, Pintasan Transfer & Kategori,
/// serta 3 Indikator Utama (S_dompet, D_aman, W_bersih).
class UnifiedLedgerSummaryCard extends ConsumerWidget {
  const UnifiedLedgerSummaryCard({
    required this.overview,
    super.key,
  });

  final LedgerOverviewState overview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final int? selectedWalletId = ref.watch(selectedWalletIdProvider);
    final WalletsState? walletsState = ref.watch(walletsProvider).valueOrNull;
    final List<WalletModel> wallets =
        walletsState?.wallets ?? <WalletModel>[];
    final WalletModel? selectedWallet =
        walletsState?.findById(selectedWalletId);

    final String selectedWalletLabel = selectedWallet != null
        ? LocalizationHelper.localizeWalletName(selectedWallet.name, l10n)
        : '';

    return TactileCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  _FilterPill(
                    label: l10n.allWallets,
                    icon: LucideIcons.layers,
                    selected: selectedWalletId == null,
                    onTap: () =>
                        ref.read(selectedWalletIdProvider.notifier).state = null,
                  ),
                  const SizedBox(width: 6),
                  for (final WalletModel wallet in wallets) ...<Widget>[
                    _FilterPill(
                      label: LocalizationHelper.localizeWalletName(
                        wallet.name,
                        l10n,
                      ),
                      icon: _walletTypeIcon(wallet.type),
                      selected: selectedWalletId == wallet.id,
                      onTap: () {
                        ref.read(selectedWalletIdProvider.notifier).state =
                            wallet.id;
                      },
                    ),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        selectedWallet != null
                            ? l10n
                                .selectedWalletBalanceLabel(
                                  selectedWalletLabel,
                                )
                                .toUpperCase()
                            : l10n.activeWalletBalanceLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                OutlinedButton.icon(
                  onPressed: () => WalletTransferSheet.show(
                    context,
                    wallets: wallets,
                    initialSourceWalletId: selectedWalletId,
                  ),
                  icon: Icon(
                    LucideIcons.arrowLeftRight,
                    size: 15,
                    color: AppColors.mutation(context),
                  ),
                  label: Text(
                    l10n.transferAction,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mutation(context),
                    ),
                  ),
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

  IconData _walletTypeIcon(String type) {
    switch (type) {
      case 'BANK':
        return LucideIcons.landmark;
      case 'EWALLET':
        return LucideIcons.smartphone;
      default:
        return LucideIcons.wallet;
    }
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = AppColors.accent(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: 0.14)
              : AppColors.surfaceSecondary(context),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? accent : AppColors.border(context),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 13,
              color: selected ? accent : AppColors.textSecondary(context),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? accent : AppColors.textPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
