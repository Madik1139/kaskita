import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../features/debts/presentation/debt_directory_tab_view.dart';
import '../../features/debts/providers/debt_provider.dart';
import '../../features/reports/presentation/reports_tab_view.dart';
import '../../features/reports/providers/report_provider.dart';
import '../../features/settings/presentation/settings_tab_view.dart';
import '../../features/settings/providers/settings_provider.dart';
import '../../features/transactions/presentation/widgets/calendar_ledger_view.dart';
import '../../features/transactions/presentation/widgets/daily_transaction_group_card.dart';
import '../../features/transactions/presentation/widgets/monthly_ledger_view.dart';
import '../../features/transactions/presentation/widgets/period_summary_header.dart';
import '../../features/transactions/presentation/widgets/transaction_form_sheet.dart';
import '../../features/transactions/providers/transaction_provider.dart';
import '../../features/wallets/presentation/widgets/onboarding_balance_sheet.dart';
import '../../features/wallets/providers/category_provider.dart';
import '../../features/wallets/providers/wallet_provider.dart';
import '../../l10n/app_localizations.dart';
import '../errors/app_exception.dart';
import '../models/ledger_summary_model.dart';
import '../providers/ledger_overview_provider.dart';
import '../theme/app_colors.dart';
import '../utils/localization_helper.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/status_badge.dart';
import 'widgets/unified_ledger_summary_card.dart';

/// Kerangka Navigasi 4 Tab & Beranda KasKita:
/// 100% murni UI (mengambil state melalui Riverpod tanpa impor SQLite).
class FoundationWorkspaceScreen extends ConsumerStatefulWidget {
  const FoundationWorkspaceScreen({super.key});

  @override
  ConsumerState<FoundationWorkspaceScreen> createState() =>
      _FoundationWorkspaceScreenState();
}

class _FoundationWorkspaceScreenState
    extends ConsumerState<FoundationWorkspaceScreen> {
  int _selectedTabIndex = 0;
  bool _onboardingDialogOpened = false;

  Future<void> _refreshAllProviders() async {
    await ref.read(walletsProvider.notifier).refresh();
    await ref.read(categoriesProvider.notifier).refresh();
    await ref.read(transactionsProvider.notifier).refresh();
    await ref.read(debtsDirectoryProvider.notifier).refresh();
    await ref.read(ledgerOverviewProvider.notifier).refreshOverview();
    ref.invalidate(reportsProvider);
    await ref.read(settingsProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<LedgerOverviewState> overviewAsync =
        ref.watch(ledgerOverviewProvider);
    final AsyncValue<TransactionsPeriodState> transactionsAsync =
        ref.watch(transactionsProvider);
    final AppLocalizations l10n = context.l10n;

    ref.listen<AsyncValue<WalletsState>>(
      walletsProvider,
      (AsyncValue<WalletsState>? previous, AsyncValue<WalletsState> next) {
        final WalletsState? state = next.valueOrNull;
        if (state != null &&
            !state.isOnboardingCompleted &&
            !_onboardingDialogOpened) {
          _onboardingDialogOpened = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              OnboardingBalanceSheet.show(context);
            }
          });
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/icons/app_icon_1024.png',
                width: 28,
                height: 28,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Text(l10n.appTitle),
            const SizedBox(width: 8),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: StatusBadge(
                  label: l10n.phaseBadge,
                  variant: BadgeVariant.positive,
                  compact: true,
                ),
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedTabIndex,
        children: <Widget>[
          _buildHomeTab(context, overviewAsync, transactionsAsync, l10n),
          const DebtDirectoryTabView(),
          const ReportsTabView(),
          const SettingsTabView(),
        ],
      ),
      floatingActionButton: _selectedTabIndex >= 2
          ? null
          : FloatingActionButton.extended(
        onPressed: () => TransactionFormSheet.show(context),
        backgroundColor: AppColors.accent(context),
        foregroundColor:
            AppColors.isDark(context) ? AppColors.darkBackground : Colors.white,
        icon: const Icon(LucideIcons.plus, size: 20),
        label: Text(
          l10n.quickRecord,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border(context), width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedTabIndex,
          onDestinationSelected: (int index) =>
              setState(() => _selectedTabIndex = index),
          destinations: <NavigationDestination>[
            NavigationDestination(
              icon: const Icon(LucideIcons.wallet),
              label: l10n.navHome,
            ),
            NavigationDestination(
              icon: const Icon(LucideIcons.bookUser),
              label: l10n.navDebtBook,
            ),
            NavigationDestination(
              icon: const Icon(LucideIcons.chartColumn),
              label: l10n.navReports,
            ),
            NavigationDestination(
              icon: const Icon(LucideIcons.settings),
              label: l10n.navSettings,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab(
    BuildContext context,
    AsyncValue<LedgerOverviewState> overviewAsync,
    AsyncValue<TransactionsPeriodState> transactionsAsync,
    AppLocalizations l10n,
  ) {
    final LedgerViewSubTab activeSubTab =
        ref.watch(selectedLedgerSubTabProvider);

    return overviewAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object err, StackTrace _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: EmptyStateView(
            icon: LucideIcons.triangleAlert,
            title: l10n.errUnexpectedUiTitle,
            subtitle: AppException.resolveError(err, l10n),
            actionLabel: l10n.reset,
            onActionTap: _refreshAllProviders,
          ),
        ),
      ),
      data: (LedgerOverviewState overview) {
        final TransactionsPeriodState? periodState =
            transactionsAsync.valueOrNull;

        return RefreshIndicator(
          onRefresh: _refreshAllProviders,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            children: <Widget>[
              UnifiedLedgerSummaryCard(overview: overview),
              const SizedBox(height: 12),
              PeriodSummaryHeader(
                totalIncome: periodState?.monthTotalIncome ?? 0,
                totalPureExpense: periodState?.monthTotalPureExpense ?? 0,
              ),
              const SizedBox(height: 12),
              if (periodState == null)
                const Center(child: CircularProgressIndicator())
              else if (activeSubTab == LedgerViewSubTab.calendar)
                CalendarLedgerView(periodState: periodState)
              else if (activeSubTab == LedgerViewSubTab.monthly)
                MonthlyLedgerView(summaries: periodState.yearlySummaries)
              else if (periodState.dailyGroups.isEmpty)
                EmptyStateView(
                  icon: LucideIcons.receiptText,
                  title: l10n.noTransactionsInPeriodTitle,
                  subtitle: l10n.noTransactionsInPeriodSubtitle,
                  actionLabel: l10n.recordTransactionBtn,
                  onActionTap: () => TransactionFormSheet.show(context),
                )
              else
                for (int i = 0;
                    i < periodState.dailyGroups.length;
                    i++) ...<Widget>[
                  if (i > 0) const SizedBox(height: 10),
                  DailyTransactionGroupCard(group: periodState.dailyGroups[i]),
                ],
            ],
          ),
        );
      },
    );
  }
}
