import 'package:flutter/material.dart';

class DaysPage extends StatefulWidget {
  const DaysPage({super.key});

  @override
  State<DaysPage> createState() => _DaysPageState();
}

class _DaysPageState extends State<DaysPage> {
  bool _isMiladi = true;

  Widget _toggleWidget() {
    return GestureDetector(
      onTap: () => setState(() => _isMiladi = !_isMiladi),
      child: Container(
        height: 36,
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: _isMiladi ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                width: 70,
                height: 36,
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withOpacity(0.25),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF4ECDC4).withOpacity(0.5)),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text("Miladi",
                        style: TextStyle(
                          fontFamily: 'MyFont2', fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _isMiladi ? const Color(0xFF4ECDC4) : Colors.white38,
                        )),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text("Hicri",
                        style: TextStyle(
                          fontFamily: 'MyFont2', fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: !_isMiladi ? const Color(0xFF4ECDC4) : Colors.white38,
                        )),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _diniGunCard(String ad, String gun, String hicri, String miladi) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF4ECDC4).withOpacity(0.12),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: const Color(0xFF4ECDC4).withOpacity(0.2)),
            ),
            child: const Icon(Icons.nightlight_round_sharp,
                color: Color(0xFF4ECDC4), size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ad,
                    style: const TextStyle(
                        fontFamily: 'MyFont2', fontSize: 14,
                        fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(gun,
                        style: const TextStyle(
                            fontFamily: 'MyFont2', fontSize: 12, color: Colors.white38)),
                    const SizedBox(width: 6),
                    Container(width: 3, height: 3,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white24)),
                    const SizedBox(width: 6),
                    Text(
                      _isMiladi ? miladi : hicri,
                      style: const TextStyle(
                          fontFamily: 'MyFont2', fontSize: 12,
                          color: Color(0xFF4ECDC4), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
                    colors: [const Color(0xFF4ECDC4).withOpacity(0.08), Colors.transparent]),
              ),
            ),
          ),
          Positioned(
            bottom: 80, left: -60,
            child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                    colors: [const Color(0xFF5B9BD5).withOpacity(0.06), Colors.transparent]),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      const Text("Dini Günlər",
                          style: TextStyle(fontSize: 20, fontFamily: 'MyFont2',
                              fontWeight: FontWeight.bold, color: Colors.white)),
                      const Spacer(),
                      _toggleWidget(),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(children: [
                    const Text("2025 – 2026",
                        style: TextStyle(fontFamily: 'MyFont2', fontSize: 12,
                            color: Colors.white38, letterSpacing: 0.6)),
                    const SizedBox(width: 10),
                    Expanded(child: Container(height: 1, color: Colors.white.withOpacity(0.06))),
                  ]),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      _diniGunCard("Miraç Kandili", "Cümə axşamı", "26 Rəcəb 1447", "15 Yanvar 2026"),
                      _diniGunCard("Berat Kandili", "Bazarertəsi", "14 Şaban 1447", "2 Fevral 2026"),
                      _diniGunCard("Ramazan Başlanğıcı", "Cümə axşamı", "1 Ramazan 1447", "19 Fevral 2026"),
                      _diniGunCard("Qədr Gecəsi", "Bazarertəsi", "26 Ramazan 1447", "16 Mart 2026"),
                      _diniGunCard("Ramazan Bayramı 1.günü", "Cümə", "1 Şəvval 1447", "20 Mart 2026"),
                      _diniGunCard("Ramazan Bayramı 2.günü", "Şənbə", "2 Şəvval 1447", "21 Mart 2026"),
                      _diniGunCard("Ramazan Bayramı 3.günü", "Bazar", "3 Şəvval 1447", "22 Mart 2026"),
                      _diniGunCard("Tərviyə günü", "Bazarertəsi", "8 Zilhiccə 1447", "25 May 2026"),
                      _diniGunCard("Ərəfə Günü", "Çərşənbə axşamı", "9 Zilhiccə 1447", "26 May 2026"),
                      _diniGunCard("Qurban Bayramı 1.günü", "Çərşənbə", "10 Zilhiccə 1447", "27 May 2026"),
                      _diniGunCard("Qurban Bayramı 2.günü", "Cümə axşamı", "11 Zilhiccə 1447", "28 May 2026"),
                      _diniGunCard("Qurban Bayramı 3.günü", "Cümə", "12 Zilhiccə 1447", "29 May 2026"),
                      _diniGunCard("Qurban Bayramı 4.günü", "Şənbə", "13 Zilhiccə 1447", "30 May 2026"),
                      _diniGunCard("Hicri Yeni il günü", "Çərşənbə axşamı", "1 Muharrəm 1448", "16 İyun 2026"),
                      _diniGunCard("Aşura Günü", "Cümə axşamı", "10 Muharrəm 1448", "25 İyun 2026"),
                      _diniGunCard("Mevlid Kandili", "Bazarertəsi", "11 Rəbüiləvvəl 1448", "24 Avqust 2026"),
                      _diniGunCard("Üç Aylar Başlanğıcı", "Cümə axşamı", "1 Rəcəb 1448", "10 Dekabr 2026"),
                      _diniGunCard("Rəğaib Kandili", "Cümə axşamı", "1 Rəcəb 1448", "10 Dekabr 2026"),
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