import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/race.dart';
import '../providers/timezone_provider.dart';

class RaceDetailScreen extends StatelessWidget {
  final Race race;
  final List<RaceSession> sessions;
  const RaceDetailScreen({super.key, required this.race, required this.sessions});

  String _formatSessionLocal(BuildContext context, String date, String time) {
    try {
      final timezoneProvider = Provider.of<TimezoneProvider>(context, listen: false);
      final dtUtc = DateTime.parse('$date' 'T' '$time');
      final dtTz = tz.TZDateTime.from(dtUtc, timezoneProvider.currentLocation);
      final dateStr = DateFormat('d MMMM yyyy', 'it_IT').format(dtTz);
      final timeStr = DateFormat.Hm().format(dtTz);
      return '$dateStr, ore $timeStr';
    } catch (_) {
      return '$date $time';
    }
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('it_IT');
    return Scaffold(
      appBar: AppBar(
        title: Text(race.raceName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(race.circuit.circuitName, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Data gara: ${_formatSessionLocal(context, race.date, race.time)}'),
            const SizedBox(height: 16),
            Text('Sessioni:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...sessions.map((session) => ListTile(
              title: Text(session.name),
              subtitle: Text(_formatSessionLocal(context, session.date, session.time)),
            )),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                if (race.url.isNotEmpty) {
                  // Open official F1 page
                  // You can use url_launcher here if desired
                }
              },
              child: const Text('Pagina ufficiale F1'),
            ),
          ],
        ),
      ),
    );
  }
}
