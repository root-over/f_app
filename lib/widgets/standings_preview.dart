import 'package:flutter/material.dart';

class StandingsPreview extends StatelessWidget {
  const StandingsPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final drivers = [
      {'name': 'Max Verstappen', 'team': 'Red Bull', 'points': 150, 'position': 1},
      {'name': 'Charles Leclerc', 'team': 'Ferrari', 'points': 135, 'position': 2},
      {'name': 'Lando Norris', 'team': 'McLaren', 'points': 125, 'position': 3},
    ];

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
              onPressed: () {},
              child: const Text('Vedi tutto'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: drivers.map((driver) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    '${driver['position']}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  driver['name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(driver['team'] as String),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${driver['points']} pts',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}