import 'package:google_maps_flutter/google_maps_flutter.dart';

class PetrolPump {
  final String name;
  final LatLng location;
  final double distance;
  final double? rating;

  PetrolPump({
    required this.name,
    required this.location,
    required this.distance,
    this.rating,
  });
}
