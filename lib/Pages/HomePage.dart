import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hijri_date/hijri.dart';
import 'package:path_provider/path_provider.dart';

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

class PrayerService {
  final String city;
  final String country;

  PrayerService({required this.city, required this.country});

  Future<void> _saveToFile(Map<String, dynamic> jsonData) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/namaz_vakitleri.json');
    await file.writeAsString(jsonEncode(jsonData));
  }

  Future<Map<String, dynamic>?> _readFromFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/namaz_vakitleri.json');
    if (await file.exists()) {
      final content = await file.readAsString();
      return jsonDecode(content);
    }
    return null;
  }
  Future<PrayerTimeResponse?> _fetchFromApi() async {
    final url = Uri.parse(
        'https://api.aladhan.com/v1/timingsByCity'
            '?city=$city'
            '&country=$country'
            '&method=13'
            '&timezonestring=Asia/Baku'
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      await _saveToFile(jsonData);
      return PrayerTimeResponse.fromJson(jsonData);
    } else {
      print('API hatası: ${response.statusCode}');
      return null;
    }
  }

  Future<PrayerTimeResponse?> getPrayerTimes() async {
    final fileData = await _readFromFile();

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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PrayerTimeResponse? prayerTimes;
  bool loading = true;

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
    loadPrayerTimes();
  }
  void loadPrayerTimes() async {
    setState(() => loading = true);

    final service = PrayerService(city: "Nakhchivan", country: "Azerbaijan");
    final data = await service.getPrayerTimes();

    setState(() {
      prayerTimes = data;
      loading = false;
    });
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
                    children: const [
                      Text("Əssələmu Aleykum", style: TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'MyFont2')),
                      Text("Namaz Vaxtım", style: TextStyle(fontSize: 15, fontFamily: 'MyFont2')),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(onPressed: (){}, icon: const Icon(Icons.location_on_outlined))
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
                      const Text("Axşama: ", style: TextStyle(fontSize: 20, fontFamily: 'MyFont2', color: Colors.white)),
                      const SizedBox(height: 5),
                      const Text("01:24:45", style: TextStyle(fontSize: 30, fontFamily: 'MyFont2', color: Colors.white)),
                      const SizedBox(height: 5),
                      const Divider(color: Colors.white70),
                      Text("${now.day} ${months[now.month]} ${now.year}, ${days[now.weekday]}", style: const TextStyle(fontSize: 13, fontFamily: 'MyFont2', color: Colors.white)),
                      Text("${HijriDate.now().toFormat("dd MMMM yyyy")}", style: const TextStyle(fontSize: 13, fontFamily: 'MyFont2', color: Colors.white70)),
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
