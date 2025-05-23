import 'package:flutter/material.dart';
import 'f1_teams.dart';

class ThemeProvider with ChangeNotifier {
  F1Team _currentTeam = F1Team.ferrari;
  ThemeMode _themeMode = ThemeMode.system;

  F1Team get currentTeam => _currentTeam;
  ThemeMode get themeMode => _themeMode;

  void setTeam(F1Team team) {
    _currentTeam = team;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleThemeMode() {
    _themeMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    notifyListeners();
  }
}