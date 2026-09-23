import 'package:riverpod/riverpod.dart';

import '../services/api_client.dart';
import '../services/cached_api_client.dart';
import '../services/mock_api_client.dart';
import '../services/venue_cache_service.dart';

const _useMockApi = bool.fromEnvironment('USE_MOCK_API', defaultValue: false);

final apiClientProvider = Provider<ApiClient>((ref) {
  final inner = _useMockApi ? MockApiClient() : HttpApiClient();
  return CachedApiClient(inner, VenueCacheService());
});
