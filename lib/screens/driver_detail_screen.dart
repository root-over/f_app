import 'package:flutter/material.dart';
import '../models/driver_standing.dart';

class DriverDetailScreen extends StatelessWidget {
  final DriverStanding driverStanding;
  final int year;

  const DriverDetailScreen({
    super.key,
    required this.driverStanding,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${driverStanding.driver.givenName} ${driverStanding.driver.familyName} ($year)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Team: ${driverStanding.constructors.isNotEmpty ? driverStanding.constructors.first.name : 'N/A'}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Points: ${driverStanding.points}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Position: ${driverStanding.position}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Wins: ${driverStanding.wins}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Nationality: ${driverStanding.driver.nationality}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Date of Birth: ${driverStanding.driver.dateOfBirth}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (driverStanding.driver.permanentNumber != null)
              Text('Permanent Number: ${driverStanding.driver.permanentNumber}', style: Theme.of(context).textTheme.titleMedium),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
