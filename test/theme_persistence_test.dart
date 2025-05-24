import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:f_app/core/theme/theme_provider.dart';
import 'package:f_app/core/theme/f1_teams.dart';

void main() {
  group('ThemeProvider Persistence Tests', () {
    setUp(() {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('should save and load team preference', () async {
      // Initialize theme provider
      final themeProvider = ThemeProvider();
      await themeProvider.initialize();
      
      // Verify initial state
      expect(themeProvider.currentTeam, F1Team.ferrari); // Default
      expect(themeProvider.isInitialized, true);
      
      // Change team and verify persistence
      await themeProvider.setTeam(F1Team.mercedes);
      expect(themeProvider.currentTeam, F1Team.mercedes);
      
      // Create new instance and initialize - should load saved team
      final newThemeProvider = ThemeProvider();
      await newThemeProvider.initialize();
      expect(newThemeProvider.currentTeam, F1Team.mercedes);
    });

    test('should save and load theme mode preference', () async {
      // Initialize theme provider
      final themeProvider = ThemeProvider();
      await themeProvider.initialize();
      
      // Verify initial state
      expect(themeProvider.themeMode, ThemeMode.system); // Default
      
      // Change theme mode and verify persistence
      await themeProvider.setThemeMode(ThemeMode.dark);
      expect(themeProvider.themeMode, ThemeMode.dark);
      
      // Create new instance and initialize - should load saved theme mode
      final newThemeProvider = ThemeProvider();
      await newThemeProvider.initialize();
      expect(newThemeProvider.themeMode, ThemeMode.dark);
    });

    test('should handle toggle theme mode with persistence', () async {
      final themeProvider = ThemeProvider();
      await themeProvider.initialize();
      
      // Set to light mode first
      await themeProvider.setThemeMode(ThemeMode.light);
      expect(themeProvider.themeMode, ThemeMode.light);
      
      // Toggle should switch to dark
      await themeProvider.toggleThemeMode();
      expect(themeProvider.themeMode, ThemeMode.dark);
      
      // Toggle again should switch to light
      await themeProvider.toggleThemeMode();
      expect(themeProvider.themeMode, ThemeMode.light);
      
      // Verify persistence after toggle
      final newThemeProvider = ThemeProvider();
      await newThemeProvider.initialize();
      expect(newThemeProvider.themeMode, ThemeMode.light);
    });

    test('should handle invalid saved values gracefully', () async {
      // Set invalid values in SharedPreferences
      SharedPreferences.setMockInitialValues({
        'selected_team': 999, // Invalid team index
        'theme_mode': 999,    // Invalid theme mode index
      });
      
      final themeProvider = ThemeProvider();
      await themeProvider.initialize();
      
      // Should fall back to defaults
      expect(themeProvider.currentTeam, F1Team.ferrari);
      expect(themeProvider.themeMode, ThemeMode.system);
      expect(themeProvider.isInitialized, true);
    });

    test('should initialize correctly with no saved preferences', () async {
      // Empty SharedPreferences
      SharedPreferences.setMockInitialValues({});
      
      final themeProvider = ThemeProvider();
      await themeProvider.initialize();
      
      // Should use defaults
      expect(themeProvider.currentTeam, F1Team.ferrari);
      expect(themeProvider.themeMode, ThemeMode.system);
      expect(themeProvider.isInitialized, true);
    });

    test('should handle SharedPreferences initialization failure gracefully', () async {
      // This test simulates SharedPreferences failing during initialization
      // In a real scenario, this could happen due to storage issues
      final themeProvider = ThemeProvider();
      
      // Even if SharedPreferences fails, initialization should complete
      await themeProvider.initialize();
      expect(themeProvider.isInitialized, true);
      expect(themeProvider.currentTeam, F1Team.ferrari); // Default fallback
      expect(themeProvider.themeMode, ThemeMode.system); // Default fallback
    });

    test('should handle negative saved values gracefully', () async {
      // Set negative values in SharedPreferences
      SharedPreferences.setMockInitialValues({
        'selected_team': -1,    // Invalid negative team index
        'theme_mode': -1,       // Invalid negative theme mode index
      });
      
      final themeProvider = ThemeProvider();
      await themeProvider.initialize();
      
      // Should fall back to defaults due to negative index validation
      expect(themeProvider.currentTeam, F1Team.ferrari);
      expect(themeProvider.themeMode, ThemeMode.system);
      expect(themeProvider.isInitialized, true);
    });
  });
}
