import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/errors/app_exception.dart';
import '../models/settings_models.dart';

/// Layanan Keamanan Aplikasi (PIN 6 Digit di FlutterSecureStorage & Biometrik)
/// serta persistensi preferensi Tema, Bahasa, & Pengingat di SQLite `app_settings`.
class AppSecurityService {
  AppSecurityService(
    this._dbHelper, {
    FlutterSecureStorage? secureStorage,
    LocalAuthentication? localAuth,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _localAuth = localAuth ?? LocalAuthentication();

  final DatabaseHelper _dbHelper;
  final FlutterSecureStorage _secureStorage;
  final LocalAuthentication _localAuth;

  static const String _keyDueReminderEnabled = 'due_reminders_enabled';

  Future<AppSecurityConfigModel> getSecurityConfig() async {
    final Database db = await _dbHelper.database;
    final List<Map<String, Object?>> rows = await db.query('app_settings');
    final Map<String, String> settings = <String, String>{};
    for (final Map<String, Object?> r in rows) {
      final String? k = r['setting_key'] as String?;
      final String? v = r['setting_value'] as String?;
      if (k != null && v != null) {
        settings[k] = v;
      }
    }

    String? savedPin;
    try {
      savedPin = await _secureStorage.read(key: AppConstants.secureKeyAppPin);
    } catch (_) {
      savedPin = settings['fallback_app_pin'];
    }

    final bool lockEnabled = settings[AppConstants.keyAppLockEnabled] == '1';
    final bool reminderEnabled = settings[_keyDueReminderEnabled] != '0';
    return AppSecurityConfigModel(
      appLockEnabled: lockEnabled && (savedPin != null && savedPin.length == 6),
      hasPinConfigured: savedPin != null && savedPin.length == 6,
      dueRemindersEnabled: reminderEnabled,
    );
  }

  Future<void> saveAppPin(String pin) async {
    if (pin.length != 6 || int.tryParse(pin) == null) {
      throw const AppException(AppErrorCode.pinInvalid);
    }
    try {
      await _secureStorage.write(key: AppConstants.secureKeyAppPin, value: pin);
    } catch (_) {
      // Fallback aman untuk lingkungan desktop/test tanpa keystore OS
      await _setSetting('fallback_app_pin', pin);
    }
    await _setSetting(AppConstants.keyAppLockEnabled, '1');
  }

  Future<bool> verifyPin(String pin) async {
    String? savedPin;
    try {
      savedPin = await _secureStorage.read(key: AppConstants.secureKeyAppPin);
    } catch (_) {
      savedPin = await _getSetting('fallback_app_pin');
    }
    if (savedPin == null || savedPin != pin) {
      throw const AppException(AppErrorCode.pinInvalid);
    }
    return true;
  }

  Future<void> disableAppLock() async {
    await _setSetting(AppConstants.keyAppLockEnabled, '0');
  }

  Future<void> setDueRemindersEnabled(bool enabled) async {
    await _setSetting(_keyDueReminderEnabled, enabled ? '1' : '0');
  }

  Future<bool> canCheckBiometrics() async {
    try {
      final bool isSupported = await _localAuth.isDeviceSupported();
      final bool canCheck = await _localAuth.canCheckBiometrics;
      return isSupported || canCheck;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics({required String reason}) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
      );
    } catch (_) {
      return false;
    }
  }

  Future<ThemeMode> loadSavedThemeMode() async {
    final String? val = await _getSetting(AppConstants.keyThemeMode);
    switch (val) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final String str = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _setSetting(AppConstants.keyThemeMode, str);
  }

  Future<Locale> loadSavedLocale() async {
    final String? val = await _getSetting(AppConstants.keyAppLocale);
    if (val == 'en') {
      return const Locale('en');
    }
    return const Locale('id');
  }

  Future<void> saveLocale(Locale locale) async {
    await _setSetting(AppConstants.keyAppLocale, locale.languageCode);
  }

  Future<String?> _getSetting(String key) async {
    final Database db = await _dbHelper.database;
    final List<Map<String, Object?>> rows = await db.query(
      'app_settings',
      where: 'setting_key = ?',
      whereArgs: <Object>[key],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return rows.first['setting_value'] as String?;
  }

  Future<void> _setSetting(String key, String value) async {
    final Database db = await _dbHelper.database;
    await db.insert(
      'app_settings',
      <String, Object?>{
        'setting_key': key,
        'setting_value': value,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

