import 'package:material_ui/material_ui.dart';

class FarmerLandingScreen extends StatelessWidget {
  const FarmerLandingScreen({
    required this.isProfileReady,
    required this.onContinue,
    this.loadingMessage = 'Preparing your account and farm profile…',
    super.key,
  });

  final bool isProfileReady;
  final VoidCallback onContinue;
  final String loadingMessage;

  static const _guideSteps = [
    _GuideStep(
      icon: Icons.agriculture_outlined,
      title: '1. Set up your field',
      description: 'Add your field location, rice variety, planting date, and field size to personalize your farm dashboard.',
    ),
    _GuideStep(
      icon: Icons.cloud_outlined,
      title: '2. Check rain and heat forecasts',
      description: 'See rain chances and daily temperatures for your field. Watch for hot days when planning farm work. Forecasts need an internet connection.',
    ),
    _GuideStep(
      icon: Icons.calendar_month_outlined,
      title: '3. Follow crop stages',
      description: 'Use the crop calendar and advisories as reminders for common rice-growing activities.',
    ),
    _GuideStep(
      icon: Icons.camera_alt_outlined,
      title: '4. Scan rice leaves',
      description: 'Take or choose a clear leaf photo to get an on-device disease screening result. It is guidance, not a confirmed diagnosis.',
    ),
    _GuideStep(
      icon: Icons.insights_outlined,
      title: '5. Explore yield estimates',
      description: 'Yield estimates use regional historical data, not field measurements. Treat them as a planning reference.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          children: [
            Center(
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const ExcludeSemantics(
                  child: Icon(
                    Icons.grass_rounded,
                    size: 38,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Welcome to PalayPlan',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF12342E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'A quick guide to the tools that can support your rice-farming decisions.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF4A5568),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            for (final step in _guideSteps) ...[
              _GuideStepCard(step: step),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: Icon(Icons.lock_outline, color: colors.primary),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Your farm profile is kept separate for each signed-in account.',
                      style: TextStyle(color: Color(0xFF2C4A45), height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              liveRegion: true,
              child: Text(
                isProfileReady ? 'Your account is ready.' : loadingMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF4A5568),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: isProfileReady ? onContinue : null,
                child: const Text('Continue to PalayPlan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideStep {
  const _GuideStep({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

class _GuideStepCard extends StatelessWidget {
  const _GuideStepCard({required this.step});

  final _GuideStep step;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: ExcludeSemantics(
                child: Icon(step.icon, color: const Color(0xFF2E7D32)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1B3B36),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    step.description,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: const Color(0xFF4A5568), height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
