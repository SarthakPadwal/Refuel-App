import 'package:google_maps_flutter/google_maps_flutter.dart';

enum CrowdLevel {
  green,
  yellow,
  orange,
  red,
  unknown,
}

class PetrolPump {
  final String name;
  final String imageUrl;
  final String status; // e.g., "Open Now" or "Closed"
  final LatLng location;
  final double distance; // in meters
  final double? rating;
  double estimatedTime; // in minutes
  final double petrolPrice;
  final double dieselPrice;
  CrowdLevel? crowd;
  final String address; // short address, e.g., locality
  String? fullAddress;  // complete formatted address, nullable
  final String? placeId; // added for Google Place Details API

  PetrolPump({
    required this.name,
    required this.imageUrl,
    required this.status,
    required this.location,
    required this.distance,
    required this.rating,
    required this.estimatedTime,
    required this.petrolPrice,
    required this.dieselPrice,
    this.crowd,
    required this.address,
    this.fullAddress,
    this.placeId,
  });

  void setCrowdLevelFromString(String crowdString) {
    switch (crowdString.toLowerCase()) {
      case 'green':
        crowd = CrowdLevel.green;
        break;
      case 'yellow':
        crowd = CrowdLevel.yellow;
        break;
      case 'orange':
        crowd = CrowdLevel.orange;
        break;
      case 'red':
        crowd = CrowdLevel.red;
        break;
      default:
        print('Unknown crowd level for string: $crowdString');
        crowd = CrowdLevel.unknown;
    }
  }
}
