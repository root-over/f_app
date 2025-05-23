import 'package:flutter/material.dart';
import 'f1_teams.dart';

class F1Themes {
  static ThemeData getTheme(F1Team team) {
    final teamData = F1Teams.getTeamData(team);
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: teamData.primaryColor,
        primary: teamData.primaryColor,
        secondary: teamData.secondaryColor,
        tertiary: teamData.accentColor,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: teamData.primaryColor,
        foregroundColor: _getContrastColor(teamData.primaryColor),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: _getContrastColor(teamData.primaryColor),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: teamData.primaryColor,
        selectedItemColor: teamData.accentColor,
        unselectedItemColor: _getContrastColor(teamData.primaryColor).withAlpha((0.6 * 255).toInt()),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: teamData.secondaryColor,
        foregroundColor: _getContrastColor(teamData.secondaryColor),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: teamData.primaryColor.withOpacity(0.1),
        labelStyle: TextStyle(color: teamData.primaryColor),
        side: BorderSide(color: teamData.primaryColor),
      ),
    );
  }

  static ThemeData getDarkTheme(F1Team team) {
    final teamData = F1Teams.getTeamData(team);
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: teamData.primaryColor,
        primary: teamData.primaryColor,
        secondary: teamData.secondaryColor,
        tertiary: teamData.accentColor,
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: teamData.primaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: teamData.primaryColor,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: teamData.primaryColor,
        unselectedItemColor: Colors.grey,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: const Color(0xFF2D2D2D),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: teamData.primaryColor,
        foregroundColor: _getContrastColor(teamData.primaryColor),
      ),
    );
  }

  static Color _getContrastColor(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}