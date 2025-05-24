import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/race.dart';
import '../screens/session_selection_screen.dart';
import '../services/api_service.dart';
import '../providers/timezone_provider.dart';

class NextRaceCard extends StatefulWidget {
  const NextRaceCard({super.key});

  @override
  State<NextRaceCard> createState() => _NextRaceCardState();
}

class _NextRaceCardState extends State<NextRaceCard> {
  late Future<Race?> _nextRaceFuture;

  @override
  void initState() {
    super.initState();
    _nextRaceFuture = _fetchNextRace();
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
        if (difference.inSeconds > 0) {
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
        } else if (difference.inSeconds <= 0 && difference.inSeconds > -7200) { // Gara in corso (entro 2h)
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
                      color: const Color(0xFF4CAF50).withAlpha((255 * 0.5).round()), // Usa un colore non deprecato
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
                    Theme.of(context).colorScheme.primary.withAlpha((0.7 * 255).toInt()),
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
                      color: Theme.of(context).colorScheme.onPrimary.withAlpha((0.9 * 255).toInt()),
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
                              color: Theme.of(context).colorScheme.onPrimary.withAlpha((0.8 * 255).toInt()),
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
                          color: Theme.of(context).colorScheme.onPrimary.withAlpha((0.2 * 255).toInt()),
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
