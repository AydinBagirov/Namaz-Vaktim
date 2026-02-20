import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
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

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  PrayerTimeResponse? prayerTimes;
  bool loading = true;
  Duration? kalanSure;
  late final Ticker _ticker;
  CityLocation? currentLocation;
  String? sonrakiVakitAdi;
  String? aktifVakit;

  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  final now = DateTime.now();
  final months = [
    "", "Yanvar", "Fevral", "Mart", "Aprel", "May", "İyun", "İyul",
    "Avqust", "Sentyabr", "Oktyabr", "Noyabr", "Dekabr"
  ];
  final days = [
    "", "Bazarertəsi", "Çərşənbə axşamı", "Çərşənbə", "Cümə axşamı",
    "Cümə", "Şənbə", "Bazar"
  ];

  // Hicri ay adları Azerbaycan dilinde (hijri_date paketi TR locale döndürür, biz override edirik)
  static const List<String> _hijriMonthsAz = [
    "", "Məhərrəm", "Səfər", "Rəbiüləvvəl", "Rəbiülaxır",
    "Cəmadiyələvvəl", "Cəmadiyəlaxır", "Rəcəb", "Şaban",
    "Ramazan", "Şəvval", "Zilqədə", "Zilhiccə",
  ];

  static const Map<String, IconData> _vakitIkonlar = {
    'İmsak':   Icons.wb_twilight_rounded,
    'Günəş':   Icons.wb_sunny_outlined,
    'Günorta': Icons.wb_sunny,
    'Əsr':     Icons.cloud_queue_rounded,
    'Axşam':   Icons.nightlight_round_sharp,
    'İşa':     Icons.nights_stay,
  };

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _pulseAnimation = Tween<double>(begin: 0.97, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initializeLocation();
    _ticker = Ticker((_) { hesaplaKalanSure(); })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String _getHijriDateText() {
    // hijri_date paketi kullanılıyor, 1 gün geri alınıyor
    HijriDate.setLocal('tr');
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final hijri = HijriDate.fromDate(yesterday);
    final monthName = _hijriMonthsAz[hijri.hMonth];
    return "${hijri.hDay} $monthName ${hijri.hYear}";
  }

  String _getCleanCityName(String? name, {int maxLength = 20}) {
    if (name == null) return "Yüklənir...";
    String cleanName = name;
    if (cleanName.startsWith('GPS: ')) cleanName = cleanName.substring(5);
    if (cleanName.startsWith('Xəritə: ')) cleanName = cleanName.substring(8);
    if (cleanName.length > maxLength) return '${cleanName.substring(0, maxLength)}...';
    return cleanName;
  }

  Future<void> _initializeLocation() async {
    final locationService = LocationService();
    CityLocation? savedLocation = await locationService.getSavedLocation();

    if (savedLocation != null) {
      setState(() { currentLocation = savedLocation; });
      loadPrayerTimes();
    } else {
      print('🎯 İlk açılış - GPS ile konum alınıyor...');
      setState(() { loading = true; });

      final gpsLocation = await locationService.getCurrentLocation();

      if (gpsLocation != null) {
        print('✅ GPS konumu alındı: ${gpsLocation.name}');
        setState(() { currentLocation = gpsLocation; });
        await locationService.saveLocation(gpsLocation);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📍 Mövqe təyin edildi: ${_getCleanCityName(gpsLocation.name)}',
                  style: const TextStyle(fontFamily: 'MyFont2')),
              backgroundColor: const Color(0xFF1E3A5F),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
        loadPrayerTimes();
      } else {
        print('⚠️ GPS alınamadı - Bakı varsayılan olarak seçildi');
        final defaultCity = AzerbaijanCities.cities.first;
        setState(() { currentLocation = defaultCity; });
        await locationService.saveLocation(defaultCity);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('⚠️ GPS alınamadı. Bakı seçildi. Ayarlardan dəyişdirə bilərsiniz.',
                  style: TextStyle(fontFamily: 'MyFont2')),
              backgroundColor: const Color(0xFF3A2A0F),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Dəyiş',
                textColor: const Color(0xFFFFD700),
                onPressed: () { _showCitySelection(); },
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
    if (totalMinutes >= 1440) totalMinutes -= 1440;
    else if (totalMinutes < 0) totalMinutes += 1440;
    final newHour = (totalMinutes ~/ 60).toString().padLeft(2, '0');
    final newMinute = (totalMinutes % 60).toString().padLeft(2, '0');
    return '$newHour:$newMinute';
  }

  void loadPrayerTimes() async {
    final location = currentLocation;
    if (location == null) {
      print('⚠️ currentLocation null, vakitler yüklenemiyor');
      return;
    }

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔄 loadPrayerTimes BAŞLADI');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📍 Şehir ADI: ${location.name}');
    print('📍 GPS Flag: ${location.isGpsLocation}');
    print('📍 Koordinatlar: ${location.latitude}, ${location.longitude}');
    print('📍 Timezone: ${location.timezone}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    setState(() => loading = true);

    final service = PrayerService();
    final today = DateTime.now();
    print('📅 Tarih: ${today.day}/${today.month}/${today.year}');

    final data = await service.getPrayerTimes(location, today);

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔍 API Response: ${data != null ? "Var" : "Null"}');

    if (data != null) {
      print('✅ VERİ ALINDI');
      print('🕌 İmsak: ${data.data.timings.imsak}');
      print('🕌 Günəş: ${data.data.timings.sunrise}');
      print('🕌 Günorta: ${data.data.timings.dhuhr}');
      print('🕌 Əsr: ${data.data.timings.asr}');
      print('🕌 Axşam: ${data.data.timings.maghrib}');
      print('🕌 İşa: ${data.data.timings.isha}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

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

      print('✏️ Adjusted İmsak: ${adjustedTimings.imsak}');

      if (mounted) {
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
        _fadeController.forward(from: 0);
        print('✅ STATE GÜNCELLENDİ');
        print('🎯 Yeni state - İmsak: ${prayerTimes!.data.timings.imsak}');
        print('🗓️ Hicri: ${_getHijriDateText()}');
      }

      try {
        final notificationService = NotificationService();
        await NotificationService.schedulePrayerNotifications(
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
      print('❌ API\'den veri alınamadı - data null');
      setState(() => loading = false);
    }

    hesaplaKalanSure();

    print('📥 30 günlük veri indiriliyor...');
    service.fetch30DaysPrayerTimes(location).then((_) {
      print('✅ 30 günlük namaz vaxtları yaddaşa yazıldı');
    }).catchError((e) {
      print('❌ 30 günlük məlumat yükləmə xətası: $e');
    });

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔄 loadPrayerTimes BİTTİ');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  void hesaplaKalanSure() {
    if (prayerTimes == null) return;

    final now = DateTime.now();
    final t = prayerTimes!.data.timings;

    final vakitler = {
      'İmsak':   _parseTime(t.imsak),
      'Günəş':   _parseTime(t.sunrise),
      'Günorta': _parseTime(t.dhuhr),
      'Əsr':     _parseTime(t.asr),
      'Axşam':   _parseTime(t.maghrib),
      'İşa':     _parseTime(t.isha),
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
        suAnkiVakit = i > 0 ? vakitListesi[i - 1].key : 'İşa';
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
    return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }

  Future<void> _getLocationFromGps() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          margin: const EdgeInsets.all(40),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B2A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white12),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF4ECDC4)),
              SizedBox(height: 18),
              Text('GPS ilə dəqiq mövqe alınır...',
                  style: TextStyle(fontFamily: 'MyFont2', color: Colors.white70)),
            ],
          ),
        ),
      ),
    );

    final locationService = LocationService();
    final location = await locationService.getCurrentLocation();

    if (mounted) Navigator.of(context).pop();

    if (location != null) {
      setState(() { currentLocation = location; });
      await locationService.saveLocation(location);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📍 ${_getCleanCityName(location.name)}',
                style: const TextStyle(fontFamily: 'MyFont2')),
            backgroundColor: const Color(0xFF1E3A5F),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            backgroundColor: const Color(0xFF0D1B2A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Xəta',
                style: TextStyle(fontFamily: 'MyFont2', color: Colors.white)),
            content: const Text(
                'GPS ilə mövqe alına bilmədi. Mövqe xidmətini açın və yenidən cəhd edin.',
                style: TextStyle(fontFamily: 'MyFont2', color: Colors.white60)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Bağla',
                    style: TextStyle(fontFamily: 'MyFont2', color: Color(0xFF4ECDC4))),
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
        backgroundColor: const Color(0xFF0D1B2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Mövqe Seçin',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                      fontFamily: 'MyFont2', color: Colors.white)),
              const SizedBox(height: 15),

              _dialogOptionCard(
                color: const Color(0xFF0A3D3D),
                borderColor: const Color(0xFF4ECDC4),
                icon: Icons.my_location_rounded,
                iconColor: const Color(0xFF4ECDC4),
                title: 'GPS ilə avtomatik',
                subtitle: 'Hal-hazırkı mövqe',
                isSelected: (currentLocation?.isGpsLocation ?? false) &&
                    !currentLocation!.name.startsWith('Xəritə:'),
                onTap: () { Navigator.of(context).pop(); _getLocationFromGps(); },
              ),

              const SizedBox(height: 10),

              _dialogOptionCard(
                color: const Color(0xFF0A1F3D),
                borderColor: const Color(0xFF5B9BD5),
                icon: Icons.map_rounded,
                iconColor: const Color(0xFF5B9BD5),
                title: 'Xəritədən seç',
                subtitle: 'Dəqiq koordinat',
                isSelected: currentLocation?.name.startsWith('Xəritə:') ?? false,
                onTap: () async {
                  Navigator.of(context).pop();
                  print('🗺️ Harita sayfası açılıyor...');
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MapPickerPage(currentLocation: currentLocation)),
                  );
                  print('🗺️ Haritadan dönüldü. Result: $result');
                  if (result != null && result is CityLocation) {
                    print('✅ Yeni konum seçildi: ${result.name}');
                    print('📍 Koordinatlar: ${result.latitude}, ${result.longitude}');
                    setState(() => currentLocation = result);
                    await LocationService().saveLocation(result);
                    print('🔄 loadPrayerTimes() çağrılıyor...');
                    loadPrayerTimes();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('📍 ${_getCleanCityName(result.name)}',
                              style: const TextStyle(fontFamily: 'MyFont2')),
                          backgroundColor: const Color(0xFF1E3A5F),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  } else {
                    print('⚠️ Konum seçilmedi veya iptal edildi');
                  }
                },
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(children: [
                  const Expanded(child: Divider(color: Colors.white12)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: const Text('Şəhər seçin',
                        style: TextStyle(fontFamily: 'MyFont2', fontSize: 12, color: Colors.white38)),
                  ),
                  const Expanded(child: Divider(color: Colors.white12)),
                ]),
              ),

              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: AzerbaijanCities.cities.length,
                  itemBuilder: (context, index) {
                    final city = AzerbaijanCities.cities[index];
                    final isSelected = currentLocation?.name == city.name &&
                        !(currentLocation?.isGpsLocation ?? false);
                    return ListTile(
                      dense: true,
                      leading: Icon(Icons.location_city_rounded,
                          color: isSelected ? const Color(0xFF4ECDC4) : Colors.white24, size: 20),
                      title: Text(city.name,
                          style: TextStyle(
                              fontFamily: 'MyFont2', fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? const Color(0xFF4ECDC4) : Colors.white70)),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF4ECDC4), size: 18)
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

  Widget _dialogOptionCard({
    required Color color,
    required Color borderColor,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isSelected ? borderColor : Colors.white12,
              width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(fontFamily: 'MyFont2',
                        fontWeight: FontWeight.bold, color: iconColor, fontSize: 14)),
                Text(subtitle,
                    style: const TextStyle(
                        fontFamily: 'MyFont2', fontSize: 11, color: Colors.white38)),
              ],
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: iconColor, size: 20),
          ],
        ),
      ),
    );
  }

  // ── PRAYER ROW ──────────────────────────────────────────────────────
  Widget _prayerRow(String ad, String saat) {
    final bool isAktif = aktifVakit == ad;
    final icon = _vakitIkonlar[ad] ?? Icons.access_time_rounded;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: isAktif
            ? Colors.white.withOpacity(0.10)
            : Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isAktif
              ? const Color(0xFF4ECDC4).withOpacity(0.55)
              : Colors.white.withOpacity(0.07),
          width: isAktif ? 1.5 : 1,
        ),
        boxShadow: isAktif
            ? [BoxShadow(
            color: const Color(0xFF4ECDC4).withOpacity(0.10),
            blurRadius: 18, spreadRadius: 1)]
            : [],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isAktif
                  ? const Color(0xFF4ECDC4).withOpacity(0.18)
                  : Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon,
                color: isAktif ? const Color(0xFF4ECDC4) : Colors.white38,
                size: 20),
          ),
          const SizedBox(width: 14),
          Text(
            ad,
            style: TextStyle(
              fontFamily: 'MyFont2',
              fontSize: 16,
              fontWeight: isAktif ? FontWeight.bold : FontWeight.w400,
              color: isAktif ? Colors.white : Colors.white60,
              letterSpacing: 0.3,
            ),
          ),
          const Spacer(),
          if (isAktif)
            Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF4ECDC4).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF4ECDC4).withOpacity(0.35)),
              ),
              child: const Text('İndi',
                  style: TextStyle(fontFamily: 'MyFont2',
                      fontSize: 11, color: Color(0xFF4ECDC4))),
            ),
          Text(
            saat,
            style: TextStyle(
              fontFamily: 'MyFont2',
              fontSize: 16,
              fontWeight: isAktif ? FontWeight.bold : FontWeight.w400,
              color: isAktif ? Colors.white : Colors.white70,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Icon(icon, color: Colors.white54, size: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080E1A),
      body: Stack(
        children: [
          // ── ARKAPLAN ──
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0D1B2A), Color(0xFF080E1A), Color(0xFF0A1628)],
                ),
              ),
            ),
          ),

          // ── DEKORATİF GLOW DAİRELERİ ──
          Positioned(
            top: -80, right: -60,
            child: Container(
              width: 280, height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [const Color(0xFF4ECDC4).withOpacity(0.12), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100, left: -80,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [const Color(0xFF5B9BD5).withOpacity(0.08), Colors.transparent],
                ),
              ),
            ),
          ),

          // ── ANA İÇERİK ──
          SafeArea(
            child: Column(
              children: [

                // ── HEADER ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(11),
                          color: Colors.white.withOpacity(0.05),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Image.asset("assets/images/AppLogo.png", fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Əssələmu Aleykum",
                              style: TextStyle(fontSize: 10, color: Colors.white38, fontFamily: 'MyFont2')),
                          Text(_getCleanCityName(currentLocation?.name),
                              style: const TextStyle(fontSize: 15, fontFamily: 'MyFont2',
                                  fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                      const Spacer(),
                      _headerBtn(
                        icon: Icons.calendar_month_outlined,
                        onTap: () {
                          if (currentLocation != null) {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => ImsakiyePage(location: currentLocation!)));
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      _headerBtn(icon: Icons.location_on_outlined, onTap: _showCitySelection),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── COUNTDOWN KARTI ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1A3A4A), Color(0xFF0F2235)],
                      ),
                      border: Border.all(color: const Color(0xFF4ECDC4).withOpacity(0.18)),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFF4ECDC4).withOpacity(0.06),
                            blurRadius: 30, spreadRadius: 2),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tarix + Hicri
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Text(
                                "${now.day} ${months[now.month]} ${now.year}  ·  ${days[now.weekday]}",
                                style: const TextStyle(fontFamily: 'MyFont2',
                                    fontSize: 11, color: Colors.white54, letterSpacing: 0.2),
                              ),
                            ),
                            const Spacer(),
                            if (_getHijriDateText().isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2)),
                                ),
                                child: Text(
                                  _getHijriDateText(),
                                  style: const TextStyle(fontFamily: 'MyFont2',
                                      fontSize: 11, color: Color(0xFFFFD700), letterSpacing: 0.2),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Sonraki vakit etiketi
                        Text(
                          sonrakiVakitAdi != null ? "${sonrakiVakitAdi!} vaxtına" : "Yüklənir...",
                          style: const TextStyle(fontFamily: 'MyFont2',
                              fontSize: 13, color: Color(0xFF4ECDC4), letterSpacing: 0.4),
                        ),

                        const SizedBox(height: 4),

                        // Geri sayım
                        ScaleTransition(
                          scale: _pulseAnimation,
                          child: Text(
                            kalanSure == null
                                ? "--:--:--"
                                : "${kalanSure!.inHours.toString().padLeft(2, '0')}:"
                                "${(kalanSure!.inMinutes % 60).toString().padLeft(2, '0')}:"
                                "${(kalanSure!.inSeconds % 60).toString().padLeft(2, '0')}",
                            style: const TextStyle(
                              fontFamily: 'MyFont2',
                              fontSize: 46,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 3,
                              height: 1.1,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        Container(height: 1, color: Colors.white.withOpacity(0.06)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // ── LİSTE BAŞLIK ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Text("Namaz vaxtları",
                          style: TextStyle(fontFamily: 'MyFont2', fontSize: 12,
                              color: Colors.white38, letterSpacing: 0.6)),
                      const SizedBox(width: 10),
                      Expanded(child: Container(height: 1, color: Colors.white.withOpacity(0.06))),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ── VAKİT LİSTESİ ──
                loading
                    ? const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF4ECDC4), strokeWidth: 2),
                  ),
                )
                    : Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 24),
                      children: [
                        if (prayerTimes != null) ...[
                          _prayerRow("İmsak",   prayerTimes!.data.timings.imsak),
                          _prayerRow("Günəş",   prayerTimes!.data.timings.sunrise),
                          _prayerRow("Günorta", prayerTimes!.data.timings.dhuhr),
                          _prayerRow("Əsr",     prayerTimes!.data.timings.asr),
                          _prayerRow("Axşam",   prayerTimes!.data.timings.maghrib),
                          _prayerRow("İşa",     prayerTimes!.data.timings.isha),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}