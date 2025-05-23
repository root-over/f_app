class Driver {
  final String driverId;
  final String permanentNumber;
  final String code;
  final String givenName;
  final String familyName;
  final String dateOfBirth;
  final String nationality;
  final String url;

  Driver({
    required this.driverId,
    required this.permanentNumber,
    required this.code,
    required this.givenName,
    required this.familyName,
    required this.dateOfBirth,
    required this.nationality,
    required this.url,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      driverId: json['driverId'] ?? '',
      permanentNumber: json['permanentNumber'] ?? '',
      code: json['code'] ?? '',
      givenName: json['givenName'] ?? '',
      familyName: json['familyName'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      nationality: json['nationality'] ?? '',
      url: json['url'] ?? '',
    );
  }

  String get fullName => '$givenName $familyName';
  
  String get countryFlag {
    final flags = {
      'Dutch': '🇳🇱',
      'Monégasque': '🇲🇨',
      'British': '🇬🇧',
      'Spanish': '🇪🇸',
      'Australian': '🇦🇺',
      'German': '🇩🇪',
      'Finnish': '🇫🇮',
      'French': '🇫🇷',
      'Canadian': '🇨🇦',
      'Mexican': '🇲🇽',
      'Thai': '🇹🇭',
      'Japanese': '🇯🇵',
      'Chinese': '🇨🇳',
      'American': '🇺🇸',
      'Danish': '🇩🇰',
    };
    return flags[nationality] ?? '🏁';
  }
}