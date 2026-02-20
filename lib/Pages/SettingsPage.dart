import 'package:flutter/material.dart';
import 'package:namazvaktim/Pages/NotificationsPage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  Widget _settingsItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Text(title, style: const TextStyle(fontFamily: 'MyFont2', fontSize: 15, color: Colors.white70)),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 20),
          ],
        ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Text("Ayarlar",
                      style: TextStyle(fontSize: 22, fontFamily: 'MyFont2',
                          fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [Color(0xFF1A3A4A), Color(0xFF0F2235)],
                      ),
                      border: Border.all(color: const Color(0xFF4ECDC4).withOpacity(0.18)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64, height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: Colors.white.withOpacity(0.06),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.asset("assets/images/AppLogo.png", fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text("Namaz Vaxtım",
                            style: TextStyle(fontSize: 16, fontFamily: 'MyFont2',
                                fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        const Text("Versiya 2.1.0",
                            style: TextStyle(fontSize: 11, color: Color(0xFF4ECDC4), fontFamily: 'MyFont2')),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(children: [
                    const Text("Parametrlər",
                        style: TextStyle(fontFamily: 'MyFont2', fontSize: 12,
                            color: Colors.white38, letterSpacing: 0.6)),
                    const SizedBox(width: 10),
                    Expanded(child: Container(height: 1, color: Colors.white.withOpacity(0.06))),
                  ]),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView(
                      children: [
                        _settingsItem(icon: Icons.notifications_outlined,
                            iconColor: const Color(0xFF4ECDC4), title: "Bildiriş Ayarları",
                            onTap: () => Navigator.push(context, MaterialPageRoute(
                                builder: (context) => const NotificationsPage()))),
                        _settingsItem(icon: Icons.dark_mode_outlined,
                            iconColor: const Color(0xFF5B9BD5), title: "Tema"),
                        _settingsItem(icon: Icons.language_outlined,
                            iconColor: const Color(0xFFFFD700), title: "Dil"),
                        _settingsItem(icon: Icons.bug_report_outlined,
                            iconColor: const Color(0xFFFF6B6B), title: "Xəta Bildir"),
                        _settingsItem(icon: Icons.mail_outline_rounded,
                            iconColor: const Color(0xFFB39DDB), title: "Əlaqə"),
                        _settingsItem(icon: Icons.share_outlined,
                            iconColor: const Color(0xFF80CBC4), title: "Proqramı Paylaş"),
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