import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../location/location_model.dart';
import '../models/PrayerModels.dart';

class PrayerService {
  static const String _fileName = 'namaz_vakitleri.json';

  Future<void> _saveToFile(Map<String, dynamic> jsonData, String cacheKey) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_fileName');

    Map<String, dynamic> cache = {};
    if (await file.exists()) {
      try {
        final content = await file.readAsString();
        cache = jsonDecode(content);
      } catch (_) {}
    }

    cache[cacheKey] = jsonData;
    await file.writeAsString(jsonEncode(cache));
  }

  Future<Map<String, dynamic>?> _readFromFile(String cacheKey) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_fileName');

    if (!await file.exists()) return null;

    try {
      final content = await file.readAsString();
      final cache = jsonDecode(content) as Map<String, dynamic>;
      return cache[cacheKey];
    } catch (_) {
      return null;
    }
  }

  String _getCacheKey(CityLocation location, DateTime date) {
    final dateString =
        "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";

    return "${location.latitude}_${location.longitude}_$dateString";
  }

  Future<PrayerTimeResponse?> _fetchFromApi(CityLocation location, DateTime date) async {
    final dateString =
        "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";

    final url = Uri.parse(
      'https://api.aladhan.com/v1/timings/$dateString'
          '?latitude=${location.latitude}'
          '&longitude=${location.longitude}'
          '&method=13'
          '&timezonestring=${location.timezone}',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final cacheKey = _getCacheKey(location, date);
        await _saveToFile(jsonData, cacheKey);
        return PrayerTimeResponse.fromJson(jsonData);
      }
    } catch (e) {
      print('API hatası: $e');
    }

    return null;
  }

  Future<PrayerTimeResponse?> getPrayerTimes(CityLocation location, DateTime date) async {
    final cacheKey = _getCacheKey(location, date);

    // Önce cache'den bak
    final fileData = await _readFromFile(cacheKey);

    if (fileData != null) {
      try {
        return PrayerTimeResponse.fromJson(fileData);
      } catch (e) {
        print('Cache parse hatası: $e');
        return await _fetchFromApi(location, date);
      }
    }

    // Cache'de yoksa API'den çek
    return await _fetchFromApi(location, date);
  }

  Future<void> clearCache() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_fileName');
    if (await file.exists()) {
      await file.delete();
    }
  }
}