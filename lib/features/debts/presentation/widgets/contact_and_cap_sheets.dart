import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../core/widgets/custom_numpad.dart';
import '../../../../core/widgets/tabular_currency_text.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/debt_provider.dart';

/// Modal Bottom Sheet untuk menambah Kontak Teman baru.
class ContactFormSheet extends ConsumerStatefulWidget {
  const ContactFormSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const ContactFormSheet(),
    );
  }

  @override
  ConsumerState<ContactFormSheet> createState() => _ContactFormSheetState();
}

class _ContactFormSheetState extends ConsumerState<ContactFormSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNoteController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNoteController.dispose();
    super.dispose();
  }

  Future<void> _saveContact() async {
    if (_isSaving) {
      return;
    }
    final AppLocalizations l10n = context.l10n;
    setState(() => _isSaving = true);
    try {
      await ref.read(debtsDirectoryProvider.notifier).createContact(
            name: _nameController.text,
            phoneNote: _phoneNoteController.text,
          );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.contactSavedMsg)),
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
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                l10n.addContactTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(LucideIcons.x, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            autofocus: true,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n.selectContactLabel,
              hintText: l10n.contactNameHint,
              isDense: true,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _phoneNoteController,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _saveContact(),
            decoration: InputDecoration(
              labelText: l10n.contactPhoneNoteLabel,
              hintText: l10n.contactPhoneNoteHint,
              isDense: true,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _isSaving ? null : _saveContact,
            icon: const Icon(LucideIcons.userPlus, size: 16),
            label: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}

/// Modal Bottom Sheet untuk mengatur Batas Rem Piutang (Lending Cap).
class LendingCapSheet extends ConsumerStatefulWidget {
  const LendingCapSheet({
    required this.initialLimit,
    super.key,
  });

  final int initialLimit;

  static Future<void> show(
    BuildContext context, {
    required int initialLimit,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => LendingCapSheet(initialLimit: initialLimit),
    );
  }

  @override
  ConsumerState<LendingCapSheet> createState() => _LendingCapSheetState();
}

class _LendingCapSheetState extends ConsumerState<LendingCapSheet> {
  late int _limitAmount;

  @override
  void initState() {
    super.initState();
    _limitAmount = widget.initialLimit;
  }

  Future<void> _saveLimit() async {
    final AppLocalizations l10n = context.l10n;
    try {
      await ref
          .read(debtsDirectoryProvider.notifier)
          .updateLendingCapLimit(_limitAmount);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppException.resolveError(error, l10n))),
        );
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text(
                  l10n.editLendingCapTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(LucideIcons.x, size: 18),
              ),
            ],
          ),
          Text(
            l10n.editLendingCapSubtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          TactileCard(
            backgroundColor: AppColors.surfaceSecondary(context),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  l10n.lendingCapBarTitle.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 4),
                TabularCurrencyText(
                  amount: _limitAmount,
                  fontSize: 28,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          CustomNumpad(
            amount: _limitAmount,
            onAmountChanged: (int val) => setState(() => _limitAmount = val),
            submitLabel: l10n.save,
            onSubmit: _saveLimit,
          ),
        ],
      ),
    );
  }
}
