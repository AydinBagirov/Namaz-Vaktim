import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CityLocation {
  final String name;
  final String country;
  final double latitude;
  final double longitude;
  final String timezone;
  final bool isGpsLocation;

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
      name: json['name'] ?? '',
      country: json['country'] ?? 'Azerbaijan',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      timezone: json['timezone'] ?? 'Asia/Baku',
      isGpsLocation: json['isGpsLocation'] ?? false,
    );
  }
}

class AzerbaijanCities {
  static final List<CityLocation> cities = [
    CityLocation(name: 'Bakı', country: 'Azerbaijan', latitude: 40.4093, longitude: 49.8671, timezone: 'Asia/Baku'),
    CityLocation(name: 'Sumqayıt', country: 'Azerbaijan', latitude: 40.5855, longitude: 49.6317, timezone: 'Asia/Baku'),
    CityLocation(name: 'Gəncə', country: 'Azerbaijan', latitude: 40.6828, longitude: 46.3606, timezone: 'Asia/Baku'),
    CityLocation(name: 'Mingəçevir', country: 'Azerbaijan', latitude: 40.7703, longitude: 47.0595, timezone: 'Asia/Baku'),
    CityLocation(name: 'Şirvan', country: 'Azerbaijan', latitude: 39.9378, longitude: 48.9290, timezone: 'Asia/Baku'),
    CityLocation(name: 'Abşeron', country: 'Azerbaijan', latitude: 40.4500, longitude: 49.7500, timezone: 'Asia/Baku'),
    CityLocation(name: 'Ağcabədi', country: 'Azerbaijan', latitude: 40.0502, longitude: 47.4594, timezone: 'Asia/Baku'),
    CityLocation(name: 'Ağdam', country: 'Azerbaijan', latitude: 39.9935, longitude: 46.9274, timezone: 'Asia/Baku'),
    CityLocation(name: 'Ağdaş', country: 'Azerbaijan', latitude: 40.6469, longitude: 47.4738, timezone: 'Asia/Baku'),
    CityLocation(name: 'Ağstafa', country: 'Azerbaijan', latitude: 41.1189, longitude: 45.4539, timezone: 'Asia/Baku'),
    CityLocation(name: 'Ağsu', country: 'Azerbaijan', latitude: 40.5692, longitude: 48.4009, timezone: 'Asia/Baku'),
    CityLocation(name: 'Astara', country: 'Azerbaijan', latitude: 38.4559, longitude: 48.8750, timezone: 'Asia/Baku'),
    CityLocation(name: 'Balakən', country: 'Azerbaijan', latitude: 41.7263, longitude: 46.4048, timezone: 'Asia/Baku'),
    CityLocation(name: 'Bərdə', country: 'Azerbaijan', latitude: 40.3758, longitude: 47.1263, timezone: 'Asia/Baku'),
    CityLocation(name: 'Beyləqan', country: 'Azerbaijan', latitude: 39.7740, longitude: 47.6186, timezone: 'Asia/Baku'),
    CityLocation(name: 'Biləsuvar', country: 'Azerbaijan', latitude: 39.4599, longitude: 48.5450, timezone: 'Asia/Baku'),
    CityLocation(name: 'Cəlilabad', country: 'Azerbaijan', latitude: 39.2096, longitude: 48.4919, timezone: 'Asia/Baku'),
    CityLocation(name: 'Daşkəsən', country: 'Azerbaijan', latitude: 40.5202, longitude: 46.0779, timezone: 'Asia/Baku'),
    CityLocation(name: 'Füzuli', country: 'Azerbaijan', latitude: 39.6009, longitude: 47.1453, timezone: 'Asia/Baku'),
    CityLocation(name: 'Gədəbəy', country: 'Azerbaijan', latitude: 40.5698, longitude: 45.8123, timezone: 'Asia/Baku'),
    CityLocation(name: 'Goranboy', country: 'Azerbaijan', latitude: 40.6103, longitude: 46.7897, timezone: 'Asia/Baku'),
    CityLocation(name: 'Göyçay', country: 'Azerbaijan', latitude: 40.6506, longitude: 47.7420, timezone: 'Asia/Baku'),
    CityLocation(name: 'Göygöl', country: 'Azerbaijan', latitude: 40.5858, longitude: 46.3189, timezone: 'Asia/Baku'),
    CityLocation(name: 'Hacıqabul', country: 'Azerbaijan', latitude: 40.0404, longitude: 48.9423, timezone: 'Asia/Baku'),
    CityLocation(name: 'İmişli', country: 'Azerbaijan', latitude: 39.8709, longitude: 48.0606, timezone: 'Asia/Baku'),
    CityLocation(name: 'İsmayıllı', country: 'Azerbaijan', latitude: 40.7849, longitude: 48.1514, timezone: 'Asia/Baku'),
    CityLocation(name: 'Kəlbəcər', country: 'Azerbaijan', latitude: 40.1094, longitude: 46.0445, timezone: 'Asia/Baku'),
    CityLocation(name: 'Kürdəmir', country: 'Azerbaijan', latitude: 40.3453, longitude: 48.1509, timezone: 'Asia/Baku'),
    CityLocation(name: 'Laçın', country: 'Azerbaijan', latitude: 39.6383, longitude: 46.5461, timezone: 'Asia/Baku'),
    CityLocation(name: 'Lerik', country: 'Azerbaijan', latitude: 38.7739, longitude: 48.4149, timezone: 'Asia/Baku'),
    CityLocation(name: 'Lənkəran', country: 'Azerbaijan', latitude: 38.7543, longitude: 48.8506, timezone: 'Asia/Baku'),
    CityLocation(name: 'Masallı', country: 'Azerbaijan', latitude: 39.0343, longitude: 48.6654, timezone: 'Asia/Baku'),
    CityLocation(name: 'Naxçıvan', country: 'Azerbaijan', latitude: 39.2089, longitude: 45.4122, timezone: 'Asia/Baku'),
    CityLocation(name: 'Naftalan', country: 'Azerbaijan', latitude: 40.5082, longitude: 46.8189, timezone: 'Asia/Baku'),
    CityLocation(name: 'Neftçala', country: 'Azerbaijan', latitude: 39.3768, longitude: 49.2470, timezone: 'Asia/Baku'),
    CityLocation(name: 'Oğuz', country: 'Azerbaijan', latitude: 41.0713, longitude: 47.4653, timezone: 'Asia/Baku'),
    CityLocation(name: 'Ordubad', country: 'Azerbaijan', latitude: 38.9096, longitude: 46.0227, timezone: 'Asia/Baku'),
    CityLocation(name: 'Qax', country: 'Azerbaijan', latitude: 41.4183, longitude: 46.9204, timezone: 'Asia/Baku'),
    CityLocation(name: 'Qazax', country: 'Azerbaijan', latitude: 41.0925, longitude: 45.3656, timezone: 'Asia/Baku'),
    CityLocation(name: 'Qəbələ', country: 'Azerbaijan', latitude: 40.9814, longitude: 47.8450, timezone: 'Asia/Baku'),
    CityLocation(name: 'Qobustan', country: 'Azerbaijan', latitude: 40.0824, longitude: 48.9340, timezone: 'Asia/Baku'),
    CityLocation(name: 'Quba', country: 'Azerbaijan', latitude: 41.3611, longitude: 48.5134, timezone: 'Asia/Baku'),
    CityLocation(name: 'Qubadlı', country: 'Azerbaijan', latitude: 39.3444, longitude: 46.5819, timezone: 'Asia/Baku'),
    CityLocation(name: 'Qusar', country: 'Azerbaijan', latitude: 41.4267, longitude: 48.4302, timezone: 'Asia/Baku'),
    CityLocation(name: 'Saatlı', country: 'Azerbaijan', latitude: 39.9321, longitude: 48.3686, timezone: 'Asia/Baku'),
    CityLocation(name: 'Sabirabad', country: 'Azerbaijan', latitude: 39.9873, longitude: 48.4695, timezone: 'Asia/Baku'),
    CityLocation(name: 'Salyan', country: 'Azerbaijan', latitude: 39.5962, longitude: 48.9848, timezone: 'Asia/Baku'),
    CityLocation(name: 'Samux', country: 'Azerbaijan', latitude: 40.7649, longitude: 46.4083, timezone: 'Asia/Baku'),
    CityLocation(name: 'Siyəzən', country: 'Azerbaijan', latitude: 41.0784, longitude: 49.1110, timezone: 'Asia/Baku'),
    CityLocation(name: 'Şabran', country: 'Azerbaijan', latitude: 41.2204, longitude: 48.9886, timezone: 'Asia/Baku'),
    CityLocation(name: 'Şahbuz', country: 'Azerbaijan', latitude: 39.4072, longitude: 45.5739, timezone: 'Asia/Baku'),
    CityLocation(name: 'Şamaxı', country: 'Azerbaijan', latitude: 40.6314, longitude: 48.6386, timezone: 'Asia/Baku'),
    CityLocation(name: 'Şəki', country: 'Azerbaijan', latitude: 41.1919, longitude: 47.1706, timezone: 'Asia/Baku'),
    CityLocation(name: 'Şəmkir', country: 'Azerbaijan', latitude: 40.8298, longitude: 46.0178, timezone: 'Asia/Baku'),
    CityLocation(name: 'Şərur', country: 'Azerbaijan', latitude: 39.5520, longitude: 44.9799, timezone: 'Asia/Baku'),
    CityLocation(name: 'Tərtər', country: 'Azerbaijan', latitude: 40.3420, longitude: 46.9320, timezone: 'Asia/Baku'),
    CityLocation(name: 'Tovuz', country: 'Azerbaijan', latitude: 40.9952, longitude: 45.6166, timezone: 'Asia/Baku'),
    CityLocation(name: 'Ucar', country: 'Azerbaijan', latitude: 40.5190, longitude: 47.6542, timezone: 'Asia/Baku'),
    CityLocation(name: 'Yardımlı', country: 'Azerbaijan', latitude: 38.9059, longitude: 48.2405, timezone: 'Asia/Baku'),
    CityLocation(name: 'Yevlax', country: 'Azerbaijan', latitude: 40.6172, longitude: 47.1501, timezone: 'Asia/Baku'),
    CityLocation(name: 'Zaqatala', country: 'Azerbaijan', latitude: 41.6316, longitude: 46.6433, timezone: 'Asia/Baku'),
    CityLocation(name: 'Zəngilan', country: 'Azerbaijan', latitude: 39.0853, longitude: 46.6525, timezone: 'Asia/Baku'),
    CityLocation(name: 'Zərdab', country: 'Azerbaijan', latitude: 40.2184, longitude: 47.7121, timezone: 'Asia/Baku'),

  ];


