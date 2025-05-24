import 'package:flutter_test/flutter_test.dart';
import 'package:f_app/services/live_race_service.dart';

void main() {
  group('LiveRaceService Basic Tests', () {
    test('LiveRaceService is singleton', () {
      final service1 = LiveRaceService.instance;
      final service2 = LiveRaceService.instance;
      expect(service1, same(service2));
    });

    test('Initial state is unknown', () {
      final service = LiveRaceService.instance;
      expect(service.currentStatus, LiveRaceStatus.unknown);
    });

    test('getCurrentRaceInfo returns valid info', () {
      final service = LiveRaceService.instance;
      final raceInfo = service.getCurrentRaceInfo();
      
      expect(raceInfo, isNotNull);
      expect(raceInfo.status, isA<LiveRaceStatus>());
      expect(raceInfo.statusText, isA<String>());
      expect(raceInfo.recentRaceControl, isA<List<RaceControlMessage>>());
      expect(raceInfo.isLive, isA<bool>());
    });
  });

  group('LiveRaceStatus Tests', () {
    test('All status values are defined', () {
      final allStatuses = LiveRaceStatus.values;
      
      expect(allStatuses, contains(LiveRaceStatus.racing));
      expect(allStatuses, contains(LiveRaceStatus.paused));
      expect(allStatuses, contains(LiveRaceStatus.yellowFlag));
      expect(allStatuses, contains(LiveRaceStatus.redFlag));
      expect(allStatuses, contains(LiveRaceStatus.safetyCar));
      expect(allStatuses, contains(LiveRaceStatus.virtualSafetyCar));
      expect(allStatuses, contains(LiveRaceStatus.finished));
      expect(allStatuses, contains(LiveRaceStatus.notLive));
      expect(allStatuses, contains(LiveRaceStatus.noSession));
      expect(allStatuses, contains(LiveRaceStatus.error));
      expect(allStatuses, contains(LiveRaceStatus.unknown));
    });
  });

  group('RaceControlMessage Tests', () {
    test('RaceControlMessage can be created from JSON', () {
      final json = {
        'category': 'Flag',
        'date': '2024-05-24T14:30:00.000Z',
        'driver_number': 1,
        'flag': 'YELLOW',
        'lap_number': 15,
        'message': 'Yellow flag sector 2',
        'scope': 'Sector',
        'sector': 2,
      };

      final message = RaceControlMessage.fromJson(json);

      expect(message.category, 'Flag');
      expect(message.driverNumber, 1);
      expect(message.flag, 'YELLOW');
      expect(message.lapNumber, 15);
      expect(message.message, 'Yellow flag sector 2');
      expect(message.scope, 'Sector');
      expect(message.sector, 2);
      expect(message.date, isA<DateTime>());
    });

    test('RaceControlMessage provides correct icons', () {
      // Test yellow flag
      final yellowFlag = RaceControlMessage(
        date: DateTime.now(),
        flag: 'YELLOW',
      );
      expect(yellowFlag.icon, '🟡');

      // Test red flag
      final redFlag = RaceControlMessage(
        date: DateTime.now(),
        flag: 'RED',
      );
      expect(redFlag.icon, '🔴');

      // Test safety car message
      final safetyCar = RaceControlMessage(
        date: DateTime.now(),
        message: 'Safety car deployed',
      );
      expect(safetyCar.icon, '🚗');
    });

    test('RaceControlMessage provides correct colors', () {
      // Test yellow flag color
      final yellowFlag = RaceControlMessage(
        date: DateTime.now(),
        flag: 'YELLOW',
      );
      expect(yellowFlag.color, 0xFFD69E2E);

      // Test red flag color
      final redFlag = RaceControlMessage(
        date: DateTime.now(),
        flag: 'RED',
      );
      expect(redFlag.color, 0xFFE53E3E);
    });
  });
}
