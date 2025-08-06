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
        pump.crowd = parseCrowdLevel(crowdLevelString);
      } catch (e) {
        print("❌ Failed to get crowd level for ${pump.name}: $e");
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

  /// 📍 Fetch full formatted address using Google Places Details API
  Future<void> updateFullAddresses({
    required String apiKey,
  }) async {
    for (var pump in _pumps) {
      if (pump.placeId == null || pump.placeId!.isEmpty) {
        print("⏩ Skipping ${pump.name} — no placeId available");
        continue;
      }

      try {
        final detailsUrl =
            "https://maps.googleapis.com/maps/api/place/details/json"
            "?place_id=${pump.placeId}&fields=formatted_address&key=$apiKey";

        final response = await ApiService.get(detailsUrl);

        if (response['status'] != "OK") {
          print("⚠️ Google Details API failed for ${pump.name}: ${response['status']}");
          pump.fullAddress = pump.address;
          continue;
        }

        final json = response['result'];
        final formattedAddress = json['formatted_address'];

        if (formattedAddress != null && formattedAddress.isNotEmpty) {
          pump.fullAddress = formattedAddress;
        } else {
          print("⚠️ No formatted_address found for ${pump.name}");
          pump.fullAddress = pump.address;
        }

      } catch (e) {
        print("❌ Exception getting address for ${pump.name}: $e");
        pump.fullAddress = pump.address;
      }
    }
  }
}
