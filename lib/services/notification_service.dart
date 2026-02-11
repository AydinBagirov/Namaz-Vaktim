import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'ezan_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // ---------------- INIT ----------------
  static Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Baku'));

    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        _onNotificationTapped(response);
      },
    );
    // Android 13+ permission
    await _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  // ---------------- TIKLAMA ----------------
  static void _onNotificationTapped(NotificationResponse response) async {
    final payload = response.payload;
    if (payload == null) return;

    final parts = payload.split(':');
    if (parts.length != 2) return;

    if (parts[0] == 'ezan') {
      final prayerKey = parts[1];
      final shouldPlay = await EzanService.shouldPlayEzan(prayerKey);

      if (shouldPlay) {
        await EzanService.playEzan();
      }
    }
  }

  // ---------------- CANCEL ----------------
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  // ---------------- SCHEDULE ALL ----------------
  static Future<void> schedulePrayerNotifications({
    required String imsak,
    required String sunrise,
    required String dhuhr,
    required String asr,
    required String maghrib,
    required String isha,
  }) async {
    await initialize();
    await cancelAll();

    final prefs = await SharedPreferences.getInstance();

    await _scheduleIfEnabled(
        1, '🌙 İmsak Vaxtı', 'İmsak vaxtı girdi', imsak, 'imsak',
        prefs.getBool('imsakNotification') ?? true,
        prefs.getBool('imsakEzan') ?? false);

    await _scheduleIfEnabled(
        2, '🌅 Günəş Vaxtı', 'Günəş doğdu', sunrise, 'sunrise',
        prefs.getBool('sunriseNotification') ?? true,
        prefs.getBool('sunriseEzan') ?? false);

    await _scheduleIfEnabled(
        3, '☀️ Günorta Namazı Vaxtı', 'Günorta namazı vaxtı girdi',
        dhuhr, 'dhuhr',
        prefs.getBool('dhuhrNotification') ?? true,
        prefs.getBool('dhuhrEzan') ?? true);

    await _scheduleIfEnabled(
        4, '🌤️ Əsr Namazı Vaxtı', 'Əsr namazı vaxtı girdi',
        asr, 'asr',
        prefs.getBool('asrNotification') ?? true,
        prefs.getBool('asrEzan') ?? true);

    await _scheduleIfEnabled(
        5, '🌆 Axşam Namazı Vaxtı', 'Axşam namazı vaxtı girdi',
        maghrib, 'maghrib',
        prefs.getBool('maghribNotification') ?? true,
        prefs.getBool('maghribEzan') ?? true);

    await _scheduleIfEnabled(
        6, '🌃 İşa Namazı Vaxtı', 'İşa namazı vaxtı girdi',
        isha, 'isha',
        prefs.getBool('ishaNotification') ?? true,
        prefs.getBool('ishaEzan') ?? true);
  }

  static Future<void> _scheduleIfEnabled(
      int id,
      String title,
      String body,
      String time,
      String prayerKey,
      bool notificationEnabled,
      bool playEzan,
      ) async {
    if (!notificationEnabled) return;

    await _scheduleNotification(
      id: id,
      title: title,
      body: body,
      time: time,
      prayerKey: prayerKey,
      playEzan: playEzan,
    );
  }

  // ---------------- TEK BILDIRIM ----------------
  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required String time,
    required String prayerKey,
    required bool playEzan,
  }) async {
    if (!time.contains(':')) return;

    final parts = time.split(':');
    if (parts.length < 2) return;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return;

    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final tzDate = tz.TZDateTime.from(scheduled, tz.local);

    // SharedPreferences'ten selectedEzan ayarını al
    final prefs = await SharedPreferences.getInstance();
    final selectedEzan = prefs.getString('selectedEzan') ?? 'default';

    // Ezan switch'i açık VE selectedEzan 'default' ise ezan sesini çal
    // Aksi halde normal bildirim sesi
    final shouldPlayEzanSound = playEzan && selectedEzan == 'default';

    final androidDetails = shouldPlayEzanSound
        ? const AndroidNotificationDetails(
      'prayer_times_ezan',
      'Namaz Vaxtları (Ezanlı)',
      channelDescription: 'Ezanlı bildirişlər',
      importance: Importance.high,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('ezan'),
      playSound: true,
    )
        : const AndroidNotificationDetails(
      'prayer_times_normal',
      'Namaz Vaxtları',
      channelDescription: 'Standart bildirişlər',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'ezan:$prayerKey',
    );
  }

  // ---------------- TEST ----------------
  static Future<void> sendTestNotification() async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Bildirişlər',
      channelDescription: 'Test üçün',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      id: 999,
      title: 'Test Bildiriş',
      body: 'Bildirim sistemi çalışıyor ✅',
      notificationDetails: details,
    );
  }
}