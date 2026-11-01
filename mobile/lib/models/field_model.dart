import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';

/// Predefined rice-producing locations in the Philippines with agro-weather coordinates.
class RiceLocation {
  final String municipality;
  final String province;
  final double latitude;
  final double longitude;

  const RiceLocation({
    required this.municipality,
    required this.province,
    required this.latitude,
    required this.longitude,
  });

  String get displayName => '$municipality, $province';

  static const List<RiceLocation> commonLocations = [
    RiceLocation(municipality: 'Ubay', province: 'Bohol', latitude: 10.3157, longitude: 123.8854),
    RiceLocation(municipality: 'Science City of Muñoz', province: 'Nueva Ecija', latitude: 15.7167, longitude: 120.9000),
    RiceLocation(municipality: 'San Mateo', province: 'Isabela', latitude: 16.8833, longitude: 121.5833),
    RiceLocation(municipality: 'Pototan', province: 'Iloilo', latitude: 10.9500, longitude: 122.6333),
    RiceLocation(municipality: 'Valencia', province: 'Bukidnon', latitude: 7.9000, longitude: 125.0833),
    RiceLocation(municipality: 'Koronadal', province: 'South Cotabato', latitude: 6.5000, longitude: 124.8500),
    RiceLocation(municipality: 'Ligao', province: 'Albay', latitude: 13.2411, longitude: 123.5381),
    RiceLocation(municipality: 'Naujan', province: 'Oriental Mindoro', latitude: 13.3228, longitude: 121.3039),
    RiceLocation(municipality: 'Baybay', province: 'Leyte', latitude: 10.6769, longitude: 124.7986),
    RiceLocation(municipality: 'Midsayap', province: 'Cotabato', latitude: 7.1917, longitude: 124.5306),
  ];
}

/// Predefined Philippine rice varieties (PhilRice / NSIC catalog).
class RiceVariety {
  final String code;
  final String popularName;
  final int daysToMaturity;
  final String ecosystem; // Inbred, Hybrid, Rainfed

  const RiceVariety({
    required this.code,
    required this.popularName,
    required this.daysToMaturity,
    required this.ecosystem,
  });

  String get displayName => '$code ($popularName) · $daysToMaturity days';

  static const List<RiceVariety> commonVarieties = [
    RiceVariety(code: 'NSIC Rc 222', popularName: 'Tubigan 21', daysToMaturity: 110, ecosystem: 'Irrigated Lowland Inbred'),
    RiceVariety(code: 'NSIC Rc 160', popularName: 'Tubigan 14', daysToMaturity: 107, ecosystem: 'Premium Inbred'),
    RiceVariety(code: 'NSIC Rc 440', popularName: 'Tubigan 39', daysToMaturity: 112, ecosystem: 'Disease-Tolerant Inbred'),
    RiceVariety(code: 'NSIC Rc 216', popularName: 'Tubigan 17', daysToMaturity: 112, ecosystem: 'High Yield Inbred'),
    RiceVariety(code: 'PSB Rc 10', popularName: 'Pagsanjan', daysToMaturity: 106, ecosystem: 'Early-Maturing Inbred'),
    RiceVariety(code: 'NSIC Rc 192', popularName: 'Sahod Ulan 1', daysToMaturity: 105, ecosystem: 'Rainfed Lowland'),
    RiceVariety(code: 'IR64', popularName: 'IR64 Traditional', daysToMaturity: 115, ecosystem: 'Traditional Inbred'),
    RiceVariety(code: 'Mestiso 20', popularName: 'M20 Hybrid', daysToMaturity: 110, ecosystem: 'Hybrid Rice'),
  ];
}

/// Farmer's field profile model.
class FieldProfile {
  final String fieldName;
  final String municipality;
  final String province;
  final double latitude;
  final double longitude;
  final DateTime plantingDate;
  final String varietyName;
  final int daysToMaturity;
  final double fieldAreaHa;

