import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import '../widgets/next_race_card.dart';
import '../widgets/standings_preview.dart';
import '../widgets/latest_news.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onSeeAllStandings;
  const HomeScreen({super.key, this.onSeeAllStandings});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _localeInitialized = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_localeInitialized) {
      initializeDateFormatting('it_IT').then((_) {
        setState(() {
          _localeInitialized = true;
        });
      });
    }
  }

  Future<void> _handleRefresh() async {
    // Trigger refresh of all widgets by rebuilding the page
    setState(() {});
    
    // Add a small delay to show the refresh animation
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    if (!_localeInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('F1 Hub'),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const NextRaceCard(),
              const SizedBox(height: 20),
              StandingsPreview(
                onSeeAll: widget.onSeeAllStandings,
              ),
              const SizedBox(height: 20),
              const LatestNews(),
            ],
          ),
        ),
      ),
    );
  }
}