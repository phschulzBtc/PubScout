import 'package:flutter_test/flutter_test.dart';
import 'package:pubscout/services/nominatim_service.dart';

void main() {
  group('NominatimResult', () {
    test('fromJson parses correctly', () {
      final json = {
        'display_name': 'Berlin, Deutschland',
        'lat': '52.5200',
        'lon': '13.4050',
      };
      final result = NominatimResult.fromJson(json);

      expect(result.displayName, 'Berlin, Deutschland');
      expect(result.latitude, 52.52);
      expect(result.longitude, 13.405);
    });
  });

  group('NominatimService', () {
    test('returns empty list for short queries', () async {
      final service = NominatimService();
      final results = await service.search('a');
      expect(results, isEmpty);
    });

    test('returns empty list for empty query', () async {
      final service = NominatimService();
      final results = await service.search('');
      expect(results, isEmpty);
    });
  });
}
