import 'package:flutter/material.dart';
import '../models/constructor_standing.dart';

class TeamDetailScreen extends StatelessWidget {
  final ConstructorStanding constructorStanding;
  final int year;

  const TeamDetailScreen({
    super.key,
    required this.constructorStanding,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${constructorStanding.constructor.name} ($year)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nationality: ${constructorStanding.constructor.nationality}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Points: ${constructorStanding.points}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Position: ${constructorStanding.position}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Wins: ${constructorStanding.wins}', style: Theme.of(context).textTheme.titleMedium),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
