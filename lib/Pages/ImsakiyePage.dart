import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../location/location_service.dart';
import 'HomePage.dart';

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
      setState(() {
        currentLocation = widget.location;
      });
      await _loadMonthlyPrayerTimes();
    } else {
      final locationService = LocationService();
      final savedLocation = await locationService.getSavedLocation();

      if (!mounted) return;

      setState(() {
        currentLocation = savedLocation ?? AzerbaijanCities.cities.first;
      });
      await _loadMonthlyPrayerTimes();
    }
  }

  String _getCacheKey() {
    return '${currentLocation!.latitude}_${currentLocation!.longitude}_'
        '${currentMonth.month}_${currentMonth.year}';
  }

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
    } catch (e) {
      print('Cache okuma hatası: $e');
    }
    return null;
  }

  Future<void> _writeToCache(List<DailyPrayerTime> times) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/imsakiye_cache.json');

      Map<String, dynamic> cache = {};
      if (await file.exists()) {
        try {
          final content = await file.readAsString();
          cache = jsonDecode(content);
        } catch (_) {}
      }

      final cacheKey = _getCacheKey();
      cache[cacheKey] = times.map((t) => t.toJson()).toList();

      await file.writeAsString(jsonEncode(cache));
      print('İmsakiye cache\'e kaydedildi: $cacheKey');
    } catch (e) {
      print('Cache yazma hatası: $e');
    }
  }

  Future<void> _loadMonthlyPrayerTimes() async {
    if (currentLocation == null || !mounted) return;

    if (mounted) {
      setState(() => loading = true);
    }

    // ÖNCE CACHE'DEN DENE
    final cachedData = await _readFromCache();
    if (cachedData != null && cachedData.isNotEmpty) {
      if (mounted) {
        setState(() {
          monthlyPrayerTimes = cachedData;
          loading = false;
        });
      }
      print('İmsakiye cache\'den yüklendi');
      return;
    }

    // CACHE YOKSA API'DEN ÇEK
    final year = currentMonth.year;
    final month = currentMonth.month;

    final url = Uri.parse(
      'https://api.aladhan.com/v1/calendar/$year/$month'
          '?latitude=${currentLocation!.latitude}'
          '&longitude=${currentLocation!.longitude}'
          '&method=13'
          '&timezonestring=${currentLocation!.timezone}',
    );

    try {
      final response = await http.get(url);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> daysData = data['data'];

        final List<DailyPrayerTime> times = [];

        for (var dayData in daysData) {
          try {
            final timings = dayData['timings'];
            final date = dayData['date']['gregorian'];

            times.add(DailyPrayerTime(
              date: DateTime(
                int.parse(date['year'].toString()),
                int.parse(date['month']['number'].toString()),
                int.parse(date['day'].toString()),
              ),
              imsak: _adjustTime(timings['Imsak'].toString(), 10), // 10 dakika ekle
              sunrise: _cleanTime(timings['Sunrise'].toString()),
              dhuhr: _cleanTime(timings['Dhuhr'].toString()),
              asr: _cleanTime(timings['Asr'].toString()),
              maghrib: _cleanTime(timings['Maghrib'].toString()),
              isha: _cleanTime(timings['Isha'].toString()),
            ));
          } catch (e) {
            print('Gün verisi parse hatası: $e');
          }
        }

        // CACHE'E KAYDET
        await _writeToCache(times);

        if (mounted) {
          setState(() {
            monthlyPrayerTimes = times;
            loading = false;
          });
        }
      }
    } catch (e) {
      print('API hatası: $e');
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  String _cleanTime(String time) {
    if (time.contains(' ')) {
      return time.split(' ')[0].substring(0, 5);
    }
    return time.substring(0, 5);
  }

  // Vakti belirli dakika kadar ayarla
  String _adjustTime(String time, int minutesToAdd) {
    final cleanedTime = _cleanTime(time);
    final parts = cleanedTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    // Toplam dakikayı hesapla
    int totalMinutes = (hour * 60) + minute + minutesToAdd;

    // Gün aşımı kontrolü (1440 dakika = 24 saat)
    if (totalMinutes >= 1440) {
      totalMinutes -= 1440;
    } else if (totalMinutes < 0) {
      totalMinutes += 1440;
    }

    // Yeni saat ve dakikayı hesapla
    final newHour = (totalMinutes ~/ 60).toString().padLeft(2, '0');
    final newMinute = (totalMinutes % 60).toString().padLeft(2, '0');

    return '$newHour:$newMinute';
  }

  @override
  Widget build(BuildContext context) {
    final months = [
      "", "Yanvar", "Fevral", "Mart", "Aprel", "May", "İyun",
      "İyul", "Avqust", "Sentyabr", "Oktyabr", "Noyabr", "Dekabr"
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'İmsakiyyə - ${currentLocation?.name ?? ""}',
          style: const TextStyle(fontFamily: 'MyFont2', color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '${months[currentMonth.month]} ${currentMonth.year}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'MyFont2',
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: loading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Yüklənir...',
              style: TextStyle(fontFamily: 'MyFont2'),
            ),
          ],
        ),
      )
          : monthlyPrayerTimes.isEmpty
          ? const Center(
        child: Text(
          'Məlumat tapılmadı',
          style: TextStyle(fontFamily: 'MyFont2'),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: monthlyPrayerTimes.length,
        itemBuilder: (context, index) {
          final dayTime = monthlyPrayerTimes[index];
          final now = DateTime.now();
          final isToday = dayTime.date.day == now.day &&
              dayTime.date.month == now.month &&
              dayTime.date.year == now.year;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            elevation: isToday ? 4 : 1,
            color: isToday ? Colors.teal.shade50 : null,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${dayTime.date.day}.${dayTime.date.month}.${dayTime.date.year}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontFamily: 'MyFont2',
                      color: isToday ? Colors.teal.shade700 : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTimeColumn('İmsak', dayTime.imsak),
                      _buildTimeColumn('Günəş', dayTime.sunrise),
                      _buildTimeColumn('Günorta', dayTime.dhuhr),
                      _buildTimeColumn('Əsr', dayTime.asr),
                      _buildTimeColumn('Axşam', dayTime.maghrib),
                      _buildTimeColumn('İşa', dayTime.isha),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeColumn(String name, String time) {
    return Column(
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
            fontFamily: 'MyFont2',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          time,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFamily: 'MyFont2',
          ),
        ),
      ],
    );
  }
}

class DailyPrayerTime {
  final DateTime date;
  final String imsak;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  DailyPrayerTime({
    required this.date,
    required this.imsak,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'imsak': imsak,
    'sunrise': sunrise,
    'dhuhr': dhuhr,
    'asr': asr,
    'maghrib': maghrib,
    'isha': isha,
  };

  factory DailyPrayerTime.fromJson(Map<String, dynamic> json) {
    return DailyPrayerTime(
      date: DateTime.parse(json['date']),
      imsak: json['imsak'],
      sunrise: json['sunrise'],
      dhuhr: json['dhuhr'],
      asr: json['asr'],
      maghrib: json['maghrib'],
      isha: json['isha'],
    );
  }
}