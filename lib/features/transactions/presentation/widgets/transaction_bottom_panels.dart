import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/category_icon_mapper.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../core/widgets/custom_numpad.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../wallets/models/category_model.dart';
import '../../../wallets/models/wallet_model.dart';

/// Mode panel input bawah pada form Catat Transaksi penuh.
enum TransactionInputPanel { numpad, wallet, category }

/// Panel bawah kontekstual pada form Transaksi:
/// berganti secara mulus antara Custom Numpad, Grid Dompet, dan Grid Kategori.
class TransactionBottomPanel extends StatelessWidget {
  const TransactionBottomPanel({
    required this.activePanel,
    required this.amount,
    required this.onAmountChanged,
    required this.onSubmit,
    required this.wallets,
    required this.selectedWalletId,
    required this.onSelectWallet,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelectCategory,
    required this.onClosePickerToNumpad,
    super.key,
  });

  final TransactionInputPanel activePanel;
  final int amount;
  final ValueChanged<int> onAmountChanged;
  final VoidCallback onSubmit;
  final List<WalletModel> wallets;
  final int selectedWalletId;
  final ValueChanged<int> onSelectWallet;
  final List<CategoryModel> categories;
  final int? selectedCategoryId;
  final ValueChanged<int> onSelectCategory;
  final VoidCallback onClosePickerToNumpad;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: Border(
          top: BorderSide(color: AppColors.border(context), width: 1),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: switch (activePanel) {
        TransactionInputPanel.numpad => CustomNumpad(
            amount: amount,
            onAmountChanged: onAmountChanged,
            submitLabel: l10n.save,
            onSubmit: onSubmit,
          ),
        TransactionInputPanel.wallet => _WalletGridPanel(
            wallets: wallets,
            selectedWalletId: selectedWalletId,
            onSelectWallet: onSelectWallet,
            onBackToNumpad: onClosePickerToNumpad,
          ),
        TransactionInputPanel.category => _CategoryGridPanel(
            categories: categories,
            selectedCategoryId: selectedCategoryId,
            onSelectCategory: onSelectCategory,
            onBackToNumpad: onClosePickerToNumpad,
          ),
      },
    );
  }
}

class _WalletGridPanel extends StatelessWidget {
  const _WalletGridPanel({
    required this.wallets,
    required this.selectedWalletId,
    required this.onSelectWallet,
    required this.onBackToNumpad,
  });

  final List<WalletModel> wallets;
  final int selectedWalletId;
  final ValueChanged<int> onSelectWallet;
  final VoidCallback onBackToNumpad;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final Color accent = AppColors.accent(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _PickerPanelHeader(
          title: l10n.selectWalletTitle,
          onBackToNumpad: onBackToNumpad,
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 248),
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: wallets.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.35,
            ),
            itemBuilder: (BuildContext ctx, int idx) {
              final WalletModel w = wallets[idx];
              final bool selected = w.id == selectedWalletId;
              final IconData icon = switch (w.type) {
                'BANK' => LucideIcons.landmark,
                'EWALLET' => LucideIcons.smartphone,
                _ => LucideIcons.wallet,
              };
              return InkWell(
                onTap: () => onSelectWallet(w.id),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? accent.withValues(alpha: 0.12)
                        : AppColors.surfaceSecondary(ctx),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected ? accent : AppColors.border(ctx),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        icon,
                        size: 17,
                        color: selected ? accent : AppColors.textSecondary(ctx),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              LocalizationHelper.localizeWalletName(
                                w.name,
                                l10n,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: selected
                                    ? accent
                                    : AppColors.textPrimary(ctx),
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(w.currentBalance),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(ctx).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryGridPanel extends StatelessWidget {
  const _CategoryGridPanel({
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelectCategory,
    required this.onBackToNumpad,
  });

  final List<CategoryModel> categories;
  final int? selectedCategoryId;
  final ValueChanged<int> onSelectCategory;
  final VoidCallback onBackToNumpad;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final Color accent = AppColors.accent(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _PickerPanelHeader(
          title: l10n.selectCategoryTitle,
          onBackToNumpad: onBackToNumpad,
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 248),
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.45,
            ),
            itemBuilder: (BuildContext ctx, int idx) {
              final CategoryModel cat = categories[idx];
              final bool selected = cat.id == selectedCategoryId;
              return InkWell(
                onTap: () => onSelectCategory(cat.id),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? accent.withValues(alpha: 0.12)
                        : AppColors.surfaceSecondary(ctx),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected ? accent : AppColors.border(ctx),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        CategoryIconMapper.getIcon(cat.iconName),
                        size: 18,
                        color: selected ? accent : AppColors.textSecondary(ctx),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        LocalizationHelper.localizeCategoryName(
                          cat.name,
                          l10n,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.15,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w600,
                          color: selected
                              ? accent
                              : AppColors.textPrimary(ctx),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PickerPanelHeader extends StatelessWidget {
  const _PickerPanelHeader({
    required this.title,
    required this.onBackToNumpad,
  });

  final String title;
  final VoidCallback onBackToNumpad;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
        TextButton.icon(
          onPressed: onBackToNumpad,
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          icon: const Icon(LucideIcons.calculator, size: 15),
          label: Text(context.l10n.transactionAmountLabel),
        ),
      ],
    );
  }
}

