import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/driver_standing.dart';
import '../models/constructor_standing.dart';
import 'driver_detail_screen.dart'; 
import 'team_detail_screen.dart';   
import '../core/theme/f1_teams.dart'; 

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({super.key});

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  int _selectedYear = DateTime.now().year; // Default to current year
  // Generate years from current down to 1950 for the dropdown
  final List<int> _availableYears = List.generate(
    DateTime.now().year - 1950 + 1, // Number of years to generate
    (index) => DateTime.now().year - index // Calculate year for each index
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onYearChanged(int? newYear) {
    if (newYear != null && newYear != _selectedYear) {
      setState(() {
        _selectedYear = newYear;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classifiche'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButton<int>(
              value: _selectedYear,
              icon: const Icon(Icons.arrow_downward, color: Colors.white), 
              dropdownColor: Theme.of(context).appBarTheme.backgroundColor, 
              style: TextStyle(color: Theme.of(context).primaryIconTheme.color ?? Colors.white), 
              underline: Container(), 
              onChanged: _onYearChanged,
              items: _availableYears.map<DropdownMenuItem<int>>((int year) {
                return DropdownMenuItem<int>(
                  value: year,
                  child: Text(year.toString(), style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.white)),
                );
              }).toList(),
            ),
          ),
        ],
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
          _DriversStandingsList(key: ValueKey('drivers_$_selectedYear'), year: _selectedYear, apiService: _apiService),
          _ConstructorsStandingsList(key: ValueKey('constructors_$_selectedYear'), year: _selectedYear, apiService: _apiService),
        ],
      ),
    );
  }
}

class _DriversStandingsList extends StatefulWidget {
  final int year;
  final ApiService apiService;

  const _DriversStandingsList({required Key key, required this.year, required this.apiService}) : super(key: key);

  @override
  State<_DriversStandingsList> createState() => _DriversStandingsListState();
}

class _DriversStandingsListState extends State<_DriversStandingsList> {
  late Future<List<DriverStanding>> _driverStandingsFuture;

  @override
  void initState() {
    super.initState();
    _fetchStandings();
  }
  
  @override
  void didUpdateWidget(covariant _DriversStandingsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.year != oldWidget.year) {
      _fetchStandings();
    }
  }

  void _fetchStandings() {
    _driverStandingsFuture = widget.apiService.getDriverStandings(year: widget.year);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DriverStanding>>(
      future: _driverStandingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Errore nel caricamento piloti: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Nessuna classifica piloti disponibile per quest'anno."));
        }

        final drivers = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: drivers.length,
          itemBuilder: (context, index) {
            final driverStanding = drivers[index]; // Renamed for clarity
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Hero(
                  tag: 'driver_standings_${driverStanding.driver.driverId}_${widget.year}', 
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      driverStanding.position.toString(),
                      style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                title: Text('${driverStanding.driver.givenName} ${driverStanding.driver.familyName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(driverStanding.constructors.isNotEmpty ? driverStanding.constructors.first.name : 'N/A'),
                trailing: Text('${driverStanding.points.toStringAsFixed(0)} Punti', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DriverDetailScreen(
                        driverStanding: driverStanding,
                        year: widget.year,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _ConstructorsStandingsList extends StatefulWidget {
  final int year;
  final ApiService apiService;

  const _ConstructorsStandingsList({required Key key, required this.year, required this.apiService}) : super(key: key);

  @override
  State<_ConstructorsStandingsList> createState() => _ConstructorsStandingsListState();
}

class _ConstructorsStandingsListState extends State<_ConstructorsStandingsList> {
  late Future<List<ConstructorStanding>> _constructorStandingsFuture;

  @override
  void initState() {
    super.initState();
    _fetchStandings();
  }

  @override
  void didUpdateWidget(covariant _ConstructorsStandingsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.year != oldWidget.year) {
      _fetchStandings();
    }
  }

  void _fetchStandings() {
    _constructorStandingsFuture = widget.apiService.getConstructorStandings(year: widget.year);
  }
  
  F1Team? _getTeamEnumFromName(String constructorName) {
    // Corrected enum names and added fallbacks
    final lowerConstructorName = constructorName.toLowerCase();
    if (lowerConstructorName.contains('ferrari')) return F1Team.ferrari;
    if (lowerConstructorName.contains('mercedes')) return F1Team.mercedes;
    if (lowerConstructorName.contains('red bull')) return F1Team.redBull;
    if (lowerConstructorName.contains('mclaren')) return F1Team.mcLaren; // Corrected enum name
    if (lowerConstructorName.contains('alpine')) return F1Team.alpine;
    if (lowerConstructorName.contains('aston martin')) return F1Team.astonMartin;
    if (lowerConstructorName.contains('haas')) return F1Team.haas;
    if (lowerConstructorName.contains('alphatauri') || lowerConstructorName.contains('rb') || lowerConstructorName.contains('racing bulls')) return F1Team.alphaTauri;
    if (lowerConstructorName.contains('alfa romeo') || lowerConstructorName.contains('sauber') || lowerConstructorName.contains('kick sauber') || lowerConstructorName.contains('stake')) return F1Team.alfaRomeo; // Corrected to alfaRomeo, assuming Sauber is represented by it
    if (lowerConstructorName.contains('williams')) return F1Team.williams;
    
    // Direct match attempt
    for (var team in F1Team.values) {
      if (team.name.toLowerCase() == lowerConstructorName) {
        return team;
      }
    }
    return null; 
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ConstructorStanding>>(
      future: _constructorStandingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Errore nel caricamento costruttori: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Nessuna classifica costruttori disponibile per quest'anno."));
        }

        final constructors = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: constructors.length,
          itemBuilder: (context, index) {
            final constructorStanding = constructors[index]; // Renamed for clarity
            final teamEnum = _getTeamEnumFromName(constructorStanding.constructor.name);
            final teamData = teamEnum != null ? F1Teams.getTeamData(teamEnum) : null; // Use F1Teams.getTeamData static method

            Widget logoWidget;
            if (teamData != null && teamData.logo != null && teamData.logo!.isNotEmpty) {
              bool isAsset = teamData.logo!.contains('.png') || teamData.logo!.contains('.svg');
              if (isAsset) {
                logoWidget = Padding(
                  padding: const EdgeInsets.all(0),
                  child: Image.asset(teamData.logo!, fit: BoxFit.contain),
                );
              } else {
                logoWidget = Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(teamData.logo!, style: const TextStyle(fontSize: 20)),
                );
              }
            } else {
              logoWidget = Text(
                constructorStanding.position.toString(),
                style: TextStyle(
                  color: (teamData?.primaryColor ?? Theme.of(context).colorScheme.primary).computeLuminance() > 0.5 
                      ? Colors.black 
                      : Colors.white, 
                  fontWeight: FontWeight.bold
                ),
              );
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Hero(
                  tag: 'constructor_standings_${constructorStanding.constructor.constructorId}_${widget.year}',
                  child: CircleAvatar(
                    backgroundColor: teamData?.primaryColor ?? Theme.of(context).colorScheme.primary,
                    child: logoWidget,
                  ),
                ),
                title: Text(constructorStanding.constructor.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Nazionalità: ${constructorStanding.constructor.nationality}'),
                trailing: Text('${constructorStanding.points.toStringAsFixed(0)} Punti', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TeamDetailScreen(
                        constructorStanding: constructorStanding,
                        year: widget.year,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

// TODO: Create DriverDetailScreen and TeamDetailScreen
// These will be modified versions of the original DriversScreen and TeamsScreen,
// designed to display details of a single driver/team passed via constructor.