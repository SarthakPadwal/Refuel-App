import 'package:google_maps_flutter/google_maps_flutter.dart';

enum CrowdLevel { green, yellow, orange, red , unknown, }

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
        crowd = CrowdLevel.unknown; // ✅ properly handle unknown cases
    }
  }

}
