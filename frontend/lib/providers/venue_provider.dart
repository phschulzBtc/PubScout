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
    bool? wheelchairOnly,
  }) {
    state = state.copyWith(
      lat: lat,
      lng: lng,
      radiusKm: radiusKm,
      activities: activities,
      venueTypes: venueTypes,
      wheelchairOnly: wheelchairOnly,
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

final venueLoadingProvider =
    NotifierProvider<_VenueLoadingNotifier, bool>(_VenueLoadingNotifier.new);

/// Spatial-only filter that triggers backend re-fetches.
/// Activity/venueType/wheelchair filters are client-side only.
final _spatialFilterProvider = Provider<({double lat, double lng, double radiusKm})>((ref) {
  final f = ref.watch(venueFilterProvider);
  return (lat: f.lat, lng: f.lng, radiusKm: f.radiusKm);
});

/// Fetches ALL venues from the backend (no activity filter).
/// All filtering happens client-side so cross-filter counts work.
class VenueNotifier extends AsyncNotifier<List<Venue>> {
  @override
  Future<List<Venue>> build() async {
    final client = ref.watch(apiClientProvider);
    final spatial = ref.watch(_spatialFilterProvider);

    // Keep previous data visible while fetching.
    final previous = state.value;
    if (previous != null) {
      state = AsyncData(previous);
    }

    Future.microtask(() => ref.read(venueLoadingProvider.notifier).set(true));

    try {
      final venues = await client.fetchVenues(
        lat: spatial.lat,
        lng: spatial.lng,
        radiusKm: spatial.radiusKm,
      );
      return venues;
    } finally {
      ref.read(venueLoadingProvider.notifier).set(false);
    }
  }
}

final venueProvider =
    AsyncNotifierProvider<VenueNotifier, List<Venue>>(VenueNotifier.new);

// ---------------------------------------------------------------------------
// Available filter options (derived from all loaded venues)
// ---------------------------------------------------------------------------

/// All activities found in loaded venues.
final availableActivitiesProvider = Provider<List<Activity>>((ref) {
  final venues = ref.watch(venueProvider).value ?? [];
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
  return activities;
});

/// All venue types found in loaded venues.
final availableVenueTypesProvider = Provider<List<String>>((ref) {
  final venues = ref.watch(venueProvider).value ?? [];
  return venues.map((v) => v.venueType).toSet().toList()..sort();
});

// ---------------------------------------------------------------------------
// Cross-filtered counts: each count reflects the OTHER active filters
// so the user sees how many results toggling THIS filter would yield.
// ---------------------------------------------------------------------------

bool _matchesWheelchair(Venue v) =>
    v.wheelchair == 'yes' || v.wheelchair == 'limited';

/// Activity counts — filtered by venue type + wheelchair (not by activities).
final activityCountsProvider = Provider<Map<String, int>>((ref) {
  final venues = ref.watch(venueProvider).value ?? [];
  final filter = ref.watch(venueFilterProvider);

  final filtered = venues.where((v) {
    if (filter.venueTypes.isNotEmpty &&
        !filter.venueTypes.contains(v.venueType)) {
      return false;
    }
    if (filter.wheelchairOnly && !_matchesWheelchair(v)) {
      return false;
    }
    return true;
  });

  final counts = <String, int>{};
  for (final venue in filtered) {
    for (final a in venue.activities) {
      counts[a.icon] = (counts[a.icon] ?? 0) + 1;
    }
  }
  return counts;
});

/// Venue type counts — filtered by activities + wheelchair (not by venue type).
final venueTypeCountsProvider = Provider<Map<String, int>>((ref) {
  final venues = ref.watch(venueProvider).value ?? [];
  final filter = ref.watch(venueFilterProvider);

  final filtered = venues.where((v) {
    if (filter.activities.isNotEmpty &&
        !v.activities.any((a) => filter.activities.contains(a.icon))) {
      return false;
    }
    if (filter.wheelchairOnly && !_matchesWheelchair(v)) {
      return false;
    }
    return true;
  });

  final counts = <String, int>{};
  for (final venue in filtered) {
    counts[venue.venueType] = (counts[venue.venueType] ?? 0) + 1;
  }
  return counts;
});

/// Wheelchair count — filtered by activities + venue type (not by wheelchair).
final wheelchairCountProvider = Provider<int>((ref) {
  final venues = ref.watch(venueProvider).value ?? [];
  final filter = ref.watch(venueFilterProvider);

  return venues.where((v) {
    if (filter.venueTypes.isNotEmpty &&
        !filter.venueTypes.contains(v.venueType)) {
      return false;
    }
    if (filter.activities.isNotEmpty &&
        !v.activities.any((a) => filter.activities.contains(a.icon))) {
      return false;
    }
    return _matchesWheelchair(v);
  }).length;
});

// ---------------------------------------------------------------------------
// Final filtered venue list (all filters applied)
// ---------------------------------------------------------------------------

final filteredVenueProvider = Provider<AsyncValue<List<Venue>>>((ref) {
  final venues = ref.watch(venueProvider);
  final filter = ref.watch(venueFilterProvider);
  final hasActivities = filter.activities.isNotEmpty;
  final hasTypes = filter.venueTypes.isNotEmpty;
  final hasWheelchair = filter.wheelchairOnly;

  if (!hasActivities && !hasTypes && !hasWheelchair) return venues;

  return venues.whenData(
    (list) => list.where((v) {
      if (hasTypes && !filter.venueTypes.contains(v.venueType)) return false;
      if (hasActivities &&
          !v.activities.any((a) => filter.activities.contains(a.icon))) {
        return false;
      }
      if (hasWheelchair && !_matchesWheelchair(v)) return false;
      return true;
    }).toList(),
  );
});
