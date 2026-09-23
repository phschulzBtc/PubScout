import 'package:latlong2/latlong.dart';
import 'package:riverpod/riverpod.dart';

import '../services/location_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final userLocationProvider = FutureProvider<LatLng>((ref) async {
  final service = ref.watch(locationServiceProvider);
  return service.getCurrentLocation();
});
