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

final venueProvider = FutureProvider<List<Venue>>((ref) async {
  final client = ref.watch(apiClientProvider);
  final filter = ref.watch(venueFilterProvider);

  return client.fetchVenues(
    lat: filter.lat,
    lng: filter.lng,
    radiusKm: filter.radiusKm,
    activities: filter.activities.isEmpty ? null : filter.activities,
  );
});
