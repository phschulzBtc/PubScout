import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/venue.dart';

class FavoritesService {
  static const _key = 'favorite_venues';

  Future<List<Venue>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    return jsonList
        .map((s) => Venue.fromJson(json.decode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<bool> isFavorite(String osmId) async {
    final favorites = await getFavorites();
    return favorites.any((v) => v.osmId == osmId);
  }

  Future<void> addFavorite(Venue venue) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];

    // Avoid duplicates
    jsonList.removeWhere((s) {
      final v = Venue.fromJson(json.decode(s) as Map<String, dynamic>);
      return v.osmId == venue.osmId;
    });

    jsonList.insert(0, json.encode(venue.toJson()));
    await prefs.setStringList(_key, jsonList);
  }

  Future<void> removeFavorite(String osmId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];

    jsonList.removeWhere((s) {
      final v = Venue.fromJson(json.decode(s) as Map<String, dynamic>);
      return v.osmId == osmId;
    });

    await prefs.setStringList(_key, jsonList);
  }

  Future<void> toggleFavorite(Venue venue) async {
    if (await isFavorite(venue.osmId)) {
      await removeFavorite(venue.osmId);
    } else {
      await addFavorite(venue);
    }
  }
}
