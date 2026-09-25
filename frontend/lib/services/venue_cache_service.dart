import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/venue.dart';

class VenueCacheService {
  static const _prefix = 'venue_cache_';
  static const _keysKey = 'venue_cache_keys';
  static const _versionKey = 'venue_cache_version';
  static const _cacheVersion = 2;
  static const _maxEntries = 50;

  /// Round coordinates to ~100m for cache key (matching backend).
  static String makeKey(double lat, double lng, double radiusKm,
      List<String>? activities) {
    final rlat = (lat * 1000).round() / 1000;
    final rlng = (lng * 1000).round() / 1000;
    final acts =
        activities != null && activities.isNotEmpty
            ? (List<String>.from(activities)..sort()).join(',')
            : '*';
    return '$rlat:$rlng:$radiusKm:$acts';
  }

  Future<void> checkVersion() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getInt(_versionKey) ?? 0;
    if (stored != _cacheVersion) {
      final keys = prefs.getStringList(_keysKey) ?? [];
      for (final key in keys) {
        await prefs.remove('$_prefix$key');
      }
      await prefs.remove(_keysKey);
      await prefs.setInt(_versionKey, _cacheVersion);
    }
  }

  Future<List<Venue>?> get(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('$_prefix$key');
    if (json == null) return null;
    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map((e) => Venue.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> put(String key, List<Venue> venues) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(venues.map((v) => v.toJson()).toList());
    await prefs.setString('$_prefix$key', json);

    // Track keys for size management
    final keys = prefs.getStringList(_keysKey) ?? [];
    keys.remove(key);
    keys.insert(0, key);
    if (keys.length > _maxEntries) {
      for (final old in keys.sublist(_maxEntries)) {
        await prefs.remove('$_prefix$old');
      }
      keys.removeRange(_maxEntries, keys.length);
    }
    await prefs.setStringList(_keysKey, keys);
  }
}
