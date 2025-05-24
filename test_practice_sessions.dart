import 'lib/core/api/f1_api.dart';

/// Test script to verify practice session functionality
void main() async {
  print('🏎️  Testing Practice Session Implementation');
  print('=' * 50);
  
  try {
    // Test 1: Check if we can get Monaco sessions for 2024
    print('\n📍 Test 1: Getting Monaco sessions for 2024...');
    final monacoSessions = await F1Api.getSessions(
      year: 2024,
      countryName: "Monaco"
    );
    
    print('Found ${monacoSessions.length} Monaco sessions');
    for (final session in monacoSessions) {
      print('  - ${session['session_name']} (Key: ${session['session_key']})');
    }
    
    // Test 2: Find Practice 1 session
    print('\n🏁 Test 2: Looking for Practice 1 session...');
    final practiceSession = monacoSessions.firstWhere(
      (session) => session['session_name']?.toLowerCase().contains('practice 1') == true,
      orElse: () => null,
    );
    
    if (practiceSession != null) {
      print('✅ Found Practice 1 session: ${practiceSession['session_name']}');
      print('   Session Key: ${practiceSession['session_key']}');
      
      // Test 3: Get drivers for this session
      print('\n👥 Test 3: Getting drivers for Practice 1...');
      final drivers = await F1Api.getOpenF1Drivers(
        sessionKey: practiceSession['session_key']
      );
      print('Found ${drivers.length} drivers');
      
      // Test 4: Get lap data for this session
      print('\n⏱️  Test 4: Getting lap data for Practice 1...');
      final laps = await F1Api.getOpenF1Laps(
        sessionKey: practiceSession['session_key']
      );
      print('Found ${laps.length} laps');
      
      if (laps.isNotEmpty) {
        print('Sample lap data:');
        final sampleLap = laps.first;
        print('  Driver: ${sampleLap['driver_number']}');
        print('  Lap Time: ${sampleLap['lap_duration']}');
        print('  Lap Number: ${sampleLap['lap_number']}');
      }
      
      print('\n✅ All tests passed! Practice session implementation should work.');
    } else {
      print('❌ Could not find Practice 1 session for Monaco 2024');
    }
    
  } catch (e) {
    print('❌ Error during testing: $e');
  }
}
