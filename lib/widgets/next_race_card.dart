import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/race.dart';
import '../screens/session_selection_screen.dart';
import '../services/api_service.dart';
import '../services/live_race_service.dart';
import '../providers/timezone_provider.dart';

class NextRaceCard extends StatefulWidget {
  const NextRaceCard({super.key});

  @override
  State<NextRaceCard> createState() => _NextRaceCardState();
}

class _NextRaceCardState extends State<NextRaceCard> {
  late Future<Race?> _nextRaceFuture;
  final LiveRaceService _liveRaceService = LiveRaceService.instance;
  LiveRaceInfo? _liveRaceInfo;
  StreamSubscription<LiveRaceInfo>? _liveRaceSubscription;

  @override
  void initState() {
    super.initState();
    _nextRaceFuture = _fetchNextRace();
    _setupLiveRaceMonitoring();
  }

  void _setupLiveRaceMonitoring() {
    _liveRaceService.startLiveMonitoring();
    
    _liveRaceSubscription = _liveRaceService.liveRaceInfoStream.listen((liveInfo) {
      if (mounted) {
        setState(() {
          _liveRaceInfo = liveInfo;
        });
      }
    });
  }

  @override
  void dispose() {
    _liveRaceSubscription?.cancel();
    super.dispose();
  }

  Future<Race?> _fetchNextRace() async {
    final api = ApiService();
    final races = await api.getRaces(year: DateTime.now().year);
    final now = DateTime.now();
    try {
      return races.firstWhere(
        (race) {
          final dt = DateTime.parse('${race.date}T${race.time}');
          return dt.isAfter(now);
        },
      );
    } catch (_) {
      return races.isNotEmpty ? races.last : null;
    }
  }

  Widget _buildLiveStatusWidget(LiveRaceInfo liveInfo) {
    final status = liveInfo.status;
    final latestMessage = liveInfo.raceControlMessages.isNotEmpty 
        ? liveInfo.raceControlMessages.first 
        : null;

    // Colori basati sullo stato
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case LiveRaceStatus.racing:
        statusColor = Colors.green;
        statusText = 'GARA LIVE';
        statusIcon = Icons.speed;
        break;
      case LiveRaceStatus.paused:
        statusColor = Colors.orange;
        statusText = 'GARA SOSPESA';
        statusIcon = Icons.pause;
        break;
      case LiveRaceStatus.yellowFlag:
        statusColor = Colors.yellow.shade700;
        statusText = 'BANDIERA GIALLA';
        statusIcon = Icons.flag;
        break;
      case LiveRaceStatus.redFlag:
        statusColor = Colors.red;
        statusText = 'BANDIERA ROSSA';
        statusIcon = Icons.flag;
        break;
      case LiveRaceStatus.safetyCar:
        statusColor = Colors.orange;
        statusText = 'SAFETY CAR';
        statusIcon = Icons.car_crash;
        break;
      case LiveRaceStatus.virtualSafetyCar:
        statusColor = Colors.amber;
        statusText = 'VSC';
        statusIcon = Icons.warning;
        break;
      case LiveRaceStatus.finished:
        statusColor = Colors.blue;
        statusText = 'GARA FINITA';
        statusIcon = Icons.flag_outlined;
        break;
      default:
        statusColor = Colors.green;
        statusText = 'LIVE';
        statusIcon = Icons.live_tv;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Indicatore stato principale
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animazione pulsante per stati live
              if (status == LiveRaceStatus.racing)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 700),
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.3, end: 1),
                    duration: const Duration(milliseconds: 700),
                    builder: (context, value, child) {
                      return Opacity(opacity: value, child: child);
                    },
                    child: const SizedBox.expand(),
                  ),
                )
              else
                Icon(
                  statusIcon,
                  color: Colors.white,
                  size: 16,
                ),
              if (status != LiveRaceStatus.racing) const SizedBox(width: 4),
              Text(
                statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        // Messaggio race control se disponibile
        if (latestMessage != null) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  latestMessage.icon,
                  style: const TextStyle(fontSize: 10),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    latestMessage.message != null 
                        ? (latestMessage.message!.length > 20 
                            ? '${latestMessage.message!.substring(0, 20)}...'
                            : latestMessage.message!)
                        : 'Race control message',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final timezoneProvider = Provider.of<TimezoneProvider>(context);
    return FutureBuilder<Race?>(
      future: _nextRaceFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('Nessuna gara trovata.'),
            ),
          );
        }
        final race = snapshot.data!;
        final now = tz.TZDateTime.now(timezoneProvider.currentLocation);
        final raceDateTimeUtc = DateTime.parse('${race.date}T${race.time}');
        final raceDateTimeLocal = tz.TZDateTime.from(raceDateTimeUtc, timezoneProvider.currentLocation);
        final localTimeString = DateFormat.Hm().format(raceDateTimeLocal);
        final localDateString = DateFormat('d MMMM yyyy', 'it_IT').format(raceDateTimeLocal);
        final difference = raceDateTimeLocal.difference(now);
        String timeLeft = '';
        Widget? statusWidget;
        
        // Verifica se abbiamo dati live e se la gara potrebbe essere in corso
        bool isRaceTimeWindow = difference.inSeconds <= 0 && difference.inSeconds > -7200; // Entro 2h dall'inizio
        
        if (_liveRaceInfo != null && _liveRaceInfo!.status != LiveRaceStatus.notLive && 
            _liveRaceInfo!.status != LiveRaceStatus.noSession && isRaceTimeWindow) {
          // Usa il widget di stato live avanzato
          statusWidget = _buildLiveStatusWidget(_liveRaceInfo!);
          timeLeft = '';
        } else if (difference.inSeconds > 0) {
          // Calcolo giorni: ogni scatto di mezzanotte conta come un giorno
          final todayTz = tz.TZDateTime(timezoneProvider.currentLocation, now.year, now.month, now.day);
          int giorni = raceDateTimeLocal.difference(todayTz).inDays;
          if (giorni > 0) {
            final giornoLabel = giorni == 1 ? 'giorno' : 'giorni';
            timeLeft = 'Tra $giorni $giornoLabel';
          } else if (difference.inHours >= 1) {
            final ore = difference.inHours;
            final minuti = difference.inMinutes % 60;
            if (ore > 0 && minuti > 0) {
              timeLeft = 'Tra $ore h $minuti min';
            } else if (ore > 0) {
              timeLeft = 'Tra $ore h';
            } else {
              timeLeft = 'Tra $minuti min';
            }
          } else {
            timeLeft = 'Tra ${difference.inMinutes} min';
          }
        } else if (difference.inSeconds <= 0 && difference.inSeconds > -7200) { // Gara dovrebbe essere in corso
          // Fallback per quando non abbiamo dati live ma la gara dovrebbe essere in corso
          statusWidget = Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 700),
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.3, end: 1),
                  duration: const Duration(milliseconds: 700),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: child,
                    );
                  },
                  child: const SizedBox.expand(),
                ),
              ),
              const Text(
                'Gara in corso',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
          timeLeft = '';
        }
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SessionSelectionScreen(race: race),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.flag,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'PROSSIMA GARA',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    race.raceName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    race.circuit.circuitName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DATA',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$localDateString, ore $localTimeString',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: statusWidget ?? Text(
                          timeLeft,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
