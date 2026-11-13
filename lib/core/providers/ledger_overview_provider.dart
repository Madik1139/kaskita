import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/wallets/providers/category_provider.dart';
import '../../features/wallets/providers/wallet_provider.dart';
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
    final int? selectedWalletId = ref.watch(selectedWalletIdProvider);
    return repo.fetchOverview(selectedWalletId: selectedWalletId);
  }

  Future<void> refreshOverview() async {
    final int? selectedWalletId = ref.read(selectedWalletIdProvider);
    state = await AsyncValue.guard(() async {
      return ref
          .read(ledgerOverviewRepositoryProvider)
          .fetchOverview(selectedWalletId: selectedWalletId);
    });
  }

  Future<void> loadDemoData() async {
    state = const AsyncLoading<LedgerOverviewState>();
    state = await AsyncValue.guard(() async {
      final LedgerOverviewRepository repo =
          ref.read(ledgerOverviewRepositoryProvider);
      await repo.seedDemoData();
      ref.invalidate(walletsProvider);
      ref.invalidate(categoriesProvider);
      return repo.fetchOverview(
        selectedWalletId: ref.read(selectedWalletIdProvider),
      );
    });
  }

  Future<void> resetAllData() async {
    state = const AsyncLoading<LedgerOverviewState>();
    state = await AsyncValue.guard(() async {
      final LedgerOverviewRepository repo =
          ref.read(ledgerOverviewRepositoryProvider);
      await repo.resetAllData();
      ref.read(selectedWalletIdProvider.notifier).state = null;
      ref.invalidate(walletsProvider);
      ref.invalidate(categoriesProvider);
      return repo.fetchOverview();
    });
  }
}
