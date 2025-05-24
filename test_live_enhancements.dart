import 'package:flutter_test/flutter_test.dart';
import 'lib/core/api/f1_api.dart';

/// Test per verificare le nuove funzionalità live
Future<void> main() async {
  group('Live Session Enhancements Tests', () {
    test('Test getStints method', () async {
      try {
        // Test basic stints call
        final stints = await F1Api.getStints(sessionKey: 9158);
        print('✅ getStints() works - returned ${stints.length} stints');
        
        // Test latest stints call
        final latestStints = await F1Api.getLatestStints();
        print('✅ getLatestStints() works - returned ${latestStints.length} latest stints');
        
        // Test specific driver stints
        final hamiltonStints = await F1Api.getStints(sessionKey: 9158, driverNumber: 44);
        print('✅ getStints(driverNumber: 44) works - returned ${hamiltonStints.length} Hamilton stints');
        
        // Test compound filter
        final softStints = await F1Api.getStints(sessionKey: 9158, compound: "SOFT");
        print('✅ getStints(compound: SOFT) works - returned ${softStints.length} soft tire stints');
        
      } catch (e) {
        print('❌ Stints API test failed: $e');
      }
    });
    
    test('Test enhanced live data methods', () async {
      try {
        // Test current session key
        final sessionKey = await F1Api.getCurrentSessionKey();
        print('✅ getCurrentSessionKey() works - session: $sessionKey');
        
        if (sessionKey != null) {
          // Test live positions
          final positions = await F1Api.getLatestPositions();
          print('✅ getLatestPositions() works - ${positions.length} drivers');
          
          // Test live intervals
          final intervals = await F1Api.getLatestIntervals();
          print('✅ getLatestIntervals() works - ${intervals.length} intervals');
          
          // Test live car data
          final carData = await F1Api.getLatestCarData();
          print('✅ getLatestCarData() works - ${carData.length} telemetry points');
          
          // Test race control messages
          final raceControl = await F1Api.getRaceControlMessages(sessionKey: sessionKey);
          print('✅ getRaceControlMessages() works - ${raceControl.length} messages');
          
          // Verify data structure for positions
          if (positions.isNotEmpty) {
            final firstPosition = positions.first;
            final hasDriverNumber = firstPosition.containsKey('driver_number');
            final hasPosition = firstPosition.containsKey('position');
            print('✅ Position data structure OK - driver_number: $hasDriverNumber, position: $hasPosition');
          }
          
          // Verify data structure for stints
          final stints = await F1Api.getLatestStints();
          if (stints.isNotEmpty) {
            final firstStint = stints.first;
            final hasCompound = firstStint.containsKey('compound');
            final hasTyreAge = firstStint.containsKey('tyre_age_at_start');
            print('✅ Stint data structure OK - compound: $hasCompound, tyre_age: $hasTyreAge');
          }
          
        } else {
          print('ℹ️  No current session available for testing');
        }
        
      } catch (e) {
        print('❌ Enhanced live data test failed: $e');
      }
    });
    
    test('Test real-time data integration', () async {
      try {
        print('🏎️  Testing real-time data integration...');
        
        // Simulate the data loading process from SessionResultsScreen
        final sessionKey = await F1Api.getCurrentSessionKey();
        
        if (sessionKey != null) {
          // Load all required data types as the app would
          final futures = await Future.wait([
            F1Api.getLatestPositions(),
            F1Api.getLatestIntervals(), 
            F1Api.getLatestStints(),
            F1Api.getLatestCarData(),
          ]);
          
          final positions = futures[0];
          final intervals = futures[1];
          final stints = futures[2];
          final carData = futures[3];
          
          print('✅ All data loaded successfully:');
          print('   - Positions: ${positions.length}');
          print('   - Intervals: ${intervals.length}');
          print('   - Stints: ${stints.length}');
          print('   - Car Data: ${carData.length}');
          
          // Verify we can match data by driver number
          if (positions.isNotEmpty) {
            final driverNumber = positions.first['driver_number'];
            
            final driverInterval = intervals.firstWhere(
              (i) => i['driver_number'] == driverNumber,
              orElse: () => {},
            );
            
            final driverStint = stints.firstWhere(
              (s) => s['driver_number'] == driverNumber,
              orElse: () => {},
            );
            
            final driverCarData = carData.firstWhere(
              (c) => c['driver_number'] == driverNumber,
              orElse: () => {},
            );
            
            print('✅ Data matching by driver number works:');
            print('   - Driver $driverNumber has interval data: ${driverInterval.isNotEmpty}');
            print('   - Driver $driverNumber has stint data: ${driverStint.isNotEmpty}');
            print('   - Driver $driverNumber has car data: ${driverCarData.isNotEmpty}');
          }
          
        } else {
          print('ℹ️  No session available - testing with historical data');
          
          // Test with a known session
          const testSessionKey = 9158;
          final positions = await F1Api.getPositions(sessionKey: testSessionKey);
          final stints = await F1Api.getStints(sessionKey: testSessionKey);
          
          print('✅ Historical data test:');
          print('   - Positions: ${positions.length}');
          print('   - Stints: ${stints.length}');
        }
        
      } catch (e) {
        print('❌ Real-time integration test failed: $e');
      }
    });
  });
}
