import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'location_model.dart';

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

  // GPS ile konum al
  Future<CityLocation?> getCurrentLocation() async {
    try {
      // Konum izni kontrolü
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Mevcut pozisyonu al
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return CityLocation(
        name: 'Cari Mövqe',
        country: 'Azerbaijan',
        latitude: position.latitude,
        longitude: position.longitude,
        timezone: 'Asia/Baku',
      );
    } catch (e) {
      print('Konum hatası: $e');
      return null;
    }
  }

  // En yakın şehri bul
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
