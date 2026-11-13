import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/ledger_overview_repository.dart';
import '../database/database_helper.dart';
import '../models/ledger_summary_model.dart';

final Provider<LedgerOverviewRepository> ledgerOverviewRepositoryProvider =
    Provider<LedgerOverviewRepository>(
  (Ref ref) => LedgerOverviewRepository(DatabaseHelper.instance),
);

final AsyncNotifierProvider<LedgerOverviewNotifier, LedgerOverviewState>
    ledgerOverviewProvider =
    AsyncNotifierProvider<LedgerOverviewNotifier, LedgerOverviewState>(
  LedgerOverviewNotifier.new,
);

class LedgerOverviewNotifier extends AsyncNotifier<LedgerOverviewState> {
  @override
  Future<LedgerOverviewState> build() async {
    final LedgerOverviewRepository repo =
        ref.watch(ledgerOverviewRepositoryProvider);
    return repo.fetchOverview();
  }

  Future<void> refreshOverview() async {
    state = const AsyncLoading<LedgerOverviewState>();
    state = await AsyncValue.guard(() async {
      return ref.read(ledgerOverviewRepositoryProvider).fetchOverview();
    });
  }

  Future<void> loadDemoData() async {
    state = const AsyncLoading<LedgerOverviewState>();
    state = await AsyncValue.guard(() async {
      final LedgerOverviewRepository repo =
          ref.read(ledgerOverviewRepositoryProvider);
      await repo.seedDemoData();
      return repo.fetchOverview();
    });
  }

  Future<void> resetAllData() async {
    state = const AsyncLoading<LedgerOverviewState>();
    state = await AsyncValue.guard(() async {
      final LedgerOverviewRepository repo =
          ref.read(ledgerOverviewRepositoryProvider);
      await repo.resetAllData();
      return repo.fetchOverview();
    });
  }
}
