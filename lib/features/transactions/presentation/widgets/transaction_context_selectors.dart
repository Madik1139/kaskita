import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/category_icon_mapper.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../wallets/models/category_model.dart';
import '../../../wallets/models/wallet_model.dart';
import '../../models/transaction_model.dart';
import 'transaction_bottom_panels.dart';

/// Field Pemilih Dompet, Kategori (buka Grid di panel bawah), serta Kontak & Jatuh Tempo.
class TransactionContextSelectors extends StatelessWidget {
  const TransactionContextSelectors({
    required this.trxType,
    required this.activePanel,
    required this.wallets,
    required this.selectedWalletId,
    required this.onTapWalletField,
    required this.modeCategories,
    required this.selectedCategoryId,
    required this.onTapCategoryField,
    required this.contacts,
    required this.selectedContactId,
    required this.onSelectContact,
    required this.contactNameController,
    required this.dueDate,
    required this.onPickDueDate,
    super.key,
  });

  final String trxType;
  final TransactionInputPanel activePanel;
  final List<WalletModel> wallets;
  final int selectedWalletId;
  final VoidCallback onTapWalletField;
  final List<CategoryModel> modeCategories;
  final int? selectedCategoryId;
  final VoidCallback onTapCategoryField;
  final List<ContactOptionModel> contacts;
  final int? selectedContactId;
  final ValueChanged<int?> onSelectContact;
  final TextEditingController contactNameController;
  final DateTime? dueDate;
  final VoidCallback onPickDueDate;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final String langCode = context.currentLanguageCode;
    final bool isDebtMode =
        trxType == 'RECEIVABLE_OUT' || trxType == 'DEBT_IN';

    final WalletModel? activeWallet = wallets
        .where((WalletModel w) => w.id == selectedWalletId)
        .firstOrNull;
    final CategoryModel? activeCategory = modeCategories
        .where((CategoryModel c) => c.id == selectedCategoryId)
        .firstOrNull;

    final String walletDisplay = activeWallet != null
        ? LocalizationHelper.localizeWalletName(activeWallet.name, l10n)
        : l10n.selectWalletLabel;
    final IconData walletIcon = switch (activeWallet?.type) {
      'BANK' => LucideIcons.landmark,
      'EWALLET' => LucideIcons.smartphone,
      _ => LucideIcons.wallet,
    };

    final String categoryDisplay = activeCategory != null
        ? LocalizationHelper.localizeCategoryName(activeCategory.name, l10n)
        : l10n.selectCategoryLabel;
    final IconData categoryIcon = activeCategory != null
        ? CategoryIconMapper.getIcon(activeCategory.iconName)
        : LucideIcons.tags;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _SelectorBoxField(
                label: l10n.selectWalletLabel,
                value: walletDisplay,
                icon: walletIcon,
                active: activePanel == TransactionInputPanel.wallet,
                onTap: onTapWalletField,
              ),
            ),
            if (!isDebtMode) ...<Widget>[
              const SizedBox(width: 8),
              Expanded(
                child: _SelectorBoxField(
                  label: l10n.selectCategoryLabel,
                  value: categoryDisplay,
                  icon: categoryIcon,
                  active: activePanel == TransactionInputPanel.category,
                  onTap: onTapCategoryField,
                ),
              ),
            ],
          ],
        ),
        if (isDebtMode) ...<Widget>[
          const SizedBox(height: 8),
          if (contacts.isNotEmpty) ...<Widget>[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: contacts.map((ContactOptionModel c) {
                final bool selected = selectedContactId == c.id;
                return ChoiceChip(
                  label: Text(c.name),
                  selected: selected,
                  visualDensity: VisualDensity.compact,
                  onSelected: (bool val) {
                    onSelectContact(val ? c.id : null);
                    if (val) {
                      contactNameController.text = c.name;
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: contactNameController,
                  onChanged: (_) => onSelectContact(null),
                  decoration: InputDecoration(
                    hintText: l10n.contactNameHint,
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ActionChip(
                avatar: const Icon(LucideIcons.calendarClock, size: 14),
                label: Text(
                  dueDate != null
                      ? DateFormatter.mediumDate(dueDate!, localeCode: langCode)
                      : l10n.dueDateLabel,
                ),
                onPressed: onPickDueDate,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SelectorBoxField extends StatelessWidget {
  const _SelectorBoxField({
    required this.label,
    required this.value,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = AppColors.accent(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: TactileCard(
        backgroundColor: active
            ? accent.withValues(alpha: 0.08)
            : AppColors.surface(context),
        borderColor: active ? accent : AppColors.border(context),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              size: 17,
              color: active ? accent : AppColors.textSecondary(context),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: active ? accent : null,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: active ? accent : AppColors.textPrimary(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronDown,
              size: 15,
              color: active ? accent : AppColors.textSecondary(context),
            ),
          ],
        ),
      ),
    );
  }
}
