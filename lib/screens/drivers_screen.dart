import 'package:flutter/material.dart';

class DriversScreen extends StatelessWidget {
  const DriversScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final drivers = [
      {'name': 'Max Verstappen', 'team': 'Red Bull Racing', 'number': 1, 'country': '🇳🇱', 'points': 150},
      {'name': 'Charles Leclerc', 'team': 'Ferrari', 'number': 16, 'country': '🇲🇨', 'points': 135},
      {'name': 'Lando Norris', 'team': 'McLaren', 'number': 4, 'country': '🇬🇧', 'points': 125},
      {'name': 'Carlos Sainz', 'team': 'Ferrari', 'number': 55, 'country': '🇪🇸', 'points': 118},
      {'name': 'Oscar Piastri', 'team': 'McLaren', 'number': 81, 'country': '🇦🇺', 'points': 105},
      {'name': 'George Russell', 'team': 'Mercedes', 'number': 63, 'country': '🇬🇧', 'points': 98},
      {'name': 'Lewis Hamilton', 'team': 'Mercedes', 'number': 44, 'country': '🇬🇧', 'points': 87},
      {'name': 'Fernando Alonso', 'team': 'Aston Martin', 'number': 14, 'country': '🇪🇸', 'points': 76},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Piloti F1'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: drivers.length,
        itemBuilder: (context, index) {
          final driver = drivers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Hero(
                tag: 'driver_${driver['number']}',
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    '${driver['number']}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              title: Row(
                children: [
                  Text(
                    '${driver['country']} ',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    driver['name'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    driver['team'] as String,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${driver['points']}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'punti',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              onTap: () => _showDriverDetails(context, driver),
            ),
          );
        },
      ),
    );
  }

  void _showDriverDetails(BuildContext context, Map<String, dynamic> driver) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Hero(
                  tag: 'driver_${driver['number']}',
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      '${driver['number']}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${driver['country']} ${driver['name']}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  driver['team'] as String,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatCard('Punti', '${driver['points']}'),
                    _StatCard('Vittorie', '3'),
                    _StatCard('Podi', '8'),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}