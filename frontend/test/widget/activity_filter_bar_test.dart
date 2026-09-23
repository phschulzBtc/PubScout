import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pubscout/models/activity.dart';
import 'package:pubscout/providers/activity_provider.dart';
import 'package:pubscout/providers/venue_provider.dart';
import 'package:pubscout/providers/location_provider.dart';
import 'package:pubscout/services/location_service.dart';
import 'package:pubscout/widgets/activity_filter_bar.dart';
import 'package:pubscout/models/venue.dart';
import 'package:latlong2/latlong.dart';

class FakeLocationService extends LocationService {
  @override
  Future<LatLng> getCurrentLocation() async =>
      const LatLng(52.52, 13.405);
}

const _testActivities = [
  Activity(name: 'Darts', icon: 'darts'),
  Activity(name: 'Billard', icon: 'billiards'),
  Activity(name: 'Kicker', icon: 'foosball'),
];

Widget _buildTestWidget() {
  return ProviderScope(
    overrides: [
      activityProvider.overrideWith((ref) => Future.value(_testActivities)),
      venueProvider.overrideWith((ref) => Future.value(<Venue>[])),
      locationServiceProvider.overrideWithValue(FakeLocationService()),
    ],
    child: const MaterialApp(
      home: Scaffold(body: ActivityFilterBar()),
    ),
  );
}

void main() {
  testWidgets('renders chips for all activities', (tester) async {
    await tester.pumpWidget(_buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Darts'), findsOneWidget);
    expect(find.text('Billard'), findsOneWidget);
    expect(find.text('Kicker'), findsOneWidget);
  });

  testWidgets('tapping chip selects it', (tester) async {
    await tester.pumpWidget(_buildTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Darts'));
    await tester.pumpAndSettle();

    final chip = tester.widget<FilterChip>(
      find.ancestor(of: find.text('Darts'), matching: find.byType(FilterChip)),
    );
    expect(chip.selected, isTrue);
  });

  testWidgets('tapping selected chip deselects it', (tester) async {
    await tester.pumpWidget(_buildTestWidget());
    await tester.pumpAndSettle();

    // Select
    await tester.tap(find.text('Darts'));
    await tester.pumpAndSettle();

    // Deselect
    await tester.tap(find.text('Darts'));
    await tester.pumpAndSettle();

    final chip = tester.widget<FilterChip>(
      find.ancestor(of: find.text('Darts'), matching: find.byType(FilterChip)),
    );
    expect(chip.selected, isFalse);
  });

  testWidgets('multiple chips can be selected', (tester) async {
    await tester.pumpWidget(_buildTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Darts'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Billard'));
    await tester.pumpAndSettle();

    final dartsChip = tester.widget<FilterChip>(
      find.ancestor(of: find.text('Darts'), matching: find.byType(FilterChip)),
    );
    final billardChip = tester.widget<FilterChip>(
      find.ancestor(
          of: find.text('Billard'), matching: find.byType(FilterChip)),
    );
    expect(dartsChip.selected, isTrue);
    expect(billardChip.selected, isTrue);
  });

}
