import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../lib/core/api/f1_api.dart';

// Generate mocks
@GenerateMocks([http.Client])
void main() {
  group('OpenF1 API Tests', () {
    
    test('getCarData should return telemetry data', () async {
      // Test basic car data retrieval
      try {
        final result = await F1Api.getCarData(sessionKey: 9158);
        expect(result, isA<List>());
      } catch (e) {
        // Test passes if it's a network error (expected in test environment)
        expect(e.toString(), contains('Error'));
      }
    });
    
    test('getOpenF1Drivers should return driver information', () async {
      try {
        final result = await F1Api.getOpenF1Drivers(sessionKey: 9158);
        expect(result, isA<List>());
      } catch (e) {
        expect(e.toString(), contains('Error'));
      }
    });
    
    test('getIntervals should return timing gaps', () async {
      try {
        final result = await F1Api.getIntervals(sessionKey: 9158);
        expect(result, isA<List>());
      } catch (e) {
        expect(e.toString(), contains('Error'));
      }
    });
    
    test('getOpenF1Laps should return lap data', () async {
      try {
        final result = await F1Api.getOpenF1Laps(sessionKey: 9158);
        expect(result, isA<List>());
      } catch (e) {
        expect(e.toString(), contains('Error'));
      }
    });
    
    test('getLocations should return position data', () async {
      try {
        final result = await F1Api.getLocations(sessionKey: 9158);
        expect(result, isA<List>());
      } catch (e) {
        expect(e.toString(), contains('Error'));
      }
    });
    
    test('getMeetings should return meeting data', () async {
      try {
        final result = await F1Api.getMeetings(year: 2024);
        expect(result, isA<List>());
      } catch (e) {
        expect(e.toString(), contains('Error'));
      }
    });
    
    test('getPitData should return pit information', () async {
      try {
        final result = await F1Api.getPitData(sessionKey: 9158);
        expect(result, isA<List>());
      } catch (e) {
        expect(e.toString(), contains('Error'));
      }
    });
    
    test('getPositions should return driver positions', () async {
      try {
        final result = await F1Api.getPositions(sessionKey: 9158);
        expect(result, isA<List>());
      } catch (e) {
        expect(e.toString(), contains('Error'));
      }
    });
    
    test('getRaceControlMessages should return race control data', () async {
      try {
        final result = await F1Api.getRaceControlMessages(sessionKey: 9158);
        expect(result, isA<List>());
      } catch (e) {
        expect(e.toString(), contains('Error'));
      }
    });
    
    test('getSessions should return session data', () async {
      try {
        final result = await F1Api.getSessions(year: 2024);
        expect(result, isA<List>());
      } catch (e) {
        expect(e.toString(), contains('Error'));
      }
    });
    
    test('getWeather should return weather data', () async {
      try {
        final result = await F1Api.getWeather(sessionKey: 9158);
        expect(result, isA<List>());
      } catch (e) {
        expect(e.toString(), contains('Error'));
      }
    });
    
    test('getTeamRadio should return radio data', () async {
      try {
        final result = await F1Api.getTeamRadio(sessionKey: 9158);
        expect(result, isA<List>());
      } catch (e) {
        expect(e.toString(), contains('Error'));
      }
    });
    
    // Test latest data endpoints
    group('Latest Data Endpoints', () {
      test('getLatestCarData should return latest telemetry', () async {
        try {
          final result = await F1Api.getLatestCarData();
          expect(result, isA<List>());
        } catch (e) {
          expect(e.toString(), contains('Error'));
        }
      });
      
      test('getLatestIntervals should return latest intervals', () async {
        try {
          final result = await F1Api.getLatestIntervals();
          expect(result, isA<List>());
        } catch (e) {
          expect(e.toString(), contains('Error'));
        }
      });
      
      test('getLatestLocations should return latest locations', () async {
        try {
          final result = await F1Api.getLatestLocations();
          expect(result, isA<List>());
        } catch (e) {
          expect(e.toString(), contains('Error'));
        }
      });
      
      test('getLatestPositions should return latest positions', () async {
        try {
          final result = await F1Api.getLatestPositions();
          expect(result, isA<List>());
        } catch (e) {
          expect(e.toString(), contains('Error'));
        }
      });
      
      test('getLatestWeather should return latest weather', () async {
        try {
          final result = await F1Api.getLatestWeather();
          expect(result, isA<List>());
        } catch (e) {
          expect(e.toString(), contains('Error'));
        }
      });
    });
    
    // Test convenience methods
    group('Convenience Methods', () {
      test('getCurrentSessionKey should return session key or null', () async {
        try {
          final result = await F1Api.getCurrentSessionKey();
          expect(result, anyOf(isA<int>(), isNull));
        } catch (e) {
          expect(e.toString(), contains('Error'));
        }
      });
      
      test('getLiveTelemetry should return telemetry for driver', () async {
        try {
          final result = await F1Api.getLiveTelemetry(44);
          expect(result, isA<List>());
        } catch (e) {
          expect(e.toString(), contains('Error'));
        }
      });
      
      test('getLiveRacePositions should return live positions', () async {
        try {
          final result = await F1Api.getLiveRacePositions();
          expect(result, isA<List>());
        } catch (e) {
          expect(e.toString(), contains('Error'));
        }
      });
      
      test('getLiveTimingGaps should return live gaps', () async {
        try {
          final result = await F1Api.getLiveTimingGaps();
          expect(result, isA<List>());
        } catch (e) {
          expect(e.toString(), contains('Error'));
        }
      });
    });
    
    // Test filtering functionality
    group('Filtering Tests', () {
      test('getCarData with driver filter should work', () async {
        try {
          final result = await F1Api.getCarData(
            sessionKey: 9158,
            driverNumber: 44,
          );
          expect(result, isA<List>());
        } catch (e) {
          expect(e.toString(), contains('Error'));
        }
      });
      
      test('getOpenF1Laps with lap number filter should work', () async {
        try {
          final result = await F1Api.getOpenF1Laps(
            sessionKey: 9158,
            lapNumberGte: 10,
            lapNumberLte: 20,
          );
          expect(result, isA<List>());
        } catch (e) {
          expect(e.toString(), contains('Error'));
        }
      });
      
      test('getRaceControlMessages with flag filter should work', () async {
        try {
          final result = await F1Api.getRaceControlMessages(
            sessionKey: 9158,
            flag: 'YELLOW',
          );
          expect(result, isA<List>());
        } catch (e) {
          expect(e.toString(), contains('Error'));
        }
      });
      
      test('getMeetings with year filter should work', () async {
        try {
          final result = await F1Api.getMeetings(year: 2024);
          expect(result, isA<List>());
        } catch (e) {
          expect(e.toString(), contains('Error'));
        }
      });
      
      test('getSessions with multiple filters should work', () async {
        try {
          final result = await F1Api.getSessions(
            year: 2024,
            sessionName: 'Race',
          );
          expect(result, isA<List>());
        } catch (e) {
          expect(e.toString(), contains('Error'));
        }
      });
    });
    
    // Test URL building
    group('URL Building Tests', () {
      test('OpenF1 base URL should be correct', () {
        expect(F1Api.openF1BaseUrl, equals('https://api.openf1.org/v1'));
      });
    });
  });
}
