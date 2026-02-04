import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hijri_date/hijri.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Location Model
class CityLocation {
  final String name;
  final String country;
  final double latitude;
  final double longitude;
  final String timezone;

  CityLocation({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'country': country,
    'latitude': latitude,
    'longitude': longitude,
    'timezone': timezone,
  };

  factory CityLocation.fromJson(Map<String, dynamic> json) {
    return CityLocation(
      name: json['name'],
      country: json['country'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      timezone: json['timezone'],
    );
  }
}

// Azerbaycan şehirleri
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
    CityLocation(
      name: 'Şirvan',
      country: 'Azerbaijan',
      latitude: 39.9369,
      longitude: 48.9208,
      timezone: 'Asia/Baku',
    ),
  ];
}

// Location Service
class LocationService {
  static const String _locationKey = 'saved_location';

  Future<CityLocation?> getSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final locationJson = prefs.getString(_locationKey);

    if (locationJson != null) {
      return CityLocation.fromJson(jsonDecode(locationJson));
    }

    return null;
  }

  Future<void> saveLocation(CityLocation location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_locationKey, jsonEncode(location.toJson()));
  }
}

// Prayer Models
class PrayerTimeResponse {
  final PrayerData data;
  PrayerTimeResponse({required this.data});

  factory PrayerTimeResponse.fromJson(Map<String, dynamic> json) {
    return PrayerTimeResponse(
      data: PrayerData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() => {
    'data': data.toJson(),
  };
}

class PrayerData {
  final Timings timings;
  PrayerData({required this.timings});

  factory PrayerData.fromJson(Map<String, dynamic> json) {
    return PrayerData(
      timings: Timings.fromJson(json['timings']),
    );
  }

  Map<String, dynamic> toJson() => {
    'timings': timings.toJson(),
  };
}

class Timings {
  final String imsak;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  Timings({
    required this.imsak,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  factory Timings.fromJson(Map<String, dynamic> json) {
    return Timings(
      imsak: json['Imsak'],
      sunrise: json['Sunrise'],
      dhuhr: json['Dhuhr'],
      asr: json['Asr'],
      maghrib: json['Maghrib'],
      isha: json['Isha'],
    );
  }

  Map<String, dynamic> toJson() => {
    'Imsak': imsak,
    'Sunrise': sunrise,
    'Dhuhr': dhuhr,
    'Asr': asr,
    'Maghrib': maghrib,
    'Isha': isha,
  };
}

// Prayer Service - Güncellenmiş
class PrayerService {
  Future<void> _saveToFile(Map<String, dynamic> jsonData, String cacheKey) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/namaz_vakitleri.json');

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
    final file = File('${dir.path}/namaz_vakitleri.json');

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

    final fileData = await _readFromFile(cacheKey);

    if (fileData != null) {
      try {
        return PrayerTimeResponse.fromJson(fileData);
      } catch (e) {
        return await _fetchFromApi(location, date);
      }
    }

    return await _fetchFromApi(location, date);
  }
}

// City Selection Dialog
class CitySelectionDialog extends StatelessWidget {
  final Function(CityLocation) onCitySelected;

  const CitySelectionDialog({
    super.key,
    required this.onCitySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Şəhər Seçin',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'MyFont2',
              ),
            ),
            const SizedBox(height: 20),

            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: AzerbaijanCities.cities.length,
                itemBuilder: (context, index) {
                  final city = AzerbaijanCities.cities[index];
                  return ListTile(
                    leading: const Icon(Icons.location_city, color: Colors.teal),
                    title: Text(
                      city.name,
                      style: const TextStyle(fontFamily: 'MyFont2'),
                    ),
                    onTap: () {
                      onCitySelected(city);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// HomePage - Güncellenmiş
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PrayerTimeResponse? prayerTimes;
  bool loading = true;
  Duration? kalanSure;
  late final Ticker _ticker;
  CityLocation? currentLocation;
  String? sonrakiVakitAdi;

  final now = DateTime.now();
  final months = [
    "", "Yanvar", "Fevral", "Mart", "Aprel", "May", "İyun", "İyul",
    "Avqust", "Sentyabr", "Oktyabr", "Noyabr", "Dekabr"
  ];
  final days = [
    "", "Bazarertəsi", "Çərşənbə axşamı", "Çərşənbə", "Cümə axşamı",
    "Cümə", "Şənbə", "Bazar"
  ];

  @override
  void initState() {
    super.initState();
    _initializeLocation();

    _ticker = Ticker((_) {
      hesaplaKalanSure();
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    final locationService = LocationService();

    CityLocation? savedLocation = await locationService.getSavedLocation();

    if (savedLocation == null) {
      // Varsayılan olarak Bakı
      savedLocation = AzerbaijanCities.cities.first;
      await locationService.saveLocation(savedLocation);
    }

    setState(() {
      currentLocation = savedLocation;
    });

    loadPrayerTimes();
  }

  void loadPrayerTimes() async {
    if (currentLocation == null) return;

    setState(() => loading = true);

    final service = PrayerService();
    final data = await service.getPrayerTimes(currentLocation!, DateTime.now());

    setState(() {
      prayerTimes = data;
      loading = false;
    });

    hesaplaKalanSure();
  }

  void hesaplaKalanSure() {
    if (prayerTimes == null) return;

    final now = DateTime.now();
    final t = prayerTimes!.data.timings;

    final vakitler = {
      'İmsak': _parseTime(t.imsak),
      'Günəş': _parseTime(t.sunrise),
      'Günorta': _parseTime(t.dhuhr),
      'Əsr': _parseTime(t.asr),
      'Axşam': _parseTime(t.maghrib),
      'İşa': _parseTime(t.isha),
    };

    DateTime? sonrakiVakit;
    String? sonrakiAd;

    for (final entry in vakitler.entries) {
      if (entry.value.isAfter(now)) {
        sonrakiVakit = entry.value;
        sonrakiAd = entry.key;
        break;
      }
    }

    if (sonrakiVakit == null) {
      sonrakiVakit = vakitler.values.first.add(const Duration(days: 1));
      sonrakiAd = vakitler.keys.first;
    }

    setState(() {
      kalanSure = sonrakiVakit!.difference(now);
      sonrakiVakitAdi = sonrakiAd;
    });
  }

  DateTime _parseTime(String time) {
    final now = DateTime.now();
    final parts = time.split(':');
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  Future<void> _showCitySelection() async {
    showDialog(
      context: context,
      builder: (context) => CitySelectionDialog(
        onCitySelected: (city) async {
          setState(() {
            currentLocation = city;
          });

          final locationService = LocationService();
          await locationService.saveLocation(city);

          loadPrayerTimes();
        },
      ),
    );
  }

  Widget ozelCard(String ad, String resim, String saat) {
    return SizedBox(
        height: 60,
        width: 600,
        child: Card(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 11, right: 13),
                child: Image.asset(resim, width: 40, height: 40,),
              ),
              Text(ad, style: const TextStyle(fontSize: 15, fontFamily: 'MyFont2'),),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Text(saat, style: const TextStyle(fontSize: 15, fontFamily: 'MyFont2'),),
              )
            ],
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    HijriDate.setLocal('tr');

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 44.0, left: 11, right: 11),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                    width: 45,
                    height: 45,
                    child: Image.asset("assets/images/AppLogo.png")
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                          "Əssələmu Aleykum",
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                              fontFamily: 'MyFont2'
                          )
                      ),
                      Text(
                          currentLocation?.name ?? "Yüklənir...",
                          style: const TextStyle(
                            fontSize: 15,
                            fontFamily: 'MyFont2',
                            fontWeight: FontWeight.bold,
                          )
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _showCitySelection,
                  icon: const Icon(Icons.location_on_outlined),
                  tooltip: 'Şəhər dəyiş',
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: SizedBox(
                width: 470,
                height: 180,
                child: Card(
                  color: Colors.teal,
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      Text(
                          "${sonrakiVakitAdi ?? 'Yüklənir'}a qədər: ",
                          style: const TextStyle(
                              fontSize: 20,
                              fontFamily: 'MyFont2',
                              color: Colors.white
                          )
                      ),
                      const SizedBox(height: 5),
                      Text(
                        kalanSure == null
                            ? "--:--:--"
                            : "${kalanSure!.inHours.toString().padLeft(2, '0')}:"
                            "${(kalanSure!.inMinutes % 60).toString().padLeft(2, '0')}:"
                            "${(kalanSure!.inSeconds % 60).toString().padLeft(2, '0')}",
                        style: const TextStyle(
                          fontSize: 30,
                          fontFamily: 'MyFont2',
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Divider(color: Colors.white70),
                      Text(
                          "${now.day} ${months[now.month]} ${now.year}, ${days[now.weekday]}",
                          style: const TextStyle(
                              fontSize: 13,
                              fontFamily: 'MyFont2',
                              color: Colors.white
                          )
                      ),
                      Text(
                          HijriDate.now().toFormat("dd MMMM yyyy"),
                          style: const TextStyle(
                              fontSize: 13,
                              fontFamily: 'MyFont2',
                              color: Colors.white70
                          )
                      ),
                    ],
                  ),
                ),
              ),
            ),
            loading
                ? const Expanded(child: Center(child: CircularProgressIndicator()))
                : Expanded(
              child: ListView(
                children: [
                  if (prayerTimes != null) ...[
                    ozelCard("İmsak", "assets/images/imsak.png", prayerTimes!.data.timings.imsak),
                    ozelCard("Günəş", "assets/images/gunes.png", prayerTimes!.data.timings.sunrise),
                    ozelCard("Günorta", "assets/images/gunorta.png", prayerTimes!.data.timings.dhuhr),
                    ozelCard("Əsr", "assets/images/esr.png", prayerTimes!.data.timings.asr),
                    ozelCard("Axşam", "assets/images/axsam.png", prayerTimes!.data.timings.maghrib),
                    ozelCard("İşa", "assets/images/isha.png", prayerTimes!.data.timings.isha),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}