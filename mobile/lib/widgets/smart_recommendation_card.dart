import 'package:material_ui/material_ui.dart';
import '../services/recommendation_service.dart';
import '../l10n/app_strings.dart';

class SmartRecommendationCard extends StatefulWidget {
  final FieldRecommendation recommendation;

  const SmartRecommendationCard({
    super.key,
    required this.recommendation,
  });

  @override
  State<SmartRecommendationCard> createState() => _SmartRecommendationCardState();
}

class _SmartRecommendationCardState extends State<SmartRecommendationCard> {
  int _selectedTab = 0; // 0 = Fertilizer, 1 = Water, 2 = Pest

  @override
  Widget build(BuildContext context) {
    final rec = widget.recommendation;
    final s = AppStrings.of(context);

    final fertilizerColor = rec.delayFertilizer
        ? const Color(0xFFE65100)
        : const Color(0xFF2E7D32);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Bar ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8E9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        s.recTitle,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B5E20),
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        'Day ${rec.currentDay} · ${rec.stageName}',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4E7D55),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFC8E6C9)),
                  ),
                  child: const Text(
                    'PalayCheck',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Headline Key Takeaway ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
            child: Text(
              rec.headline,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF191D24),
                height: 1.35,
              ),
            ),
          ),

          // ── Category Switcher Pills ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                _TabPill(
                  icon: Icons.science_rounded,
                  label: s.featFertilizer,
                  isSelected: _selectedTab == 0,
                  badgeColor: rec.delayFertilizer ? const Color(0xFFE65100) : null,
                  onTap: () => setState(() => _selectedTab = 0),
                ),
                const SizedBox(width: 6),
                _TabPill(
                  icon: Icons.water_drop_rounded,
                  label: 'AWD Tubig',
                  isSelected: _selectedTab == 1,
                  onTap: () => setState(() => _selectedTab = 1),
                ),
                const SizedBox(width: 6),
                _TabPill(
                  icon: Icons.shield_rounded,
                  label: 'Peste & Sakit',
                  isSelected: _selectedTab == 2,
                  onTap: () => setState(() => _selectedTab = 2),
                ),
              ],
            ),
          ),

          // ── Detail Pane ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: _selectedTab == 0
                  ? _DetailView(
                      icon: Icons.science_rounded,
                      accentColor: fertilizerColor,
                      statusBadge: rec.delayFertilizer ? s.recDelayRain : s.recApplySafe,
                      statusBadgeColor: fertilizerColor,
                      title: rec.fertilizerTitle,
                      description: rec.fertilizerDetail,
                    )
                  : _selectedTab == 1
                      ? _DetailView(
                          icon: Icons.water_drop_rounded,
                          accentColor: const Color(0xFF0288D1),
                          statusBadge: 'Alternate Wetting & Drying',
                          statusBadgeColor: const Color(0xFF0288D1),
                          title: rec.waterTitle,
                          description: rec.waterDetail,
                        )
                      : _DetailView(
                          icon: Icons.shield_rounded,
                          accentColor: const Color(0xFF7B1FA2),
                          statusBadge: 'Field Scouting Guidance',
                          statusBadgeColor: const Color(0xFF7B1FA2),
                          title: rec.pestTitle,
                          description: rec.pestDetail,
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _TabPill({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF191D24) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF191D24) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : const Color(0xFF5A6270),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : const Color(0xFF5A6270),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badgeColor != null) ...[
                const SizedBox(width: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailView extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final String statusBadge;
  final Color statusBadgeColor;
  final String title;
  final String description;

  const _DetailView({
    required this.icon,
    required this.accentColor,
    required this.statusBadge,
    required this.statusBadgeColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusBadgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                statusBadge,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: statusBadgeColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFF191D24),
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4A505A),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

