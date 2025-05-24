import 'dart:convert';
import 'package:http/http.dart' as http;

/// Comprehensive Jolpica F1 API Client
/// 
/// This client provides access to all available Jolpica F1 API endpoints.
/// The Jolpica F1 API is the successor to the Ergast API and provides backwards
/// compatible endpoints with enhanced data and performance.
/// 
/// API Documentation: https://jolpi.ca/docs/
/// Base URL: https://api.jolpi.ca/ergast/f1/
/// 
/// All endpoints support JSON format and include pagination via limit/offset parameters.
/// Rate limits apply - see API documentation for current limits.
/// 
/// OPENF1 API INTEGRATION:
/// This client also provides comprehensive access to the OpenF1 API, which offers
/// real-time and historical Formula 1 data including:
/// - Live telemetry data (~3.7Hz sample rate)
/// - Driver radio communications
/// - Real-time timing and gaps
/// - 3D car positions on track
/// - Race control messages and flags
/// - Pit lane timing data
/// 
/// OpenF1 API Documentation: https://openf1.org/
/// OpenF1 Base URL: https://api.openf1.org/v1/
class F1Api {
  /// Base URL for the Jolpica F1 API (Ergast-compatible endpoints)
  static const String baseUrl = 'https://api.jolpi.ca/ergast/f1';
  
  /// New F1 API base URL for enhanced endpoints
  static const String newApiBaseUrl = 'https://api.jolpi.ca/f1/alpha';
  
  /// OpenF1 API base URL for real-time and live data
  static const String openF1BaseUrl = 'https://api.openf1.org/v1';
  
  // =============================================================================
  // DRIVER STANDINGS ENDPOINTS
  // =============================================================================
  
  /// Get current season driver standings
  /// 
  /// Endpoint: GET /current/driverstandings.json
  /// Returns: List of driver standings for the current season
  /// 
  /// Example:
  /// ```dart
  /// final standings = await F1Api.getCurrentDriverStandings();
  /// ```
  static Future<List<dynamic>> getCurrentDriverStandings() async {
    return _getDriverStandings('current');
  }
  
  /// Get driver standings for a specific season
  /// 
  /// Endpoint: GET /{season}/driverstandings.json
  /// 
  /// Parameters:
  /// - [season]: Year (e.g., 2024) or 'current'
  /// - [round]: Optional round number, 'last', or 'next'
  /// - [limit]: Maximum results (default: 30, max: 100)
  /// - [offset]: Pagination offset (default: 0)
  /// 
  /// Example:
  /// ```dart
  /// final standings = await F1Api.getDriverStandings(2024);
  /// final standingsAfterRound10 = await F1Api.getDriverStandings(2024, round: 10);
  /// ```
  static Future<List<dynamic>> getDriverStandings(
    dynamic season, {
    dynamic round,
    int? limit,
    int? offset,
  }) async {
    return _getDriverStandings(season, round: round, limit: limit, offset: offset);
  }
  
  /// Get driver standings filtered by driver
  /// 
  /// Endpoint: GET /drivers/{driverId}/driverstandings.json
  /// 
  /// Parameters:
  /// - [driverId]: Driver reference (e.g., 'hamilton', 'verstappen')
  /// - [season]: Optional season filter
  /// 
  /// Example:
  /// ```dart
  /// final hamiltonStandings = await F1Api.getDriverStandingsByDriver('hamilton');
  /// ```
  static Future<List<dynamic>> getDriverStandingsByDriver(
    String driverId, {
    dynamic season,
    int? limit,
    int? offset,
  }) async {
    final seasonParam = season != null ? '$season/' : '';
    return _makeRequest('${seasonParam}drivers/$driverId/driverstandings.json', 
      limit: limit, offset: offset)
      .then((data) => data['MRData']['StandingsTable']['StandingsLists'][0]['DriverStandings']);
  }
  
  // =============================================================================
  // CONSTRUCTOR STANDINGS ENDPOINTS
  // =============================================================================
  
  /// Get current season constructor standings
  /// 
  /// Endpoint: GET /current/constructorstandings.json
  /// 
  /// Example:
  /// ```dart
  /// final standings = await F1Api.getCurrentConstructorStandings();
  /// ```
  static Future<List<dynamic>> getCurrentConstructorStandings() async {
    return _getConstructorStandings('current');
  }
  
  /// Get constructor standings for a specific season
  /// 
  /// Endpoint: GET /{season}/constructorstandings.json
  /// 
  /// Parameters:
  /// - [season]: Year (e.g., 2024) or 'current'
  /// - [round]: Optional round number, 'last', or 'next'
  /// - [limit]: Maximum results (default: 30, max: 100)
  /// - [offset]: Pagination offset (default: 0)
  /// 
  /// Example:
  /// ```dart
  /// final standings = await F1Api.getConstructorStandings(2024);
  /// ```
  static Future<List<dynamic>> getConstructorStandings(
    dynamic season, {
    dynamic round,
    int? limit,
    int? offset,
  }) async {
    return _getConstructorStandings(season, round: round, limit: limit, offset: offset);
  }
  
  /// Get constructor standings filtered by constructor
  /// 
  /// Endpoint: GET /constructors/{constructorId}/constructorstandings.json
  /// 
  /// Parameters:
  /// - [constructorId]: Constructor reference (e.g., 'mercedes', 'red_bull')
  /// - [season]: Optional season filter
  /// 
  /// Example:
  /// ```dart
  /// final mercedesStandings = await F1Api.getConstructorStandingsByConstructor('mercedes');
  /// ```
  static Future<List<dynamic>> getConstructorStandingsByConstructor(
    String constructorId, {
    dynamic season,
    int? limit,
    int? offset,
  }) async {
    final seasonParam = season != null ? '$season/' : '';
    return _makeRequest('${seasonParam}constructors/$constructorId/constructorstandings.json',
      limit: limit, offset: offset)
      .then((data) => data['MRData']['StandingsTable']['StandingsLists'][0]['ConstructorStandings']);
  }
  
  // =============================================================================
  // RACE SCHEDULE ENDPOINTS
  // =============================================================================
  
  /// Get current season race schedule
  /// 
  /// Endpoint: GET /current.json
  /// 
  /// Example:
  /// ```dart
  /// final races = await F1Api.getCurrentSeasonRaces();
  /// ```
  static Future<List<dynamic>> getCurrentSeasonRaces() async {
    return getRaces('current');
  }
  
  /// Get races for a specific season or all seasons
  /// 
  /// Endpoint: GET /races.json or GET /{season}/races.json
  /// 
  /// Parameters:
  /// - [season]: Optional year (e.g., 2024) or 'current'. If null, returns all seasons
  /// - [round]: Optional round number, 'last', or 'next'
  /// - [limit]: Maximum results (default: 30, max: 100)
  /// - [offset]: Pagination offset (default: 0)
  /// 
  /// Example:
  /// ```dart
  /// final allRaces = await F1Api.getRaces(); // All seasons
  /// final races2024 = await F1Api.getRaces('2024');
  /// final lastRace = await F1Api.getRaces('current', round: 'last');
  /// ```
  static Future<List<dynamic>> getRaces([
    dynamic season,
    dynamic round,
    int? limit,
    int? offset,
  ]) async {
    String endpoint = 'races.json';
    if (season != null) {
      endpoint = round != null ? '$season/$round/races.json' : '$season/races.json';
    }
    return _makeRequest(endpoint, limit: limit, offset: offset)
      .then((data) => data['MRData']['RaceTable']['Races']);
  }
  
  /// Get races filtered by circuit
  /// 
  /// Endpoint: GET /circuits/{circuitId}/races.json
  /// 
  /// Parameters:
  /// - [circuitId]: Circuit reference (e.g., 'monza', 'silverstone')
  /// - [season]: Optional season filter
  /// 
  /// Example:
  /// ```dart
  /// final monzaRaces = await F1Api.getRacesByCircuit('monza');
  /// ```
  static Future<List<dynamic>> getRacesByCircuit(
    String circuitId, {
    dynamic season,
    int? limit,
    int? offset,
  }) async {
    final seasonParam = season != null ? '$season/' : '';
    return _makeRequest('${seasonParam}circuits/$circuitId/races.json',
      limit: limit, offset: offset)
      .then((data) => data['MRData']['RaceTable']['Races']);
  }
  
