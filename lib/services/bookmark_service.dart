import 'package:flutter/material.dart';
import '../models/petrol_pump_model.dart'; // Adjust path

class BookmarkService extends ChangeNotifier {
  final List<PetrolPump> _bookmarked = [];

  List<PetrolPump> get bookmarked => _bookmarked;

  void toggleBookmark(PetrolPump pump) {
    if (_bookmarked.contains(pump)) {
      _bookmarked.remove(pump);
    } else {
      _bookmarked.add(pump);
    }
    notifyListeners();
  }

  bool isBookmarked(PetrolPump pump) {
    return _bookmarked.contains(pump);
  }

  void remove(PetrolPump pump) {
    _bookmarked.remove(pump);
    notifyListeners();
  }
}
