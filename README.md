# 🏎️ F1 App - Complete Formula 1 Data Platform

A comprehensive Flutter application providing complete access to Formula 1 data through integrated Jolpica F1 API and OpenF1 API.

## 🚀 Features

### 📊 Dual API Integration
- **Jolpica F1 API**: Complete historical and official F1 data
- **OpenF1 API**: Real-time telemetry and live race data

### ⚡ Real-time Capabilities
- Live telemetry data (~3.7Hz sample rate)
- Real-time race positions and timing gaps
- 3D car positions on track
- Race control messages and flags
- Live weather data

### 📈 Advanced Data Analytics
- Detailed lap analysis with sector times
- Driver performance metrics
- Team comparisons
- Historical data trends

## 🛠️ API Coverage

### Jolpica F1 API (Historical Data)
- Driver standings and championships
- Race results and qualifying
- Circuit information
- Constructor standings
- Season schedules
- Sprint race results

### OpenF1 API (Live Data)
- Car telemetry (speed, throttle, brake, DRS, gear, RPM)
- 3D car locations on track
- Real-time timing intervals
- Pit lane data
- Race control messages
- Driver radio communications
- Weather information
- Session management

## 📚 Documentation

- [OpenF1 API Documentation](docs/OPENF1_API_DOCUMENTATION.md)
- [Implementation Summary](IMPLEMENTATION_SUMMARY.md)
- [Changelog](OPENF1_CHANGELOG.md)
- [API Examples](examples/openf1_api_examples.dart)

## 🧪 Testing

Run the complete test suite:
```bash
flutter test
```

Test specific OpenF1 integration:
```bash
dart test test/openf1_api_test.dart
```

Run examples:
```bash
dart run examples/openf1_api_examples.dart
```

## 🔧 Quick Start

### Basic Usage
```dart
import 'lib/core/api/f1_api.dart';

// Get current season standings
final standings = await F1Api.getCurrentDriverStandings();

// Get live race positions
final livePositions = await F1Api.getLiveRacePositions();

// Get real-time telemetry for Lewis Hamilton
final hamiltonTelemetry = await F1Api.getLiveTelemetry(44);
```

### Advanced Usage
```dart
// Get detailed session data
final currentSession = await F1Api.getCurrentSessionKey();
if (currentSession != null) {
  // Get all telemetry data for the session
  final telemetry = await F1Api.getCarData(sessionKey: currentSession);
  
  // Get race control messages
  final raceControl = await F1Api.getRaceControlMessages(sessionKey: currentSession);
  
  // Get weather conditions
  final weather = await F1Api.getWeather(sessionKey: currentSession);
}
```

## 🎯 Use Cases

### Real-time Race Monitoring
Perfect for building live race dashboards with real-time position updates, timing gaps, and race control information.

### Telemetry Analysis
Access high-frequency telemetry data for detailed performance analysis and data visualization.

### Historical Research
Comprehensive access to historical F1 data for research, statistics, and trend analysis.

### Live Event Applications
Build applications that respond to real-time race events, flags, and incidents.

## 🏁 Getting Started

This project is a starting point for a Flutter application with complete F1 data integration.

### Prerequisites
- Flutter SDK
- Dart SDK
- Internet connection for API access

### Installation
1. Clone the repository
2. Run `flutter pub get`
3. Run `flutter run`

## 📖 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Jolpica F1 API](https://jolpi.ca/docs/)
- [OpenF1 API](https://openf1.org/)
- [Formula 1 Official](https://www.formula1.com/)

## 🤝 Contributing

Contributions are welcome! Please read the contributing guidelines and submit pull requests.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
