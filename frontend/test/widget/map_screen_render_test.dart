import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pubscout/app.dart';
import 'package:pubscout/providers/api_client_provider.dart';
import 'package:pubscout/providers/location_provider.dart';
import 'package:pubscout/services/location_service.dart';
import 'package:pubscout/services/mock_api_client.dart';

class FakeLocationService extends LocationService {
  @override
  Future<LatLng> getCurrentLocation() async => const LatLng(52.52, 13.405);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
    'map screen renders with venue markers without MapController error',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(MockApiClient()),
            locationServiceProvider.overrideWithValue(FakeLocationService()),
          ],
          child: const PubScoutApp(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(tester.takeException(), isNull);
      expect(find.byType(FlutterMap), findsOneWidget);
    },
  );
}
