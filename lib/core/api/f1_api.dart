import 'dart:convert';
import 'package:http/http.dart' as http;

class F1Api {
  static const String baseUrl = 'https://api.jolpi.ca/ergast/f1';
  
  static Future<List<dynamic>> getCurrentDriverStandings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/current/driverStandings.json'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['MRData']['StandingsTable']['StandingsLists'][0]['DriverStandings'];
      } else {
        throw Exception('Failed to load driver standings');
      }
    } catch (e) {
      throw Exception('Error fetching driver standings: $e');
    }
  }
  
  static Future<List<dynamic>> getCurrentConstructorStandings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/current/constructorStandings.json'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['MRData']['StandingsTable']['StandingsLists'][0]['ConstructorStandings'];
      } else {
        throw Exception('Failed to load constructor standings');
      }
    } catch (e) {
      throw Exception('Error fetching constructor standings: $e');
    }
  }
  
  static Future<List<dynamic>> getCurrentSeasonRaces() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/current.json'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['MRData']['RaceTable']['Races'];
      } else {
        throw Exception('Failed to load races');
      }
    } catch (e) {
      throw Exception('Error fetching races: $e');
    }
  }
  
  static Future<List<dynamic>> getDrivers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/current/drivers.json'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['MRData']['DriverTable']['Drivers'];
      } else {
        throw Exception('Failed to load drivers');
      }
    } catch (e) {
      throw Exception('Error fetching drivers: $e');
    }
  }
  
  static Future<List<dynamic>> getConstructors() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/current/constructors.json'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['MRData']['ConstructorTable']['Constructors'];
      } else {
        throw Exception('Failed to load constructors');
      }
    } catch (e) {
      throw Exception('Error fetching constructors: $e');
    }
  }
  
  static Future<Map<String, dynamic>> getNextRace() async {
    try {
      final races = await getCurrentSeasonRaces();
      final now = DateTime.now();
      
      for (final race in races) {
        final raceDate = DateTime.parse('${race['date']} ${race['time']}');
        if (raceDate.isAfter(now)) {
          return race;
        }
      }
      
      return races.last; // Return last race if no upcoming race
    } catch (e) {
      throw Exception('Error fetching next race: $e');
    }
  }
}
