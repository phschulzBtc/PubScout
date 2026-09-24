import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/geo_utils.dart';
import '../core/theme.dart';
import '../models/venue.dart';
import '../providers/favorites_provider.dart';
import '../providers/location_provider.dart';
import '../providers/venue_provider.dart';

class VenueListPanel extends ConsumerWidget {
  final List<Venue> venues;
  final Venue? selectedVenue;
  final ValueChanged<Venue> onVenueTap;

  const VenueListPanel({
    super.key,
    required this.venues,
    required this.onVenueTap,
    this.selectedVenue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final favoriteIds = ref
            .watch(favoritesProvider)
            .value
            ?.map((v) => v.osmId)
            .toSet() ??
        {};
    final userLoc = ref.watch(userLocationProvider).value;
    final filter = ref.watch(venueFilterProvider);

    if (venues.isEmpty) {
      return _EmptyState(
        hasFilters: filter.activities.isNotEmpty ||
            filter.venueTypes.isNotEmpty,
        radiusKm: filter.radiusKm,
        onClearFilters: () {
          ref.read(venueFilterProvider.notifier).update(
                activities: [],
                venueTypes: [],
              );
        },
      );
    }

    // Sort by distance if user location is available
    final sorted = List<Venue>.from(venues);
    if (userLoc != null) {
      sorted.sort((a, b) {
        final da = distanceKm(
            userLoc.latitude, userLoc.longitude, a.latitude, a.longitude);
        final db = distanceKm(
            userLoc.latitude, userLoc.longitude, b.latitude, b.longitude);
        return da.compareTo(db);
      });
    } else {
      sorted.sort((a, b) => a.name.compareTo(b.name));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final venue = sorted[index];
        final isFav = favoriteIds.contains(venue.osmId);
        final isSelected = selectedVenue == venue;

        String subtitle = venueTypeLabel(venue.venueType);
        if (userLoc != null) {
          final dist = distanceKm(userLoc.latitude, userLoc.longitude,
              venue.latitude, venue.longitude);
          subtitle += ' · ${formatDistance(dist)}';
        }
        if (venue.address.isNotEmpty) {
          subtitle += ' · ${venue.address}';
        }

        return ListTile(
          selected: isSelected,
          selectedTileColor: pubScoutGreen.withValues(alpha: 0.08),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isFav
                    ? [pubScoutAmber, pubScoutCoral]
                    : [pubScoutGreen, pubScoutGreenDark],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isFav ? Icons.favorite : _iconForVenueType(venue.venueType),
              color: Colors.white,
              size: 20,
            ),
          ),
          title: Text(venue.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          subtitle: Text(subtitle,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: venue.activities.isNotEmpty
              ? Text('${venue.activities.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant))
              : null,
          onTap: () => onVenueTap(venue),
        );
      },
    );
  }

  static IconData _iconForVenueType(String type) {
    return switch (type) {
      'bar' => Icons.local_bar,
      'biergarten' => Icons.deck,
      'nightclub' => Icons.nightlife,
      _ => Icons.sports_bar,
    };
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilters;
  final double radiusKm;
  final VoidCallback onClearFilters;

  const _EmptyState({
    required this.hasFilters,
    required this.radiusKm,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off,
                size: 48, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 12),
            Text(
              hasFilters
                  ? 'Keine Venues mit diesen Filtern gefunden'
                  : 'Keine Venues im Umkreis von ${formatDistance(radiusKm)}',
              style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (hasFilters)
              FilledButton.tonal(
                onPressed: onClearFilters,
                child: const Text('Filter entfernen'),
              ),
          ],
        ),
      ),
    );
  }
}
