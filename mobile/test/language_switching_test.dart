import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:palayplan/providers/language_provider.dart';
import 'package:palayplan/l10n/app_strings.dart';
import 'package:palayplan/widgets/language_picker_sheet.dart';
import 'package:palayplan/screens/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LanguageProvider and AppStrings Translations', () {
    test('Defaults to English and returns English strings', () {
      final provider = LanguageProvider();
      expect(provider.language, AppLanguage.english);

      final strings = AppStrings.of(_DummyContext());
      expect(strings.featScan, 'Scan Rice Leaf Disease');
      expect(strings.featFertilizer, 'Fertilizer Schedule');
      expect(strings.featWeather, '7-Day Weather Forecast');
      expect(strings.scanTitle, 'Rice Disease Scanner');
      expect(strings.resultHealthy, 'HEALTHY CROP');
      expect(strings.diseaseName('bacterial_leaf_blight'), 'Bacterial Leaf Blight');
    });

    test('Switching to Filipino (Tagalog) translates labels and agronomic advice', () async {
      final provider = LanguageProvider();
      await provider.setLanguage(AppLanguage.filipino);

      expect(provider.language, AppLanguage.filipino);
      expect(provider.language.code, 'fil');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_language'), 'fil');
    });

    test('Switching to Bisaya (Cebuano) translates labels and agronomic advice', () async {
      final provider = LanguageProvider();
      await provider.setLanguage(AppLanguage.bisaya);

      expect(provider.language, AppLanguage.bisaya);
      expect(provider.language.code, 'ceb');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_language'), 'ceb');
    });

    testWidgets('Tapping Language Switcher in HomeScreen opens picker and switches language to Bisaya',
        (WidgetTester tester) async {
      final provider = LanguageProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<LanguageProvider>.value(
          value: provider,
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pump();

      // Verify the EN language pill is displayed
      final langPill = find.text('EN');
      expect(langPill, findsOneWidget);

      // Tap the pill to open the sheet
      await tester.tap(langPill);
      await tester.pumpAndSettle();

      // Verify the LanguagePickerSheet opened with all 3 choices
      expect(find.byType(LanguagePickerSheet), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Filipino'), findsOneWidget);
      expect(find.text('Bisaya'), findsOneWidget);

      // Select Bisaya
      await tester.tap(find.text('Bisaya'));
      await tester.pumpAndSettle();

      // Picker sheet should close
      expect(find.byType(LanguagePickerSheet), findsNothing);

      // Provider language should now be Bisaya
      expect(provider.language, AppLanguage.bisaya);

      // Language pill should now show 'CEB'
      expect(find.text('CEB'), findsOneWidget);
    });
  });
}

class _DummyContext extends Fake implements BuildContext {}
