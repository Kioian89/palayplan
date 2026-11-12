import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import 'api_cache.dart';

/// Central place for all backend calls. Swap [baseUrl] per environment
/// (local emulator, staging, production) via --dart-define or a config file.
class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static const _requestTimeout = Duration(seconds: 12);

  final http.Client _client;
  bool _lastResponseWasCached = false;
  DateTime? _lastResponseAt;

  bool get lastResponseWasCached => _lastResponseWasCached;
  DateTime? get lastResponseAt => _lastResponseAt;

  void close() => _client.close();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://palayplan-1.onrender.com',
  );

  Future<WeatherForecast> getForecast({
    required String municipality,
    required double lat,
    required double lon,
  }) async {
    final uri =
        Uri.parse('$baseUrl/weather/forecast').replace(queryParameters: {
      'municipality': municipality,
      'lat': lat.toString(),
      'lon': lon.toString(),
    });
    final cacheKey = _cacheKey('forecast', [municipality, lat, lon]);
    try {
      final response = await _client.get(uri).timeout(_requestTimeout);
      if (response.statusCode != 200) {
        throw _ApiRequestException(
          'Failed to load forecast: HTTP ${response.statusCode}',
        );
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final forecast = WeatherForecast.fromJson(data);
      _markNetworkResponse();
      await _saveCache(cacheKey, data);
      return forecast;
    } catch (error) {
      if (!_isRecoverable(error)) rethrow;
      final cached = await ApiCache.read(cacheKey);
      if (cached == null || cached.data is! Map<String, dynamic>) rethrow;
      _markCachedResponse(cached.savedAt);
      return WeatherForecast.fromJson(cached.data as Map<String, dynamic>);
    }
  }

  Future<List<Advisory>> getAdvisories({
    required String municipality,
    required double lat,
    required double lon,
    required DateTime startDate,
    required int daysToMaturity,
  }) async {
    final uri = Uri.parse('$baseUrl/advisory/').replace(queryParameters: {
      'municipality': municipality,
      'lat': lat.toString(),
      'lon': lon.toString(),
      'start_date': startDate.toIso8601String().split('T').first,
      'days_to_maturity': daysToMaturity.toString(),
    });
    final cacheKey = _cacheKey('advisories', [
      municipality,
      lat,
      lon,
      startDate.toIso8601String().split('T').first,
      daysToMaturity,
    ]);
    try {
      final response = await _client.get(uri).timeout(_requestTimeout);
      if (response.statusCode != 200) {
        throw _ApiRequestException(
          'Failed to load advisories: HTTP ${response.statusCode}',
        );
      }
      final data = jsonDecode(response.body) as List<dynamic>;
      final advisories = data
          .map((item) => Advisory.fromJson(item as Map<String, dynamic>))
          .toList();
      _markNetworkResponse();
      await _saveCache(cacheKey, data);
      return advisories;
    } catch (error) {
      if (!_isRecoverable(error)) rethrow;
      final cached = await ApiCache.read(cacheKey);
      if (cached == null || cached.data is! List<dynamic>) rethrow;
      _markCachedResponse(cached.savedAt);
      return (cached.data as List<dynamic>)
          .map((item) => Advisory.fromJson(item as Map<String, dynamic>))
          .toList();
    }
  }

  Future<Map<String, dynamic>> predictYield({
    required String seedVariety,
    required int daysToMaturity,
    required double fieldSizeHectares,
    required DateTime startDate,
    required String municipality,
    required double lat,
    required double lon,
    String? soilType,
    String? ecosystemType,
  }) async {
    final uri = Uri.parse('$baseUrl/predict/yield').replace(queryParameters: {
      'lat': lat.toString(),
      'lon': lon.toString(),
    });
    final payload = <String, dynamic>{
      'seed_variety': seedVariety,
      'days_to_maturity': daysToMaturity,
      'field_size_hectares': fieldSizeHectares,
      'start_date': startDate.toIso8601String().split('T').first,
      'municipality': municipality,
      'soil_type': soilType,
    };
    if (ecosystemType != null && ecosystemType.isNotEmpty) {
      payload['ecosystem_type'] = ecosystemType;
    }
    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        )
        .timeout(_requestTimeout);
    if (response.statusCode != 200) {
      throw Exception('Prediction failed: ${response.body}');
    }
    return jsonDecode(response.body);
  }

  String _cacheKey(String category, List<Object> dimensions) =>
      '${category}_${Uri.encodeComponent(dimensions.join('|'))}';

  bool _isRecoverable(Object error) =>
      error is http.ClientException ||
      error is SocketException ||
      error is TimeoutException ||
      error is FormatException ||
      error is _ApiRequestException;

  void _markNetworkResponse() {
    _lastResponseWasCached = false;
    _lastResponseAt = DateTime.now();
  }

  void _markCachedResponse(DateTime savedAt) {
    _lastResponseWasCached = true;
    _lastResponseAt = savedAt;
  }

  Future<void> _saveCache(String key, Object data) async {
    try {
      await ApiCache.write(key, data);
    } catch (error) {
      debugPrint('Could not save offline API data: $error');
    }
  }
}

class _ApiRequestException implements Exception {
  const _ApiRequestException(this.message);

  final String message;

  @override
  String toString() => message;
}