  static CityLocation? getCityByName(String name) {
    try {
      return cities.firstWhere((city) => city.name == name);
    } catch (e) {
      return null;
    }
  }
}

class LocationService {
  static const String _locationKey = 'saved_location';

  Future<CityLocation?> getSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationJson = prefs.getString(_locationKey);

      if (locationJson != null) {
        return CityLocation.fromJson(jsonDecode(locationJson));
      }
    } catch (e) {
      print('Saxlanmış mövqe oxuma xətası: $e');
    }

    return null;
  }

  Future<void> saveLocation(CityLocation location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_locationKey, jsonEncode(location.toJson()));
      print('✅ Mövqe saxlanıldı: ${location.name}');
    } catch (e) {
      print('❌ Mövqe saxlama xətası: $e');
    }
  }

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
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Zaman aşımı');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        String? cityName = data['address']?['city'] ??
            data['address']?['town'] ??
            data['address']?['village'] ??
            data['address']?['municipality'] ??
            data['address']?['county'];

        if (cityName != null && cityName.isNotEmpty) {
          return cityName;
        }
      }
    } catch (e) {
      print('Reverse geocoding xətası: $e');
    }

    return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
  }

  Future<CityLocation?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('⚠️ Mövqe xidməti bağlıdır');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('⚠️ Mövqe icazəsi rədd edildi');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('⚠️ Mövqe icazəsi daimi olaraq rədd edilib');
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      print('📍 GPS Koordinatları: ${position.latitude}, ${position.longitude}');

      String cityName = await _getCityNameFromCoordinates(
        position.latitude,
        position.longitude,
      );

      return CityLocation(
        name: 'GPS: $cityName',
        country: 'Azerbaijan',
        latitude: position.latitude,
        longitude: position.longitude,
        timezone: 'Asia/Baku',
        isGpsLocation: true,
      );

    } catch (e) {
      print('❌ Mövqe xətası: $e');
      return null;
    }
  }

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