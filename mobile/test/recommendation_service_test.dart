import 'package:flutter_test/flutter_test.dart';
import 'package:palayplan/models/field_model.dart';
import 'package:palayplan/models/weather_model.dart';
import 'package:palayplan/providers/language_provider.dart';
import 'package:palayplan/services/recommendation_service.dart';

void main() {
  group('RecommendationService PhilRice PalayCheck Logic', () {
    test('Phase 1 (Day 1-14): Seedbed recommendations and rain risk pause', () {
      final profile = FieldProfile(
        plantingDate: DateTime.now().subtract(const Duration(days: 8)),
        daysToMaturity: 110,
      );

      // Rain forecast with 65% probability
      final rainyForecast = WeatherForecast(
        municipality: 'Ubay, Bohol',
        dailyForecast: [
          DailyForecast(
            date: DateTime.now(),
            rainProbabilityPct: 65.0,
            temperatureC: 28.0,
            humidityPct: 82.0,
            windSpeedKph: 12.0,
          ),
        ],
      );

      final rec = RecommendationService.generate(
        profile: profile,
        lang: AppLanguage.english,
        forecast: rainyForecast,
      );

      expect(rec.currentDay, 8);
      expect(rec.stageName, contains('Seedbed'));
      expect(rec.delayFertilizer, isTrue);
      expect(rec.fertilizerDetail, contains('Pause'));
      expect(rec.waterTitle, contains('2-3 cm'));
      expect(rec.pestTitle, contains('Snail'));
    });

    test('Phase 2 (Day 15-45): Vegetative AWD cycling and clear weather Urea topdress', () {
      final profile = FieldProfile(
        plantingDate: DateTime.now().subtract(const Duration(days: 30)),
        daysToMaturity: 110,
      );

      // Clear weather forecast (15% rain)
      final sunnyForecast = WeatherForecast(
        municipality: 'Ubay, Bohol',
        dailyForecast: [
          DailyForecast(
            date: DateTime.now(),
            rainProbabilityPct: 15.0,
            temperatureC: 30.0,
            humidityPct: 70.0,
            windSpeedKph: 8.0,
          ),
        ],
      );

      final rec = RecommendationService.generate(
        profile: profile,
        lang: AppLanguage.filipino,
        forecast: sunnyForecast,
      );

      expect(rec.currentDay, 30);
      expect(rec.delayFertilizer, isFalse);
      expect(rec.waterTitle, contains('AWD'));
      expect(rec.fertilizerTitle, contains('Urea'));
    });

    test('Phase 3 (Day 46-90): Reproductive panicle initiation and Potash recommendation', () {
      final profile = FieldProfile(
        plantingDate: DateTime.now().subtract(const Duration(days: 60)),
        daysToMaturity: 110,
      );

      final rec = RecommendationService.generate(
        profile: profile,
        lang: AppLanguage.bisaya,
      );

      expect(rec.currentDay, 60);
      expect(rec.fertilizerTitle, contains('Potash'));
      expect(rec.waterTitle, contains('Padayon'));
    });

    test('Phase 4 (Near Maturity): Terminal drainage and harvest window', () {
      final profile = FieldProfile(
        plantingDate: DateTime.now().subtract(const Duration(days: 102)),
        daysToMaturity: 110,
      );

      final rec = RecommendationService.generate(
        profile: profile,
        lang: AppLanguage.english,
      );

      expect(rec.currentDay, 102);
      expect(rec.fertilizerTitle, contains('No Chemical'));
      expect(rec.waterTitle, contains('Terminal Drainage'));
      expect(rec.pestTitle, contains('Harvest'));
    });
  });
}
