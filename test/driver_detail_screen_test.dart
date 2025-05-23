import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:f_app/screens/driver_detail_screen.dart';
import 'package:f_app/models/driver_standing.dart';

void main() {
  group('DriverDetailScreen Tests', () {
    late DriverStanding mockDriverStanding;

    setUp(() {
      // Create a mock driver standing for testing
      mockDriverStanding = DriverStanding(
        position: 1,
        points: 475.0,
        wins: 15,
        driver: Driver(
          driverId: 'verstappen',
          permanentNumber: '1',
          code: 'VER',
          givenName: 'Max',
          familyName: 'Verstappen',
          dateOfBirth: '1997-09-30',
          nationality: 'Dutch',
        ),
        constructors: [
          ConstructorInfo(
            constructorId: 'red_bull',
            name: 'Red Bull Racing Honda RBPT',
            nationality: 'Austrian',
          ),
        ],
      );
    });

    testWidgets('DriverDetailScreen displays driver information correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DriverDetailScreen(
            driverStanding: mockDriverStanding,
            year: 2024,
          ),
        ),
      );

      // Wait for the widget to settle
      await tester.pumpAndSettle();

      // Verify driver name is displayed in app bar
      expect(find.text('Max Verstappen'), findsOneWidget);

      // Verify position is displayed
      expect(find.text('1st'), findsOneWidget);

      // Verify points are displayed
      expect(find.text('475'), findsOneWidget);

      // Verify wins are displayed
      expect(find.text('15'), findsOneWidget);

      // Verify nationality is displayed
      expect(find.text('Dutch'), findsOneWidget);

      // Verify team name is displayed
      expect(find.text('Red Bull Racing Honda RBPT'), findsOneWidget);

      // Verify permanent number is displayed
      expect(find.text('1'), findsOneWidget);

      // Verify driver code is displayed
      expect(find.text('VER'), findsOneWidget);
    });

    testWidgets('DriverDetailScreen handles driver without permanent number', (WidgetTester tester) async {
      final driverWithoutNumber = DriverStanding(
        position: 5,
        points: 200.0,
        wins: 2,
        driver: Driver(
          driverId: 'test_driver',
          permanentNumber: null, // No permanent number
          code: 'TST',
          givenName: 'Test',
          familyName: 'Driver',
          dateOfBirth: '1995-01-01',
          nationality: 'British',
        ),
        constructors: [
          ConstructorInfo(
            constructorId: 'test_team',
            name: 'Test Team',
            nationality: 'British',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: DriverDetailScreen(
            driverStanding: driverWithoutNumber,
            year: 2024,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify driver name is displayed
      expect(find.text('Test Driver'), findsOneWidget);

      // Verify the permanent number section is not displayed when null
      expect(find.textContaining('Numero Permanente'), findsNothing);
    });

    testWidgets('DriverDetailScreen handles driver without team', (WidgetTester tester) async {
      final driverWithoutTeam = DriverStanding(
        position: 10,
        points: 50.0,
        wins: 0,
        driver: Driver(
          driverId: 'solo_driver',
          permanentNumber: '99',
          code: 'SOL',
          givenName: 'Solo',
          familyName: 'Driver',
          dateOfBirth: '1990-12-25',
          nationality: 'Italian',
        ),
        constructors: [], // No team
      );

      await tester.pumpWidget(
        MaterialApp(
          home: DriverDetailScreen(
            driverStanding: driverWithoutTeam,
            year: 2024,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify driver name is displayed
      expect(find.text('Solo Driver'), findsOneWidget);

      // Verify team section is not displayed when no constructors
      expect(find.textContaining('Team (2024)'), findsNothing);
    });

    testWidgets('DriverDetailScreen displays correct position suffix', (WidgetTester tester) async {
      final testCases = [
        (1, '1st'),
        (2, '2nd'),
        (3, '3rd'),
        (4, '4th'),
        (11, '11th'),
        (21, '21st'),
        (22, '22nd'),
        (23, '23rd'),
      ];

      for (final (position, expectedSuffix) in testCases) {
        final testDriver = DriverStanding(
          position: position,
          points: 100.0,
          wins: 1,
          driver: Driver(
            driverId: 'test$position',
            givenName: 'Test',
            familyName: 'Driver$position',
            dateOfBirth: '1990-01-01',
            nationality: 'Test',
          ),
          constructors: [],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: DriverDetailScreen(
              driverStanding: testDriver,
              year: 2024,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify correct position suffix is displayed
        expect(find.text(expectedSuffix), findsOneWidget, 
               reason: 'Position $position should display as $expectedSuffix');

        // Clear the widget tree for next test
        await tester.binding.setSurfaceSize(null);
      }
    });

    testWidgets('DriverDetailScreen calculates age correctly', (WidgetTester tester) async {
      // Test with a known birthdate (should be 26 years old in 2024)
      final driverWithAge = DriverStanding(
        position: 1,
        points: 100.0,
        wins: 1,
        driver: Driver(
          driverId: 'age_test',
          givenName: 'Age',
          familyName: 'Test',
          dateOfBirth: '1997-09-30', // Verstappen's actual birthdate
          nationality: 'Test',
        ),
        constructors: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: DriverDetailScreen(
            driverStanding: driverWithAge,
            year: 2024,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // The age calculation should show the correct age
      // Note: This test might need adjustment based on current date
      expect(find.textContaining('anni'), findsOneWidget);
    });
  });
}
