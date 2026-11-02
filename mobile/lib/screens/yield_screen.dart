import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/field_model.dart';
import '../providers/field_provider.dart';
import '../services/api_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Yield Estimation Screen
// Calls /predict/yield via ApiService and shows a full result breakdown.
// ─────────────────────────────────────────────────────────────────────────────
class YieldScreen extends StatefulWidget {
  const YieldScreen({super.key});

  @override
  State<YieldScreen> createState() => _YieldScreenState();
}

class _YieldScreenState extends State<YieldScreen> {
  final ApiService _api = ApiService();
  bool _loading = false;
  Map<String, dynamic>? _result;
  String? _error;
  String? _selectedEcosystem; // null = Auto/Blend, 'irrigated', 'rainfed'

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  Future<void> _predict() async {
    final field = FieldProvider.fieldOf(context);
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final result = await _api.predictYield(
        seedVariety: field.varietyName,
        daysToMaturity: field.daysToMaturity,
        fieldSizeHectares: field.fieldAreaHa,
        startDate: field.plantingDate,
        municipality: field.municipality,
        lat: field.latitude,
        lon: field.longitude,
        ecosystemType: _selectedEcosystem,
      );
      if (mounted) {
        setState(() {
          _result = result;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final field = FieldProvider.fieldOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(s.yieldTitle),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF191D24),
        surfaceTintColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Field Summary Card ────────────────────────────────────────────
            _FieldSummaryCard(field: field),
            const SizedBox(height: 16),

            // ── Water / Ecosystem Source Selector ─────────────────────────────
            _EcosystemSelectorCard(
              selected: _selectedEcosystem,
              onChanged: (val) {
                setState(() => _selectedEcosystem = val);
              },
            ),
            const SizedBox(height: 20),

            // ── Estimate Button ───────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _predict,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_graph_rounded),
                label: Text(
                  _loading ? s.yieldCalculating : s.yieldEstimateBtn,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 16),
              _ErrorCard(message: _error!),
            ],

            if (_result != null) ...[
              const SizedBox(height: 24),
              _YieldResultCard(result: _result!, field: field, s: s),
            ],

            if (_result == null && _error == null && !_loading) ...[
              const SizedBox(height: 28),
              _HowItWorksCard(s: s),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Field Summary (pre-estimate)
// ─────────────────────────────────────────────────────────────────────────────
class _FieldSummaryCard extends StatelessWidget {
  final FieldProfile field;
  const _FieldSummaryCard({required this.field});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final daysSincePlanting = DateTime.now()
        .difference(field.plantingDate)
        .inDays
        .clamp(0, field.daysToMaturity);
    final harvestIn = (field.daysToMaturity - daysSincePlanting)
        .clamp(0, field.daysToMaturity);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.agriculture_rounded,
                  color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Text(
                s.yieldFieldSummary,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            field.varietyName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            field.locationDisplay,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _SummaryPill(
                icon: Icons.straighten_rounded,
                label: '${field.fieldAreaHa} ha',
              ),
              const SizedBox(width: 8),
              _SummaryPill(
                icon: Icons.schedule_rounded,
                label: 'Day $daysSincePlanting / ${field.daysToMaturity}',
              ),
              const SizedBox(width: 8),
              _SummaryPill(
                icon: Icons.cut_rounded,
                label: 'Harvest in ${harvestIn}d',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SummaryPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white70),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Yield Result Card
// ─────────────────────────────────────────────────────────────────────────────
class _YieldResultCard extends StatelessWidget {
  final Map<String, dynamic> result;
  final FieldProfile field;
  final AppStrings s;

  const _YieldResultCard(
      {required this.result, required this.field, required this.s});

  @override
  Widget build(BuildContext context) {
    final estimatedCavans = ((result['predicted_yield_cavans'] ??
                result['estimated_yield_cavans']) as num?)
            ?.toDouble() ??
        0;
    final estimatedTons = ((result['predicted_yield_tons'] ??
                result['estimated_yield_tons']) as num?)
            ?.toDouble() ??
        0;
    final riskLevel =
        (result['climate_risk_level'] ?? result['risk_level'])?.toString() ??
            'low';
    final riskFactors = (result['risk_factors'] as List<dynamic>?) ?? [];
    final recommendations = (result['recommendations'] as List<dynamic>?) ?? [];
    final modelNote = result['prediction_note']?.toString() ?? '';

    final Color riskColor = riskLevel == 'high'
        ? const Color(0xFFD32F2F)
        : riskLevel == 'medium'
            ? const Color(0xFFF57C00)
            : const Color(0xFF2E7D32);

    final IconData riskIcon = riskLevel == 'high'
        ? Icons.warning_rounded
        : riskLevel == 'medium'
            ? Icons.info_outline_rounded
            : Icons.check_circle_outline_rounded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Main Yield Numbers ──────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2EBE6), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      s.yieldEstimate.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: riskColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(riskIcon, size: 13, color: riskColor),
                        const SizedBox(width: 4),
                        Text(
                          '${riskLevel.toUpperCase()} RISK',
                          style: TextStyle(
                            color: riskColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    estimatedCavans.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1B3B36),
                      letterSpacing: -1.5,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.yieldCavans,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        Text(
                          '${estimatedTons.toStringAsFixed(2)} metric tons',
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${s.yieldForField}: ${field.fieldAreaHa} ha · ${(estimatedCavans / field.fieldAreaHa).toStringAsFixed(1)} cav/ha',
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              if (modelNote.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F7F4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline,
                          size: 18, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          modelNote,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // ── Risk Factors ────────────────────────────────────────────────────
        if (riskFactors.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionHeader(
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFF57C00),
            title: s.yieldRiskFactors,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFFF57C00).withValues(alpha: 0.25)),
            ),
            child: Column(
              children: riskFactors
                  .map(
                    (f) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.circle,
                              size: 6, color: Color(0xFFF57C00)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              f.toString(),
                              style: const TextStyle(
                                  fontSize: 13.5, color: Color(0xFF374151)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],

        // ── Recommendations ─────────────────────────────────────────────────
        if (recommendations.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionHeader(
            icon: Icons.tips_and_updates_rounded,
            iconColor: const Color(0xFF2E7D32),
            title: s.yieldRecommendations,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.2)),
            ),
            child: Column(
              children: recommendations
                  .asMap()
                  .entries
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32)
                                  .withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2E7D32)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              entry.value.toString(),
                              style: const TextStyle(
                                  fontSize: 13.5, color: Color(0xFF374151)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],

        // ── Disclaimer ──────────────────────────────────────────────────────
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 16, color: Color(0xFF6B7280)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  s.yieldDisclaimer,
                  style: const TextStyle(
                      fontSize: 11.5, color: Color(0xFF6B7280), height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  const _SectionHeader(
      {required this.icon, required this.iconColor, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B3B36),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// How It Works Card (pre-estimate state)
// ─────────────────────────────────────────────────────────────────────────────
class _HowItWorksCard extends StatelessWidget {
  final AppStrings s;
  const _HowItWorksCard({required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2EBE6), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_graph_rounded,
                    color: Color(0xFF2E7D32), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                s.yieldHowTitle,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B3B36),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...[
            (Icons.wb_sunny_outlined, s.yieldStep1),
            (Icons.science_outlined, s.yieldStep2),
            (Icons.agriculture_outlined, s.yieldStep3),
          ].map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item.$1, size: 18, color: const Color(0xFF6B7280)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.$2,
                      style: const TextStyle(
                          fontSize: 13.5, color: Color(0xFF374151)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error Card
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEF9A9A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 18, color: Color(0xFFD32F2F)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFFB71C1C), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Water / Ecosystem Type Selector Card
// ─────────────────────────────────────────────────────────────────────────────

class _EcosystemSelectorCard extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;

  const _EcosystemSelectorCard({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.water_drop_outlined, size: 16, color: Color(0xFF2E7D32)),
              SizedBox(width: 6),
              Text(
                'Water / Ecosystem Type',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF374151),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildOption(
                label: 'Auto',
                subtitle: 'Regional',
                icon: Icons.auto_awesome,
                value: null,
              ),
              const SizedBox(width: 8),
              _buildOption(
                label: 'Irrigated',
                subtitle: 'Tubigan',
                icon: Icons.water,
                value: 'irrigated',
              ),
              const SizedBox(width: 8),
              _buildOption(
                label: 'Rainfed',
                subtitle: 'Sahod Ulan',
                icon: Icons.cloud,
                value: 'rainfed',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required String label,
    required String subtitle,
    required IconData icon,
    required String? value,
  }) {
    final isSelected = selected == value;
    return Expanded(
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF2E7D32).withValues(alpha: 0.1)
                : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFE5E7EB),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFF6B7280),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? const Color(0xFF1B5E20)
                      : const Color(0xFF374151),
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
