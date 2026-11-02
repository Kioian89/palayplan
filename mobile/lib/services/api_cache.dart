import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CachedApiEntry {
  const CachedApiEntry({
    required this.data,
    required this.savedAt,
  });

  final Object data;
  final DateTime savedAt;
}

class ApiCache {
  static const _keyPrefix = 'palayplan_api_cache_';

  static Future<void> write(String key, Object data) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      '$_keyPrefix$key',
      jsonEncode({
        'saved_at': DateTime.now().toUtc().toIso8601String(),
        'data': data,
      }),
    );
  }

  static Future<CachedApiEntry?> read(String key) async {
    final preferences = await SharedPreferences.getInstance();
    final storageKey = '$_keyPrefix$key';
    final encoded = preferences.getString(storageKey);
    if (encoded == null) return null;

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map<String, dynamic> ||
          decoded['data'] == null ||
          decoded['saved_at'] is! String) {
        await preferences.remove(storageKey);
        return null;
      }
      return CachedApiEntry(
        data: decoded['data'] as Object,
        savedAt: DateTime.parse(decoded['saved_at'] as String),
      );
    } on FormatException {
      await preferences.remove(storageKey);
      return null;
    }
  }
}
