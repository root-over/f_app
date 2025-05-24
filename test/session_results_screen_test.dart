import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:f_app/screens/session_results_screen.dart';
import 'package:f_app/models/race.dart';

void main() {
  group('SessionResultsScreen', () {
    late Race testRace;
    late RaceSession testSession;

    setUp(() {
      testRace = Race(
        season: '2024',
        round: '1',
        url: 'http://test.com',
        raceName: 'Test Grand Prix',
        circuit: Circuit(
          circuitId: 'test',
          url: 'http://test.com',
          circuitName: 'Test Circuit',
          location: Location(
            lat: '0.0',
            long: '0.0',
            locality: 'Test City',
            country: 'Test Country',
          ),
        ),
        date: '2024-03-10',
        time: '14:00:00Z',
        sessions: [
          RaceSession(name: 'Prima Prova Libera', date: '2024-03-08', time: '11:30:00Z'),
          RaceSession(name: 'Seconda Prova Libera', date: '2024-03-08', time: '15:00:00Z'),
          RaceSession(name: 'Terza Prova Libera', date: '2024-03-09', time: '12:30:00Z'),
          RaceSession(name: 'Qualifiche', date: '2024-03-09', time: '16:00:00Z'),
          RaceSession(name: 'Gara', date: '2024-03-10', time: '14:00:00Z'),
        ],
      );

      testSession = RaceSession(
        name: 'Prima Prova Libera',
        date: '2024-03-08',
        time: '11:30:00Z',
      );
    });

    testWidgets('should create SessionResultsScreen widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SessionResultsScreen(
            race: testRace,
            session: testSession,
          ),
        ),
      );

      // Verify the widget is created and shows the session name
      expect(find.text('Prima Prova Libera'), findsOneWidget);
      expect(find.text('Test Grand Prix'), findsOneWidget);
    });

    testWidgets('should show loading indicator initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SessionResultsScreen(
            race: testRace,
            session: testSession,
          ),
        ),
      );

      // Should show loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show refresh button for live sessions', (WidgetTester tester) async {
      // Create a session that would be considered "live" (within the time window)
      final now = DateTime.now();
      final liveSession = RaceSession(
        name: 'Prova Live',
        date: now.toIso8601String().split('T')[0],
        time: '${now.toIso8601String().split('T')[1]}Z',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SessionResultsScreen(
            race: testRace,
            session: liveSession,
          ),
        ),
      );

      // The refresh button should be present in the app bar for live sessions
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });
  });
}
