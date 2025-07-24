import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import '../services/pump_service.dart';
import '../models/petrol_pump_model.dart';

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
        circleId: CircleId("radius_circle"),
        center: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        radius: _radius,
        strokeColor: Colors.red,
        strokeWidth: 2,
        fillColor: Colors.red.withOpacity(0.1),
      );
    });

    if (result.status == "OK" && result.results.isNotEmpty) {
      final List<PetrolPump> nearbyPumps = [];
      final newMarkers = result.results.where((place) {
        final lat = place.geometry!.location.lat;
        final lng = place.geometry!.location.lng;
        final distance = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          lat,
          lng,
        );
        if (distance <= _radius) {
          nearbyPumps.add(
            PetrolPump(
              name: place.name,
              location: LatLng(lat, lng),
              distance: distance,
              rating: place.rating?.toDouble(),
            ),
          );
          return true;
        }
        return false;
      }).map((place) {
        return Marker(
          markerId: MarkerId(place.placeId),
          position: LatLng(
            place.geometry!.location.lat,
            place.geometry!.location.lng,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(title: place.name),
        );
      }).toSet();

      setState(() {
        _markers.addAll(newMarkers);
      });

      PumpService().setPumps(nearbyPumps);
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
                    color: Color(0xFFFFD0C9),
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
              onTap: () {
                Navigator.pushNamed(context, '/search');
              },
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: "Search",
                    filled: true,
                    fillColor: Color(0xFFE9E9E9),
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
                color: Color(0xFFFFE5E0),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
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
            color: isSelected ? Colors.orange.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? Colors.orange : Color(0xFFE9E9E9)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 30, color: isSelected ? Colors.orange : iconColor),
              const SizedBox(height: 10),
              Text(label, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? Colors.orange : Colors.black)),
            ],
          ),
        ),
      ),
    );
  }
}