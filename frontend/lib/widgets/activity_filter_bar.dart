import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/activity_provider.dart';
import '../providers/venue_provider.dart';

class ActivityFilterBar extends ConsumerWidget {
  const ActivityFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(activityProvider);
    final filter = ref.watch(venueFilterProvider);
    final selectedActivities = filter.activities;

    return activitiesAsync.when(
      data: (activities) => SizedBox(
        height: 50,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          itemCount: activities.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final activity = activities[index];
            final isSelected = selectedActivities.contains(activity.name);

            return FilterChip(
              label: Text(activity.name),
              selected: isSelected,
              onSelected: (_) => _toggleActivity(ref, activity.name),
              avatar: Icon(
                _activityIcon(activity.icon),
                size: 18,
              ),
              showCheckmark: false,
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
            );
          },
        ),
      ),
      loading: () => const SizedBox(
        height: 50,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  void _toggleActivity(WidgetRef ref, String activityName) {
    final current = ref.read(venueFilterProvider).activities;
    final updated = current.contains(activityName)
        ? current.where((a) => a != activityName).toList()
        : [...current, activityName];
    ref.read(venueFilterProvider.notifier).update(activities: updated);
  }

  IconData _activityIcon(String icon) {
    return switch (icon) {
      'darts' => Icons.gps_fixed,
      'billiards' || 'pool' => Icons.circle,
      'foosball' => Icons.sports_soccer,
      'board_games' => Icons.extension,
      'table_tennis' => Icons.sports_tennis,
      'quiz' => Icons.quiz,
      'shuffleboard' => Icons.swap_horiz,
      _ => Icons.sports_bar,
    };
  }
}
