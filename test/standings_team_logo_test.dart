import 'package:flutter_test/flutter_test.dart';

// Helper function to simulate the team logo mapping from standings screen
String? getTeamLogoPath(String constructorName) {
  final lowerConstructorName = constructorName.toLowerCase().trim();
  
  // Map of constructor names to their corresponding logo asset files (using PNG format)
  final teamLogoMap = {
    'ferrari': 'assets/team_logo/altri/ferrari.png',
    'scuderia ferrari': 'assets/team_logo/altri/ferrari.png',
    
    'mercedes': 'assets/team_logo/altri/mercedes.png',
    'mercedes-amg': 'assets/team_logo/altri/mercedes.png',
    'mercedes-amg petronas': 'assets/team_logo/altri/mercedes.png',
    
    'red bull': 'assets/team_logo/altri/red_bull_racing.png',
    'red bull racing': 'assets/team_logo/altri/red_bull_racing.png',
    
    'mclaren': 'assets/team_logo/altri/mclaren.png',
    'mclaren f1 team': 'assets/team_logo/altri/mclaren.png',
    
    'alpine': 'assets/team_logo/altri/alpine.png',
    'alpine f1 team': 'assets/team_logo/altri/alpine.png',
    
    'aston martin': 'assets/team_logo/altri/aston_martin.png',
    'aston martin aramco': 'assets/team_logo/altri/aston_martin.png',
    
    'haas': 'assets/team_logo/altri/haas.png',
    'haas f1 team': 'assets/team_logo/altri/haas.png',
    
    'alphatauri': 'assets/team_logo/altri/racing_bulls.png',
    'rb': 'assets/team_logo/altri/racing_bulls.png',
    'racing bulls': 'assets/team_logo/altri/racing_bulls.png',
    'visa rb': 'assets/team_logo/altri/racing_bulls.png',
    
    'alfa romeo': 'assets/team_logo/altri/kick_sauber.png',
    'sauber': 'assets/team_logo/altri/kick_sauber.png',
    'kick sauber': 'assets/team_logo/altri/kick_sauber.png',
    'stake f1 team': 'assets/team_logo/altri/kick_sauber.png',
    
    'williams': 'assets/team_logo/altri/williams.png',
    'williams racing': 'assets/team_logo/altri/williams.png',
  };
  
  return teamLogoMap[lowerConstructorName];
}

void main() {
  group('Standings Team Logo Mapping Tests', () {
    test('Constructor names should map to correct PNG logo paths', () {
      // Test Ferrari variations
      expect(getTeamLogoPath('Ferrari'), equals('assets/team_logo/altri/ferrari.png'));
      expect(getTeamLogoPath('Scuderia Ferrari'), equals('assets/team_logo/altri/ferrari.png'));
      expect(getTeamLogoPath('FERRARI'), equals('assets/team_logo/altri/ferrari.png'));
      
      // Test Mercedes variations
      expect(getTeamLogoPath('Mercedes'), equals('assets/team_logo/altri/mercedes.png'));
      expect(getTeamLogoPath('Mercedes-AMG'), equals('assets/team_logo/altri/mercedes.png'));
      expect(getTeamLogoPath('Mercedes-AMG Petronas'), equals('assets/team_logo/altri/mercedes.png'));
      
      // Test Red Bull variations
      expect(getTeamLogoPath('Red Bull'), equals('assets/team_logo/altri/red_bull_racing.png'));
      expect(getTeamLogoPath('Red Bull Racing'), equals('assets/team_logo/altri/red_bull_racing.png'));
      
      // Test McLaren variations
      expect(getTeamLogoPath('McLaren'), equals('assets/team_logo/altri/mclaren.png'));
      expect(getTeamLogoPath('McLaren F1 Team'), equals('assets/team_logo/altri/mclaren.png'));
      
      // Test Alpine variations
      expect(getTeamLogoPath('Alpine'), equals('assets/team_logo/altri/alpine.png'));
      expect(getTeamLogoPath('Alpine F1 Team'), equals('assets/team_logo/altri/alpine.png'));
      
      // Test Aston Martin variations
      expect(getTeamLogoPath('Aston Martin'), equals('assets/team_logo/altri/aston_martin.png'));
      expect(getTeamLogoPath('Aston Martin Aramco'), equals('assets/team_logo/altri/aston_martin.png'));
      
      // Test Haas variations
      expect(getTeamLogoPath('Haas'), equals('assets/team_logo/altri/haas.png'));
      expect(getTeamLogoPath('Haas F1 Team'), equals('assets/team_logo/altri/haas.png'));
      
      // Test Racing Bulls/AlphaTauri variations
      expect(getTeamLogoPath('AlphaTauri'), equals('assets/team_logo/altri/racing_bulls.png'));
      expect(getTeamLogoPath('RB'), equals('assets/team_logo/altri/racing_bulls.png'));
      expect(getTeamLogoPath('Racing Bulls'), equals('assets/team_logo/altri/racing_bulls.png'));
      expect(getTeamLogoPath('Visa RB'), equals('assets/team_logo/altri/racing_bulls.png'));
      
      // Test Sauber variations
      expect(getTeamLogoPath('Alfa Romeo'), equals('assets/team_logo/altri/kick_sauber.png'));
      expect(getTeamLogoPath('Sauber'), equals('assets/team_logo/altri/kick_sauber.png'));
      expect(getTeamLogoPath('Kick Sauber'), equals('assets/team_logo/altri/kick_sauber.png'));
      expect(getTeamLogoPath('Stake F1 Team'), equals('assets/team_logo/altri/kick_sauber.png'));
      
      // Test Williams variations
      expect(getTeamLogoPath('Williams'), equals('assets/team_logo/altri/williams.png'));
      expect(getTeamLogoPath('Williams Racing'), equals('assets/team_logo/altri/williams.png'));
    });

    test('Unknown constructor names should return null', () {
      expect(getTeamLogoPath('Unknown Team'), isNull);
      expect(getTeamLogoPath(''), isNull);
      expect(getTeamLogoPath('NonExistent'), isNull);
    });

    test('All logo paths should use PNG format', () {
      final testCases = [
        'Ferrari', 'Mercedes', 'Red Bull', 'McLaren', 'Alpine',
        'Aston Martin', 'Haas', 'RB', 'Sauber', 'Williams'
      ];

      for (final constructorName in testCases) {
        final logoPath = getTeamLogoPath(constructorName);
        expect(logoPath, isNotNull, reason: 'Logo path should exist for $constructorName');
        expect(logoPath!.startsWith('assets/team_logo/altri/'), isTrue,
            reason: 'Logo path should start with correct asset directory');
        expect(logoPath.endsWith('.png'), isTrue,
            reason: 'Logo should be a PNG file');
      }
    });
  });
}
