import 'package:flutter_test/flutter_test.dart';
import 'package:pubscout/core/constants.dart';
import 'package:pubscout/models/venue_filter.dart';

void main() {
  group('VenueFilter', () {
    test('has correct defaults', () {
      const filter = VenueFilter();
      expect(filter.lat, defaultLatitude);
      expect(filter.lng, defaultLongitude);
      expect(filter.radiusKm, defaultSearchRadiusKm);
      expect(filter.activities, isEmpty);
    });

    test('copyWith updates only specified fields', () {
      const filter = VenueFilter();
      final updated = filter.copyWith(lat: 48.0, activities: ['Darts']);

      expect(updated.lat, 48.0);
      expect(updated.lng, defaultLongitude);
      expect(updated.radiusKm, defaultSearchRadiusKm);
      expect(updated.activities, ['Darts']);
    });

    test('copyWith preserves all fields when none specified', () {
      const filter = VenueFilter(
        lat: 48.0,
        lng: 11.0,
        radiusKm: 10.0,
        activities: ['Darts', 'Pool'],
      );
      final copy = filter.copyWith();

      expect(copy.lat, 48.0);
      expect(copy.lng, 11.0);
      expect(copy.radiusKm, 10.0);
      expect(copy.activities, ['Darts', 'Pool']);
    });
  });
}
