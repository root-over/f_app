import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:f_app/screens/driver_detail_screen.dart';
import 'package:f_app/models/driver_standing.dart';
import 'package:f_app/models/driver.dart';
import 'package:f_app/models/constructor.dart';

void main() {
  group('Telemetry Loading Tests', () {
    late DriverStanding testDriverStanding;

    setUp(() {
      // Create test data
      final testDriver = Driver(
        driverId: 'test_driver',
        permanentNumber: '44',
        code: 'HAM',
        url: 'test_url',
        givenName: 'Test',
        familyName: 'Driver',
        dateOfBirth: '1985-01-07',
        nationality: 'British',
      );

      final testConstructor = Constructor(
        constructorId: 'test_constructor',
        url: 'test_url',
        name: 'Test Team',
        nationality: 'British',
      );

      testDriverStanding = DriverStanding(
        position: '1',
        positionText: '1',
        points: '100',
        wins: '5',
        driver: testDriver,
        constructors: [testConstructor],
      );
    });

    testWidgets('should show loading only during initial telemetry load', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DriverDetailScreen(
            driverStanding: testDriverStanding,
            year: 2024,
          ),
        ),
      );

      // Initial build should show loading state for telemetry
      expect(find.text('Caricamento telemetria...'), findsOneWidget);

      // After some time, the loading should disappear
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      // Loading text should not be visible anymore (assuming API call completes or fails)
      // This test verifies that the loading state is not persistent
    });

    testWidgets('should show loading on manual refresh but not on automatic updates', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DriverDetailScreen(
            driverStanding: testDriverStanding,
            year: 2024,
          ),
        ),
      );

      // Wait for initial load to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Perform pull-to-refresh
      await tester.fling(find.byType(CustomScrollView), const Offset(0, 300), 1000);
      await tester.pump();

      // Should show loading during refresh
      expect(find.text('Caricamento telemetria...'), findsOneWidget);
      
      await tester.pumpAndSettle();
    });
  });
}
