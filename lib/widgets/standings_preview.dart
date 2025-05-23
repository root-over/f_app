import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/driver_standing.dart';

class StandingsPreview extends StatefulWidget {
  final VoidCallback? onSeeAll;
  const StandingsPreview({super.key, this.onSeeAll});

  @override
  State<StandingsPreview> createState() => _StandingsPreviewState();
}

class _StandingsPreviewState extends State<StandingsPreview> {
  late Future<List<DriverStanding>> _standingsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _standingsFuture = _apiService.getDriverStandings(year: DateTime.now().year);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Classifica Piloti',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: widget.onSeeAll,
              child: const Text('Vedi tutto'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: FutureBuilder<List<DriverStanding>>(
            future: _standingsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Errore nel caricamento classifica: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Nessuna classifica disponibile.'),
                );
              }
              final drivers = snapshot.data!.take(3).toList();
              return Column(
                children: drivers.map((driver) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        driver.position.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      '${driver.driver.givenName} ${driver.driver.familyName}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(driver.constructors.isNotEmpty ? driver.constructors.first.name : ''),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${driver.points.toStringAsFixed(0)} pts',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}