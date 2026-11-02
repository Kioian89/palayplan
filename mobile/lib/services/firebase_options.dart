import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseClientOptions {
  static const _projectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'palay-plan',
  );
  static const _senderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '1057325937104',
  );
  static const _androidApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY_ANDROID',
    defaultValue: 'AIzaSyAfuT-RUmzDt4FhAMtLTNadUysXO1s9gqM',
  );
  static const _androidAppId = String.fromEnvironment(
    'FIREBASE_APP_ID_ANDROID',
    defaultValue: '1:1057325937104:android:2fbdf7819e124042a109d5',
  );
  static const _iosApiKey = String.fromEnvironment('FIREBASE_API_KEY_IOS');
  static const _iosAppId = String.fromEnvironment('FIREBASE_APP_ID_IOS');
  static const _iosBundleId = String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID');
  static const _webApiKey = String.fromEnvironment('FIREBASE_API_KEY_WEB');
  static const _webAppId = String.fromEnvironment('FIREBASE_APP_ID_WEB');
  static const _webAuthDomain = String.fromEnvironment(
    'FIREBASE_AUTH_DOMAIN_WEB',
  );
  static const googleWebClientId = String.fromEnvironment(
    'GOOGLE_SIGN_IN_WEB_CLIENT_ID',
    defaultValue:
        '1057325937104-m4ad0sbd51doou911ac35rnqarhgnqtd.apps.googleusercontent.com',
  );

  static FirebaseOptions? get current {
    if (_projectId.isEmpty || _senderId.isEmpty) return null;

    if (kIsWeb) {
      if (_webApiKey.isEmpty || _webAppId.isEmpty || _webAuthDomain.isEmpty) {
        return null;
      }
      return const FirebaseOptions(
        apiKey: _webApiKey,
        appId: _webAppId,
        messagingSenderId: _senderId,
        projectId: _projectId,
        authDomain: _webAuthDomain,
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        if (_androidApiKey.isEmpty || _androidAppId.isEmpty) return null;
        return const FirebaseOptions(
          apiKey: _androidApiKey,
          appId: _androidAppId,
          messagingSenderId: _senderId,
          projectId: _projectId,
        );
      case TargetPlatform.iOS:
        if (_iosApiKey.isEmpty || _iosAppId.isEmpty || _iosBundleId.isEmpty) {
          return null;
        }
        return const FirebaseOptions(
          apiKey: _iosApiKey,
          appId: _iosAppId,
          messagingSenderId: _senderId,
          projectId: _projectId,
          iosBundleId: _iosBundleId,
        );
      default:
        return null;
    }
  }
}
