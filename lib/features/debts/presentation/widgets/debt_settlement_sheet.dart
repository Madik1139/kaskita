import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../core/widgets/custom_numpad.dart';
import '../../../../core/widgets/tabular_currency_text.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../wallets/models/category_model.dart';
import '../../../wallets/models/wallet_model.dart';
import '../../../wallets/providers/category_provider.dart';
import '../../../wallets/providers/wallet_provider.dart';
import '../../models/debt_models.dart';
import '../../providers/debt_provider.dart';

/// Modal Bottom Sheet untuk Pelunasan / Cicilan (Otomatis FIFO, Pilih Tagihan Spesifik,
/// Tunai Dompet, maupun Lunas via Barang/Traktiran).
class DebtSettlementSheet extends ConsumerStatefulWidget {
  const DebtSettlementSheet({
    required this.contact,
    required this.activeDebts,
    this.initialSpecificDebt,
    super.key,
  });

  final ContactSummaryModel contact;
  final List<DebtItemModel> activeDebts;
  final DebtItemModel? initialSpecificDebt;

  static Future<void> show(
    BuildContext context, {
    required ContactSummaryModel contact,
    required List<DebtItemModel> activeDebts,
    DebtItemModel? initialSpecificDebt,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DebtSettlementSheet(
        contact: contact,
        activeDebts: activeDebts,
        initialSpecificDebt: initialSpecificDebt,
      ),
    );
  }

  @override
  ConsumerState<DebtSettlementSheet> createState() =>
      _DebtSettlementSheetState();
}

