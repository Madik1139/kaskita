import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/tabular_currency_text.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../models/wallet_model.dart';
import '../../providers/wallet_provider.dart';
import 'wallet_form_sheet.dart';

/// Modal Bottom Sheet untuk mengelola daftar Dompet Kas (Lihat, Tambah, Ubah, Arsipkan).
class WalletManagementSheet extends ConsumerWidget {
  const WalletManagementSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const WalletManagementSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AsyncValue<WalletsState> walletsAsync = ref.watch(walletsProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
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
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                l10n.walletManagementSheetTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                tooltip: l10n.close,
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(LucideIcons.x, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 360),
            child: walletsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object err, StackTrace _) => EmptyStateView(
                icon: LucideIcons.triangleAlert,
                title: l10n.errUnexpectedUiTitle,
                subtitle: AppException.resolveError(err, l10n),
              ),
              data: (WalletsState state) {
                if (state.wallets.isEmpty) {
                  return EmptyStateView(
                    icon: LucideIcons.wallet,
                    title: l10n.walletManagementTitle,
                    subtitle: l10n.emptyTransactionsSubtitle,
                  );
                }
                return TactileCard(
                  padding: EdgeInsets.zero,
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: state.wallets.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (BuildContext ctx, int idx) {
                      final WalletModel wallet = state.wallets[idx];
                      final String typeLabel = switch (wallet.type) {
                        'BANK' => l10n.walletTypeBank,
                        'EWALLET' => l10n.walletTypeEwallet,
                        _ => l10n.walletTypeCash,
                      };
                      final IconData typeIcon = switch (wallet.type) {
                        'BANK' => LucideIcons.landmark,
                        'EWALLET' => LucideIcons.smartphone,
                        _ => LucideIcons.wallet,
                      };
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 17,
                          backgroundColor: AppColors.accent(ctx)
                              .withValues(alpha: 0.12),
                          child: Icon(
                            typeIcon,
                            size: 16,
                            color: AppColors.accent(ctx),
                          ),
                        ),
                        title: Text(
                          LocalizationHelper.localizeWalletName(
                            wallet.name,
                            l10n,
                          ),
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          typeLabel,
                          style: Theme.of(ctx).textTheme.bodySmall,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            TabularCurrencyText(
                              amount: wallet.currentBalance,
                              fontSize: 13.5,
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              tooltip: l10n.edit,
                              onPressed: () => WalletFormSheet.show(
                                ctx,
                                editingWallet: wallet,
                              ),
                              icon: Icon(
                                LucideIcons.pencil,
                                size: 16,
                                color: AppColors.textSecondary(ctx),
                              ),
                            ),
                          ],
                        ),
                        onTap: () => WalletFormSheet.show(
                          ctx,
                          editingWallet: wallet,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => WalletFormSheet.show(context),
            icon: const Icon(LucideIcons.plus, size: 18),
            label: Text(l10n.addNewWalletBtn),
          ),
        ],
      ),
    );
  }
}