  /// Get races filtered by constructor
  /// 
  /// Endpoint: GET /constructors/{constructorId}/races.json
  /// 
  /// Parameters:
  /// - [constructorId]: Constructor reference (e.g., 'ferrari', 'mclaren')
  /// - [season]: Optional season filter
  /// 
  /// Example:
  /// ```dart
  /// final ferrariRaces = await F1Api.getRacesByConstructor('ferrari');
  /// ```
  static Future<List<dynamic>> getRacesByConstructor(
    String constructorId, {
    dynamic season,
    int? limit,
    int? offset,
  }) async {
    final seasonParam = season != null ? '$season/' : '';
    return _makeRequest('${seasonParam}constructors/$constructorId/races.json',
      limit: limit, offset: offset)
      .then((data) => data['MRData']['RaceTable']['Races']);
  }
  
  /// Get races filtered by driver
  /// 
  /// Endpoint: GET /drivers/{driverId}/races.json
  /// 
  /// Parameters:
  /// - [driverId]: Driver reference (e.g., 'hamilton', 'leclerc')
  /// - [season]: Optional season filter
  /// 
  /// Example:
  /// ```dart
  /// final hamiltonRaces = await F1Api.getRacesByDriver('hamilton');
  /// ```
  static Future<List<dynamic>> getRacesByDriver(
    String driverId, {
    dynamic season,
    int? limit,
    int? offset,
  }) async {
    final seasonParam = season != null ? '$season/' : '';
    return _makeRequest('${seasonParam}drivers/$driverId/races.json',
      limit: limit, offset: offset)
      .then((data) => data['MRData']['RaceTable']['Races']);
  }
  
  // =============================================================================
  // DRIVER ENDPOINTS
  // =============================================================================
  
  /// Get all drivers or drivers for current season
  /// 
  /// Endpoint: GET /drivers.json or GET /current/drivers.json
  /// 
  /// Parameters:
  /// - [season]: Optional season filter ('current', year, or null for all)
  /// - [limit]: Maximum results (default: 30, max: 100)
  /// - [offset]: Pagination offset (default: 0)
  /// 
  /// Example:
  /// ```dart
  /// final allDrivers = await F1Api.getDrivers();
  /// final currentDrivers = await F1Api.getDrivers('current');
  /// ```
  static Future<List<dynamic>> getDrivers([
    dynamic season,
    int? limit,
    int? offset,
  ]) async {
    final endpoint = season != null ? '$season/drivers.json' : 'drivers.json';
    return _makeRequest(endpoint, limit: limit, offset: offset)
      .then((data) => data['MRData']['DriverTable']['Drivers']);
  }
  
  /// Get specific driver information
  /// 
  /// Endpoint: GET /drivers/{driverId}.json
  /// 
  /// Parameters:
  /// - [driverId]: Driver reference (e.g., 'hamilton', 'verstappen')
  /// 
  /// Example:
  /// ```dart
  /// final hamilton = await F1Api.getDriver('hamilton');
  /// ```
  static Future<Map<String, dynamic>> getDriver(String driverId) async {
    return _makeRequest('drivers/$driverId.json')
      .then((data) => data['MRData']['DriverTable']['Drivers'][0]);
  }
  
  /// Get drivers filtered by constructor
  /// 
  /// Endpoint: GET /constructors/{constructorId}/drivers.json
  /// 
  /// Parameters:
  /// - [constructorId]: Constructor reference (e.g., 'mercedes', 'ferrari')
  /// - [season]: Optional season filter
  /// 
  /// Example:
  /// ```dart
  /// final mercedesDrivers = await F1Api.getDriversByConstructor('mercedes');
  /// ```
  static Future<List<dynamic>> getDriversByConstructor(
    String constructorId, {
    dynamic season,
    int? limit,
    int? offset,
  }) async {
    final seasonParam = season != null ? '$season/' : '';
    return _makeRequest('${seasonParam}constructors/$constructorId/drivers.json',
      limit: limit, offset: offset)
      .then((data) => data['MRData']['DriverTable']['Drivers']);
  }
  
  /// Get drivers filtered by circuit
  /// 
  /// Endpoint: GET /circuits/{circuitId}/drivers.json
  /// 
  /// Parameters:
  /// - [circuitId]: Circuit reference (e.g., 'monaco', 'spa')
  /// - [season]: Optional season filter
  /// 
  /// Example:
  /// ```dart
  /// final monacoDrivers = await F1Api.getDriversByCircuit('monaco');
  /// ```
  static Future<List<dynamic>> getDriversByCircuit(
    String circuitId, {
    dynamic season,
    int? limit,
    int? offset,
  }) async {
    final seasonParam = season != null ? '$season/' : '';
    return _makeRequest('${seasonParam}circuits/$circuitId/drivers.json',
      limit: limit, offset: offset)
      .then((data) => data['MRData']['DriverTable']['Drivers']);
  }
  
  // =============================================================================
  // CONSTRUCTOR ENDPOINTS
  // =============================================================================
  
  /// Get all constructors or constructors for current season
  /// 
  /// Endpoint: GET /constructors.json or GET /current/constructors.json
  /// 
  /// Parameters:
  /// - [season]: Optional season filter ('current', year, or null for all)
  /// - [limit]: Maximum results (default: 30, max: 100)
  /// - [offset]: Pagination offset (default: 0)
  /// 
  /// Example:
  /// ```dart
  /// final allConstructors = await F1Api.getConstructors();
  /// final currentConstructors = await F1Api.getConstructors('current');
  /// ```
  static Future<List<dynamic>> getConstructors([
    dynamic season,
    int? limit,
    int? offset,
  ]) async {
    final endpoint = season != null ? '$season/constructors.json' : 'constructors.json';
    return _makeRequest(endpoint, limit: limit, offset: offset)
      .then((data) => data['MRData']['ConstructorTable']['Constructors']);
  }
  
  /// Get specific constructor information
  /// 
  /// Endpoint: GET /constructors/{constructorId}.json
  /// 
  /// Parameters:
  /// - [constructorId]: Constructor reference (e.g., 'mercedes', 'ferrari')
  /// 
  /// Example:
  /// ```dart
  /// final mercedes = await F1Api.getConstructor('mercedes');
  /// ```
  static Future<Map<String, dynamic>> getConstructor(String constructorId) async {
    return _makeRequest('constructors/$constructorId.json')
      .then((data) => data['MRData']['ConstructorTable']['Constructors'][0]);
  }
  
  /// Get constructors filtered by driver
  /// 
  /// Endpoint: GET /drivers/{driverId}/constructors.json
  /// 
  /// Parameters:
  /// - [driverId]: Driver reference (e.g., 'hamilton', 'alonso')
  /// - [season]: Optional season filter
  /// 
  /// Example:
  /// ```dart
  /// final hamiltonTeams = await F1Api.getConstructorsByDriver('hamilton');
  /// ```
  static Future<List<dynamic>> getConstructorsByDriver(
    String driverId, {
    dynamic season,
    int? limit,
    int? offset,
  }) async {
    final seasonParam = season != null ? '$season/' : '';
    return _makeRequest('${seasonParam}drivers/$driverId/constructors.json',
      limit: limit, offset: offset)
      .then((data) => data['MRData']['ConstructorTable']['Constructors']);
  }
  
  // =============================================================================
  // CIRCUIT ENDPOINTS
  // =============================================================================
  
  /// Get all circuits
  /// 
  /// Endpoint: GET /circuits.json
  /// 
  /// Parameters:
  /// - [season]: Optional season filter
  /// - [limit]: Maximum results (default: 30, max: 100)
  /// - [offset]: Pagination offset (default: 0)
  /// 
  /// Example:
  /// ```dart
  /// final allCircuits = await F1Api.getCircuits();
  /// final circuits2024 = await F1Api.getCircuits(season: 2024);
  /// ```
  static Future<List<dynamic>> getCircuits({
    dynamic season,
    int? limit,
    int? offset,
  }) async {
    final endpoint = season != null ? '$season/circuits.json' : 'circuits.json';
    return _makeRequest(endpoint, limit: limit, offset: offset)
      .then((data) => data['MRData']['CircuitTable']['Circuits']);
  }
  
  /// Get specific circuit information
  /// 
  /// Endpoint: GET /circuits/{circuitId}.json
  /// 
  /// Parameters:
  /// - [circuitId]: Circuit reference (e.g., 'silverstone', 'monza')
  /// 
  /// Example:
  /// ```dart
  /// final silverstone = await F1Api.getCircuit('silverstone');
  /// ```
  static Future<Map<String, dynamic>> getCircuit(String circuitId) async {
    return _makeRequest('circuits/$circuitId.json')
      .then((data) => data['MRData']['CircuitTable']['Circuits'][0]);
  }
  
  // =============================================================================
  // RACE RESULTS ENDPOINTS
  // =============================================================================
  
