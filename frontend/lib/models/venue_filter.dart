import 'package:meta/meta.dart';

import '../core/constants.dart';

@immutable
class VenueFilter {
  final double lat;
  final double lng;
  final double radiusKm;
  final List<String> activities;
  final List<String> venueTypes;
  final bool wheelchairOnly;

  const VenueFilter({
    this.lat = defaultLatitude,
    this.lng = defaultLongitude,
    this.radiusKm = defaultSearchRadiusKm,
    this.activities = const [],
    this.venueTypes = const [],
    this.wheelchairOnly = false,
  });

  VenueFilter copyWith({
    double? lat,
    double? lng,
    double? radiusKm,
    List<String>? activities,
    List<String>? venueTypes,
    bool? wheelchairOnly,
  }) {
    return VenueFilter(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      radiusKm: radiusKm ?? this.radiusKm,
      activities: activities ?? this.activities,
      venueTypes: venueTypes ?? this.venueTypes,
      wheelchairOnly: wheelchairOnly ?? this.wheelchairOnly,
    );
  }
}
