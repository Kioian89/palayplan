import 'package:material_ui/material_ui.dart';
import '../l10n/app_strings.dart';
import '../models/field_model.dart';
import '../services/zoom_earth_service.dart';

/// Interactive card showcasing Zoom Earth live satellite, rain radar,
/// and typhoon wind tracks centered on the farmer's active rice field.
class ZoomEarthCard extends StatelessWidget {
  const ZoomEarthCard({
    required this.field,
    super.key,
  });

  final FieldProfile field;

  Future<void> _launch(BuildContext context, Uri uri) async {
    final success = await ZoomEarthService.launchMap(uri);
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open Zoom Earth map. Please check your internet connection.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final lat = field.latitude;
    final lon = field.longitude;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0D1B2A),
            Color(0xFF1B263B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF415A77).withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D1B2A).withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header: LIVE Badge + Zoom Earth Branding ─────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFF00E676).withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00E676),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'LIVE SATELLITE',
                          style: TextStyle(
                            color: Color(0xFF00E676),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'ZOOM.EARTH',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Title & Field Coordinates ────────────────────────────────
              Text(
                s.zoomEarthTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${field.locationDisplay} (${lat.toStringAsFixed(2)}°N, ${lon.toStringAsFixed(2)}°E)',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                s.zoomEarthOpenPrompt,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),

              // ── 3 Interactive Layer Shortcuts ────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _LayerButton(
                      icon: Icons.water_drop_rounded,
                      iconColor: const Color(0xFF00B0FF),
                      label: s.zoomEarthRadar,
                      onTap: () => _launch(
                        context,
                        ZoomEarthService.radarUrl(lat: lat, lon: lon),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _LayerButton(
                      icon: Icons.satellite_alt_rounded,
                      iconColor: const Color(0xFFB388FF),
                      label: s.zoomEarthSatellite,
                      onTap: () => _launch(
                        context,
                        ZoomEarthService.satelliteUrl(lat: lat, lon: lon),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _LayerButton(
                      icon: Icons.cyclone_rounded,
                      iconColor: const Color(0xFFFFAB40),
                      label: s.zoomEarthWind,
                      onTap: () => _launch(
                        context,
                        ZoomEarthService.windUrl(lat: lat, lon: lon),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Primary Action Button ────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _launch(
                    context,
                    ZoomEarthService.radarUrl(lat: lat, lon: lon),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: Text(
                    s.zoomEarthExplore,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
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

class _LayerButton extends StatelessWidget {
  const _LayerButton({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