  /// Get race results
  /// 
  /// Endpoint: GET /results.json or GET /{season}/results.json or GET /{season}/{round}/results.json
  /// 
  /// Parameters:
  /// - [season]: Optional season filter ('current', year, or null for all)
  /// - [round]: Optional round number, 'last', or 'next'
  /// - [limit]: Maximum results (default: 30, max: 100)
  /// - [offset]: Pagination offset (default: 0)
  /// 
  /// Example:
  /// ```dart
  /// final allResults = await F1Api.getResults();
  /// final currentResults = await F1Api.getResults(season: 'current');
  /// final lastRaceResults = await F1Api.getResults(season: 'current', round: 'last');
  /// ```
  static Future<List<dynamic>> getResults({
    dynamic season,
    dynamic round,
    int? limit,
    int? offset,
  }) async {
    String endpoint = 'results.json';
    if (season != null) {
      endpoint = round != null ? '$season/$round/results.json' : '$season/results.json';
    }
    return _makeRequest(endpoint, limit: limit, offset: offset)
      .then((data) => data['MRData']['RaceTable']['Races']);
  }
  
  /// Get race results filtered by driver
  /// 
  /// Endpoint: GET /drivers/{driverId}/results.json
  /// 
  /// Parameters:
  /// - [driverId]: Driver reference (e.g., 'hamilton', 'verstappen')
  /// - [season]: Optional season filter
  /// - [round]: Optional round filter
  /// 
  /// Example:
  /// ```dart
  /// final hamiltonResults = await F1Api.getResultsByDriver('hamilton');
  /// ```
  static Future<List<dynamic>> getResultsByDriver(
    String driverId, {
    dynamic season,
    dynamic round,
    int? limit,
    int? offset,
  }) async {
    String endpoint = 'drivers/$driverId/results.json';
    if (season != null) {
      endpoint = round != null ? '$season/$round/drivers/$driverId/results.json' 
                               : '$season/drivers/$driverId/results.json';
    }
    return _makeRequest(endpoint, limit: limit, offset: offset)
      .then((data) => data['MRData']['RaceTable']['Races']);
  }
  
  /// Get race results filtered by constructor
  /// 
  /// Endpoint: GET /constructors/{constructorId}/results.json
  /// 
  /// Parameters:
  /// - [constructorId]: Constructor reference (e.g., 'mercedes', 'ferrari')
  /// - [season]: Optional season filter
  /// - [round]: Optional round filter
  /// 
  /// Example:
  /// ```dart
  /// final mercedesResults = await F1Api.getResultsByConstructor('mercedes');
  /// ```
  static Future<List<dynamic>> getResultsByConstructor(
    String constructorId, {
    dynamic season,
    dynamic round,
    int? limit,
    int? offset,
  }) async {
    String endpoint = 'constructors/$constructorId/results.json';
    if (season != null) {
      endpoint = round != null ? '$season/$round/constructors/$constructorId/results.json'
                               : '$season/constructors/$constructorId/results.json';
    }
    return _makeRequest(endpoint, limit: limit, offset: offset)
      .then((data) => data['MRData']['RaceTable']['Races']);
  }
  
  /// Get race results filtered by finishing position
  /// 
  /// Endpoint: GET /results/{position}.json
  /// 
  /// Parameters:
  /// - [position]: Finishing position (1-20+)
  /// - [season]: Optional season filter
  /// 
  /// Example:
  /// ```dart
  /// final winners = await F1Api.getResultsByPosition(1); // All race winners
  /// ```
  static Future<List<dynamic>> getResultsByPosition(
    int position, {
    dynamic season,
    int? limit,
    int? offset,
  }) async {
    final seasonParam = season != null ? '$season/' : '';
    return _makeRequest('${seasonParam}results/$position.json',
      limit: limit, offset: offset)
      .then((data) => data['MRData']['RaceTable']['Races']);
  }
  
  /// Get race results filtered by grid position
  /// 
  /// Endpoint: GET /grid/{position}/results.json
  /// 
  /// Parameters:
  /// - [position]: Grid position (1-20+)
  /// - [season]: Optional season filter
  /// 
  /// Example:
  /// ```dart
  /// final poleWinners = await F1Api.getResultsByGridPosition(1);
  /// ```
  static Future<List<dynamic>> getResultsByGridPosition(
    int position, {
    dynamic season,
    int? limit,
    int? offset,
  }) async {
    final seasonParam = season != null ? '$season/' : '';
    return _makeRequest('${seasonParam}grid/$position/results.json',
      limit: limit, offset: offset)
      .then((data) => data['MRData']['RaceTable']['Races']);
  }
  
  /// Get race results filtered by fastest lap rank
  /// 
  /// Endpoint: GET /fastest/{rank}/results.json
  /// 
  /// Parameters:
  /// - [rank]: Fastest lap rank (1 for fastest lap)
  /// - [season]: Optional season filter
  /// 
  /// Example:
  /// ```dart
  /// final fastestLaps = await F1Api.getResultsByFastestLap(1);
  /// ```
  static Future<List<dynamic>> getResultsByFastestLap(
    int rank, {
    dynamic season,
    int? limit,
    int? offset,
  }) async {
    final seasonParam = season != null ? '$season/' : '';
    return _makeRequest('${seasonParam}fastest/$rank/results.json',
      limit: limit, offset: offset)
      .then((data) => data['MRData']['RaceTable']['Races']);
  }
  
  /// Get race results filtered by status
  /// 
  /// Endpoint: GET /status/{statusId}/results.json
  /// 
  /// Parameters:
  /// - [statusId]: Status ID (1 = Finished, 2 = Disqualified, etc.)
  /// - [season]: Optional season filter
  /// 
  /// Example:
  /// ```dart
  /// final finishedResults = await F1Api.getResultsByStatus(1);
  /// ```
  static Future<List<dynamic>> getResultsByStatus(
    int statusId, {
    dynamic season,
    int? limit,
    int? offset,
  }) async {
    final seasonParam = season != null ? '$season/' : '';
    return _makeRequest('${seasonParam}status/$statusId/results.json',
      limit: limit, offset: offset)
      .then((data) => data['MRData']['RaceTable']['Races']);
  }
  
  // =============================================================================
  // QUALIFYING RESULTS ENDPOINTS
  // =============================================================================
  
  /// Get qualifying results
  /// 
  /// Endpoint: GET /qualifying.json or GET /{season}/qualifying.json or GET /{season}/{round}/qualifying.json
  /// 
  /// Parameters:
  /// - [season]: Optional season filter ('current', year, or null for all)
  /// - [round]: Optional round number, 'last', or 'next'
  /// - [limit]: Maximum results (default: 30, max: 100)
  /// - [offset]: Pagination offset (default: 0)
  /// 
  /// Example:
  /// ```dart
  /// final allQualifying = await F1Api.getQualifying();
  /// final currentQualifying = await F1Api.getQualifying(season: 'current');
  /// ```
  static Future<List<dynamic>> getQualifying({
    dynamic season,
    dynamic round,
    int? limit,
    int? offset,
  }) async {
    String endpoint = 'qualifying.json';
    if (season != null) {
      endpoint = round != null ? '$season/$round/qualifying.json' : '$season/qualifying.json';
    }
    return _makeRequest(endpoint, limit: limit, offset: offset)
      .then((data) => data['MRData']['RaceTable']['Races']);
  }
  
  /// Get qualifying results filtered by driver
  /// 
  /// Endpoint: GET /drivers/{driverId}/qualifying.json
  /// 
  /// Parameters:
  /// - [driverId]: Driver reference (e.g., 'hamilton', 'verstappen')
  /// - [season]: Optional season filter
  /// 
  /// Example:
  /// ```dart
  /// final hamiltonQualifying = await F1Api.getQualifyingByDriver('hamilton');
  /// ```
  static Future<List<dynamic>> getQualifyingByDriver(
    String driverId, {
    dynamic season,
    dynamic round,
    int? limit,
    int? offset,
  }) async {
    String endpoint = 'drivers/$driverId/qualifying.json';
    if (season != null) {
      endpoint = round != null ? '$season/$round/drivers/$driverId/qualifying.json'
                               : '$season/drivers/$driverId/qualifying.json';
    }
    return _makeRequest(endpoint, limit: limit, offset: offset)
      .then((data) => data['MRData']['RaceTable']['Races']);
  }
  
