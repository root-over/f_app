class Race {
  final String season;
  final String round;
  final String url;
  final String raceName;
  final Circuit circuit;
  final String date;
  final String time;

  Race({
    required this.season,
    required this.round,
    required this.url,
    required this.raceName,
    required this.circuit,
    required this.date,
    required this.time,
  });

  factory Race.fromJson(Map<String, dynamic> json) {
    return Race(
      season: json['season'] ?? '',
      round: json['round'] ?? '',
      url: json['url'] ?? '',
      raceName: json['raceName'] ?? '',
      circuit: Circuit.fromJson(json['Circuit'] ?? {}),
      date: json['date'] ?? '',
      time: json['time'] ?? '',
    );
  }

  DateTime get dateTime {
    try {
      return DateTime.parse('$date $time');
    } catch (e) {
      return DateTime.parse(date);
    }
  }

  bool get isCompleted => dateTime.isBefore(DateTime.now());
}

class Circuit {
  final String circuitId;
  final String url;
  final String circuitName;
  final Location location;

  Circuit({
    required this.circuitId,
    required this.url,
    required this.circuitName,
    required this.location,
  });

  factory Circuit.fromJson(Map<String, dynamic> json) {
    return Circuit(
      circuitId: json['circuitId'] ?? '',
      url: json['url'] ?? '',
      circuitName: json['circuitName'] ?? '',
      location: Location.fromJson(json['Location'] ?? {}),
    );
  }
}

class Location {
  final String lat;
  final String long;
  final String locality;
  final String country;

  Location({
    required this.lat,
    required this.long,
    required this.locality,
    required this.country,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: json['lat'] ?? '',
      long: json['long'] ?? '',
      locality: json['locality'] ?? '',
      country: json['country'] ?? '',
    );
  }
}