import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/venue.dart';
import '../services/favorites_service.dart';

final favoritesServiceProvider = Provider((_) => FavoritesService());

class FavoritesNotifier extends AsyncNotifier<List<Venue>> {
  @override
  Future<List<Venue>> build() {
    return ref.read(favoritesServiceProvider).getFavorites();
  }

  Future<void> toggle(Venue venue) async {
    final service = ref.read(favoritesServiceProvider);
    await service.toggleFavorite(venue);
    state = AsyncData(await service.getFavorites());
  }

  bool isFavorite(String osmId) {
    final list = state.value;
    if (list == null) return false;
    return list.any((v) => v.osmId == osmId);
  }
}

final favoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, List<Venue>>(
        FavoritesNotifier.new);
