import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/providers/app_preferences_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/localization_helper.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/tactile_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../reports/models/report_models.dart';
import '../../reports/presentation/widgets/category_breakdown_card.dart';
import '../../reports/presentation/widgets/monthly_comparison_chart_card.dart';
import '../../reports/providers/report_provider.dart';
import '../models/settings_models.dart';
import '../providers/settings_provider.dart';
import 'widgets/pin_lock_and_setup_views.dart';

/// Tampilan Tab 3 (Ringkasan & Pengaturan):
/// - Grafik Perbandingan 6 Bulan (`fl_chart`) & Rincian Kategori
/// - Kunci Aplikasi (PIN 6 Digit & Biometrik)
/// - Pengingat Jatuh Tempo Lokal (09.00 pagi)
/// - Backup/Restore Lokal (`.json` / `.db`) & Ekspor Laporan `.csv`
/// - Cek Pembaruan Aplikasi OTA via GitHub Releases
class SummarySettingsTabView extends ConsumerStatefulWidget {
  const SummarySettingsTabView({super.key});

  @override
  ConsumerState<SummarySettingsTabView> createState() =>
      _SummarySettingsTabViewState();
}

class _SummarySettingsTabViewState
    extends ConsumerState<SummarySettingsTabView> {
  bool _isBusy = false;

  Future<void> _runWithFeedback(Future<void> Function() action) async {
    if (_isBusy) {
      return;
    }
    setState(() => _isBusy = true);
    try {
      await action();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppException.resolveError(error, context.l10n)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _checkOtaUpdates() async {
    final AppLocalizations l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.checkingUpdateMsg)),
    );
    await _runWithFeedback(() async {
      final OtaReleaseCheckResult result =
          await ref.read(otaUpdateServiceProvider).checkLatestRelease();
      if (!mounted) {
        return;
      }
      if (!result.hasUpdate) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.alreadyLatestVersionMsg(result.currentVersion)),
          ),
        );
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (BuildContext ctx) => AlertDialog(
          title: Text(l10n.updateAvailableTitle(result.latestVersion)),
          content: Text(
            result.releaseNotes.isNotEmpty
                ? result.releaseNotes
                : '${result.currentVersion} -> ${result.latestVersion}',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.close),
            ),
            FilledButton.icon(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await ref.read(otaUpdateServiceProvider).openReleaseUrl(
                      result.downloadUrl ?? result.releaseUrl,
                    );
              },
              icon: const Icon(LucideIcons.download, size: 16),
              label: Text(l10n.downloadUpdateBtn),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final String langCode = ref.watch(appLocaleProvider).languageCode;
    final AsyncValue<ReportSummaryState> reportsAsync =
        ref.watch(reportsProvider);
    final AsyncValue<AppSecurityConfigModel> settingsAsync =
        ref.watch(settingsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(reportsProvider);
        await ref.read(settingsProvider.notifier).refresh();
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        children: <Widget>[
          Text(
            l10n.reportSectionTitle,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 8),
          reportsAsync.when(
            loading: () => const TactileCard(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (Object err, StackTrace _) => EmptyStateView(
              icon: LucideIcons.triangleAlert,
              title: l10n.errUnexpectedUiTitle,
              subtitle: AppException.resolveError(err, l10n),
            ),
            data: (ReportSummaryState report) => Column(
              children: <Widget>[
                MonthlyComparisonChartCard(points: report.sixMonthTrend),
                const SizedBox(height: 12),
                CategoryBreakdownCard(
                  activePeriod: report.activePeriod,
                  items: report.categoryBreakdown,
                  totalPureExpense: report.totalPureExpenseInMonth,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.securitySectionTitle,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 8),
          settingsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (AppSecurityConfigModel config) => TactileCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: <Widget>[
                  SwitchListTile(
                    secondary: Icon(
                      LucideIcons.shieldCheck,
                      size: 20,
                      color: AppColors.accent(context),
                    ),
                    title: Text(
                      l10n.appLockToggleTitle,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      l10n.appLockToggleSubtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    value: config.appLockEnabled,
                    onChanged: (bool val) async {
                      if (val) {
                        await PinSetupSheet.show(context);
                      } else {
                        await ref
                            .read(settingsProvider.notifier)
                            .disablePinLock();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.pinDisabledMsg)),
                          );
                        }
                      }
                    },
                  ),
                  if (config.appLockEnabled) ...<Widget>[
                    const Divider(),
                    ListTile(
                      dense: true,
                      leading: const Icon(LucideIcons.keyRound, size: 18),
                      title: Text(l10n.changePinAction),
                      trailing: const Icon(LucideIcons.chevronRight, size: 16),
                      onTap: () => PinSetupSheet.show(context),
                    ),
                  ],
                  const Divider(),
                  SwitchListTile(
                    secondary: Icon(
                      LucideIcons.bellRing,
                      size: 20,
                      color: AppColors.warning(context),
                    ),
                    title: Text(
                      l10n.dueReminderToggleTitle,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      l10n.dueReminderToggleSubtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    value: config.dueRemindersEnabled,
                    onChanged: (bool val) async {
                      final int count = await ref
                          .read(settingsProvider.notifier)
                          .setAndSyncReminders(val, langCode);
                      if (val && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.remindersScheduledMsg(count)),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.dataBackupSectionTitle,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 8),
          TactileCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(LucideIcons.fileJson, size: 19),
                  title: Text(l10n.exportBackupJsonBtn),
                  trailing: const Icon(LucideIcons.share2, size: 16),
                  onTap: () => _runWithFeedback(() async {
                    await ref
                        .read(backupRestoreServiceProvider)
                        .exportAndShareJsonBackup();
                  }),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(LucideIcons.databaseBackup, size: 19),
                  title: Text(l10n.exportBackupDbBtn),
                  trailing: const Icon(LucideIcons.share2, size: 16),
                  onTap: () => _runWithFeedback(() async {
                    await ref
                        .read(backupRestoreServiceProvider)
                        .exportAndShareDbBackup();
                  }),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(LucideIcons.fileSpreadsheet, size: 19),
                  title: Text(l10n.exportCsvBtn),
                  trailing: const Icon(LucideIcons.share2, size: 16),
                  onTap: () => _runWithFeedback(() async {
                    await ref
                        .read(backupRestoreServiceProvider)
                        .exportAndShareCsvReport();
                  }),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(
                    LucideIcons.folderUp,
                    size: 19,
                    color: AppColors.mutation(context),
                  ),
                  title: Text(
                    l10n.restoreBackupBtn,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  trailing: const Icon(LucideIcons.chevronRight, size: 16),
                  onTap: () => _runWithFeedback(() async {
                    final bool restored = await ref
                        .read(settingsProvider.notifier)
                        .restoreFromBackupFile();
                    if (restored && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.backupRestoredMsg)),
                      );
                    }
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.otaSectionTitle,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 8),
          TactileCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(LucideIcons.info, size: 19),
                  title: Text(l10n.currentVersionLabel),
                  trailing: const Text(
                    'v${AppConstants.appVersion}',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(
                    LucideIcons.refreshCw,
                    size: 19,
                    color: AppColors.accent(context),
                  ),
                  title: Text(
                    l10n.checkUpdateBtn,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  trailing: _isBusy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(LucideIcons.chevronRight, size: 16),
                  onTap: _checkOtaUpdates,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