  /// Get qualifying results filtered by qualifying position
  /// 
  /// Endpoint: GET /qualifying/{position}.json
  /// 
  /// Parameters:
  /// - [position]: Qualifying position (1-20+)
  /// - [season]: Optional season filter
  /// 
  /// Example:
  /// ```dart
  /// final poleSitters = await F1Api.getQualifyingByPosition(1);
  /// ```
  static Future<List<dynamic>> getQualifyingByPosition(
    int position, {
    dynamic season,
    int? limit,
    int? offset,
  }) async {
    final seasonParam = season != null ? '$season/' : '';
    return _makeRequest('${seasonParam}qualifying/$position.json',
      limit: limit, offset: offset)
      .then((data) => data['MRData']['RaceTable']['Races']);
  }
  
  // =============================================================================
  // SPRINT RESULTS ENDPOINTS
  // =============================================================================
  
  /// Get sprint results
  /// 
  /// Endpoint: GET /sprint.json or GET /{season}/sprint.json or GET /{season}/{round}/sprint.json
  /// 
  /// Parameters:
  /// - [season]: Optional season filter ('current', year, or null for all)
  /// - [round]: Optional round number, 'last', or 'next'
  /// - [limit]: Maximum results (default: 30, max: 100)
  /// - [offset]: Pagination offset (default: 0)
  /// 
  /// Example:
  /// ```dart
  /// final allSprints = await F1Api.getSprint();
  /// final currentSprints = await F1Api.getSprint(season: 'current');
  /// ```
  static Future<List<dynamic>> getSprint({
    dynamic season,
    dynamic round,
    int? limit,
    int? offset,
  }) async {
    String endpoint = 'sprint.json';
    if (season != null) {
      endpoint = round != null ? '$season/$round/sprint.json' : '$season/sprint.json';
    }
    return _makeRequest(endpoint, limit: limit, offset: offset)
      .then((data) => data['MRData']['RaceTable']['Races']);
  }
  
  /// Get sprint results filtered by driver
  /// 
  /// Endpoint: GET /drivers/{driverId}/sprint.json
  /// 
  /// Parameters:
  /// - [driverId]: Driver reference (e.g., 'hamilton', 'verstappen')
  /// - [season]: Optional season filter
  /// 
  /// Example:
  /// ```dart
  /// final hamiltonSprints = await F1Api.getSprintByDriver('hamilton');
  /// ```
  static Future<List<dynamic>> getSprintByDriver(
    String driverId, {
    dynamic season,
    dynamic round,
    int? limit,
    int? offset,
  }) async {
    String endpoint = 'drivers/$driverId/sprint.json';
    if (season != null) {
      endpoint = round != null ? '$season/$round/drivers/$driverId/sprint.json'
                               : '$season/drivers/$driverId/sprint.json';
    }
    return _makeRequest(endpoint, limit: limit, offset: offset)
      .then((data) => data['MRData']['RaceTable']['Races']);
  }
  
  /// Get sprint results filtered by position
  /// 
  /// Endpoint: GET /sprint/{position}.json
  /// 
  /// Parameters:
  /// - [position]: Sprint finishing position (1-20+)
  /// - [season]: Optional season filter
  /// 
  /// Example:
  /// ```dart
  /// final sprintWinners = await F1Api.getSprintByPosition(1);
  /// ```
  static Future<List<dynamic>> getSprintByPosition(
    int position, {
    dynamic season,
    int? limit,
    int? offset,
  }) async {
    final seasonParam = season != null ? '$season/' : '';
    return _makeRequest('${seasonParam}sprint/$position.json',
      limit: limit, offset: offset)
      .then((data) => data['MRData']['RaceTable']['Races']);
  }
  
  // =============================================================================
  // LAP TIMES ENDPOINTS
  // =============================================================================
  
  /// Get lap times for a specific race
  /// 
  /// Endpoint: GET /{season}/{round}/laps.json or GET /{season}/{round}/laps/{lap}.json
  /// 
  /// Note: Season and round are required parameters for lap data
  /// 
  /// Parameters:
  /// - [season]: Season year or 'current'
  /// - [round]: Round number, 'last', or 'next'
  /// - [lap]: Optional specific lap number
  /// - [limit]: Maximum results (default: 30, max: 100)
  /// - [offset]: Pagination offset (default: 0)
  /// 
  /// Example:
  /// ```dart
  /// final allLaps = await F1Api.getLaps('current', 'last');
  /// final lap1 = await F1Api.getLaps('current', 'last', lap: 1);
  /// ```
  static Future<List<dynamic>> getLaps(
    dynamic season,
    dynamic round, {
    int? lap,
    int? limit,
    int? offset,
  }) async {
    final endpoint = lap != null ? '$season/$round/laps/$lap.json' : '$season/$round/laps.json';
    return _makeRequest(endpoint, limit: limit, offset: offset)
      .then((data) => data['MRData']['RaceTable']['Races'][0]['Laps']);
  }
  
  /// Get lap times filtered by driver
  /// 
  /// Endpoint: GET /{season}/{round}/drivers/{driverId}/laps.json
  /// 
  /// Parameters:
  /// - [season]: Season year or 'current'
  /// - [round]: Round number, 'last', or 'next'
  /// - [driverId]: Driver reference (e.g., 'hamilton')
  /// 
  /// Example:
  /// ```dart
  /// final hamiltonLaps = await F1Api.getLapsByDriver('current', 'last', 'hamilton');
  /// ```
  static Future<List<dynamic>> getLapsByDriver(
    dynamic season,
    dynamic round,
    String driverId, {
    int? limit,
    int? offset,
  }) async {
    return _makeRequest('$season/$round/drivers/$driverId/laps.json',
      limit: limit, offset: offset)
      .then((data) => data['MRData']['RaceTable']['Races'][0]['Laps']);
  }
  
  // =============================================================================
  // PIT STOPS ENDPOINTS
  // =============================================================================
  
  /// Get pit stops for a specific race
  /// 
  /// Endpoint: GET /{season}/{round}/pitstops.json or GET /{season}/{round}/pitstops/{stop}.json
  /// 
  /// Note: Season and round are required parameters for pit stop data
  /// 
  /// Parameters:
  /// - [season]: Season year or 'current'
  /// - [round]: Round number, 'last', or 'next'
  /// - [stop]: Optional specific pit stop number
  /// - [limit]: Maximum results (default: 30, max: 100)
  /// - [offset]: Pagination offset (default: 0)
  /// 
  /// Example:
  /// ```dart
  /// final allPitStops = await F1Api.getPitStops('current', 'last');
  /// final firstStops = await F1Api.getPitStops('current', 'last', stop: 1);
  /// ```
  static Future<List<dynamic>> getPitStops(
    dynamic season,
    dynamic round, {
    int? stop,
    int? limit,
    int? offset,
  }) async {
    final endpoint = stop != null ? '$season/$round/pitstops/$stop.json' : '$season/$round/pitstops.json';
    return _makeRequest(endpoint, limit: limit, offset: offset)
      .then((data) => data['MRData']['RaceTable']['Races'][0]['PitStops']);
  }
  
  /// Get pit stops filtered by driver
  /// 
  /// Endpoint: GET /{season}/{round}/drivers/{driverId}/pitstops.json
  /// 
  /// Parameters:
  /// - [season]: Season year or 'current'
  /// - [round]: Round number, 'last', or 'next'
  /// - [driverId]: Driver reference (e.g., 'hamilton')
  /// 
  /// Example:
  /// ```dart
  /// final hamiltonPitStops = await F1Api.getPitStopsByDriver('current', 'last', 'hamilton');
  /// ```
  static Future<List<dynamic>> getPitStopsByDriver(
    dynamic season,
    dynamic round,
    String driverId, {
    int? limit,
    int? offset,
  }) async {
    return _makeRequest('$season/$round/drivers/$driverId/pitstops.json',
      limit: limit, offset: offset)
      .then((data) => data['MRData']['RaceTable']['Races'][0]['PitStops']);
  }
  
  // =============================================================================
  // STATUS ENDPOINTS
  // =============================================================================
  
  /// Get all finishing statuses
  /// 
  /// Endpoint: GET /status.json
  /// 
  /// Parameters:
  /// - [season]: Optional season filter
  /// - [round]: Optional round filter
  /// - [limit]: Maximum results (default: 30, max: 100)
  /// - [offset]: Pagination offset (default: 0)
  /// 
  /// Example:
  /// ```dart
  /// final allStatuses = await F1Api.getStatus();
  /// final currentStatuses = await F1Api.getStatus(season: 'current');
  /// ```
  static Future<List<dynamic>> getStatus({
    dynamic season,
    dynamic round,
    int? limit,
    int? offset,
  }) async {
    String endpoint = 'status.json';
    if (season != null) {
      endpoint = round != null ? '$season/$round/status.json' : '$season/status.json';
    }
    return _makeRequest(endpoint, limit: limit, offset: offset)
      .then((data) => data['MRData']['StatusTable']['Status']);
  }
  
