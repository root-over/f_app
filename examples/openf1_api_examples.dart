/// OpenF1 API Usage Examples
/// 
/// This file demonstrates how to use the OpenF1 API endpoints integrated
/// into the F1Api class. OpenF1 provides real-time and historical F1 data
/// including telemetry, timing, positions, and race control information.
/// 
/// For complete documentation, visit: https://openf1.org/

import '../lib/core/api/f1_api.dart';

void main() async {
  await demonstrateOpenF1Features();
}

/// Comprehensive demonstration of OpenF1 API features
Future<void> demonstrateOpenF1Features() async {
  print('🏎️  OpenF1 API Examples\n');
  
  try {
    // =======================================================================
    // 1. GET BASIC SESSION AND MEETING INFORMATION
    // =======================================================================
    
    print('📅 Getting 2024 meetings and sessions...');
    
    // Get all 2024 meetings (Grand Prix weekends)
    final meetings2024 = await F1Api.getMeetings(year: 2024);
    if (meetings2024.isNotEmpty) {
      final lastMeeting = meetings2024.last;
      print('Last 2024 meeting: ${lastMeeting['meeting_name']} in ${lastMeeting['country_name']}');
      
      // Get sessions for this meeting
      final sessions = await F1Api.getSessions(year: 2024, countryName: lastMeeting['country_name']);
      print('Sessions available: ${sessions.length}');
      
      if (sessions.isNotEmpty) {
        final raceSession = sessions.firstWhere(
          (session) => session['session_name'] == 'Race',
          orElse: () => sessions.first,
        );
        final sessionKey = raceSession['session_key'];
        
        print('Using session: ${raceSession['session_name']} (Key: $sessionKey)\n');
        
        // =================================================================
        // 2. GET LIVE/LATEST DATA
        // =================================================================
        
        print('⚡ Getting latest live data...');
        
        // Get latest car positions
        final latestPositions = await F1Api.getLatestPositions();
        print('Latest positions available: ${latestPositions.length} drivers');
        
        // Get latest timing intervals
        final latestIntervals = await F1Api.getLatestIntervals();
        print('Latest intervals available: ${latestIntervals.length} entries');
        
        // Get latest car telemetry
        final latestCarData = await F1Api.getLatestCarData();
        print('Latest car data available: ${latestCarData.length} entries');
        
        // Get latest car locations
        final latestLocations = await F1Api.getLatestLocations();
        print('Latest locations available: ${latestLocations.length} entries');
        
        print('');
        
        // =================================================================
        // 3. GET DRIVER-SPECIFIC DATA
        // =================================================================
        
        print('👨‍🏎️  Getting driver-specific data...');
        
        // Get drivers for this session
        final drivers = await F1Api.getOpenF1Drivers(sessionKey: sessionKey);
        if (drivers.isNotEmpty) {
          final hamilton = drivers.firstWhere(
            (driver) => driver['name_acronym'] == 'HAM',
            orElse: () => drivers.first,
          );
          
          final driverNumber = hamilton['driver_number'];
          print('Analyzing data for: ${hamilton['full_name']} (#$driverNumber)');
          
          // Get Hamilton's lap data
          final hamiltonLaps = await F1Api.getOpenF1Laps(
            sessionKey: sessionKey,
            driverNumber: driverNumber,
          );
          print('${hamilton['name_acronym']} laps available: ${hamiltonLaps.length}');
          
          // Get Hamilton's car data (telemetry)
          final hamiltonCarData = await F1Api.getCarData(
            sessionKey: sessionKey,
            driverNumber: driverNumber,
          );
          print('${hamilton['name_acronym']} telemetry points: ${hamiltonCarData.length}');
          
          // Get Hamilton's positions
          final hamiltonPositions = await F1Api.getPositions(
            sessionKey: sessionKey,
            driverNumber: driverNumber,
          );
          print('${hamilton['name_acronym']} position changes: ${hamiltonPositions.length}');
          
          // Get Hamilton's location data
          final hamiltonLocations = await F1Api.getLocations(
            sessionKey: sessionKey,
            driverNumber: driverNumber,
          );
          print('${hamilton['name_acronym']} location points: ${hamiltonLocations.length}');
        }
        
        print('');
        
        // =================================================================
        // 4. GET RACE CONTROL AND PIT DATA
        // =================================================================
        
        print('🚩 Getting race control and pit data...');
        
        // Get race control messages
        final raceControlMessages = await F1Api.getRaceControlMessages(sessionKey: sessionKey);
        print('Race control messages: ${raceControlMessages.length}');
        
        // Get yellow flag messages specifically
        final yellowFlags = await F1Api.getRaceControlMessages(
          sessionKey: sessionKey,
          flag: 'YELLOW',
        );
        print('Yellow flag incidents: ${yellowFlags.length}');
        
        // Get pit stop data
        final pitData = await F1Api.getPitData(sessionKey: sessionKey);
        print('Pit stop entries: ${pitData.length}');
        
        print('');
        
        // =================================================================
        // 5. GET WEATHER DATA
        // =================================================================
        
        print('🌤️  Getting weather data...');
        
        // Get weather for this session
        final weather = await F1Api.getWeather(sessionKey: sessionKey);
        if (weather.isNotEmpty) {
          final latestWeather = weather.last;
          print('Track temp: ${latestWeather['track_temperature']}°C');
          print('Air temp: ${latestWeather['air_temperature']}°C');
          print('Humidity: ${latestWeather['humidity']}%');
          print('Pressure: ${latestWeather['pressure']} mbar');
        }
        
        // Get latest weather
        final latestWeather = await F1Api.getLatestWeather();
        print('Latest weather entries: ${latestWeather.length}');
        
        print('');
        
        // =================================================================
        // 6. CONVENIENCE METHODS FOR LIVE DATA
        // =================================================================
        
        print('🔴 Using convenience methods for live data...');
        
        // Get current session key
        final currentSessionKey = await F1Api.getCurrentSessionKey();
        print('Current session key: $currentSessionKey');
        
        // Get live race positions
        final livePositions = await F1Api.getLiveRacePositions();
        print('Live race positions: ${livePositions.length} drivers');
        
        // Get live timing gaps
        final liveGaps = await F1Api.getLiveTimingGaps();
        print('Live timing gaps: ${liveGaps.length} entries');
        
        // Get live telemetry for a specific driver (Hamilton #44)
        final liveTelemetry = await F1Api.getLiveTelemetry(44);
        print('Live telemetry for #44: ${liveTelemetry.length} data points');
        
        print('');
        
        // =================================================================
        // 7. ADVANCED FILTERING EXAMPLES
        // =================================================================
        
        print('🔍 Advanced filtering examples...');
        
        // Get lap data for laps 10-20
        final middleLaps = await F1Api.getOpenF1Laps(
          sessionKey: sessionKey,
          lapNumberGte: 10,
          lapNumberLte: 20,
        );
        print('Laps 10-20 data: ${middleLaps.length} entries');
        
        // Get positions for P1 only
        final leaderPositions = await F1Api.getPositions(
          sessionKey: sessionKey,
          position: 1,
        );
        print('P1 position changes: ${leaderPositions.length} entries');
        
        // Get data for Mercedes team
        final mercedesDrivers = await F1Api.getOpenF1Drivers(
          sessionKey: sessionKey,
          teamName: 'Mercedes',
        );
        print('Mercedes drivers in session: ${mercedesDrivers.length}');
        
        print('');
        
        // =================================================================
        // 8. TEAM RADIO (if available)
        // =================================================================
        
        print('📻 Attempting to get team radio...');
        
        try {
          final teamRadio = await F1Api.getTeamRadio(sessionKey: sessionKey);
          print('Team radio messages: ${teamRadio.length}');
        } catch (e) {
          print('Team radio not available (may require special access): $e');
        }
        
        print('');
      }
    }
    
    print('✅ OpenF1 API demonstration completed successfully!');
    
  } catch (e) {
    print('❌ Error during OpenF1 API demonstration: $e');
  }
}

