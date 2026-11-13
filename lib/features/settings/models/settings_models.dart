import 'package:equatable/equatable.dart';

class AppSecurityConfigModel extends Equatable {
  const AppSecurityConfigModel({
    required this.appLockEnabled,
    required this.hasPinConfigured,
    required this.dueRemindersEnabled,
  });

  final bool appLockEnabled;
  final bool hasPinConfigured;
  final bool dueRemindersEnabled;

  @override
  List<Object?> get props => <Object?>[
        appLockEnabled,
        hasPinConfigured,
        dueRemindersEnabled,
      ];
}

class OtaReleaseCheckResult extends Equatable {
  const OtaReleaseCheckResult({
    required this.currentVersion,
    required this.latestVersion,
    required this.releaseUrl,
    required this.hasUpdate,
    this.downloadUrl,
    this.releaseNotes = '',
  });

  final String currentVersion;
  final String latestVersion;
  final String releaseUrl;
  final bool hasUpdate;
  final String? downloadUrl;
  final String releaseNotes;

  /// Membandingkan dua string versi semantik (`v0.6.0+6` vs `0.5.0`).
  static bool isNewerVersion(String latestRaw, String currentRaw) {
    final List<int> latest = _parseVersionTuple(latestRaw);
    final List<int> current = _parseVersionTuple(currentRaw);
    for (int i = 0; i < 3; i++) {
      if (latest[i] > current[i]) {
        return true;
      }
      if (latest[i] < current[i]) {
        return false;
      }
    }
    return false;
  }

  static List<int> _parseVersionTuple(String raw) {
    final String cleaned =
        raw.trim().replaceFirst(RegExp(r'^[vV]'), '').split('+').first;
    final List<String> parts = cleaned.split('.');
    return List<int>.generate(3, (int i) {
      if (i >= parts.length) {
        return 0;
      }
      return int.tryParse(parts[i].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    });
  }

  @override
  List<Object?> get props => <Object?>[
        currentVersion,
        latestVersion,
        releaseUrl,
        hasUpdate,
        downloadUrl,
        releaseNotes,
      ];
}

