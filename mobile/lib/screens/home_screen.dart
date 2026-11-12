import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import '../services/api_service.dart';
import '../widgets/crop_arc_gauge.dart';
import '../widgets/language_picker_sheet.dart';
import '../widgets/edit_field_sheet.dart';
import '../widgets/offline_data_notice.dart';
import '../providers/language_provider.dart';
import '../providers/field_provider.dart';
import '../l10n/app_strings.dart';
import 'weather_screen.dart';
import 'calendar_screen.dart';
import 'advisory_screen.dart';
import 'scan_screen.dart';
import 'settings_screen.dart';
import '../services/firebase_auth_service.dart';
import '../services/recommendation_service.dart';
import '../widgets/smart_recommendation_card.dart';
import 'yield_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.authService});

  final FirebaseAuthService? authService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();
  List<Advisory> _todayAdvisories = [];
  bool _loading = true;
  bool _usingCachedData = false;
  DateTime? _dataSavedAt;
  int _selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAdvisories();
  }

  Future<void> _loadAdvisories() async {
    final field = FieldProvider.fieldOf(context);
    if (!field.isConfigured) {
      if (mounted) {
        setState(() {
          _todayAdvisories = [];
          _usingCachedData = false;
          _dataSavedAt = null;
          _loading = false;
        });
      }
      return;
    }

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
          _usingCachedData = _api.lastResponseWasCached;
          _dataSavedAt = _api.lastResponseAt;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _editField() async {
    await EditFieldSheet.show(context);
    await _loadAdvisories();
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todayStr = DateFormat('d MMM').format(DateTime.now());
    final s = AppStrings.of(context);
    final field = FieldProvider.fieldOf(context);
    final filters = [
      s.filterAll,
      s.filterVeg,
      s.filterWeather,
      s.filterAdvisory,
    ];
    final langShort = s.lang == AppLanguage.english
        ? 'EN'
        : s.lang == AppLanguage.filipino
            ? 'FIL'
            : 'CEB';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadAdvisories,
          color: const Color(0xFF2E7D32),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              if (_usingCachedData && _dataSavedAt != null)
                SliverToBoxAdapter(
                  child: OfflineDataNotice(savedAt: _dataSavedAt!),
                ),

              // ── Top Header Bar ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 16, 8),
                  child: Row(
                    children: [
                      // Logo & Field Location Selector
                      Expanded(
                        child: GestureDetector(
                          onTap: _editField,
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'assets/icons/app_logo.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    s.homeTitle,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF191D24),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.location_on_rounded,
                                        size: 13,
                                        color: Color(0xFF2E7D32),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        field.locationDisplay,
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF5A6270),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 14,
                                        color: Color(0xFF5A6270),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Language Switcher Pill
                      GestureDetector(
                        onTap: () => LanguagePickerSheet.show(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.language_rounded,
                                size: 14,
                                color: Color(0xFF2E7D32),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                langShort,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF191D24),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Notification Icon
                      _CircleActionBtn(
                        icon: Icons.notifications_none_rounded,
                        badge: _todayAdvisories.isNotEmpty
                            ? '${_todayAdvisories.length}'
                            : null,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdvisoryScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Settings Icon with Tooltip
                      IconButton(
                        tooltip: s.settingsTitle,
                        constraints: const BoxConstraints.tightFor(
                          width: 40,
                          height: 40,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => SettingsScreen(
                              authService: widget.authService,
                            ),
                          ),
                        ),
                        icon: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.settings_outlined,
                              size: 18,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Rice Field Spotlight Card (with Scan Leaf CTA) ───────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                  child: _HeroRiceFarmCard(s: s),
                ),
              ),

              // ── Radial Crop Arc Gauge ────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: field.isConfigured
                      ? Column(
                          children: [
                            CropArcGauge(
                              currentDay: field.currentDay,
                              totalDays: field.daysToMaturity,
                              stageName:
                                  '${field.stageName(context)} · $todayStr',
                              percent: field.progressPercent,
                            ),
                            const SizedBox(height: 16),
                            SmartRecommendationCard(
                              recommendation: RecommendationService.generate(
                                profile: field,
                                lang: s.lang,
                              ),
                            ),
                          ],
                        )
                      : Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Set up your rice field',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1B3B36),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Add your field location, rice variety, planting date, and area to get local weather and crop recommendations.',
                                  style: TextStyle(height: 1.4),
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton.icon(
                                  onPressed: _editField,
                                  icon: const Icon(Icons.tune_rounded),
                                  label: const Text('Set up field'),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),

              // ── Section Title: Quick Access ──────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Text(
                    s.fieldStatusTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF191D24),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),

              // ── 2x2 Professional Rice Farm Feature Cards ──────────────────
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  delegate: SliverChildListDelegate([
                    _RiceFeatureCard(
                      imagePath: 'assets/images/card_weather.jpg',
                      icon: Icons.wb_cloudy_rounded,
                      title: s.featWeather,
                      subtitle: s.featWeatherBadge,
                      accentColor: const Color(0xFF0277BD),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WeatherScreen(),
                        ),
                      ),
                    ),
                    _RiceFeatureCard(
                      imagePath: 'assets/images/card_calendar.jpg',
                      icon: Icons.calendar_month_rounded,
                      title: s.featCalendar,
                      subtitle: s.featCalendarBadge,
                      accentColor: const Color(0xFF2E7D32),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CalendarScreen(),
                        ),
                      ),
                    ),
                    _RiceFeatureCard(
                      imagePath: 'assets/images/card_scanner.jpg',
                      icon: Icons.auto_graph_rounded,
                      title: s.yieldTitle,
                      subtitle: s.featCalendarBadge,
                      accentColor: const Color(0xFFE65100),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const YieldScreen(),
                        ),
                      ),
                    ),
                    _RiceFeatureCard(
                      imagePath: 'assets/images/card_advisory.jpg',
                      icon: Icons.shield_rounded,
                      title: s.featAdvisory,
                      subtitle: _loading
                          ? '…'
                          : '${_todayAdvisories.length} ${s.navAdvisory}',
                      accentColor: const Color(0xFF6A1B9A),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdvisoryScreen(),
                        ),
                      ),
                    ),
                  ]),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                ),
              ),

              // ── Advisories Filter Chips ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        s.navAdvisory,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF191D24),
                          letterSpacing: -0.2,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdvisoryScreen(),
                          ),
                        ),
                        child: Text(
                          s.seeAll,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: SizedBox(
                  height: 36,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final isSelected = _selectedFilterIndex == index;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedFilterIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF2E7D32)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFE5E7EB),
                            ),
                            boxShadow: [
                              if (!isSelected)
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 6,
                                  offset: const Offset(0, 1),
                                ),
                            ],
                          ),
                          child: Text(
                            filters[index],
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF4A505A),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // ── Active Advisories List ───────────────────────────────────
              if (_loading)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.sync_rounded,
                              color: Color(0xFF2E7D32),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            s.advLoading,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (_todayAdvisories.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            color: Color(0xFF2E7D32),
                            size: 38,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            s.advEmpty,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF191D24),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final adv = _todayAdvisories[index];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: _AdvisoryCard(advisory: adv),
                      );
                    },
                    childCount: _todayAdvisories.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 90)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Rice Farm Banner Card
