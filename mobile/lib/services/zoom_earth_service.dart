import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Helper service for launching Zoom Earth live satellite, radar, and wind maps
/// centered dynamically on the farmer's active rice field coordinates.
class ZoomEarthService {
  const ZoomEarthService._();

  static Uri radarUrl({
    required double lat,
    required double lon,
    int zoom = 8,
  }) {
    return Uri.parse(
      'https://zoom.earth/maps/radar/#view=$lat,$lon,${zoom}z',
    );
  }

  static Uri satelliteUrl({
    required double lat,
    required double lon,
    int zoom = 8,
  }) {
    return Uri.parse(
      'https://zoom.earth/maps/satellite/#view=$lat,$lon,${zoom}z',
    );
  }

  static Uri windUrl({
    required double lat,
    required double lon,
    int zoom = 7,
  }) {
    return Uri.parse(
      'https://zoom.earth/maps/wind-speed/#view=$lat,$lon,${zoom}z',
    );
  }

  static Future<bool> launchMap(Uri uri) async {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
      );
      if (launched) return true;
    } catch (e) {
      debugPrint('inAppBrowserView launch failed: $e, falling back to external app');
    }

    try {
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('externalApplication launch failed: $e');
      return false;
    }
  }
}
