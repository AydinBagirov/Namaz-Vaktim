import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import '../location/location_service.dart';

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> with TickerProviderStateMixin {
  static const double _kabeLatitude = 21.4225;
  static const double _kabeLongitude = 39.8262;

  double? _compassHeading;
  double? _qiblaAngle;
  double? _userLatitude;
  double? _userLongitude;
  String _locationName = '';
  bool _loadingLocation = true;
  bool _compassAvailable = true;
  String? _errorMessage;

  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _pulseController = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    _initLocation();
    _startCompass();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    setState(() => _loadingLocation = true);

    final locationService = LocationService();
    CityLocation? saved = await locationService.getSavedLocation();

    if (saved != null) {
      _setLocation(saved.latitude, saved.longitude, saved.name);
      return;
    }

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Mövqe xidməti bağlıdır';
          _loadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Mövqe icazəsi verilmədi';
          _loadingLocation = false;
        });
        return;
      }

      Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10));
      _setLocation(pos.latitude, pos.longitude, '');
    } catch (e) {
      _setLocation(40.4093, 49.8671, 'Bakı');
    }
  }

  void _setLocation(double lat, double lng, String name) {
    final angle = _calculateQiblaAngle(lat, lng);
    setState(() {
      _userLatitude = lat;
      _userLongitude = lng;
      _qiblaAngle = angle;
      _locationName = name;
      _loadingLocation = false;
      _errorMessage = null;
    });
    _fadeController.forward(from: 0);
  }

  double _calculateQiblaAngle(double lat, double lng) {
    final double latRad = lat * math.pi / 180;
    final double lngRad = lng * math.pi / 180;
    final double kabeLat = _kabeLatitude * math.pi / 180;
    final double kabeLng = _kabeLongitude * math.pi / 180;

    final double dLng = kabeLng - lngRad;

    final double y = math.sin(dLng);
    final double x = math.cos(latRad) * math.tan(kabeLat) -
        math.sin(latRad) * math.cos(dLng);

    double angle = math.atan2(y, x) * 180 / math.pi;
    return (angle + 360) % 360;
  }

  void _startCompass() {
    FlutterCompass.events?.listen((CompassEvent event) {
      if (event.heading != null && mounted) {
        setState(() {
          _compassHeading = event.heading!;
          _compassAvailable = true;
        });
      }
    }, onError: (e) {
      if (mounted) {
        setState(() => _compassAvailable = false);
      }
    });
  }

  double get _needleRotation {
    if (_compassHeading == null || _qiblaAngle == null) return 0;
    return (_qiblaAngle! - _compassHeading!) * math.pi / 180;
  }

  double get _qiblaDeviation {
    if (_compassHeading == null || _qiblaAngle == null) return 999;
    double diff = (_qiblaAngle! - _compassHeading! + 360) % 360;
    if (diff > 180) diff = 360 - diff;
    return diff;
  }

  bool get _isPointingQibla => _qiblaDeviation < 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080E1A),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0D1B2A), Color(0xFF080E1A), Color(0xFF0A1628)],
                ),
              ),
            ),
          ),

          Positioned(
            top: -80, right: -60,
            child: Container(
              width: 280, height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [const Color(0xFFFFD700).withOpacity(0.07), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 60, left: -80,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [const Color(0xFF4ECDC4).withOpacity(0.06), Colors.transparent],
                ),
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
                      const Text("Qiblə",
                          style: TextStyle(
                              fontSize: 22, fontFamily: 'MyFont2',
                              fontWeight: FontWeight.bold, color: Colors.white)),
                      const Spacer(),
                      if (_locationName.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on_rounded,
                                  color: Color(0xFF4ECDC4), size: 14),
                              const SizedBox(width: 4),
                              Text(_locationName,
                                  style: const TextStyle(
                                      fontFamily: 'MyFont2', fontSize: 12,
                                      color: Colors.white70)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(children: [
                    const Text("Kompas",
                        style: TextStyle(fontFamily: 'MyFont2', fontSize: 12,
                            color: Colors.white38, letterSpacing: 0.6)),
                    const SizedBox(width: 10),
                    Expanded(child: Container(
                        height: 1, color: Colors.white.withOpacity(0.06))),
                  ]),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: _loadingLocation
                      ? _buildLoading()
                      : _errorMessage != null
                      ? _buildError()
                      : !_compassAvailable
                      ? _buildNoCompass()
                      : FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildCompass(),
                  ),
                ),

                if (!_loadingLocation && _errorMessage == null && _compassAvailable)
                  _buildInfoCard(),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF4ECDC4), strokeWidth: 2),
          SizedBox(height: 16),
          Text('Mövqe alınır...', style: TextStyle(
              fontFamily: 'MyFont2', color: Colors.white54, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B).withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.3)),
              ),
              child: const Icon(Icons.location_off_rounded,
                  color: Color(0xFFFF6B6B), size: 40),
            ),
            const SizedBox(height: 20),
            Text(_errorMessage ?? 'Xəta baş verdi',
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'MyFont2',
                    color: Colors.white70, fontSize: 15)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _initLocation,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF4ECDC4).withOpacity(0.4)),
                ),
                child: const Text('Yenidən cəhd et',
                    style: TextStyle(fontFamily: 'MyFont2',
                        color: Color(0xFF4ECDC4), fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoCompass() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
              ),
              child: const Icon(Icons.explore_off_rounded,
                  color: Color(0xFFFFD700), size: 40),
            ),
            const SizedBox(height: 20),
            const Text('Bu cihazda kompas sensoru tapılmadı',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'MyFont2',
                    color: Colors.white70, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildCompass() {
    final isAligned = _isPointingQibla;
    final activeColor = isAligned ? const Color(0xFF4ECDC4) : const Color(0xFFFFD700);

    return Column(
      children: [
        _buildDirectionIndicator(),

        const SizedBox(height: 16),

        Expanded(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Dış glow
                if (isAligned)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 280, height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4ECDC4).withOpacity(0.2),
                          blurRadius: 40, spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),

                CustomPaint(
                  size: const Size(260, 260),
                  painter: _CompassRingPainter(
                    heading: _compassHeading ?? 0,
                    activeColor: activeColor,
                  ),
                ),

                SizedBox(
                  width: 200, height: 200,
                  child: AnimatedRotation(
                    turns: _needleRotation / (2 * math.pi),
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    child: CustomPaint(
                      painter: _QiblaNeedlePainter(
                          isAligned: isAligned, activeColor: activeColor),
                    ),
                  ),
                ),

                Container(
                  width: 16, height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: activeColor,
                    boxShadow: [
                      BoxShadow(color: activeColor.withOpacity(0.5), blurRadius: 8),
                    ],
                  ),
                ),

                if (_qiblaAngle != null && _compassHeading != null)
                  Transform.rotate(
                    angle: _needleRotation,
                    child: Transform.translate(
                      offset: const Offset(0, -82),
                      child: ScaleTransition(
                        scale: isAligned ? _pulseAnimation :
                        const AlwaysStoppedAnimation(1.0),
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: activeColor.withOpacity(0.2),
                            border: Border.all(color: activeColor, width: 1.5),
                          ),
                          child: Icon(Icons.mosque_rounded,
                              color: activeColor, size: 16),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDirectionIndicator() {
    if (_compassHeading == null) return const SizedBox();

    final heading = _compassHeading!;
    String direction;
    if (heading < 22.5 || heading >= 337.5) direction = 'Şimal';
    else if (heading < 67.5) direction = 'Şimal-Şərq';
    else if (heading < 112.5) direction = 'Şərq';
    else if (heading < 157.5) direction = 'Cənub-Şərq';
    else if (heading < 202.5) direction = 'Cənub';
    else if (heading < 247.5) direction = 'Cənub-Qərb';
    else if (heading < 292.5) direction = 'Qərb';
    else direction = 'Şimal-Qərb';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Icon(Icons.explore_rounded, color: Colors.white38, size: 16),
                const SizedBox(width: 6),
                Text('${heading.toStringAsFixed(0)}°',
                    style: const TextStyle(fontFamily: 'MyFont2',
                        fontSize: 13, color: Colors.white70)),
                const SizedBox(width: 4),
                Text(direction,
                    style: const TextStyle(fontFamily: 'MyFont2',
                        fontSize: 12, color: Colors.white38)),
              ],
            ),
          ),
          if (_qiblaAngle != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.mosque_rounded, color: Color(0xFFFFD700), size: 16),
                  const SizedBox(width: 6),
                  Text('Qiblə: ${_qiblaAngle!.toStringAsFixed(0)}°',
                      style: const TextStyle(fontFamily: 'MyFont2',
                          fontSize: 13, color: Color(0xFFFFD700))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final isAligned = _isPointingQibla;
    final deviation = _qiblaDeviation;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: isAligned
                ? [const Color(0xFF0A3D3D), const Color(0xFF0A2A2A)]
                : [const Color(0xFF1A3A4A), const Color(0xFF0F2235)],
          ),
          border: Border.all(
            color: isAligned
                ? const Color(0xFF4ECDC4).withOpacity(0.4)
                : const Color(0xFFFFD700).withOpacity(0.2),
          ),
          boxShadow: isAligned
              ? [BoxShadow(color: const Color(0xFF4ECDC4).withOpacity(0.1),
              blurRadius: 20)]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isAligned
                    ? const Color(0xFF4ECDC4)
                    : const Color(0xFFFFD700)).withOpacity(0.15),
                border: Border.all(
                  color: (isAligned
                      ? const Color(0xFF4ECDC4)
                      : const Color(0xFFFFD700)).withOpacity(0.4),
                ),
              ),
              child: Icon(
                isAligned ? Icons.check_circle_rounded : Icons.navigation_rounded,
                color: isAligned ? const Color(0xFF4ECDC4) : const Color(0xFFFFD700),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAligned ? 'Qiblə istiqamətiniz düzgündür!' : 'Qiblə istiqamətini tapın',
                    style: TextStyle(
                      fontFamily: 'MyFont2', fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isAligned ? const Color(0xFF4ECDC4) : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isAligned
                        ? 'Üzünüz Kəbəyə doğrudur'
                        : '${deviation.toStringAsFixed(0)}° sapma var',
                    style: TextStyle(
                      fontFamily: 'MyFont2', fontSize: 12,
                      color: isAligned
                          ? const Color(0xFF4ECDC4).withOpacity(0.7)
                          : Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
            if (_userLatitude != null && _userLongitude != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${_userLatitude!.toStringAsFixed(2)}°N',
                      style: const TextStyle(fontFamily: 'MyFont2',
                          fontSize: 11, color: Colors.white38)),
                  Text('${_userLongitude!.toStringAsFixed(2)}°E',
                      style: const TextStyle(fontFamily: 'MyFont2',
                          fontSize: 11, color: Colors.white38)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _CompassRingPainter extends CustomPainter {
  final double heading;
  final Color activeColor;

  _CompassRingPainter({required this.heading, required this.activeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final ringPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius - 2, ringPaint);

    final innerRingPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius - 20, innerRingPaint);

    for (int i = 0; i < 36; i++) {
      final angle = (i * 10 - heading) * math.pi / 180;
      final isMajor = i % 9 == 0;
      final isMedium = i % 3 == 0;

      final tickLength = isMajor ? 16.0 : (isMedium ? 10.0 : 6.0);
      final tickWidth = isMajor ? 2.0 : 1.0;
      final tickColor = isMajor
          ? Colors.white.withOpacity(0.7)
          : (isMedium ? Colors.white.withOpacity(0.35) : Colors.white.withOpacity(0.15));

      final paint = Paint()
        ..color = tickColor
        ..strokeWidth = tickWidth
        ..strokeCap = StrokeCap.round;

      final outerPoint = Offset(
        center.dx + (radius - 4) * math.sin(angle),
        center.dy - (radius - 4) * math.cos(angle),
      );
      final innerPoint = Offset(
        center.dx + (radius - 4 - tickLength) * math.sin(angle),
        center.dy - (radius - 4 - tickLength) * math.cos(angle),
      );
      canvas.drawLine(outerPoint, innerPoint, paint);

      if (isMajor) {
        final labels = ['Ş', 'Ş', 'C', 'Q'];
        final directions = [0, 90, 180, 270];
        final dirIndex = [0, 90, 180, 270].indexOf(i * 10);
        if (dirIndex != -1) {
          final textPainter = TextPainter(
            text: TextSpan(
              text: ['Ş', 'Ş-Ş', 'C', 'Q'][dirIndex],
              style: TextStyle(
                color: dirIndex == 0
                    ? activeColor
                    : Colors.white.withOpacity(0.5),
                fontSize: dirIndex == 0 ? 14 : 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();

          final labelPoint = Offset(
            center.dx + (radius - 4 - tickLength - 18) * math.sin(angle) -
                textPainter.width / 2,
            center.dy - (radius - 4 - tickLength - 18) * math.cos(angle) -
                textPainter.height / 2,
          );
          textPainter.paint(canvas, labelPoint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_CompassRingPainter old) =>
      old.heading != heading || old.activeColor != activeColor;
}

class _QiblaNeedlePainter extends CustomPainter {
  final bool isAligned;
  final Color activeColor;

  _QiblaNeedlePainter({required this.isAligned, required this.activeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final upColor = activeColor;
    final downColor = Colors.white.withOpacity(0.2);

    final upPath = Path();
    upPath.moveTo(center.dx, center.dy - 70);
    upPath.lineTo(center.dx - 8, center.dy - 10);
    upPath.lineTo(center.dx, center.dy - 20);
    upPath.lineTo(center.dx + 8, center.dy - 10);
    upPath.close();

    canvas.drawPath(
        upPath,
        Paint()
          ..color = upColor
          ..style = PaintingStyle.fill);

    canvas.drawPath(
        upPath,
        Paint()
          ..color = upColor.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);

    if (isAligned) {
      canvas.drawPath(
          upPath,
          Paint()
            ..color = upColor.withOpacity(0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
            ..style = PaintingStyle.fill);
    }

    final downPath = Path();
    downPath.moveTo(center.dx, center.dy + 70);
    downPath.lineTo(center.dx - 6, center.dy + 15);
    downPath.lineTo(center.dx, center.dy + 20);
    downPath.lineTo(center.dx + 6, center.dy + 15);
    downPath.close();

    canvas.drawPath(
        downPath,
        Paint()
          ..color = downColor
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_QiblaNeedlePainter old) =>
      old.isAligned != isAligned || old.activeColor != activeColor;
}