  /// Get specific status information
  /// 
  /// Endpoint: GET /status/{statusId}.json
  /// 
  /// Parameters:
  /// - [statusId]: Status ID (1 = Finished, 2 = Disqualified, etc.)
  /// 
  /// Example:
  /// ```dart
  /// final finishedStatus = await F1Api.getStatusById(1);
  /// ```
  static Future<Map<String, dynamic>> getStatusById(int statusId) async {
    return _makeRequest('status/$statusId.json')
      .then((data) => data['MRData']['StatusTable']['Status'][0]);
  }
  
  // =============================================================================
  // SEASONS ENDPOINTS
  // =============================================================================
  
  /// Get all seasons
  /// 
  /// Endpoint: GET /seasons.json
  /// 
  /// Parameters:
  /// - [limit]: Maximum results (default: 30, max: 100)
  /// - [offset]: Pagination offset (default: 0)
  /// 
  /// Example:
  /// ```dart
  /// final allSeasons = await F1Api.getSeasons();
  /// ```
  static Future<List<dynamic>> getSeasons({
    int? limit,
    int? offset,
  }) async {
    return _makeRequest('seasons.json', limit: limit, offset: offset)
      .then((data) => data['MRData']['SeasonTable']['Seasons']);
  }
  
  // =============================================================================
  // ENHANCED F1 API ENDPOINTS (Alpha)
  // =============================================================================
  
  /// Get season schedules using the new F1 API
  /// 
  /// Endpoint: GET /f1/alpha/schedules/
  /// 
  /// Returns enhanced schedule data with metadata and pagination
  /// 
  /// Example:
  /// ```dart
  /// final schedules = await F1Api.getSchedules();
  /// ```
  static Future<Map<String, dynamic>> getSchedules({
    int? limit,
    int? offset,
  }) async {
    return _makeNewApiRequest('schedules/', limit: limit, offset: offset);
  }
  
  /// Get detailed season schedule
  /// 
  /// Endpoint: GET /f1/alpha/schedules/{year}/
  /// 
  /// Parameters:
  /// - [year]: Season year (e.g., 2024)
  /// 
  /// Returns detailed schedule with rounds, sessions, and navigation info
  /// 
  /// Example:
  /// ```dart
  /// final schedule2024 = await F1Api.getScheduleDetail(2024);
  /// ```
  static Future<Map<String, dynamic>> getScheduleDetail(int year) async {
    return _makeNewApiRequest('schedules/$year/');
  }
  
  /// Get session results using the new F1 API
  /// 
  /// Endpoint: GET /f1/alpha/results/
  /// 
  /// Returns enhanced session results with metadata and pagination
  /// 
  /// Example:
  /// ```dart
  /// final results = await F1Api.getSessionResults();
  /// ```
  static Future<Map<String, dynamic>> getSessionResults({
    int? limit,
    int? offset,
  }) async {
    return _makeNewApiRequest('results/', limit: limit, offset: offset);
  }
  
  /// Get detailed session result
  /// 
  /// Endpoint: GET /f1/alpha/results/{sessionId}/
  /// 
  /// Parameters:
  /// - [sessionId]: Session ID
  /// 
  /// Returns detailed session result with timing and classification data
  /// 
  /// Example:
  /// ```dart
  /// final sessionResult = await F1Api.getSessionResultDetail(123);
  /// ```
  static Future<Map<String, dynamic>> getSessionResultDetail(int sessionId) async {
    return _makeNewApiRequest('results/$sessionId/');
  }
  
  // =============================================================================
  // OPENF1 API ENDPOINTS
  // =============================================================================
  
  // -----------------------------------------------------------------------------
  // CAR DATA ENDPOINTS (OpenF1)
  // -----------------------------------------------------------------------------
  
  /// Get car telemetry data from OpenF1 API
  /// 
  /// Endpoint: GET /car_data
  /// Returns: Real-time car telemetry data sampled at approximately 3.7Hz
  /// 
  /// Parameters:
  /// - [sessionKey]: Session identifier (required)
  /// - [driverNumber]: Driver number (1-99)
  /// - [date]: Date filter (ISO 8601 format)
  /// - [dateGte]: Date greater than or equal
  /// - [dateLte]: Date less than or equal
  /// 
  /// Example:
  /// ```dart
  /// // Get all car data for session
  /// final carData = await F1Api.getCarData(sessionKey: 9158);
  /// 
  /// // Get car data for specific driver
  /// final hamiltonData = await F1Api.getCarData(sessionKey: 9158, driverNumber: 44);
  /// 
  /// // Get latest car data
  /// final latestData = await F1Api.getLatestCarData();
  /// ```
  static Future<List<dynamic>> getCarData({
    int? sessionKey,
    int? driverNumber,
    String? date,
    String? dateGte,
    String? dateLte,
  }) async {
    final queryParams = <String, String>{};
    
    if (sessionKey != null) queryParams['session_key'] = sessionKey.toString();
    if (driverNumber != null) queryParams['driver_number'] = driverNumber.toString();
    if (date != null) queryParams['date'] = date;
    if (dateGte != null) queryParams['date>'] = dateGte;
    if (dateLte != null) queryParams['date<'] = dateLte;
    
    return _makeOpenF1Request('car_data', queryParams);
  }
  
  /// Get latest car telemetry data from OpenF1 API
  /// 
  /// Endpoint: GET /car_data?latest
  /// Returns: Most recent car telemetry data for all drivers
  /// 
  /// Example:
  /// ```dart
  /// final latestData = await F1Api.getLatestCarData();
  /// ```
  static Future<List<dynamic>> getLatestCarData() async {
    return _makeOpenF1Request('car_data', {'latest': 'true'});
  }
  
  // -----------------------------------------------------------------------------
  // DRIVERS ENDPOINTS (OpenF1)
  // -----------------------------------------------------------------------------
  
  /// Get driver information from OpenF1 API
  /// 
  /// Endpoint: GET /drivers
  /// Returns: Driver information for sessions including team affiliations
  /// 
  /// Parameters:
  /// - [sessionKey]: Session identifier
  /// - [driverNumber]: Driver number (1-99)
  /// - [teamName]: Team name filter
  /// - [nameAcronym]: Driver name acronym (e.g., "HAM", "VER")
  /// 
  /// Example:
  /// ```dart
  /// // Get all drivers for session
  /// final drivers = await F1Api.getOpenF1Drivers(sessionKey: 9158);
  /// 
  /// // Get specific driver
  /// final hamilton = await F1Api.getOpenF1Drivers(driverNumber: 44);
  /// 
  /// // Get drivers by team
  /// final mercedesDrivers = await F1Api.getOpenF1Drivers(teamName: "Mercedes");
  /// ```
  static Future<List<dynamic>> getOpenF1Drivers({
    int? sessionKey,
    int? driverNumber,
    String? teamName,
    String? nameAcronym,
  }) async {
    final queryParams = <String, String>{};
    
    if (sessionKey != null) queryParams['session_key'] = sessionKey.toString();
    if (driverNumber != null) queryParams['driver_number'] = driverNumber.toString();
    if (teamName != null) queryParams['team_name'] = teamName;
    if (nameAcronym != null) queryParams['name_acronym'] = nameAcronym;
    
    return _makeOpenF1Request('drivers', queryParams);
  }
  
  // -----------------------------------------------------------------------------
  // INTERVALS ENDPOINTS (OpenF1)
  // -----------------------------------------------------------------------------
  
  /// Get real-time gap intervals from OpenF1 API
  /// 
  /// Endpoint: GET /intervals
  /// Returns: Real-time gap data showing intervals between drivers during races
  /// 
  /// Parameters:
  /// - [sessionKey]: Session identifier (required for historical data)
  /// - [driverNumber]: Driver number (1-99)
  /// - [date]: Date filter (ISO 8601 format)
  /// - [dateGte]: Date greater than or equal
  /// - [dateLte]: Date less than or equal
  /// 
  /// Example:
  /// ```dart
  /// // Get all intervals for session
  /// final intervals = await F1Api.getIntervals(sessionKey: 9158);
  /// 
  /// // Get intervals for specific driver
  /// final hamiltonIntervals = await F1Api.getIntervals(sessionKey: 9158, driverNumber: 44);
  /// 
  /// // Get latest intervals
  /// final latestIntervals = await F1Api.getLatestIntervals();
  /// ```
  static Future<List<dynamic>> getIntervals({
    int? sessionKey,
    int? driverNumber,
    String? date,
    String? dateGte,
    String? dateLte,
  }) async {
    final queryParams = <String, String>{};
    
    if (sessionKey != null) queryParams['session_key'] = sessionKey.toString();
    if (driverNumber != null) queryParams['driver_number'] = driverNumber.toString();
    if (date != null) queryParams['date'] = date;
    if (dateGte != null) queryParams['date>'] = dateGte;
    if (dateLte != null) queryParams['date<'] = dateLte;
    
    return _makeOpenF1Request('intervals', queryParams);
  }
  
