import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/PrayerModels.dart';

class PrayerService {
  final String city;
  final String country;

  PrayerService({required this.city, required this.country});

  Future<void> _savePrayerTimesToFile(Map<String, dynamic> jsonData) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/namaz_vakitleri.json');
    await file.writeAsString(jsonEncode(jsonData));
  }

  Future<Map<String, dynamic>?> _readPrayerTimesFromFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/namaz_vakitleri.json');
    if (await file.exists()) {
      final content = await file.readAsString();
      return jsonDecode(content);
    } else {
      return null;
    }
  }

  Future<PrayerTimeResponse?> _fetchFromApi() async {
    final url = Uri.parse(
        'https://api.aladhan.com/v1/timingsByCity?city=$city&country=$country&method=13');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      // JSON'u kaydet
      await _savePrayerTimesToFile(jsonData);
      return PrayerTimeResponse.fromJson(jsonData);
    } else {
      print('API hatası: ${response.statusCode}');
      return null;
    }
  }

  Future<PrayerTimeResponse?> getPrayerTimes() async {
    final fileData = await _readPrayerTimesFromFile();

    if (fileData != null) {
      try {
        return PrayerTimeResponse.fromJson(fileData);
      } catch (e) {
        return await _fetchFromApi();
      }
    } else {
      return await _fetchFromApi();
    }
  }
}
