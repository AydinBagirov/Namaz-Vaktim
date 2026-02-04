import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final now = DateTime.now();
  final months = [
    "",
    "Yanvar",
    "Fevral",
    "Mart",
    "Aprel",
    "May",
    "İyun",
    "İyul",
    "Avqust",
    "Sentyabr",
    "Oktyabr",
    "Noyabr",
    "Dekabr",
  ];

  final days = [
    "",
    "Bazarertəsi",
    "Çərşənbə axşamı",
    "Çərşənbə",
    "Cümə axşamı",
    "Cümə",
    "Şənbə",
    "Bazar",
  ];

Widget ozelCard(String ad, String resim){
  return SizedBox(
      height: 60,
      width: 600,
      child: Card(
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 11, right: 13),
              child: Image.asset(resim, width: 40, height: 40,),
            ),
            Text("$ad", style: TextStyle(fontSize: 15, fontFamily: 'MyFont2'),),
            Spacer(),
            Padding(
              padding: EdgeInsets.only(right: 15.0),
              child: Text("05:42", style: TextStyle(fontSize: 15, fontFamily: 'MyFont2'),),
            )
          ],
        ),
      )
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
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
                    children: [
                      Text("Əssələmu Aleykum", style: TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'MyFont')),
                      Text("Namaz Vaxtım", style: TextStyle(fontSize: 15, fontFamily: 'MyFont2'),),
                    ],
                  ),
                ),
                Spacer(),
                IconButton(onPressed: (){}, icon: Icon(Icons.location_on_outlined))
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: SizedBox(
                width: 470,
                height: 180,
                child: Card(
                  color: Colors.teal,
                  child: Column(
                    children: [
                      Text("İkindiye qalan vaxt :", style: TextStyle(fontSize: 20, fontFamily: 'MyFont', color: Colors.white)),
                      Text("01:24:45", style: TextStyle(fontSize: 30, fontFamily: 'MyFont2', color: Colors.white)),
                      Text("Sonraki vaxt: Axşam", style: TextStyle(fontSize: 20, fontFamily: 'MyFont', color: Colors.white)),
                      Padding(
                        padding: EdgeInsets.only(left: 15, right: 15),
                        child: Divider(),
                      ),
                      Text("${DateTime.now().day} ${months[now.month]} ${DateTime.now().year}, ${days[now.weekday]}", style: TextStyle(fontSize: 13, fontFamily: 'MyFont2', color: Colors.white)),
                      Text("11 Ramazan 1448", style: TextStyle(fontSize: 13, fontFamily: 'MyFont2', color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ozelCard("İmsak", "assets/images/imsak.png"),
                  ozelCard("Günəş", "assets/images/gunes.png"),
                  ozelCard("Günorta", "assets/images/gunorta.png"),
                  ozelCard("Əsr", "assets/images/esr.png"),
                  ozelCard("Axşam", "assets/images/axsam.png"),
                  ozelCard("İşa", "assets/images/isha.png"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
