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
    RiceLocation(
        municipality: 'Ubay',
        province: 'Bohol',
        latitude: 10.3157,
        longitude: 123.8854),
    RiceLocation(
        municipality: 'Science City of Muñoz',
        province: 'Nueva Ecija',
        latitude: 15.7167,
        longitude: 120.9000),
    RiceLocation(
        municipality: 'San Mateo',
        province: 'Isabela',
        latitude: 16.8833,
        longitude: 121.5833),
    RiceLocation(
        municipality: 'Pototan',
        province: 'Iloilo',
        latitude: 10.9500,
        longitude: 122.6333),
    RiceLocation(
        municipality: 'Valencia',
        province: 'Bukidnon',
        latitude: 7.9000,
        longitude: 125.0833),
    RiceLocation(
        municipality: 'Koronadal',
        province: 'South Cotabato',
        latitude: 6.5000,
        longitude: 124.8500),
    RiceLocation(
        municipality: 'Ligao',
        province: 'Albay',
        latitude: 13.2411,
        longitude: 123.5381),
    RiceLocation(
        municipality: 'Naujan',
        province: 'Oriental Mindoro',
        latitude: 13.3228,
        longitude: 121.3039),
    RiceLocation(
        municipality: 'Baybay',
        province: 'Leyte',
        latitude: 10.6769,
        longitude: 124.7986),
    RiceLocation(
        municipality: 'Midsayap',
        province: 'Cotabato',
        latitude: 7.1917,
        longitude: 124.5306),
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
    // ── Irrigated Lowland Inbreds ─────────────────────────────────────────────
    RiceVariety(
        code: 'NSIC Rc 222',
        popularName: 'Tubigan 21',
        daysToMaturity: 110,
        ecosystem: 'Irrigated Lowland Inbred'),
    RiceVariety(
        code: 'NSIC Rc 160',
        popularName: 'Tubigan 14 (Premium Soft)',
        daysToMaturity: 107,
        ecosystem: 'Premium Inbred'),
    RiceVariety(
        code: 'NSIC Rc 216',
        popularName: 'Tubigan 17',
        daysToMaturity: 112,
        ecosystem: 'High Yield Inbred'),
    RiceVariety(
        code: 'NSIC Rc 440',
        popularName: 'Tubigan 39 (Disease-Tolerant)',
        daysToMaturity: 112,
        ecosystem: 'Disease-Tolerant Inbred'),
    RiceVariety(
        code: 'NSIC Rc 436',
        popularName: 'Tubigan 37 (Early-Maturing)',
        daysToMaturity: 106,
        ecosystem: 'Early Inbred'),
    RiceVariety(
        code: 'NSIC Rc 480',
        popularName: 'GSR 8 (Green Super Rice)',
        daysToMaturity: 107,
        ecosystem: 'Climate-Resilient Inbred'),
    RiceVariety(
        code: 'NSIC Rc 300',
        popularName: 'Tubigan 24',
        daysToMaturity: 115,
        ecosystem: 'Irrigated Lowland Inbred'),
    RiceVariety(
        code: 'NSIC Rc 238',
        popularName: 'Tubigan 23',
        daysToMaturity: 110,
        ecosystem: 'High Milling Inbred'),
    RiceVariety(
        code: 'NSIC Rc 358',
        popularName: 'Tubigan 30',
        daysToMaturity: 111,
        ecosystem: 'Irrigated Lowland Inbred'),
    RiceVariety(
        code: 'NSIC Rc 402',
        popularName: 'Tubigan 36 (BLB-Resistant)',
        daysToMaturity: 114,
        ecosystem: 'Blight-Resistant Inbred'),
    RiceVariety(
        code: 'NSIC Rc 506',
        popularName: 'Tubigan 43',
        daysToMaturity: 110,
        ecosystem: 'Irrigated Lowland Inbred'),
    RiceVariety(
        code: 'NSIC Rc 512',
        popularName: 'Tubigan 45',
        daysToMaturity: 112,
        ecosystem: 'Irrigated Lowland Inbred'),
    RiceVariety(
        code: 'PSB Rc 10',
        popularName: 'Pagsanjan (Early)',
        daysToMaturity: 106,
        ecosystem: 'Early-Maturing Inbred'),
    RiceVariety(
        code: 'PSB Rc 18',
        popularName: 'Ala',
        daysToMaturity: 123,
        ecosystem: 'Classic Inbred'),
    RiceVariety(
        code: 'PSB Rc 28',
        popularName: 'Agno',
        daysToMaturity: 118,
        ecosystem: 'Irrigated Inbred'),
    RiceVariety(
        code: 'PSB Rc 82',
        popularName: 'Peñaranda',
        daysToMaturity: 110,
        ecosystem: 'Central Luzon Inbred'),
    RiceVariety(
        code: 'IR64',
        popularName: 'IR64 Traditional',
        daysToMaturity: 115,
        ecosystem: 'Benchmark Quality Inbred'),
    RiceVariety(
        code: 'BPI Ri 10',
        popularName: 'BPI National',
        daysToMaturity: 120,
        ecosystem: 'Traditional Inbred'),

    // ── Rainfed Lowland (Drought-Tolerant / Sahod Ulan) ────────────────────────
    RiceVariety(
        code: 'NSIC Rc 192',
        popularName: 'Sahod Ulan 1 (Drought-Resilient)',
        daysToMaturity: 105,
        ecosystem: 'Rainfed Lowland'),
    RiceVariety(
        code: 'NSIC Rc 272',
        popularName: 'Sahod Ulan 2',
        daysToMaturity: 107,
        ecosystem: 'Rainfed Lowland'),
    RiceVariety(
        code: 'NSIC Rc 284',
        popularName: 'Sahod Ulan 5',
        daysToMaturity: 109,
        ecosystem: 'Rainfed Lowland'),
    RiceVariety(
        code: 'NSIC Rc 416',
        popularName: 'Sahod Ulan 11',
        daysToMaturity: 108,
        ecosystem: 'Rainfed Lowland'),
    RiceVariety(
        code: 'NSIC Rc 422',
        popularName: 'Sahod Ulan 14',
        daysToMaturity: 109,
        ecosystem: 'Rainfed Lowland'),
    RiceVariety(
        code: 'NSIC Rc 472',
        popularName: 'Sahod Ulan 18',
        daysToMaturity: 111,
        ecosystem: 'Rainfed Lowland'),
    RiceVariety(
        code: 'PSB Rc 14',
        popularName: 'Rio Grande',
        daysToMaturity: 110,
        ecosystem: 'Rainfed Lowland'),

    // ── Submergence & Flood-Prone (Submarino) ─────────────────────────────────
    RiceVariety(
        code: 'NSIC Rc 194',
        popularName: 'Submarino 1 (14-Day Flood-Proof)',
        daysToMaturity: 112,
        ecosystem: 'Submergence-Tolerant'),
    RiceVariety(
        code: 'NSIC Rc 418',
        popularName: 'Submarino 2',
        daysToMaturity: 110,
        ecosystem: 'Submergence-Tolerant'),
    RiceVariety(
        code: 'NSIC Rc 520',
        popularName: 'Submarino 3',
        daysToMaturity: 111,
        ecosystem: 'Submergence-Tolerant'),

    // ── Saline-Prone & Coastal Lowland (Salinas) ──────────────────────────────
    RiceVariety(
        code: 'NSIC Rc 106',
        popularName: 'Salinas 1 (Saline-Tolerant)',
        daysToMaturity: 115,
        ecosystem: 'Saline-Prone Lowland'),
    RiceVariety(
        code: 'NSIC Rc 182',
        popularName: 'Salinas 2',
        daysToMaturity: 110,
        ecosystem: 'Saline-Prone Lowland'),
    RiceVariety(
        code: 'NSIC Rc 184',
        popularName: 'Salinas 3',
        daysToMaturity: 112,
        ecosystem: 'Saline-Prone Lowland'),
    RiceVariety(
        code: 'NSIC Rc 392',
        popularName: 'Salinas 17',
        daysToMaturity: 110,
        ecosystem: 'Saline-Prone Lowland'),
    RiceVariety(
        code: 'NSIC Rc 466',
        popularName: 'Salinas 21',
        daysToMaturity: 113,
        ecosystem: 'Saline-Prone Lowland'),

    // ── Cool-Elevated & Terraces (Cordillera) ─────────────────────────────────
    RiceVariety(
        code: 'NSIC Rc 104',
        popularName: 'Balili (Highland)',
        daysToMaturity: 135,
        ecosystem: 'Cool-Elevated Terraces'),
    RiceVariety(
        code: 'PSB Rc 44',
        popularName: 'Gohang (Cordillera)',
        daysToMaturity: 130,
        ecosystem: 'Cool-Elevated Terraces'),
    RiceVariety(
        code: 'PSB Rc 92',
        popularName: 'Banaue',
        daysToMaturity: 135,
        ecosystem: 'Cool-Elevated Terraces'),

    // ── Upland & Aerobic Rice (Katihan) ───────────────────────────────────────
    RiceVariety(
        code: 'NSIC Rc 9',
        popularName: 'Apo (Upland)',
        daysToMaturity: 119,
        ecosystem: 'Upland Ecosystem'),
    RiceVariety(
        code: 'NSIC Rc 11',
        popularName: 'Canlaon',
        daysToMaturity: 118,
        ecosystem: 'Upland Ecosystem'),
    RiceVariety(
        code: 'NSIC Rc 23',
        popularName: 'Katihan 1',
        daysToMaturity: 108,
        ecosystem: 'Upland Aerobic'),
    RiceVariety(
        code: 'NSIC Rc 190',
        popularName: 'Katihan 3',
        daysToMaturity: 105,
        ecosystem: 'Upland Aerobic'),

    // ── Public & Commercial Hybrids ───────────────────────────────────────────
    RiceVariety(
        code: 'Mestiso 1',
        popularName: 'PSB Rc 72H Hybrid',
        daysToMaturity: 107,
        ecosystem: 'Public Hybrid'),
    RiceVariety(
        code: 'Mestiso 19',
        popularName: 'NSIC Rc 202H',
        daysToMaturity: 110,
        ecosystem: 'Public Hybrid'),
    RiceVariety(
        code: 'Mestiso 20',
        popularName: 'M20 Hybrid (High-Yield)',
        daysToMaturity: 110,
        ecosystem: 'Public Hybrid'),
    RiceVariety(
        code: 'Mestiso 29',
        popularName: 'NSIC Rc 244H (Heat-Tolerant)',
        daysToMaturity: 110,
        ecosystem: 'Public Hybrid'),
    RiceVariety(
        code: 'Mestiso 55',
        popularName: 'NSIC Rc 368H',
        daysToMaturity: 111,
        ecosystem: 'Public Hybrid'),
    RiceVariety(
        code: 'SL-8H',
        popularName: 'Super Hybrid (SL Agritech)',
        daysToMaturity: 112,
        ecosystem: 'Commercial Hybrid'),
    RiceVariety(
        code: 'SL-19H',
        popularName: 'Premium Hybrid',
        daysToMaturity: 110,
        ecosystem: 'Commercial Hybrid'),
    RiceVariety(
        code: 'Bigante Plus',
        popularName: 'Bayer Hybrid (Blight-Resistant)',
        daysToMaturity: 115,
        ecosystem: 'Commercial Hybrid'),
    RiceVariety(
        code: 'Arize H64',
        popularName: 'Bayer Hybrid',
        daysToMaturity: 113,
        ecosystem: 'Commercial Hybrid'),
    RiceVariety(
        code: 'NK6410',
        popularName: 'Syngenta Hybrid',
        daysToMaturity: 112,
        ecosystem: 'Commercial Hybrid'),
    RiceVariety(
        code: 'PHB73',
        popularName: 'Pioneer Corteva Hybrid',
        daysToMaturity: 110,
        ecosystem: 'Commercial Hybrid'),

    // ── Traditional, Heirloom & Specialty Rice ────────────────────────────────
    RiceVariety(
        code: 'Dinorado',
        popularName: 'Traditional Pink Fragrant',
        daysToMaturity: 125,
        ecosystem: 'Specialty Aromatic'),
    RiceVariety(
        code: 'Sinandomeng',
        popularName: 'Traditional Staple',
        daysToMaturity: 120,
        ecosystem: 'Traditional Inbred'),
    RiceVariety(
        code: 'Milagrosa',
        popularName: 'Fragrant Heritage',
        daysToMaturity: 125,
        ecosystem: 'Specialty Aromatic'),
    RiceVariety(
        code: 'Black Rice',
        popularName: 'Ominio Heirloom Pigmented',
        daysToMaturity: 130,
        ecosystem: 'Specialty Heirloom'),
    RiceVariety(
        code: 'Red Rice',
        popularName: 'Cordillera Mountain Heirloom',
        daysToMaturity: 135,
        ecosystem: 'Specialty Heirloom'),
    RiceVariety(
        code: 'Malagkit (IR29)',
        popularName: 'Glutinous Sticky Rice',
        daysToMaturity: 115,
        ecosystem: 'Glutinous / Specialty'),
  ];
}

