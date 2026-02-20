import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ezan_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool imsakNotification = true;
  bool sunriseNotification = true;
  bool dhuhrNotification = true;
  bool asrNotification = true;
  bool maghribNotification = true;
  bool ishaNotification = true;

  bool imsakEzan = false;
  bool sunriseEzan = false;
  bool dhuhrEzan = true;
  bool asrEzan = true;
  bool maghribEzan = true;
  bool ishaEzan = true;

  String selectedEzan = 'default';

  final List<Map<String, String>> ezanSounds = [
    {'id': 'default', 'name': 'Varsayılan Əzan'},
    {'id': 'notification', 'name': 'Sadəcə Bildiriş Səsi'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      imsakNotification = prefs.getBool('imsakNotification') ?? true;
      sunriseNotification = prefs.getBool('sunriseNotification') ?? true;
      dhuhrNotification = prefs.getBool('dhuhrNotification') ?? true;
      asrNotification = prefs.getBool('asrNotification') ?? true;
      maghribNotification = prefs.getBool('maghribNotification') ?? true;
      ishaNotification = prefs.getBool('ishaNotification') ?? true;
      imsakEzan = prefs.getBool('imsakEzan') ?? false;
      sunriseEzan = prefs.getBool('sunriseEzan') ?? false;
      dhuhrEzan = prefs.getBool('dhuhrEzan') ?? true;
      asrEzan = prefs.getBool('asrEzan') ?? true;
      maghribEzan = prefs.getBool('maghribEzan') ?? true;
      ishaEzan = prefs.getBool('ishaEzan') ?? true;
      selectedEzan = prefs.getString('selectedEzan') ?? 'default';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('imsakNotification', imsakNotification);
    await prefs.setBool('sunriseNotification', sunriseNotification);
    await prefs.setBool('dhuhrNotification', dhuhrNotification);
    await prefs.setBool('asrNotification', asrNotification);
    await prefs.setBool('maghribNotification', maghribNotification);
    await prefs.setBool('ishaNotification', ishaNotification);
    await prefs.setBool('imsakEzan', imsakEzan);
    await prefs.setBool('sunriseEzan', sunriseEzan);
    await prefs.setBool('dhuhrEzan', dhuhrEzan);
    await prefs.setBool('asrEzan', asrEzan);
    await prefs.setBool('maghribEzan', maghribEzan);
    await prefs.setBool('ishaEzan', ishaEzan);
    await prefs.setString('selectedEzan', selectedEzan);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ayarlar saxlanıldı', style: TextStyle(fontFamily: 'MyFont2')),
          backgroundColor: const Color(0xFF1A3A4A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _notificationCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required bool isNotificationEnabled,
    required bool isEzanEnabled,
    required Function(bool) onNotificationChanged,
    required Function(bool) onEzanChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isNotificationEnabled
              ? iconColor.withOpacity(0.3)
              : Colors.white.withOpacity(0.07),
          width: isNotificationEnabled ? 1.2 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(isNotificationEnabled ? 0.18 : 0.07),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon,
                    color: isNotificationEnabled ? iconColor : Colors.white24, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title,
                  style: TextStyle(
                      fontFamily: 'MyFont2', fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isNotificationEnabled ? Colors.white : Colors.white38)),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.notifications_outlined, size: 16, color: Colors.white38),
              const SizedBox(width: 8),
              const Text('Bildiriş',
                  style: TextStyle(fontFamily: 'MyFont2', fontSize: 13, color: Colors.white54)),
              const Spacer(),
              _darkSwitch(
                value: isNotificationEnabled,
                activeColor: iconColor,
                onChanged: (value) { onNotificationChanged(value); _saveSettings(); },
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.volume_up_outlined, size: 16,
                  color: isNotificationEnabled ? Colors.white38 : Colors.white12),
              const SizedBox(width: 8),
              Text('Əzan Səsi',
                  style: TextStyle(fontFamily: 'MyFont2', fontSize: 13,
                      color: isNotificationEnabled ? Colors.white54 : Colors.white24)),
              const Spacer(),
              _darkSwitch(
                value: isEzanEnabled,
                activeColor: iconColor,
                onChanged: isNotificationEnabled
                    ? (value) { onEzanChanged(value); _saveSettings(); }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _darkSwitch({
    required bool value,
    required Color activeColor,
    required Function(bool)? onChanged,
  }) {
    return Transform.scale(
      scale: 0.85,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
        activeTrackColor: activeColor.withOpacity(0.3),
        inactiveThumbColor: Colors.white24,
        inactiveTrackColor: Colors.white10,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080E1A),
      body: Stack(
        children: [
          Positioned(
            top: -60, right: -40,
            child: Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [const Color(0xFF4ECDC4).withOpacity(0.08), Colors.transparent],
                ),
              ),
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
                      const Text("Bildiriş Ayarları",
                          style: TextStyle(fontSize: 18, fontFamily: 'MyFont2',
                              fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [

                      // Ezan seçim kartı
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                            colors: [Color(0xFF1A3A4A), Color(0xFF0F2235)],
                          ),
                          border: Border.all(color: const Color(0xFF4ECDC4).withOpacity(0.18)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4ECDC4).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.volume_up_rounded,
                                    color: Color(0xFF4ECDC4), size: 20),
                              ),
                              const SizedBox(width: 12),
                              const Text("Əzan Səsi Seçin",
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                                      fontFamily: 'MyFont2', color: Colors.white)),
                            ]),
                            const SizedBox(height: 14),
                            ...ezanSounds.map((sound) {
                              final isSelected = selectedEzan == sound['id'];
                              return GestureDetector(
                                onTap: () { setState(() => selectedEzan = sound['id']!); _saveSettings(); },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF4ECDC4).withOpacity(0.12)
                                        : Colors.white.withOpacity(0.04),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF4ECDC4).withOpacity(0.4)
                                          : Colors.white12,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isSelected ? Icons.radio_button_checked_rounded
                                            : Icons.radio_button_off_rounded,
                                        color: isSelected ? const Color(0xFF4ECDC4) : Colors.white24,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(sound['name']!,
                                          style: TextStyle(
                                              fontFamily: 'MyFont2', fontSize: 13,
                                              color: isSelected ? Colors.white : Colors.white54)),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      if (selectedEzan == 'default') {
                                        await EzanService.playEzan();
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                            content: const Text('Əzan səsi çalınır...',
                                                style: TextStyle(fontFamily: 'MyFont2')),
                                            backgroundColor: const Color(0xFF1A3A4A),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ));
                                        }
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4ECDC4).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFF4ECDC4).withOpacity(0.3)),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.play_arrow_rounded, color: Color(0xFF4ECDC4), size: 20),
                                          SizedBox(width: 6),
                                          Text('Dinlə', style: TextStyle(fontFamily: 'MyFont2',
                                              color: Color(0xFF4ECDC4), fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      if (selectedEzan == 'default') {
                                        await EzanService.stopEzan();
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                            content: const Text('Dayandırıldı',
                                                style: TextStyle(fontFamily: 'MyFont2')),
                                            backgroundColor: const Color(0xFF3A1A1A),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ));
                                        }
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF6B6B).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.3)),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.stop_rounded, color: Color(0xFFFF6B6B), size: 20),
                                          SizedBox(width: 6),
                                          Text('Dayandır', style: TextStyle(fontFamily: 'MyFont2',
                                              color: Color(0xFFFF6B6B), fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Bölüm başlık
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(children: [
                          const Text("Namaz Vaxtları",
                              style: TextStyle(fontFamily: 'MyFont2', fontSize: 12,
                                  color: Colors.white38, letterSpacing: 0.6)),
                          const SizedBox(width: 10),
                          Expanded(child: Container(height: 1, color: Colors.white.withOpacity(0.06))),
                        ]),
                      ),

                      _notificationCard(title: 'İmsak', icon: Icons.nights_stay_rounded,
                          iconColor: const Color(0xFF7B8EBF),
                          isNotificationEnabled: imsakNotification, isEzanEnabled: imsakEzan,
                          onNotificationChanged: (v) { setState(() { imsakNotification = v; if (!v) imsakEzan = false; }); },
                          onEzanChanged: (v) => setState(() => imsakEzan = v)),

                      _notificationCard(title: 'Günəş', icon: Icons.wb_twilight_rounded,
                          iconColor: const Color(0xFFFFB347),
                          isNotificationEnabled: sunriseNotification, isEzanEnabled: sunriseEzan,
                          onNotificationChanged: (v) { setState(() { sunriseNotification = v; if (!v) sunriseEzan = false; }); },
                          onEzanChanged: (v) => setState(() => sunriseEzan = v)),

                      _notificationCard(title: 'Günorta', icon: Icons.wb_sunny,
                          iconColor: const Color(0xFFFFD700),
                          isNotificationEnabled: dhuhrNotification, isEzanEnabled: dhuhrEzan,
                          onNotificationChanged: (v) { setState(() { dhuhrNotification = v; if (!v) dhuhrEzan = false; }); },
                          onEzanChanged: (v) => setState(() => dhuhrEzan = v)),

                      _notificationCard(title: 'Əsr', icon: Icons.cloud_queue_rounded,
                          iconColor: const Color(0xFF80CBC4),
                          isNotificationEnabled: asrNotification, isEzanEnabled: asrEzan,
                          onNotificationChanged: (v) { setState(() { asrNotification = v; if (!v) asrEzan = false; }); },
                          onEzanChanged: (v) => setState(() => asrEzan = v)),

                      _notificationCard(title: 'Axşam', icon: Icons.nightlight_round_sharp,
                          iconColor: const Color(0xFFFF8A65),
                          isNotificationEnabled: maghribNotification, isEzanEnabled: maghribEzan,
                          onNotificationChanged: (v) { setState(() { maghribNotification = v; if (!v) maghribEzan = false; }); },
                          onEzanChanged: (v) => setState(() => maghribEzan = v)),

                      _notificationCard(title: 'İşa', icon: Icons.nights_stay,
                          iconColor: const Color(0xFFB39DDB),
                          isNotificationEnabled: ishaNotification, isEzanEnabled: ishaEzan,
                          onNotificationChanged: (v) { setState(() { ishaNotification = v; if (!v) ishaEzan = false; }); },
                          onEzanChanged: (v) => setState(() => ishaEzan = v)),

                      const SizedBox(height: 16),

                      // Toplu butonlar
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  imsakNotification = sunriseNotification = dhuhrNotification =
                                      asrNotification = maghribNotification = ishaNotification = true;
                                });
                                _saveSettings();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4ECDC4).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFF4ECDC4).withOpacity(0.3)),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.notifications_active_outlined,
                                        color: Color(0xFF4ECDC4), size: 18),
                                    SizedBox(width: 8),
                                    Text('Hamısını Aç',
                                        style: TextStyle(fontFamily: 'MyFont2',
                                            color: Color(0xFF4ECDC4), fontSize: 13)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  imsakNotification = sunriseNotification = dhuhrNotification =
                                      asrNotification = maghribNotification = ishaNotification =
                                      imsakEzan = sunriseEzan = dhuhrEzan =
                                      asrEzan = maghribEzan = ishaEzan = false;
                                });
                                _saveSettings();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6B6B).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.3)),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.notifications_off_outlined,
                                        color: Color(0xFFFF6B6B), size: 18),
                                    SizedBox(width: 8),
                                    Text('Hamısını Bağla',
                                        style: TextStyle(fontFamily: 'MyFont2',
                                            color: Color(0xFFFF6B6B), fontSize: 13)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                    ],
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