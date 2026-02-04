import 'package:flutter/material.dart';

class DaysPage extends StatefulWidget {
  const DaysPage({super.key});

  @override
  State<DaysPage> createState() => _DaysPageState();
}

class _DaysPageState extends State<DaysPage> {
  double _height = 40;
  double _width = 150;
  bool _isMiladi = true;
  Widget Teqvim(){
    return GestureDetector(
      onTap: () => setState(() => _isMiladi = !_isMiladi),
      child: Container(
        height: _height,
        width: _width,
        decoration: BoxDecoration(
          color: Color(0xFF14A38B),
          borderRadius: BorderRadius.circular(_height / 2),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: _isMiladi
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Container(
                  width: _width / 2,
                  height: _height - 4,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(_height / 2),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Center(
                  child: Text(
                    "Miladi",
                    style: TextStyle(
                      color: _isMiladi ? Color(0xFF14A38B) : Colors.white60,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'MyFont2',
                    ),
                  ),
                ),
                Text(
                  "Hicri",
                  style: TextStyle(
                      color: !_isMiladi ? Color(0xFF14A38B) : Colors.white60,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'MyFont2'
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget DiniGunCard(String ad, String gun, String hicri, String miladi){
    return Padding(
      padding: EdgeInsets.only(left: 18.0, right: 18.0, top: 10),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFFE9F7F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.brightness_3_outlined,
                color: Color(0xFF14A38B),
                size: 24,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "$ad",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1D2939),
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "$gun",
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      _isMiladi == true ? Text(
                        "  •  $miladi",
                        style: TextStyle(
                            color: Color(0xFF14A38B),
                            fontWeight: FontWeight.w500,
                            fontSize: 13
                        ),
                      ): Text(
              "  •  $hicri",
              style: TextStyle(
                  color: Color(0xFF14A38B),
                  fontWeight: FontWeight.w500,
                  fontSize: 13
              ),
            ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 31.0),
              child: Text(
                "Dini Günlər",
                style: TextStyle(fontSize: 20, fontFamily: 'MyFont2'),
              ),
            ),
          ),
         Padding(
           padding: const EdgeInsets.only(left: 18.0, right: 18.0),
           child: Card(
             color: Colors.green,
             child: Row(
               children: [
                 Padding(
                   padding: const EdgeInsets.only(left: 18.0),
                   child: Text("Təqvim", style: TextStyle(fontSize: 20, fontFamily: 'MyFont2'),),
                 ),
                 Spacer(),
                 Padding(
                   padding: EdgeInsets.only(right: 12.0, top: 8, bottom: 8),
                   child: Teqvim(),
                 ),
               ],
             ),
           ),
         ),
          Expanded(child: ListView(
            children: [
              DiniGunCard("Miraç Kandili", "Cümə axşamı", "26 Rəcəb 1447", "15 yanvar 2026"),
              DiniGunCard("Berat Kandili", "Bazarertəsi", "14 Şaban 1447", "2 fevral 2026"),
              DiniGunCard("Ramazan Başlanğıcı", "Cümə axşamı", "1 Ramazan 1447", "19 fevral 2026"),
              DiniGunCard("Qədr Gecəsi", "Bazarertəsi", "26 Ramazan 1447", "16 mart 2026"),
              DiniGunCard("Ramazan Bayramı 1.günü", "Cümə", "1 Şəvval 1447", "20 mart 2026"),
              DiniGunCard("Ramazan Bayramı 2.günü", "Şənbə", "2 Şəvval 1447", "21 mart 2026"),
              DiniGunCard("Ramazan Bayramı 3.günü", "Bazar", "3 Şəvval 1447", "22 mart 2026"),
              DiniGunCard("Tərviyə günü", "Bazarertəsi", "8 Zilhiccə 1447", "25 may 2026"),
              DiniGunCard("Ərəfə Günü", "Çərşənbə axşamı", "9 Zilhiccə 1447", "26 may 2026"),
              DiniGunCard("Qurban Bayramı 1.günü", "Çərşənbə", "10 Zilhiccə 1447", "27 may 2026"),
              DiniGunCard("Qurban Bayramı 2.günü", "Cümə axşamı", "11 Zilhiccə 1447", "28 may 2026"),
              DiniGunCard("Qurban Bayramı 3.günü", "Cümə", "12 Zilhiccə 1447", "29 may 2026"),
              DiniGunCard("Qurban Bayramı 4.günü", "Şənbə", "13 Zilhiccə 1447", "30 may 2026"),
              DiniGunCard("Hicri Yeni il günü", "Çərşənbə axşamı", "1 Muharrəm 1448", "16 iyun 2026"),
              DiniGunCard("Aşura Günü", "Cümə axşamı", "10 Muharrəm 1448", "25 iyun 2026"),
              DiniGunCard("Mevlid Kandili", "Bazarertəsi", "11 Rəbüiləvvəl 1448", "24 avqust 2026"),
              DiniGunCard("Üç Aylar Başlanğıcı", "Cümə axşamı", "1 Rəcəb 1448", "10 dekabr 2026"),
              DiniGunCard("Rəğaib Kandili", "Cümə axşamı", "1 Rəcəb 1448", "10 dekabr 2026"),
            ],
          ))

        ],
      ),
    );
  }
}