class _DebtSettlementSheetState extends ConsumerState<DebtSettlementSheet> {
  final TextEditingController _noteController = TextEditingController();
  late String _debtType;
  String _settlementMethod = 'CASH'; // 'CASH' | 'ITEM_TREAT'
  int? _specificDebtId;
  int? _walletId;
  bool _recordTreatAsExpense = true;
  int? _treatCategoryId;
  late int _amount;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final DebtItemModel? specific = widget.initialSpecificDebt;
    if (specific != null) {
      _debtType = specific.debtType;
      _specificDebtId = specific.id;
      _amount = specific.remainingAmount;
    } else {
      final bool hasReceivables = widget.activeDebts
          .any((DebtItemModel d) => d.debtType == 'RECEIVABLE');
      _debtType = (widget.contact.netBalance >= 0 && hasReceivables)
          ? 'RECEIVABLE'
          : 'PAYABLE';
      _specificDebtId = null;
      _amount = _maxRemainingForCurrentScope();
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  List<DebtItemModel> get _debtsOfActiveType => widget.activeDebts
      .where((DebtItemModel d) => d.debtType == _debtType)
      .toList();

  int _maxRemainingForCurrentScope() {
    if (_specificDebtId != null) {
      for (final DebtItemModel d in widget.activeDebts) {
        if (d.id == _specificDebtId) {
          return d.remainingAmount;
        }
      }
    }
    int sum = 0;
    for (final DebtItemModel d in _debtsOfActiveType) {
      sum += d.remainingAmount;
    }
    return sum;
  }

  Future<void> _submitSettlement(
    List<WalletModel> wallets,
    List<CategoryModel> expenseCategories,
  ) async {
    if (_isSubmitting) {
      return;
    }
    final AppLocalizations l10n = context.l10n;
    final int? effectiveWalletId =
        _walletId ?? (wallets.isNotEmpty ? wallets.first.id : null);
    final int effectiveCatId = _treatCategoryId ??
        (expenseCategories.isNotEmpty ? expenseCategories.first.id : 1);

    setState(() => _isSubmitting = true);
    try {
      await ref.read(debtsDirectoryProvider.notifier).settleDebts(
            contactId: widget.contact.id,
            debtType: _debtType,
            amount: _amount,
            settlementMethod: _settlementMethod,
            paymentDate: DateTime.now(),
            walletId: _settlementMethod == 'CASH' ? effectiveWalletId : null,
            specificDebtId: _specificDebtId,
            recordTreatAsPersonalExpense:
                _settlementMethod == 'ITEM_TREAT' && _recordTreatAsExpense,
            treatExpenseCategoryId: effectiveCatId,
            note: _noteController.text,
          );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settlementSuccessMsg)),
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
    final List<CategoryModel> expenseCategories = allCategories
        .where((CategoryModel c) => c.type == 'EXPENSE')
        .toList();

    final int effectiveWalletId =
        _walletId ?? (wallets.isNotEmpty ? wallets.first.id : 1);
    final int effectiveCatId = _treatCategoryId ??
        (expenseCategories.isNotEmpty ? expenseCategories.first.id : 1);
    final int maxRemaining = _maxRemainingForCurrentScope();
    final List<DebtItemModel> matchingDebts = _debtsOfActiveType;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    _debtType == 'RECEIVABLE'
                        ? l10n.settlementSheetTitleReceivable
                        : l10n.settlementSheetTitlePayable,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(LucideIcons.x, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Pilihan Metode: Tunai vs Barang/Traktiran
            Row(
              children: <Widget>[
                Expanded(
                  child: ChoiceChip(
                    avatar: const Icon(LucideIcons.wallet, size: 14),
                    label: Text(l10n.settlementMethodCash),
                    selected: _settlementMethod == 'CASH',
                    onSelected: (_) =>
                        setState(() => _settlementMethod = 'CASH'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    avatar: const Icon(LucideIcons.utensils, size: 14),
                    label: Text(l10n.settlementMethodItemTreat),
                    selected: _settlementMethod == 'ITEM_TREAT',
                    onSelected: (_) =>
                        setState(() => _settlementMethod = 'ITEM_TREAT'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Pilihan Alokasi: Otomatis FIFO vs Pilih Tagihan Spesifik
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  ChoiceChip(
                    label: Text(l10n.allocationModeFifo),
                    selected: _specificDebtId == null,
                    visualDensity: VisualDensity.compact,
                    onSelected: (_) {
                      setState(() {
                        _specificDebtId = null;
                        _amount = _maxRemainingForCurrentScope();
                      });
                    },
                  ),
                  const SizedBox(width: 6),
                  for (final DebtItemModel d in matchingDebts) ...<Widget>[
                    ChoiceChip(
                      label: Text(
                        '${d.note} (${CurrencyFormatter.format(d.remainingAmount)})',
                      ),
                      selected: _specificDebtId == d.id,
                      visualDensity: VisualDensity.compact,
                      onSelected: (_) {
                        setState(() {
                          _specificDebtId = d.id;
                          _amount = d.remainingAmount;
                        });
                      },
                    ),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (_settlementMethod == 'CASH')
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: wallets.map((WalletModel w) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(
                          LocalizationHelper.localizeWalletName(w.name, l10n),
                        ),
                        selected: w.id == effectiveWalletId,
                        visualDensity: VisualDensity.compact,
                        onSelected: (_) => setState(() => _walletId = w.id),
                      ),
                    );
                  }).toList(),
                ),
              )
            else
              TactileCard(
                backgroundColor: AppColors.surfaceSecondary(context),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                l10n.recordTreatAsExpenseToggle,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                l10n.recordTreatAsExpenseSubtitle,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _recordTreatAsExpense,
                          onChanged: (bool val) =>
                              setState(() => _recordTreatAsExpense = val),
                        ),
                      ],
                    ),
                    if (_recordTreatAsExpense) ...<Widget>[
                      const SizedBox(height: 4),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: expenseCategories.map((CategoryModel cat) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text(
                                  LocalizationHelper.localizeCategoryName(
                                    cat.name,
                                    l10n,
                                  ),
                                ),
                                selected: cat.id == effectiveCatId,
                                visualDensity: VisualDensity.compact,
                                onSelected: (_) =>
                                    setState(() => _treatCategoryId = cat.id),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 8),
            TactileCard(
              backgroundColor: AppColors.surfaceSecondary(context),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ActionChip(
                    label: Text(
                      l10n.payFullRemainingChip(
                        CurrencyFormatter.format(maxRemaining),
                      ),
                    ),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setState(() => _amount = maxRemaining),
                  ),
                  TabularCurrencyText(
                    amount: _amount,
                    fontSize: 26,
                    semanticType: CurrencySemanticType.mutation,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            CustomNumpad(
              amount: _amount,
              onAmountChanged: (int val) => setState(() => _amount = val),
              submitLabel: l10n.settleOrPayBtn,
              onSubmit: () => _submitSettlement(wallets, expenseCategories),
            ),
          ],
        ),
      ),
    );
  }
}