  const FieldProfile({
    this.fieldName = 'Main Paddy',
    this.municipality = 'Ubay',
    this.province = 'Bohol',
    this.latitude = 10.3157,
    this.longitude = 123.8854,
    required this.plantingDate,
    this.varietyName = 'NSIC Rc 222 (Tubigan 21)',
    this.daysToMaturity = 110,
    this.fieldAreaHa = 1.0,
  });

  /// Default profile initialized to day 42 of 110 (Active Vegetative).
  factory FieldProfile.defaultProfile() {
    return FieldProfile(
      plantingDate: DateTime.now().subtract(const Duration(days: 42)),
    );
  }

  String get locationDisplay => '$municipality, $province';

  /// Current day in the cropping cycle (1 to daysToMaturity).
  int get currentDay {
    final diff = DateTime.now().difference(plantingDate).inDays;
    return diff.clamp(1, daysToMaturity);
  }

  /// Completion percentage from 0.0 to 1.0.
  double get progressPercent => (currentDay / daysToMaturity).clamp(0.0, 1.0);

  /// Expected harvest date.
  DateTime get harvestDate => plantingDate.add(Duration(days: daysToMaturity));

  /// Days remaining until harvest.
  int get daysUntilHarvest {
    final remaining = daysToMaturity - currentDay;
    return remaining.clamp(0, daysToMaturity);
  }

  /// Categorical growth stage identifier.
  String get growthStageKey {
    if (currentDay <= 14) return 'seedbed';
    if (currentDay <= 50) return 'vegetative';
    if (currentDay <= 85) return 'reproductive';
    return 'ripening';
  }

  /// Localized growth stage title.
  String stageName(BuildContext context) {
    final s = AppStrings.of(context);
    switch (growthStageKey) {
      case 'seedbed':
        return s.calPhaseNursery;
      case 'vegetative':
        return s.calPhaseVeg;
      case 'reproductive':
        return s.calPhaseRep;
      case 'ripening':
        return s.calPhaseMat;
      default:
        return s.calPhaseVeg;
    }
  }

  FieldProfile copyWith({
    String? fieldName,
    String? municipality,
    String? province,
    double? latitude,
    double? longitude,
    DateTime? plantingDate,
    String? varietyName,
    int? daysToMaturity,
    double? fieldAreaHa,
  }) {
    return FieldProfile(
      fieldName: fieldName ?? this.fieldName,
      municipality: municipality ?? this.municipality,
      province: province ?? this.province,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      plantingDate: plantingDate ?? this.plantingDate,
      varietyName: varietyName ?? this.varietyName,
      daysToMaturity: daysToMaturity ?? this.daysToMaturity,
      fieldAreaHa: fieldAreaHa ?? this.fieldAreaHa,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fieldName': fieldName,
      'municipality': municipality,
      'province': province,
      'latitude': latitude,
      'longitude': longitude,
      'plantingDate': plantingDate.toIso8601String(),
      'varietyName': varietyName,
      'daysToMaturity': daysToMaturity,
      'fieldAreaHa': fieldAreaHa,
    };
  }

  factory FieldProfile.fromJson(Map<String, dynamic> json) {
    return FieldProfile(
      fieldName: json['fieldName'] ?? 'Main Paddy',
      municipality: json['municipality'] ?? 'Ubay',
      province: json['province'] ?? 'Bohol',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 10.3157,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 123.8854,
      plantingDate: json['plantingDate'] != null
          ? DateTime.tryParse(json['plantingDate']) ?? DateTime.now().subtract(const Duration(days: 42))
          : DateTime.now().subtract(const Duration(days: 42)),
      varietyName: json['varietyName'] ?? 'NSIC Rc 222 (Tubigan 21)',
      daysToMaturity: (json['daysToMaturity'] as num?)?.toInt() ?? 110,
      fieldAreaHa: (json['fieldAreaHa'] as num?)?.toDouble() ?? 1.0,
    );
  }
}
