import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/f1_themes.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const F1App());
}

class F1App extends StatelessWidget {
  const F1App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
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
