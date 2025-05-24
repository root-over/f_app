import 'package:flutter/material.dart';
import 'dart:async';
import '../models/driver_standing.dart';
import '../core/utils/driver_image_utils.dart';
import '../core/api/f1_api.dart';
import '../services/live_race_service.dart';

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
  
  // Live race service integration
  final LiveRaceService _liveRaceService = LiveRaceService.instance;
  LiveRaceInfo? _liveRaceInfo;
  StreamSubscription<LiveRaceStatus>? _statusSubscription;
  StreamSubscription<List<RaceControlMessage>>? _raceControlSubscription;
  
  // Telemetry loading and racing status
  bool _isLoadingTelemetry = false;
  bool _isInitialTelemetryLoad = true; // Track if this is the first telemetry load
  bool _isCarRacing = false;
  DateTime? _lastTelemetryUpdate;

  // Add refresh indicator key for pull-to-refresh
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _initializeLiveData();
    _setupLiveRaceMonitoring();
  }

  @override
  void dispose() {
    _dataUpdateTimer?.cancel();
    _statusSubscription?.cancel();
    _raceControlSubscription?.cancel();
    _liveRaceService.stopLiveMonitoring();
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

      // Update telemetry data for this driver with loading state
      if (driverNumber != null) {
        // Only show loading spinner during initial load
        if (mounted && _isInitialTelemetryLoad) {
          setState(() {
            _isLoadingTelemetry = true;
          });
        }
        
        final telemetry = await F1Api.getLiveTelemetry(driverNumber);
        
        if (mounted && telemetry.isNotEmpty) {
          final latestTelemetry = telemetry.last;
          final currentTime = DateTime.now();
          
          // Determine if car is racing based on telemetry data
          final speed = latestTelemetry['speed'] ?? 0;
          final rpm = latestTelemetry['rpm'] ?? 0;
          final gear = latestTelemetry['gear'] ?? 0;
          
          // Car is considered racing if:
          // - Speed > 50 km/h OR
          // - RPM > 5000 OR  
          // - Gear > 1 (not in neutral/1st gear)
          final isRacing = speed > 50 || rpm > 5000 || gear > 1;
          
          setState(() {
            _liveTelemetry = telemetry;
            _isCarRacing = isRacing;
            _lastTelemetryUpdate = currentTime;
            _isLoadingTelemetry = false;
            _isInitialTelemetryLoad = false; // Mark initial load as complete
          });
        } else if (mounted) {
          setState(() {
            _isLoadingTelemetry = false;
            _isInitialTelemetryLoad = false; // Mark initial load as complete even if no data
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
          _isLoadingTelemetry = false;
        });
      }
    }
  }

  /// Setup live race monitoring with flag detection
  void _setupLiveRaceMonitoring() {
    // Start live race monitoring service
    _liveRaceService.startLiveMonitoring();
    
    // Listen to race status changes
    _statusSubscription = _liveRaceService.liveStatusStream.listen((status) {
      if (mounted) {
        setState(() {
          _liveRaceInfo = _liveRaceService.getCurrentRaceInfo();
          
          // Update car racing status based on live race status
          _isCarRacing = _liveRaceInfo?.isLive ?? false;
        });
      }
    });
    
    // Listen to race control messages
    _raceControlSubscription = _liveRaceService.raceControlStream.listen((messages) {
      if (mounted) {
        setState(() {
          // Race control messages are automatically updated in the service
        });
      }
    });
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
    // Reset initial load flag to show loading during manual refresh
    setState(() {
      _isInitialTelemetryLoad = true;
    });
    
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
                    
                    // Live Race Status Card (showing current race state)
                    if (_liveRaceInfo != null)
                      _LiveRaceStatusCard(raceInfo: _liveRaceInfo!),
                    
                    // Live Telemetry Card (if data available or loading)
                    if (_liveTelemetry.isNotEmpty || _isLoadingTelemetry)
                      _LiveTelemetryCard(
                        telemetryData: _liveTelemetry.isNotEmpty ? _liveTelemetry.last : {},
                        isLoading: _isLoadingTelemetry,
                        isCarRacing: _isCarRacing,
                        lastUpdate: _lastTelemetryUpdate,
                      ),
                    
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

// Enhanced Live Telemetry Card with modern UI
class _LiveTelemetryCard extends StatelessWidget {
  final Map<String, dynamic> telemetryData;
  final bool isLoading;
  final bool isCarRacing;
  final DateTime? lastUpdate;
  
  const _LiveTelemetryCard({
    required this.telemetryData,
    this.isLoading = false,
    this.isCarRacing = false,
    this.lastUpdate,
  });
  
  @override
  Widget build(BuildContext context) {
    // Show loading state
    if (isLoading) {
      return Card(
        elevation: 8,
        margin: const EdgeInsets.only(bottom: 16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(width: 16),
                    Text(
                      'Caricamento telemetria...',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Recupero dati in tempo reale',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 8,
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with racing status
              Row(
                children: [
                  Icon(
                    Icons.sensors,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Telemetria Live',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (lastUpdate != null)
                          Text(
                            'Ultimo aggiornamento: ${_formatTime(lastUpdate!)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Racing status indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCarRacing ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCarRacing ? Icons.play_arrow : Icons.pause,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isCarRacing ? 'RACING' : 'IDLE',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
                
              const SizedBox(height: 20),
              
              // Telemetry metrics in a grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _TelemetryMetric(
                    icon: Icons.speed,
                    label: 'Velocità',
                    value: '${telemetryData['speed'] ?? '--'}',
                    unit: 'km/h',
                    color: Colors.blue,
                  ),
                  _TelemetryMetric(
                    icon: Icons.rotate_right,
                    label: 'RPM',
                    value: '${telemetryData['rpm'] ?? '--'}',
                    unit: 'rpm',
                    color: Colors.orange,
                  ),
                  _TelemetryMetric(
                    icon: Icons.timeline,
                    label: 'Marcia',
                    value: '${telemetryData['gear'] ?? '--'}',
                    unit: '',
                    color: Colors.green,
                  ),
                  _TelemetryMetric(
                    icon: Icons.thermostat,
                    label: 'DRS',
                    value: telemetryData['drs'] == true ? 'ON' : 'OFF',
                    unit: '',
                    color: telemetryData['drs'] == true ? Colors.green : Colors.red,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Throttle and Brake bars
              if (telemetryData['throttle'] != null || telemetryData['brake'] != null) ...[
                const Divider(),
                const SizedBox(height: 12),
                _PedalIndicator(
                  label: 'Acceleratore',
                  value: (telemetryData['throttle'] ?? 0).toDouble(),
                  color: Colors.green,
                  icon: Icons.keyboard_arrow_up,
                ),
                const SizedBox(height: 8),
                _PedalIndicator(
                  label: 'Freno',
                  value: (telemetryData['brake'] ?? 0).toDouble(),
                  color: Colors.red,
                  icon: Icons.keyboard_arrow_down,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s fa';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m fa';
    } else {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}

// Widget for individual telemetry metrics
class _TelemetryMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _TelemetryMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// Widget for pedal indicators (throttle/brake)
class _PedalIndicator extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;

  const _PedalIndicator({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (value / 100).clamp(0.0, 1.0);
    
    return Column(
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              '${value.toInt()}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
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

// Live Race Status Card showing current race state, flags, and safety car
class _LiveRaceStatusCard extends StatelessWidget {
  final LiveRaceInfo raceInfo;
  
  const _LiveRaceStatusCard({
    required this.raceInfo,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with race status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(raceInfo.status),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getStatusIcon(raceInfo.status),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stato Gara',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          raceInfo.statusText,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _getStatusColor(raceInfo.status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Live indicator if race is live
                  if (raceInfo.isLive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
                
              const SizedBox(height: 16),
              
              // Race control messages (if any)
              if (raceInfo.recentRaceControl.isNotEmpty) ...[
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'Controllo Gara',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: raceInfo.recentRaceControl.length,
                    itemBuilder: (context, index) {
                      final message = raceInfo.recentRaceControl[index];
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(message.color),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              message.icon,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Expanded(
                              child: Text(
                                message.message ?? message.category ?? 'Info',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(LiveRaceStatus status) {
    switch (status) {
      case LiveRaceStatus.racing:
        return Colors.green;
      case LiveRaceStatus.paused:
        return Colors.orange;
      case LiveRaceStatus.yellowFlag:
        return Colors.yellow[700]!;
      case LiveRaceStatus.redFlag:
        return Colors.red;
      case LiveRaceStatus.safetyCar:
      case LiveRaceStatus.virtualSafetyCar:
        return Colors.amber[700]!;
      case LiveRaceStatus.finished:
        return Colors.grey[600]!;
      case LiveRaceStatus.notLive:
      case LiveRaceStatus.noSession:
        return Colors.grey;
      case LiveRaceStatus.error:
        return Colors.red[800]!;
      case LiveRaceStatus.unknown:
        return Colors.grey[400]!;
    }
  }

  IconData _getStatusIcon(LiveRaceStatus status) {
    switch (status) {
      case LiveRaceStatus.racing:
        return Icons.play_arrow;
      case LiveRaceStatus.paused:
        return Icons.pause;
      case LiveRaceStatus.yellowFlag:
        return Icons.flag;
      case LiveRaceStatus.redFlag:
        return Icons.stop;
      case LiveRaceStatus.safetyCar:
        return Icons.directions_car;
      case LiveRaceStatus.virtualSafetyCar:
        return Icons.computer;
      case LiveRaceStatus.finished:
        return Icons.sports_score;
      case LiveRaceStatus.notLive:
      case LiveRaceStatus.noSession:
        return Icons.tv_off;
      case LiveRaceStatus.error:
        return Icons.error;
      case LiveRaceStatus.unknown:
        return Icons.help;
    }
  }
}
