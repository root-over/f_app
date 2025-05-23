import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../models/race.dart';
import '../services/api_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late Future<List<Race>> _racesFuture;

  @override
  void initState() {
    super.initState();
    _racesFuture = ApiService().getRaces(year: DateTime.now().year);
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('it_IT');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario F1 2025'),
      ),
      body: FutureBuilder<List<Race>>(
        future: _racesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Errore: \\${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nessuna gara trovata.'));
          }
          final races = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: races.length,
            itemBuilder: (context, index) {
              final race = races[index];
              final isCompleted = race.dateTime.isBefore(DateTime.now());
              final isNext = !isCompleted && (index == 0 || races[index - 1].dateTime.isBefore(DateTime.now()));
              final raceDateTimeLocal = race.dateTime.toLocal();
              final localTimeString = DateFormat.Hm().format(raceDateTimeLocal);
              final localDateString = DateFormat('d MMMM yyyy', 'it_IT').format(raceDateTimeLocal);
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: isNext ? 8 : 2,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RaceDetailScreen(
                          race: race,
                          sessions: race.sessions,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: isNext 
                          ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                          : null,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isNext 
                              ? Theme.of(context).colorScheme.primary
                              : isCompleted 
                                  ? Colors.green 
                                  : Colors.grey.withAlpha((0.3 * 255).toInt()),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                localDateString,
                                style: TextStyle(
                                  color: isNext || isCompleted ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                localTimeString,
                                style: TextStyle(
                                  color: isNext || isCompleted ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            race.raceName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isNext ? Theme.of(context).colorScheme.primary : null,
                            ),
                          ),
                          if (isNext) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'PROSSIMA',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(race.circuit.circuitName),
                          if (isCompleted) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Completata ✓',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: Icon(
                        isCompleted ? Icons.check_circle : Icons.schedule,
                        color: isCompleted ? Colors.green : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class RaceDetailScreen extends StatelessWidget {
  final Race race;
  final List<RaceSession> sessions;

  const RaceDetailScreen({super.key, required this.race, required this.sessions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(race.raceName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${race.date} - ${race.time}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              race.circuit.circuitName,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Sessioni:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '${session.name} - ${session.date} ${session.time}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
