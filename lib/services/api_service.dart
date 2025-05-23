import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/driver_standing.dart';
import '../models/constructor_standing.dart';

class ApiService {
  static const String _baseUrl = 'https://api.jolpi.ca/ergast/f1'; // Updated base URL

  Future<List<DriverStanding>> getDriverStandings({int? year, String? round}) async {
    // Default to current year if not provided, or a recent year with data
    final int queryYear = year ?? DateTime.now().year;
    String url = '$_baseUrl/$queryYear/driverstandings.json'; // Ensure .json suffix

    // The 'round' parameter for standings might not be supported directly in this endpoint path.
    // The documentation suggests standings are typically by season.
    // If round-specific standings are needed, the API structure might be different or require other endpoints.
    // For now, focusing on season standings.
    // Example: /ergast/f1/2024/driverstandings.json

    // If round is truly needed and supported by this specific endpoint as a query param:
    // if (round != null) {
    //   url += '?round=$round'; // This is an assumption if API supports round as query
    // }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // The response is nested under "MRData" -> "StandingsTable" -> "StandingsLists" [0] -> "DriverStandings"
      Map<String, dynamic> decodedBody = jsonDecode(response.body);
      if (decodedBody['MRData'] != null &&
          decodedBody['MRData']['StandingsTable'] != null &&
          decodedBody['MRData']['StandingsTable']['StandingsLists'] != null &&
          (decodedBody['MRData']['StandingsTable']['StandingsLists'] as List).isNotEmpty) {
        
        List<dynamic> standingsData = decodedBody['MRData']['StandingsTable']['StandingsLists'][0]['DriverStandings'];
        List<DriverStanding> standings = standingsData.map((dynamic item) => DriverStanding.fromJson(item)).toList();
        return standings;
      } else {
        throw Exception('Failed to parse driver standings: Unexpected JSON structure. Body: ${response.body}');
      }
    } else {
      throw Exception('Failed to load driver standings. Status code: ${response.statusCode}, Body: ${response.body}');
    }
  }

  Future<List<ConstructorStanding>> getConstructorStandings({int? year, String? round}) async {
    final int queryYear = year ?? DateTime.now().year;
    String url = '$_baseUrl/$queryYear/constructorstandings.json'; // Ensure .json suffix
    
    // Similar to driver standings, round parameter might not be part of this specific path.
    // Example: /ergast/f1/2024/constructorstandings.json

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // The response is nested under "MRData" -> "StandingsTable" -> "StandingsLists" [0] -> "ConstructorStandings"
      Map<String, dynamic> decodedBody = jsonDecode(response.body);
       if (decodedBody['MRData'] != null &&
          decodedBody['MRData']['StandingsTable'] != null &&
          decodedBody['MRData']['StandingsTable']['StandingsLists'] != null &&
          (decodedBody['MRData']['StandingsTable']['StandingsLists'] as List).isNotEmpty) {

        List<dynamic> standingsData = decodedBody['MRData']['StandingsTable']['StandingsLists'][0]['ConstructorStandings'];
        List<ConstructorStanding> standings = standingsData.map((dynamic item) => ConstructorStanding.fromJson(item)).toList();
        return standings;
      } else {
        throw Exception('Failed to parse constructor standings: Unexpected JSON structure. Body: ${response.body}');
      }
    } else {
      throw Exception('Failed to load constructor standings. Status code: ${response.statusCode}, Body: ${response.body}');
    }
  }
}
