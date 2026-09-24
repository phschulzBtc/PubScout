import 'dart:math';

double distanceKm(double lat1, double lng1, double lat2, double lng2) {
  const earthRadiusKm = 6371.0;
  final dLat = _toRadians(lat2 - lat1);
  final dLng = _toRadians(lng2 - lng1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRadians(lat1)) *
          cos(_toRadians(lat2)) *
          sin(dLng / 2) *
          sin(dLng / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadiusKm * c;
}

String formatDistance(double km) {
  if (km < 1) return '${(km * 1000).round()} m';
  return '${km.toStringAsFixed(1)} km';
}

String venueTypeLabel(String type) {
  return switch (type) {
    'pub' => 'Kneipe',
    'bar' => 'Bar',
    'biergarten' => 'Biergarten',
    'nightclub' => 'Nachtclub',
    _ => type,
  };
}

double _toRadians(double degrees) => degrees * pi / 180;