  /// Get latest real-time gap intervals from OpenF1 API
  /// 
  /// Endpoint: GET /intervals?latest
  /// Returns: Most recent interval data for all drivers
  /// 
  /// Example:
  /// ```dart
  /// final latestIntervals = await F1Api.getLatestIntervals();
  /// ```
  static Future<List<dynamic>> getLatestIntervals() async {
    return _makeOpenF1Request('intervals', {'latest': 'true'});
  }
  
  // -----------------------------------------------------------------------------
  // LAPS ENDPOINTS (OpenF1)
  // -----------------------------------------------------------------------------
  
  /// Get detailed lap information from OpenF1 API
  /// 
  /// Endpoint: GET /laps
  /// Returns: Comprehensive lap data including sector times and lap times
  /// 
  /// Parameters:
  /// - [sessionKey]: Session identifier
  /// - [driverNumber]: Driver number (1-99)
  /// - [lapNumber]: Specific lap number
  /// - [lapNumberGte]: Lap number greater than or equal
  /// - [lapNumberLte]: Lap number less than or equal
  /// 
  /// Example:
  /// ```dart
  /// // Get all laps for session
  /// final laps = await F1Api.getOpenF1Laps(sessionKey: 9158);
  /// 
  /// // Get specific driver's laps
  /// final hamiltonLaps = await F1Api.getOpenF1Laps(sessionKey: 9158, driverNumber: 44);
  /// 
  /// // Get specific lap
  /// final lap10 = await F1Api.getOpenF1Laps(sessionKey: 9158, lapNumber: 10);
  /// ```
  static Future<List<dynamic>> getOpenF1Laps({
    int? sessionKey,
    int? driverNumber,
    int? lapNumber,
    int? lapNumberGte,
    int? lapNumberLte,
  }) async {
    final queryParams = <String, String>{};
    
    if (sessionKey != null) queryParams['session_key'] = sessionKey.toString();
    if (driverNumber != null) queryParams['driver_number'] = driverNumber.toString();
    if (lapNumber != null) queryParams['lap_number'] = lapNumber.toString();
    if (lapNumberGte != null) queryParams['lap_number>'] = lapNumberGte.toString();
    if (lapNumberLte != null) queryParams['lap_number<'] = lapNumberLte.toString();
    
    return _makeOpenF1Request('laps', queryParams);
  }
  
  // -----------------------------------------------------------------------------
  // LOCATION ENDPOINTS (OpenF1)
  // -----------------------------------------------------------------------------
  
  /// Get 3D car location data from OpenF1 API
  /// 
  /// Endpoint: GET /location
  /// Returns: 3D positions of cars on track sampled at approximately 3.7Hz
  /// 
  /// Parameters:
  /// - [sessionKey]: Session identifier (required)
  /// - [driverNumber]: Driver number (1-99)
  /// - [date]: Date filter (ISO 8601 format)
  /// - [dateGte]: Date greater than or equal
  /// - [dateLte]: Date less than or equal
  /// 
  /// Example:
  /// ```dart
  /// // Get all location data for session
  /// final locations = await F1Api.getLocations(sessionKey: 9158);
  /// 
  /// // Get location data for specific driver
  /// final hamiltonLocation = await F1Api.getLocations(sessionKey: 9158, driverNumber: 44);
  /// 
  /// // Get latest locations
  /// final latestLocations = await F1Api.getLatestLocations();
  /// ```
  static Future<List<dynamic>> getLocations({
    int? sessionKey,
    int? driverNumber,
    String? date,
    String? dateGte,
    String? dateLte,
  }) async {
    final queryParams = <String, String>{};
    
    if (sessionKey != null) queryParams['session_key'] = sessionKey.toString();
    if (driverNumber != null) queryParams['driver_number'] = driverNumber.toString();
    if (date != null) queryParams['date'] = date;
    if (dateGte != null) queryParams['date>'] = dateGte;
    if (dateLte != null) queryParams['date<'] = dateLte;
    
    return _makeOpenF1Request('location', queryParams);
  }
  
  /// Get latest 3D car location data from OpenF1 API
  /// 
  /// Endpoint: GET /location?latest
  /// Returns: Most recent 3D position data for all cars
  /// 
  /// Example:
  /// ```dart
  /// final latestLocations = await F1Api.getLatestLocations();
  /// ```
  static Future<List<dynamic>> getLatestLocations() async {
    return _makeOpenF1Request('location', {'latest': 'true'});
  }
  
  // -----------------------------------------------------------------------------
  // MEETINGS ENDPOINTS (OpenF1)
  // -----------------------------------------------------------------------------
  
  /// Get Grand Prix meeting information from OpenF1 API
  /// 
  /// Endpoint: GET /meetings
  /// Returns: Information about Grand Prix weekends and meetings
  /// 
  /// Parameters:
  /// - [meetingKey]: Meeting identifier
  /// - [year]: Year filter
  /// - [countryName]: Country name filter
  /// - [circuitShortName]: Circuit short name filter
  /// 
  /// Example:
  /// ```dart
  /// // Get all meetings for 2024
  /// final meetings2024 = await F1Api.getMeetings(year: 2024);
  /// 
  /// // Get specific meeting
  /// final meeting = await F1Api.getMeetings(meetingKey: 1217);
  /// 
  /// // Get meetings by country
  /// final monacoMeetings = await F1Api.getMeetings(countryName: "Monaco");
  /// ```
  static Future<List<dynamic>> getMeetings({
    int? meetingKey,
    int? year,
    String? countryName,
    String? circuitShortName,
  }) async {
    final queryParams = <String, String>{};
    
    if (meetingKey != null) queryParams['meeting_key'] = meetingKey.toString();
    if (year != null) queryParams['year'] = year.toString();
    if (countryName != null) queryParams['country_name'] = countryName;
    if (circuitShortName != null) queryParams['circuit_short_name'] = circuitShortName;
    
    return _makeOpenF1Request('meetings', queryParams);
  }
  
  // -----------------------------------------------------------------------------
  // PIT ENDPOINTS (OpenF1)
  // -----------------------------------------------------------------------------
  
  /// Get pit lane timing data from OpenF1 API
  /// 
  /// Endpoint: GET /pit
  /// Returns: Pit lane timing data including pit stop duration and pit lane times
  /// 
  /// Parameters:
  /// - [sessionKey]: Session identifier
  /// - [driverNumber]: Driver number (1-99)
  /// - [date]: Date filter (ISO 8601 format)
  /// - [dateGte]: Date greater than or equal
  /// - [dateLte]: Date less than or equal
  /// 
  /// Example:
  /// ```dart
  /// // Get all pit data for session
  /// final pitData = await F1Api.getPitData(sessionKey: 9158);
  /// 
  /// // Get pit data for specific driver
  /// final hamiltonPits = await F1Api.getPitData(sessionKey: 9158, driverNumber: 44);
  /// ```
  static Future<List<dynamic>> getPitData({
    int? sessionKey,
    int? driverNumber,
    String? date,
    String? dateGte,
    String? dateLte,
  }) async {
    final queryParams = <String, String>{};
    
    if (sessionKey != null) queryParams['session_key'] = sessionKey.toString();
    if (driverNumber != null) queryParams['driver_number'] = driverNumber.toString();
    if (date != null) queryParams['date'] = date;
    if (dateGte != null) queryParams['date>'] = dateGte;
    if (dateLte != null) queryParams['date<'] = dateLte;
    
    return _makeOpenF1Request('pit', queryParams);
  }
  
  // -----------------------------------------------------------------------------
  // POSITION ENDPOINTS (OpenF1)
  // -----------------------------------------------------------------------------
  
