import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:f_app/screens/calendar_screen.dart';
import 'package:f_app/providers/timezone_provider.dart';

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
  });

  testWidgets('CalendarScreen loads and displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => TimezoneProvider()),
        ],
        child: MaterialApp(
          home: const CalendarScreen(),
        ),
      ),
    );

    // Wait for the initial frame to render
    await tester.pump();

    // Verify that the screen shows loading indicator initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Verify the app bar title
    expect(find.text('Calendario F1 2025'), findsOneWidget);
  });

  testWidgets('CalendarScreen shows error state correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => TimezoneProvider()),
        ],
        child: MaterialApp(
          home: const CalendarScreen(),
        ),
      ),
    );

    // Wait for API call to complete (which will fail in test environment)
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Check if error state is displayed
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text('Errore nel caricamento'), findsOneWidget);
    expect(find.text('Riprova'), findsOneWidget);
  });
}
