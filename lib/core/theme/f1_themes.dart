// filepath: /Users/giuseppemagliano/Do        unselectedLabelColor: _getContrastColor(teamData.primaryColor).withAlpha((255*0.6).round()),uments/progetti_personali/f_app/lib/core/theme/f1_themes.dart
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
      // Miglioramento AppBar con ombre e animazione
      appBarTheme: AppBarTheme(
        backgroundColor: teamData.primaryColor,
        foregroundColor: _getContrastColor(teamData.primaryColor),
        elevation: 4, // Aggiunta ombra
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 22, // Dimensione aumentata
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5, // Migliore leggibilità
          color: _getContrastColor(teamData.primaryColor),
        ),
        shadowColor: teamData.secondaryColor.withAlpha((255 * 0.5).round()),
        iconTheme: IconThemeData(
          color: _getContrastColor(teamData.primaryColor),
          size: 24, // Icone leggermente più grandi
        ),
      ),
      // Miglioramento della barra di navigazione con effetti di transizione
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: teamData.primaryColor,
        selectedItemColor: teamData.accentColor,
        unselectedItemColor: _getContrastColor(teamData.primaryColor).withAlpha((255*0.8).round()), // Miglior contrasto
        selectedIconTheme: IconThemeData(size: 28, color: teamData.accentColor),
        unselectedIconTheme: IconThemeData(size: 24),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        elevation: 8, // Ombra più pronunciata
        type: BottomNavigationBarType.fixed,
      ),
      // Miglioramento delle card con ombre e animazioni
      cardTheme: CardThemeData(
        elevation: 6, // Ombra più pronunciata
        shadowColor: teamData.primaryColor.withAlpha((255*0.3).round()),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: teamData.primaryColor.withAlpha((255 * 0.1).round()), width: 1),
        ),
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      ),
      // Miglioramento FAB con effetti animati
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: teamData.secondaryColor,
        foregroundColor: _getContrastColor(teamData.secondaryColor),
        elevation: 8,
        splashColor: teamData.accentColor.withAlpha((255 * 0.3).round()),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      // Miglioramento Chip con effetti visivi
      chipTheme: ChipThemeData(
        backgroundColor: teamData.primaryColor.withAlpha((255*0.15).round()),
        labelStyle: TextStyle(
          color: teamData.primaryColor,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide(color: teamData.primaryColor.withAlpha((255*0.3).round())), 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: teamData.primaryColor.withAlpha((255*0.2).round()),
        elevation: 2,
        selectedColor: teamData.primaryColor.withAlpha((255*0.3).round()),
        checkmarkColor: teamData.accentColor,
      ),
      // Miglioramento stile dei pulsanti
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: teamData.primaryColor,
          foregroundColor: _getContrastColor(teamData.primaryColor),
          elevation: 4,
          shadowColor: teamData.primaryColor.withAlpha((255*0.5).round()),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),
      // Miglioramento TabBar
      tabBarTheme: TabBarThemeData(
        labelColor: _getContrastColor(teamData.primaryColor),
        unselectedLabelColor: _getContrastColor(teamData.primaryColor).withAlpha((255*0.85).round()), // Miglior contrasto
        indicatorColor: teamData.accentColor,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        unselectedLabelStyle: const TextStyle(fontSize: 15),
      ),
      // Miglioramento ListTile
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        iconColor: teamData.primaryColor,
        textColor: Colors.black87,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static ThemeData getDarkTheme(F1Team team) {
    final teamData = F1Teams.getTeamData(team);
    final darkBackgroundColor = Color(0xFF121212);
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: teamData.primaryColor,
        primary: teamData.primaryColor,
        secondary: teamData.secondaryColor,
        tertiary: teamData.accentColor,
        brightness: Brightness.dark,
        surface: const Color(0xFF1E1E1E),
        surfaceTint: darkBackgroundColor, // Replacing deprecated 'background'
        onSurface: Colors.white.withAlpha((255 * 0.87).round()),
      ),
      // Miglioramento AppBar in dark mode
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1A1A1A), // Nero profondo
        foregroundColor: teamData.primaryColor,
        elevation: 4,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: teamData.primaryColor,
        ),
        shadowColor: Colors.black26,
        iconTheme: IconThemeData(
          color: teamData.primaryColor,
          size: 24,
        ),
      ),
      // Miglioramento BottomNavigationBar in dark mode
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1A1A1A),
        selectedItemColor: teamData.primaryColor,
        unselectedItemColor: Colors.grey.shade300, // Grigio più chiaro per miglior contrasto in dark mode
        selectedIconTheme: IconThemeData(size: 28, color: teamData.primaryColor),
        unselectedIconTheme: const IconThemeData(size: 24),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      // Miglioramento Card in dark mode
      cardTheme: CardThemeData(
        elevation: 6,
        shadowColor: Colors.black45,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: teamData.primaryColor.withAlpha((255 * 0.2).round()), width: 1),
        ),
        color: const Color(0xFF2D2D2D),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      ),
      // Miglioramento FAB in dark mode
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: teamData.primaryColor,
        foregroundColor: _getContrastColor(teamData.primaryColor),
        elevation: 8,
        splashColor: teamData.accentColor.withAlpha((255 * 0.3).round()),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      // Miglioramento Chip in dark mode
      chipTheme: ChipThemeData(
        backgroundColor: teamData.primaryColor.withAlpha((255 * 0.2).round()),
        labelStyle: TextStyle(
          color: teamData.primaryColor,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide(color: teamData.primaryColor.withAlpha((255 * 0.4).round())),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: Colors.black38,
        elevation: 3,
        selectedColor: teamData.primaryColor.withAlpha((255 * 0.4).round()),
        checkmarkColor: teamData.accentColor,
      ),
      // Miglioramento stile dei pulsanti in dark mode
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: teamData.primaryColor,
          foregroundColor: _getContrastColor(teamData.primaryColor),
          elevation: 4,
          shadowColor: Colors.black45,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),
      // Miglioramento TabBar in dark mode
      tabBarTheme: TabBarThemeData(
        labelColor: teamData.primaryColor,
        unselectedLabelColor: Colors.grey.shade200, // Grigio più chiaro per contrasto migliore
        indicatorColor: teamData.primaryColor,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        unselectedLabelStyle: const TextStyle(fontSize: 15),
      ),
      // Miglioramento ListTile in dark mode
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        iconColor: teamData.primaryColor,
        textColor: Colors.white.withAlpha((255 * 0.87).round()),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      // Miglioramento delle icone in dark mode
      iconTheme: IconThemeData(
        color: teamData.primaryColor,
        size: 24,
      ),
    );
  }

  static Color _getContrastColor(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}
