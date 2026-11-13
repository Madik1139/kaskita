import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/providers/app_preferences_provider.dart';
import '../../../core/providers/ledger_overview_provider.dart';
import '../../debts/providers/debt_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../wallets/providers/category_provider.dart';
import '../../wallets/providers/wallet_provider.dart';
import '../data/app_security_service.dart';
import '../data/backup_restore_service.dart';
import '../data/notification_reminder_service.dart';
import '../data/ota_update_service.dart';
import '../models/settings_models.dart';

final Provider<BackupRestoreService> backupRestoreServiceProvider =
    Provider<BackupRestoreService>(
  (Ref ref) => BackupRestoreService(DatabaseHelper.instance),
);

final Provider<AppSecurityService> appSecurityServiceProvider =
    Provider<AppSecurityService>(
  (Ref ref) => AppSecurityService(DatabaseHelper.instance),
);

final Provider<NotificationReminderService> notificationReminderServiceProvider =
    Provider<NotificationReminderService>(
  (Ref ref) => NotificationReminderService(DatabaseHelper.instance),
);

final Provider<OtaUpdateService> otaUpdateServiceProvider =
    Provider<OtaUpdateService>((Ref ref) => const OtaUpdateService());

/// Menandakan apakah aplikasi sedang dalam kondisi terkunci (menunggu verifikasi PIN/Biometrik).
final StateProvider<bool> isAppLockedProvider =
    StateProvider<bool>((Ref ref) => false);

final AsyncNotifierProvider<SettingsNotifier, AppSecurityConfigModel>
    settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSecurityConfigModel>(
  SettingsNotifier.new,
);

class SettingsNotifier extends AsyncNotifier<AppSecurityConfigModel> {
  bool _syncedInitialPreferences = false;
  bool _userOverrodeTheme = false;
  bool _userOverrodeLocale = false;

  @override
  Future<AppSecurityConfigModel> build() async {
    final AppSecurityService security = ref.read(appSecurityServiceProvider);
    if (!_syncedInitialPreferences) {
      _syncedInitialPreferences = true;
      final ThemeMode savedTheme = await security.loadSavedThemeMode();
      final Locale savedLocale = await security.loadSavedLocale();
      if (!_userOverrodeTheme) {
        ref.read(themeModeProvider.notifier).state = savedTheme;
      }
      if (!_userOverrodeLocale) {
        ref.read(appLocaleProvider.notifier).state = savedLocale;
      }
    }

    final AppSecurityConfigModel config = await security.getSecurityConfig();
    if (config.appLockEnabled) {
      ref.read(isAppLockedProvider.notifier).state = true;
    }
    return config;
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(appSecurityServiceProvider).getSecurityConfig(),
    );
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    _userOverrodeTheme = true;
    _syncedInitialPreferences = true;
    ref.read(themeModeProvider.notifier).state = mode;
    await ref.read(appSecurityServiceProvider).saveThemeMode(mode);
  }

  Future<void> saveLocale(Locale locale) async {
    _userOverrodeLocale = true;
    _syncedInitialPreferences = true;
    ref.read(appLocaleProvider.notifier).state = locale;
    await ref.read(appSecurityServiceProvider).saveLocale(locale);
  }

  Future<void> enablePinLock(String pin) async {
    await ref.read(appSecurityServiceProvider).saveAppPin(pin);
    await refresh();
  }

  Future<void> disablePinLock() async {
    await ref.read(appSecurityServiceProvider).disableAppLock();
    ref.read(isAppLockedProvider.notifier).state = false;
    await refresh();
  }

  Future<bool> unlockWithPin(String pin) async {
    final bool ok = await ref.read(appSecurityServiceProvider).verifyPin(pin);
    if (ok) {
      ref.read(isAppLockedProvider.notifier).state = false;
    }
    return ok;
  }

  Future<bool> unlockWithBiometrics(String reason) async {
    final bool ok = await ref
        .read(appSecurityServiceProvider)
        .authenticateWithBiometrics(reason: reason);
    if (ok) {
      ref.read(isAppLockedProvider.notifier).state = false;
    }
    return ok;
  }

  Future<int> setAndSyncReminders(bool enabled, String languageCode) async {
    await ref.read(appSecurityServiceProvider).setDueRemindersEnabled(enabled);
    await refresh();
    if (!enabled) {
      return 0;
    }
    return ref
        .read(notificationReminderServiceProvider)
        .syncDueDateReminders(languageCode: languageCode);
  }

  Future<bool> restoreFromBackupFile() async {
    final bool restored =
        await ref.read(backupRestoreServiceProvider).pickAndRestoreBackupFile();
    if (restored) {
      ref.read(selectedWalletIdProvider.notifier).state = null;
      await ref.read(walletsProvider.notifier).refresh();
      await ref.read(categoriesProvider.notifier).refresh();
      await ref.read(transactionsProvider.notifier).refresh();
      await ref.read(debtsDirectoryProvider.notifier).refresh();
      await ref.read(ledgerOverviewProvider.notifier).refreshOverview();
      await refresh();
    }
    return restored;
  }
}

