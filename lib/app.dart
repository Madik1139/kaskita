import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/presentation/foundation_workspace_screen.dart';
import 'core/providers/app_preferences_provider.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

class KasKitaApp extends ConsumerWidget {
  const KasKitaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      home: const FoundationWorkspaceScreen(),
    );
  }
}