  /// Get driver position changes from OpenF1 API
  /// 
  /// Endpoint: GET /position
  /// Returns: Real-time driver position changes during sessions
  /// 
  /// Parameters:
  /// - [sessionKey]: Session identifier
  /// - [driverNumber]: Driver number (1-99)
  /// - [date]: Date filter (ISO 8601 format)
  /// - [dateGte]: Date greater than or equal
  /// - [dateLte]: Date less than or equal
  /// - [position]: Specific position filter
  /// 
  /// Example:
  /// ```dart
  /// // Get all position data for session
  /// final positions = await F1Api.getPositions(sessionKey: 9158);
  /// 
  /// // Get position data for specific driver
  /// final hamiltonPositions = await F1Api.getPositions(sessionKey: 9158, driverNumber: 44);
  /// 
  /// // Get latest positions
  /// final latestPositions = await F1Api.getLatestPositions();
  /// ```
  static Future<List<dynamic>> getPositions({
    int? sessionKey,
    int? driverNumber,
    String? date,
    String? dateGte,
    String? dateLte,
    int? position,
  }) async {
    final queryParams = <String, String>{};
    
    if (sessionKey != null) queryParams['session_key'] = sessionKey.toString();
    if (driverNumber != null) queryParams['driver_number'] = driverNumber.toString();
    if (date != null) queryParams['date'] = date;
    if (dateGte != null) queryParams['date>'] = dateGte;
    if (dateLte != null) queryParams['date<'] = dateLte;
    if (position != null) queryParams['position'] = position.toString();
    
    return _makeOpenF1Request('position', queryParams);
  }
  
  /// Get latest driver position data from OpenF1 API
  /// 
  /// Endpoint: GET /position?latest
  /// Returns: Most recent position data for all drivers
  /// 
  /// Example:
  /// ```dart
  /// final latestPositions = await F1Api.getLatestPositions();
  /// ```
  static Future<List<dynamic>> getLatestPositions() async {
    return _makeOpenF1Request('position', {'latest': 'true'});
  }
  
  // -----------------------------------------------------------------------------
  // RACE CONTROL ENDPOINTS (OpenF1)
  // -----------------------------------------------------------------------------
  
  /// Get race control messages from OpenF1 API
  /// 
  /// Endpoint: GET /race_control
  /// Returns: Race control messages including flags, safety car, and incident information
  /// 
  /// Parameters:
  /// - [sessionKey]: Session identifier
  /// - [category]: Message category filter
  /// - [flag]: Flag type filter
  /// - [scope]: Message scope filter
  /// - [sector]: Sector number filter
  /// - [date]: Date filter (ISO 8601 format)
  /// - [dateGte]: Date greater than or equal
  /// - [dateLte]: Date less than or equal
  /// 
  /// Example:
  /// ```dart
  /// // Get all race control messages for session
  /// final raceControl = await F1Api.getRaceControlMessages(sessionKey: 9158);
  /// 
  /// // Get yellow flag messages
  /// final yellowFlags = await F1Api.getRaceControlMessages(sessionKey: 9158, flag: "YELLOW");
  /// 
  /// // Get safety car messages
  /// final safetyCar = await F1Api.getRaceControlMessages(sessionKey: 9158, category: "SafetyCar");
  /// ```
  static Future<List<dynamic>> getRaceControlMessages({
    int? sessionKey,
    String? category,
    String? flag,
    String? scope,
    int? sector,
    String? date,
    String? dateGte,
    String? dateLte,
  }) async {
    final queryParams = <String, String>{};
    
    if (sessionKey != null) queryParams['session_key'] = sessionKey.toString();
    if (category != null) queryParams['category'] = category;
    if (flag != null) queryParams['flag'] = flag;
    if (scope != null) queryParams['scope'] = scope;
    if (sector != null) queryParams['sector'] = sector.toString();
    if (date != null) queryParams['date'] = date;
    if (dateGte != null) queryParams['date>'] = dateGte;
    if (dateLte != null) queryParams['date<'] = dateLte;
    
    return _makeOpenF1Request('race_control', queryParams);
  }
  
  // -----------------------------------------------------------------------------
  // SESSIONS ENDPOINTS (OpenF1)
  // -----------------------------------------------------------------------------
  
  /// Get session information from OpenF1 API
  /// 
  /// Endpoint: GET /sessions
  /// Returns: Information about practice, qualifying, and race sessions
  /// 
  /// Parameters:
  /// - [sessionKey]: Session identifier
  /// - [sessionName]: Session name (e.g., "Practice 1", "Qualifying", "Race")
  /// - [sessionType]: Session type filter
  /// - [countryName]: Country name filter
  /// - [circuitShortName]: Circuit short name filter
  /// - [year]: Year filter
  /// 
  /// Example:
  /// ```dart
  /// // Get all sessions for 2024
  /// final sessions2024 = await F1Api.getSessions(year: 2024);
  /// 
  /// // Get specific session
  /// final session = await F1Api.getSessions(sessionKey: 9158);
  /// 
  /// // Get qualifying sessions
  /// final qualifying = await F1Api.getSessions(sessionName: "Qualifying");
  /// 
  /// // Get sessions by country
  /// final monacoSessions = await F1Api.getSessions(countryName: "Monaco");
  /// ```
  static Future<List<dynamic>> getSessions({
    int? sessionKey,
    String? sessionName,
    String? sessionType,
    String? countryName,
    String? circuitShortName,
    int? year,
  }) async {
    final queryParams = <String, String>{};
    
    if (sessionKey != null) queryParams['session_key'] = sessionKey.toString();
    if (sessionName != null) queryParams['session_name'] = sessionName;
    if (sessionType != null) queryParams['session_type'] = sessionType;
    if (countryName != null) queryParams['country_name'] = countryName;
    if (circuitShortName != null) queryParams['circuit_short_name'] = circuitShortName;
    if (year != null) queryParams['year'] = year.toString();
    
    return _makeOpenF1Request('sessions', queryParams);
  }
  
  // -----------------------------------------------------------------------------
  // STINTS ENDPOINTS (OpenF1)
  // -----------------------------------------------------------------------------
  
  /// Get tire stint information from OpenF1 API
  /// 
  /// Endpoint: GET /stints
  /// Returns: Information about individual stints including tire compounds and age
  /// 
  /// Parameters:
  /// - [sessionKey]: Session identifier
  /// - [driverNumber]: Driver number (1-99)
  /// - [compound]: Tire compound filter ("SOFT", "MEDIUM", "HARD", "INTERMEDIATE", "WET")
  /// - [stintNumber]: Stint number filter
  /// - [lapStart]: Starting lap number filter
  /// - [lapEnd]: Ending lap number filter
  /// - [tyreAgeAtStart]: Filter by tire age at start
  /// - [tyreAgeAtStartGte]: Tire age at start greater than or equal
  /// - [tyreAgeAtStartLte]: Tire age at start less than or equal
  /// 
  /// Example:
  /// ```dart
  /// // Get all stints for session
  /// final stints = await F1Api.getStints(sessionKey: 9158);
  /// 
  /// // Get stints for specific driver
  /// final hamiltonStints = await F1Api.getStints(sessionKey: 9158, driverNumber: 44);
  /// 
  /// // Get soft tire stints
  /// final softStints = await F1Api.getStints(sessionKey: 9158, compound: "SOFT");
  /// 
  /// // Get stints with fresh tires
  /// final freshTires = await F1Api.getStints(sessionKey: 9158, tyreAgeAtStart: 0);
  /// ```
  static Future<List<dynamic>> getStints({
    int? sessionKey,
    int? driverNumber,
    String? compound,
    int? stintNumber,
    int? lapStart,
    int? lapEnd,
    int? tyreAgeAtStart,
    int? tyreAgeAtStartGte,
    int? tyreAgeAtStartLte,
  }) async {
    final queryParams = <String, String>{};
    
    if (sessionKey != null) queryParams['session_key'] = sessionKey.toString();
    if (driverNumber != null) queryParams['driver_number'] = driverNumber.toString();
    if (compound != null) queryParams['compound'] = compound;
    if (stintNumber != null) queryParams['stint_number'] = stintNumber.toString();
    if (lapStart != null) queryParams['lap_start'] = lapStart.toString();
    if (lapEnd != null) queryParams['lap_end'] = lapEnd.toString();
    if (tyreAgeAtStart != null) queryParams['tyre_age_at_start'] = tyreAgeAtStart.toString();
    if (tyreAgeAtStartGte != null) queryParams['tyre_age_at_start>'] = tyreAgeAtStartGte.toString();
    if (tyreAgeAtStartLte != null) queryParams['tyre_age_at_start<'] = tyreAgeAtStartLte.toString();
    
    return _makeOpenF1Request('stints', queryParams);
  }
  
  /// Get latest stint information from OpenF1 API
  /// 
  /// Endpoint: GET /stints?latest
  /// Returns: Most recent stint data for all drivers
  /// 
  /// Example:
  /// ```dart
  /// final latestStints = await F1Api.getLatestStints();
  /// ```
  static Future<List<dynamic>> getLatestStints() async {
    return _makeOpenF1Request('stints', {'latest': 'true'});
  }
  
