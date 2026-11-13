import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_helper.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../data/report_repository.dart';
import '../models/report_models.dart';

final Provider<ReportRepository> reportRepositoryProvider =
    Provider<ReportRepository>(
  (Ref ref) => ReportRepository(DatabaseHelper.instance),
);

final FutureProvider<ReportSummaryState> reportsProvider =
    FutureProvider<ReportSummaryState>((Ref ref) async {
  final DateTime period = ref.watch(selectedPeriodProvider);
  // Otomatis refresh setiap daftar transaksi atau dompet berubah
  ref.watch(transactionsProvider);

  final ReportRepository repo = ref.read(reportRepositoryProvider);
  final List<MonthlyComparisonPoint> trend =
      await repo.getSixMonthComparison(endPeriod: period);
  final List<CategoryBreakdownItem> categories = await repo.getCategoryBreakdown(
    year: period.year,
    month: period.month,
  );

  int totalPure = 0;
  for (final CategoryBreakdownItem item in categories) {
    totalPure += item.totalAmount;
  }

  return ReportSummaryState(
    activePeriod: period,
    sixMonthTrend: trend,
    categoryBreakdown: categories,
    totalPureExpenseInMonth: totalPure,
  );
});
