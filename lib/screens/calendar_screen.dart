import 'package:flutter/material.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final races = [
      {'name': 'GP Bahrain', 'date': '2 Mar', 'circuit': 'Bahrain International Circuit', 'completed': true},
      {'name': 'GP Arabia Saudita', 'date': '9 Mar', 'circuit': 'Jeddah Corniche Circuit', 'completed': true},
      {'name': 'GP Australia', 'date': '24 Mar', 'circuit': 'Albert Park Circuit', 'completed': true},
      {'name': 'GP Giappone', 'date': '7 Apr', 'circuit': 'Suzuka Circuit', 'completed': true},
      {'name': 'GP Cina', 'date': '21 Apr', 'circuit': 'Shanghai International Circuit', 'completed': true},
      {'name': 'GP Miami', 'date': '5 Mag', 'circuit': 'Miami International Autodrome', 'completed': true},
      {'name': 'GP Emilia Romagna', 'date': '19 Mag', 'circuit': 'Autodromo Enzo e Dino Ferrari', 'completed': true},
      {'name': 'GP Monaco', 'date': '26 Mag', 'circuit': 'Circuit de Monaco', 'completed': false, 'next': true},
      {'name': 'GP Canada', 'date': '9 Giu', 'circuit': 'Circuit Gilles Villeneuve', 'completed': false},
      {'name': 'GP Spagna', 'date': '23 Giu', 'circuit': 'Circuit de Barcelona-Catalunya', 'completed': false},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario F1 2025'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: races.length,
        itemBuilder: (context, index) {
          final race = races[index];
          final isNext = race['next'] == true;
          final isCompleted = race['completed'] == true;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: isNext ? 8 : 2,
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
                    child: Text(
                      race['date'] as String,
                      style: TextStyle(
                        color: isNext || isCompleted ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      race['name'] as String,
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
                    Text(race['circuit'] as String),
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
                onTap: () {},
              ),
            ),
          );
        },
      ),
    );
  }
}
