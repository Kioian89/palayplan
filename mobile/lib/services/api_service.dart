import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

/// Central place for all backend calls. Swap [baseUrl] per environment
/// (local emulator, staging, production) via --dart-define or a config file.
class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.5.244:8000', // Android emulator -> localhost
  );

  Future<WeatherForecast> getForecast({
    required String municipality,
    required double lat,
    required double lon,
  }) async {
    final uri = Uri.parse('$baseUrl/weather/forecast').replace(queryParameters: {
      'municipality': municipality,
      'lat': lat.toString(),
      'lon': lon.toString(),
    });
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load forecast: ${response.body}');
    }
    return WeatherForecast.fromJson(jsonDecode(response.body));
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
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load advisories: ${response.body}');
    }
    final List data = jsonDecode(response.body);
    return data.map((e) => Advisory.fromJson(e)).toList();
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
  }) async {
    final uri = Uri.parse('$baseUrl/predict/yield').replace(queryParameters: {
      'lat': lat.toString(),
      'lon': lon.toString(),
    });
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'seed_variety': seedVariety,
        'days_to_maturity': daysToMaturity,
        'field_size_hectares': fieldSizeHectares,
        'start_date': startDate.toIso8601String().split('T').first,
        'municipality': municipality,
        'soil_type': soilType,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Prediction failed: ${response.body}');
    }
    return jsonDecode(response.body);
  }
}
