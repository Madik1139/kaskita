import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/localization_helper.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/tactile_card.dart';
import '../../../l10n/app_localizations.dart';
import '../models/report_models.dart';
import '../providers/report_provider.dart';
import 'widgets/category_breakdown_card.dart';
import 'widgets/monthly_comparison_chart_card.dart';

/// Tampilan Tab 3 (Laporan):
/// Menampilkan Grafik Perbandingan 6 Bulan (`fl_chart`) & Rincian Pengeluaran per Kategori.
class ReportsTabView extends ConsumerWidget {
  const ReportsTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AsyncValue<ReportSummaryState> reportsAsync =
        ref.watch(reportsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(reportsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: <Widget>[
          Text(
            l10n.reportSectionTitle,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 8),
          reportsAsync.when(
            loading: () => const TactileCard(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (Object err, StackTrace _) => EmptyStateView(
              icon: LucideIcons.triangleAlert,
              title: l10n.errUnexpectedUiTitle,
              subtitle: AppException.resolveError(err, l10n),
            ),
            data: (ReportSummaryState report) => Column(
              children: <Widget>[
                MonthlyComparisonChartCard(points: report.sixMonthTrend),
                const SizedBox(height: 12),
                CategoryBreakdownCard(
                  activePeriod: report.activePeriod,
                  items: report.categoryBreakdown,
                  totalPureExpense: report.totalPureExpenseInMonth,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
