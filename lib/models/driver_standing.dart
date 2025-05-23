class Driver {
  final String driverId;
  final String? permanentNumber;
  final String? code;
  final String givenName;
  final String familyName;
  final String dateOfBirth;
  final String nationality;

  Driver({
    required this.driverId,
    this.permanentNumber,
    this.code,
    required this.givenName,
    required this.familyName,
    required this.dateOfBirth,
    required this.nationality,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      driverId: json['driverId'],
      permanentNumber: json['permanentNumber'],
      code: json['code'],
      givenName: json['givenName'],
      familyName: json['familyName'],
      dateOfBirth: json['dateOfBirth'],
      nationality: json['nationality'],
    );
  }
}

class ConstructorInfo { // Renamed from Constructor to avoid conflict if a top-level Constructor model exists
  final String constructorId;
  final String name;
  final String nationality;

  ConstructorInfo({
    required this.constructorId,
    required this.name,
    required this.nationality,
  });

  factory ConstructorInfo.fromJson(Map<String, dynamic> json) {
    return ConstructorInfo(
      constructorId: json['constructorId'],
      name: json['name'],
      nationality: json['nationality'],
    );
  }
}

class DriverStanding {
  final int position;
  final double points;
  final int wins;
  final Driver driver;
  final List<ConstructorInfo> constructors;

  DriverStanding({
    required this.position,
    required this.points,
    required this.wins,
    required this.driver,
    required this.constructors,
  });

  factory DriverStanding.fromJson(Map<String, dynamic> json) {
    var constructorList = json['Constructors'] as List;
    List<ConstructorInfo> constructors = constructorList.map((i) => ConstructorInfo.fromJson(i)).toList();
    
    return DriverStanding(
      position: int.parse(json['position'] as String),
      points: double.parse(json['points'] as String),
      wins: int.parse(json['wins'] as String),
      driver: Driver.fromJson(json['Driver']),
      constructors: constructors,
    );
  }
}
