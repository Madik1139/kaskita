import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../core/widgets/tabular_currency_text.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../models/transaction_model.dart';

/// Bagian "Sekalian Talangi Teman" (Inline Split Expense) pada form Pengeluaran.
class SplitExpenseSection extends StatelessWidget {
  const SplitExpenseSection({
    required this.enabled,
    required this.onToggle,
    required this.totalWalletAmount,
    required this.friendShareAmount,
    required this.editingFriendShare,
    required this.onSelectFriendShareInput,
    required this.onSplitEqual5050,
    required this.contacts,
    required this.selectedContactId,
    required this.onSelectContactId,
    required this.contactNameController,
    super.key,
  });

  final bool enabled;
  final ValueChanged<bool> onToggle;
  final int totalWalletAmount;
  final int friendShareAmount;
  final bool editingFriendShare;
  final ValueChanged<bool> onSelectFriendShareInput;
  final VoidCallback onSplitEqual5050;
  final List<ContactOptionModel> contacts;
  final int? selectedContactId;
  final ValueChanged<int?> onSelectContactId;
  final TextEditingController contactNameController;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final Color accent = AppColors.accent(context);
    final int pureExpense =
        (totalWalletAmount - friendShareAmount).clamp(0, totalWalletAmount);

    String resolvedContactLabel = contactNameController.text.trim();
    if (selectedContactId != null) {
      for (final ContactOptionModel c in contacts) {
        if (c.id == selectedContactId) {
          resolvedContactLabel = c.name;
          break;
        }
      }
    }
    if (resolvedContactLabel.isEmpty) {
      resolvedContactLabel = l10n.selectContactLabel;
    }

    return TactileCard(
      backgroundColor: enabled
          ? accent.withValues(alpha: 0.06)
          : AppColors.surfaceSecondary(context),
      borderColor: enabled ? accent : AppColors.border(context),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                LucideIcons.users,
                size: 17,
                color: enabled ? accent : AppColors.textSecondary(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.splitExpenseToggleTitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      l10n.splitExpenseToggleSubtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                onChanged: onToggle,
              ),
            ],
          ),
          if (enabled) ...<Widget>[
            const Divider(height: 14),
            if (contacts.isNotEmpty) ...<Widget>[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: contacts.map((ContactOptionModel c) {
                    final bool isSelected = selectedContactId == c.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(c.name),
                        selected: isSelected,
                        visualDensity: VisualDensity.compact,
                        onSelected: (bool val) {
                          if (val) {
                            onSelectContactId(c.id);
                            contactNameController.text = c.name;
                          } else {
                            onSelectContactId(null);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
            ],
            TextField(
              controller: contactNameController,
              onChanged: (_) => onSelectContactId(null),
              decoration: InputDecoration(
                hintText: l10n.contactNameHint,
                isDense: true,
                prefixIcon: const Icon(LucideIcons.userPlus, size: 16),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    onTap: () =>
                        onSelectFriendShareInput(!editingFriendShare),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface(context),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: editingFriendShare
                              ? accent
                              : AppColors.border(context),
                          width: editingFriendShare ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            l10n.splitFriendShareLabel,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(height: 2),
                          TabularCurrencyText(
                            amount: friendShareAmount,
                            fontSize: 16,
                            semanticType: CurrencySemanticType.positive,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onSplitEqual5050,
                  icon: const Icon(LucideIcons.divide, size: 15),
                  label: Text(l10n.splitEqual5050),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Text(
                l10n.splitSummaryText(
                  CurrencyFormatter.format(totalWalletAmount),
                  CurrencyFormatter.format(pureExpense),
                  resolvedContactLabel,
                  CurrencyFormatter.format(friendShareAmount),
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(context),
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
