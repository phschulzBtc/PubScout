import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/venue_provider.dart';

class ActivityFilterBar extends ConsumerWidget {
  const ActivityFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(availableActivitiesProvider);
    final filter = ref.watch(venueFilterProvider);
    final selectedActivities = filter.activities;
    final counts = ref.watch(activityCountsProvider);

    if (activities.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: activities.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final activity = activities[index];
          final isSelected = selectedActivities.contains(activity.icon);
          final count = counts[activity.icon] ?? 0;
          final isDisabled = count == 0 && !isSelected;

          return FilterChip(
            label: Text(
              count > 0
                  ? '${activity.name} ($count)'
                  : activity.name,
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
                : (_) => _toggleActivity(ref, activity.icon),
            avatar: Icon(
              _activityIcon(activity.icon),
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

  void _toggleActivity(WidgetRef ref, String activityIcon) {
    final current = ref.read(venueFilterProvider).activities;
    final updated = current.contains(activityIcon)
        ? current.where((a) => a != activityIcon).toList()
        : [...current, activityIcon];
    ref.read(venueFilterProvider.notifier).update(activities: updated);
  }

  IconData _activityIcon(String icon) {
    return switch (icon) {
      'darts' => Icons.gps_fixed,
      'billiards' => Icons.circle,
      'foosball' => Icons.sports_soccer,
      'board_games' => Icons.extension,
      'table_tennis' => Icons.sports_tennis,
      'quiz' => Icons.quiz,
      'shuffleboard' => Icons.swap_horiz,
      'karaoke' => Icons.mic,
      'live_music' => Icons.music_note,
      'poker' => Icons.style,
      'sport_tv' => Icons.tv,
      _ => Icons.sports_bar,
    };
  }
}
