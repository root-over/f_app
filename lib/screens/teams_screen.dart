import 'package:flutter/material.dart';
import '../core/theme/f1_teams.dart';

class TeamsScreen extends StatelessWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team F1'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: F1Team.values.length,
        itemBuilder: (context, index) {
          final team = F1Team.values[index];
          final teamData = F1Teams.getTeamData(team);
          
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    teamData.primaryColor.withAlpha((0.1 * 255).toInt()),
                    teamData.secondaryColor.withAlpha((0.1 * 255).toInt()),
                  ],
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(20),
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: teamData.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      teamData.logo,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                title: Text(
                  teamData.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      teamData.fullName,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: teamData.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: teamData.secondaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
            ),
          );
        },
      ),
    );
  }
}