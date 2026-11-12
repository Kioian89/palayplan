import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palayplan/providers/field_provider.dart';
import 'package:palayplan/providers/language_provider.dart';
import 'package:palayplan/screens/yield_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('YieldScreen renders field info and estimate button initially', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => FieldProvider()),
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ],
        child: const MaterialApp(
          home: YieldScreen(),
        ),
      ),
    );
    await tester.pump();

    // Verify Title and Field Summary
    expect(find.text('Yield Estimator'), findsOneWidget);
    expect(find.text('ACTIVE FIELD'), findsOneWidget);
    expect(find.text('Estimate Yield'), findsOneWidget);
    expect(find.text('How It Works'), findsOneWidget);
  });
}
