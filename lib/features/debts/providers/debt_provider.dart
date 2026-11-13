import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/providers/ledger_overview_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../wallets/data/wallet_repository.dart';
import '../../wallets/providers/wallet_provider.dart';
import '../data/debt_repository.dart';
import '../models/debt_models.dart';

enum ContactFilterType {
  all,
  theyOweMe,
  iOweThem,
  overdue,
}

final Provider<DebtRepository> debtRepositoryProvider =
    Provider<DebtRepository>(
  (Ref ref) => DebtRepository(DatabaseHelper.instance),
);

final StateProvider<ContactFilterType> selectedContactFilterProvider =
    StateProvider<ContactFilterType>((Ref ref) => ContactFilterType.all);

class DebtsDirectoryState extends Equatable {
  const DebtsDirectoryState({
    required this.contacts,
    required this.totalReceivables,
    required this.totalPayables,
    required this.lendingCapLimit,
  });

  final List<ContactSummaryModel> contacts;
  final int totalReceivables;
  final int totalPayables;
  final int lendingCapLimit;

  bool get isLendingCapExceeded =>
      lendingCapLimit > 0 && totalReceivables >= lendingCapLimit;

  double get lendingCapProgress => lendingCapLimit <= 0
      ? 0
      : (totalReceivables / lendingCapLimit).clamp(0.0, 1.0);

  List<ContactSummaryModel> filterContacts(ContactFilterType filter) {
    switch (filter) {
      case ContactFilterType.theyOweMe:
        return contacts
            .where((ContactSummaryModel c) => c.netBalance > 0)
            .toList();
      case ContactFilterType.iOweThem:
        return contacts
            .where((ContactSummaryModel c) => c.netBalance < 0)
            .toList();
      case ContactFilterType.overdue:
        return contacts.where((ContactSummaryModel c) => c.isOverdue).toList();
      case ContactFilterType.all:
        return contacts;
    }
  }

  ContactSummaryModel? findById(int? id) {
    if (id == null) {
      return null;
    }
    for (final ContactSummaryModel c in contacts) {
      if (c.id == id) {
        return c;
      }
    }
    return null;
  }

  @override
  List<Object?> get props => <Object?>[
        contacts,
        totalReceivables,
        totalPayables,
        lendingCapLimit,
      ];
}

final AsyncNotifierProvider<DebtsDirectoryNotifier, DebtsDirectoryState>
    debtsDirectoryProvider =
    AsyncNotifierProvider<DebtsDirectoryNotifier, DebtsDirectoryState>(
  DebtsDirectoryNotifier.new,
);

class DebtsDirectoryNotifier extends AsyncNotifier<DebtsDirectoryState> {
  @override
  Future<DebtsDirectoryState> build() async {
    return _fetchState();
  }

  Future<DebtsDirectoryState> _fetchState() async {
    final DebtRepository repo = ref.read(debtRepositoryProvider);
    final List<ContactSummaryModel> contacts = await repo.getContactsSummary();
    final int cap = await repo.getLendingCapLimit();
    final WalletsState? wState = ref.read(walletsProvider).valueOrNull;

    int totalRec = wState?.indicators.activeReceivables ?? 0;
    int totalPay = wState?.indicators.activePayables ?? 0;
    if (wState == null) {
      final WalletRepository walletRepo = ref.read(walletRepositoryProvider);
      final ind = await walletRepo.calculateIndicators();
      totalRec = ind.activeReceivables;
      totalPay = ind.activePayables;
    }

    return DebtsDirectoryState(
      contacts: contacts,
      totalReceivables: totalRec,
      totalPayables: totalPay,
      lendingCapLimit: cap,
    );
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_fetchState);
  }

  Future<void> _syncAllLedgers() async {
    await ref.read(walletsProvider.notifier).refresh();
    await ref.read(transactionsProvider.notifier).refresh();
    await ref.read(ledgerOverviewProvider.notifier).refreshOverview();
    await refresh();
  }

  Future<void> createContact({
    required String name,
    String? phoneNote,
  }) async {
    await ref.read(debtRepositoryProvider).createContact(
          name: name,
          phoneNote: phoneNote,
        );
    await _syncAllLedgers();
  }

  Future<void> updateContact({
    required int id,
    required String name,
    String? phoneNote,
  }) async {
    await ref.read(debtRepositoryProvider).updateContact(
          id: id,
          name: name,
          phoneNote: phoneNote,
        );
    await _syncAllLedgers();
  }

  Future<void> deleteContact(int contactId) async {
    await ref.read(debtRepositoryProvider).deleteContact(contactId);
    await _syncAllLedgers();
  }

  Future<void> updateLendingCapLimit(int newLimit) async {
    await ref.read(debtRepositoryProvider).updateLendingCapLimit(newLimit);
    await refresh();
  }

  Future<void> settleDebts({
    required int contactId,
    required String debtType,
    required int amount,
    required String settlementMethod,
    required DateTime paymentDate,
    int? walletId,
    int? specificDebtId,
    bool recordTreatAsPersonalExpense = false,
    int? treatExpenseCategoryId,
    String? note,
  }) async {
    await ref.read(debtRepositoryProvider).settleDebts(
          contactId: contactId,
          debtType: debtType,
          amount: amount,
          settlementMethod: settlementMethod,
          paymentDate: paymentDate,
          walletId: walletId,
          specificDebtId: specificDebtId,
          recordTreatAsPersonalExpense: recordTreatAsPersonalExpense,
          treatExpenseCategoryId: treatExpenseCategoryId,
          note: note,
        );
    await _syncAllLedgers();
  }

  Future<void> recordDebtWithAutoNetting({
    required int contactId,
    required String newDebtType,
    required int amount,
    required DateTime date,
    int? walletId,
    String? note,
    DateTime? dueDate,
  }) async {
    await ref.read(debtRepositoryProvider).recordDebtWithAutoNetting(
          contactId: contactId,
          newDebtType: newDebtType,
          amount: amount,
          date: date,
          walletId: walletId,
          note: note,
          dueDate: dueDate,
        );
    await _syncAllLedgers();
  }

  Future<void> cancelDebtPayment(int paymentId) async {
    await ref.read(debtRepositoryProvider).cancelDebtPayment(paymentId);
    await _syncAllLedgers();
  }
}

final FutureProviderFamily<ContactDetailStateModel, int> contactDetailProvider =
    FutureProvider.family<ContactDetailStateModel, int>(
  (Ref ref, int contactId) async {
    ref.watch(debtsDirectoryProvider);
    return ref.read(debtRepositoryProvider).getContactDetail(contactId);
  },
);
