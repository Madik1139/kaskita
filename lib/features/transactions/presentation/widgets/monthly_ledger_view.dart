import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../core/widgets/tabular_currency_text.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';

/// Sub-Tab Bulanan bergaya Money Manager (Realbyte):
/// Menampilkan rekapitulasi 12 bulan dalam tahun terpilih beserta rincian mingguan (expandable).
class MonthlyLedgerView extends ConsumerStatefulWidget {
  const MonthlyLedgerView({
    required this.summaries,
    super.key,
  });

  final List<MonthlySummaryModel> summaries;

  @override
  ConsumerState<MonthlyLedgerView> createState() => _MonthlyLedgerViewState();
}

class _MonthlyLedgerViewState extends ConsumerState<MonthlyLedgerView> {
  int? _expandedMonth = DateTime.now().month;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final String langCode = context.currentLanguageCode;

    return TactileCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          for (int i = 0; i < widget.summaries.length; i++) ...<Widget>[
            if (i > 0) const Divider(),
            _MonthRowItem(
              summary: widget.summaries[i],
              langCode: langCode,
              l10n: l10n,
              expanded: _expandedMonth == widget.summaries[i].month,
              onToggleExpand: () {
                final int m = widget.summaries[i].month;
                setState(() {
                  _expandedMonth = _expandedMonth == m ? null : m;
                });
              },
              onOpenMonthDaily: () {
                final MonthlySummaryModel s = widget.summaries[i];
                ref.read(selectedPeriodProvider.notifier).state =
                    DateTime(s.year, s.month, 1);
                ref.read(selectedLedgerSubTabProvider.notifier).state =
                    LedgerViewSubTab.daily;
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _MonthRowItem extends StatelessWidget {
  const _MonthRowItem({
    required this.summary,
    required this.langCode,
    required this.l10n,
    required this.expanded,
    required this.onToggleExpand,
    required this.onOpenMonthDaily,
  });

  final MonthlySummaryModel summary;
  final String langCode;
  final AppLocalizations l10n;
  final bool expanded;
  final VoidCallback onToggleExpand;
  final VoidCallback onOpenMonthDaily;

  @override
  Widget build(BuildContext context) {
    final DateTime monthDate = DateTime(summary.year, summary.month, 1);
    final String monthTitle =
        DateFormatter.fullMonthYear(monthDate, localeCode: langCode);
    final bool hasActivity =
        summary.totalIncome > 0 || summary.totalPureExpense > 0;

    return Column(
      children: <Widget>[
        InkWell(
          onTap: onToggleExpand,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Row(
                    children: <Widget>[
                      Icon(
                        expanded
                            ? LucideIcons.chevronDown
                            : LucideIcons.chevronRight,
                        size: 15,
                        color: AppColors.textSecondary(context),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          monthTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: hasActivity
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TabularCurrencyText(
                      amount: summary.totalIncome,
                      fontSize: 12,
                      semanticType: CurrencySemanticType.positive,
                      showPlusSign: summary.totalIncome > 0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TabularCurrencyText(
                      amount: -summary.totalPureExpense,
                      fontSize: 12,
                      semanticType: CurrencySemanticType.negative,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: l10n.subTabDaily,
                  onPressed: onOpenMonthDaily,
                  icon: Icon(
                    LucideIcons.arrowUpRight,
                    size: 15,
                    color: AppColors.accent(context),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (expanded && summary.weeks.isNotEmpty)
          Container(
            color: AppColors.surfaceSecondary(context),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: summary.weeks.map((WeeklyBreakdownModel w) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: Text(
                          l10n.weekRangeLabel(
                            w.weekNumber,
                            w.startDay.toString().padLeft(2, '0'),
                            w.endDay.toString().padLeft(2, '0'),
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TabularCurrencyText(
                            amount: w.totalIncome,
                            fontSize: 11,
                            semanticType: CurrencySemanticType.positive,
                            showPlusSign: w.totalIncome > 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TabularCurrencyText(
                            amount: -w.totalPureExpense,
                            fontSize: 11,
                            semanticType: CurrencySemanticType.negative,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

