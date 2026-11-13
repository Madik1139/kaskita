import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../debts/presentation/widgets/debt_smart_alert_banners.dart';
import '../../../wallets/models/category_model.dart';
import '../../../wallets/models/wallet_model.dart';
import '../../../wallets/presentation/widgets/wallet_transfer_sheet.dart';
import '../../../wallets/providers/category_provider.dart';
import '../../../wallets/providers/wallet_provider.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import 'split_expense_section.dart';
import 'transaction_bottom_panels.dart';
import 'transaction_context_selectors.dart';
import 'transaction_form_actions.dart';
import 'transaction_form_header.dart';

/// Halaman Penuh Input Transaksi Satu Pintu & Detail/Ubah Transaksi:
/// - Panel bawah kontekstual (Numpad <-> Grid Dompet <-> Grid Kategori)
/// - Field Tanggal, Nominal, Dompet, dan Kategori terpisah rapi tanpa geser horizontal
class TransactionFormSheet extends ConsumerStatefulWidget {
  const TransactionFormSheet({
    this.editingItem,
    super.key,
  });

  final TransactionItemModel? editingItem;

  static Future<void> show(
    BuildContext context, {
    TransactionItemModel? editingItem,
  }) =>
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => TransactionFormSheet(editingItem: editingItem),
        ),
      );

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
  TransactionInputPanel _activePanel = TransactionInputPanel.numpad;

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
    FocusScope.of(context).unfocus();
    final DateTime initial = isDueDate
        ? (_dueDate ?? _trxDate.add(const Duration(days: 7)))
        : _trxDate;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null || !mounted) return;
    setState(() => isDueDate ? _dueDate = picked : _trxDate = picked);
  }

  Future<void> _guardSubmit(Future<bool> Function() run) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await run();
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _openInputPanel(TransactionInputPanel panel) {
    FocusScope.of(context).unfocus();
    setState(() {
      _activePanel = panel;
      if (panel == TransactionInputPanel.numpad) {
        _editingFriendShare = false;
      }
    });
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
    final int effectiveWalletId =
        TransactionFormActions.resolveEffectiveWalletId(
              _walletId,
              ref,
              wallets,
            ) ??
            1;
    final List<CategoryModel> modeCategories = allCategories
        .where((CategoryModel c) => c.type == _trxType)
        .toList();
    final int? effectiveCategoryId =
        modeCategories.any((CategoryModel c) => c.id == _categoryId)
            ? _categoryId
            : (modeCategories.isNotEmpty ? modeCategories.first.id : null);
    final bool isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final bool isEditing = widget.editingItem != null;

    Future<void> onSave() => _guardSubmit(
          () => TransactionFormActions.submitTransaction(
            context: context,
            ref: ref,
            l10n: l10n,
            editingItem: widget.editingItem,
            trxType: _trxType,
            wallets: wallets,
            categories: allCategories,
            explicitWalletId: _walletId,
            explicitCategoryId: _categoryId,
            totalWalletAmount: _totalWalletAmount,
            trxDate: _trxDate,
            note: _noteController.text,
            isSplitTalangan: _isSplitTalangan,
            friendShareAmount: _friendShareAmount,
            contactId: _contactId,
            newContactName: _contactNameController.text,
            dueDate: _dueDate,
          ),
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? l10n.editTransactionTitle : l10n.recordTransactionBtn,
        ),
        actions: <Widget>[
          if (isEditing)
            IconButton(
              tooltip: l10n.delete,
              onPressed: _isSubmitting
                  ? null
                  : () => _guardSubmit(
                        () => TransactionFormActions.deleteTransaction(
                          context: context,
                          ref: ref,
                          l10n: l10n,
                          transactionId: widget.editingItem!.id,
                        ),
                      ),
              icon: Icon(
                LucideIcons.trash2,
                size: 19,
                color: AppColors.negative(context),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: TextButton.icon(
              onPressed: _isSubmitting ? null : onSave,
              icon: const Icon(LucideIcons.check, size: 17),
              label: Text(
                l10n.save,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TransactionFormHeader(
                      isEditing: isEditing,
                      trxType: _trxType,
                      totalWalletAmount: _totalWalletAmount,
                      trxDate: _trxDate,
                      isAmountFocused:
                          _activePanel == TransactionInputPanel.numpad &&
                              !_editingFriendShare,
                      onSelectMode: (String mode) {
                        setState(() {
                          _trxType = mode;
                          _editingFriendShare = false;
                          if ((mode == 'RECEIVABLE_OUT' ||
                                  mode == 'DEBT_IN') &&
                              _activePanel == TransactionInputPanel.category) {
                            _activePanel = TransactionInputPanel.numpad;
                          }
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
                          _openInputPanel(TransactionInputPanel.numpad),
                      onPickTrxDate: () => _pickDate(isDueDate: false),
                      onSelectQuickDate: (DateTime date) =>
                          setState(() => _trxDate = date),
                    ),
                    const SizedBox(height: 8),
                    TransactionContextSelectors(
                      trxType: _trxType,
                      activePanel: _activePanel,
                      wallets: wallets,
                      selectedWalletId: effectiveWalletId,
                      onTapWalletField: () =>
                          _openInputPanel(TransactionInputPanel.wallet),
                      modeCategories: modeCategories,
                      selectedCategoryId: effectiveCategoryId,
                      onTapCategoryField: () =>
                          _openInputPanel(TransactionInputPanel.category),
                      contacts: contacts,
                      selectedContactId: _contactId,
                      onSelectContact: (int? id) =>
                          setState(() => _contactId = id),
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
                      onApplyAutoNetting: ({required bool nonCashOnly}) =>
                          _guardSubmit(
                        () => TransactionFormActions.applyAutoNetting(
                          context: context,
                          ref: ref,
                          l10n: l10n,
                          wallets: wallets,
                          explicitWalletId: _walletId,
                          contactId: _contactId,
                          trxType: _trxType,
                          amount: _totalWalletAmount,
                          trxDate: _trxDate,
                          note: _noteController.text,
                          dueDate: _dueDate,
                          nonCashOnly: nonCashOnly,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _noteController,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: l10n.transactionNoteHint,
                        isDense: true,
                        prefixIcon: const Icon(LucideIcons.fileText, size: 17),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    if (_trxType == 'EXPENSE') ...<Widget>[
                      const SizedBox(height: 10),
                      SplitExpenseSection(
                        enabled: _isSplitTalangan,
                        onToggle: (bool val) => setState(() {
                          _isSplitTalangan = val;
                          if (val && _friendShareAmount == 0) {
                            _friendShareAmount = _totalWalletAmount ~/ 2;
                          } else if (!val) {
                            _editingFriendShare = false;
                          }
                        }),
                        totalWalletAmount: _totalWalletAmount,
                        friendShareAmount: _friendShareAmount,
                        editingFriendShare: _editingFriendShare,
                        onSelectFriendShareInput: (bool val) {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            _editingFriendShare = val;
                            _activePanel = TransactionInputPanel.numpad;
                          });
                        },
                        onSplitEqual5050: () => setState(
                          () => _friendShareAmount = _totalWalletAmount ~/ 2,
                        ),
                        contacts: contacts,
                        selectedContactId: _contactId,
                        onSelectContactId: (int? id) =>
                            setState(() => _contactId = id),
                        contactNameController: _contactNameController,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (!isKeyboardOpen)
              TransactionBottomPanel(
                activePanel: _activePanel,
                amount: _editingFriendShare
                    ? _friendShareAmount
                    : _totalWalletAmount,
                onAmountChanged: (int nextValue) => setState(() {
                  if (_editingFriendShare) {
                    _friendShareAmount = nextValue;
                  } else {
                    _totalWalletAmount = nextValue;
                  }
                }),
                onSubmit: onSave,
                wallets: wallets,
                selectedWalletId: effectiveWalletId,
                onSelectWallet: (int id) => setState(() {
                  _walletId = id;
                  _activePanel = TransactionInputPanel.numpad;
                }),
                categories: modeCategories,
                selectedCategoryId: effectiveCategoryId,
                onSelectCategory: (int id) => setState(() {
                  _categoryId = id;
                  _activePanel = TransactionInputPanel.numpad;
                }),
                onClosePickerToNumpad: () =>
                    setState(() => _activePanel = TransactionInputPanel.numpad),
              ),
          ],
        ),
      ),
    );
  }
}
