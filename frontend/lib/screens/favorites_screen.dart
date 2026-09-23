import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../models/venue.dart';
import '../providers/favorites_provider.dart';
import '../widgets/venue_detail_sheet.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoriten'),
      ),
      body: favorites.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_border,
                      size: 64, color: theme.colorScheme.outlineVariant),
                  const SizedBox(height: 16),
                  Text('Noch keine Favoriten',
                      style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Text(
                    'Tippe auf das Herz-Icon bei einem Venue,\num ihn als Favorit zu speichern.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final venue = list[index];
              return _FavoriteTile(venue: venue);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Fehler: $e')),
      ),
    );
  }
}

class _FavoriteTile extends ConsumerWidget {
  final Venue venue;

  const _FavoriteTile({required this.venue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(venue.osmId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: theme.colorScheme.errorContainer,
        child: Icon(Icons.delete, color: theme.colorScheme.onErrorContainer),
      ),
      onDismissed: (_) => ref.read(favoritesProvider.notifier).toggle(venue),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [pubScoutGreen, pubScoutGreenDark],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child:
              const Icon(Icons.sports_bar, color: Colors.white, size: 22),
        ),
        title: Text(venue.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: venue.address.isNotEmpty ? Text(venue.address) : null,
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: pubScoutCoral),
          onPressed: () =>
              ref.read(favoritesProvider.notifier).toggle(venue),
        ),
        onTap: () => _showVenueDetail(context, venue),
      ),
    );
  }

  void _showVenueDetail(BuildContext context, Venue venue) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VenueDetailSheet(venue: venue),
    );
  }
}
