import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import '../services/api_service.dart';
import '../widgets/crop_arc_gauge.dart';
import '../widgets/language_picker_sheet.dart';
import '../widgets/edit_field_sheet.dart';
import '../providers/language_provider.dart';
import '../providers/field_provider.dart';
import '../l10n/app_strings.dart';
import 'weather_screen.dart';
import 'calendar_screen.dart';
import 'advisory_screen.dart';
import 'scan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();
  List<Advisory> _todayAdvisories = [];
  bool _loading = true;
  int _selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAdvisories();
  }

  Future<void> _loadAdvisories() async {
    final field = FieldProvider.fieldOf(context);
    try {
      final advisories = await _api.getAdvisories(
        municipality: field.municipality,
        lat: field.latitude,
        lon: field.longitude,
        startDate: field.plantingDate,
        daysToMaturity: field.daysToMaturity,
      );
      if (mounted) {
        setState(() {
          _todayAdvisories = advisories.take(3).toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final todayStr = DateFormat('d MMM').format(DateTime.now());
    final s = AppStrings.of(context);
    final field = FieldProvider.fieldOf(context);
    final filters = [s.filterAll, s.filterVeg, s.filterWeather, s.filterAdvisory];
    final langShort = s.lang == AppLanguage.english
        ? 'EN'
        : s.lang == AppLanguage.filipino
            ? 'FIL'
            : 'CEB';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadAdvisories,
          color: const Color(0xFFFF7E55),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // Top Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CircleIconButton(
                        icon: Icons.grain_rounded,
                        iconColor: const Color(0xFFFF7E55),
                        onTap: () => LanguagePickerSheet.show(context),
                      ),
                      GestureDetector(
                        onTap: () => EditFieldSheet.show(context),
                        child: Column(
                          children: [
                            Text(
                              s.homeTitle,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1B2128),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on, size: 12, color: Color(0xFFFF7E55)),
                                const SizedBox(width: 2),
                                Text(
                                  field.locationDisplay,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF8A9099),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Color(0xFFFF7E55)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Language Switcher Pill
                          GestureDetector(
                            onTap: () => LanguagePickerSheet.show(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.language_rounded, size: 15, color: Color(0xFFFF7E55)),
                                  const SizedBox(width: 4),
                                  Text(
                                    langShort,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF191D24),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _CircleIconButton(
                            icon: Icons.notifications_none_rounded,
                            iconColor: const Color(0xFF1B2128),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AdvisoryScreen()),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Segmented Radial Arc Gauge Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: CropArcGauge(
                    currentDay: field.currentDay,
                    totalDays: field.daysToMaturity,
                    stageName: '${field.stageName(context)} · $todayStr',
                    percent: field.progressPercent,
                  ),
                ),
              ),

              // Quick Filter Pills
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 38,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final isSelected = _selectedFilterIndex == index;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedFilterIndex = index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF191D24) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              if (!isSelected)
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              filters[index],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : const Color(0xFF4A505A),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // "Your Crops, Decoded By AI" Spotlight Hero Card — image-style
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, animation, __) => const ScanScreen(),
                        transitionsBuilder: (_, animation, __, child) {
                          final curved = CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          );
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 1),
                              end: Offset.zero,
                            ).animate(curved),
                            child: FadeTransition(opacity: curved, child: child),
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 320),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: SizedBox(
                        height: 210,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Rice field gradient painting (no asset needed)
                            CustomPaint(painter: _RiceFieldPainter()),

                            // Overlay gradient for text legibility
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.0),
                                    Colors.black.withValues(alpha: 0.62),
                                  ],
                                  stops: const [0.35, 1.0],
                                ),
                              ),
                            ),

                            // Top-right floating pill: accuracy badge
                            Positioned(
                              top: 14,
                              right: 14,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.20),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.35),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.auto_awesome,
                                        size: 13, color: Colors.white),
                                    const SizedBox(width: 5),
                                    Text(
                                      s.accuracyBadge,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Top-left floating pill: on-device AI
                            Positioned(
                              top: 14,
                              left: 14,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 11, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF7E55)
                                      .withValues(alpha: 0.88),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.memory_rounded,
                                        size: 12, color: Colors.white),
                                    const SizedBox(width: 5),
                                    Text(
                                      s.onDeviceAi,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Bottom content
                            Positioned(
                              left: 18,
                              right: 18,
                              bottom: 18,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          s.heroTitle,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            height: 1.2,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black38,
                                                blurRadius: 8,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          s.heroSubtitle,
                                          style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.82),
                                            fontSize: 12,
                                            height: 1.35,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Scan CTA button
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 11),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Colors.black.withValues(alpha: 0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.camera_alt_rounded,
                                            size: 16,
                                            color: Color(0xFFFF7E55)),
                                        const SizedBox(width: 6),
                                        Text(
                                          s.featScan,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF192024),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Horizontal Quick-Access Feature Cards (reference design style)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 135,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FeatureCard(
                        emoji: '🌤️',
                        title: s.navWeather,
                        value: s.featWeatherBadge,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const WeatherScreen()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _FeatureCard(
                        emoji: '📅',
                        title: s.navCalendar,
                        value: s.featCalendarBadge,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF81C784), Color(0xFF388E3C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CalendarScreen()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _FeatureCard(
                        emoji: '🧪',
                        title: s.featFertilizer,
                        value: s.featFertilizerBadge,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFB74D), Color(0xFFE65100)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CalendarScreen()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _FeatureCard(
                        emoji: '🛡️',
                        title: s.navAdvisory,
                        value: _loading ? '…' : '${_todayAdvisories.length}',
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF9A9A), Color(0xFFB71C1C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AdvisoryScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // Section Title: Field Status & Activities
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        s.fieldStatusTitle,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF192024),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AdvisoryScreen()),
                        ),
                        child: Text(
                          s.seeAll,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFF7E55),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Activity Cards List
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _FieldActivityCard(
                      icon: Icons.science_outlined,
                      iconBg: const Color(0xFFFFF0EB),
                      iconColor: const Color(0xFFFF7E55),
                      title: s.featFertilizer,
                      subtitle: s.featFertilizerSub,
                      badgeText: s.featFertilizerBadge,
                      badgeColor: const Color(0xFFE8F5E9),
                      badgeTextColor: const Color(0xFF2E7D32),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CalendarScreen()),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _FieldActivityCard(
                      icon: Icons.wb_sunny_outlined,
                      iconBg: const Color(0xFFFFF8E1),
                      iconColor: const Color(0xFFFFA000),
                      title: s.featWeather,
                      subtitle: s.featWeatherSub,
                      badgeText: s.featWeatherBadge,
                      badgeColor: const Color(0xFFE3F2FD),
                      badgeTextColor: const Color(0xFF1976D2),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WeatherScreen()),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _FieldActivityCard(
                      icon: Icons.calendar_today_outlined,
                      iconBg: const Color(0xFFE8F5E9),
                      iconColor: const Color(0xFF388E3C),
                      title: s.featCalendar,
                      subtitle: s.featCalendarSub,
                      badgeText: s.featCalendarBadge,
                      badgeColor: const Color(0xFFF1F8E9),
                      badgeTextColor: const Color(0xFF558B2F),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CalendarScreen()),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _FieldActivityCard(
                      icon: Icons.shield_outlined,
                      iconBg: const Color(0xFFFFEBEE),
                      iconColor: const Color(0xFFE53935),
                      title: s.featAdvisory,
                      subtitle: _loading
                          ? s.advLoading
                          : '${_todayAdvisories.length} ${s.featAdvisorySub}',
                      badgeText: s.featAdvisoryBadge,
                      badgeColor: const Color(0xFFFFF3E0),
                      badgeTextColor: const Color(0xFFE65100),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdvisoryScreen()),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldActivityCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String badgeText;
  final Color badgeColor;
  final Color badgeTextColor;
  final VoidCallback onTap;

  const _FieldActivityCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left round thumbnail icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, color: iconColor, size: 24),
              ),
            ),
            const SizedBox(width: 14),
            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF192024),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            // Right Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: badgeTextColor,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFB0B4BA),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// Paints a stylized rice paddy landscape in code (no image asset needed).
