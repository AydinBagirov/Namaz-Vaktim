import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hijri_date/hijri.dart';

// MODEL
class PrayerTimeResponse {
  final PrayerData data;
  PrayerTimeResponse({required this.data});

  factory PrayerTimeResponse.fromJson(Map<String, dynamic> json) {
    return PrayerTimeResponse(
      data: PrayerData.fromJson(json['data']),
    );
  }
}

class PrayerData {
  final Timings timings;
  PrayerData({required this.timings});
  factory PrayerData.fromJson(Map<String, dynamic> json) {
    return PrayerData(
      timings: Timings.fromJson(json['timings']),
    );
  }
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
}

// SERVICE
class PrayerService {
  Future<PrayerTimeResponse?> fetchPrayerTimes() async {
    final url = Uri.parse(
        'https://api.aladhan.com/v1/timingsByCity?city=Baku&country=Azerbaijan&method=13');

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

// UI
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
    fetchPrayerTimes();
  }

  void fetchPrayerTimes() async {
    final service = PrayerService();
    final data = await service.fetchPrayerTimes();
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
                padding: EdgeInsets.only(left: 11, right: 13),
                child: Image.asset(resim, width: 40, height: 40,),
              ),
              Text("$ad", style: TextStyle(fontSize: 15, fontFamily: 'MyFont2'),),
              Spacer(),
              Padding(
                padding: EdgeInsets.only(right: 15.0),
                child: Text(saat, style: TextStyle(fontSize: 15, fontFamily: 'MyFont2'),),
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
            // HEADER
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
                    children: [
                      Text("Əssələmu Aleykum", style: TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'MyFont')),
                      Text("Namaz Vaxtım", style: TextStyle(fontSize: 15, fontFamily: 'MyFont2'),),
                    ],
                  ),
                ),
                Spacer(),
                IconButton(onPressed: (){}, icon: Icon(Icons.location_on_outlined))
              ],
            ),

            // CARD: SONRAKI NAMAZ
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: SizedBox(
                width: 470,
                height: 180,
                child: Card(
                  color: Colors.teal,
                  child: Column(
                    children: [
                      Text("Axşama: ", style: TextStyle(fontSize: 20, fontFamily: 'MyFont2', color: Colors.white)),
                      Text("01:24:45", style: TextStyle(fontSize: 30, fontFamily: 'MyFont2', color: Colors.white)),
                      Text("Sonraki vaxt: İşa", style: TextStyle(fontSize: 20, fontFamily: 'MyFont2', color: Colors.white)),
                      Padding(
                        padding: EdgeInsets.only(left: 15, right: 15),
                        child: Divider(),
                      ),
                      Text("${now.day} ${months[now.month]} ${now.year}, ${days[now.weekday]}", style: TextStyle(fontSize: 13, fontFamily: 'MyFont2', color: Colors.white)),
                      Text("${HijriDate.now().toFormat("dd MMMM yyyy")}", style: TextStyle(fontSize: 13, fontFamily: 'MyFont2', color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ),

            // NAMAZ VAKİTLERİ
            loading
                ? Expanded(child: Center(child: CircularProgressIndicator()))
                : Expanded(
              child: ListView(
                children: [
                  ozelCard("İmsak", "assets/images/imsak.png", prayerTimes!.data.timings.imsak),
                  ozelCard("Günəş", "assets/images/gunes.png", prayerTimes!.data.timings.sunrise),
                  ozelCard("Günorta", "assets/images/gunorta.png", prayerTimes!.data.timings.dhuhr),
                  ozelCard("Əsr", "assets/images/esr.png", prayerTimes!.data.timings.asr),
                  ozelCard("Axşam", "assets/images/axsam.png", prayerTimes!.data.timings.maghrib),
                  ozelCard("İşa", "assets/images/isha.png", prayerTimes!.data.timings.isha),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
