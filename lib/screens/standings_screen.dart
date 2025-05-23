import 'package:flutter/material.dart';

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({super.key});

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classifiche'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Piloti'),
            Tab(text: 'Costruttori'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _DriversStandings(),
          _ConstructorsStandings(),
        ],
      ),
    );
  }
}

class _DriversStandings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final drivers = [
      {'pos': 1, 'name': 'Max Verstappen', 'team': 'Red Bull', 'points': 150, 'change': 0},
      {'pos': 2, 'name': 'Charles Leclerc', 'team': 'Ferrari', 'points': 135, 'change': 1},
      {'pos': 3, 'name': 'Lando Norris', 'team': 'McLaren', 'points': 125, 'change': -1},
      {'pos': 4, 'name': 'Carlos Sainz', 'team': 'Ferrari', 'points': 118, 'change': 0},
      {'pos': 5, 'name': 'Oscar Piastri', 'team': 'McLaren', 'points': 105, 'change': 2},
      {'pos': 6, 'name': 'George Russell', 'team': 'Mercedes', 'points': 98, 'change': -1},
      {'pos': 7, 'name': 'Lewis Hamilton', 'team': 'Mercedes', 'points': 87, 'change': -1},
      {'pos': 8, 'name': 'Fernando Alonso', 'team': 'Aston Martin', 'points': 76, 'change': 0},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: drivers.length,
      itemBuilder: (context, index) {
        final driver = drivers[index];
        final change = driver['change'] as int;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: index < 3 
                    ? [Colors.amber, Colors.grey, Color(0xFFCD7F32)][index]
                    : Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${driver['pos']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            title: Text(
              driver['name'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(driver['team'] as String),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (change != 0) ...[
                  Icon(
                    change > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    color: change > 0 ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  '${driver['points']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ConstructorsStandings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final constructors = [
      {'pos': 1, 'team': 'Red Bull Racing', 'points': 185, 'change': 0},
      {'pos': 2, 'team': 'Ferrari', 'points': 253, 'change': 1},
      {'pos': 3, 'team': 'McLaren', 'points': 230, 'change': -1},
      {'pos': 4, 'team': 'Mercedes', 'points': 185, 'change': 0},
      {'pos': 5, 'team': 'Aston Martin', 'points': 94, 'change': 0},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: constructors.length,
      itemBuilder: (context, index) {
        final constructor = constructors[index];
        final change = constructor['change'] as int;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: index < 3 
                    ? [Colors.amber, Colors.grey, Color(0xFFCD7F32)][index]
                    : Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${constructor['pos']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            title: Text(
              constructor['team'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (change != 0) ...[
                  Icon(
                    change > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    color: change > 0 ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  '${constructor['points']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}