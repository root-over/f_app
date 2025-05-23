import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_provider.dart';
import '../core/theme/f1_teams.dart';

class TeamSelector extends StatelessWidget {
  const TeamSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Scegli il tuo team preferito',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: F1Team.values.length,
              itemBuilder: (context, index) {
                final team = F1Team.values[index];
                final teamData = F1Teams.getTeamData(team);
                final isSelected = context.watch<ThemeProvider>().currentTeam == team;

                return InkWell(
                  onTap: () {
                    context.read<ThemeProvider>().setTeam(team);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: teamData.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected 
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            teamData.logo,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            teamData.name,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
