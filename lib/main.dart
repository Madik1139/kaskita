import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/errors/app_exception.dart';
import 'l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Global Error Boundary agar tidak pernah menampilkan Red Screen of Death di produksi
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    return true;
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    final String sysLang =
        PlatformDispatcher.instance.locale.languageCode;
    final AppLocalizations l10n = AppException.fallbackL10n(sysLang);
    final String localizedError =
        AppException.resolveError(details.exception, l10n);

    return Material(
      color: const Color(0xFFF7F6F2),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE4E2DD)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  l10n.errUnexpectedUiTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF141518),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  localizedError,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF686B73),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  };

  runApp(
    const ProviderScope(
      child: KasKitaApp(),
    ),
  );
}
