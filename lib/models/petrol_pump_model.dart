import 'package:google_maps_flutter/google_maps_flutter.dart';

enum CrowdLevel { green, yellow, orange, red }

class PetrolPump {
  final String name;
  final LatLng location;
  final double distance;
  final double? rating;
  CrowdLevel? crowd;

  PetrolPump({
    required this.name,
    required this.location,
    required this.distance,
    this.rating,
    this.crowd,
  });

  // ✅ Fix: This method is now correctly placed and uses 'crowd' instead of 'crowdLevel'
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
        crowd = null;
    }
  }
}
