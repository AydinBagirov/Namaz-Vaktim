import 'package:flutter/material.dart';
import 'package:namazvaktim/Pages/NotificationsPage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

Widget ozelCard(String ad, String resim) {
  return SizedBox(
    height: 60,
    width: double.infinity,
    child: Card(
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 11, right: 13),
            child: Image.asset(resim, width: 40, height: 40),
          ),
          Text(
            ad,
            style: TextStyle(fontSize: 15, fontFamily: 'MyFont2'),
          ),
        ],
      ),
    ),
  );
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 3.0, top: 10),
              child: Text(
                "Ayarlar",
                style: TextStyle(fontSize: 20, fontFamily: 'MyFont2'),
              ),
            ),

            SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 55,
                    height: 55,
                    child: Image.asset("assets/images/AppLogo.png"),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Namaz Vaxtım",
                    style: TextStyle(fontSize: 15, fontFamily: 'MyFont2'),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Versiya 2.0.0",
                    style: TextStyle(
                        fontSize: 10, color: Colors.grey, fontFamily: 'MyFont'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  GestureDetector(
                      child: ozelCard("Bildiriş Ayarları", "assets/images/bildirish.png"), onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationsPage(),
                      ),
                    );
                  },),
                  ozelCard("Tema", "assets/images/tema.png"),
                  ozelCard("Dil", "assets/images/dil.png"),
                  ozelCard("Xəta Bildir", "assets/images/xeta.png"),
                  ozelCard("Əlaqə", "assets/images/elaqe.png"),
                  ozelCard("Proqramı Paylaş", "assets/images/paylash.png"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
