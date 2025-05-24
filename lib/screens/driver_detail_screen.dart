import 'package:flutter/material.dart';
import 'dart:async';
import '../models/driver_standing.dart';
import '../core/utils/driver_image_utils.dart';
import '../core/api/f1_api.dart';

class DriverDetailScreen extends StatefulWidget {
  final DriverStanding driverStanding;
  final int year;

  const DriverDetailScreen({
    super.key,
    required this.driverStanding,
    required this.year,
  });

  @override
  State<DriverDetailScreen> createState() => _DriverDetailScreenState();
}

class _DriverDetailScreenState extends State<DriverDetailScreen> {
  // Live data state variables
  Timer? _dataUpdateTimer;
  List<dynamic> _liveTelemetry = [];
  List<dynamic> _livePositions = [];
  List<dynamic> _liveIntervals = [];
  List<dynamic> _latestWeather = [];
  List<dynamic> _raceControlMessages = [];
  int? _currentSessionKey;
  bool _isLoadingLiveData = false;
  String? _liveDataError;

  @override
  void initState() {
    super.initState();
    _initializeLiveData();
  }

  @override
  void dispose() {
    _dataUpdateTimer?.cancel();
    super.dispose();
  }

  /// Initialize live data collection
  Future<void> _initializeLiveData() async {
    try {
      setState(() {
        _isLoadingLiveData = true;
        _liveDataError = null;
      });

      // Get current session key
      _currentSessionKey = await F1Api.getCurrentSessionKey();
      
      if (_currentSessionKey != null) {
        // Load initial data
        await _updateLiveData();
        
        // Start periodic updates every 10 seconds
        _dataUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
          _updateLiveData();
        });
      }
    } catch (e) {
      setState(() {
        _liveDataError = 'Errore caricamento dati live: $e';
      });
    } finally {
      setState(() {
        _isLoadingLiveData = false;
      });
    }
  }

  /// Update live data from OpenF1 API
  Future<void> _updateLiveData() async {
    if (_currentSessionKey == null) return;

    try {
      // Get driver number from permanent number or code
      final driverNumber = widget.driverStanding.driver.permanentNumber != null 
          ? int.tryParse(widget.driverStanding.driver.permanentNumber!)
          : null;

      // Update telemetry data for this driver
      if (driverNumber != null) {
        final telemetry = await F1Api.getLiveTelemetry(driverNumber);
        if (mounted) {
          setState(() {
            _liveTelemetry = telemetry;
          });
        }
      }

      // Update position and timing data
      final positions = await F1Api.getLatestPositions();
      final intervals = await F1Api.getLatestIntervals();
      final weather = await F1Api.getLatestWeather();
      final raceControl = await F1Api.getRaceControlMessages(sessionKey: _currentSessionKey!);

      if (mounted) {
        setState(() {
          _livePositions = positions;
          _liveIntervals = intervals;
          _latestWeather = weather;
          _raceControlMessages = raceControl.take(5).toList(); // Last 5 messages
          _liveDataError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _liveDataError = 'Errore aggiornamento dati: $e';
        });
      }
    }
  }

  /// Calculate age from date of birth
  int _calculateAge(String dateOfBirth) {
    try {
      final birthDate = DateTime.parse(dateOfBirth);
      final now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month || 
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }

  /// Format date of birth for display
  String _formatDateOfBirth(String dateOfBirth) {
    try {
      final date = DateTime.parse(dateOfBirth);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateOfBirth;
    }
  }

  /// Get position suffix (1st, 2nd, 3rd, etc.)
  String _getPositionSuffix(int position) {
    if (position >= 11 && position <= 13) {
      return '${position}th';
    }
    switch (position % 10) {
      case 1:
        return '${position}st';
      case 2:
        return '${position}nd';
      case 3:
        return '${position}rd';
      default:
        return '${position}th';
    }
  }

  /// Get position color based on championship position
  Color _getPositionColor(BuildContext context, int position) {
    switch (position) {
      case 1:
        return Colors.amber; // Gold
      case 2:
        return Colors.grey[400]!; // Silver
      case 3:
        return Colors.brown[400]!; // Bronze
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  /// Create text with outline for better contrast in any theme
  static Widget _createTextWithOutline({
    required String text,
    required TextStyle style,
    Color outlineColor = const Color.fromARGB(255, 255, 255, 255),
    double outlineWidth = 1.0,
  }) {
    return Stack(
      children: [
        // Outlines - creating 8 slightly offset copies for a complete outline effect
        Text(
          text,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = outlineWidth
              ..color = outlineColor,
          ),
        ),
        // Main text on top
        Text(
          text,
          style: style,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final driver = widget.driverStanding.driver;
    final team = widget.driverStanding.constructors.isNotEmpty 
        ? widget.driverStanding.constructors.first 
        : null;
    final driverImagePath = DriverImageUtils.getDriverImagePath(driver.familyName);
    final age = _calculateAge(driver.dateOfBirth);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero App Bar with driver image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: _createTextWithOutline(
                text: '${driver.givenName} ${driver.familyName}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.white,
                ),
                outlineColor: Colors.black,
                outlineWidth: 1.5,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                          Theme.of(context).colorScheme.secondary.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                  // Driver image
                  if (driverImagePath != null)
                    Positioned(
                      right: -20,
                      bottom: 0,
                      child: Hero(
                        tag: DriverImageUtils.getDriverHeroTag(driver.driverId, widget.year),
                        child: Image.asset(
                          driverImagePath,
                          height: 280,
                          width: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 280,
                              width: 200,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.person,
                                size: 100,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  // Position badge
                  Positioned(
                    top: 100,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _getPositionColor(context, widget.driverStanding.position),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        _getPositionSuffix(widget.driverStanding.position),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Quick stats cards
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Punti',
                          value: widget.driverStanding.points.toStringAsFixed(0),
                          icon: Icons.emoji_events,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Vittorie',
                          value: widget.driverStanding.wins.toString(),
                          icon: Icons.flag,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Driver Information Card
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Informazioni Pilota',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          _InfoRow(
                            icon: Icons.flag,
                            label: 'Nazionalità',
                            value: driver.nationality,
                          ),
                          _InfoRow(
                            icon: Icons.cake,
                            label: 'Data di Nascita',
                            value: '${_formatDateOfBirth(driver.dateOfBirth)} ($age anni)',
                          ),
                          if (driver.permanentNumber != null)
                            _InfoRow(
                              icon: Icons.confirmation_number,
                              label: 'Numero Permanente',
                              value: driver.permanentNumber!,
                            ),
                          if (driver.code != null)
                            _InfoRow(
                              icon: Icons.code,
                              label: 'Codice Pilota',
                              value: driver.code!,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Team Information Card (if available)
                  if (team != null)
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.groups,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Team (${widget.year})',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            _InfoRow(
                              icon: Icons.business,
                              label: 'Scuderia',
                              value: team.name,
                            ),
                            _InfoRow(
                              icon: Icons.flag,
                              label: 'Nazionalità Team',
                              value: team.nationality,
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  
                  // Live Telemetry Card (if data available)
                  if (_liveTelemetry.isNotEmpty)
                    _LiveTelemetryCard(telemetryData: _liveTelemetry.last),
                  
                  // Weather Conditions Card (if data available)
                  if (_latestWeather.isNotEmpty)
                    _WeatherCard(weatherData: _latestWeather.last),
                  
                  // Live Position and Timing Card (if data available)
                  if (_livePositions.isNotEmpty || _liveIntervals.isNotEmpty)
                    _LiveTimingCard(
                      driverNumber: widget.driverStanding.driver.permanentNumber,
                      positions: _livePositions,
                      intervals: _liveIntervals,
                    ),
                  
                  // Race Control Messages Card (if data available)
                  if (_raceControlMessages.isNotEmpty)
                    _RaceControlCard(messages: _raceControlMessages),
                  
                  // Live Data Status Card
                  _LiveDataStatusCard(
                    isLoading: _isLoadingLiveData,
                    error: _liveDataError,
                    sessionKey: _currentSessionKey,
                    onRefresh: () => _updateLiveData(),
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// LIVE DATA WIDGETS
// =============================================================================

class _LiveTelemetryCard extends StatelessWidget {
  final Map<String, dynamic> telemetryData;

  const _LiveTelemetryCard({required this.telemetryData});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.speed,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Telemetria Live',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _TelemetryItem(
                    icon: Icons.speed,
                    label: 'Velocità',
                    value: '${telemetryData['speed'] ?? 'N/A'} km/h',
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _TelemetryItem(
                    icon: Icons.settings,
                    label: 'Marcia',
                    value: '${telemetryData['n_gear'] ?? 'N/A'}',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _TelemetryItem(
                    icon: Icons.flash_on,
                    label: 'Acceleratore',
                    value: '${telemetryData['throttle'] ?? 'N/A'}%',
                    color: Colors.orange,
                  ),
                ),
                Expanded(
                  child: _TelemetryItem(
                    icon: Icons.stop,
                    label: 'Freno',
                    value: '${telemetryData['brake'] ?? 'N/A'}%',
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            if (telemetryData['rpm'] != null) ...[
              const SizedBox(height: 12),
              _TelemetryItem(
                icon: Icons.rotate_right,
                label: 'RPM',
                value: '${telemetryData['rpm']}',
                color: Colors.purple,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TelemetryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _TelemetryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  final Map<String, dynamic> weatherData;

  const _WeatherCard({required this.weatherData});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getWeatherIcon(weatherData),
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Condizioni Meteo',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _WeatherItem(
                    icon: Icons.thermostat,
                    label: 'Temp. Pista',
                    value: '${weatherData['track_temperature'] ?? 'N/A'}°C',
                    color: Colors.orange,
                  ),
                ),
                Expanded(
                  child: _WeatherItem(
                    icon: Icons.air,
                    label: 'Temp. Aria',
                    value: '${weatherData['air_temperature'] ?? 'N/A'}°C',
                    color: Colors.lightBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _WeatherItem(
                    icon: Icons.water_drop,
                    label: 'Umidità',
                    value: '${weatherData['humidity'] ?? 'N/A'}%',
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _WeatherItem(
                    icon: Icons.compress,
                    label: 'Pressione',
                    value: '${weatherData['pressure'] ?? 'N/A'} mbar',
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            if (weatherData['rainfall'] == 1) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.umbrella, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Pioggia in corso',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getWeatherIcon(Map<String, dynamic> weather) {
    if (weather['rainfall'] == 1) return Icons.umbrella;
    final trackTemp = weather['track_temperature'] as num?;
    if (trackTemp == null) return Icons.wb_sunny;
    if (trackTemp > 40) return Icons.wb_sunny;
    if (trackTemp > 20) return Icons.wb_cloudy;
    return Icons.ac_unit;
  }
}

class _WeatherItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _WeatherItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _LiveTimingCard extends StatelessWidget {
  final String? driverNumber;
  final List<dynamic> positions;
  final List<dynamic> intervals;

  const _LiveTimingCard({
    required this.driverNumber,
    required this.positions,
    required this.intervals,
  });

  @override
  Widget build(BuildContext context) {
    // Find current driver position and interval
    Map<String, dynamic>? driverPosition;
    Map<String, dynamic>? driverInterval;

    if (driverNumber != null) {
      final driverNum = int.tryParse(driverNumber!);
      if (driverNum != null) {
        driverPosition = positions.cast<Map<String, dynamic>>().firstWhere(
          (pos) => pos['driver_number'] == driverNum,
          orElse: () => <String, dynamic>{},
        );
        driverInterval = intervals.cast<Map<String, dynamic>>().firstWhere(
          (interval) => interval['driver_number'] == driverNum,
          orElse: () => <String, dynamic>{},
        );
      }
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timer,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Timing Live',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (driverPosition != null && driverPosition.isNotEmpty) ...[
              _TimingItem(
                icon: Icons.flag,
                label: 'Posizione Attuale',
                value: 'P${driverPosition['position'] ?? 'N/A'}',
                color: _getPositionColor(driverPosition['position']),
              ),
              const SizedBox(height: 12),
            ],
            if (driverInterval != null && driverInterval.isNotEmpty) ...[
              _TimingItem(
                icon: Icons.access_time,
                label: 'Gap',
                value: '${driverInterval['interval'] ?? 'N/A'}',
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
            ],
            // Show top 3 current positions
            Text(
              'Classifica Live (Top 3)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...positions.take(3).map((pos) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: _getPositionColor(pos['position']),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        '${pos['position']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Pilota #${pos['driver_number']}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Color _getPositionColor(int? position) {
    switch (position) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown[400]!;
      default:
        return Colors.blue;
    }
  }
}

class _TimingItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _TimingItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RaceControlCard extends StatelessWidget {
  final List<dynamic> messages;

  const _RaceControlCard({required this.messages});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flag,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Controllo Gara',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...messages.map((message) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getMessageColor(message).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getMessageColor(message).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getMessageIcon(message),
                      color: _getMessageColor(message),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message['message'] ?? 'N/A',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (message['flag'] != null)
                            Text(
                              'Bandiera: ${message['flag']}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: _getMessageColor(message),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Color _getMessageColor(Map<String, dynamic> message) {
    final flag = message['flag']?.toString().toUpperCase();
    switch (flag) {
      case 'YELLOW':
        return Colors.yellow[700]!;
      case 'RED':
        return Colors.red;
      case 'GREEN':
        return Colors.green;
      case 'BLUE':
        return Colors.blue;
      case 'BLACK':
        return Colors.black87;
      default:
        return Colors.grey[600]!;
    }
  }

  IconData _getMessageIcon(Map<String, dynamic> message) {
    final flag = message['flag']?.toString().toUpperCase();
    final messageText = message['message']?.toString().toLowerCase() ?? '';
    
    if (messageText.contains('safety car')) return Icons.warning;
    if (messageText.contains('pit')) return Icons.local_gas_station;
    
    switch (flag) {
      case 'YELLOW':
        return Icons.warning;
      case 'RED':
        return Icons.stop;
      case 'GREEN':
        return Icons.play_arrow;
      case 'BLUE':
        return Icons.info;
      case 'BLACK':
        return Icons.block;
      default:
        return Icons.flag;
    }
  }
}

class _LiveDataStatusCard extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final int? sessionKey;
  final VoidCallback onRefresh;

  const _LiveDataStatusCard({
    required this.isLoading,
    required this.error,
    required this.sessionKey,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.data_usage,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Stato Dati Live',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: isLoading ? null : onRefresh,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (sessionKey != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Connesso alla sessione $sessionKey',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Nessuna sessione attiva al momento',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Aggiornamento automatico ogni 10 secondi',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
