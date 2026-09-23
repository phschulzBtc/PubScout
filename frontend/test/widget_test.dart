import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pubscout/app.dart';
import 'package:pubscout/providers/venue_provider.dart';
import 'package:pubscout/providers/location_provider.dart';
import 'package:pubscout/models/venue.dart';
import 'package:pubscout/models/activity.dart';
import 'package:pubscout/services/location_service.dart';
import 'package:latlong2/latlong.dart';

/// A LocationService that returns immediately without platform calls.
class FakeLocationService extends LocationService {
  @override
  Future<LatLng> getCurrentLocation() async =>
      const LatLng(52.52, 13.405);
}

void main() {
  final testOverrides = [
    venueProvider.overrideWith((ref) => Future.value(<Venue>[])),
    locationServiceProvider.overrideWithValue(FakeLocationService()),
  ];

  testWidgets('PubScout app renders map screen with title', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: testOverrides,
        child: const PubScoutApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('PubScout'), findsOneWidget);
  });

  testWidgets('MapScreen shows my-location FAB', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: testOverrides,
        child: const PubScoutApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.my_location), findsOneWidget);
  });

  testWidgets('MapScreen shows venue count when loaded', (tester) async {
    final mockVenues = [
      const Venue(
        name: 'Test Bar',
        latitude: 52.52,
        longitude: 13.405,
        osmId: 'node/1',
        activities: [Activity(name: 'Darts', icon: 'darts')],
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          venueProvider.overrideWith((ref) => Future.value(mockVenues)),
          locationServiceProvider.overrideWithValue(FakeLocationService()),
        ],
        child: const PubScoutApp(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('1 Venues'), findsOneWidget);
  });
}
