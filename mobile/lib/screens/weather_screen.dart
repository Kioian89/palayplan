import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import '../services/api_service.dart';
import '../providers/field_provider.dart';
import '../widgets/edit_field_sheet.dart';
import '../widgets/offline_data_notice.dart';
import '../l10n/app_strings.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final ApiService _api = ApiService();
  WeatherForecast? _forecast;
  String? _error;
  bool _usingCachedData = false;
  DateTime? _dataSavedAt;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final field = FieldProvider.fieldOf(context);
    try {
      final forecast = await _api.getForecast(
        municipality: field.locationDisplay,
        lat: field.latitude,
        lon: field.longitude,
      );
      if (mounted) {
        setState(() {
          _forecast = forecast;
          _usingCachedData = _api.lastResponseWasCached;
          _dataSavedAt = _api.lastResponseAt;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (_forecast == null) {
            _error = e.toString();
          } else {
            _usingCachedData = true;
            _error = null;
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.weatherTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on_outlined),
            tooltip: 'Change Field Location',
            onPressed: () => EditFieldSheet.show(context),
          ),
        ],
      ),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_rounded,
                        size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      s.offlineNoCachedData,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _load,
                      child: Text(s.offlineRetry),
                    ),
                  ],
                ),
              ),
            )
          : _forecast == null
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    children: [
                      if (_usingCachedData && _dataSavedAt != null)
                        OfflineDataNotice(savedAt: _dataSavedAt!),
                      // Today Hero Banner
                      if (_forecast!.dailyForecast.isNotEmpty)
                        _TodayWeatherHero(day: _forecast!.dailyForecast.first),

                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 4),
                        child: Text(
                          'Upcoming 7 Days',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1B3B36),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Daily Forecast Cards
                      ..._forecast!.dailyForecast
                          .map((day) => _DailyWeatherCard(day: day)),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }
}

class _TodayWeatherHero extends StatelessWidget {
  final DailyForecast day;

  const _TodayWeatherHero({required this.day});

  @override
  Widget build(BuildContext context) {
    final isRainy = day.rainProbabilityPct >= 50;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isRainy
              ? const [Color(0xFF37474F), Color(0xFF263238)]
              : const [Color(0xFF00695C), Color(0xFF004D40)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: (isRainy ? const Color(0xFF263238) : const Color(0xFF00695C))
                .withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'TODAY ON THE FIELD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              Icon(
                isRainy ? Icons.water_drop_rounded : Icons.wb_sunny_rounded,
                color:
                    isRainy ? const Color(0xFF81D4FA) : const Color(0xFFFFD54F),
                size: 32,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${day.temperatureC.round()}°',
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'C',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.water_drop,
                        size: 16, color: Color(0xFF81D4FA)),
                    const SizedBox(width: 4),
                    Text(
                      '${day.rainProbabilityPct.round()}% Rain',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _HeroStat(
                  label: 'Humidity',
                  value: '${day.humidityPct.round()}%',
                  icon: Icons.waves_rounded),
              _HeroStat(
                  label: 'Wind',
                  value: '${day.windSpeedKph.round()} kph',
                  icon: Icons.air_rounded),
              _HeroStat(
                  label: 'Field Risk',
                  value: day.riskLevel.toUpperCase(),
                  icon: Icons.shield_outlined),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _HeroStat(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white70),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
      ],
    );
  }
}

class _DailyWeatherCard extends StatelessWidget {
  final DailyForecast day;

  const _DailyWeatherCard({required this.day});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE, MMM d').format(day.date);
    final isRainy = day.rainProbabilityPct >= 50;

    final Color badgeColor = day.riskLevel == 'high'
        ? Colors.red
        : day.riskLevel == 'medium'
            ? Colors.orange
            : const Color(0xFF2E7D32);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EBE6), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (isRainy ? Colors.blue : Colors.amber)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isRainy ? Icons.water_drop_rounded : Icons.wb_sunny_rounded,
              color: isRainy ? Colors.blue.shade700 : Colors.amber.shade800,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B3B36),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${day.temperatureC.round()}°C · Humidity ${day.humidityPct.round()}% · Wind ${day.windSpeedKph.round()} kph',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${day.rainProbabilityPct.round()}% rain',
              style: TextStyle(
                color: badgeColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
