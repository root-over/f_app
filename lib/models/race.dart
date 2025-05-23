class RaceSession {
  final String name;
  final String date;
  final String time;
  RaceSession({required this.name, required this.date, required this.time});

  factory RaceSession.fromJson(String name, Map<String, dynamic> json) {
    return RaceSession(
      name: name,
      date: json['date'] ?? '',
      time: json['time'] ?? '',
    );
  }
}

class Race {
  final String season;
  final String round;
  final String url;
  final String raceName;
  final Circuit circuit;
  final String date;
  final String time;
  final List<RaceSession> sessions;

  Race({
    required this.season,
    required this.round,
    required this.url,
    required this.raceName,
    required this.circuit,
    required this.date,
    required this.time,
    required this.sessions,
  });

  factory Race.fromJson(Map<String, dynamic> json) {
    List<RaceSession> sessions = [];
    if (json['FirstPractice'] != null) {
      sessions.add(RaceSession.fromJson('Prove Libere 1', json['FirstPractice']));
    }
    if (json['SecondPractice'] != null) {
      sessions.add(RaceSession.fromJson('Prove Libere 2', json['SecondPractice']));
    }
    if (json['ThirdPractice'] != null) {
      sessions.add(RaceSession.fromJson('Prove Libere 3', json['ThirdPractice']));
    }
    if (json['Qualifying'] != null) {
      sessions.add(RaceSession.fromJson('Qualifiche', json['Qualifying']));
    }
    if (json['Sprint'] != null) {
      sessions.add(RaceSession.fromJson('Sprint', json['Sprint']));
    }
    if (json['SprintQualifying'] != null) {
      sessions.add(RaceSession.fromJson('Sprint Qualifying', json['SprintQualifying']));
    }
    if (json['SprintShootout'] != null) {
      sessions.add(RaceSession.fromJson('Sprint Shootout', json['SprintShootout']));
    }
    sessions.add(RaceSession(name: 'Gara', date: json['date'] ?? '', time: json['time'] ?? ''));
    return Race(
      season: json['season'] ?? '',
      round: json['round'] ?? '',
      url: json['url'] ?? '',
      raceName: json['raceName'] ?? '',
      circuit: Circuit.fromJson(json['Circuit'] ?? {}),
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      sessions: sessions,
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