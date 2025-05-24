import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;
import '../providers/timezone_provider.dart';
import '../core/theme/theme_provider.dart';
import '../core/theme/f1_teams.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _selectedTimezone;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final timezoneProvider = Provider.of<TimezoneProvider>(context);
    final timezoneMode = timezoneProvider.mode;
    final timezones = tz.timeZoneDatabase.locations.keys.toList()..sort();
    _selectedTimezone = timezoneProvider.manualTimezone;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Tema', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async => await themeProvider.setThemeMode(ThemeMode.light),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Text('Chiaro'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async => await themeProvider.setThemeMode(ThemeMode.dark),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  child: const Text('Scuro'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async => await themeProvider.setThemeMode(ThemeMode.system),
                  child: const Text('Sistema'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Tema Team', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: F1Team.values.map((team) {
              final teamData = F1Teams.teams[team]!;
              return ChoiceChip(
                label: Text(teamData.name),
                selected: themeProvider.currentTeam == team,
                onSelected: (_) async => await themeProvider.setTeam(team),
                avatar: Text(teamData.logo),
                selectedColor: teamData.primaryColor.withAlpha((255*0.2).round()),
                backgroundColor: teamData.primaryColor.withAlpha((255*0.08).round()),
                labelStyle: TextStyle(
                  color: themeProvider.currentTeam == team
                      ? teamData.primaryColor
                      : Colors.black,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('Fuso orario', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ListTile(
            title: const Text('Automatico (consigliato)'),
            leading: Radio<String>(
              value: 'auto',
              groupValue: timezoneMode,
              onChanged: (value) {
                timezoneProvider.setMode('auto');
                setState(() {});
              },
            ),
          ),
          ListTile(
            title: const Text('Manuale'),
            leading: Radio<String>(
              value: 'manual',
              groupValue: timezoneMode,
              onChanged: (value) {
                timezoneProvider.setMode('manual');
                setState(() {});
              },
            ),
          ),
          if (timezoneMode == 'manual') ...[
            TextField(
              decoration: const InputDecoration(
                labelText: 'Cerca fuso orario',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  // Reset la selezione se il valore corrente non è più visibile
                  if (_selectedTimezone != null && !timezones.where((tzName) => _searchQuery.isEmpty || tzName.toLowerCase().contains(_searchQuery.toLowerCase())).contains(_selectedTimezone)) {
                    _selectedTimezone = null;
                    timezoneProvider.setManualTimezone('');
                  }
                });
              },
            ),
            DropdownButton<String>(
              value: _selectedTimezone,
              hint: const Text('Seleziona fuso orario'),
              isExpanded: true,
              items: timezones
                  .where((tzName) => _searchQuery.isEmpty || tzName.toLowerCase().contains(_searchQuery.toLowerCase()))
                  .map((tzName) => DropdownMenuItem(
                        value: tzName,
                        child: Text(tzName),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTimezone = value;
                  timezoneProvider.setManualTimezone(value!);
                });
              },
            ),
          ],
        ],
      ),
    );
  }
}
