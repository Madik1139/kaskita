import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/utils/category_icon_mapper.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../wallets/models/category_model.dart';
import '../../../wallets/models/wallet_model.dart';
import '../../models/transaction_model.dart';

/// Baris pemilih kontekstual Dompet, Kategori, atau Kontak Teman + Jatuh Tempo.
class TransactionContextSelectors extends StatelessWidget {
  const TransactionContextSelectors({
    required this.trxType,
    required this.wallets,
    required this.selectedWalletId,
    required this.onSelectWallet,
    required this.modeCategories,
    required this.selectedCategoryId,
    required this.onSelectCategory,
    required this.contacts,
    required this.selectedContactId,
    required this.onSelectContact,
    required this.contactNameController,
    required this.dueDate,
    required this.onPickDueDate,
    super.key,
  });

  final String trxType;
  final List<WalletModel> wallets;
  final int selectedWalletId;
  final ValueChanged<int> onSelectWallet;
  final List<CategoryModel> modeCategories;
  final int? selectedCategoryId;
  final ValueChanged<int> onSelectCategory;
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: wallets.map((WalletModel w) {
              final bool selected = w.id == selectedWalletId;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(
                    LocalizationHelper.localizeWalletName(w.name, l10n),
                  ),
                  selected: selected,
                  visualDensity: VisualDensity.compact,
                  onSelected: (_) => onSelectWallet(w.id),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 6),
        if (!isDebtMode)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: modeCategories.map((CategoryModel cat) {
                final bool selected = cat.id == selectedCategoryId;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    avatar: Icon(
                      CategoryIconMapper.getIcon(cat.iconName),
                      size: 14,
                    ),
                    label: Text(
                      LocalizationHelper.localizeCategoryName(
                        cat.name,
                        l10n,
                      ),
                    ),
                    selected: selected,
                    visualDensity: VisualDensity.compact,
                    onSelected: (_) => onSelectCategory(cat.id),
                  ),
                );
              }).toList(),
            ),
          )
        else ...<Widget>[
          if (contacts.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: contacts.map((ContactOptionModel c) {
                  final bool selected = selectedContactId == c.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(c.name),
                      selected: selected,
                      visualDensity: VisualDensity.compact,
                      onSelected: (bool val) {
                        onSelectContact(val ? c.id : null);
                        if (val) {
                          contactNameController.text = c.name;
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 6),
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

