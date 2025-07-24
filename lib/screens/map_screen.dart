import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import '../services/pump_service.dart';
import '../models/petrol_pump_model.dart';
import 'package:dotted_line/dotted_line.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  LatLng? _mapCenter;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  final String _apiKey = 'AIzaSyAYk6MBrQZlFU6hO-iYprSOF8wUwkgbTMA';
  Circle? _circle;
  bool _isLoading = true;
  int _selectedIndex = 1;
  int _selectedServiceIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _serviceTypes = [
    "petrol pump",
    "cng pump",
    "electric vehicle charging station",
    "car repair"
  ];

  final List<String> _serviceLabels = [
    "Petrol / Diesel",
    "CNG",
    "EV",
    "Mechanic"
  ];

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

      _mapCenter = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentPosition = position;
        _circle = Circle(
          circleId: const CircleId('user_radius'),
          center: _mapCenter!,
          radius: 3000,
          strokeColor: Colors.red,
          strokeWidth: 2,
          fillColor: Colors.red.withOpacity(0.1),
        );
      });

      await _loadNearbyPlaces(_serviceTypes[_selectedServiceIndex]);
    } catch (e) {
      debugPrint('❌ Location error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNearbyPlaces(String placeType) async {
    if (_mapCenter == null) return;
    final places = GoogleMapsPlaces(apiKey: _apiKey);
    final result = await places.searchNearbyWithRadius(
      Location(lat: _mapCenter!.latitude, lng: _mapCenter!.longitude),
      3000,
      keyword: placeType,
    );

    setState(() {
      _markers.clear();
    });

    if (result.status == "OK" && result.results.isNotEmpty) {
      final newMarkers = <Marker>{};
      final newPumps = <PetrolPump>[];

      for (var place in result.results) {
        final lat = place.geometry!.location.lat;
        final lng = place.geometry!.location.lng;
        final distance = Geolocator.distanceBetween(
          _mapCenter!.latitude,
          _mapCenter!.longitude,
          lat,
          lng,
        );

        if (distance <= 3000) {
          newMarkers.add(Marker(
            markerId: MarkerId(place.placeId),
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
            infoWindow: InfoWindow(title: place.name),
          ));

          newPumps.add(
            PetrolPump(
              name: place.name ?? 'Unknown',
              location: LatLng(lat, lng),
              distance: distance,
              rating: place.rating?.toDouble(),
            ),
          );
        }
      }

      PumpService().setPumps(newPumps);

      setState(() {
        _markers.addAll(newMarkers);
      });
    } else {
      debugPrint("⚠️ No nearby results found for $placeType");
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

  Widget buildFilterButton(String label, int index) {
    bool isSelected = _selectedServiceIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() => _selectedServiceIndex = index);
          _loadNearbyPlaces(_serviceTypes[index]);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFFFFD0C9) : const Color(0xFFE9E9E9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isSelected ? const Color(0xFFAF0505) : Colors.black,
        ),
      ),
    ),
  );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading || _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/search'),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: 'Search...',
                          fillColor: Colors.grey[200],
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(
                _serviceLabels.length,
                    (index) => buildFilterButton(_serviceLabels[index], index),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) => _mapController = controller,
              initialCameraPosition: CameraPosition(
                target: _mapCenter!,
                zoom: 13.5,
              ),
              onCameraMove: (position) {
                _mapCenter = position.target;
                setState(() {
                  _circle = Circle(
                    circleId: const CircleId('user_radius'),
                    center: _mapCenter!,
                    radius: 3000,
                    strokeColor: Colors.red,
                    strokeWidth: 2,
                    fillColor: Colors.red.withOpacity(0.1),
                  );
                });
              },
              onCameraIdle: () => _loadNearbyPlaces(_serviceTypes[_selectedServiceIndex]),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: _markers,
              circles: _circle != null ? {_circle!} : {},
              mapType: MapType.normal,
            ),
          ),
        ],
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
        dashColor: Color(0xFFFF725E), // Your orange color
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
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
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
  ],
),
    );
  }
}