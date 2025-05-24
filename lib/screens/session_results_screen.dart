import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/race.dart';
import '../providers/timezone_provider.dart';
import '../core/api/f1_api.dart';

class SessionResultsScreen extends StatefulWidget {
  final Race race;
  final RaceSession session;

  const SessionResultsScreen({
    super.key,
    required this.race,
    required this.session,
  });

  @override
  State<SessionResultsScreen> createState() => _SessionResultsScreenState();
}

class _SessionResultsScreenState extends State<SessionResultsScreen> {
  List<dynamic> _results = [];
  List<dynamic> _livePositions = [];
  List<dynamic> _liveIntervals = [];
  bool _isLoading = true;
  bool _isLiveSession = false;
  String? _error;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _checkSessionStatus();
    _loadData();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _checkSessionStatus() {
    try {
      final sessionDateTime = DateTime.parse('${widget.session.date}T${widget.session.time}');
      final now = DateTime.now();
      
      // Consider session as live if it's within 1 hour before to 3 hours after start time
      _isLiveSession = sessionDateTime.isAfter(now.subtract(const Duration(hours: 1))) &&
                      sessionDateTime.isBefore(now.add(const Duration(hours: 3)));
    } catch (e) {
      _isLiveSession = false;
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (_isLiveSession) {
        await _loadLiveData();
        // Start refresh timer for live data
        _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) => _loadLiveData());
      } else {
        await _loadHistoricalResults();
      }
    } catch (e) {
      setState(() {
        _error = 'Errore nel caricamento dei dati: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadLiveData() async {
    try {
      // Get current session key
      final sessionKey = await F1Api.getCurrentSessionKey();
      
      if (sessionKey != null) {
        // Load live positions and intervals
        final positions = await F1Api.getLatestPositions();
        final intervals = await F1Api.getLatestIntervals();
        
        if (mounted) {
          setState(() {
            _livePositions = positions;
            _liveIntervals = intervals;
            _error = null;
          });
        }
      } else {
        // Try to get the most recent completed results
        await _loadHistoricalResults();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Errore nel caricamento dati live: $e';
        });
      }
    }
  }

  Future<void> _loadHistoricalResults() async {
    try {
      List<dynamic> results = [];
      
      // Map session type to API endpoint
      if (widget.session.name.toLowerCase().contains('qualif')) {
        results = await F1Api.getQualifying(
          season: widget.race.season,
          round: widget.race.round,
        );
      } else if (widget.session.name.toLowerCase() == 'gara') {
        results = await F1Api.getResults(
          season: widget.race.season,
          round: widget.race.round,
        );
      } else if (widget.session.name.toLowerCase().contains('sprint')) {
        // Sprint results (fallback to race results for now)
        results = await F1Api.getResults(
          season: widget.race.season,
          round: widget.race.round,
        );
      } else if (widget.session.name.toLowerCase().contains('prove') || 
                 widget.session.name.toLowerCase().contains('practice')) {
        // For practice sessions, try to get data from OpenF1 API
        await _loadPracticeSessionData();
        return;
      }
      
      if (mounted) {
        setState(() {
          _results = results;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Errore nel caricamento risultati storici: $e';
        });
      }
    }
  }

  Future<void> _loadPracticeSessionData() async {
    try {
      // Get sessions for this race year and circuit
      final year = int.tryParse(widget.race.season) ?? DateTime.now().year;
      final countryName = widget.race.circuit.location.country;
      
      // Get all sessions for this race weekend
      final sessions = await F1Api.getSessions(
        year: year,
        countryName: countryName,
      );
      
      if (sessions.isEmpty) {
        setState(() {
          _error = 'Nessuna sessione trovata per questo weekend di gara';
        });
        return;
      }
      
      // Find the matching practice session
      Map<String, dynamic>? matchingSession;
      
      for (final session in sessions) {
        final sessionName = session['session_name']?.toString().toLowerCase() ?? '';
        final currentSessionName = widget.session.name.toLowerCase();
        
        if (currentSessionName.contains('prove libere 1') || currentSessionName.contains('practice 1')) {
          if (sessionName.contains('practice 1') || sessionName.contains('free practice 1')) {
            matchingSession = session;
            break;
          }
        } else if (currentSessionName.contains('prove libere 2') || currentSessionName.contains('practice 2')) {
          if (sessionName.contains('practice 2') || sessionName.contains('free practice 2')) {
            matchingSession = session;
            break;
          }
        } else if (currentSessionName.contains('prove libere 3') || currentSessionName.contains('practice 3')) {
          if (sessionName.contains('practice 3') || sessionName.contains('free practice 3')) {
            matchingSession = session;
            break;
          }
        }
      }
      
      if (matchingSession == null) {
        setState(() {
          _error = 'Sessione specifica non trovata. Sessioni disponibili: ${sessions.map((s) => s['session_name']).join(', ')}';
        });
        return;
      }
      
      final sessionKey = matchingSession['session_key'];
      
      // Get lap data and driver info for this session
      final laps = await F1Api.getOpenF1Laps(sessionKey: sessionKey);
      final drivers = await F1Api.getOpenF1Drivers(sessionKey: sessionKey);
      
      if (laps.isEmpty) {
        setState(() {
          _error = 'Nessun dato di tempo sul giro disponibile per questa sessione';
        });
        return;
      }
      
      // Process lap data to create practice session results
      final practiceResults = _processPracticeSessionLaps(laps, drivers);
      
      if (mounted) {
        setState(() {
          _results = [{'Results': practiceResults}];
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Errore nel caricamento dati prove libere: $e';
        });
      }
    }
  }

  List<Map<String, dynamic>> _processPracticeSessionLaps(List<dynamic> laps, List<dynamic> drivers) {
    // Create driver info map
    final Map<int, Map<String, dynamic>> driverInfo = {};
    for (final driver in drivers) {
      final driverNumber = driver['driver_number'];
      if (driverNumber != null) {
        driverInfo[driverNumber] = {
          'givenName': driver['first_name'] ?? 'Driver',
          'familyName': driver['last_name'] ?? '#$driverNumber',
          'code': driver['name_acronym'] ?? 'P$driverNumber',
          'teamName': driver['team_name'] ?? 'Unknown',
          'teamColor': driver['team_colour'],
        };
      }
    }
    
    // Group laps by driver
    final Map<int, List<dynamic>> lapsByDriver = {};
    
    for (final lap in laps) {
      final driverNumber = lap['driver_number'];
      if (driverNumber != null) {
        lapsByDriver[driverNumber] ??= [];
        lapsByDriver[driverNumber]!.add(lap);
      }
    }
    
    // Find best lap time for each driver
    final List<Map<String, dynamic>> results = [];
    
    for (final entry in lapsByDriver.entries) {
      final driverNumber = entry.key;
      final driverLaps = entry.value;
      final driver = driverInfo[driverNumber];
      
      // Find fastest valid lap
      dynamic fastestLap;
      Duration? bestTime;
      
      for (final lap in driverLaps) {
        final lapTimeMs = lap['lap_duration'];
        if (lapTimeMs != null && lapTimeMs > 0) {
          final duration = Duration(milliseconds: (lapTimeMs * 1000).round());
          if (bestTime == null || duration < bestTime) {
            bestTime = duration;
            fastestLap = lap;
          }
        }
      }
      
      if (fastestLap != null && bestTime != null) {
        results.add({
          'number': driverNumber.toString(),
          'position': null, // Will be set after sorting
          'positionText': null,
          'Driver': {
            'driverId': 'driver_$driverNumber',
            'permanentNumber': driverNumber.toString(),
            'code': driver?['code'] ?? 'P$driverNumber',
            'givenName': driver?['givenName'] ?? 'Driver',
            'familyName': driver?['familyName'] ?? '#$driverNumber',
          },
          'Constructor': {
            'name': driver?['teamName'] ?? 'Unknown',
            'nationality': 'Unknown'
          },
          'BestLap': {
            'Time': {
              'time': _formatLapTime(bestTime),
              'millis': bestTime.inMilliseconds.toString(),
            },
            'lap': fastestLap['lap_number']?.toString() ?? '0',
          },
          'laps': driverLaps.length.toString(),
        });
      }
    }
    
    // Sort by best lap time and assign positions
    results.sort((a, b) {
      final aTime = Duration(milliseconds: int.parse(a['BestLap']['Time']['millis']));
      final bTime = Duration(milliseconds: int.parse(b['BestLap']['Time']['millis']));
      return aTime.compareTo(bTime);
    });
    
    for (int i = 0; i < results.length; i++) {
      results[i]['position'] = (i + 1).toString();
      results[i]['positionText'] = (i + 1).toString();
    }
    
    return results;
  }

  String _formatLapTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final milliseconds = duration.inMilliseconds % 1000;
    
    if (minutes > 0) {
      return '$minutes:${seconds.toString().padLeft(2, '0')}.${(milliseconds ~/ 10).toString().padLeft(2, '0')}';
    } else {
      return '$seconds.${(milliseconds ~/ 10).toString().padLeft(2, '0')}';
    }
  }

  String _formatSessionLocal(BuildContext context, String date, String time) {
    try {
      final timezoneProvider = Provider.of<TimezoneProvider>(context, listen: false);
      final dtUtc = DateTime.parse('${date}T$time');
      final dtTz = tz.TZDateTime.from(dtUtc, timezoneProvider.currentLocation);
      final dateStr = DateFormat('d MMMM yyyy', 'it_IT').format(dtTz);
      final timeStr = DateFormat.Hm().format(dtTz);
      return '$dateStr, ore $timeStr';
    } catch (_) {
      return '$date $time';
    }
  }

  Color _getPositionColor(int position) {
    switch (position) {
      case 1:
        return Colors.amber[700]!; // Gold
      case 2:
        return Colors.grey[400]!; // Silver
      case 3:
        return Colors.orange[800]!; // Bronze
      default:
        if (position <= 10) {
          return Colors.green; // Points positions
        } else {
          return Colors.blue; // Non-points positions
        }
    }
  }

  Widget _buildLiveResults() {
    if (_livePositions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('Nessun dato di posizione live disponibile'),
        ),
      );
    }

    return Column(
      children: [
        // Live indicator
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        // Positions list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _livePositions.length,
            itemBuilder: (context, index) {
              final position = _livePositions[index];
              final interval = _liveIntervals.firstWhere(
                (i) => i['driver_number'] == position['driver_number'],
                orElse: () => <String, dynamic>{},
              );
              
              final pos = position['position'] ?? (index + 1);
              final driverNumber = position['driver_number']?.toString() ?? 'N/A';
              final gap = interval['gap'] ?? interval['interval'] ?? '';
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getPositionColor(pos),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        pos.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    'Pilota #$driverNumber',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: gap.isNotEmpty
                      ? Text(
                          gap,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoricalResults() {
    if (_results.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('Nessun risultato disponibile per questa sessione'),
        ),
      );
    }

    // Handle practice sessions differently
    final bool isPracticeSession = widget.session.name.toLowerCase().contains('prove') || 
                                   widget.session.name.toLowerCase().contains('practice');
    final bool isQualifying = widget.session.name.toLowerCase().contains('qualif');
    
    List<dynamic> resultsToShow = [];
    
    if (isPracticeSession && _results.isNotEmpty && _results[0]['Results'] != null) {
      // Practice session results from OpenF1
      resultsToShow = _results[0]['Results'];
    } else {
      // Race/Qualifying results from Jolpica - extract results from race data
      for (final raceData in _results) {
        if (raceData['Results'] != null) {
          resultsToShow.addAll(raceData['Results']);
        } else if (raceData['QualifyingResults'] != null) {
          resultsToShow.addAll(raceData['QualifyingResults']);
        }
      }
    }

    if (resultsToShow.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('Nessun risultato disponibile per questa sessione'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: resultsToShow.length,
      itemBuilder: (context, index) {
        final result = resultsToShow[index];
        final position = int.tryParse(result['position']?.toString() ?? '0') ?? (index + 1);
        final driver = result['Driver'];
        final constructor = result['Constructor'];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: isPracticeSession
              ? _buildPracticeResultTile(result, position, driver, constructor, index, resultsToShow)
              : isQualifying
                  ? _buildQualifyingResultTile(result, position, driver, constructor)
                  : _buildRaceResultTile(result, position, driver, constructor),
        );
      },
    );
  }

  // Calculate gap to next driver for practice sessions
  String _calculateGapToNext(int currentIndex, List<dynamic> results) {
    if (currentIndex >= results.length - 1) {
      return ''; // Last driver has no gap
    }
    
    final current = results[currentIndex];
    final next = results[currentIndex + 1];
    
    final currentBestLap = current['BestLap'];
    final nextBestLap = next['BestLap'];
    
    if (currentBestLap?['Time']?['time'] != null && nextBestLap?['Time']?['time'] != null) {
      try {
        final currentTime = _parseTimeToSeconds(currentBestLap['Time']['time']);
        final nextTime = _parseTimeToSeconds(nextBestLap['Time']['time']);
        final gap = nextTime - currentTime;
        
        if (gap > 0) {
          return '+${gap.toStringAsFixed(3)}s';
        }
      } catch (e) {
        // Error parsing times, return empty gap
        return '';
      }
    }
    
    return '';
  }
  
  // Parse lap time string to seconds
  double _parseTimeToSeconds(String timeString) {
    // Handle formats like "1:23.456" or "23.456"
    final parts = timeString.split(':');
    if (parts.length == 2) {
      // Format: "1:23.456"
      final minutes = double.parse(parts[0]);
      final seconds = double.parse(parts[1]);
      return minutes * 60 + seconds;
    } else {
      // Format: "23.456"
      return double.parse(timeString);
    }
  }

  // Build practice session result tile with gap information
  Widget _buildPracticeResultTile(dynamic result, int position, dynamic driver, dynamic constructor, int index, List<dynamic> allResults) {
    final bestLap = result['BestLap'];
    String resultText = '';
    if (bestLap != null && bestLap['Time'] != null) {
      resultText = bestLap['Time']['time'] ?? 'No time';
    } else {
      resultText = 'No time';
    }
    
    final gap = _calculateGapToNext(index, allResults);
    
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _getPositionColor(position),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            position.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      title: Text(
        '${driver?['givenName']} ${driver?['familyName']}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(constructor?['name'] ?? 'N/A'),
          if (result['laps'] != null)
            Text(
              '${result['laps']} giri',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
              ),
            ),
          if (gap.isNotEmpty)
            Text(
              gap,
              style: TextStyle(
                fontSize: 12,
                color: Colors.red[600],
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            resultText,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          if (bestLap?['lap'] != null)
            Text(
              'Giro ${bestLap['lap']}',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
              ),
            ),
        ],
      ),
    );
  }

  // Build qualifying result tile with Q1, Q2, Q3 times
  Widget _buildQualifyingResultTile(dynamic result, int position, dynamic driver, dynamic constructor) {
    final q1Time = result['Q1'];
    final q2Time = result['Q2'];
    final q3Time = result['Q3'];
    
    return ExpansionTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _getPositionColor(position),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            position.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      title: Text(
        '${driver?['givenName']} ${driver?['familyName']}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(constructor?['name'] ?? 'N/A'),
          Text(
            q3Time ?? q2Time ?? q1Time ?? 'No time',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (q1Time != null)
                _buildQualifyingTimeRow('Q1', q1Time),
              if (q2Time != null)
                _buildQualifyingTimeRow('Q2', q2Time),
              if (q3Time != null)
                _buildQualifyingTimeRow('Q3', q3Time),
            ],
          ),
        ),
      ],
    );
  }
  
  // Helper method to build qualifying time rows
  Widget _buildQualifyingTimeRow(String phase, String time) {
    Color phaseColor;
    switch (phase) {
      case 'Q1':
        phaseColor = Colors.red;
        break;
      case 'Q2':
        phaseColor = Colors.orange;
        break;
      case 'Q3':
        phaseColor = Colors.green;
        break;
      default:
        phaseColor = Colors.grey;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: phaseColor.withAlpha(40),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: phaseColor.withAlpha(100)),
            ),
            child: Text(
              phase,
              style: TextStyle(
                color: phaseColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Build race result tile (existing functionality)
  Widget _buildRaceResultTile(dynamic result, int position, dynamic driver, dynamic constructor) {
    final time = result['Time']?['time'];
    final status = result['status'];
    final resultText = time ?? status ?? 'N/A';
    
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _getPositionColor(position),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            position.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      title: Text(
        '${driver?['givenName']} ${driver?['familyName']}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(constructor?['name'] ?? 'N/A'),
      trailing: Text(
        resultText,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.session.name),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          if (_isLiveSession)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
            ),
        ],
      ),
      body: Column(
        children: [
          // Session info header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(50),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.race.raceName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatSessionLocal(context, widget.session.date, widget.session.time),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                  ),
                ),
                if (_isLiveSession) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'SESSIONE LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Results content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red.withAlpha(180),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _error!,
                                style: const TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadData,
                                child: const Text('Riprova'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _isLiveSession
                        ? _buildLiveResults()
                        : _buildHistoricalResults(),
          ),
        ],
      ),
    );
  }
}
