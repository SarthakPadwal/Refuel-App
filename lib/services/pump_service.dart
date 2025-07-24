// services/pump_service.dart
import '../models/petrol_pump_model.dart';

class PumpService {
  static final PumpService _instance = PumpService._internal();

  factory PumpService() => _instance;

  PumpService._internal();

  List<PetrolPump> _pumps = [];

  void setPumps(List<PetrolPump> pumps) {
    _pumps = pumps;
  }

  List<PetrolPump> get pumps => _pumps;
}