  // -----------------------------------------------------------------------------
  // RADIO ENDPOINTS (OpenF1) - Note: Available in documentation but may require special access
  // -----------------------------------------------------------------------------
  
  /// Get driver radio communications from OpenF1 API
  /// 
  /// Endpoint: GET /team_radio
  /// Returns: Driver radio communications during sessions
  /// 
  /// Note: This endpoint may require special access or authentication.
  /// Check OpenF1 API documentation for current availability.
  /// 
  /// Parameters:
  /// - [sessionKey]: Session identifier
  /// - [driverNumber]: Driver number (1-99)
  /// - [date]: Date filter (ISO 8601 format)
  /// - [dateGte]: Date greater than or equal
  /// - [dateLte]: Date less than or equal
  /// 
  /// Example:
  /// ```dart
  /// // Get all radio communications for session
  /// final radio = await F1Api.getTeamRadio(sessionKey: 9158);
  /// 
  /// // Get radio for specific driver
  /// final hamiltonRadio = await F1Api.getTeamRadio(sessionKey: 9158, driverNumber: 44);
  /// ```
  static Future<List<dynamic>> getTeamRadio({
    int? sessionKey,
    int? driverNumber,
    String? date,
    String? dateGte,
    String? dateLte,
  }) async {
    final queryParams = <String, String>{};
    
    if (sessionKey != null) queryParams['session_key'] = sessionKey.toString();
    if (driverNumber != null) queryParams['driver_number'] = driverNumber.toString();
    if (date != null) queryParams['date'] = date;
    if (dateGte != null) queryParams['date>'] = dateGte;
    if (dateLte != null) queryParams['date<'] = dateLte;
    
    return _makeOpenF1Request('team_radio', queryParams);
  }
  
  // -----------------------------------------------------------------------------
  // WEATHER ENDPOINTS (OpenF1)
  // -----------------------------------------------------------------------------
  
  /// Get weather data from OpenF1 API
  /// 
  /// Endpoint: GET /weather
  /// Returns: Weather information for sessions including temperature, humidity, and conditions
  /// 
  /// Parameters:
  /// - [sessionKey]: Session identifier
  /// - [date]: Date filter (ISO 8601 format)
  /// - [dateGte]: Date greater than or equal
  /// - [dateLte]: Date less than or equal
  /// 
  /// Example:
  /// ```dart
  /// // Get all weather data for session
  /// final weather = await F1Api.getWeather(sessionKey: 9158);
  /// 
  /// // Get latest weather
  /// final latestWeather = await F1Api.getLatestWeather();
  /// ```
  static Future<List<dynamic>> getWeather({
    int? sessionKey,
    String? date,
    String? dateGte,
    String? dateLte,
  }) async {
    final queryParams = <String, String>{};
    
    if (sessionKey != null) queryParams['session_key'] = sessionKey.toString();
    if (date != null) queryParams['date'] = date;
    if (dateGte != null) queryParams['date>'] = dateGte;
    if (dateLte != null) queryParams['date<'] = dateLte;
    
    return _makeOpenF1Request('weather', queryParams);
  }
  
  /// Get latest weather data from OpenF1 API
  /// 
  /// Endpoint: GET /weather?latest
  /// Returns: Most recent weather data
  /// 
  /// Example:
  /// ```dart
  /// final latestWeather = await F1Api.getLatestWeather();
  /// ```
  static Future<List<dynamic>> getLatestWeather() async {
    return _makeOpenF1Request('weather', {'latest': 'true'});
  }
  
  // =============================================================================
  // UTILITY METHODS FOR OPENF1 API
  // =============================================================================
  
  /// Get current live session key for OpenF1 API
  /// 
  /// This method attempts to find the current active session by getting
  /// the latest session data from OpenF1 API.
  /// 
  /// Example:
  /// ```dart
  /// final currentSession = await F1Api.getCurrentSessionKey();
  /// if (currentSession != null) {
  ///   final liveData = await F1Api.getLatestCarData();
  /// }
  /// ```
  static Future<int?> getCurrentSessionKey() async {
    try {
      final sessions = await getSessions();
      if (sessions.isNotEmpty) {
        // Find the most recent session
        final sortedSessions = List<Map<String, dynamic>>.from(sessions);
        sortedSessions.sort((a, b) {
          final dateA = DateTime.parse(a['date_start'] ?? '1970-01-01');
          final dateB = DateTime.parse(b['date_start'] ?? '1970-01-01');
          return dateB.compareTo(dateA);
        });
        return sortedSessions.first['session_key'] as int?;
      }
    } catch (e) {
      // Return null if unable to get current session
    }
    return null;
  }
  
  /// Get live telemetry data for a specific driver
  /// 
  /// This is a convenience method that combines session lookup with car data retrieval.
  /// 
  /// Parameters:
  /// - [driverNumber]: Driver number (1-99)
  /// 
  /// Example:
  /// ```dart
  /// // Get live telemetry for Lewis Hamilton (car #44)
  /// final hamiltonTelemetry = await F1Api.getLiveTelemetry(44);
  /// ```
  static Future<List<dynamic>> getLiveTelemetry(int driverNumber) async {
    final sessionKey = await getCurrentSessionKey();
    if (sessionKey != null) {
      return getCarData(sessionKey: sessionKey, driverNumber: driverNumber);
    }
    return [];
  }
  
  /// Get live race positions for all drivers
  /// 
  /// This is a convenience method that gets the latest position data.
  /// 
  /// Example:
  /// ```dart
  /// final livePositions = await F1Api.getLiveRacePositions();
  /// ```
  static Future<List<dynamic>> getLiveRacePositions() async {
    return getLatestPositions();
  }
  
  /// Get live timing gaps between drivers
  /// 
  /// This is a convenience method that gets the latest interval data.
  /// 
  /// Example:
  /// ```dart
  /// final liveGaps = await F1Api.getLiveTimingGaps();
  /// ```
  static Future<List<dynamic>> getLiveTimingGaps() async {
    return getLatestIntervals();
  }

  // =============================================================================
  // HTTP REQUEST METHODS
  // =============================================================================
  
  /// Internal method to get driver standings
  static Future<List<dynamic>> _getDriverStandings(
    dynamic season, {
    dynamic round,
    int? limit,
    int? offset,
  }) async {
    String endpoint = '$season/driverstandings.json';
    if (round != null) {
      endpoint = '$season/$round/driverstandings.json';
    }
    return _makeRequest(endpoint, limit: limit, offset: offset)
      .then((data) => data['MRData']['StandingsTable']['StandingsLists'][0]['DriverStandings']);
  }
  
  /// Internal method to get constructor standings
  static Future<List<dynamic>> _getConstructorStandings(
    dynamic season, {
    dynamic round,
    int? limit,
    int? offset,
  }) async {
    String endpoint = '$season/constructorstandings.json';
    if (round != null) {
      endpoint = '$season/$round/constructorstandings.json';
    }
    return _makeRequest(endpoint, limit: limit, offset: offset)
      .then((data) => data['MRData']['StandingsTable']['StandingsLists'][0]['ConstructorStandings']);
  }
  
  /// Internal method to make HTTP requests to the Ergast-compatible API
  static Future<Map<String, dynamic>> _makeRequest(
    String endpoint, {
    int? limit,
    int? offset,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      final queryParams = <String, String>{};
      
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();
      
      final finalUri = queryParams.isNotEmpty 
        ? uri.replace(queryParameters: queryParams)
        : uri;
      
      final response = await http.get(finalUri);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error making API request to $endpoint: $e');
    }
  }
  
  /// Internal method to make HTTP requests to the new F1 API
  static Future<Map<String, dynamic>> _makeNewApiRequest(
    String endpoint, {
    int? limit,
    int? offset,
  }) async {
    try {
      final uri = Uri.parse('$newApiBaseUrl/$endpoint');
      final queryParams = <String, String>{};
      
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();
      
      final finalUri = queryParams.isNotEmpty 
        ? uri.replace(queryParameters: queryParams)
        : uri;
      
      final response = await http.get(finalUri);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error making new API request to $endpoint: $e');
    }
  }
  
  /// Internal method to make HTTP requests to the OpenF1 API
  static Future<List<dynamic>> _makeOpenF1Request(
    String endpoint,
    Map<String, String> queryParams,
  ) async {
    try {
      final uri = Uri.parse('$openF1BaseUrl/$endpoint');
      final finalUri = queryParams.isNotEmpty 
        ? uri.replace(queryParameters: queryParams)
        : uri;
      
      final response = await http.get(finalUri);
      
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        // OpenF1 API returns a list directly
        return decoded is List ? decoded : [decoded];
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error making OpenF1 API request to $endpoint: $e');
    }
  }
}