/// Farmer's field profile model.
class FieldProfile {
  final String fieldName;
  final String municipality;
  final String province;
  final double latitude;
  final double longitude;
  final bool hasCustomCoordinates;
  final DateTime plantingDate;
  final String varietyName;
  final int daysToMaturity;
  final double fieldAreaHa;

  const FieldProfile({
    this.fieldName = '',
    this.municipality = '',
    this.province = '',
    this.latitude = 0,
    this.longitude = 0,
    this.hasCustomCoordinates = false,
    required this.plantingDate,
    this.varietyName = '',
    this.daysToMaturity = 0,
    this.fieldAreaHa = 0,
  });

  /// Empty profile used until the farmer enters their own field details.
  factory FieldProfile.defaultProfile() {
    return FieldProfile(plantingDate: DateTime.now());
  }

  bool get isConfigured =>
      fieldName.trim().isNotEmpty &&
      municipality.trim().isNotEmpty &&
      province.trim().isNotEmpty &&
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180 &&
      (latitude != 0 || longitude != 0) &&
      varietyName.trim().isNotEmpty &&
      daysToMaturity > 0 &&
      fieldAreaHa > 0;

  String get locationDisplay {
    if (municipality.isEmpty && province.isEmpty) return 'Location not set';
    if (municipality.isEmpty) return province;
    if (province.isEmpty) return municipality;
    return '$municipality, $province';
  }

