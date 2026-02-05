import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
//import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Bildirim ID'leri
  static const int imsakId = 1;
  static const int sunriseId = 2;
  static const int dhuhrId = 3;
  static const int asrId = 4;
  static const int maghribId = 5;
  static const int ishaId = 6;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Baku'));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    //
    // await _notifications.initialize(initSettings,
    //   onDidReceiveNotificationResponse: (NotificationResponse details) {
    //     print('Bildirime tıklandı: ${details.payload}');
    //   },
    // );

    _initialized = true;
    print('✅ Bildirimler başlatıldı');
  }

  Future<void> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
    }

    final IOSFlutterLocalNotificationsPlugin? iosImplementation =
    _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

    if (iosImplementation != null) {
      await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> schedulePrayerNotifications({
    required String imsak,
    required String sunrise,
    required String dhuhr,
    required String asr,
    required String maghrib,
    required String isha,
  }) async {
    await initialize();
    await cancelAllNotifications();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Her namaz vakti için bildirim ayarla
    await _scheduleNotification(
      id: imsakId,
      title: '🌙 İmsak Vaxtı',
      body: 'İmsak vaxtı girdi',
      time: _parseTime(imsak, today),
    );

    await _scheduleNotification(
      id: sunriseId,
      title: '🌅 Günəş Vaxtı',
      body: 'Günəş vaxtı girdi',
      time: _parseTime(sunrise, today),
    );

    await _scheduleNotification(
      id: dhuhrId,
      title: '☀️ Günorta Namazı Vaxtı',
      body: 'Günorta namazı vaxtı girdi',
      time: _parseTime(dhuhr, today),
    );

    await _scheduleNotification(
      id: asrId,
      title: '🌤️ Əsr Namazı Vaxtı',
      body: 'Əsr namazı vaxtı girdi',
      time: _parseTime(asr, today),
    );

    await _scheduleNotification(
      id: maghribId,
      title: '🌆 Axşam Namazı Vaxtı',
      body: 'Axşam namazı vaxtı girdi',
      time: _parseTime(maghrib, today),
    );

    await _scheduleNotification(
      id: ishaId,
      title: '🌃 İşa Namazı Vaxtı',
      body: 'İşa namazı vaxtı girdi',
      time: _parseTime(isha, today),
    );

    // Bildirimleri kaydet
    await _saveNotificationTimes(imsak, sunrise, dhuhr, asr, maghrib, isha);

    print('✅ Bildirimlər quruldu');
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) async {
    final now = DateTime.now();

    // Eğer vakit geçmişse, yarın için ayarla
    DateTime scheduledTime = time;
    if (time.isBefore(now)) {
      scheduledTime = time.add(const Duration(days: 1));
    }

    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'prayer_times',
      'Namaz Vakitleri',
      channelDescription: 'Namaz vakitleri bildirimleri',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      //uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, scheduledDate: tzTime, notificationDetails: details,
    );

    print('📅 Bildirim ayarlandı: $title - ${tzTime.toString()}');
  }

  DateTime _parseTime(String time, DateTime baseDate) {
    final cleanTime = time.split(' ')[0].substring(0, 5);
    final parts = cleanTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    return DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      hour,
      minute,
    );
  }

  Future<void> _saveNotificationTimes(
      String imsak,
      String sunrise,
      String dhuhr,
      String asr,
      String maghrib,
      String isha,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notification_times', jsonEncode({
      'imsak': imsak,
      'sunrise': sunrise,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
    }));
  }

  Future<Map<String, String>?> getSavedNotificationTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('notification_times');
    if (data != null) {
      return Map<String, String>.from(jsonDecode(data));
    }
    return null;
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('❌ Tüm bildirimler iptal edildi');
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id: id);
  }

  // Bildirim açık mı kontrol et
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }

  // Bildirimleri aç/kapat
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);

    if (!enabled) {
      await cancelAllNotifications();
    }
  }
}