import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';

/// A segmented radial arc gauge widget — elevated design with gradient arc,
/// richer center content, and a mini stats row below.
class CropArcGauge extends StatelessWidget {
  final int currentDay;
  final int totalDays;
  final String stageName;
  final double percent; // 0.0 to 1.0

  const CropArcGauge({
    super.key,
    required this.currentDay,
    required this.totalDays,
    required this.stageName,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    final daysLeft = (totalDays - currentDay).clamp(0, totalDays);
    final pct = (percent * 100).toInt();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Arc + center content
          SizedBox(
            height: 182,
            width: double.infinity,
            child: CustomPaint(
              painter: _GradientArcPainter(
                progress: percent.clamp(0.0, 1.0),
                activeColors: const [Color(0xFFFFB347), Color(0xFFFF6E40)],
                inactiveColor: const Color(0xFFF0EBE1),
                totalSegments: 12,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 36),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Stage pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF8A65), Color(0xFFFF6E40)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.eco_rounded,
                                size: 12, color: Colors.white),
                            const SizedBox(width: 5),
                            Text(
                              stageName,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Big day number
                      Text(
                        'Day $currentDay',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF192024),
                          letterSpacing: -1,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$pct% of season',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),
          Container(height: 1, color: const Color(0xFFF0EBE1)),
          const SizedBox(height: 14),

          // Mini stats row
          Row(
            children: [
              _StatChip(
                icon: Icons.calendar_today_rounded,
                label: 'Day',
                value: '$currentDay',
                color: const Color(0xFFFF8A65),
              ),
              const SizedBox(width: 10),
              _StatChip(
                icon: Icons.flag_rounded,
                label: 'Total',
                value: '$totalDays days',
                color: const Color(0xFF4CAF50),
              ),
              const SizedBox(width: 10),
              _StatChip(
                icon: Icons.hourglass_bottom_rounded,
                label: 'Left',
                value: '$daysLeft days',
                color: const Color(0xFF2196F3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: color.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientArcPainter extends CustomPainter {
  final double progress;
  final List<Color> activeColors;
  final Color inactiveColor;
  final int totalSegments;

  _GradientArcPainter({
    required this.progress,
    required this.activeColors,
    required this.inactiveColor,
    required this.totalSegments,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.90);
    final radius = size.height * 0.80;
    const strokeWidth = 26.0;

    const startAngle = 3.32; // ~190 deg
    const sweepTotal = 2.80; // ~160 deg

    final activeSegments = (progress * totalSegments).round();
    const gapAngle = 0.06;
    final segmentSweep =
        (sweepTotal - (gapAngle * (totalSegments - 1))) / totalSegments;

    for (int i = 0; i < totalSegments; i++) {
      final segStart = startAngle + i * (segmentSweep + gapAngle);
      final isFilled = i < activeSegments;

      Color segColor;
      if (isFilled) {
        // Interpolate gradient across active segments
        final t = activeSegments > 1 ? i / (activeSegments - 1) : 1.0;
        segColor = Color.lerp(activeColors.first, activeColors.last, t)!;
      } else {
        segColor = inactiveColor;
      }

      // Outer glow for filled segments
      if (isFilled) {
        final glowPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth + 6
          ..strokeCap = StrokeCap.round
          ..color = segColor.withValues(alpha: 0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          segStart,
          segmentSweep,
          false,
          glowPaint,
        );
      }

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = segColor;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        segStart,
        segmentSweep,
        false,
        paint,
      );
    }

    // End dot glow on active tip
    if (progress > 0) {
      final lastActive = activeSegments - 1;
      final tipAngle = startAngle +
          lastActive * (segmentSweep + gapAngle) +
          segmentSweep;
      final tipX = center.dx + radius * math.cos(tipAngle);
      final tipY = center.dy + radius * math.sin(tipAngle);
      canvas.drawCircle(
        Offset(tipX, tipY),
        strokeWidth / 2 + 2,
        Paint()..color = activeColors.last.withValues(alpha: 0.35),
      );
      canvas.drawCircle(
        Offset(tipX, tipY),
        strokeWidth / 2 - 2,
        Paint()..color = activeColors.last,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GradientArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
