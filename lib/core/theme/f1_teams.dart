import 'package:flutter/material.dart';

enum F1Team {
  ferrari,
  mercedes,
  redBull,
  mcLaren,
  alpine,
  astonMartin,
  williams,
  alphaTauri,
  alfaRomeo,
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
      primaryColor: Color(0xFFDC143C),
      secondaryColor: Color(0xFF8B0000),
      accentColor: Color(0xFFFFD700),
      logo: 'assets/team_logo/altri/ferrari.png',
    ),
    F1Team.mercedes: F1TeamData(
      name: 'Mercedes',
      fullName: 'Mercedes-AMG Petronas',
      primaryColor: Color(0xFF00D2BE),
      secondaryColor: Color(0xFF000000),
      accentColor: Color(0xFFC0C0C0),
      logo: 'assets/team_logo/altri/mercedes.png',
    ),
    F1Team.redBull: F1TeamData(
      name: 'Red Bull',
      fullName: 'Oracle Red Bull Racing',
      primaryColor: Color(0xFF1E41FF),
      secondaryColor: Color(0xFFDC143C),
      accentColor: Color(0xFFFFD700),
      logo: 'assets/team_logo/altri/red_bull_racing.png',
    ),
    F1Team.mcLaren: F1TeamData(
      name: 'McLaren',
      fullName: 'McLaren F1 Team',
      primaryColor: Color(0xFFFF8700),
      secondaryColor: Color(0xFF47C7FC),
      accentColor: Color(0xFF000000),
      logo: 'assets/team_logo/altri/mclaren.png',
    ),
    F1Team.alpine: F1TeamData(
      name: 'Alpine',
      fullName: 'BWT Alpine F1 Team',
      primaryColor: Color(0xFF0090FF),
      secondaryColor: Color(0xFFFF87BC),
      accentColor: Color(0xFFFFFFFF),
      logo: 'assets/team_logo/altri/alpine.png',
    ),
    F1Team.astonMartin: F1TeamData(
      name: 'Aston Martin',
      fullName: 'Aston Martin Aramco',
      primaryColor: Color(0xFF006F62),
      secondaryColor: Color(0xFF00352F),
      accentColor: Color(0xFFCDDC39),
      logo: 'assets/team_logo/altri/aston_martin.png',
    ),
    F1Team.williams: F1TeamData(
      name: 'Williams',
      fullName: 'Williams Racing',
      primaryColor: Color(0xFF005AFF),
      secondaryColor: Color(0xFF00A0FF),
      accentColor: Color(0xFFFFFFFF),
      logo: 'assets/team_logo/altri/williams.png',
    ),
    F1Team.alphaTauri: F1TeamData(
      name: 'AlphaTauri',
      fullName: 'Scuderia AlphaTauri',
      primaryColor: Color(0xFF2B4562),
      secondaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFF4169E1),
      logo: 'assets/team_logo/altri/racing_bulls.png',
    ),
    F1Team.alfaRomeo: F1TeamData(
      name: 'Alfa Romeo',
      fullName: 'Alfa Romeo F1 Team ORLEN',
      primaryColor: Color(0xFF900000),
      secondaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFF000000),
      logo: 'assets/team_logo/altri/kick_sauber.png',
    ),
    F1Team.haas: F1TeamData(
      name: 'Haas',
      fullName: 'MoneyGram Haas F1 Team',
      primaryColor: Color(0xFFFFFFFF),
      secondaryColor: Color(0xFF000000),
      accentColor: Color(0xFFDC143C),
      logo: 'assets/team_logo/altri/haas.png',
    ),
  };

  static F1TeamData getTeamData(F1Team team) {
    return teams[team]!;
  }
}
