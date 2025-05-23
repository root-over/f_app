class ConstructorStanding {
  final int position;
  final double points;
  final int wins;
  final String constructorName;
  final String constructorNationality;

  ConstructorStanding({
    required this.position,
    required this.points,
    required this.wins,
    required this.constructorName,
    required this.constructorNationality,
  });

  factory ConstructorStanding.fromJson(Map<String, dynamic> json) {
    return ConstructorStanding(
      position: int.parse(json['position'] as String),
      points: double.parse(json['points'] as String),
      wins: int.parse(json['wins'] as String),
      constructorName: json['Constructor']['name'],
      constructorNationality: json['Constructor']['nationality'],
    );
  }
}
