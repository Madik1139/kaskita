import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/providers/ledger_overview_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../core/widgets/custom_numpad.dart';
import '../../../../core/widgets/tabular_currency_text.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../models/wallet_model.dart';
import '../../providers/wallet_provider.dart';
import 'wallet_form_sheet.dart';

/// Modal Bottom Sheet untuk Transfer Antar Dompet (`trx_type = 'TRANSFER'`).
class WalletTransferSheet extends ConsumerStatefulWidget {
  const WalletTransferSheet({
    required this.wallets,
    this.initialSourceWalletId,
    super.key,
  });

  final List<WalletModel> wallets;
  final int? initialSourceWalletId;

  static Future<void> show(
    BuildContext context, {
    required List<WalletModel> wallets,
    int? initialSourceWalletId,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => WalletTransferSheet(
        wallets: wallets,
        initialSourceWalletId: initialSourceWalletId,
      ),
    );
  }

  @override
  ConsumerState<WalletTransferSheet> createState() =>
      _WalletTransferSheetState();
}

class _WalletTransferSheetState extends ConsumerState<WalletTransferSheet> {
  final TextEditingController _noteController = TextEditingController();
  late int? _sourceWalletId;
  late int? _targetWalletId;
  int _amount = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final List<WalletModel> list = widget.wallets;
    if (list.isNotEmpty) {
      _sourceWalletId = widget.initialSourceWalletId ?? list.first.id;
      final WalletModel? second = list
          .where((WalletModel w) => w.id != _sourceWalletId)
          .firstOrNull;
      _targetWalletId = second?.id ?? list.first.id;
    } else {
      _sourceWalletId = null;
      _targetWalletId = null;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _swapWallets() {
    setState(() {
      final int? temp = _sourceWalletId;
      _sourceWalletId = _targetWalletId;
      _targetWalletId = temp;
    });
  }

  Future<void> _submitTransfer() async {
    if (_isSubmitting) {
      return;
    }
    final AppLocalizations l10n = context.l10n;
    if (_sourceWalletId == null || _targetWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errWalletRequired)),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await ref.read(walletsProvider.notifier).transferBetweenWallets(
            sourceWalletId: _sourceWalletId!,
            targetWalletId: _targetWalletId!,
            amount: _amount,
            date: DateTime.now(),
            note: _noteController.text,
          );
      await ref.read(ledgerOverviewProvider.notifier).refreshOverview();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.transferSuccessMsg)),
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

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final List<WalletModel> wallets =
        ref.watch(walletsProvider).valueOrNull?.wallets ?? widget.wallets;

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
                Icon(
                  LucideIcons.arrowLeftRight,
                  size: 19,
                  color: AppColors.mutation(context),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.transferTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => WalletFormSheet.show(context),
                  icon: const Icon(LucideIcons.plus, size: 15),
                  label: Text(l10n.addWallet),
                ),
              ],
            ),
            Text(
              l10n.transferSubtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: _WalletDropdownField(
                    label: l10n.sourceWalletLabel,
                    wallets: wallets,
                    selectedId: _sourceWalletId,
                    onChanged: (int? val) =>
                        setState(() => _sourceWalletId = val),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: IconButton(
                    onPressed: _swapWallets,
                    icon: const Icon(LucideIcons.arrowLeftRight, size: 18),
                  ),
                ),
                Expanded(
                  child: _WalletDropdownField(
                    label: l10n.targetWalletLabel,
                    wallets: wallets,
                    selectedId: _targetWalletId,
                    onChanged: (int? val) =>
                        setState(() => _targetWalletId = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _noteController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: l10n.transferNoteHint,
                isDense: true,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TactileCard(
              backgroundColor: AppColors.surfaceSecondary(context),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    l10n.transferAmountLabel,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 4),
                  TabularCurrencyText(
                    amount: _amount,
                    fontSize: 28,
                    semanticType: CurrencySemanticType.mutation,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            CustomNumpad(
              amount: _amount,
              onAmountChanged: (int nextValue) =>
                  setState(() => _amount = nextValue),
              submitLabel: l10n.transferAction,
              onSubmit: _submitTransfer,
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletDropdownField extends StatelessWidget {
  const _WalletDropdownField({
    required this.label,
    required this.wallets,
    required this.selectedId,
    required this.onChanged,
  });

  final String label;
  final List<WalletModel> wallets;
  final int? selectedId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final int? effectiveValue =
        wallets.any((WalletModel w) => w.id == selectedId)
            ? selectedId
            : (wallets.isNotEmpty ? wallets.first.id : null);

    return DropdownButtonFormField<int>(
      initialValue: effectiveValue,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: const OutlineInputBorder(),
      ),
      items: wallets.map((WalletModel wallet) {
        final String displayName = LocalizationHelper.localizeWalletName(
          wallet.name,
          l10n,
        );
        return DropdownMenuItem<int>(
          value: wallet.id,
          child: Text(
            '$displayName (${CurrencyFormatter.format(wallet.currentBalance)})',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
