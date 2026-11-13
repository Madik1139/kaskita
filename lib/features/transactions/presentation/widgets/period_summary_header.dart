import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../core/widgets/tabular_currency_text.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/transaction_provider.dart';

/// Header Navigasi Periode, Sub-Tab (Harian | Kalender | Bulanan),
/// dan Bar Ringkasan 3 Kolom (Pemasukan, Konsumsi Murni, Selisih Bersih)
/// bergaya Money Manager (Realbyte).
class PeriodSummaryHeader extends ConsumerWidget {
  const PeriodSummaryHeader({
    required this.totalIncome,
    required this.totalPureExpense,
    super.key,
  });

  final int totalIncome;
  final int totalPureExpense;

  void _shiftPeriod(WidgetRef ref, int delta, LedgerViewSubTab subTab) {
    final DateTime current = ref.read(selectedPeriodProvider);
    final DateTime next = subTab == LedgerViewSubTab.monthly
        ? DateTime(current.year + delta, current.month, 1)
        : DateTime(current.year, current.month + delta, 1);
    ref.read(selectedPeriodProvider.notifier).state = next;
    ref.read(selectedCalendarDayProvider.notifier).state = next;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final String langCode = context.currentLanguageCode;
    final DateTime activePeriod = ref.watch(selectedPeriodProvider);
    final LedgerViewSubTab activeSubTab =
        ref.watch(selectedLedgerSubTabProvider);
    final int netDiff = totalIncome - totalPureExpense;

    final String periodLabel = activeSubTab == LedgerViewSubTab.monthly
        ? activePeriod.year.toString()
        : DateFormatter.fullMonthYear(activePeriod, localeCode: langCode);

    return TactileCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _shiftPeriod(ref, -1, activeSubTab),
                        icon: const Icon(LucideIcons.chevronLeft, size: 18),
                      ),
                      Text(
                        periodLabel,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _shiftPeriod(ref, 1, activeSubTab),
                        icon: const Icon(LucideIcons.chevronRight, size: 18),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _SubTabButton(
                        label: l10n.subTabDaily,
                        selected: activeSubTab == LedgerViewSubTab.daily,
                        onTap: () => ref
                            .read(selectedLedgerSubTabProvider.notifier)
                            .state = LedgerViewSubTab.daily,
                      ),
                      const SizedBox(width: 4),
                      _SubTabButton(
                        label: l10n.subTabCalendar,
                        selected: activeSubTab == LedgerViewSubTab.calendar,
                        onTap: () => ref
                            .read(selectedLedgerSubTabProvider.notifier)
                            .state = LedgerViewSubTab.calendar,
                      ),
                      const SizedBox(width: 4),
                      _SubTabButton(
                        label: l10n.subTabMonthly,
                        selected: activeSubTab == LedgerViewSubTab.monthly,
                        onTap: () => ref
                            .read(selectedLedgerSubTabProvider.notifier)
                            .state = LedgerViewSubTab.monthly,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          IntrinsicHeight(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _SummaryColumn(
                    label: l10n.summaryIncomeLabel,
                    amount: totalIncome,
                    semanticType: CurrencySemanticType.positive,
                  ),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(
                  child: _SummaryColumn(
                    label: l10n.summaryPureExpenseLabel,
                    amount: totalPureExpense,
                    semanticType: CurrencySemanticType.negative,
                  ),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(
                  child: _SummaryColumn(
                    label: l10n.summaryNetDifferenceLabel,
                    amount: netDiff,
                    semanticType: netDiff >= 0
                        ? CurrencySemanticType.positive
                        : CurrencySemanticType.negative,
                    showPlusSign: netDiff > 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubTabButton extends StatelessWidget {
  const _SubTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = AppColors.accent(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: 0.14)
              : AppColors.surfaceSecondary(context),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? accent : AppColors.border(context),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected ? accent : AppColors.textSecondary(context),
          ),
        ),
      ),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  const _SummaryColumn({
    required this.label,
    required this.amount,
    required this.semanticType,
    this.showPlusSign = false,
  });

  final String label;
  final int amount;
  final CurrencySemanticType semanticType;
  final bool showPlusSign;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Column(
        children: <Widget>[
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 3),
          TabularCurrencyText(
            amount: amount,
            fontSize: 13,
            semanticType: semanticType,
            showPlusSign: showPlusSign,
          ),
        ],
      ),
    );
  }
}

