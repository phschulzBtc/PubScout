import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../core/constants.dart';

class LocationService {
  static const _defaultLocation = LatLng(defaultLatitude, defaultLongitude);

  Future<LatLng> getCurrentLocation() async {
    try {
      // Skip checkPermission/requestPermission — on web these often return
      // "denied" even though the browser will show its own permission prompt
      // when getCurrentPosition is called.  Calling getCurrentPosition
      // directly triggers the browser dialog and works on all platforms.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      return _defaultLocation;
    }
  }
}
