import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:palayplan/services/app_update_service.dart';

void main() {
  test('finds a newer release APK and compares semantic versions', () async {
    final service = AppUpdateService(
      client: MockClient((request) async {
        expect(request.url.path, '/repos/Kioian89/palayplan/releases/latest');
        return http.Response(
          jsonEncode({
            'tag_name': 'v0.2.0',
            'html_url':
                'https://github.com/Kioian89/palayplan/releases/tag/v0.2.0',
            'body': 'Bug fixes',
            'assets': [
              {
                'name': 'palayplan.apk',
                'browser_download_url':
                    'https://github.com/Kioian89/palayplan/releases/download/v0.2.0/palayplan.apk',
              },
            ],
          }),
          200,
        );
      }),
      installedVersion: () async => '0.1.0',
    );

    final update = await service.checkForUpdate();

    expect(update.currentVersion, '0.1.0');
    expect(update.latestVersion, '0.2.0');
    expect(update.isUpdateAvailable, isTrue);
    expect(update.downloadUrl.path, endsWith('/palayplan.apk'));
    service.close();
  });

  test('does not offer an update when versions match', () async {
    final service = AppUpdateService(
      client: MockClient((_) async {
        return http.Response(
          jsonEncode({
            'tag_name': 'v0.1.0',
            'html_url':
                'https://github.com/Kioian89/palayplan/releases/tag/v0.1.0',
            'assets': [],
          }),
          200,
        );
      }),
      installedVersion: () async => '0.1.0+2',
    );

    final update = await service.checkForUpdate();

    expect(update.isUpdateAvailable, isFalse);
    expect(update.downloadUrl.path, endsWith('v0.1.0'));
    service.close();
  });

  test('reports GitHub API errors instead of treating them as current',
      () async {
    final service = AppUpdateService(
      client: MockClient((_) async => http.Response('Not found', 404)),
      installedVersion: () async => '0.1.0',
    );

    await expectLater(
      service.checkForUpdate(),
      throwsA(isA<AppUpdateException>()),
    );
    service.close();
  });
}
