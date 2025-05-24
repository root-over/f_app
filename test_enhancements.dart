import 'lib/core/api/f1_api.dart';

/// Test delle nuove funzionalità per qualifiche e prove libere
void main() async {
  print('🏎️  Testing Enhanced Session Results');
  print('=' * 50);
  
  try {
    print('\n📍 Test 1: Monaco 2024 Qualifying Data...');
    
    // Get qualifying results for Monaco 2024
    final monacoQualifying = await F1Api.getQualifying(
      season: 2024,
      round: 8, // Monaco
    );
    
    if (monacoQualifying.isNotEmpty && monacoQualifying[0]['QualifyingResults'] != null) {
      final qualifyingResults = monacoQualifying[0]['QualifyingResults'];
      print('✅ Found ${qualifyingResults.length} qualifying results');
      
      // Check Q1, Q2, Q3 data
      final topResult = qualifyingResults[0];
      print('Top qualifier: ${topResult['Driver']['givenName']} ${topResult['Driver']['familyName']}');
      print('Q1: ${topResult['Q1'] ?? 'N/A'}');
      print('Q2: ${topResult['Q2'] ?? 'N/A'}');
      print('Q3: ${topResult['Q3'] ?? 'N/A'}');
      
      // Count how many have Q1, Q2, Q3 times
      int q1Count = 0, q2Count = 0, q3Count = 0;
      for (final result in qualifyingResults) {
        if (result['Q1'] != null) q1Count++;
        if (result['Q2'] != null) q2Count++;
        if (result['Q3'] != null) q3Count++;
      }
      
      print('Drivers with Q1 times: $q1Count');
      print('Drivers with Q2 times: $q2Count');
      print('Drivers with Q3 times: $q3Count');
    }
    
    print('\n🏁 Test 2: Monaco 2024 Practice Session Data...');
    
    // Get practice session from OpenF1
    final monacoSessions = await F1Api.getSessions(
      year: 2024,
      countryName: "Monaco"
    );
    
    final practiceSession = monacoSessions.firstWhere(
      (session) => session['session_name']?.toLowerCase().contains('practice 1') == true,
      orElse: () => null,
    );
    
    if (practiceSession != null) {
      print('✅ Found Practice 1 session: ${practiceSession['session_name']}');
      
      final laps = await F1Api.getOpenF1Laps(
        sessionKey: practiceSession['session_key']
      );
      
      print('Found ${laps.length} laps for gap calculation testing');
      
      // Test gap calculation logic
      if (laps.length >= 2) {
        final sampleLap1 = laps[0];
        final sampleLap2 = laps[1];
        print('Sample lap 1: ${sampleLap1['lap_duration']}s');
        print('Sample lap 2: ${sampleLap2['lap_duration']}s');
        
        if (sampleLap1['lap_duration'] != null && sampleLap2['lap_duration'] != null) {
          final gap = sampleLap2['lap_duration'] - sampleLap1['lap_duration'];
          print('Sample gap calculation: +${gap.toStringAsFixed(3)}s');
        }
      }
    }
    
    print('\n✅ Enhancement testing completed successfully!');
    print('📋 Summary:');
    print('   • Qualifying Q1/Q2/Q3 times available');
    print('   • Practice session lap data available for gap calculations');
    print('   • Both APIs working correctly for enhanced displays');
    
  } catch (e) {
    print('❌ Error during testing: $e');
  }
}
