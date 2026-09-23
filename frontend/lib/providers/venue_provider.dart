import 'package:riverpod/riverpod.dart';

import '../models/venue.dart';
import '../models/venue_filter.dart';
import 'api_client_provider.dart';

class VenueFilterNotifier extends Notifier<VenueFilter> {
  @override
  VenueFilter build() => const VenueFilter();

  void update({
    double? lat,
    double? lng,
    double? radiusKm,
    List<String>? activities,
  }) {
    state = state.copyWith(
      lat: lat,
      lng: lng,
      radiusKm: radiusKm,
      activities: activities,
    );
  }
}

final venueFilterProvider =
    NotifierProvider<VenueFilterNotifier, VenueFilter>(VenueFilterNotifier.new);

class VenueNotifier extends AsyncNotifier<List<Venue>> {
  @override
  Future<List<Venue>> build() async {
    final client = ref.watch(apiClientProvider);
    final filter = ref.watch(venueFilterProvider);

    // While loading, show previous data filtered by current activity selection
    final previous = state.value;
    if (previous != null) {
      if (filter.activities.isEmpty) {
        state = AsyncData(previous);
      } else {
        final filtered = previous
            .where((v) => v.activities
                .any((a) => filter.activities.contains(a.icon)))
            .toList();
        state = AsyncData(filtered);
      }
    }

    return client.fetchVenues(
      lat: filter.lat,
      lng: filter.lng,
      radiusKm: filter.radiusKm,
      activities: filter.activities.isEmpty ? null : filter.activities,
    );
  }
}

final venueProvider =
    AsyncNotifierProvider<VenueNotifier, List<Venue>>(VenueNotifier.new);
