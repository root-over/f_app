import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'core/theme/theme_provider.dart';
import 'core/theme/f1_teams.dart';
import 'core/theme/f1_themes.dart';
import 'screens/main_screen.dart';
import '../providers/timezone_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('it_IT');
  tz.initializeTimeZones();
  
  // Initialize ThemeProvider with saved preferences
  final themeProvider = ThemeProvider();
  await themeProvider.initialize();
  
  runApp(F1App(themeProvider: themeProvider));
}

class F1App extends StatelessWidget {
  final ThemeProvider themeProvider;
  
  const F1App({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (context) => TimezoneProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          // Show loading screen while theme is initializing
          if (!themeProvider.isInitialized) {
            return MaterialApp(
              title: 'F1 Hub',
              theme: F1Themes.getTheme(F1Team.ferrari), // Default theme during loading
              home: const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Caricamento impostazioni...'),
                    ],
                  ),
                ),
              ),
              debugShowCheckedModeBanner: false,
            );
          }
          
          return MaterialApp(
            title: 'F1 Hub',
            theme: F1Themes.getTheme(themeProvider.currentTeam),
            darkTheme: F1Themes.getDarkTheme(themeProvider.currentTeam),
            themeMode: themeProvider.themeMode,
            home: const MainScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
