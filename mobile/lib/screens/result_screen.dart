import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/disease_classifier.dart';
import '../l10n/app_strings.dart';

class ResultScreen extends StatelessWidget {
  final Uint8List imageBytes;
  final DiseasePrediction prediction;

  const ResultScreen({
    super.key,
    required this.imageBytes,
    required this.prediction,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final isConfident = prediction.confidence >= 0.60;
    final confidencePct = (prediction.confidence * 100).toStringAsFixed(1);
    final isHealthy = prediction.label.toLowerCase() == 'healthy';

    final Color statusColor = isHealthy
        ? const Color(0xFF2E7D32)
        : isConfident
            ? const Color(0xFFE65100)
            : const Color(0xFFF59E0B);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      body: CustomScrollView(
        slivers: [
          // Collapsible Hero App Bar
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF191D24),
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              title: Text(
                s.resultTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(
                    imageBytes,
                    fit: BoxFit.cover,
                  ),
                  // Gradient overlay for readability
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Color(0xCC191D24),
                        ],
                        begin: Alignment(0, -0.2),
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Captured specimen tag
                  Positioned(
                    top: 100,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.photo_camera_back_rounded,
                              color: Colors.white70, size: 13),
                          SizedBox(width: 5),
                          Text(
                            'Captured Specimen',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Body content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isConfident) ...[
                    // ── High-confidence diagnosis ──────────────────────────
                    _DiagnosisCard(
                      prediction: prediction,
                      isHealthy: isHealthy,
                      statusColor: statusColor,
                      confidencePct: confidencePct,
                    ),
                    const SizedBox(height: 16),

                    // Treatment card
                    _TreatmentCard(
                        prediction: prediction, isHealthy: isHealthy),
                    const SizedBox(height: 16),

                    // Severity & quick-action chips
                    if (!isHealthy) ...[
                      _SeverityCard(prediction: prediction),
                      const SizedBox(height: 16),
                    ],
                  ] else ...[
                    // ── Low confidence card ───────────────────────────────
                    _LowConfidenceCard(confidencePct: confidencePct),
                    const SizedBox(height: 16),
                  ],

                  // Disclaimer
                  const _DisclaimerPill(),
                  const SizedBox(height: 20),

                  // Action buttons
                  _ActionButtons(onScanAgain: () => Navigator.pop(context)),
                  const SizedBox(height: 32),
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
// Confidence Arc Ring Painter
// ─────────────────────────────────────────────────────────────────────────────
class _ConfidenceRingPainter extends CustomPainter {
  final double value; // 0.0–1.0
  final Color color;

  const _ConfidenceRingPainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const strokeWidth = 7.0;
    const startAngle = -math.pi / 2;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.grey.shade200
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
    // Progress
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      2 * math.pi * value.clamp(0.0, 1.0),
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ConfidenceRingPainter old) =>
      old.value != value || old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Diagnosis Card
// ─────────────────────────────────────────────────────────────────────────────
class _DiagnosisCard extends StatelessWidget {
  final DiseasePrediction prediction;
  final bool isHealthy;
  final Color statusColor;
  final String confidencePct;

  const _DiagnosisCard({
    required this.prediction,
    required this.isHealthy,
    required this.statusColor,
    required this.confidencePct,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Confidence Ring
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(72, 72),
                  painter: _ConfidenceRingPainter(
                    value: prediction.confidence,
                    color: statusColor,
                  ),
                ),
                Text(
                  '$confidencePct%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Name + badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isHealthy ? s.resultHealthy : s.resultDisease,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  s.diseaseName(prediction.label),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF191D24),
                    letterSpacing: -0.3,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.memory_rounded,
                        size: 12, color: Color(0xFF9BA3AF)),
                    const SizedBox(width: 4),
                    Text(
                      s.resultModelTag,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF9BA3AF)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isHealthy
                  ? Icons.check_circle_rounded
                  : Icons.warning_amber_rounded,
              color: statusColor,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Treatment Card
// ─────────────────────────────────────────────────────────────────────────────
class _TreatmentCard extends StatelessWidget {
  final DiseasePrediction prediction;
  final bool isHealthy;

  const _TreatmentCard({required this.prediction, required this.isHealthy});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2EBE6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.lightbulb_rounded, color: primary, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                isHealthy ? s.resultMaintain : s.resultAction,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B3B36),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            s.diseaseTreatmentTip(prediction.label),
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Severity & Quick-Action Chips Card
// ─────────────────────────────────────────────────────────────────────────────
class _SeverityCard extends StatelessWidget {
  final DiseasePrediction prediction;

  const _SeverityCard({required this.prediction});

  /// Returns (label, color, icon) for severity based on confidence
  (String, Color, IconData) _severity(AppStrings s) {
    final c = prediction.confidence;
    if (c >= 0.90) {
      return (
        s.resultHighRisk,
        const Color(0xFFD32F2F),
        Icons.crisis_alert_rounded
      );
    }
    if (c >= 0.75) {
      return (s.resultMedRisk, const Color(0xFFE65100), Icons.warning_rounded);
    }
    return (s.resultLowRisk, const Color(0xFFF59E0B), Icons.info_rounded);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final (severityLabel, severityColor, severityIcon) = _severity(s);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: severityColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: severityColor.withValues(alpha: 0.22), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(severityIcon, color: severityColor, size: 20),
              const SizedBox(width: 8),
              Text(
                s.resultSeverity,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: severityColor),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: severityColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  severityLabel,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Quick action chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ActionChip(
                  icon: Icons.person_outline_rounded, label: s.chipConsult),
              _ActionChip(
                  icon: Icons.medical_services_outlined,
                  label: s.chipFungicide),
              _ActionChip(icon: Icons.camera_alt_outlined, label: s.chipRescan),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF6B7280)),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF374151),
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Low Confidence Card
// ─────────────────────────────────────────────────────────────────────────────
class _LowConfidenceCard extends StatelessWidget {
  final String confidencePct;
  const _LowConfidenceCard({required this.confidencePct});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.help_rounded,
                color: Colors.amber.shade900, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.resultLowConf,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF795548),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${s.resultConfLabel}: $confidencePct% (<60%)',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF8D6E63),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  s.resultLowConfSub,
                  style:
                      const TextStyle(fontSize: 13.5, color: Color(0xFF5D4037)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Disclaimer Pill
// ─────────────────────────────────────────────────────────────────────────────
class _DisclaimerPill extends StatelessWidget {
  const _DisclaimerPill();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF4F1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user_outlined, size: 18, color: primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              s.resultDisclaimer,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF38524B),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action Buttons
// ─────────────────────────────────────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  final VoidCallback onScanAgain;
  const _ActionButtons({required this.onScanAgain});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    return Row(
      children: [
        // Secondary: Save Report
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text('Report saved!'),
                    ],
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.save_alt_rounded, size: 18),
            label: Text(s.resultSaveReport),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
              foregroundColor: const Color(0xFF374151),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Primary: Scan Again
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: onScanAgain,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(s.resultScanAgain),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: const Color(0xFFFF7E55),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }
}
