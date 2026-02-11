import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// Location Model
class CityLocation {
  final String name;
  final String country;
  final double latitude;
  final double longitude;
  final String timezone;
  final bool isGpsLocation; // GPS və ya xəritədən seçilib?

  CityLocation({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    this.isGpsLocation = false,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'country': country,
    'latitude': latitude,
    'longitude': longitude,
    'timezone': timezone,
    'isGpsLocation': isGpsLocation,
  };

  factory CityLocation.fromJson(Map<String, dynamic> json) {
    return CityLocation(
      name: json['name'],
      country: json['country'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      timezone: json['timezone'],
      isGpsLocation: json['isGpsLocation'] ?? false,
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

// Location Service
class LocationService {
  static const String _locationKey = 'saved_location';

  // Kaydedilmiş konumu al
  Future<CityLocation?> getSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final locationJson = prefs.getString(_locationKey);

    if (locationJson != null) {
      return CityLocation.fromJson(jsonDecode(locationJson));
    }

    return null;
  }

  // Konumu kaydet
  Future<void> saveLocation(CityLocation location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_locationKey, jsonEncode(location.toJson()));
  }

  // Reverse Geocoding - Koordinatlardan şehir adı al
  Future<String> _getCityNameFromCoordinates(double latitude, double longitude) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
            '?format=json'
            '&lat=$latitude'
            '&lon=$longitude'
            '&zoom=10'
            '&accept-language=az',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'NamazVaktiApp/1.0'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Şehir, kasaba veya köy adını al
        String? cityName = data['address']?['city'] ??
            data['address']?['town'] ??
            data['address']?['village'] ??
            data['address']?['municipality'] ??
            data['address']?['county'];

        if (cityName != null) {
          return cityName;
        }
      }
    } catch (e) {
      print('Reverse geocoding xətası: $e');
    }

    // Eğer API çalışmazsa koordinatları göster
    return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
  }

  // GPS ile konum al - TAM KOORDINATLARLA
  Future<CityLocation?> getCurrentLocation() async {
    try {
      // Konum izni kontrolü
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Mövqe xidməti bağlıdır');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Mövqe icazəsi rədd edildi');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Mövqe icazəsi daimi olaraq rədd edilib');
        return null;
      }

      // Mevcut pozisyonu al
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      print('GPS Koordinatları: ${position.latitude}, ${position.longitude}');

      // Şehir adını al (görüntüleme için)
      String cityName = await _getCityNameFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // GPS konumunu döndür
      return CityLocation(
        name: 'GPS: $cityName',
        country: 'Azerbaijan',
        latitude: position.latitude,
        longitude: position.longitude,
        timezone: 'Asia/Baku',
        isGpsLocation: true,
      );

    } catch (e) {
      print('Mövqe xətası: $e');
      return null;
    }
  }

  // En yakın şehri bul (kullanılmıyor artık - ama yedek olarak var)
  CityLocation findNearestCity(double latitude, double longitude) {
    CityLocation? nearest;
    double minDistance = double.infinity;

    for (var city in AzerbaijanCities.cities) {
      double distance = Geolocator.distanceBetween(
        latitude,
        longitude,
        city.latitude,
        city.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearest = city;
      }
    }

    return nearest ?? AzerbaijanCities.cities.first;
  }
}