import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'weather_screen.dart';
import 'calendar_screen.dart';
import 'advisory_screen.dart';
import 'scan_screen.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;

  // AnimationController for crossfade between tabs
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // The ordered screens for the 4 real tabs (skipping center scanner slot)
  static const List<Widget> _screens = [
    HomeScreen(),
    WeatherScreen(),
    CalendarScreen(),
    AdvisoryScreen(),
  ];

  // Map tab-bar indices (0,1,3,4) to screen list indices (0,1,2,3)
  static int _screenIndex(int tabIndex) {
    if (tabIndex <= 1) return tabIndex;
    if (tabIndex >= 3) return tabIndex - 1;
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _animController.value = 1.0; // start fully visible
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      // Center tab is quick-launch to ScanScreen with slide-up transition
      Navigator.push(
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
      );
      return;
    }
    if (index == _currentIndex) return;

    setState(() => _currentIndex = index);

    // Crossfade: snap to 0 then animate to 1
    _animController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      body: Stack(
        children: [
          // Animated Screen Content with crossfade
          Positioned.fill(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: _screens[_screenIndex(_currentIndex)],
            ),
          ),

          // Floating Dark Bottom Navigation Bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Container(
              height: 68,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF191D24),
                borderRadius: BorderRadius.circular(34),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavBarItem(
                    icon: Icons.dashboard_rounded,
                    isSelected: _currentIndex == 0,
                    onTap: () => _onTabTapped(0),
                  ),
                  _NavBarItem(
                    icon: Icons.cloud_outlined,
                    isSelected: _currentIndex == 1,
                    onTap: () => _onTabTapped(1),
                  ),

                  // Center Floating AI Scanner CTA
                  GestureDetector(
                    onTap: () => _onTabTapped(2),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF8A65), Color(0xFFFF6E40)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6E40).withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.crop_free_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),

                  _NavBarItem(
                    icon: Icons.calendar_month_outlined,
                    isSelected: _currentIndex == 3,
                    onTap: () => _onTabTapped(3),
                  ),
                  _NavBarItem(
                    icon: Icons.notifications_none_rounded,
                    isSelected: _currentIndex == 4,
                    onTap: () => _onTabTapped(4),
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

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF8A65).withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.18 : 1.0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: Icon(
                icon,
                size: 24,
                color: isSelected
                    ? const Color(0xFFFF8A65)
                    : const Color(0xFF7E848D),
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF8A65),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
