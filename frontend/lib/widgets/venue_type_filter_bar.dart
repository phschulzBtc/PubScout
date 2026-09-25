import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/geo_utils.dart';
import '../l10n/app_localizations.dart';
import '../providers/venue_provider.dart';

class VenueTypeFilterBar extends ConsumerWidget {
  const VenueTypeFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final types = ref.watch(availableVenueTypesProvider);
    final selected = ref.watch(venueFilterProvider).venueTypes;
    final counts = ref.watch(venueTypeCountsProvider);

    if (types.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: types.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final type = types[index];
          final isSelected = selected.contains(type);
          final count = counts[type] ?? 0;
          final isDisabled = count == 0 && !isSelected;

          return FilterChip(
            label: Text(
              count > 0
                  ? '${venueTypeLabel(type, AppLocalizations.of(context)!)} ($count)'
                  : venueTypeLabel(type, AppLocalizations.of(context)!),
              style: isDisabled
                  ? TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.38))
                  : null,
            ),
            selected: isSelected,
            onSelected: isDisabled
                ? null
                : (_) => _toggle(ref, type),
            avatar: Icon(
              _icon(type),
              size: 18,
              color: isDisabled
                  ? Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.38)
                  : null,
            ),
            showCheckmark: false,
            selectedColor: Theme.of(context).colorScheme.primaryContainer,
          );
        },
      ),
    );
  }

  void _toggle(WidgetRef ref, String type) {
    final current = ref.read(venueFilterProvider).venueTypes;
    final updated = current.contains(type)
        ? current.where((t) => t != type).toList()
        : [...current, type];
    ref.read(venueFilterProvider.notifier).update(venueTypes: updated);
  }

  static IconData _icon(String type) {
    return switch (type) {
      'bar' => Icons.local_bar,
      'biergarten' => Icons.deck,
      'nightclub' => Icons.nightlife,
      _ => Icons.sports_bar,
    };
  }
}
