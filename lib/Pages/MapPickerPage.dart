import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:namazvaktim/location/location_service.dart';
import 'dart:convert';

class MapPickerPage extends StatefulWidget {
  final CityLocation? currentLocation;

  const MapPickerPage({super.key, this.currentLocation});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  late MapController mapController;
  LatLng? selectedPosition;
  String selectedLocationName = 'Xəritədən seçin';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    mapController = MapController();


    if (widget.currentLocation != null) {
      selectedPosition = LatLng(
        widget.currentLocation!.latitude,
        widget.currentLocation!.longitude,
      );

      selectedLocationName = _getCleanCityName(widget.currentLocation!.name);
    }
  }


  String _getCleanCityName(String name) {

    if (name.startsWith('GPS: ')) {
      return name.substring(5);
    }
    if (name.startsWith('Xəritə: ')) {
      return name.substring(8);
    }
    return name;
  }


  Future<String> _getLocationName(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
            '?format=json'
            '&lat=$lat'
            '&lon=$lng'
            '&zoom=10'
            '&accept-language=az',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'NamazVaktiApp/1.0'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        String? cityName = data['address']?['city'] ??
            data['address']?['town'] ??
            data['address']?['village'] ??
            data['address']?['municipality'] ??
            data['address']?['county'] ??
            data['address']?['state'];

        if (cityName != null && cityName.isNotEmpty) {
          return cityName;
        }
      }
    } catch (e) {
      print('Geocoding xətası: $e');
    }

    return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
  }


  void _onMapTap(TapPosition tapPosition, LatLng position) async {
    print('🗺️ Harita tıklandı: ${position.latitude}, ${position.longitude}');

    setState(() {
      selectedPosition = position;
      isLoading = true;
      selectedLocationName = 'Yüklənir...';
    });


    final name = await _getLocationName(position.latitude, position.longitude);

    print('📍 Alınan yer adı: $name');

    setState(() {
      selectedLocationName = name;
      isLoading = false;
    });
  }


  void _confirmLocation() {
    if (selectedPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Xahiş edirik xəritədən bir mövqe seçin',
            style: TextStyle(fontFamily: 'MyFont2'),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ KONUM ONAYLANDI');
    print('📍 Seçilen konum: $selectedLocationName');
    print('📍 Koordinatlar: ${selectedPosition!.latitude}, ${selectedPosition!.longitude}');

    final location = CityLocation(
      name: 'Xəritə: $selectedLocationName',
      country: 'Azerbaijan',
      latitude: selectedPosition!.latitude,
      longitude: selectedPosition!.longitude,
      timezone: 'Asia/Baku',
      isGpsLocation: true,
    );

    print('📦 Oluşturulan CityLocation:');
    print('   - name: ${location.name}');
    print('   - latitude: ${location.latitude}');
    print('   - longitude: ${location.longitude}');
    print('   - isGpsLocation: ${location.isGpsLocation}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    Navigator.of(context).pop(location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Xəritədən Seçin',
          style: TextStyle(fontFamily: 'MyFont2'),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [

          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: selectedPosition ??
                  const LatLng(40.4093, 49.8671),
              initialZoom: selectedPosition != null ? 13.0 : 7.0,
              onTap: _onMapTap,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [

              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.namaz_vakti',
                maxZoom: 19,
              ),


              if (selectedPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: selectedPosition!,
                      width: 80,
                      height: 80,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 50,
                      ),
                    ),
                  ],
                ),
            ],
          ),


          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Seçilən mövqe:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontFamily: 'MyFont2',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (isLoading)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        if (isLoading) const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            selectedLocationName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'MyFont2',
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (selectedPosition != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${selectedPosition!.latitude.toStringAsFixed(4)}, ${selectedPosition!.longitude.toStringAsFixed(4)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontFamily: 'MyFont2',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),


          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                ElevatedButton.icon(
                  onPressed: () async {
                    setState(() => isLoading = true);

                    final locationService = LocationService();
                    final position = await locationService.getCurrentLocation();

                    if (position != null) {
                      final latLng = LatLng(position.latitude, position.longitude);

                      setState(() {
                        selectedPosition = latLng;

                        selectedLocationName = _getCleanCityName(position.name);
                        isLoading = false;
                      });

                      mapController.move(latLng, 15.0);
                    } else {
                      setState(() => isLoading = false);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'GPS mövqe alına bilmədi',
                              style: TextStyle(fontFamily: 'MyFont2'),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.my_location),
                  label: const Text(
                    'Hal-hazırkı mövqe',
                    style: TextStyle(fontFamily: 'MyFont2'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.teal,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),

                const SizedBox(height: 8),


                ElevatedButton.icon(
                  onPressed: selectedPosition != null && !isLoading
                      ? _confirmLocation
                      : null,
                  icon: const Icon(Icons.check),
                  label: const Text(
                    'Təsdiq et',
                    style: TextStyle(fontFamily: 'MyFont2'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),


          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height / 2 - 60,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'zoom_in',
                  onPressed: () {
                    final zoom = mapController.camera.zoom;
                    mapController.move(
                      mapController.camera.center,
                      zoom + 1,
                    );
                  },
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.add, color: Colors.teal),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom_out',
                  onPressed: () {
                    final zoom = mapController.camera.zoom;
                    mapController.move(
                      mapController.camera.center,
                      zoom - 1,
                    );
                  },
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.remove, color: Colors.teal),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}