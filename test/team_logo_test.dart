import 'package:flutter_test/flutter_test.dart';
import 'package:f_app/core/theme/f1_teams.dart';

void main() {
  group('Team Logo Tests', () {
    test('F1Teams should have PNG logo paths instead of emojis', () {
      for (F1Team team in F1Team.values) {
        final teamData = F1Teams.getTeamData(team);
        
        // Verify that the logo is a PNG asset path, not an emoji
        expect(teamData.logo.startsWith('assets/team_logo/altri/'), isTrue,
            reason: 'Team ${team.name} logo should be an asset path');
        expect(teamData.logo.endsWith('.png'), isTrue,
            reason: 'Team ${team.name} logo should be a PNG file');
        
        // Verify basic properties exist
        expect(teamData.name.isNotEmpty, isTrue);
        expect(teamData.fullName.isNotEmpty, isTrue);
      }
    });

    test('All teams should have valid team data', () {
      expect(F1Team.values.length, equals(10));
      
      // Test specific teams
      final ferrari = F1Teams.getTeamData(F1Team.ferrari);
      expect(ferrari.logo, equals('assets/team_logo/altri/ferrari.png'));
      expect(ferrari.name, equals('Ferrari'));
      
      final mercedes = F1Teams.getTeamData(F1Team.mercedes);
      expect(mercedes.logo, equals('assets/team_logo/altri/mercedes.png'));
      expect(mercedes.name, equals('Mercedes'));
      
      final redBull = F1Teams.getTeamData(F1Team.redBull);
      expect(redBull.logo, equals('assets/team_logo/altri/red_bull_racing.png'));
      expect(redBull.name, equals('Red Bull'));
    });
  });
}
