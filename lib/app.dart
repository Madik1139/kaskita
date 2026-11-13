import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/presentation/foundation_workspace_screen.dart';
import 'core/providers/app_preferences_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/widgets/pin_lock_and_setup_views.dart';
import 'features/settings/providers/settings_provider.dart';
import 'l10n/app_localizations.dart';

class KasKitaApp extends ConsumerWidget {
  const KasKitaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(settingsProvider);
    final bool isLocked = ref.watch(isAppLockedProvider);
    final ThemeMode themeMode = ref.watch(themeModeProvider);
    final Locale currentLocale = ref.watch(appLocaleProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: currentLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: isLocked
          ? const PinLockOverlay()
          : const FoundationWorkspaceScreen(),
    );
  }
}
