import 'package:Refuel/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import '../services/pump_service.dart';
import '../models/petrol_pump_model.dart';
import 'package:dotted_line/dotted_line.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart' as geo;


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _selectedServiceIndex = 0;
  Position? _currentPosition;
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final String _apiKey = 'AIzaSyAYk6MBrQZlFU6hO-iYprSOF8wUwkgbTMA';
  Circle? _circle;
  final double _radius = 3000;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  double _getEstimatedTime(CrowdLevel level) {
    final random = Random();
    switch (level) {
      case CrowdLevel.green:
        return (5 + random.nextInt(6)).toDouble();
      case CrowdLevel.yellow:
        return (15 + random.nextInt(11)).toDouble();
      case CrowdLevel.orange:
        return (25 + random.nextInt(11)).toDouble();
      case CrowdLevel.red:
        return (40 + random.nextInt(11)).toDouble();
      case CrowdLevel.unknown:
      default:
        return (10 + random.nextInt(6)).toDouble();
    }
  }

  Future<String> _getAddressFromLatLng(double lat, double lng) async {
    try {
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return "${place.name}, ${place.locality}, ${place.administrativeArea}";
      }
    } catch (e) {
      print('Error getting address: \$e');
    }
    return "Unknown Location";
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return;
    }

    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() => _currentPosition = position);

    _loadNearbyPlaces("petrol pump", 0);

    Timer.periodic(Duration(minutes: 2), (_) {
      if (_currentPosition != null) {
        _loadNearbyPlaces("petrol pump", _selectedServiceIndex);
      }
    });
  }

  CrowdLevel _mapCrowdLevelFromString(String level) {
    switch (level) {
      case 'green':
        return CrowdLevel.green;
      case 'yellow':
        return CrowdLevel.yellow;
      case 'orange':
        return CrowdLevel.orange;
      case 'red':
        return CrowdLevel.red;
      default:
        return CrowdLevel.unknown;
    }
  }

  Future<void> _loadNearbyPlaces(String placeType, int index) async {
    if (_currentPosition == null) return;

    final places = GoogleMapsPlaces(apiKey: _apiKey);
    final result = await places.searchNearbyWithRadius(
      Location(lat: _currentPosition!.latitude, lng: _currentPosition!.longitude),
      _radius.toInt(),
      keyword: placeType,
    );

    setState(() {
      _selectedServiceIndex = index;
      _markers.clear();
      _circle = Circle(
        circleId: const CircleId("radius_circle"),
        center: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        radius: _radius,
        strokeColor: Colors.red,
        strokeWidth: 2,
        fillColor: Colors.red.withOpacity(0.1),
      );
    });

    if (result.status == "OK" && result.results.isNotEmpty) {
      final List<PetrolPump> nearbyPumps = [];

      for (final place in result.results) {
        final lat = place.geometry!.location.lat;
        final lng = place.geometry!.location.lng;

        final distance = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          lat,
          lng,
        );

        if (distance <= _radius) {
          final crowdString = await ApiService.getCrowdLevelMultiDirection(
            lat: lat,
            lng: lng,
            apiKey: _apiKey,
          );
          final crowdLevel = _mapCrowdLevelFromString(crowdString);

          final address = await _getAddressFromLatLng(lat, lng);

          final pump = PetrolPump(
            name: place.name,
            location: LatLng(lat, lng),
            distance: distance,
            rating: place.rating?.toDouble(),
            crowd: crowdLevel,
            imageUrl: (place.photos != null && place.photos!.isNotEmpty)
                ? "https://maps.googleapis.com/maps/api/place/photo"
                "?maxwidth=400"
                "&photoreference=${place.photos!.first.photoReference}"
                "&key=$_apiKey"
                : 'assets/images/station.jpg',
            status: "Open Now",
            estimatedTime: _getEstimatedTime(crowdLevel),
            petrolPrice: 104.77,
            dieselPrice: 90.03,
            address: address,
          );

          nearbyPumps.add(pump);
        }
      }

      final newMarkers = nearbyPumps.map((pump) {
        return Marker(
          markerId: MarkerId(pump.name),
          position: pump.location,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(
            title: pump.name,
            snippet: _crowdDescription(pump.crowd!),
          ),
        );
      }).toSet();

      setState(() {
        _markers.addAll(newMarkers);
      });

      PumpService().setPumps(nearbyPumps);
    }
  }

  String _crowdDescription(CrowdLevel level) {
    switch (level) {
      case CrowdLevel.green:
        return 'Low crowd';
      case CrowdLevel.yellow:
        return 'Moderate crowd';
      case CrowdLevel.orange:
        return 'High crowd';
      case CrowdLevel.red:
        return 'Very crowded';
      default:
        return 'Unknown';
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/map');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/saved');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/images/Brand.png', width: 230, height: 90),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD0C9),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.location_pin, color: Color(0xFFAF0505), size: 16),
                      SizedBox(width: 6, height: 35),
                      Text("GPM, Bandra", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFAF0505))),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 5),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/search'),
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: "Search...",
                    filled: true,
                    fillColor: const Color(0xFFE9E9E9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE5E0),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8)],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      buildOption(Icons.local_gas_station, "Petrol / Diesel", Colors.black, 0, () => _loadNearbyPlaces("petrol pump", 0)),
                      buildOption(Icons.gas_meter, "CNG", Colors.black, 1, () => _loadNearbyPlaces("cng pump", 1)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      buildOption(Icons.ev_station, "EV", Colors.black, 2, () => _loadNearbyPlaces("electric vehicle charging station", 2)),
                      buildOption(Icons.build, "Mechanic Service", Colors.black, 3, () => _loadNearbyPlaces("car repair", 3)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(" Map", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/map'),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _currentPosition == null
                      ? const Center(child: CircularProgressIndicator())
                      : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      zoom: 13.5,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: true,
                    markers: _markers,
                    circles: _circle != null ? {_circle!} : {},
                    mapType: MapType.normal,
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 1),
            child: DottedLine(
              dashLength: 7,
              dashGapLength: 4,
              lineThickness: 1.5,
              dashColor: Color(0xFFFF725E),
            ),
          ),
          BottomNavigationBar(
            backgroundColor: Colors.white,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.orange,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Map'),
              BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: 'Saved'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildOption(IconData icon, String label, Color iconColor, int index, VoidCallback onTap) {
    final bool isSelected = _selectedServiceIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFD0C9) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? const Color(0xFFAF0505) : const Color(0xFFE9E9E9)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 30, color: isSelected ? const Color(0xFFAF0505) : iconColor),
              const SizedBox(height: 10),
              Text(label, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? const Color(0xFFAF0505) : Colors.black)),
            ],
          ),
        ),
      ),
    );
  }
}
