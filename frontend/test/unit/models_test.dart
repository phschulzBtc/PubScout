import 'package:flutter_test/flutter_test.dart';
import 'package:pubscout/models/activity.dart';
import 'package:pubscout/models/venue.dart';

void main() {
  group('Activity', () {
    test('fromJson parses correctly', () {
      final json = {
        'name': 'Darts',
        'icon': 'darts',
        'osm_tags': ['leisure=darts', 'sport=darts'],
      };
      final activity = Activity.fromJson(json);

      expect(activity.name, 'Darts');
      expect(activity.icon, 'darts');
      expect(activity.osmTags, ['leisure=darts', 'sport=darts']);
    });

    test('fromJson handles missing osm_tags', () {
      final json = {'name': 'Darts', 'icon': 'darts'};
      final activity = Activity.fromJson(json);

      expect(activity.osmTags, isEmpty);
    });

    test('fromJson throws on missing name', () {
      expect(
        () => Activity.fromJson({'icon': 'darts'}),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromJson throws on missing icon', () {
      expect(
        () => Activity.fromJson({'name': 'Darts'}),
        throwsA(isA<FormatException>()),
      );
    });

    test('toJson round-trips correctly', () {
      const activity = Activity(
        name: 'Darts',
        icon: 'darts',
        osmTags: ['leisure=darts'],
      );
      final json = activity.toJson();
      final restored = Activity.fromJson(json);

      expect(restored.name, activity.name);
      expect(restored.icon, activity.icon);
      expect(restored.osmTags, activity.osmTags);
    });

    test('equality works by name and icon', () {
      const a = Activity(name: 'Darts', icon: 'darts');
      const b = Activity(name: 'Darts', icon: 'darts', osmTags: ['x=y']);
      const c = Activity(name: 'Pool', icon: 'pool');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString is readable', () {
      const activity = Activity(name: 'Darts', icon: 'darts');
      expect(activity.toString(), 'Activity(name: Darts, icon: darts)');
    });
  });

  group('Venue', () {
    test('fromJson parses correctly', () {
      final json = {
        'name': 'Test Bar',
        'latitude': 52.52,
        'longitude': 13.405,
        'address': 'Teststr. 1',
        'osm_id': 'node/123',
        'activities': [
          {'name': 'Darts', 'icon': 'darts', 'osm_tags': []},
        ],
      };
      final venue = Venue.fromJson(json);

      expect(venue.name, 'Test Bar');
      expect(venue.latitude, 52.52);
      expect(venue.longitude, 13.405);
      expect(venue.address, 'Teststr. 1');
      expect(venue.osmId, 'node/123');
      expect(venue.activities, hasLength(1));
      expect(venue.activities.first.name, 'Darts');
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'name': 'Minimal Bar',
        'latitude': 52.0,
        'longitude': 13.0,
      };
      final venue = Venue.fromJson(json);

      expect(venue.address, '');
      expect(venue.osmId, '');
      expect(venue.activities, isEmpty);
    });

    test('fromJson throws on missing name', () {
      expect(
        () => Venue.fromJson({'latitude': 52.0, 'longitude': 13.0}),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromJson throws on missing latitude', () {
      expect(
        () => Venue.fromJson({'name': 'Bar', 'longitude': 13.0}),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromJson throws on invalid latitude type', () {
      expect(
        () => Venue.fromJson({
          'name': 'Bar',
          'latitude': 'not a number',
          'longitude': 13.0,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('toJson round-trips correctly', () {
      const venue = Venue(
        name: 'Test',
        latitude: 52.0,
        longitude: 13.0,
        address: 'Addr',
        osmId: 'node/1',
        activities: [Activity(name: 'Pool', icon: 'pool')],
      );
      final json = venue.toJson();
      final restored = Venue.fromJson(json);

      expect(restored.name, venue.name);
      expect(restored.latitude, venue.latitude);
      expect(restored.activities.first.name, 'Pool');
    });

    test('equality works by osmId and name', () {
      const a = Venue(name: 'Bar', latitude: 52.0, longitude: 13.0, osmId: 'node/1');
      const b = Venue(name: 'Bar', latitude: 99.0, longitude: 99.0, osmId: 'node/1');
      const c = Venue(name: 'Other', latitude: 52.0, longitude: 13.0, osmId: 'node/2');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('toString is readable', () {
      const venue = Venue(name: 'Bar', latitude: 52.0, longitude: 13.0, osmId: 'n/1');
      expect(venue.toString(), 'Venue(name: Bar, osmId: n/1)');
    });
  });
}
