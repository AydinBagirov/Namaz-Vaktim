import 'package:flutter/material.dart';
import 'package:namazvaktim/Pages/DaysPage.dart';
import 'package:namazvaktim/Pages/QiblaPage.dart';
import 'package:namazvaktim/Pages/SettingsPage.dart';

import 'Pages/HomePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: BNavBar(),
    );
  }
}

class BNavBar extends StatefulWidget {
  const BNavBar({super.key});

  @override
  State<BNavBar> createState() => _BNavBarState();
}

class _BNavBarState extends State<BNavBar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const DaysPage(),
    //const QiblaPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 8.0),
        child: Container(
          color: Colors.white,
          height: 100,
          child: Column(
            children: [
              SizedBox(
                  width: 500,
                  height: 52,
                  child: Card(child: Text("Reklam"),)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home),
                    onPressed: () => _onItemTapped(0),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_month),
                    onPressed: () => _onItemTapped(1),
                  ),
                  // IconButton(
                  //   icon: const Icon(Icons.compass_calibration_outlined),
                  //   onPressed: () => _onItemTapped(2),
                  // ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => _onItemTapped(2),
                  ),
                ],
              ),
            ],
          )
        ),
      ),
    );
  }
}

