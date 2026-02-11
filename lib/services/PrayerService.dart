import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../location/location_service.dart';
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

  // GPS konumları için yuvarlanmış cache key - internetsiz çalışma için
  String _getCacheKey(CityLocation location, DateTime date) {
    final dateString =
        "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";

    // GPS konumu ise koordinatları 2 ondalık basamağa yuvarla
    // Bu sayede yakın konumlar (~1km) aynı cache'i kullanır
    if (location.isGpsLocation) {
      final roundedLat = (location.latitude * 100).round() / 100;
      final roundedLng = (location.longitude * 100).round() / 100;
      return "gps_${roundedLat}_${roundedLng}_$dateString";
    }

    // Normal şehirler için tam koordinat
    return "city_${location.latitude}_${location.longitude}_$dateString";
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
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Bağlantı zaman aşımına uğradı');
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final cacheKey = _getCacheKey(location, date);
        await _saveToFile(jsonData, cacheKey);
        print('✅ ${date.day}/${date.month} - İndirildi və yadda saxlanıldı');
        return PrayerTimeResponse.fromJson(jsonData);
      }
    } catch (e) {
      print('⚠️ API xətası: $e');
    }

    return null;
  }

  Future<PrayerTimeResponse?> getPrayerTimes(CityLocation location, DateTime date) async {
    final cacheKey = _getCacheKey(location, date);

    // Önce cache'den bak
    final fileData = await _readFromFile(cacheKey);

    if (fileData != null) {
      print('📱 ${date.day}/${date.month} - Offline yaddaşdan');
      try {
        return PrayerTimeResponse.fromJson(fileData);
      } catch (e) {
        print('⚠️ Cache parse xətası: $e');
        return await _fetchFromApi(location, date);
      }
    }

    // Cache'de yoksa API'den çek
    print('🌐 ${date.day}/${date.month} - İnternetdən yüklənir...');
    return await _fetchFromApi(location, date);
  }

  // 30 günlük namaz vakitlerini indir ve kaydet
  Future<void> fetch30DaysPrayerTimes(CityLocation location) async {
    print('📥 30 günlük namaz vaxtları yüklənir...');
    final today = DateTime.now();
    int downloadedCount = 0;
    int cachedCount = 0;

    for (int i = 0; i < 30; i++) {
      final date = today.add(Duration(days: i));
      final cacheKey = _getCacheKey(location, date);

      final cached = await _readFromFile(cacheKey);
      if (cached == null) {
        await _fetchFromApi(location, date);
        downloadedCount++;
        // API rate limit için bekleme
        await Future.delayed(const Duration(milliseconds: 300));
      } else {
        cachedCount++;
      }
    }

    print('✅ 30 günlük məlumat hazırdır:');
    print('   📦 Yaddaşda: $cachedCount gün');
    print('   📥 Yükləndi: $downloadedCount gün');
  }

  // Cache durumunu kontrol et
  Future<Map<String, dynamic>> getCacheStatus(CityLocation location) async {
    final today = DateTime.now();
    int cachedDays = 0;
    int totalDays = 30;

    for (int i = 0; i < totalDays; i++) {
      final date = today.add(Duration(days: i));
      final cacheKey = _getCacheKey(location, date);
      final cached = await _readFromFile(cacheKey);

      if (cached != null) {
        cachedDays++;
      }
    }

    return {
      'cachedDays': cachedDays,
      'totalDays': totalDays,
      'isFullyCached': cachedDays == totalDays,
      'percentage': (cachedDays / totalDays * 100).round(),
    };
  }

  Future<void> clearCache() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_fileName');
    if (await file.exists()) {
      await file.delete();
      print('🗑️ Yaddaş təmizləndi');
    }
  }
}