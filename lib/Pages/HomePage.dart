import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hijri_date/hijri.dart';
import 'package:namazvaktim/Pages/ImsakiyePage.dart';
import 'package:namazvaktim/Pages/MapPickerPage.dart';
import 'package:namazvaktim/models/PrayerModels.dart';
import 'package:namazvaktim/services/notification_service.dart';

import '../location/location_service.dart';
import '../services/PrayerService.dart';

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
  String? aktifVakit;

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

    // Önce kaydedilmiş konum var mı kontrol et
    CityLocation? savedLocation = await locationService.getSavedLocation();

    if (savedLocation != null) {
      // Kaydedilmiş konum varsa onu kullan
      setState(() {
        currentLocation = savedLocation;
      });
      loadPrayerTimes();
    } else {
      // İLK AÇILIŞ - Otomatik GPS ile konum al
      print('🎯 İlk açılış - GPS ile konum alınıyor...');

      setState(() {
        loading = true;
      });

      // GPS ile konum almayı dene
      final gpsLocation = await locationService.getCurrentLocation();

      if (gpsLocation != null) {
        // GPS başarılı
        print('✅ GPS konumu alındı: ${gpsLocation.name}');
        setState(() {
          currentLocation = gpsLocation;
        });
        await locationService.saveLocation(gpsLocation);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '📍 Mövqe təyin edildi: ${gpsLocation.name}',
                style: const TextStyle(fontFamily: 'MyFont2'),
              ),
              backgroundColor: Colors.teal,
              duration: const Duration(seconds: 3),
            ),
          );
        }

        loadPrayerTimes();
      } else {
        // GPS başarısız - Varsayılan şehir kullan (Bakı)
        print('⚠️ GPS alınamadı - Bakı varsayılan olarak seçildi');
        final defaultCity = AzerbaijanCities.cities.first; // Bakı

        setState(() {
          currentLocation = defaultCity;
        });
        await locationService.saveLocation(defaultCity);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                '⚠️ GPS alınamadı. Bakı seçildi. Ayarlardan dəyişdirə bilərsiniz.',
                style: TextStyle(fontFamily: 'MyFont2'),
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Dəyiş',
                textColor: Colors.white,
                onPressed: () {
                  _showCitySelection();
                },
              ),
            ),
          );
        }

        loadPrayerTimes();
      }
    }
  }

  String _adjustTime(String time, int minutesToAdd) {
    final cleanedTime = time.contains(' ') ? time.split(' ')[0].substring(0, 5) : time.substring(0, 5);
    final parts = cleanedTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    int totalMinutes = (hour * 60) + minute + minutesToAdd;

    if (totalMinutes >= 1440) {
      totalMinutes -= 1440;
    } else if (totalMinutes < 0) {
      totalMinutes += 1440;
    }

    final newHour = (totalMinutes ~/ 60).toString().padLeft(2, '0');
    final newMinute = (totalMinutes % 60).toString().padLeft(2, '0');

    return '$newHour:$newMinute';
  }

  void loadPrayerTimes() async {
    final location = currentLocation;
    if (location == null) return;

    setState(() => loading = true);

    final service = PrayerService();
    final data = await service.getPrayerTimes(location, DateTime.now());

    if (data != null) {
      final adjustedTimings = Timings(
        imsak: _adjustTime(data.data.timings.imsak, 10),
        fajr: data.data.timings.fajr,
        sunrise: data.data.timings.sunrise,
        dhuhr: data.data.timings.dhuhr,
        asr: data.data.timings.asr,
        sunset: data.data.timings.sunset,
        maghrib: data.data.timings.maghrib,
        isha: data.data.timings.isha,
        midnight: data.data.timings.midnight,
        firstthird: data.data.timings.firstthird,
        lastthird: data.data.timings.lastthird,
      );

      setState(() {
        prayerTimes = PrayerTimeResponse(
          code: data.code,
          status: data.status,
          data: PrayerData(
            timings: adjustedTimings,
            date: data.data.date,
            meta: data.data.meta,
          ),
        );
        loading = false;
      });

      // 🔔 BİLDİRİMLERİ AYARLA
      try {
        final notificationService = NotificationService();
        await notificationService.schedulePrayerNotifications(
          imsak: adjustedTimings.imsak,
          sunrise: adjustedTimings.sunrise,
          dhuhr: adjustedTimings.dhuhr,
          asr: adjustedTimings.asr,
          maghrib: adjustedTimings.maghrib,
          isha: adjustedTimings.isha,
        );
        print('✅ Bildirişlər uğurla təyin edildi');
      } catch (e) {
        print('❌ Bildiriş xətası: $e');
      }
    } else {
      setState(() => loading = false);
    }

    hesaplaKalanSure();

    // 30 günlük veriyi arka planda indir
    service.fetch30DaysPrayerTimes(location).then((_) {
      print('30 günlük namaz vaxtları yaddaşa yazıldı');
    }).catchError((e) {
      print('30 günlük məlumat yükləmə xətası: $e');
    });
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
    String? suAnkiVakit;

    final vakitListesi = vakitler.entries.toList();
    for (int i = 0; i < vakitListesi.length; i++) {
      final entry = vakitListesi[i];

      if (entry.value.isAfter(now)) {
        sonrakiVakit = entry.value;
        sonrakiAd = entry.key;

        if (i > 0) {
          suAnkiVakit = vakitListesi[i - 1].key;
        } else {
          suAnkiVakit = 'İşa';
        }
        break;
      }
    }

    if (sonrakiVakit == null) {
      sonrakiVakit = vakitler.values.first.add(const Duration(days: 1));
      sonrakiAd = vakitler.keys.first;
      suAnkiVakit = 'İşa';
    }

    setState(() {
      kalanSure = sonrakiVakit!.difference(now);
      sonrakiVakitAdi = sonrakiAd;
      aktifVakit = suAnkiVakit;
    });
  }

  DateTime _parseTime(String time) {
    final now = DateTime.now();
    final cleanedTime = time.contains(' ') ? time.split(' ')[0] : time;
    final parts = cleanedTime.split(':');
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  // GPS ile konum al
  Future<void> _getLocationFromGps() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 15),
                Text(
                  'GPS ilə dəqiq mövqe alınır...',
                  style: TextStyle(fontFamily: 'MyFont2'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final locationService = LocationService();
    final location = await locationService.getCurrentLocation();

    if (mounted) Navigator.of(context).pop();

    if (location != null) {
      setState(() {
        currentLocation = location;
      });

      await locationService.saveLocation(location);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '📍 ${location.name}',
              style: const TextStyle(fontFamily: 'MyFont2'),
            ),
            backgroundColor: Colors.teal,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      loadPrayerTimes();
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xəta', style: TextStyle(fontFamily: 'MyFont2')),
            content: const Text(
              'GPS ilə mövqe alına bilmədi. Mövqe xidmətini açın və yenidən cəhd edin.',
              style: TextStyle(fontFamily: 'MyFont2'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Bağla', style: TextStyle(fontFamily: 'MyFont2')),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _showCitySelection() async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Mövqe Seçin',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'MyFont2',
                ),
              ),
              const SizedBox(height: 15),

              // GPS BUTONU
              Card(
                color: Colors.teal.shade50,
                child: ListTile(
                  leading: const Icon(Icons.my_location, color: Colors.teal),
                  title: const Text(
                    'GPS ilə avtomatik',
                    style: TextStyle(
                      fontFamily: 'MyFont2',
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  subtitle: const Text(
                    'Hal-hazırkı mövqe',
                    style: TextStyle(fontFamily: 'MyFont2', fontSize: 12),
                  ),
                  trailing: (currentLocation?.isGpsLocation ?? false) &&
                      !currentLocation!.name.startsWith('Xəritə:')
                      ? const Icon(Icons.check_circle, color: Colors.teal)
                      : null,
                  onTap: () {
                    Navigator.of(context).pop();
                    _getLocationFromGps();
                  },
                ),
              ),

              const SizedBox(height: 10),

              // HARİTA BUTONU
              Card(
                color: Colors.blue.shade50,
                child: ListTile(
                  leading: const Icon(Icons.map, color: Colors.blue),
                  title: const Text(
                    'Xəritədən seç',
                    style: TextStyle(
                      fontFamily: 'MyFont2',
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  subtitle: const Text(
                    'Dəqiq koordinat',
                    style: TextStyle(fontFamily: 'MyFont2', fontSize: 12),
                  ),
                  trailing: (currentLocation?.name.startsWith('Xəritə:') ?? false)
                      ? const Icon(Icons.check_circle, color: Colors.blue)
                      : null,
                  onTap: () async {
                    Navigator.of(context).pop();

                    // Harita sayfasını aç
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapPickerPage(
                          currentLocation: currentLocation,
                        ),
                      ),
                    );

                    // Eğer konum seçildiyse
                    if (result != null && result is CityLocation) {
                      setState(() => currentLocation = result);
                      await LocationService().saveLocation(result);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '📍 ${result.name}',
                              style: const TextStyle(fontFamily: 'MyFont2'),
                            ),
                            backgroundColor: Colors.blue,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }

                      loadPrayerTimes();
                    }
                  },
                ),
              ),

              const Divider(height: 30),

              const Text(
                'Və ya şəhər seçin:',
                style: TextStyle(fontSize: 14, fontFamily: 'MyFont2', color: Colors.grey),
              ),
              const SizedBox(height: 10),

              // ŞEHİR LİSTESİ
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: AzerbaijanCities.cities.length,
                  itemBuilder: (context, index) {
                    final city = AzerbaijanCities.cities[index];
                    final isSelected = currentLocation?.name == city.name &&
                        !(currentLocation?.isGpsLocation ?? false);

                    return ListTile(
                      leading: Icon(
                        Icons.location_city,
                        color: isSelected ? Colors.teal : Colors.grey,
                      ),
                      title: Text(
                        city.name,
                        style: TextStyle(
                          fontFamily: 'MyFont2',
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.teal : null,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.teal)
                          : null,
                      onTap: () async {
                        setState(() => currentLocation = city);
                        await LocationService().saveLocation(city);
                        Navigator.of(context).pop();
                        loadPrayerTimes();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget ozelCard(String ad, String resim, String saat) {
    final bool isAktif = aktifVakit == ad;

    return SizedBox(
        height: 60,
        width: 600,
        child: Card(
          elevation: isAktif ? 8 : 1,
          color: isAktif ? Colors.teal.shade50 : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isAktif
                ? const BorderSide(color: Colors.teal, width: 2)
                : BorderSide.none,
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 11, right: 13),
                child: Image.asset(
                  resim,
                  width: 40,
                  height: 40,
                ),
              ),
              Text(
                ad,
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'MyFont2',
                  fontWeight: isAktif ? FontWeight.bold : FontWeight.normal,
                  color: isAktif ? Colors.teal.shade700 : null,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Text(
                  saat,
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'MyFont2',
                    fontWeight: isAktif ? FontWeight.bold : FontWeight.normal,
                    color: isAktif ? Colors.teal.shade700 : null,
                  ),
                ),
              ),
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
                  onPressed: () {
                    if (currentLocation != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImsakiyePage(location: currentLocation!),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.calendar_month_outlined),
                  tooltip: 'İmsakiyyə',
                ),
                IconButton(
                  onPressed: _showCitySelection,
                  icon: const Icon(Icons.location_on_outlined),
                  tooltip: 'Mövqe dəyiş',
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
                          "${sonrakiVakitAdi ?? 'Yüklənir'} vaxtına: ",
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
                      const Padding(
                        padding: EdgeInsets.only(left: 39.0, right: 39.0),
                        child: Divider(color: Colors.white70),
                      ),
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