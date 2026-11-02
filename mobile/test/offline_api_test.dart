import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:palayplan/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('forecast loads online and is available from cache offline', () async {
    final responseBody = jsonEncode({
      'municipality': 'Ubay, Bohol',
      'latitude': 10.1,
      'longitude': 124.0,
      'daily_forecast': [
        {
          'forecast_date': '2026-11-01',
          'rain_probability_pct': 20,
          'temperature_c': 29,
          'humidity_pct': 70,
          'wind_speed_kph': 8,
        },
      ],
    });
    final online = ApiService(
      client: MockClient((_) async => http.Response(responseBody, 200)),
    );

    final liveForecast = await online.getForecast(
      municipality: 'Ubay, Bohol',
      lat: 10.1,
      lon: 124.0,
    );
    expect(liveForecast.dailyForecast, hasLength(1));
    expect(online.lastResponseWasCached, isFalse);
    online.close();

    final offline = ApiService(
      client: MockClient((_) async => throw const SocketException('offline')),
    );
    final cachedForecast = await offline.getForecast(
      municipality: 'Ubay, Bohol',
      lat: 10.1,
      lon: 124.0,
    );

    expect(cachedForecast.dailyForecast, hasLength(1));
    expect(offline.lastResponseWasCached, isTrue);
    expect(offline.lastResponseAt, isNotNull);
    offline.close();
  });

  test('advisories load online and an empty response is cached offline',
      () async {
    final online = ApiService(
      client: MockClient((_) async => http.Response('[]', 200)),
    );
    final startDate = DateTime(2026, 10, 15);

    expect(
      await online.getAdvisories(
        municipality: 'Ubay',
        lat: 10.1,
        lon: 124.0,
        startDate: startDate,
        daysToMaturity: 110,
      ),
      isEmpty,
    );
    online.close();

    final offline = ApiService(
      client: MockClient((_) async => throw const SocketException('offline')),
    );
    expect(
      await offline.getAdvisories(
        municipality: 'Ubay',
        lat: 10.1,
        lon: 124.0,
        startDate: startDate,
        daysToMaturity: 110,
      ),
      isEmpty,
    );
    expect(offline.lastResponseWasCached, isTrue);
    offline.close();
  });

  test('offline requests without cached data fail instead of inventing results',
      () async {
    final offline = ApiService(
      client: MockClient((_) async => throw const SocketException('offline')),
    );

    await expectLater(
      offline.getForecast(
        municipality: 'Ubay, Bohol',
        lat: 10.1,
        lon: 124.0,
      ),
      throwsA(isA<SocketException>()),
    );
    offline.close();
  });
}
