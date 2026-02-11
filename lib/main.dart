import 'package:flutter/material.dart';
import 'package:namazvaktim/Pages/DaysPage.dart';
import 'package:namazvaktim/Pages/SettingsPage.dart';
import 'package:namazvaktim/Pages/HomePage.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();

  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Namaz Vaxtı',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const BNavBar(),
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
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Container(
          color: Colors.white,
          height: 100,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home),
                    onPressed: () => _onItemTapped(0),
                  ),
                  IconButton(
                    icon: const Icon(Icons.wb_sunny_sharp),
                    onPressed: () => _onItemTapped(1),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => _onItemTapped(2),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}