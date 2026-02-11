import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ezan_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Bildirim açık/kapalı durumları
  bool imsakNotification = true;
  bool sunriseNotification = true;
  bool dhuhrNotification = true;
  bool asrNotification = true;
  bool maghribNotification = true;
  bool ishaNotification = true;

  // Ezan sesi açık/kapalı
  bool imsakEzan = false;
  bool sunriseEzan = false;
  bool dhuhrEzan = true;
  bool asrEzan = true;
  bool maghribEzan = true;
  bool ishaEzan = true;

  // Seçili ezan sesi
  String selectedEzan = 'default';

  final List<Map<String, String>> ezanSounds = [
    {'id': 'default', 'name': 'Varsayılan Əzan'},
    {'id': 'notification', 'name': 'Sadece Bildirim Sesi'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      // Bildirimler
      imsakNotification = prefs.getBool('imsakNotification') ?? true;
      sunriseNotification = prefs.getBool('sunriseNotification') ?? true;
      dhuhrNotification = prefs.getBool('dhuhrNotification') ?? true;
      asrNotification = prefs.getBool('asrNotification') ?? true;
      maghribNotification = prefs.getBool('maghribNotification') ?? true;
      ishaNotification = prefs.getBool('ishaNotification') ?? true;

      // Ezan sesleri
      imsakEzan = prefs.getBool('imsakEzan') ?? false;
      sunriseEzan = prefs.getBool('sunriseEzan') ?? false;
      dhuhrEzan = prefs.getBool('dhuhrEzan') ?? true;
      asrEzan = prefs.getBool('asrEzan') ?? true;
      maghribEzan = prefs.getBool('maghribEzan') ?? true;
      ishaEzan = prefs.getBool('ishaEzan') ?? true;

      // Seçili ezan
      selectedEzan = prefs.getString('selectedEzan') ?? 'default';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Bildirimler
    await prefs.setBool('imsakNotification', imsakNotification);
    await prefs.setBool('sunriseNotification', sunriseNotification);
    await prefs.setBool('dhuhrNotification', dhuhrNotification);
    await prefs.setBool('asrNotification', asrNotification);
    await prefs.setBool('maghribNotification', maghribNotification);
    await prefs.setBool('ishaNotification', ishaNotification);

    // Ezan sesleri
    await prefs.setBool('imsakEzan', imsakEzan);
    await prefs.setBool('sunriseEzan', sunriseEzan);
    await prefs.setBool('dhuhrEzan', dhuhrEzan);
    await prefs.setBool('asrEzan', asrEzan);
    await prefs.setBool('maghribEzan', maghribEzan);
    await prefs.setBool('ishaEzan', ishaEzan);

    // Seçili ezan
    await prefs.setString('selectedEzan', selectedEzan);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ayarlar saxlanıldı',
            style: TextStyle(fontFamily: 'MyFont2'),
          ),
          backgroundColor: Colors.teal,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildNotificationCard({
    required String title,
    required String icon,
    required bool isNotificationEnabled,
    required bool isEzanEnabled,
    required Function(bool) onNotificationChanged,
    required Function(bool) onEzanChanged,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  icon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'MyFont2',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bildiriş',
                  style: TextStyle(fontFamily: 'MyFont2'),
                ),
                Switch(
                  value: isNotificationEnabled,
                  onChanged: (value) {
                    onNotificationChanged(value);
                    _saveSettings();
                  },
                  activeColor: Colors.teal,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Əzan Səsi',
                  style: TextStyle(fontFamily: 'MyFont2'),
                ),
                Switch(
                  value: isEzanEnabled,
                  onChanged: isNotificationEnabled
                      ? (value) {
                    onEzanChanged(value);
                    _saveSettings();
                  }
                      : null,
                  activeColor: Colors.teal,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bildiriş Ayarları',
          style: TextStyle(fontFamily: 'MyFont2'),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // Ezan Sesi Seçimi
          Card(
            margin: const EdgeInsets.all(16),
            color: Colors.teal.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.volume_up, color: Colors.teal, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Əzan Səsi Seçin',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'MyFont2',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...ezanSounds.map((sound) {
                    return RadioListTile<String>(
                      title: Text(
                        sound['name']!,
                        style: const TextStyle(fontFamily: 'MyFont2'),
                      ),
                      value: sound['id']!,
                      groupValue: selectedEzan,
                      activeColor: Colors.teal,
                      onChanged: (value) {
                        setState(() {
                          selectedEzan = value!;
                        });
                        _saveSettings();
                      },
                    );
                  }),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      // Seçili ezan sesini çal
                      if (selectedEzan == 'default') {
                        // Ezan sesini çal
                        await EzanService.playEzan();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Əzan səsi çalınır...',
                                style: TextStyle(fontFamily: 'MyFont2'),
                              ),
                              backgroundColor: Colors.teal,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      } else {
                        // Normal bildirim sesi mesajı
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Bu seçim normal bildirim səsi istifadə edir',
                                style: TextStyle(fontFamily: 'MyFont2'),
                              ),
                              backgroundColor: Colors.orange,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text(
                      'Dinlə',
                      style: TextStyle(fontFamily: 'MyFont2'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 45),
                    ),
                  ),

                  //DAYANDIR
                  ElevatedButton.icon(
                    onPressed: () async {
                      // Seçili ezan sesini durdur
                      if (selectedEzan == 'default') {
                        await EzanService.stopEzan();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Əzan səsi dayandırıldı...',
                                style: TextStyle(fontFamily: 'MyFont2'),
                              ),
                              backgroundColor: Colors.teal,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      } else {
                        // Normal bildirim sesi mesajı
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Bu seçim normal bildirim səsi istifadə edir',
                                style: TextStyle(fontFamily: 'MyFont2'),
                              ),
                              backgroundColor: Colors.orange,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.stop),
                    label: const Text(
                      'Dayandır',
                      style: TextStyle(fontFamily: 'MyFont2'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 45),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Namaz Vaxtları',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'MyFont2',
              ),
            ),
          ),

          // İmsak
          _buildNotificationCard(
            title: 'İmsak',
            icon: '🌙',
            isNotificationEnabled: imsakNotification,
            isEzanEnabled: imsakEzan,
            onNotificationChanged: (value) {
              setState(() => imsakNotification = value);
              if (!value) setState(() => imsakEzan = false);
            },
            onEzanChanged: (value) => setState(() => imsakEzan = value),
          ),

          // Günəş
          _buildNotificationCard(
            title: 'Günəş',
            icon: '🌅',
            isNotificationEnabled: sunriseNotification,
            isEzanEnabled: sunriseEzan,
            onNotificationChanged: (value) {
              setState(() => sunriseNotification = value);
              if (!value) setState(() => sunriseEzan = false);
            },
            onEzanChanged: (value) => setState(() => sunriseEzan = value),
          ),

          // Günorta
          _buildNotificationCard(
            title: 'Günorta',
            icon: '☀️',
            isNotificationEnabled: dhuhrNotification,
            isEzanEnabled: dhuhrEzan,
            onNotificationChanged: (value) {
              setState(() => dhuhrNotification = value);
              if (!value) setState(() => dhuhrEzan = false);
            },
            onEzanChanged: (value) => setState(() => dhuhrEzan = value),
          ),

          // Əsr
          _buildNotificationCard(
            title: 'Əsr',
            icon: '🌤️',
            isNotificationEnabled: asrNotification,
            isEzanEnabled: asrEzan,
            onNotificationChanged: (value) {
              setState(() => asrNotification = value);
              if (!value) setState(() => asrEzan = false);
            },
            onEzanChanged: (value) => setState(() => asrEzan = value),
          ),

          // Axşam
          _buildNotificationCard(
            title: 'Axşam',
            icon: '🌆',
            isNotificationEnabled: maghribNotification,
            isEzanEnabled: maghribEzan,
            onNotificationChanged: (value) {
              setState(() => maghribNotification = value);
              if (!value) setState(() => maghribEzan = false);
            },
            onEzanChanged: (value) => setState(() => maghribEzan = value),
          ),

          // İşa
          _buildNotificationCard(
            title: 'İşa',
            icon: '🌃',
            isNotificationEnabled: ishaNotification,
            isEzanEnabled: ishaEzan,
            onNotificationChanged: (value) {
              setState(() => ishaNotification = value);
              if (!value) setState(() => ishaEzan = false);
            },
            onEzanChanged: (value) => setState(() => ishaEzan = value),
          ),

          const SizedBox(height: 20),

          // Toplu Aç/Kapa Butonları
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        imsakNotification = true;
                        sunriseNotification = true;
                        dhuhrNotification = true;
                        asrNotification = true;
                        maghribNotification = true;
                        ishaNotification = true;
                      });
                      _saveSettings();
                    },
                    icon: const Icon(Icons.notifications_active),
                    label: const Text(
                      'Hamısını Aç',
                      style: TextStyle(fontFamily: 'MyFont2'),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.teal,
                      side: const BorderSide(color: Colors.teal),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        imsakNotification = false;
                        sunriseNotification = false;
                        dhuhrNotification = false;
                        asrNotification = false;
                        maghribNotification = false;
                        ishaNotification = false;
                        imsakEzan = false;
                        sunriseEzan = false;
                        dhuhrEzan = false;
                        asrEzan = false;
                        maghribEzan = false;
                        ishaEzan = false;
                      });
                      _saveSettings();
                    },
                    icon: const Icon(Icons.notifications_off),
                    label: const Text(
                      'Hamısını Bağla',
                      style: TextStyle(fontFamily: 'MyFont2'),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}