class CityLocation {
  final String name;
  final String country;
  final double latitude;
  final double longitude;
  final String timezone;

  CityLocation({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'country': country,
    'latitude': latitude,
    'longitude': longitude,
    'timezone': timezone,
  };

  factory CityLocation.fromJson(Map<String, dynamic> json) {
    return CityLocation(
      name: json['name'],
      country: json['country'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      timezone: json['timezone'],
    );
  }
}

// Azerbaycan şehirleri listesi
class AzerbaijanCities {
  static final List<CityLocation> cities = [
    CityLocation(
      name: 'Bakı',
      country: 'Azerbaijan',
      latitude: 40.4093,
      longitude: 49.8671,
      timezone: 'Asia/Baku',
    ),
    CityLocation(
      name: 'Gəncə',
      country: 'Azerbaijan',
      latitude: 40.6828,
      longitude: 46.3606,
      timezone: 'Asia/Baku',
    ),
    CityLocation(
      name: 'Sumqayıt',
      country: 'Azerbaijan',
      latitude: 40.5897,
      longitude: 49.6686,
      timezone: 'Asia/Baku',
    ),
    CityLocation(
      name: 'Mingəçevir',
      country: 'Azerbaijan',
      latitude: 40.7703,
      longitude: 47.0496,
      timezone: 'Asia/Baku',
    ),
    CityLocation(
      name: 'Şirvan',
      country: 'Azerbaijan',
      latitude: 39.9369,
      longitude: 48.9208,
      timezone: 'Asia/Baku',
    ),
    CityLocation(
      name: 'Naxçıvan',
      country: 'Azerbaijan',
      latitude: 39.2089,
      longitude: 45.4122,
      timezone: 'Asia/Baku',
    ),
    CityLocation(
      name: 'Lənkəran',
      country: 'Azerbaijan',
      latitude: 38.7536,
      longitude: 48.8511,
      timezone: 'Asia/Baku',
    ),
    CityLocation(
      name: 'Şəki',
      country: 'Azerbaijan',
      latitude: 41.1919,
      longitude: 47.1706,
      timezone: 'Asia/Baku',
    ),
    CityLocation(
      name: 'Quba',
      country: 'Azerbaijan',
      latitude: 41.3614,
      longitude: 48.5133,
      timezone: 'Asia/Baku',
    ),
    CityLocation(
      name: 'Şamaxı',
      country: 'Azerbaijan',
      latitude: 40.6314,
      longitude: 48.6386,
      timezone: 'Asia/Baku',
    ),
  ];

  static CityLocation? getCityByName(String name) {
    try {
      return cities.firstWhere((city) => city.name == name);
    } catch (e) {
      return null;
    }
  }
}
