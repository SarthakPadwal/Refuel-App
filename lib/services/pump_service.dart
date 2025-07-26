import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/petrol_pump_model.dart';
import 'api_service.dart';

class PumpService {
  static final PumpService _instance = PumpService._internal();

  factory PumpService() => _instance;

  PumpService._internal();

  List<PetrolPump> _pumps = [];

  void setPumps(List<PetrolPump> pumps) {
    _pumps = pumps;
  }

  List<PetrolPump> get pumps => _pumps;

  /// 🔥 Update each pump with its crowd level using multi-directional traffic analysis
  Future<void> updateCrowdLevels({
    required LatLng currentLocation,
    required String apiKey,
  }) async {
    for (var pump in _pumps) {
      try {
        final crowdLevelString = await ApiService.getCrowdLevelMultiDirection(
          lat: pump.location.latitude,
          lng: pump.location.longitude,
          apiKey: apiKey,
        );
        pump.crowd = parseCrowdLevel(crowdLevelString); // ✅ Convert string to enum
      } catch (e) {
        print("Failed to get crowd level for ${pump.name}: $e");
        pump.crowd = null;
      }
    }
  }

  /// ✅ Helper method to convert crowd string to enum
  CrowdLevel? parseCrowdLevel(String level) {
    switch (level.toLowerCase()) {
      case 'green':
        return CrowdLevel.green;
      case 'yellow':
        return CrowdLevel.yellow;
      case 'orange':
        return CrowdLevel.orange;
      case 'red':
        return CrowdLevel.red;
      default:
        return null;
    }
  }
}
