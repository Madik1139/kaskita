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
import '../../models/debt_models.dart';
import '../../providers/debt_provider.dart';

/// Modal Bottom Sheet untuk menambah atau mengubah Kontak Teman.
class ContactFormSheet extends ConsumerStatefulWidget {
  const ContactFormSheet({
    this.editingContact,
    super.key,
  });

  final ContactSummaryModel? editingContact;

  static Future<void> show(
    BuildContext context, {
    ContactSummaryModel? editingContact,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ContactFormSheet(editingContact: editingContact),
    );
  }

  @override
  ConsumerState<ContactFormSheet> createState() => _ContactFormSheetState();
}

class _ContactFormSheetState extends ConsumerState<ContactFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneNoteController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.editingContact?.name ?? '',
    );
    _phoneNoteController = TextEditingController(
      text: widget.editingContact?.phoneNote ?? '',
    );
  }

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
    final ContactSummaryModel? editing = widget.editingContact;
    setState(() => _isSaving = true);
    try {
      if (editing == null) {
        await ref.read(debtsDirectoryProvider.notifier).createContact(
              name: _nameController.text,
              phoneNote: _phoneNoteController.text,
            );
      } else {
        await ref.read(debtsDirectoryProvider.notifier).updateContact(
              id: editing.id,
              name: _nameController.text,
              phoneNote: _phoneNoteController.text,
            );
      }
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              editing == null ? l10n.contactSavedMsg : l10n.contactUpdatedMsg,
            ),
          ),
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
    final bool isEditing = widget.editingContact != null;

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
                isEditing ? l10n.editContactTitle : l10n.addContactTitle,
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
            icon: Icon(
              isEditing ? LucideIcons.check : LucideIcons.userPlus,
              size: 16,
            ),
            label: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}

/// Helper bersama untuk dialog konfirmasi & eksekusi hapus kontak.
class ContactActionsHelper {
  const ContactActionsHelper._();

  static Future<void> confirmAndDelete({
    required BuildContext context,
    required WidgetRef ref,
    required ContactSummaryModel contact,
    VoidCallback? onBeforeDelete,
    VoidCallback? onAfterDelete,
    VoidCallback? onDeleteFailed,
  }) async {
    final AppLocalizations l10n = context.l10n;
    final bool hasActiveDebts =
        contact.openDebtsCount > 0 || contact.netBalance != 0;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(l10n.deleteContactConfirmTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(l10n.deleteContactConfirmSubtitle(contact.name)),
            if (hasActiveDebts) ...<Widget>[
              const SizedBox(height: 10),
              Text(
                l10n.deleteContactActiveDebtsWarning(contact.openDebtsCount),
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning(ctx),
                ),
              ),
            ],
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.negative(ctx),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    onBeforeDelete?.call();
    try {
      await ref.read(debtsDirectoryProvider.notifier).deleteContact(contact.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.contactDeletedMsg)),
        );
        onAfterDelete?.call();
      }
    } catch (error) {
      onDeleteFailed?.call();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppException.resolveError(error, l10n))),
        );
      }
    }
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

