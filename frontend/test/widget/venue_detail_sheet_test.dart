import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pubscout/models/activity.dart';
import 'package:pubscout/models/venue.dart';
import 'package:pubscout/widgets/venue_detail_sheet.dart';

const _testVenue = Venue(
  name: 'Test Pub',
  latitude: 52.52,
  longitude: 13.405,
  address: 'Teststr. 1, Berlin',
  osmId: 'node/123',
  openingHours: 'Mo-Fr 17:00-02:00',
  activities: [
    Activity(name: 'Darts', icon: 'darts'),
    Activity(name: 'Billard', icon: 'billiards'),
  ],
);

Widget _buildSheet({Venue venue = _testVenue, double? userLat, double? userLng}) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => VenueDetailSheet(
              venue: venue,
              userLat: userLat,
              userLng: userLng,
            ),
          ),
          child: const Text('Open'),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows venue name and address', (tester) async {
    await tester.pumpWidget(_buildSheet());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Test Pub'), findsOneWidget);
    expect(find.text('Teststr. 1, Berlin'), findsOneWidget);
  });

  testWidgets('shows activity chips', (tester) async {
    await tester.pumpWidget(_buildSheet());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Darts'), findsOneWidget);
    expect(find.text('Billard'), findsOneWidget);
  });

  testWidgets('shows opening hours', (tester) async {
    await tester.pumpWidget(_buildSheet());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Mo-Fr 17:00-02:00'), findsOneWidget);
  });

  testWidgets('hides opening hours when empty', (tester) async {
    const venueNoHours = Venue(
      name: 'No Hours Bar',
      latitude: 52.0,
      longitude: 13.0,
    );
    await tester.pumpWidget(_buildSheet(venue: venueNoHours));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.access_time), findsNothing);
  });

  testWidgets('shows distance when user location provided', (tester) async {
    await tester.pumpWidget(_buildSheet(userLat: 52.52, userLng: 13.405));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.textContaining('entfernt'), findsOneWidget);
  });

  testWidgets('hides distance when no user location', (tester) async {
    await tester.pumpWidget(_buildSheet());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.straighten), findsNothing);
  });

  testWidgets('shows route button', (tester) async {
    await tester.pumpWidget(_buildSheet());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Route planen'), findsOneWidget);
    expect(find.byIcon(Icons.directions), findsOneWidget);
  });
}
