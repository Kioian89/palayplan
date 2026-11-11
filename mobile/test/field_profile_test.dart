import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:palayplan/models/field_model.dart';
import 'package:palayplan/providers/field_provider.dart';
import 'package:palayplan/providers/language_provider.dart';
import 'package:palayplan/widgets/edit_field_sheet.dart';
import 'package:palayplan/screens/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('FieldProfile Model & Provider Logic', () {
    test('Default FieldProfile has no preset field values', () {
      final profile = FieldProfile.defaultProfile();

      expect(profile.fieldName, isEmpty);
      expect(profile.municipality, isEmpty);
      expect(profile.province, isEmpty);
      expect(profile.latitude, 0);
      expect(profile.longitude, 0);
      expect(profile.varietyName, isEmpty);
      expect(profile.fieldAreaHa, 0);
      expect(profile.isConfigured, isFalse);
      expect(profile.currentDay, 0);
      expect(profile.progressPercent, 0);
    });

    test('FieldProvider updates and persists profile in SharedPreferences',
        () async {
      final provider = FieldProvider();

      final updated = FieldProfile(
        fieldName: 'Pinitan 2',
        municipality: 'Science City of Muñoz',
        province: 'Nueva Ecija',
        latitude: 15.7167,
        longitude: 120.9000,
        hasCustomCoordinates: true,
        plantingDate: DateTime.now().subtract(const Duration(days: 20)),
        varietyName: 'NSIC Rc 160 (Tubigan 14)',
        daysToMaturity: 107,
        fieldAreaHa: 2.5,
      );

      await provider.updateField(updated);

      expect(provider.field.municipality, 'Science City of Muñoz');
      expect(provider.field.daysToMaturity, 107);
      expect(provider.field.fieldAreaHa, 2.5);
      expect(provider.field.hasCustomCoordinates, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('farmer_field_profile'), isNotNull);
      expect(prefs.getString('farmer_field_profile'), contains('Nueva Ecija'));
      expect(prefs.getString('farmer_field_profile'),
          contains('"hasCustomCoordinates":true'));
    });

    testWidgets(
        'Tapping location on HomeScreen opens EditFieldSheet and saves profile',
        (WidgetTester tester) async {
      final fieldProvider = FieldProvider();
      final langProvider = LanguageProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FieldProvider>.value(value: fieldProvider),
            ChangeNotifierProvider<LanguageProvider>.value(value: langProvider),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Location not set'), findsOneWidget);

      // Tap on the location text to open the EditFieldSheet
      await tester.tap(find.text('Location not set'));
      await tester.pumpAndSettle();

      // Verify sheet opened
      expect(find.byType(EditFieldSheet), findsOneWidget);
      expect(find.text('My Field Profile'), findsOneWidget);
      expect(find.text('Save Field Profile'), findsOneWidget);
      expect(find.text('Choose exact location on map'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(3));
      for (final finder in [
        find.byType(TextField).first,
        find.byType(TextField).at(1),
        find.byType(TextField).at(2),
      ]) {
        expect(tester.widget<TextField>(finder).controller!.text, isEmpty);
      }
      expect(find.text('Choose a rice variety'), findsOneWidget);
      expect(find.text('Select planting date'), findsOneWidget);

      // Saving an untouched first-run form must not create demo field data.
      await tester.ensureVisible(find.text('Save Field Profile'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save Field Profile'));
      await tester.pumpAndSettle();

      expect(find.byType(EditFieldSheet), findsOneWidget);
      expect(fieldProvider.field.isConfigured, isFalse);
    });
  });
}