/// Horizontal quick-access feature card (reference: food app category cards).
class _FeatureCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String value;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.emoji,
    required this.title,
    required this.value,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 104,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.last.withValues(alpha: 0.28),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.88),
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Paints a stylized rice paddy landscape in code (no image asset needed).
class _RiceFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sky gradient (warm sunrise tones)
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF87CEEB), Color(0xFFFDB97D)],
        stops: [0.0, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.45));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.45), skyPaint);

    // Sun glow
    final sunGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFF176).withValues(alpha: 0.8),
          const Color(0xFFFDB97D).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(
          center: Offset(w * 0.72, h * 0.18), radius: h * 0.28));
    canvas.drawCircle(Offset(w * 0.72, h * 0.18), h * 0.28, sunGlow);

    // Sun disc
    canvas.drawCircle(
      Offset(w * 0.72, h * 0.18),
      h * 0.065,
      Paint()..color = const Color(0xFFFFF176),
    );

    // Mountain silhouette
    final mtPaint = Paint()..color = const Color(0xFF5D8A6B);
    final mtPath = Path()
      ..moveTo(0, h * 0.42)
      ..lineTo(w * 0.18, h * 0.18)
      ..lineTo(w * 0.36, h * 0.38)
      ..lineTo(w * 0.48, h * 0.22)
      ..lineTo(w * 0.62, h * 0.40)
      ..lineTo(w, h * 0.30)
      ..lineTo(w, h * 0.45)
      ..close();
    canvas.drawPath(mtPath, mtPaint);

    // Terraced paddy fields (horizontal bands with water reflections)
    final terraceColors = [
      const Color(0xFF4CAF50),
      const Color(0xFF81C784),
      const Color(0xFFA5D6A7),
      const Color(0xFF66BB6A),
    ];
    final waterColors = [
      const Color(0xFF29B6F6).withValues(alpha: 0.5),
      const Color(0xFF4FC3F7).withValues(alpha: 0.4),
      const Color(0xFF81D4FA).withValues(alpha: 0.35),
    ];

    // Draw 4 terraces from bottom
    for (int i = 0; i < 4; i++) {
      final top = h * (0.43 + i * 0.135);
      final bot = top + h * 0.13;
      final terraceRect = Rect.fromLTWH(0, top, w, bot - top);

      // Grass/rice layer
      canvas.drawRect(
        terraceRect,
        Paint()..color = terraceColors[i % terraceColors.length],
      );

      // Water shimmer strip at top of each terrace
      if (i < 3) {
        canvas.drawRect(
          Rect.fromLTWH(0, top, w, h * 0.025),
          Paint()..color = waterColors[i % waterColors.length],
        );
      }

      // Rice stalk rows (thin vertical lines)
      final stalkPaint = Paint()
        ..color = const Color(0xFF2E7D32).withValues(alpha: 0.5)
        ..strokeWidth = 1.2;
      for (double x = 8; x < w; x += 14) {
        final jitter = math.sin(x * 0.3 + i) * 3;
        canvas.drawLine(
          Offset(x + jitter, top + h * 0.03),
          Offset(x + jitter, top + h * 0.11),
          stalkPaint,
        );
        // Rice grain head tilt
        canvas.drawLine(
          Offset(x + jitter, top + h * 0.03),
          Offset(x + jitter + 5, top + h * 0.01),
          stalkPaint,
        );
      }
    }

    // Foreground edge shadow
    final fgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          const Color(0xFF1B4332).withValues(alpha: 0.3),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.75, w, h * 0.25));
    canvas.drawRect(Rect.fromLTWH(0, h * 0.75, w, h * 0.25), fgPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, color: iconColor, size: 20),
        ),
      ),
    );
  }
}
