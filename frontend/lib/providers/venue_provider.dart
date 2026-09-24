import 'dart:async';

import 'package:riverpod/riverpod.dart';

import '../models/activity.dart';
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
    List<String>? venueTypes,
  }) {
    state = state.copyWith(
      lat: lat,
      lng: lng,
      radiusKm: radiusKm,
      activities: activities,
      venueTypes: venueTypes,
    );
  }
}

final venueFilterProvider =
    NotifierProvider<VenueFilterNotifier, VenueFilter>(VenueFilterNotifier.new);

class _VenueLoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

/// Whether a background venue fetch is in progress while stale data is shown.
final venueLoadingProvider =
    NotifierProvider<_VenueLoadingNotifier, bool>(_VenueLoadingNotifier.new);

class VenueNotifier extends AsyncNotifier<List<Venue>> {
  @override
  Future<List<Venue>> build() async {
    final client = ref.watch(apiClientProvider);
    final filter = ref.watch(venueFilterProvider);

    // Keep previous data visible while fetching new results.
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

    // Defer the loading flag update to avoid modifying another provider
    // during this provider's synchronous initialization phase.
    Future.microtask(() => ref.read(venueLoadingProvider.notifier).set(true));

    try {
      final venues = await client.fetchVenues(
        lat: filter.lat,
        lng: filter.lng,
        radiusKm: filter.radiusKm,
        activities: filter.activities.isEmpty ? null : filter.activities,
      );
      // Update available activity filters when fetching without filter,
      // so the filter bar shows only activities that exist in this area.
      if (filter.activities.isEmpty) {
        ref.read(availableActivitiesProvider.notifier).update(venues);
        ref.read(availableVenueTypesProvider.notifier).update(venues);
      }
      return venues;
    } finally {
      ref.read(venueLoadingProvider.notifier).set(false);
    }
  }
}

final venueProvider =
    AsyncNotifierProvider<VenueNotifier, List<Venue>>(VenueNotifier.new);

/// Activities that actually exist in the currently loaded (unfiltered) venues.
/// Updated each time a fresh venue fetch completes without activity filters.
class _AvailableActivitiesNotifier extends Notifier<List<Activity>> {
  @override
  List<Activity> build() => [];

  void update(List<Venue> venues) {
    final seen = <String>{};
    final activities = <Activity>[];
    for (final venue in venues) {
      for (final a in venue.activities) {
        if (seen.add(a.icon)) {
          activities.add(a);
        }
      }
    }
    activities.sort((a, b) => a.name.compareTo(b.name));
    state = activities;
  }
}

final availableActivitiesProvider =
    NotifierProvider<_AvailableActivitiesNotifier, List<Activity>>(
        _AvailableActivitiesNotifier.new);

/// Venue types that exist in the currently loaded venues.
class _AvailableVenueTypesNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  void update(List<Venue> venues) {
    final types = venues.map((v) => v.venueType).toSet().toList()..sort();
    state = types;
  }
}

final availableVenueTypesProvider =
    NotifierProvider<_AvailableVenueTypesNotifier, List<String>>(
        _AvailableVenueTypesNotifier.new);

/// Count of venues per activity icon in the current (unfiltered) dataset.
final activityCountsProvider = Provider<Map<String, int>>((ref) {
  final venues = ref.watch(venueProvider).value ?? [];
  final counts = <String, int>{};
  for (final venue in venues) {
    for (final a in venue.activities) {
      counts[a.icon] = (counts[a.icon] ?? 0) + 1;
    }
  }
  return counts;
});

/// Count of venues per venue type in the current (unfiltered) dataset.
final venueTypeCountsProvider = Provider<Map<String, int>>((ref) {
  final venues = ref.watch(venueProvider).value ?? [];
  final counts = <String, int>{};
  for (final venue in venues) {
    counts[venue.venueType] = (counts[venue.venueType] ?? 0) + 1;
  }
  return counts;
});

/// Venues filtered client-side by venue type selection.
final filteredVenueProvider = Provider<AsyncValue<List<Venue>>>((ref) {
  final venues = ref.watch(venueProvider);
  final selectedTypes = ref.watch(venueFilterProvider).venueTypes;
  if (selectedTypes.isEmpty) return venues;
  return venues.whenData(
    (list) => list.where((v) => selectedTypes.contains(v.venueType)).toList(),
  );
});
