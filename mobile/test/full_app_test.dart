import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palayplan/main.dart';
import 'package:palayplan/screens/home_screen.dart';
import 'package:palayplan/screens/scan_screen.dart';
import 'package:palayplan/screens/result_screen.dart';
import 'package:palayplan/screens/weather_screen.dart';
import 'package:palayplan/screens/calendar_screen.dart';
import 'package:palayplan/screens/advisory_screen.dart';
import 'package:palayplan/services/disease_classifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Disease Prediction & Advice Logic', () {
    test('All 10 rice leaf conditions have proper names and non-empty advice', () {
      final conditions = [
        'bacterial_leaf_blight',
        'brown_spot',
        'brownspot',
        'healthy',
        'leaf_blast',
        'blast',
        'leaf_scald',
        'narrow_brown_spot',
        'neck_blast',
        'rice_hispa',
        'sheath_blight',
        'tungro',
      ];

      for (final cond in conditions) {
        final pred = DiseasePrediction(label: cond, confidence: 0.85);
        expect(pred.displayName.isNotEmpty, true, reason: 'Failed for $cond');
        expect(pred.treatmentTip.isNotEmpty, true, reason: 'Failed for $cond');
        expect(pred.treatmentTip, isNot(contains('unknown')));
      }
    });

    test('Handles unknown condition gracefully with fallback advice', () {
      const pred = DiseasePrediction(label: 'unknown_pest', confidence: 0.50);
      expect(pred.displayName, 'Unknown Pest');
      // Fallback tip mentions consulting an expert (DA Agricultural Technologist)
      expect(pred.treatmentTip, contains('Agricultural Technologist'));
    });
  });

  group('Full Application Screens & Navigation Flow', () {
    testWidgets('App launches at SplashScreen and transitions to HomeScreen', (WidgetTester tester) async {
      await tester.pumpWidget(const PalayPlanApp());
      await tester.pump();

      // 1. Verify SplashScreen is displayed
      expect(find.text('PalayPlan'), findsOneWidget);
      expect(find.text('Smart Agro-Weather & Rice Yield Optimization'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 2. Fast-forward past splash timer (2.5 seconds)
      await tester.pump(const Duration(milliseconds: 2600));
      await tester.pumpAndSettle();

      // 3. Verify HomeScreen is reached
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Scan Rice Leaf Disease'), findsOneWidget);
    });

    testWidgets('HomeScreen navigation buttons navigate to corresponding screens', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pump();

      // Helper: scroll until the text widget is visible, then tap it.
      Future<void> scrollAndTap(String text) async {
        await tester.scrollUntilVisible(
          find.text(text).first,
          200.0,
          scrollable: find.byType(Scrollable).first,
          maxScrolls: 100,
        );
        await tester.ensureVisible(find.text(text).first);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(find.text(text).first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
      }

      // Scan Leaf Disease navigation (in hero spotlight card near top)
      await scrollAndTap('Scan Rice Leaf Disease');
      expect(find.byType(ScanScreen), findsOneWidget);
      await tester.pageBack();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Weather forecast navigation
      await scrollAndTap('7-Day Weather Forecast');
      expect(find.byType(WeatherScreen), findsOneWidget);
      await tester.pageBack();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Cropping Calendar navigation
      await scrollAndTap('Cropping Calendar');
      expect(find.byType(CalendarScreen), findsOneWidget);
      await tester.pageBack();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Advisories navigation
      await scrollAndTap('All Advisories');
      expect(find.byType(AdvisoryScreen), findsOneWidget);
      await tester.pageBack();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('ScanScreen renders capture buttons and leaf guidance banner', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ScanScreen()));
      await tester.pump();

      expect(find.text('Rice Disease Scanner'), findsOneWidget);
      expect(find.textContaining('Take a close-up photo of a single rice leaf'), findsOneWidget);
      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('No photo selected yet'), findsOneWidget);
    });

    testWidgets('ResultScreen displays high-confidence diagnosis and treatment tip', (WidgetTester tester) async {
      // Create a 1x1 dummy transparent image byte buffer
      final dummyBytes = Uint8List.fromList([
        137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82,
        0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, 0, 0,
        0, 10, 73, 68, 65, 84, 120, 156, 99, 0, 1, 0, 0, 5, 0, 1, 13,
        10, 45, 180, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130
      ]);

      const pred = DiseasePrediction(
        label: 'bacterial_leaf_blight',
        confidence: 0.884,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ResultScreen(
            imageBytes: dummyBytes,
            prediction: pred,
          ),
        ),
      );
      await tester.pump();

      // Verify diagnosis title and confidence % (shown in the arc ring)
      expect(find.text('Bacterial Leaf Blight'), findsOneWidget);
      expect(find.text('88.4%'), findsOneWidget);

      // Verify recommended action tip (contains Filipino farming advice keywords)
      expect(find.text('Recommended Action'), findsOneWidget);
      expect(find.textContaining('nitrogen'), findsOneWidget);

      // Verify disclaimer
      expect(find.textContaining('This is a guide only'), findsOneWidget);
      expect(find.text('Scan Another Leaf'), findsOneWidget);
    });

    testWidgets('ResultScreen displays low-confidence threshold fallback (<60%)', (WidgetTester tester) async {
      final dummyBytes = Uint8List.fromList([
        137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82,
        0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, 0, 0,
        0, 10, 73, 68, 65, 84, 120, 156, 99, 0, 1, 0, 0, 5, 0, 1, 13,
        10, 45, 180, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130
      ]);

      const pred = DiseasePrediction(
        label: 'brown_spot',
        confidence: 0.45, // < 60% threshold
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ResultScreen(
            imageBytes: dummyBytes,
            prediction: pred,
          ),
        ),
      );
      await tester.pump();

      // Verify fallback guidance message (updated text in new UI)
      expect(find.text('Not confident enough to diagnose'), findsOneWidget);
      // Ensure specific diagnosis card is hidden when confidence is below 60%
      expect(find.text('Recommended Action'), findsNothing);
      expect(find.textContaining('This is a guide only'), findsOneWidget);
    });
  });
}

