import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_provider.dart';
import '../widgets/next_race_card.dart';
import '../widgets/standings_preview.dart';
import '../widgets/latest_news.dart';
import '../widgets/team_selector.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('F1 Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: () => _showTeamSelector(context),
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () => context.read<ThemeProvider>().toggleThemeMode(),
          ),
        ],
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NextRaceCard(),
            SizedBox(height: 20),
            StandingsPreview(),
            SizedBox(height: 20),
            LatestNews(),
          ],
        ),
      ),
    );
  }

  void _showTeamSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const TeamSelector(),
    );
  }
}