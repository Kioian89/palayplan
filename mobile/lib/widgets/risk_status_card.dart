import 'package:flutter/material.dart';

/// Modern, high-contrast, accessible risk status card.
/// Designed for field clarity and quick farmer comprehension.
class RiskStatusCard extends StatelessWidget {
  final String title;
  final String message;
  final String riskLevel; // 'low' | 'medium' | 'high'

  const RiskStatusCard({
    super.key,
    required this.title,
    required this.message,
    required this.riskLevel,
  });

  Color get _primaryColor {
    switch (riskLevel.toLowerCase()) {
      case 'high':
      case 'critical':
        return const Color(0xFFD32F2F);
      case 'medium':
      case 'warning':
        return const Color(0xFFF57C00);
      default:
        return const Color(0xFF2E7D32);
    }
  }

  Color get _bgColor {
    switch (riskLevel.toLowerCase()) {
      case 'high':
      case 'critical':
        return const Color(0xFFFFEBEE);
      case 'medium':
      case 'warning':
        return const Color(0xFFFFF3E0);
      default:
        return const Color(0xFFE8F5E9);
    }
  }

  String get _badgeText {
    switch (riskLevel.toLowerCase()) {
      case 'high':
      case 'critical':
        return 'CRITICAL ACTION';
      case 'medium':
      case 'warning':
        return 'FIELD ADVISORY';
      default:
        return 'FIELD NORMAL';
    }
  }

  IconData get _icon {
    switch (riskLevel.toLowerCase()) {
      case 'high':
      case 'critical':
        return Icons.warning_rounded;
      case 'medium':
      case 'warning':
        return Icons.info_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _primaryColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left status accent indicator bar
              Container(
                width: 6,
                color: _primaryColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _primaryColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(_icon, color: _primaryColor, size: 20),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _primaryColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _badgeText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _primaryColor.withValues(alpha: 0.95),
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: const TextStyle(
                          fontSize: 14.5,
                          color: Color(0xFF37474F),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
