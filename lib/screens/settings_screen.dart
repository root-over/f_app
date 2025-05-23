import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    // TODO: Add timezone selection logic
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
                  onPressed: () => themeProvider.toggleThemeMode(force: ThemeMode.light),
                  child: const Text('Chiaro'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => themeProvider.toggleThemeMode(force: ThemeMode.dark),
                  child: const Text('Scuro'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => themeProvider.toggleThemeMode(force: ThemeMode.system),
                  child: const Text('Sistema'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Fuso orario', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          // TODO: Add timezone selection widget
          ListTile(
            title: const Text('Automatico (consigliato)'),
            leading: Radio<String>(
              value: 'auto',
              groupValue: 'auto', // TODO: bind to state
              onChanged: (value) {},
            ),
          ),
          // Add manual timezone selection here
        ],
      ),
    );
  }
}
