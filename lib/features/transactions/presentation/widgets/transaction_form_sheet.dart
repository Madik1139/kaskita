import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../core/widgets/custom_numpad.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../debts/presentation/widgets/debt_smart_alert_banners.dart';
import '../../../debts/providers/debt_provider.dart';
import '../../../wallets/models/category_model.dart';
import '../../../wallets/models/wallet_model.dart';
import '../../../wallets/presentation/widgets/wallet_transfer_sheet.dart';
import '../../../wallets/providers/category_provider.dart';
import '../../../wallets/providers/wallet_provider.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import 'split_expense_section.dart';
import 'transaction_context_selectors.dart';
import 'transaction_form_header.dart';

/// Modal Bottom Sheet Input Satu Pintu (< 5 Detik) & Edit/Hapus Transaksi.
class TransactionFormSheet extends ConsumerStatefulWidget {
  const TransactionFormSheet({
    this.editingItem,
    super.key,
  });

  final TransactionItemModel? editingItem;

  static Future<void> show(
    BuildContext context, {
    TransactionItemModel? editingItem,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => TransactionFormSheet(editingItem: editingItem),
    );
  }

  @override
  ConsumerState<TransactionFormSheet> createState() =>
      _TransactionFormSheetState();
}

class _TransactionFormSheetState extends ConsumerState<TransactionFormSheet> {
  late final TextEditingController _noteController;
  late final TextEditingController _contactNameController;
  late String _trxType;
  int? _walletId;
  int? _categoryId;
  int? _contactId;
  late DateTime _trxDate;
  DateTime? _dueDate;
  late int _totalWalletAmount;
  late bool _isSplitTalangan;
  late int _friendShareAmount;
  bool _editingFriendShare = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final TransactionItemModel? item = widget.editingItem;
    _noteController = TextEditingController(text: item?.note ?? '');
    _contactNameController =
        TextEditingController(text: item?.contactName ?? '');
    _trxType = item?.trxType ?? 'EXPENSE';
    _walletId = item?.walletId;
    _categoryId = item?.categoryId;
    _contactId = item?.contactId;
    _trxDate = item != null
        ? (DateTime.tryParse(item.trxDate) ?? DateTime.now())
        : DateTime.now();
    _dueDate =
        item?.dueDate != null ? DateTime.tryParse(item!.dueDate!) : null;
    _totalWalletAmount = item?.totalWalletAmount ?? 0;
    _isSplitTalangan = item?.isSplitTalangan ?? false;
    _friendShareAmount = item != null && item.isSplitTalangan
        ? (item.totalWalletAmount - item.pureConsumptionAmount)
        : 0;
  }

  @override
  void dispose() {
    _noteController.dispose();
    _contactNameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isDueDate}) async {
    final DateTime initial = isDueDate
        ? (_dueDate ?? _trxDate.add(const Duration(days: 7)))
        : _trxDate;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isDueDate) {
          _dueDate = picked;
        } else {
          _trxDate = picked;
        }
      });
    }
  }

  Future<void> _submitForm(
    List<WalletModel> wallets,
    List<CategoryModel> categories,
  ) async {
    if (_isSubmitting) {
      return;
    }
    final AppLocalizations l10n = context.l10n;
    final int? effectiveWalletId =
        _walletId ?? (wallets.isNotEmpty ? wallets.first.id : null);
    if (effectiveWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errWalletRequired)),
      );
      return;
    }

    int? effectiveCatId = _categoryId;
    if (_trxType == 'EXPENSE' || _trxType == 'INCOME') {
      final List<CategoryModel> matching =
          categories.where((CategoryModel c) => c.type == _trxType).toList();
      if (effectiveCatId == null ||
          !matching.any((CategoryModel c) => c.id == effectiveCatId)) {
        effectiveCatId = matching.isNotEmpty ? matching.first.id : null;
      }
    }

    await _runSubmissionAction(
      l10n: l10n,
      successMessage: l10n.transactionSavedMsg,
      action: () async {
        final TransactionItemModel? editing = widget.editingItem;
        final bool isSplit = _trxType == 'EXPENSE' && _isSplitTalangan;
        if (editing == null) {
          await ref.read(transactionsProvider.notifier).recordTransaction(
                trxType: _trxType,
                walletId: effectiveWalletId,
                totalWalletAmount: _totalWalletAmount,
                trxDate: _trxDate,
                categoryId: effectiveCatId,
                note: _noteController.text,
                isSplitTalangan: isSplit,
                friendShareAmount: _friendShareAmount,
                contactId: _contactId,
                newContactName: _contactNameController.text,
                dueDate: _dueDate,
              );
        } else {
          await ref.read(transactionsProvider.notifier).updateTransaction(
                transactionId: editing.id,
                walletId: effectiveWalletId,
                totalWalletAmount: _totalWalletAmount,
                trxDate: _trxDate,
                categoryId: effectiveCatId,
                note: _noteController.text,
                isSplitTalangan: isSplit,
                friendShareAmount: _friendShareAmount,
                contactId: _contactId,
                newContactName: _contactNameController.text,
                dueDate: _dueDate,
              );
        }
        await ref.read(debtsDirectoryProvider.notifier).refresh();
      },
    );
  }

  Future<void> _deleteCurrentTransaction() async {
    final TransactionItemModel? editing = widget.editingItem;
    if (editing == null || _isSubmitting) {
      return;
    }
    final AppLocalizations l10n = context.l10n;
    await _runSubmissionAction(
      l10n: l10n,
      successMessage: l10n.transactionDeletedMsg,
      action: () async {
        await ref.read(transactionsProvider.notifier).deleteTransaction(
              editing.id,
            );
        await ref.read(debtsDirectoryProvider.notifier).refresh();
      },
    );
  }

  Future<void> _applyAutoNetting(AppLocalizations l10n) async {
    if (_contactId == null || _isSubmitting) {
      return;
    }
    await _runSubmissionAction(
      l10n: l10n,
      successMessage: l10n.settlementSuccessMsg,
      action: () => ref
          .read(debtsDirectoryProvider.notifier)
          .recordDebtWithAutoNetting(
            contactId: _contactId!,
            newDebtType: _trxType == 'DEBT_IN' ? 'PAYABLE' : 'RECEIVABLE',
            amount: _totalWalletAmount,
            date: _trxDate,
            note: _noteController.text,
            dueDate: _dueDate,
          ),
    );
  }

  Future<void> _runSubmissionAction({
    required AppLocalizations l10n,
    required String successMessage,
    required Future<void> Function() action,
  }) async {
    setState(() => _isSubmitting = true);
    try {
      await action();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
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
        ref.watch(walletsProvider).valueOrNull?.wallets ?? <WalletModel>[];
    final List<CategoryModel> allCategories =
        ref.watch(categoriesProvider).valueOrNull ?? <CategoryModel>[];
    final List<ContactOptionModel> contacts =
        ref.watch(transactionsProvider).valueOrNull?.contacts ??
            <ContactOptionModel>[];

    final int effectiveWalletId = _walletId ??
        ref.read(selectedWalletIdProvider) ??
        (wallets.isNotEmpty ? wallets.first.id : 1);
    final List<CategoryModel> modeCategories = allCategories
        .where((CategoryModel c) => c.type == _trxType)
        .toList();
    final int? effectiveCategoryId =
        modeCategories.any((CategoryModel c) => c.id == _categoryId)
            ? _categoryId
            : (modeCategories.isNotEmpty ? modeCategories.first.id : null);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        14 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TransactionFormHeader(
              isEditing: widget.editingItem != null,
              isSubmitting: _isSubmitting,
              trxType: _trxType,
              totalWalletAmount: _totalWalletAmount,
              trxDate: _trxDate,
              editingFriendShare: _editingFriendShare,
              onSelectMode: (String mode) {
                setState(() {
                  _trxType = mode;
                  _editingFriendShare = false;
                });
              },
              onOpenTransfer: () {
                Navigator.of(context).pop();
                WalletTransferSheet.show(
                  context,
                  wallets: wallets,
                  initialSourceWalletId: effectiveWalletId,
                );
              },
              onFocusTotalAmount: () =>
                  setState(() => _editingFriendShare = false),
              onPickTrxDate: () => _pickDate(isDueDate: false),
              onDelete: _deleteCurrentTransaction,
              onClose: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 8),
            TransactionContextSelectors(
              trxType: _trxType,
              wallets: wallets,
              selectedWalletId: effectiveWalletId,
              onSelectWallet: (int id) => setState(() => _walletId = id),
              modeCategories: modeCategories,
              selectedCategoryId: effectiveCategoryId,
              onSelectCategory: (int id) => setState(() => _categoryId = id),
              contacts: contacts,
              selectedContactId: _contactId,
              onSelectContact: (int? id) => setState(() => _contactId = id),
              contactNameController: _contactNameController,
              dueDate: _dueDate,
              onPickDueDate: () => _pickDate(isDueDate: true),
            ),
            DebtSmartAlertBanners(
              trxType: _trxType,
              isSplitTalangan: _isSplitTalangan,
              totalWalletAmount: _totalWalletAmount,
              friendShareAmount: _friendShareAmount,
              selectedContact: contacts
                  .where((ContactOptionModel c) => c.id == _contactId)
                  .firstOrNull,
              onApplyAutoNetting: () => _applyAutoNetting(l10n),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: l10n.transactionNoteHint,
                isDense: true,
                border: const OutlineInputBorder(),
              ),
            ),
            if (_trxType == 'EXPENSE') ...<Widget>[
              const SizedBox(height: 8),
              SplitExpenseSection(
                enabled: _isSplitTalangan,
                onToggle: (bool val) {
                  setState(() {
                    _isSplitTalangan = val;
                    if (val && _friendShareAmount == 0) {
                      _friendShareAmount = _totalWalletAmount ~/ 2;
                    } else if (!val) {
                      _editingFriendShare = false;
                    }
                  });
                },
                totalWalletAmount: _totalWalletAmount,
                friendShareAmount: _friendShareAmount,
                editingFriendShare: _editingFriendShare,
                onSelectFriendShareInput: (bool val) =>
                    setState(() => _editingFriendShare = val),
                onSplitEqual5050: () {
                  setState(() {
                    _friendShareAmount = _totalWalletAmount ~/ 2;
                  });
                },
                contacts: contacts,
                selectedContactId: _contactId,
                onSelectContactId: (int? id) =>
                    setState(() => _contactId = id),
                contactNameController: _contactNameController,
              ),
            ],
            const SizedBox(height: 10),
            CustomNumpad(
              amount: _editingFriendShare
                  ? _friendShareAmount
                  : _totalWalletAmount,
              onAmountChanged: (int nextValue) {
                setState(() {
                  if (_editingFriendShare) {
                    _friendShareAmount = nextValue;
                  } else {
                    _totalWalletAmount = nextValue;
                  }
                });
              },
              submitLabel: l10n.save,
              onSubmit: () => _submitForm(wallets, allCategories),
            ),
          ],
        ),
      ),
    );
  }
}
