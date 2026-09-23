import 'package:riverpod/riverpod.dart';

import '../services/api_client.dart';
import '../services/mock_api_client.dart';

const _useMockApi = bool.fromEnvironment('USE_MOCK_API', defaultValue: false);

final apiClientProvider = Provider<ApiClient>((ref) {
  return _useMockApi ? MockApiClient() : HttpApiClient();
});
