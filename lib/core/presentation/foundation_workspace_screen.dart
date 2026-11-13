import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../l10n/app_localizations.dart';
import '../errors/app_exception.dart';
import '../models/ledger_summary_model.dart';
import '../providers/app_preferences_provider.dart';
import '../providers/ledger_overview_provider.dart';
import '../theme/app_colors.dart';
import '../utils/localization_helper.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/status_badge.dart';
import '../widgets/tactile_card.dart';
import 'widgets/daily_ledger_preview_card.dart';
import 'widgets/quick_input_preview_sheet.dart';
import 'widgets/unified_ledger_summary_card.dart';

/// Layar Beranda Fase 1 (v0.2.0):
/// 100% murni UI (mengambil state melalui Riverpod `ledgerOverviewProvider`,
/// tanpa impor SQLite dan dipecah menjadi sub-widget modular < 200 baris).
class FoundationWorkspaceScreen extends ConsumerWidget {
  const FoundationWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode currentTheme = ref.watch(themeModeProvider);
    final Locale currentLocale = ref.watch(appLocaleProvider);
    final AsyncValue<LedgerOverviewState> overviewAsync =
        ref.watch(ledgerOverviewProvider);
    final AppLocalizations l10n = context.l10n;
    final String langCode = currentLocale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.accent(context),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                LucideIcons.bookOpen,
                size: 16,
                color: AppColors.isDark(context)
                    ? AppColors.darkBackground
                    : Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Text(l10n.appTitle),
            const SizedBox(width: 8),
            StatusBadge(
              label: l10n.phase1Badge,
              variant: BadgeVariant.positive,
              compact: true,
            ),
          ],
        ),
        actions: <Widget>[
          Tooltip(
            message: l10n.switchLanguageTooltip,
            child: TextButton.icon(
              onPressed: () {
                final Locale nextLocale = langCode == 'id'
                    ? const Locale('en')
                    : const Locale('id');
                ref.read(appLocaleProvider.notifier).state = nextLocale;
              },
              icon: const Icon(LucideIcons.languages, size: 16),
              label: Text(
                langCode.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          IconButton(
            tooltip: l10n.switchThemeTooltip,
            onPressed: () {
              final ThemeMode next = currentTheme == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
              ref.read(themeModeProvider.notifier).state = next;
            },
            icon: Icon(
              AppColors.isDark(context) ? LucideIcons.sun : LucideIcons.moon,
              size: 19,
            ),
          ),
        ],
      ),
      body: overviewAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object err, StackTrace _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: EmptyStateView(
              icon: LucideIcons.triangleAlert,
              title: l10n.errUnexpectedUiTitle,
              subtitle: AppException.resolveError(err, l10n),
              actionLabel: l10n.reset,
              onActionTap: () =>
                  ref.read(ledgerOverviewProvider.notifier).refreshOverview(),
            ),
          ),
        ),
        data: (LedgerOverviewState overview) => RefreshIndicator(
          onRefresh: () =>
              ref.read(ledgerOverviewProvider.notifier).refreshOverview(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              UnifiedLedgerSummaryCard(overview: overview),
              const SizedBox(height: 12),
              TactileCard(
                backgroundColor: AppColors.surfaceSecondary(context),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => ref
                            .read(ledgerOverviewProvider.notifier)
                            .loadDemoData(),
                        icon: const Icon(LucideIcons.database, size: 16),
                        label: Text(l10n.loadDemoData),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => ref
                            .read(ledgerOverviewProvider.notifier)
                            .resetAllData(),
                        icon: const Icon(LucideIcons.rotateCcw, size: 16),
                        label: Text(l10n.resetDataToZero),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (overview.recentTransactions.isEmpty)
                EmptyStateView(
                  icon: LucideIcons.receiptText,
                  title: l10n.emptyTransactionsTitle,
                  subtitle: l10n.emptyTransactionsSubtitle,
                  actionLabel: l10n.loadDemoDataNow,
                  onActionTap: () =>
                      ref.read(ledgerOverviewProvider.notifier).loadDemoData(),
                )
              else
                DailyLedgerPreviewCard(
                  date: DateTime.now(),
                  transactions: overview.recentTransactions,
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => QuickInputPreviewSheet.show(context),
        backgroundColor: AppColors.accent(context),
        foregroundColor:
            AppColors.isDark(context) ? AppColors.darkBackground : Colors.white,
        icon: const Icon(LucideIcons.plus, size: 20),
        label: Text(
          l10n.quickRecord,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