// ─────────────────────────────────────────────────────────────────────────────
class _HeroRiceFarmCard extends StatelessWidget {
  final AppStrings s;
  const _HeroRiceFarmCard({required this.s});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
      child: Container(
        height: 205,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B5E20).withValues(alpha: 0.22),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Real High-Resolution Rice Terraces Photography
              Image.asset(
                'assets/images/hero_rice_field.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),

              // Gradient Overlay for Crystal Clear Text Readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.72),
                    ],
                    stops: const [0.25, 1.0],
                  ),
                ),
              ),

              // Top Floating Badges
              Positioned(
                top: 14,
                left: 14,
                child: _PillBadge(
                  text: s.onDeviceAi,
                  icon: Icons.memory_rounded,
                  bg: const Color(0xFF2E7D32).withValues(alpha: 0.92),
                ),
              ),
              Positioned(
                top: 14,
                right: 14,
                child: _PillBadge(
                  text: s.accuracyBadge,
                  icon: Icons.auto_awesome,
                  bg: Colors.white.withValues(alpha: 0.22),
                  borderColor: Colors.white.withValues(alpha: 0.45),
                ),
              ),

              // Bottom Title and CTA Button
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            s.heroTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              letterSpacing: -0.3,
                              shadows: [
                                Shadow(color: Colors.black45, blurRadius: 8),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.heroSubtitle,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.90),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Primary Scan CTA Button
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF2E7D32).withValues(alpha: 0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.document_scanner_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            s.featScan,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Professional Rice Farm Feature Card
// ─────────────────────────────────────────────────────────────────────────────
class _RiceFeatureCard extends StatelessWidget {
  final String imagePath;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  const _RiceFeatureCard({
    required this.imagePath,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo Header (Top Portion)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 80,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: accentColor.withValues(alpha: 0.12)),
                ),
              ),

              // Soft Fade to Card Body
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                height: 35,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.white],
                    ),
                  ),
                ),
              ),

              // Floating Icon Badge
              Positioned(
                top: 48,
                left: 12,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(icon, color: accentColor, size: 17),
                  ),
                ),
              ),

              // Title and Subtitle at Bottom
              Positioned(
                left: 12,
                right: 12,
                bottom: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF191D24),
                        letterSpacing: -0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Advisory Card
// ─────────────────────────────────────────────────────────────────────────────
class _AdvisoryCard extends StatelessWidget {
  final Advisory advisory;
  const _AdvisoryCard({required this.advisory});

  Color _severityColor() {
    switch (advisory.severity.toLowerCase()) {
      case 'critical':
      case 'high':
        return const Color(0xFFB71C1C);
      case 'warning':
      case 'medium':
        return const Color(0xFFE65100);
      default:
        return const Color(0xFF2E7D32);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _severityColor();
    final fmt = DateFormat('MMM d');
    final title = '${advisory.stage} · ${fmt.format(advisory.date)}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.warning_amber_rounded, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF191D24),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        advisory.severity.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  advisory.message,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF5A6270),
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
// Pill Badge
// ─────────────────────────────────────────────────────────────────────────────
class _PillBadge extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color bg;
  final Color? borderColor;

  const _PillBadge({
    required this.text,
    required this.icon,
    required this.bg,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Circle Action Button
// ─────────────────────────────────────────────────────────────────────────────
class _CircleActionBtn extends StatelessWidget {
  final IconData icon;
  final String? badge;
  final VoidCallback onTap;

  const _CircleActionBtn({
    required this.icon,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(icon, size: 18, color: const Color(0xFF374151)),
            ),
          ),
          if (badge != null)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFB71C1C),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
