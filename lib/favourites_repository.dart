import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'pumps_map_screen.dart'; // Replace with the correct file name where PumpInfo is defined

class FavouritesRepository {
  static final List<PumpInfo> _favourites = [];

  static List<PumpInfo> get favourites => _favourites;

  static void add(PumpInfo pump) {
    if (!_favourites.any((p) => _isSameLocation(p.location, pump.location))) {
      _favourites.add(pump);
    }
  }

  static void remove(PumpInfo pump) {
    _favourites.removeWhere((p) => _isSameLocation(p.location, pump.location));
  }

  static bool contains(PumpInfo pump) {
    return _favourites.any((p) => _isSameLocation(p.location, pump.location));
  }

  static bool _isSameLocation(LatLng a, LatLng b) {
    return a.latitude == b.latitude && a.longitude == b.longitude;
  }
}
