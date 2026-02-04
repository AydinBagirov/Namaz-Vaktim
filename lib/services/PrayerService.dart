import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../models/PrayerModels.dart';

class PrayerService {
  static const String _fileName = 'namaz_vakitleri.json';

  Future<void> _saveToFile(Map<String, dynamic> jsonData) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_fileName');
    await file.writeAsString(jsonEncode(jsonData));
  }
  Future<Map<String, dynamic>?> _readFromFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_fileName');

    if (!await file.exists()) return null;

    final content = await file.readAsString();
    return jsonDecode(content);
  }

  Future<PrayerTimeResponse?> _fetchFromApi(DateTime date) async {
    final dateString =
        "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";

    final url = Uri.parse(
      'https://api.aladhan.com/v1/timings/$dateString'
          '?latitude=40.7128'
          '&longitude=-74.0060'
          '&method=13'
          '&timezonestring=Asia/Baku',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      await _saveToFile(jsonData);
      return PrayerTimeResponse.fromJson(jsonData);
    }

    return null;
  }

  Future<PrayerTimeResponse?> getPrayerTimes(DateTime date) async {
    final fileData = await _readFromFile();

    if (fileData != null) {
      try {
        return PrayerTimeResponse.fromJson(fileData);
      } catch (_) {
        return await _fetchFromApi(date);
      }
    }

    return await _fetchFromApi(date);
  }
}
