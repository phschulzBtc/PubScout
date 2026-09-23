import '../models/activity.dart';
import '../models/venue.dart';
import 'api_client.dart';
import 'venue_cache_service.dart';

class CachedApiClient implements ApiClient {
  final ApiClient _inner;
  final VenueCacheService _cache;

  CachedApiClient(this._inner, this._cache);

  @override
  Future<List<Activity>> fetchActivities() => _inner.fetchActivities();

  @override
  Future<List<Venue>> fetchVenues({
    required double lat,
    required double lng,
    double radiusKm = 5.0,
    List<String>? activities,
  }) async {
    final key = VenueCacheService.makeKey(lat, lng, radiusKm, activities);

    try {
      final venues = await _inner.fetchVenues(
        lat: lat,
        lng: lng,
        radiusKm: radiusKm,
        activities: activities,
      );
      // Cache successful results
      await _cache.put(key, venues);
      return venues;
    } catch (e) {
      // Fall back to cache on network error
      final cached = await _cache.get(key);
      if (cached != null) return cached;
      rethrow;
    }
  }
}
