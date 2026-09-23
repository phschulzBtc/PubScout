import 'package:riverpod/riverpod.dart';

import '../models/activity.dart';
import 'api_client_provider.dart';

final activityProvider = FutureProvider<List<Activity>>((ref) async {
  final client = ref.watch(apiClientProvider);
  return client.fetchActivities();
});
