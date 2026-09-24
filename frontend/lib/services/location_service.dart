import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../core/constants.dart';

class LocationService {
  static const _defaultLocation = LatLng(defaultLatitude, defaultLongitude);

  Future<LatLng> getCurrentLocation() async {
    try {
      // On web, use the browser Geolocation API directly via geolocator_web.
      // checkPermission/requestPermission are unreliable on web — the browser
      // shows its own permission dialog when getCurrentPosition is called.
      if (!kIsWeb) {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          dev.log('Location services disabled');
          return _defaultLocation;
        }

        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          dev.log('Location permission denied: $permission');
          return _defaultLocation;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );
      dev.log('Got location: ${position.latitude}, ${position.longitude}');
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      dev.log('Location error: $e');
      return _defaultLocation;
    }
  }
}
