// filepath: /Users/giuseppemagliano/Documents/progetti_personali/f_app/lib/core/theme/f1_teams.dart
import 'package:flutter/material.dart';

enum F1Team {
  ferrari,
  mercedes,
  redBull,
  mcLaren,
  alpine,
  astonMartin,
  williams,
  racingBulls, 
  kickSauber, 
  haas,
}

class F1TeamData {
  final String name;
  final String fullName;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final String logo;

  const F1TeamData({
    required this.name,
    required this.fullName,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.logo,
  });
}

class F1Teams {
  static const Map<F1Team, F1TeamData> teams = {
    F1Team.ferrari: F1TeamData(
      name: 'Ferrari',
      fullName: 'Scuderia Ferrari',
      primaryColor: Color(0xFFDC143C), // Rosso Ferrari migliorato
      secondaryColor: Color(0xFF8B0000), // Rosso scuro
      accentColor: Color(0xFFFFD700),   // Oro
      logo: 'assets/team_logo/altri/ferrari.png',
    ),
    F1Team.mercedes: F1TeamData(
      name: 'Mercedes',
      fullName: 'Mercedes-AMG Petronas',
      primaryColor: Color(0xFF00D2BE),  // Turchese Mercedes
      secondaryColor: Color(0xFF1E1E1E), // Nero
      accentColor: Color(0xFFC0C0C0),   // Argento
      logo: 'assets/team_logo/altri/mercedes.png',
    ),
    F1Team.redBull: F1TeamData(
      name: 'Red Bull',
      fullName: 'Oracle Red Bull Racing',
      primaryColor: Color(0xFF0600EF),  // Blu Red Bull intenso
      secondaryColor: Color(0xFFB90000), // Rosso intenso 
      accentColor: Color(0xFFFFCC00),   // Oro più vivace
      logo: 'assets/team_logo/altri/red_bull_racing.png',
    ),
    F1Team.mcLaren: F1TeamData(
      name: 'McLaren',
      fullName: 'McLaren F1 Team',
      primaryColor: Color(0xFFFF8000),  // Papaya McLaren migliorato
      secondaryColor: Color(0xFF0090D4), // Azzurro più luminoso
      accentColor: Color(0xFF0E1011),   // Nero/grigio profondo
      logo: 'assets/team_logo/altri/mclaren.png',
    ),
    F1Team.alpine: F1TeamData(
      name: 'Alpine',
      fullName: 'BWT Alpine F1 Team',
      primaryColor: Color(0xFF0078FF),  // Blu Alpine più brillante
      secondaryColor: Color(0xFFFF6BCA), // Rosa BWT più vivace
      accentColor: Color(0xFFFFFFFF),   // Bianco
      logo: 'assets/team_logo/altri/alpine.png',
    ),
    F1Team.astonMartin: F1TeamData(
      name: 'Aston Martin',
      fullName: 'Aston Martin Aramco',
      primaryColor: Color(0xFF006F62),  // Verde British racing
      secondaryColor: Color(0xFF00352F), // Verde scuro
      accentColor: Color(0xFFDCE935),   // Lime/Giallo fluorescente
      logo: 'assets/team_logo/altri/aston_martin.png',
    ),
    F1Team.williams: F1TeamData(
      name: 'Williams',
      fullName: 'Williams Racing',
      primaryColor: Color(0xFF0053D0),  // Blu Williams più profondo
      secondaryColor: Color(0xFF00A0FF), // Azzurro
      accentColor: Color(0xFFF5F5F5),   // Bianco-grigio
      logo: 'assets/team_logo/altri/williams.png',
    ),
    F1Team.racingBulls: F1TeamData(
      name: 'Racing Bulls',
      fullName: 'Visa Cash App RB F1 Team',
      primaryColor: Color(0xFF0B2539),  // Blu navy scuro
      secondaryColor: Color(0xFFE90000), // Rosso brillante
      accentColor: Color(0xFFFFFFFF),   // Bianco
      logo: 'assets/team_logo/altri/racing_bulls.png',
    ),
    F1Team.kickSauber: F1TeamData(
      name: 'Kick Sauber',
      fullName: 'Stake F1 Team Kick Sauber',
      primaryColor: Color(0xFF00FF3C),  // Verde Kick brillante
      secondaryColor: Color(0xFF222222), // Nero/grigio scuro
      accentColor: Color(0xFFF0F0F0),   // Bianco/grigio chiaro
      logo: 'assets/team_logo/altri/kick_sauber.png',
    ),
    F1Team.haas: F1TeamData(
      name: 'Haas',
      fullName: 'MoneyGram Haas F1 Team',
      primaryColor: Color(0xFFFFFFFF),  // Bianco
      secondaryColor: Color(0xFF000000), // Nero
      accentColor: Color(0xFFE10600),   // Rosso vibrante
      logo: 'assets/team_logo/altri/haas.png',
    ),
  };

  static F1TeamData getTeamData(F1Team team) {
    return teams[team]!;
  }
}
