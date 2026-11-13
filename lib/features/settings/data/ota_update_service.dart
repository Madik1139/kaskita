import 'dart:convert';
import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../models/settings_models.dart';

/// Layanan Cek Pembaruan Aplikasi Otomatis (OTA) via GitHub Releases API.
class OtaUpdateService {
  const OtaUpdateService();

  Future<String> getInstalledVersion() async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      if (info.version.isNotEmpty) {
        return info.version;
      }
    } catch (_) {}
    return AppConstants.appVersion;
  }

  Future<OtaReleaseCheckResult> checkLatestRelease() async {
    final String currentVersion = await getInstalledVersion();
    final HttpClient client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);

    try {
      final HttpClientRequest request =
          await client.getUrl(Uri.parse(AppConstants.githubLatestReleaseApi));
      request.headers.set(HttpHeaders.acceptHeader, 'application/vnd.github+json');
      request.headers.set(HttpHeaders.userAgentHeader, 'KasKita-App');

      final HttpClientResponse response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        throw const AppException(AppErrorCode.otaCheckFailed);
      }

      final String rawBody = await response.transform(utf8.decoder).join();
      final Map<String, dynamic> data =
          jsonDecode(rawBody) as Map<String, dynamic>;

      final String tagName = (data['tag_name'] as String?) ?? currentVersion;
      final String releaseUrl =
          (data['html_url'] as String?) ?? AppConstants.githubReleasesWebUrl;
      final String bodyNotes = (data['body'] as String?) ?? '';

      String? apkDownloadUrl;
      final dynamic assets = data['assets'];
      if (assets is List<dynamic>) {
        for (final dynamic asset in assets) {
          if (asset is Map<String, dynamic>) {
            final String name = (asset['name'] as String?) ?? '';
            if (name.toLowerCase().endsWith('.apk')) {
              apkDownloadUrl = asset['browser_download_url'] as String?;
              break;
            }
          }
        }
      }

      final bool hasUpdate =
          OtaReleaseCheckResult.isNewerVersion(tagName, currentVersion);

      return OtaReleaseCheckResult(
        currentVersion: currentVersion,
        latestVersion: tagName,
        releaseUrl: releaseUrl,
        hasUpdate: hasUpdate,
        downloadUrl: apkDownloadUrl ?? releaseUrl,
        releaseNotes: bodyNotes,
      );
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException(AppErrorCode.otaCheckFailed);
    } finally {
      client.close(force: true);
    }
  }

  Future<void> openReleaseUrl(String url) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

