# OpenF1 API Integration

This document provides comprehensive documentation for the OpenF1 API endpoints integrated into the F1Api class. OpenF1 provides real-time and historical Formula 1 data with high-frequency telemetry, timing, and positional data.

## 🏎️ Overview

The OpenF1 API offers:
- **Real-time telemetry** (~3.7Hz sample rate)
- **Live timing and gaps** between drivers
- **3D car positions** on track
- **Race control messages** (flags, safety car, incidents)
- **Driver radio communications**
- **Pit lane timing data**
- **Weather information**
- **Comprehensive session data**

**Base URL**: `https://api.openf1.org/v1/`

## 📊 Available Endpoints

### 1. Car Data (Telemetry)
Get real-time car telemetry data sampled at approximately 3.7Hz.

```dart
// Get all car data for session
final carData = await F1Api.getCarData(sessionKey: 9158);

// Get car data for specific driver
final hamiltonData = await F1Api.getCarData(sessionKey: 9158, driverNumber: 44);

// Get latest car data
final latestData = await F1Api.getLatestCarData();
```

**Available data includes**:
- Speed (km/h)
- Throttle (%)
- Brake (%)
- DRS status
- Gear
- RPM
- And more...

### 2. Drivers
Get driver information for sessions including team affiliations.

```dart
// Get all drivers for session
final drivers = await F1Api.getOpenF1Drivers(sessionKey: 9158);

// Get specific driver
final hamilton = await F1Api.getOpenF1Drivers(driverNumber: 44);

// Get drivers by team
final mercedesDrivers = await F1Api.getOpenF1Drivers(teamName: "Mercedes");
```

### 3. Intervals (Timing Gaps)
Get real-time gap data showing intervals between drivers during races.

```dart
// Get all intervals for session
final intervals = await F1Api.getIntervals(sessionKey: 9158);

// Get intervals for specific driver
final hamiltonIntervals = await F1Api.getIntervals(sessionKey: 9158, driverNumber: 44);

// Get latest intervals
final latestIntervals = await F1Api.getLatestIntervals();
```

### 4. Laps
Get comprehensive lap data including sector times and lap times.

```dart
// Get all laps for session
final laps = await F1Api.getOpenF1Laps(sessionKey: 9158);

// Get specific driver's laps
final hamiltonLaps = await F1Api.getOpenF1Laps(sessionKey: 9158, driverNumber: 44);

// Get specific lap
final lap10 = await F1Api.getOpenF1Laps(sessionKey: 9158, lapNumber: 10);

// Get laps 10-20
final middleLaps = await F1Api.getOpenF1Laps(
  sessionKey: 9158,
  lapNumberGte: 10,
  lapNumberLte: 20,
);
```

### 5. Location (3D Positions)
Get 3D positions of cars on track sampled at approximately 3.7Hz.

```dart
// Get all location data for session
final locations = await F1Api.getLocations(sessionKey: 9158);

// Get location data for specific driver
final hamiltonLocation = await F1Api.getLocations(sessionKey: 9158, driverNumber: 44);

// Get latest locations
final latestLocations = await F1Api.getLatestLocations();
```

**Location data includes**:
- X, Y, Z coordinates
- Timestamp
- Driver number
- Session key

### 6. Meetings
Get Grand Prix meeting information.

```dart
// Get all meetings for 2024
final meetings2024 = await F1Api.getMeetings(year: 2024);

// Get specific meeting
final meeting = await F1Api.getMeetings(meetingKey: 1217);

// Get meetings by country
final monacoMeetings = await F1Api.getMeetings(countryName: "Monaco");
```

### 7. Pit Data
Get pit lane timing data including pit stop duration and pit lane times.

```dart
// Get all pit data for session
final pitData = await F1Api.getPitData(sessionKey: 9158);

// Get pit data for specific driver
final hamiltonPits = await F1Api.getPitData(sessionKey: 9158, driverNumber: 44);
```

### 8. Position
Get driver position changes during sessions.

```dart
// Get all position data for session
final positions = await F1Api.getPositions(sessionKey: 9158);

// Get position data for specific driver
final hamiltonPositions = await F1Api.getPositions(sessionKey: 9158, driverNumber: 44);

// Get latest positions
final latestPositions = await F1Api.getLatestPositions();

// Get positions for P1 only
final leaderPositions = await F1Api.getPositions(sessionKey: 9158, position: 1);
```

### 9. Race Control
Get race control messages including flags, safety car, and incident information.

```dart
// Get all race control messages for session
final raceControl = await F1Api.getRaceControlMessages(sessionKey: 9158);

// Get yellow flag messages
final yellowFlags = await F1Api.getRaceControlMessages(sessionKey: 9158, flag: "YELLOW");

// Get safety car messages
final safetyCar = await F1Api.getRaceControlMessages(sessionKey: 9158, category: "SafetyCar");
```

### 10. Sessions
Get information about practice, qualifying, and race sessions.

```dart
// Get all sessions for 2024
final sessions2024 = await F1Api.getSessions(year: 2024);

// Get specific session
final session = await F1Api.getSessions(sessionKey: 9158);

// Get qualifying sessions
final qualifying = await F1Api.getSessions(sessionName: "Qualifying");

// Get sessions by country
final monacoSessions = await F1Api.getSessions(countryName: "Monaco");
```

### 11. Team Radio
Get driver radio communications during sessions.

