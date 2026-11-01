class DailyForecast {
  final DateTime date;
  final double rainProbabilityPct;
  final double temperatureC;
  final double humidityPct;
  final double windSpeedKph;

  DailyForecast({
    required this.date,
    required this.rainProbabilityPct,
    required this.temperatureC,
    required this.humidityPct,
    required this.windSpeedKph,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: DateTime.parse(json['forecast_date']),
      rainProbabilityPct: (json['rain_probability_pct'] as num).toDouble(),
      temperatureC: (json['temperature_c'] as num).toDouble(),
      humidityPct: (json['humidity_pct'] as num).toDouble(),
      windSpeedKph: (json['wind_speed_kph'] as num).toDouble(),
    );
  }

  /// Simple traffic-light risk classification used by the RiskStatusCard.
  String get riskLevel {
    if (rainProbabilityPct >= 60 || humidityPct >= 85) return 'high';
    if (rainProbabilityPct >= 30 || humidityPct >= 70) return 'medium';
    return 'low';
  }
}

class WeatherForecast {
  final String municipality;
  final List<DailyForecast> dailyForecast;

  WeatherForecast({required this.municipality, required this.dailyForecast});

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      municipality: json['municipality'],
      dailyForecast: (json['daily_forecast'] as List)
          .map((d) => DailyForecast.fromJson(d))
          .toList(),
    );
  }
}

class Advisory {
  final String stage;
  final DateTime date;
  final String message;
  final String severity; // info | warning | critical

  Advisory({
    required this.stage,
    required this.date,
    required this.message,
    required this.severity,
  });

  factory Advisory.fromJson(Map<String, dynamic> json) {
    return Advisory(
      stage: json['stage'],
      date: DateTime.parse(json['date']),
      message: json['message'],
      severity: json['severity'],
    );
  }
}
