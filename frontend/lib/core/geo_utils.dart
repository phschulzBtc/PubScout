import 'dart:math';

import '../l10n/app_localizations.dart';

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

/// Localized venue type label. Requires a BuildContext with AppLocalizations.
String venueTypeLabel(String type, AppLocalizations l10n) {
  return switch (type) {
    'pub' => l10n.venueTypePub,
    'bar' => l10n.venueTypeBar,
    'biergarten' => l10n.venueTypeBiergarten,
    'nightclub' => l10n.venueTypeNightclub,
    _ => type,
  };
}

double _toRadians(double degrees) => degrees * pi / 180;
