import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../location/location_service.dart';

class ImsakiyePage extends StatefulWidget {
  final CityLocation? location;

  const ImsakiyePage({super.key, this.location});

  @override
  State<ImsakiyePage> createState() => _ImsakiyePageState();
}

class _ImsakiyePageState extends State<ImsakiyePage> {
  CityLocation? currentLocation;
  bool loading = true;
  List<DailyPrayerTime> monthlyPrayerTimes = [];
  final DateTime currentMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    if (!mounted) return;
    if (widget.location != null) {
      setState(() { currentLocation = widget.location; });
      await _loadMonthlyPrayerTimes();
    } else {
      final locationService = LocationService();
      final savedLocation = await locationService.getSavedLocation();
      if (!mounted) return;
      setState(() { currentLocation = savedLocation ?? AzerbaijanCities.cities.first; });
      await _loadMonthlyPrayerTimes();
    }
  }

  String _getCacheKey() =>
      '${currentLocation!.latitude}_${currentLocation!.longitude}_${currentMonth.month}_${currentMonth.year}';

  Future<List<DailyPrayerTime>?> _readFromCache() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/imsakiye_cache.json');
      if (!await file.exists()) return null;
      final content = await file.readAsString();
      final cache = jsonDecode(content) as Map<String, dynamic>;
      final cacheKey = _getCacheKey();
      if (cache.containsKey(cacheKey)) {
        final List<dynamic> data = cache[cacheKey];
        return data.map((item) => DailyPrayerTime.fromJson(item)).toList();
      }
    } catch (e) { print('Cache okuma hatası: $e'); }
    return null;
  }

  Future<void> _writeToCache(List<DailyPrayerTime> times) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/imsakiye_cache.json');
      Map<String, dynamic> cache = {};
      if (await file.exists()) {
        try { cache = jsonDecode(await file.readAsString()); } catch (_) {}
      }
      cache[_getCacheKey()] = times.map((t) => t.toJson()).toList();
      await file.writeAsString(jsonEncode(cache));
    } catch (e) { print('Cache yazma hatası: $e'); }
  }

  Future<void> _loadMonthlyPrayerTimes() async {
    if (currentLocation == null || !mounted) return;
    setState(() => loading = true);

    final cachedData = await _readFromCache();
    if (cachedData != null && cachedData.isNotEmpty) {
      if (mounted) setState(() { monthlyPrayerTimes = cachedData; loading = false; });
      return;
    }

    final url = Uri.parse(
      'https://api.aladhan.com/v1/calendar/${currentMonth.year}/${currentMonth.month}'
          '?latitude=${currentLocation!.latitude}&longitude=${currentLocation!.longitude}'
          '&method=13&timezonestring=${currentLocation!.timezone}',
    );

    try {
      final response = await http.get(url);
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<DailyPrayerTime> times = [];
        for (var dayData in data['data']) {
          try {
            final timings = dayData['timings'];
            final date = dayData['date']['gregorian'];
            times.add(DailyPrayerTime(
              date: DateTime(int.parse(date['year'].toString()),
                  int.parse(date['month']['number'].toString()), int.parse(date['day'].toString())),
              imsak: _adjustTime(timings['Imsak'].toString(), 10),
              sunrise: _cleanTime(timings['Sunrise'].toString()),
              dhuhr: _cleanTime(timings['Dhuhr'].toString()),
              asr: _cleanTime(timings['Asr'].toString()),
              maghrib: _cleanTime(timings['Maghrib'].toString()),
              isha: _cleanTime(timings['Isha'].toString()),
            ));
          } catch (e) { print('Gün verisi parse hatası: $e'); }
        }
        await _writeToCache(times);
        if (mounted) setState(() { monthlyPrayerTimes = times; loading = false; });
      }
    } catch (e) {
      print('API hatası: $e');
      if (mounted) setState(() => loading = false);
    }
  }

  String _cleanTime(String time) {
    if (time.contains(' ')) return time.split(' ')[0].substring(0, 5);
    return time.substring(0, 5);
  }

  String _adjustTime(String time, int minutesToAdd) {
    final cleanedTime = _cleanTime(time);
    final parts = cleanedTime.split(':');
    int totalMinutes = (int.parse(parts[0]) * 60) + int.parse(parts[1]) + minutesToAdd;
    if (totalMinutes >= 1440) totalMinutes -= 1440;
    else if (totalMinutes < 0) totalMinutes += 1440;
    return '${(totalMinutes ~/ 60).toString().padLeft(2, '0')}:${(totalMinutes % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final months = ["", "Yanvar", "Fevral", "Mart", "Aprel", "May", "İyun",
      "İyul", "Avqust", "Sentyabr", "Oktyabr", "Noyabr", "Dekabr"];

    return Scaffold(
      backgroundColor: const Color(0xFF080E1A),
      body: Stack(
        children: [
          Positioned(
            top: -60, right: -40,
            child: Container(width: 200, height: 200,
              decoration: BoxDecoration(shape: BoxShape.circle,
                  gradient: RadialGradient(
                      colors: [const Color(0xFF4ECDC4).withOpacity(0.08), Colors.transparent])),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 20, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white70, size: 20),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("İmsakiyyə",
                              style: TextStyle(fontSize: 18, fontFamily: 'MyFont2',
                                  fontWeight: FontWeight.bold, color: Colors.white)),
                          Text("${months[currentMonth.month]} ${currentMonth.year}",
                              style: const TextStyle(fontSize: 12, fontFamily: 'MyFont2',
                                  color: Color(0xFF4ECDC4))),
                        ],
                      ),
                    ],
                  ),
                ),

                // Column headers
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ECDC4).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF4ECDC4).withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 36),
                      ..._headerLabels(),
                    ],
                  ),
                ),

                // List
                Expanded(
                  child: loading
                      ? const Center(child: CircularProgressIndicator(
                      color: Color(0xFF4ECDC4), strokeWidth: 2))
                      : monthlyPrayerTimes.isEmpty
                      ? const Center(child: Text('Məlumat tapılmadı',
                      style: TextStyle(fontFamily: 'MyFont2', color: Colors.white54)))
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: monthlyPrayerTimes.length,
                    itemBuilder: (context, index) {
                      final dayTime = monthlyPrayerTimes[index];
                      final now = DateTime.now();
                      final isToday = dayTime.date.day == now.day &&
                          dayTime.date.month == now.month &&
                          dayTime.date.year == now.year;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isToday
                              ? const Color(0xFF4ECDC4).withOpacity(0.10)
                              : Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isToday
                                ? const Color(0xFF4ECDC4).withOpacity(0.4)
                                : Colors.white.withOpacity(0.06),
                            width: isToday ? 1.2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 36,
                              child: Text(
                                '${dayTime.date.day}',
                                style: TextStyle(
                                  fontFamily: 'MyFont2',
                                  fontSize: 14,
                                  fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                                  color: isToday ? const Color(0xFF4ECDC4) : Colors.white54,
                                ),
                              ),
                            ),
                            ..._timeCell(dayTime.imsak, isToday),
                            ..._timeCell(dayTime.sunrise, isToday),
                            ..._timeCell(dayTime.dhuhr, isToday),
                            ..._timeCell(dayTime.asr, isToday),
                            ..._timeCell(dayTime.maghrib, isToday),
                            ..._timeCell(dayTime.isha, isToday),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _headerLabels() {
    final labels = ['İmsak', 'Günəş', 'Günorta', 'Əsr', 'Axşam', 'İşa'];
    return labels.map((l) => Expanded(
      child: Text(l, textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'MyFont2', fontSize: 10,
              color: Color(0xFF4ECDC4), letterSpacing: 0.3)),
    )).toList();
  }

  List<Widget> _timeCell(String time, bool isToday) {
    return [
      Expanded(
        child: Text(time, textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'MyFont2', fontSize: 11,
                fontWeight: isToday ? FontWeight.bold : FontWeight.w400,
                color: isToday ? Colors.white : Colors.white54)),
      ),
    ];
  }
}

class DailyPrayerTime {
  final DateTime date;
  final String imsak, sunrise, dhuhr, asr, maghrib, isha;

  DailyPrayerTime({required this.date, required this.imsak, required this.sunrise,
    required this.dhuhr, required this.asr, required this.maghrib, required this.isha});

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(), 'imsak': imsak, 'sunrise': sunrise,
    'dhuhr': dhuhr, 'asr': asr, 'maghrib': maghrib, 'isha': isha,
  };

  factory DailyPrayerTime.fromJson(Map<String, dynamic> json) => DailyPrayerTime(
    date: DateTime.parse(json['date']), imsak: json['imsak'], sunrise: json['sunrise'],
    dhuhr: json['dhuhr'], asr: json['asr'], maghrib: json['maghrib'], isha: json['isha'],
  );
}