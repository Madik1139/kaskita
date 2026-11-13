import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/providers/ledger_overview_provider.dart';
import '../../wallets/providers/wallet_provider.dart';
import '../data/transaction_query_repository.dart';
import '../data/transaction_repository.dart';
import '../models/transaction_model.dart';

enum LedgerViewSubTab {
  daily,
  calendar,
  monthly,
}

final Provider<TransactionRepository> transactionRepositoryProvider =
    Provider<TransactionRepository>(
  (Ref ref) => TransactionRepository(DatabaseHelper.instance),
);

final Provider<TransactionQueryRepository> transactionQueryRepositoryProvider =
    Provider<TransactionQueryRepository>(
  (Ref ref) => TransactionQueryRepository(DatabaseHelper.instance),
);

final StateProvider<DateTime> selectedPeriodProvider = StateProvider<DateTime>(
  (Ref ref) {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  },
);

final StateProvider<DateTime> selectedCalendarDayProvider =
    StateProvider<DateTime>((Ref ref) => DateTime.now());

final StateProvider<LedgerViewSubTab> selectedLedgerSubTabProvider =
    StateProvider<LedgerViewSubTab>((Ref ref) => LedgerViewSubTab.daily);

class TransactionsPeriodState extends Equatable {
  const TransactionsPeriodState({
    required this.activePeriod,
    required this.monthTransactions,
    required this.dailyGroups,
    required this.yearlySummaries,
    required this.contacts,
    required this.monthTotalIncome,
    required this.monthTotalPureExpense,
  });

  final DateTime activePeriod;
  final List<TransactionItemModel> monthTransactions;
  final List<DailyTransactionGroupModel> dailyGroups;
  final List<MonthlySummaryModel> yearlySummaries;
  final List<ContactOptionModel> contacts;
  final int monthTotalIncome;
  final int monthTotalPureExpense;

  int get monthNetDifference => monthTotalIncome - monthTotalPureExpense;

  DailyTransactionGroupModel? groupForDate(DateTime date) {
    final String iso =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    for (final DailyTransactionGroupModel g in dailyGroups) {
      if (g.isoDate == iso) {
        return g;
      }
    }
    return null;
  }

  @override
  List<Object?> get props => <Object?>[
        activePeriod,
        monthTransactions,
        dailyGroups,
        yearlySummaries,
        contacts,
        monthTotalIncome,
        monthTotalPureExpense,
      ];
}

final AsyncNotifierProvider<TransactionsNotifier, TransactionsPeriodState>
    transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, TransactionsPeriodState>(
  TransactionsNotifier.new,
);

class TransactionsNotifier extends AsyncNotifier<TransactionsPeriodState> {
  @override
  Future<TransactionsPeriodState> build() async {
    final DateTime period = ref.watch(selectedPeriodProvider);
    final int? selectedWalletId = ref.watch(selectedWalletIdProvider);
    return _fetchPeriodState(period, selectedWalletId);
  }

  Future<TransactionsPeriodState> _fetchPeriodState(
    DateTime period,
    int? selectedWalletId,
  ) async {
    final TransactionQueryRepository queryRepo =
        ref.read(transactionQueryRepositoryProvider);
    final TransactionRepository trxRepo =
        ref.read(transactionRepositoryProvider);

    final List<TransactionItemModel> monthItems =
        await queryRepo.getTransactionsByMonth(
      year: period.year,
      month: period.month,
      selectedWalletId: selectedWalletId,
    );
    final List<DailyTransactionGroupModel> dailyGroups =
        TransactionQueryRepository.groupTransactionsByDay(monthItems);
    final List<MonthlySummaryModel> yearlySummaries =
        await queryRepo.getYearlyMonthlySummaries(
      year: period.year,
      selectedWalletId: selectedWalletId,
    );
    final List<ContactOptionModel> contacts = await trxRepo.getContacts();

    int totalIncome = 0;
    int totalPureExpense = 0;
    for (final TransactionItemModel item in monthItems) {
      if (item.trxType == 'INCOME') {
        totalIncome += item.pureConsumptionAmount;
      } else if (item.trxType == 'EXPENSE') {
        totalPureExpense += item.pureConsumptionAmount;
      }
    }

    return TransactionsPeriodState(
      activePeriod: period,
      monthTransactions: monthItems,
      dailyGroups: dailyGroups,
      yearlySummaries: yearlySummaries,
      contacts: contacts,
      monthTotalIncome: totalIncome,
      monthTotalPureExpense: totalPureExpense,
    );
  }

  Future<void> refresh() async {
    final DateTime period = ref.read(selectedPeriodProvider);
    final int? walletId = ref.read(selectedWalletIdProvider);
    state = await AsyncValue.guard(() => _fetchPeriodState(period, walletId));
  }

  Future<void> _syncAllLedgers() async {
    await refresh();
    await ref.read(walletsProvider.notifier).refresh();
    await ref.read(ledgerOverviewProvider.notifier).refreshOverview();
  }

  Future<void> recordTransaction({
    required String trxType,
    required int walletId,
    required int totalWalletAmount,
    required DateTime trxDate,
    int? categoryId,
    String? note,
    bool isSplitTalangan = false,
    int friendShareAmount = 0,
    int? contactId,
    String? newContactName,
    DateTime? dueDate,
  }) async {
    await ref.read(transactionRepositoryProvider).recordTransaction(
          trxType: trxType,
          walletId: walletId,
          totalWalletAmount: totalWalletAmount,
          trxDate: trxDate,
          categoryId: categoryId,
          note: note,
          isSplitTalangan: isSplitTalangan,
          friendShareAmount: friendShareAmount,
          contactId: contactId,
          newContactName: newContactName,
          dueDate: dueDate,
        );
    await _syncAllLedgers();
  }

  Future<void> updateTransaction({
    required int transactionId,
    required int walletId,
    required int totalWalletAmount,
    required DateTime trxDate,
    int? categoryId,
    String? note,
    bool isSplitTalangan = false,
    int friendShareAmount = 0,
    int? contactId,
    String? newContactName,
    DateTime? dueDate,
  }) async {
    await ref.read(transactionRepositoryProvider).updateTransaction(
          transactionId: transactionId,
          walletId: walletId,
          totalWalletAmount: totalWalletAmount,
          trxDate: trxDate,
          categoryId: categoryId,
          note: note,
          isSplitTalangan: isSplitTalangan,
          friendShareAmount: friendShareAmount,
          contactId: contactId,
          newContactName: newContactName,
          dueDate: dueDate,
        );
    await _syncAllLedgers();
  }

  Future<void> deleteTransaction(int transactionId) async {
    await ref
        .read(transactionRepositoryProvider)
        .deleteTransaction(transactionId);
    await _syncAllLedgers();
  }
}

