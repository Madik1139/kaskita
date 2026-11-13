import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../models/transaction_model.dart';

/// Repository khusus query & pengelompokan transaksi periode Harian, Kalender,
/// dan Bulanan bergaya Money Manager (Realbyte).
class TransactionQueryRepository {
  const TransactionQueryRepository(this._dbHelper);

  final DatabaseHelper _dbHelper;

  static const String _joinedSelectSql = '''
    SELECT 
      t.id,
      t.wallet_id,
      t.target_wallet_id,
      t.category_id,
      t.trx_type,
      t.total_wallet_amount,
      t.pure_consumption_amount,
      t.note,
      t.trx_date,
      w.name AS wallet_name,
      tw.name AS target_wallet_name,
      c.name AS category_name,
      c.icon_name AS category_icon,
      d.id AS debt_id,
      d.contact_id AS contact_id,
      ct.name AS contact_name,
      d.principal_amount AS debt_principal,
      d.remaining_amount AS debt_remaining,
      d.due_date AS due_date,
      (SELECT COUNT(*) FROM debt_payments dp WHERE dp.debt_id = d.id) AS installment_count
    FROM transactions t
    LEFT JOIN wallets w ON t.wallet_id = w.id
    LEFT JOIN wallets tw ON t.target_wallet_id = tw.id
    LEFT JOIN categories c ON t.category_id = c.id
    LEFT JOIN debts d ON d.source_transaction_id = t.id
    LEFT JOIN contacts ct ON d.contact_id = ct.id
  ''';

  Future<List<TransactionItemModel>> getTransactionsByMonth({
    required int year,
    required int month,
    int? selectedWalletId,
  }) async {
    final Database db = await _dbHelper.database;
    final String monthPrefix =
        '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';

    final String walletClause = selectedWalletId != null
        ? 'AND (t.wallet_id = ? OR t.target_wallet_id = ?)'
        : '';
    final List<Object> args = <Object>[
      '$monthPrefix-01',
      '$monthPrefix-31',
      if (selectedWalletId != null) ...<Object>[
        selectedWalletId,
        selectedWalletId,
      ],
    ];

    final List<Map<String, Object?>> rows = await db.rawQuery(
      '''
      $_joinedSelectSql
      WHERE t.trx_date >= ? AND t.trx_date <= ? $walletClause
      ORDER BY t.trx_date DESC, t.id DESC
      ''',
      args,
    );

    return rows.map(TransactionItemModel.fromJoinedMap).toList();
  }

  static List<DailyTransactionGroupModel> groupTransactionsByDay(
    List<TransactionItemModel> transactions,
  ) {
    final Map<String, List<TransactionItemModel>> grouped =
        <String, List<TransactionItemModel>>{};
    for (final TransactionItemModel item in transactions) {
      grouped.putIfAbsent(item.trxDate, () => <TransactionItemModel>[]).add(
            item,
          );
    }

    final List<String> sortedDates = grouped.keys.toList()
      ..sort((String a, String b) => b.compareTo(a));

    return sortedDates.map((String isoDate) {
      final List<TransactionItemModel> dayItems = grouped[isoDate]!;
      int income = 0;
      int pureExpense = 0;
      for (final TransactionItemModel item in dayItems) {
        if (item.trxType == 'INCOME') {
          income += item.pureConsumptionAmount;
        } else if (item.trxType == 'EXPENSE') {
          pureExpense += item.pureConsumptionAmount;
        }
      }
      final DateTime parsedDate =
          DateTime.tryParse(isoDate) ?? DateTime.now();
      return DailyTransactionGroupModel(
        date: parsedDate,
        isoDate: isoDate,
        totalIncome: income,
        totalPureExpense: pureExpense,
        items: dayItems,
      );
    }).toList();
  }

  Future<List<MonthlySummaryModel>> getYearlyMonthlySummaries({
    required int year,
    int? selectedWalletId,
  }) async {
    final Database db = await _dbHelper.database;
    final String yearPrefix = year.toString().padLeft(4, '0');
    final String walletClause = selectedWalletId != null
        ? 'AND (t.wallet_id = ? OR t.target_wallet_id = ?)'
        : '';
    final List<Object> args = <Object>[
      '$yearPrefix-01-01',
      '$yearPrefix-12-31',
      if (selectedWalletId != null) ...<Object>[
        selectedWalletId,
        selectedWalletId,
      ],
    ];

    final List<Map<String, Object?>> rows = await db.rawQuery(
      '''
      SELECT trx_type, pure_consumption_amount, trx_date
      FROM transactions t
      WHERE t.trx_date >= ? AND t.trx_date <= ? $walletClause
      ORDER BY t.trx_date ASC
      ''',
      args,
    );

    final List<MonthlySummaryModel> summaries = <MonthlySummaryModel>[];
    for (int month = 12; month >= 1; month--) {
      final String mPrefix =
          '$yearPrefix-${month.toString().padLeft(2, '0')}';
      final List<Map<String, Object?>> monthRows = rows
          .where(
            (Map<String, Object?> r) =>
                ((r['trx_date'] as String?) ?? '').startsWith(mPrefix),
          )
          .toList();

      int mIncome = 0;
      int mExpense = 0;
      final Map<int, List<int>> weekTotals = <int, List<int>>{
        1: <int>[0, 0],
        2: <int>[0, 0],
        3: <int>[0, 0],
        4: <int>[0, 0],
        5: <int>[0, 0],
      };

      for (final Map<String, Object?> r in monthRows) {
        final String trxType = (r['trx_type'] as String?) ?? '';
        final int pureAmt = (r['pure_consumption_amount'] as int?) ?? 0;
        final String dateStr = (r['trx_date'] as String?) ?? '';
        final int day = int.tryParse(dateStr.split('-').last) ?? 1;
        final int weekNum = ((day - 1) ~/ 7) + 1;

        if (trxType == 'INCOME') {
          mIncome += pureAmt;
          weekTotals[weekNum]![0] += pureAmt;
        } else if (trxType == 'EXPENSE') {
          mExpense += pureAmt;
          weekTotals[weekNum]![1] += pureAmt;
        }
      }

      final int lastDayOfMonth = DateTime(year, month + 1, 0).day;
      final List<WeeklyBreakdownModel> weeks = <WeeklyBreakdownModel>[];
      for (int w = 1; w <= 5; w++) {
        final int startDay = ((w - 1) * 7) + 1;
        if (startDay > lastDayOfMonth) {
          break;
        }
        final int endDay =
            (w * 7) > lastDayOfMonth ? lastDayOfMonth : (w * 7);
        final int wInc = weekTotals[w]![0];
        final int wExp = weekTotals[w]![1];
        if (wInc > 0 || wExp > 0) {
          weeks.add(
            WeeklyBreakdownModel(
              weekNumber: w,
              startDay: startDay,
              endDay: endDay,
              totalIncome: wInc,
              totalPureExpense: wExp,
            ),
          );
        }
      }

      summaries.add(
        MonthlySummaryModel(
          year: year,
          month: month,
          totalIncome: mIncome,
          totalPureExpense: mExpense,
          weeks: weeks,
        ),
      );
    }

    return summaries;
  }
}

