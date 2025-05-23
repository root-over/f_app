import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/constructor_standing.dart';
import '../core/theme/f1_teams.dart'; // Assuming F1Teams provides color/logo based on name

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  late Future<List<ConstructorStanding>> _constructorStandings;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _constructorStandings = _apiService.getConstructorStandings(year: 2025); // Example: Fetch for current year
  }

  // Helper to get F1Team enum from constructor name (you might need a more robust mapping)
  F1Team? _getTeamEnumFromName(String constructorName) {
    for (var team in F1Team.values) {
      // Attempt to match based on the 'name' field in F1TeamData
      if (F1Teams.getTeamData(team).name.toLowerCase() == constructorName.toLowerCase()) {
        return team;
      }
      // Attempt to match based on parts of the full name if direct match fails
      if (F1Teams.getTeamData(team).fullName.toLowerCase().contains(constructorName.toLowerCase())){
        return team;
      }
    }
    // Fallback for common name variations not directly in F1TeamData.name
    String lowerConstructorName = constructorName.toLowerCase();
    if (lowerConstructorName.contains("red bull")) return F1Team.redBull;
    if (lowerConstructorName.contains("ferrari")) return F1Team.ferrari;
    if (lowerConstructorName.contains("mercedes")) return F1Team.mercedes;
    if (lowerConstructorName.contains("mclaren")) return F1Team.mcLaren;
    if (lowerConstructorName.contains("aston martin")) return F1Team.astonMartin;
    if (lowerConstructorName.contains("alpine")) return F1Team.alpine;
    if (lowerConstructorName.contains("williams")) return F1Team.williams;
    if (lowerConstructorName.contains("rb") || lowerConstructorName.contains("racing bulls") || lowerConstructorName.contains("visa cash app")) return F1Team.alphaTauri; // Updated for AlphaTauri/RB
    if (lowerConstructorName.contains("stake") || lowerConstructorName.contains("kick sauber") || lowerConstructorName.contains("sauber")) return F1Team.alfaRomeo; // Updated for AlfaRomeo/Sauber/Stake
    if (lowerConstructorName.contains("haas")) return F1Team.haas;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Team F1'),
      ),
      body: FutureBuilder<List<ConstructorStanding>>(
        future: _constructorStandings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nessun dato disponibile'));
          }

          final teams = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final standing = teams[index];
              final f1TeamEnum = _getTeamEnumFromName(standing.constructorName);
              final teamData = f1TeamEnum != null
                               ? F1Teams.getTeamData(f1TeamEnum)
                               : F1TeamData(
                                   name: standing.constructorName,
                                   fullName: standing.constructorName,
                                   logo: "🏁", // Default logo
                                   primaryColor: Colors.grey,
                                   secondaryColor: Colors.blueGrey,
                                   accentColor: Colors.black // Added missing accentColor
                                 );

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
                          style: const TextStyle(fontSize: 24, color: Colors.white),
                        ),
                      ),
                    ),
                    title: Text(
                      standing.constructorName,
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
                          'Nazionalità: ${standing.constructorNationality}',
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
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          standing.points.toStringAsFixed(0),
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
                    onTap: () {
                      // Handle team tap, e.g., navigate to a team details screen
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}