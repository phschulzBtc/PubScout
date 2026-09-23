import 'package:flutter_test/flutter_test.dart';
import 'package:pubscout/services/mock_api_client.dart';

void main() {
  late MockApiClient client;

  setUp(() {
    client = MockApiClient();
  });

  group('MockApiClient', () {
    test('fetchActivities returns 8 activities', () async {
      final activities = await client.fetchActivities();

      expect(activities, hasLength(8));
      expect(activities.map((a) => a.name), contains('Darts'));
      expect(activities.map((a) => a.name), contains('Billard'));
    });

    test('fetchVenues returns mock venues', () async {
      final venues = await client.fetchVenues(lat: 52.52, lng: 13.405);

      expect(venues, isNotEmpty);
      for (final venue in venues) {
        expect(venue.name, isNotEmpty);
        expect(venue.activities, isNotEmpty);
        expect(venue.osmId, startsWith('node/'));
      }
    });

    test('fetchVenues filters by activity', () async {
      final venues = await client.fetchVenues(
        lat: 52.52,
        lng: 13.405,
        activities: ['Darts'],
      );

      expect(venues, isNotEmpty);
      for (final venue in venues) {
        expect(
          venue.activities.any((a) => a.name == 'Darts'),
          isTrue,
        );
      }
    });

    test('fetchVenues with unknown activity returns empty', () async {
      final venues = await client.fetchVenues(
        lat: 52.52,
        lng: 13.405,
        activities: ['NonExistent'],
      );

      expect(venues, isEmpty);
    });
  });
}
