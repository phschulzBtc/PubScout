import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/venue_provider.dart';

const _radiusOptions = [0.5, 1.0, 2.0, 5.0, 10.0];
const _prefsKey = 'search_radius_km';

class RadiusSelector extends ConsumerStatefulWidget {
  const RadiusSelector({super.key});

  @override
  ConsumerState<RadiusSelector> createState() => _RadiusSelectorState();
}

class _RadiusSelectorState extends ConsumerState<RadiusSelector> {
  @override
  void initState() {
    super.initState();
    _loadSavedRadius();
  }

  Future<void> _loadSavedRadius() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble(_prefsKey);
    if (saved != null && _radiusOptions.contains(saved)) {
      ref.read(venueFilterProvider.notifier).update(radiusKm: saved);
    } else if (saved != null) {
      // Saved value no longer valid — reset to default
      await prefs.remove(_prefsKey);
    }
  }

  Future<void> _setRadius(double radius) async {
    ref.read(venueFilterProvider.notifier).update(radiusKm: radius);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefsKey, radius);
  }

  @override
  Widget build(BuildContext context) {
    final currentRadius = ref.watch(venueFilterProvider).radiusKm;

    return PopupMenuButton<double>(
      onSelected: _setRadius,
      tooltip: 'Suchradius',
      position: PopupMenuPosition.under,
      initialValue: currentRadius,
      itemBuilder: (_) => _radiusOptions
          .map((r) => PopupMenuItem(
                value: r,
                child: Row(
                  children: [
                    if (r == currentRadius)
                      Icon(Icons.check,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary)
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    Text(_formatRadius(r)),
                  ],
                ),
              ))
          .toList(),
      child: Chip(
        avatar: const Icon(Icons.radar, size: 18),
        label: Text(_formatRadius(currentRadius)),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  String _formatRadius(double km) {
    if (km < 1) return '${(km * 1000).round()} m';
    if (km == km.roundToDouble()) return '${km.round()} km';
    return '${km.toStringAsFixed(1)} km';
  }
}
