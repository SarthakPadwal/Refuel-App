import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  final String _apiKey = 'AIzaSyAYk6MBrQZlFU6hO-iYprSOF8wUwkgbTMA';
  Circle? _circle;
  bool _isLoading = true;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _initLocationAndPlaces();
  }

  Future<void> _initLocationAndPlaces() async {
    try {
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

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _circle = Circle(
          circleId: const CircleId('user_radius'),
          center: LatLng(position.latitude, position.longitude),
          radius: 3000,
          strokeColor: Colors.red,
          strokeWidth: 2,
          fillColor: Colors.red.withOpacity(0.1),
        );
      });

      await _loadNearbyPetrolPumps(position);
    } catch (e) {
      debugPrint('❌ Location error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNearbyPetrolPumps(Position position) async {
    final places = GoogleMapsPlaces(apiKey: _apiKey);
    final result = await places.searchNearbyWithRadius(
      Location(lat: position.latitude, lng: position.longitude),
      3000,
      type: "gas_station",
    );

    if (result.status == "OK") {
      debugPrint("🟢 Found ${result.results.length} petrol pumps.");
      final newMarkers = result.results.map((place) {
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
    } else {
      debugPrint("⚠️ Places API error: ${result.errorMessage}");
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
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
      body: _isLoading || _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        onMapCreated: (controller) => _mapController = controller,
        initialCameraPosition: CameraPosition(
          target: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          zoom: 13.5,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: _markers,
        circles: _circle != null ? {_circle!} : {},
        mapType: MapType.normal,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.blue,
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
}
