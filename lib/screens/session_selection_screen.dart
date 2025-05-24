import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/race.dart';
import '../providers/timezone_provider.dart';
import 'session_results_screen.dart';

class SessionSelectionScreen extends StatefulWidget {
  final Race race;

  const SessionSelectionScreen({super.key, required this.race});

  @override
  State<SessionSelectionScreen> createState() => _SessionSelectionScreenState();
}

class _SessionSelectionScreenState extends State<SessionSelectionScreen> {
  // Add refresh indicator key for pull-to-refresh
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  // Add refresh handler method
  Future<void> _handleRefresh() async {
    // For now, just simulate a refresh delay and rebuild the UI
    // In a real app, this might reload race data from the API
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {});
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

  Color _getSessionStatusColor(RaceSession session) {
    try {
      final sessionDateTime = DateTime.parse('${session.date}T${session.time}');
      final now = DateTime.now();
      
      // Session completed
      if (sessionDateTime.isBefore(now.subtract(const Duration(hours: 3)))) {
        return Colors.green;
      }
      // Session in progress or recently completed (within 3 hours)
      else if (sessionDateTime.isBefore(now.add(const Duration(hours: 1)))) {
        return Colors.orange;
      }
      // Future session
      else {
        return Colors.blue;
      }
    } catch (e) {
      return Colors.grey;
    }
  }

  IconData _getSessionIcon(String sessionName) {
    switch (sessionName.toLowerCase()) {
      case 'prove libere 1':
      case 'prove libere 2':
      case 'prove libere 3':
        return Icons.speed;
      case 'qualifiche':
      case 'sprint qualifying':
      case 'sprint shootout':
        return Icons.timer;
      case 'sprint':
        return Icons.flash_on;
      case 'gara':
        return Icons.flag;
      default:
        return Icons.sports_motorsports;
    }
  }

  String _getSessionStatus(RaceSession session) {
    try {
      final sessionDateTime = DateTime.parse('${session.date}T${session.time}');
      final now = DateTime.now();
      
      if (sessionDateTime.isBefore(now.subtract(const Duration(hours: 3)))) {
        return 'Completata';
      } else if (sessionDateTime.isBefore(now.add(const Duration(hours: 1)))) {
        return 'In corso';
      } else {
        return 'Programmata';
      }
    } catch (e) {
      return 'Sconosciuto';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.race.raceName),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          // Header with race info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withAlpha(200),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.race.circuit.circuitName,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Seleziona una sessione per vedere i risultati',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary.withAlpha(200),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Sessions list with pull-to-refresh
          Expanded(
            child: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _handleRefresh,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: widget.race.sessions.length,
                itemBuilder: (context, index) {
                  final session = widget.race.sessions[index];
                  final statusColor = _getSessionStatusColor(session);
                  final status = _getSessionStatus(session);
                  final icon = _getSessionIcon(session.name);
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 4,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SessionResultsScreen(
                              race: widget.race,
                              session: session,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Session icon
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: statusColor.withAlpha(50),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: statusColor.withAlpha(100),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                icon,
                                color: statusColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Session info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    session.name,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatSessionLocal(context, session.date, session.time),
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withAlpha(50),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Arrow
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Theme.of(context).colorScheme.onSurface.withAlpha(120),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
