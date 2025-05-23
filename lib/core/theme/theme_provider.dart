import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'f1_teams.dart';

class ThemeProvider with ChangeNotifier {
  static const String _teamKey = 'selected_team';
  static const String _themeModeKey = 'theme_mode';

  F1Team _currentTeam = F1Team.ferrari;
  ThemeMode _themeMode = ThemeMode.system;
  bool _isInitialized = false;

  F1Team get currentTeam => _currentTeam;
  ThemeMode get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;

  /// Initialize the ThemeProvider by loading saved preferences
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load saved team preference
      final savedTeamIndex = prefs.getInt(_teamKey);
      if (savedTeamIndex != null && 
          savedTeamIndex >= 0 && 
          savedTeamIndex < F1Team.values.length) {
        _currentTeam = F1Team.values[savedTeamIndex];
      }
      
      // Load saved theme mode preference
      final savedThemeModeIndex = prefs.getInt(_themeModeKey);
      if (savedThemeModeIndex != null && 
          savedThemeModeIndex >= 0 && 
          savedThemeModeIndex < ThemeMode.values.length) {
        _themeMode = ThemeMode.values[savedThemeModeIndex];
      }
    } catch (e) {
      // If SharedPreferences fails, continue with default values
      debugPrint('Failed to load theme preferences: $e');
      // Reset to defaults
      _currentTeam = F1Team.ferrari;
      _themeMode = ThemeMode.system;
    }
    
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setTeam(F1Team team) async {
    _currentTeam = team;
    
    try {
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_teamKey, team.index);
    } catch (e) {
      // If saving fails, continue with the change in memory
      debugPrint('Failed to save team preference: $e');
    }
    
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    
    try {
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, mode.index);
    } catch (e) {
      // If saving fails, continue with the change in memory
      debugPrint('Failed to save theme mode preference: $e');
    }
    
    notifyListeners();
  }

  Future<void> toggleThemeMode() async {
    final newMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    await setThemeMode(newMode);
  }
}