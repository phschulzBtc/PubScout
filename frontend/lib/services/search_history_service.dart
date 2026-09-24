import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryEntry {
  final String name;
  final double lat;
  final double lng;

  const SearchHistoryEntry({
    required this.name,
    required this.lat,
    required this.lng,
  });

  Map<String, dynamic> toJson() => {'name': name, 'lat': lat, 'lng': lng};

  factory SearchHistoryEntry.fromJson(Map<String, dynamic> json) {
    return SearchHistoryEntry(
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }
}

class SearchHistoryService {
  static const _key = 'search_history_v2';
  static const _maxEntries = 10;

  Future<List<SearchHistoryEntry>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((s) {
      try {
        return SearchHistoryEntry.fromJson(
            json.decode(s) as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }).whereType<SearchHistoryEntry>().toList();
  }

  Future<void> addEntry(SearchHistoryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];

    // Remove duplicate by name
    raw.removeWhere((s) {
      try {
        final e = json.decode(s) as Map<String, dynamic>;
        return e['name'] == entry.name;
      } catch (_) {
        return false;
      }
    });

    raw.insert(0, json.encode(entry.toJson()));
    if (raw.length > _maxEntries) {
      raw.removeRange(_maxEntries, raw.length);
    }

    await prefs.setStringList(_key, raw);
  }

  Future<void> removeEntry(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.removeWhere((s) {
      try {
        final e = json.decode(s) as Map<String, dynamic>;
        return e['name'] == name;
      } catch (_) {
        return false;
      }
    });
    await prefs.setStringList(_key, raw);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
