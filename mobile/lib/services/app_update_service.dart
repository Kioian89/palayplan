import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class AppUpdateInfo {
  const AppUpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.downloadUrl,
    this.releaseNotes,
  });

  final String currentVersion;
  final String latestVersion;
  final Uri downloadUrl;
  final String? releaseNotes;

  bool get isUpdateAvailable =>
      _compareVersions(latestVersion, currentVersion) > 0;
}

class AppUpdateException implements Exception {
  const AppUpdateException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AppUpdateService {
  AppUpdateService({
    http.Client? client,
    Future<String> Function()? installedVersion,
    Uri? releaseApiUrl,
  })  : _client = client ?? http.Client(),
        _installedVersion = installedVersion ?? _readInstalledVersion,
        _releaseApiUrl = releaseApiUrl ??
            Uri.parse(
              'https://api.github.com/repos/Kioian89/palayplan/releases/latest',
            );

  final http.Client _client;
  final Future<String> Function() _installedVersion;
  final Uri _releaseApiUrl;

  void close() {
    _client.close();
  }

  Future<AppUpdateInfo> checkForUpdate() async {
    final response = await _client.get(
      _releaseApiUrl,
      headers: const {'Accept': 'application/vnd.github+json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw AppUpdateException(
        'Could not check for app updates (HTTP ${response.statusCode}).',
      );
    }

    final payload = jsonDecode(response.body);
    if (payload is! Map<String, dynamic>) {
      throw const FormatException('The latest release response is invalid.');
    }

    final tagName = payload['tag_name'];
    final releaseUrl = payload['html_url'];
    if (tagName is! String || releaseUrl is! String) {
      throw const FormatException(
          'The latest release is missing its version or URL.');
    }

    final assets = payload['assets'];
    Map<String, dynamic>? apkAsset;
    if (assets is List) {
      for (final asset in assets.whereType<Map<String, dynamic>>()) {
        final name = asset['name'];
        if (name is String && name.toLowerCase().endsWith('.apk')) {
          apkAsset = asset;
          break;
        }
      }
    }
    final apkUrl = apkAsset?['browser_download_url'];
    final downloadUrl =
        apkUrl is String ? Uri.tryParse(apkUrl) : Uri.tryParse(releaseUrl);
    if (downloadUrl == null ||
        downloadUrl.scheme != 'https' ||
        downloadUrl.host != 'github.com') {
      throw const FormatException('The latest release URL is invalid.');
    }

    return AppUpdateInfo(
      currentVersion: await _installedVersion(),
      latestVersion: _normalizedVersion(tagName),
      downloadUrl: downloadUrl,
      releaseNotes:
          payload['body'] is String ? payload['body'] as String : null,
    );
  }

  static Future<String> _readInstalledVersion() async =>
      (await PackageInfo.fromPlatform()).version;
}

String _normalizedVersion(String version) =>
    version.trim().replaceFirst(RegExp(r'^[vV]'), '');

int _compareVersions(String first, String second) {
  final firstParts = _versionParts(first);
  final secondParts = _versionParts(second);
  for (var index = 0; index < 3; index++) {
    final comparison = firstParts[index].compareTo(secondParts[index]);
    if (comparison != 0) return comparison;
  }
  return 0;
}

List<int> _versionParts(String version) {
  final match = RegExp(r'^(\d+)\.(\d+)\.(\d+)(?:[-+].*)?$')
      .firstMatch(_normalizedVersion(version));
  if (match == null) {
    throw FormatException('Invalid app version: $version');
  }
  return [
    int.parse(match.group(1)!),
    int.parse(match.group(2)!),
    int.parse(match.group(3)!),
  ];
}
