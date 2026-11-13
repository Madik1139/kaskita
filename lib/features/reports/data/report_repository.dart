import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../models/report_models.dart';

/// Repository SQLite untuk analitik Grafik Bulanan & Rincian Pengeluaran per Kategori.
class ReportRepository {
  const ReportRepository(this._dbHelper);

  final DatabaseHelper _dbHelper;

  /// Mengambil tren 6 bulan terakhir (berakhir pada `endPeriod`) yang membandingkan:
  /// - Konsumsi Murni (`EXPENSE.pure_consumption_amount`)
  /// - Uang Tertahan / Dipinjamkan ke Teman (`RECEIVABLE_OUT` + porsi talangan `EXPENSE`)
  /// - Pemasukan (`INCOME.pure_consumption_amount`)
  Future<List<MonthlyComparisonPoint>> getSixMonthComparison({
    required DateTime endPeriod,
  }) async {
    final Database db = await _dbHelper.database;
    final List<DateTime> months = <DateTime>[];
    for (int offset = 5; offset >= 0; offset--) {
      months.add(DateTime(endPeriod.year, endPeriod.month - offset, 1));
    }

    final DateTime start = months.first;
    final DateTime end = DateTime(endPeriod.year, endPeriod.month + 1, 0);
    final String startIso =
        '${start.year.toString().padLeft(4, '0')}-${start.month.toString().padLeft(2, '0')}-01';
    final String endIso =
        '${end.year.toString().padLeft(4, '0')}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';

    final List<Map<String, Object?>> rows = await db.rawQuery(
      '''
      SELECT 
        trx_type,
        total_wallet_amount,
        pure_consumption_amount,
        trx_date
      FROM transactions
      WHERE trx_date >= ? AND trx_date <= ?
      ''',
      <Object>[startIso, endIso],
    );

    final List<MonthlyComparisonPoint> points = <MonthlyComparisonPoint>[];
    for (final DateTime m in months) {
      final String prefix =
          '${m.year.toString().padLeft(4, '0')}-${m.month.toString().padLeft(2, '0')}';
      int pureExp = 0;
      int recLent = 0;
      int income = 0;

      for (final Map<String, Object?> r in rows) {
        final String d = (r['trx_date'] as String?) ?? '';
        if (!d.startsWith(prefix)) {
          continue;
        }
        final String type = (r['trx_type'] as String?) ?? '';
        final int walletAmt = (r['total_wallet_amount'] as int?) ?? 0;
        final int pureAmt = (r['pure_consumption_amount'] as int?) ?? 0;

        if (type == 'EXPENSE') {
          pureExp += pureAmt;
          if (walletAmt > pureAmt) {
            recLent += walletAmt - pureAmt;
          }
        } else if (type == 'RECEIVABLE_OUT') {
          recLent += walletAmt;
        } else if (type == 'INCOME') {
          income += pureAmt;
        }
      }

      points.add(
        MonthlyComparisonPoint(
          year: m.year,
          month: m.month,
          pureExpense: pureExp,
          receivableLent: recLent,
          totalIncome: income,
        ),
      );
    }

    return points;
  }

  /// Mengambil rincian persentase & nominal pengeluaran konsumsi murni per kategori.
  Future<List<CategoryBreakdownItem>> getCategoryBreakdown({
    required int year,
    required int month,
  }) async {
    final Database db = await _dbHelper.database;
    final String prefix =
        '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';

    final List<Map<String, Object?>> rows = await db.rawQuery(
      '''
      SELECT 
        COALESCE(c.name, 'Lainnya') AS category_name,
        COALESCE(c.icon_name, 'more_horizontal') AS icon_name,
        COALESCE(c.color_hex, '#686B73') AS color_hex,
        SUM(t.pure_consumption_amount) AS total_amount
      FROM transactions t
      LEFT JOIN categories c ON t.category_id = c.id
      WHERE t.trx_type = 'EXPENSE'
        AND t.pure_consumption_amount > 0
        AND t.trx_date >= ? AND t.trx_date <= ?
      GROUP BY c.id, category_name, icon_name, color_hex
      ORDER BY total_amount DESC
      ''',
      <Object>['$prefix-01', '$prefix-31'],
    );

    int grandTotal = 0;
    for (final Map<String, Object?> r in rows) {
      grandTotal += (r['total_amount'] as int?) ?? 0;
    }
    if (grandTotal <= 0) {
      return <CategoryBreakdownItem>[];
    }

    return rows.map((Map<String, Object?> r) {
      final int amt = (r['total_amount'] as int?) ?? 0;
      return CategoryBreakdownItem(
        categoryName: (r['category_name'] as String?) ?? 'Lainnya',
        iconName: (r['icon_name'] as String?) ?? 'more_horizontal',
        colorHex: (r['color_hex'] as String?) ?? '#686B73',
        totalAmount: amt,
        percentage: (amt / grandTotal) * 100.0,
      );
    }).toList();
  }
}

