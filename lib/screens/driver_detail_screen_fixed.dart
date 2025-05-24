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

  // Add refresh indicator key for pull-to-refresh
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

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

  // Add refresh handler method
  Future<void> _handleRefresh() async {
    // Refresh live data
    await _updateLiveData();
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
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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

// Placeholder for live data widgets that would need implementation
class _LiveTelemetryCard extends StatelessWidget {
  final Map<String, dynamic> telemetryData;
  const _LiveTelemetryCard({required this.telemetryData});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Live Telemetry: ${telemetryData.toString()}'),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Weather: ${weatherData.toString()}'),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Live Timing for driver $driverNumber'),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Race Control: ${messages.length} messages'),
      ),
    );
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Live Data Status'),
            if (error != null) Text('Error: $error'),
            if (sessionKey != null) Text('Session: $sessionKey'),
            ElevatedButton(
              onPressed: isLoading ? null : onRefresh,
              child: Text(isLoading ? 'Loading...' : 'Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
