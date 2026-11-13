import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_helper.dart';
import '../data/wallet_repository.dart';
import '../models/wallet_model.dart';

final Provider<WalletRepository> walletRepositoryProvider =
    Provider<WalletRepository>(
  (Ref ref) => WalletRepository(DatabaseHelper.instance),
);

/// Menyimpan filter pill dompet aktif di Beranda (`null` = Semua Dompet).
final StateProvider<int?> selectedWalletIdProvider =
    StateProvider<int?>((Ref ref) => null);

class WalletsState extends Equatable {
  const WalletsState({
    required this.wallets,
    required this.indicators,
    required this.isOnboardingCompleted,
  });

  final List<WalletModel> wallets;
  final FinancialIndicatorsModel indicators;
  final bool isOnboardingCompleted;

  WalletModel? findById(int? id) {
    if (id == null) {
      return null;
    }
    for (final WalletModel w in wallets) {
      if (w.id == id) {
        return w;
      }
    }
    return null;
  }

  @override
  List<Object?> get props => <Object?>[
        wallets,
        indicators,
        isOnboardingCompleted,
      ];
}

final AsyncNotifierProvider<WalletsNotifier, WalletsState> walletsProvider =
    AsyncNotifierProvider<WalletsNotifier, WalletsState>(WalletsNotifier.new);

class WalletsNotifier extends AsyncNotifier<WalletsState> {
  @override
  Future<WalletsState> build() async {
    final int? selectedWalletId = ref.watch(selectedWalletIdProvider);
    return _fetchState(selectedWalletId);
  }

  Future<WalletsState> _fetchState(int? selectedWalletId) async {
    final WalletRepository repo = ref.read(walletRepositoryProvider);
    final List<WalletModel> wallets = await repo.getActiveWallets();
    final FinancialIndicatorsModel indicators = await repo.calculateIndicators(
      selectedWalletId: selectedWalletId,
    );
    final bool onboardingDone = await repo.isOnboardingPromptShown();
    return WalletsState(
      wallets: wallets,
      indicators: indicators,
      isOnboardingCompleted: onboardingDone,
    );
  }

  Future<void> refresh() async {
    final int? selectedId = ref.read(selectedWalletIdProvider);
    state = await AsyncValue.guard(() => _fetchState(selectedId));
  }

  Future<void> completeOnboarding(int initialCashBalance) async {
    final WalletRepository repo = ref.read(walletRepositoryProvider);
    await repo.completeOnboarding(initialCashBalance: initialCashBalance);
    await refresh();
  }

  Future<void> createWallet({
    required String name,
    required String type,
    required int initialBalance,
  }) async {
    final WalletRepository repo = ref.read(walletRepositoryProvider);
    await repo.createWallet(
      name: name,
      type: type,
      initialBalance: initialBalance,
    );
    await refresh();
  }

  Future<void> updateWallet({
    required int id,
    required String name,
    required String type,
    required int currentBalance,
  }) async {
    final WalletRepository repo = ref.read(walletRepositoryProvider);
    await repo.updateWallet(
      id: id,
      name: name,
      type: type,
      currentBalance: currentBalance,
    );
    await refresh();
  }

  Future<void> archiveWallet(int id) async {
    final WalletRepository repo = ref.read(walletRepositoryProvider);
    await repo.archiveWallet(id);
    if (ref.read(selectedWalletIdProvider) == id) {
      ref.read(selectedWalletIdProvider.notifier).state = null;
    }
    await refresh();
  }

  Future<void> transferBetweenWallets({
    required int sourceWalletId,
    required int targetWalletId,
    required int amount,
    required DateTime date,
    String? note,
  }) async {
    final WalletRepository repo = ref.read(walletRepositoryProvider);
    await repo.transferBetweenWallets(
      sourceWalletId: sourceWalletId,
      targetWalletId: targetWalletId,
      amount: amount,
      date: date,
      note: note,
    );
    await refresh();
  }
}

