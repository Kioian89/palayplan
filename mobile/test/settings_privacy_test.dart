import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palayplan/providers/language_provider.dart';
import 'package:palayplan/screens/home_screen.dart';
import 'package:palayplan/screens/privacy_policy_screen.dart';
import 'package:palayplan/screens/settings_screen.dart';
import 'package:palayplan/widgets/language_picker_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Home opens Settings for guest users', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LanguageProvider(),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);

    // The guest text may be below the fold after the new Contact section was
    // added. Scroll down to make sure it is visible.
    await tester.scrollUntilVisible(
      find.text('You are using PalayPlan as a guest'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('You are using PalayPlan as a guest'), findsOneWidget);
  });

  testWidgets('Settings opens the privacy policy', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LanguageProvider(),
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );

    await tester.tap(find.text('How PalayPlan handles your information'));
    await tester.pumpAndSettle();

    expect(find.byType(PrivacyPolicyScreen), findsOneWidget);
    expect(find.text('Information used'), findsOneWidget);
    expect(find.textContaining('Firebase Authentication'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Your choices'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Your choices'), findsOneWidget);
  });

  testWidgets('Settings language picker updates the displayed language',
      (tester) async {
    final provider = LanguageProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider<LanguageProvider>.value(
        value: provider,
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );

    await tester.tap(find.text('Choose the language used in the app'));
    await tester.pumpAndSettle();
    expect(find.byType(LanguagePickerSheet), findsOneWidget);

    await tester.tap(find.text('Filipino'));
    await tester.pumpAndSettle();

    expect(provider.language, AppLanguage.filipino);
    expect(find.text('Piliin ang wikang gagamitin sa app'), findsOneWidget);
  });
}
