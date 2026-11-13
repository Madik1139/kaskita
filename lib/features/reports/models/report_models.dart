import 'package:equatable/equatable.dart';

/// Titik data perbandingan bulanan untuk grafik batang (`fl_chart`):
/// Membandingkan Konsumsi Murni (`pureExpense`) vs Uang Tertahan di Teman (`receivableLent`).
class MonthlyComparisonPoint extends Equatable {
  const MonthlyComparisonPoint({
    required this.year,
    required this.month,
    required this.pureExpense,
    required this.receivableLent,
    required this.totalIncome,
  });

  final int year;
  final int month;
  final int pureExpense;
  final int receivableLent;
  final int totalIncome;

  @override
  List<Object?> get props => <Object?>[
        year,
        month,
        pureExpense,
        receivableLent,
        totalIncome,
      ];
}

/// Rincian pengeluaran konsumsi murni per kategori pada bulan terpilih.
class CategoryBreakdownItem extends Equatable {
  const CategoryBreakdownItem({
    required this.categoryName,
    required this.iconName,
    required this.colorHex,
    required this.totalAmount,
    required this.percentage,
  });

  final String categoryName;
  final String iconName;
  final String colorHex;
  final int totalAmount;
  final double percentage;

  @override
  List<Object?> get props => <Object?>[
        categoryName,
        iconName,
        colorHex,
        totalAmount,
        percentage,
      ];
}

class ReportSummaryState extends Equatable {
  const ReportSummaryState({
    required this.activePeriod,
    required this.sixMonthTrend,
    required this.categoryBreakdown,
    required this.totalPureExpenseInMonth,
  });

  final DateTime activePeriod;
  final List<MonthlyComparisonPoint> sixMonthTrend;
  final List<CategoryBreakdownItem> categoryBreakdown;
  final int totalPureExpenseInMonth;

  @override
  List<Object?> get props => <Object?>[
        activePeriod,
        sixMonthTrend,
        categoryBreakdown,
        totalPureExpenseInMonth,
      ];
}
