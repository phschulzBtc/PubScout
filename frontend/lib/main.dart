import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'services/venue_cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await VenueCacheService().checkVersion();
  runApp(const ProviderScope(child: PubScoutApp()));
}
