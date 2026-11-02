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
    test('Default FieldProfile calculates correct maturity and growth stage',
        () {
      final profile = FieldProfile.defaultProfile();

      expect(profile.municipality, 'Ubay');
      expect(profile.province, 'Bohol');
      expect(profile.daysToMaturity, 110);
      expect(profile.currentDay, 42);
      expect(profile.growthStageKey, 'vegetative');
      expect(profile.daysUntilHarvest, 68);
      expect((profile.progressPercent * 100).round(), 38);
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

      // Location shows Ubay, Bohol by default
      expect(find.text('Ubay, Bohol'), findsOneWidget);

      // Tap on the location text to open the EditFieldSheet
      await tester.tap(find.text('Ubay, Bohol'));
      await tester.pumpAndSettle();

      // Verify sheet opened
      expect(find.byType(EditFieldSheet), findsOneWidget);
      expect(find.text('My Field Profile'), findsOneWidget);
      expect(find.text('Save Field Profile'), findsOneWidget);
      expect(find.text('Choose exact location on map'), findsOneWidget);

      // Ensure save button is visible and tap Save
      await tester.ensureVisible(find.text('Save Field Profile'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save Field Profile'));
      await tester.pumpAndSettle();

      // Sheet should be dismissed
      expect(find.byType(EditFieldSheet), findsNothing);
    });
  });
}
