import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palayplan/models/field_model.dart';
import 'package:palayplan/providers/language_provider.dart';
import 'package:palayplan/services/zoom_earth_service.dart';
import 'package:palayplan/widgets/zoom_earth_card.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ZoomEarthService URL Generation', () {
    test('generates valid radar, satellite, and wind URLs for field coordinates', () {
      const lat = 10.3157;
      const lon = 123.8854;

      final radar = ZoomEarthService.radarUrl(lat: lat, lon: lon);
      expect(radar.toString(), contains('zoom.earth/maps/radar/#view=10.3157,123.8854,8z'));

      final satellite = ZoomEarthService.satelliteUrl(lat: lat, lon: lon);
      expect(satellite.toString(), contains('zoom.earth/maps/satellite/#view=10.3157,123.8854,8z'));

      final wind = ZoomEarthService.windUrl(lat: lat, lon: lon);
      expect(wind.toString(), contains('zoom.earth/maps/wind-speed/#view=10.3157,123.8854,7z'));
    });
  });

  group('ZoomEarthCard Widget Test', () {
    testWidgets('renders live radar badge, field coordinates, and action buttons', (WidgetTester tester) async {
      final field = FieldProfile.defaultProfile().copyWith(
        municipality: 'Ubay',
        province: 'Bohol',
        latitude: 10.3157,
        longitude: 123.8854,
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ZoomEarthCard(field: field),
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify badges and branding
      expect(find.text('LIVE SATELLITE'), findsOneWidget);
      expect(find.text('ZOOM.EARTH'), findsOneWidget);
      expect(find.text('Live Satellite & Radar'), findsOneWidget);
      expect(find.textContaining('Ubay, Bohol'), findsOneWidget);
      expect(find.textContaining('10.32°N, 123.89°E'), findsOneWidget);

      // Verify layer buttons
      expect(find.text('Rain Radar'), findsOneWidget);
      expect(find.text('Satellite'), findsOneWidget);
      expect(find.text('Wind & Typhoon'), findsOneWidget);
      expect(find.text('Explore on Zoom Earth'), findsOneWidget);
    });
  });
}
