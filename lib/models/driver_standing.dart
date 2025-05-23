class DriverStanding {
  final int position;
  final double points;
  final int wins;
  final String driverCode;
  final String driverGivenName;
  final String driverFamilyName;
  final String driverNationality;
  final String constructorName;

  DriverStanding({
    required this.position,
    required this.points,
    required this.wins,
    required this.driverCode,
    required this.driverGivenName,
    required this.driverFamilyName,
    required this.driverNationality,
    required this.constructorName,
  });

  factory DriverStanding.fromJson(Map<String, dynamic> json) {
    return DriverStanding(
      position: int.parse(json['position'] as String),
      points: double.parse(json['points'] as String),
      wins: int.parse(json['wins'] as String),
      driverCode: json['Driver']['code'],
      driverGivenName: json['Driver']['givenName'],
      driverFamilyName: json['Driver']['familyName'],
      driverNationality: json['Driver']['nationality'],
      constructorName: json['Constructors'][0]['name'], // Assuming the first constructor is the relevant one
    );
  }
}