```dart
// Get all radio communications for session
final radio = await F1Api.getTeamRadio(sessionKey: 9158);

// Get radio for specific driver
final hamiltonRadio = await F1Api.getTeamRadio(sessionKey: 9158, driverNumber: 44);
```

**Note**: This endpoint may require special access or authentication.

### 12. Weather
Get weather information for sessions.

```dart
// Get all weather data for session
final weather = await F1Api.getWeather(sessionKey: 9158);

// Get latest weather
final latestWeather = await F1Api.getLatestWeather();
```

## 🔧 Utility Methods

### Get Current Session
```dart
final currentSession = await F1Api.getCurrentSessionKey();
if (currentSession != null) {
  final liveData = await F1Api.getLatestCarData();
}
```

### Live Telemetry for Specific Driver
```dart
// Get live telemetry for Lewis Hamilton (car #44)
final hamiltonTelemetry = await F1Api.getLiveTelemetry(44);
```

### Live Race Positions
```dart
final livePositions = await F1Api.getLiveRacePositions();
```

### Live Timing Gaps
```dart
final liveGaps = await F1Api.getLiveTimingGaps();
```

## 🔍 Advanced Filtering

OpenF1 API supports advanced filtering with comparison operators:

### Date Filtering
```dart
// Get data after specific date
final recentData = await F1Api.getCarData(
  sessionKey: 9158,
  dateGte: "2024-07-28T14:00:00.000Z",
);

// Get data before specific date
final earlyData = await F1Api.getCarData(
  sessionKey: 9158,
  dateLte: "2024-07-28T15:00:00.000Z",
);
```

### Numeric Filtering
```dart
// Get laps after lap 10
final lateLaps = await F1Api.getOpenF1Laps(
  sessionKey: 9158,
  lapNumberGte: 10,
);

// Get laps before lap 20
final earlyLaps = await F1Api.getOpenF1Laps(
  sessionKey: 9158,
  lapNumberLte: 20,
);
```

### Latest Data
Use the `latest` keyword to get the most recent data:

```dart
final latestPositions = await F1Api.getLatestPositions();
final latestIntervals = await F1Api.getLatestIntervals();
final latestCarData = await F1Api.getLatestCarData();
final latestLocations = await F1Api.getLatestLocations();
final latestWeather = await F1Api.getLatestWeather();
```

## 🏁 Real-time Race Monitoring Example

```dart
Future<void> monitorRace() async {
  // Get current session
  final sessionKey = await F1Api.getCurrentSessionKey();
  if (sessionKey == null) return;
  
  // Set up monitoring loop
  Timer.periodic(Duration(seconds: 5), (timer) async {
    try {
      // Get latest positions
      final positions = await F1Api.getLatestPositions();
      print('Leader: Driver #${positions.first['driver_number']}');
      
      // Get latest intervals
      final intervals = await F1Api.getLatestIntervals();
      if (intervals.length >= 2) {
        print('Gap to leader: ${intervals[1]['interval']}');
      }
      
      // Check for race control messages
      final raceControl = await F1Api.getRaceControlMessages(sessionKey: sessionKey);
      // Process race control messages...
      
    } catch (e) {
      print('Error in monitoring: $e');
    }
  });
}
```

## 📈 Telemetry Analysis Example

```dart
Future<void> analyzeTelemetry(int sessionKey, int driverNumber) async {
  // Get telemetry data
  final carData = await F1Api.getCarData(
    sessionKey: sessionKey,
    driverNumber: driverNumber,
  );
  
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
  
  // Get corresponding location data for track mapping
  final locations = await F1Api.getLocations(
    sessionKey: sessionKey,
    driverNumber: driverNumber,
  );
  
  // Combine telemetry with location for track visualization
  // ... implement visualization logic
}
```

## 🚨 Error Handling

All OpenF1 API methods include proper error handling:

```dart
try {
  final data = await F1Api.getLatestCarData();
  // Process data...
} catch (e) {
  print('Error getting car data: $e');
  // Handle error appropriately
}
```

## ⚡ Performance Tips

1. **Use latest endpoints** for real-time data instead of polling all data
2. **Filter by driver number** when you only need specific driver data
3. **Use date filters** to limit data ranges and improve performance
4. **Cache session keys** to avoid repeated session lookups
5. **Implement rate limiting** to respect API limits

## 🔗 Integration with Jolpica F1 API

The OpenF1 endpoints work alongside the existing Jolpica F1 API endpoints. You can combine both APIs for comprehensive F1 data:

```dart
// Get basic race info from Jolpica
final raceResults = await F1Api.getRaceResults(2024, 15);

// Get detailed telemetry from OpenF1
final sessionKey = await F1Api.getCurrentSessionKey();
final telemetry = await F1Api.getLatestCarData();

// Combine both datasets for complete analysis
```

## 📚 Additional Resources

- [OpenF1 Official Documentation](https://openf1.org/)
- [OpenF1 API Reference](https://openf1.org/docs)
- [Example Applications](../examples/openf1_api_examples.dart)

## 🆘 Common Issues

### No Data Available
- Ensure you're using a valid `sessionKey`
- Check if the session is currently active
- Verify driver numbers are correct (1-99)

### Rate Limiting
- Implement delays between requests
- Use latest endpoints for real-time data
- Cache responses when appropriate

### Authentication Required
- Some endpoints (like team radio) may require special access
- Check OpenF1 documentation for current requirements
