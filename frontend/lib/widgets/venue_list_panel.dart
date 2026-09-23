import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../models/venue.dart';
import '../providers/favorites_provider.dart';

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

    if (venues.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off,
                size: 48, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 12),
            Text('Keine Venues gefunden',
                style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: venues.length,
      itemBuilder: (context, index) {
        final venue = venues[index];
        final isFav = favoriteIds.contains(venue.osmId);
        final isSelected = selectedVenue == venue;

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
              isFav ? Icons.favorite : Icons.sports_bar,
              color: Colors.white,
              size: 20,
            ),
          ),
          title: Text(venue.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          subtitle: Text(
              venue.address.isNotEmpty ? venue.address : 'Keine Adresse',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: venue.address.isEmpty
                  ? TextStyle(color: theme.colorScheme.outlineVariant)
                  : null),
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
}
