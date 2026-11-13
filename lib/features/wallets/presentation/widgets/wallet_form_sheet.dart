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
import '../../models/wallet_model.dart';
import '../../providers/wallet_provider.dart';

/// Modal Bottom Sheet untuk Tambah / Ubah / Arsipkan Dompet.
class WalletFormSheet extends ConsumerStatefulWidget {
  const WalletFormSheet({
    this.editingWallet,
    super.key,
  });

  final WalletModel? editingWallet;

  static Future<void> show(
    BuildContext context, {
    WalletModel? editingWallet,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => WalletFormSheet(editingWallet: editingWallet),
    );
  }

  @override
  ConsumerState<WalletFormSheet> createState() => _WalletFormSheetState();
}

class _WalletFormSheetState extends ConsumerState<WalletFormSheet> {
  late final TextEditingController _nameController;
  late String _selectedType;
  late int _balance;
  bool _isSubmitting = false;

  static const List<MapEntry<String, String>> _quickPresets =
      <MapEntry<String, String>>[
    MapEntry<String, String>('BCA', 'BANK'),
    MapEntry<String, String>('Mandiri', 'BANK'),
    MapEntry<String, String>('BRI', 'BANK'),
    MapEntry<String, String>('GoPay', 'EWALLET'),
    MapEntry<String, String>('OVO', 'EWALLET'),
    MapEntry<String, String>('ShopeePay', 'EWALLET'),
  ];

  @override
  void initState() {
    super.initState();
    final WalletModel? wallet = widget.editingWallet;
    _nameController = TextEditingController(text: wallet?.name ?? '');
    _selectedType = wallet?.type ?? 'BANK';
    _balance = wallet?.currentBalance ?? 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveWallet() async {
    if (_isSubmitting) {
      return;
    }
    setState(() => _isSubmitting = true);
    final AppLocalizations l10n = context.l10n;
    try {
      final WalletModel? editing = widget.editingWallet;
      if (editing == null) {
        await ref.read(walletsProvider.notifier).createWallet(
              name: _nameController.text,
              type: _selectedType,
              initialBalance: _balance,
            );
      } else {
        await ref.read(walletsProvider.notifier).updateWallet(
              id: editing.id,
              name: _nameController.text,
              type: _selectedType,
              currentBalance: _balance,
            );
      }
      await ref.read(ledgerOverviewProvider.notifier).refreshOverview();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.walletSavedMsg)),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppException.resolveError(error, l10n))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _archiveWallet() async {
    final WalletModel? editing = widget.editingWallet;
    if (editing == null || _isSubmitting) {
      return;
    }
    setState(() => _isSubmitting = true);
    final AppLocalizations l10n = context.l10n;
    try {
      await ref.read(walletsProvider.notifier).archiveWallet(editing.id);
      await ref.read(ledgerOverviewProvider.notifier).refreshOverview();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppException.resolveError(error, l10n))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final bool isEditing = widget.editingWallet != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
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
              children: <Widget>[
                Expanded(
                  child: Text(
                    isEditing ? l10n.editWalletTitle : l10n.addWalletTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (isEditing)
                  IconButton(
                    tooltip: l10n.delete,
                    onPressed: _isSubmitting ? null : _archiveWallet,
                    icon: Icon(
                      LucideIcons.trash2,
                      size: 18,
                      color: AppColors.negative(context),
                    ),
                  ),
                IconButton(
                  tooltip: l10n.close,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(LucideIcons.x, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: l10n.walletNameLabel,
                hintText: l10n.walletNameHint,
                isDense: true,
                border: const OutlineInputBorder(),
              ),
            ),
            if (!isEditing) ...<Widget>[
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _quickPresets.map((MapEntry<String, String> item) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ActionChip(
                        label: Text(item.key),
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          setState(() {
                            _nameController.text = item.key;
                            _selectedType = item.value;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                _WalletTypeChip(
                  label: l10n.walletTypeCash,
                  icon: LucideIcons.wallet,
                  selected: _selectedType == 'CASH',
                  onTap: () => setState(() => _selectedType = 'CASH'),
                ),
                const SizedBox(width: 8),
                _WalletTypeChip(
                  label: l10n.walletTypeBank,
                  icon: LucideIcons.landmark,
                  selected: _selectedType == 'BANK',
                  onTap: () => setState(() => _selectedType = 'BANK'),
                ),
                const SizedBox(width: 8),
                _WalletTypeChip(
                  label: l10n.walletTypeEwallet,
                  icon: LucideIcons.smartphone,
                  selected: _selectedType == 'EWALLET',
                  onTap: () => setState(() => _selectedType = 'EWALLET'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TactileCard(
              backgroundColor: AppColors.surfaceSecondary(context),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    l10n.initialBalanceLabel,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 4),
                  TabularCurrencyText(
                    amount: _balance,
                    fontSize: 28,
                    semanticType: CurrencySemanticType.positive,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            CustomNumpad(
              amount: _balance,
              onAmountChanged: (int nextValue) =>
                  setState(() => _balance = nextValue),
              submitLabel: l10n.save,
              onSubmit: _saveWallet,
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletTypeChip extends StatelessWidget {
  const _WalletTypeChip({
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
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: 0.14)
                : AppColors.surfaceSecondary(context),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? accent : AppColors.border(context),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: 15,
                color: selected ? accent : AppColors.textSecondary(context),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: selected ? accent : AppColors.textPrimary(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
