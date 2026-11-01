// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:palayplan/main.dart';

void main() {
  testWidgets('PalayPlanApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PalayPlanApp());
    await tester.pump();

    // Verify splash screen renders title
    expect(find.text('PalayPlan'), findsOneWidget);

    // Fast-forward past the splash timer (2.5s)
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify home screen and leaf scanner entry point are present
    expect(find.text('Scan Rice Leaf Disease'), findsOneWidget);
  });
}