/// Example: Real-time race monitoring setup
Future<void> realTimeRaceMonitoring() async {
  print('🏎️  Setting up real-time race monitoring...\n');
  
  try {
    // Get current session
    final sessionKey = await F1Api.getCurrentSessionKey();
    if (sessionKey == null) {
      print('No active session found');
      return;
    }
    
    print('Monitoring session: $sessionKey');
    
    // Simulate real-time monitoring loop
    for (int i = 0; i < 5; i++) {
      print('\n--- Update ${i + 1} ---');
      
      // Get latest positions
      final positions = await F1Api.getLatestPositions();
      if (positions.isNotEmpty) {
        print('Leader: Driver #${positions.first['driver_number']}');
      }
      
      // Get latest intervals
      final intervals = await F1Api.getLatestIntervals();
      if (intervals.length >= 2) {
        print('Gap to leader: ${intervals[1]['interval']}');
      }
      
      // Get latest race control messages
      final raceControl = await F1Api.getRaceControlMessages(sessionKey: sessionKey);
      if (raceControl.isNotEmpty) {
        final latestMessage = raceControl.last;
        print('Latest race control: ${latestMessage['message']}');
      }
      
      // Wait before next update (in real app, this would be based on data freshness)
      await Future.delayed(Duration(seconds: 2));
    }
    
  } catch (e) {
    print('Error in real-time monitoring: $e');
  }
}

/// Example: Detailed telemetry analysis
Future<void> detailedTelemetryAnalysis(int sessionKey, int driverNumber) async {
  print('📊 Detailed telemetry analysis for driver #$driverNumber\n');
  
  try {
    // Get all car data for the driver
    final carData = await F1Api.getCarData(
      sessionKey: sessionKey,
      driverNumber: driverNumber,
    );
    
    if (carData.isEmpty) {
      print('No telemetry data available');
      return;
    }
    
    print('Total telemetry points: ${carData.length}');
    
    // Analyze speed data
    final speeds = carData
        .where((data) => data['speed'] != null)
        .map<double>((data) => (data['speed'] as num).toDouble())
        .toList();
    
    if (speeds.isNotEmpty) {
      final maxSpeed = speeds.reduce((a, b) => a > b ? a : b);
      final avgSpeed = speeds.reduce((a, b) => a + b) / speeds.length;
      print('Max speed: ${maxSpeed.toStringAsFixed(1)} km/h');
      print('Average speed: ${avgSpeed.toStringAsFixed(1)} km/h');
    }
    
    // Analyze throttle data
    final throttleData = carData
        .where((data) => data['throttle'] != null)
        .map<double>((data) => (data['throttle'] as num).toDouble())
        .toList();
    
    if (throttleData.isNotEmpty) {
      final avgThrottle = throttleData.reduce((a, b) => a + b) / throttleData.length;
      print('Average throttle: ${avgThrottle.toStringAsFixed(1)}%');
    }
    
    // Get corresponding location data
    final locations = await F1Api.getLocations(
      sessionKey: sessionKey,
      driverNumber: driverNumber,
    );
    
    print('Location data points: ${locations.length}');
    
  } catch (e) {
    print('Error in telemetry analysis: $e');
  }
}
