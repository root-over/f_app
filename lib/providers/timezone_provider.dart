import 'dart:io';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

class TimezoneProvider with ChangeNotifier {
  String _mode = 'auto'; // 'auto' or 'manual'
  String? _manualTimezone;
  tz.Location _currentLocation = tz.local;
  String? _systemTimezone;

  String get mode => _mode;
  String? get manualTimezone => _manualTimezone;
  tz.Location get currentLocation => _currentLocation;
  String? get systemTimezone => _systemTimezone;

  TimezoneProvider() {
    _detectSystemTimezone();
  }

  Future<void> _detectSystemTimezone() async {
    try {
      final result = await Process.run('readlink', ['/etc/localtime']);
      if (result.exitCode == 0) {
        final output = result.stdout.toString().trim();
        final match = RegExp(r'zoneinfo/(.*)').firstMatch(output);
        if (match != null) {
          _systemTimezone = match.group(1);
          // Fix: Europe/Rome -> Europe/Rome (no . or extra chars)
          if (_mode == 'auto' && _systemTimezone != null) {
            _currentLocation = tz.getLocation(_systemTimezone!.replaceAll('.',''));
            notifyListeners();
          }
        }
      }
    } catch (_) {}
  }

  void setMode(String mode) {
    _mode = mode;
    if (mode == 'auto') {
      if (_systemTimezone != null) {
        _currentLocation = tz.getLocation(_systemTimezone!.replaceAll('.',''));
      } else {
        _currentLocation = tz.local;
      }
    } else if (_manualTimezone != null) {
      _currentLocation = tz.getLocation(_manualTimezone!);
    }
    notifyListeners();
  }

  void setManualTimezone(String timezone) {
    _manualTimezone = timezone;
    if (_mode == 'manual') {
      _currentLocation = tz.getLocation(timezone);
      notifyListeners();
    }
  }
}
