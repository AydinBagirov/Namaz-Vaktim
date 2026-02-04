import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/PrayerModels.dart';

class PrayerService {
  final String city;
  final String country;

  PrayerService({required this.city, required this.country});

  Future<PrayerTimeResponse?> fetchPrayerTimes() async {
    final url = Uri.parse(
        'https://api.aladhan.com/v1/timingsByCity?city=$city&country=$country&method=13');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return PrayerTimeResponse.fromJson(jsonData);
    } else {
      print('API hatası: ${response.statusCode}');
      return null;
    }
  }
}
