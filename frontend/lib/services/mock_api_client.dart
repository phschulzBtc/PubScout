import 'dart:math';

import '../core/constants.dart';
import '../models/activity.dart';
import '../models/venue.dart';
import 'api_client.dart';

class MockApiClient implements ApiClient {
  @override
  Future<List<Activity>> fetchActivities() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const [
      Activity(name: 'Billard', icon: 'billiards', osmTags: ['sport=billiards']),
      Activity(name: 'Brettspiele', icon: 'board_games', osmTags: ['leisure=board_game']),
      Activity(name: 'Darts', icon: 'darts', osmTags: ['leisure=darts', 'sport=darts']),
      Activity(name: 'Kicker', icon: 'foosball', osmTags: ['sport=table_soccer']),
      Activity(name: 'Pool', icon: 'pool', osmTags: ['sport=pool']),
      Activity(name: 'Quiz/Trivia', icon: 'quiz', osmTags: ['quiz=yes']),
      Activity(name: 'Shuffleboard', icon: 'shuffleboard', osmTags: ['sport=shuffleboard']),
      Activity(name: 'Tischtennis', icon: 'table_tennis', osmTags: ['sport=table_tennis']),
    ];
  }

  @override
  Future<List<Venue>> fetchVenues({
    required double lat,
    required double lng,
    double radiusKm = defaultSearchRadiusKm,
    List<String>? activities,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    var venues = _mockVenues(lat, lng);

    venues = venues
        .where((v) => _distanceKm(lat, lng, v.latitude, v.longitude) <= radiusKm)
        .toList();

    if (activities != null && activities.isNotEmpty) {
      venues = venues
          .where((v) => v.activities.any((a) => activities.contains(a.name)))
          .toList();
    }

    return venues;
  }

  /// Haversine distance in kilometers.
  double _distanceKm(double lat1, double lng1, double lat2, double lng2) {
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

  double _toRadians(double degrees) => degrees * pi / 180;

  List<Venue> _mockVenues(double lat, double lng) {
    return [
      Venue(
        name: 'The Dart Pub',
        latitude: lat + 0.005,
        longitude: lng + 0.003,
        address: 'Kreuzbergstr. 12, Berlin',
        osmId: 'node/100001',
        openingHours: 'Mo-Fr 17:00-02:00; Sa-Su 15:00-03:00',
        activities: const [
          Activity(name: 'Darts', icon: 'darts'),
          Activity(name: 'Billard', icon: 'billiards'),
        ],
      ),
      Venue(
        name: 'Kickerbar Neukölln',
        latitude: lat - 0.003,
        longitude: lng + 0.007,
        address: 'Sonnenallee 45, Berlin',
        osmId: 'node/100002',
        openingHours: 'Mo-Su 16:00-01:00',
        activities: const [
          Activity(name: 'Kicker', icon: 'foosball'),
          Activity(name: 'Brettspiele', icon: 'board_games'),
        ],
      ),
      Venue(
        name: 'Pool Hall Mitte',
        latitude: lat + 0.008,
        longitude: lng - 0.004,
        address: 'Torstr. 78, Berlin',
        osmId: 'node/100003',
        openingHours: 'Mo-Sa 14:00-00:00; Su 16:00-22:00',
        activities: const [
          Activity(name: 'Pool', icon: 'pool'),
          Activity(name: 'Billard', icon: 'billiards'),
        ],
      ),
      Venue(
        name: 'Quiz Night Bar',
        latitude: lat - 0.006,
        longitude: lng - 0.002,
        address: 'Oranienstr. 33, Berlin',
        osmId: 'node/100004',
        activities: const [
          Activity(name: 'Quiz/Trivia', icon: 'quiz'),
          Activity(name: 'Darts', icon: 'darts'),
        ],
      ),
      Venue(
        name: 'Spielcafé Friedrichshain',
        latitude: lat + 0.002,
        longitude: lng + 0.009,
        address: 'Boxhagener Str. 15, Berlin',
        osmId: 'node/100005',
        openingHours: 'Tu-Su 12:00-22:00',
        activities: const [
          Activity(name: 'Brettspiele', icon: 'board_games'),
          Activity(name: 'Tischtennis', icon: 'table_tennis'),
        ],
      ),
    ];
  }
}
