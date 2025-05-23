class Constructor {
  final String constructorId;
  final String name;
  final String nationality;

  Constructor({
    required this.constructorId,
    required this.name,
    required this.nationality,
  });

  factory Constructor.fromJson(Map<String, dynamic> json) {
    return Constructor(
      constructorId: json['constructorId'],
      name: json['name'],
      nationality: json['nationality'],
    );
  }
}

class ConstructorStanding {
  final int position;
  final double points;
  final int wins;
  final Constructor constructor;

  ConstructorStanding({
    required this.position,
    required this.points,
    required this.wins,
    required this.constructor,
  });

  factory ConstructorStanding.fromJson(Map<String, dynamic> json) {
    return ConstructorStanding(
      position: int.parse(json['position'] as String),
      points: double.parse(json['points'] as String),
      wins: int.parse(json['wins'] as String),
      constructor: Constructor.fromJson(json['Constructor']),
    );
  }
}
