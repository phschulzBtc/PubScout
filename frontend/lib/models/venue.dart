import 'package:meta/meta.dart';

import 'activity.dart';

@immutable
class Venue {
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final String osmId;
  final String openingHours;
  final String description;
  final String website;
  final String phone;
  final bool outdoorSeating;
  final String wheelchair;
  final String venueType;
  final List<Activity> activities;

  const Venue({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address = '',
    this.osmId = '',
    this.openingHours = '',
    this.description = '',
    this.website = '',
    this.phone = '',
    this.outdoorSeating = false,
    this.wheelchair = '',
    this.venueType = 'pub',
    this.activities = const [],
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final lat = json['latitude'];
    final lng = json['longitude'];
    if (name is! String) {
      throw FormatException('Venue: missing or invalid "name" field', json);
    }
    if (lat is! num) {
      throw FormatException(
          'Venue: missing or invalid "latitude" field', json);
    }
    if (lng is! num) {
      throw FormatException(
          'Venue: missing or invalid "longitude" field', json);
    }
    return Venue(
      name: name,
      latitude: lat.toDouble(),
      longitude: lng.toDouble(),
      address: json['address'] as String? ?? '',
      osmId: json['osm_id'] as String? ?? '',
      openingHours: json['opening_hours'] as String? ?? '',
      description: json['description'] as String? ?? '',
      website: json['website'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      outdoorSeating: json['outdoor_seating'] as bool? ?? false,
      wheelchair: json['wheelchair'] as String? ?? '',
      venueType: json['venue_type'] as String? ?? 'pub',
      activities: (json['activities'] as List<dynamic>?)
              ?.map((e) => Activity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'osm_id': osmId,
        'opening_hours': openingHours,
        'description': description,
        'website': website,
        'phone': phone,
        'outdoor_seating': outdoorSeating,
        'wheelchair': wheelchair,
        'venue_type': venueType,
        'activities': activities.map((a) => a.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Venue &&
          runtimeType == other.runtimeType &&
          osmId == other.osmId &&
          name == other.name;

  @override
  int get hashCode => osmId.hashCode ^ name.hashCode;

  @override
  String toString() => 'Venue(name: $name, osmId: $osmId)';
}