  /// Current day in the cropping cycle (1 to daysToMaturity).
  int get currentDay {
    if (daysToMaturity <= 0) return 0;
    final diff = DateTime.now().difference(plantingDate).inDays;
    return diff.clamp(1, daysToMaturity);
  }

  /// Completion percentage from 0.0 to 1.0.
  double get progressPercent =>
      daysToMaturity > 0 ? (currentDay / daysToMaturity).clamp(0.0, 1.0) : 0;

  /// Expected harvest date.
  DateTime get harvestDate => plantingDate.add(Duration(days: daysToMaturity));

  /// Days remaining until harvest.
  int get daysUntilHarvest {
    if (daysToMaturity <= 0) return 0;
    final remaining = daysToMaturity - currentDay;
    return remaining.clamp(0, daysToMaturity);
  }

  /// Categorical growth stage identifier.
  String get growthStageKey {
    if (daysToMaturity <= 0) return 'unconfigured';
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
    bool? hasCustomCoordinates,
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
      hasCustomCoordinates: hasCustomCoordinates ?? this.hasCustomCoordinates,
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
      'hasCustomCoordinates': hasCustomCoordinates,
      'plantingDate': plantingDate.toIso8601String(),
      'varietyName': varietyName,
      'daysToMaturity': daysToMaturity,
      'fieldAreaHa': fieldAreaHa,
    };
  }

  factory FieldProfile.fromJson(Map<String, dynamic> json) {
    return FieldProfile(
      fieldName: json['fieldName'] ?? '',
      municipality: json['municipality'] ?? '',
      province: json['province'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      hasCustomCoordinates: json['hasCustomCoordinates'] == true,
      plantingDate: json['plantingDate'] != null
          ? DateTime.tryParse(json['plantingDate']) ?? DateTime.now()
          : DateTime.now(),
      varietyName: json['varietyName'] ?? '',
      daysToMaturity: (json['daysToMaturity'] as num?)?.toInt() ?? 0,
      fieldAreaHa: (json['fieldAreaHa'] as num?)?.toDouble() ?? 0,
    );
  }
}
