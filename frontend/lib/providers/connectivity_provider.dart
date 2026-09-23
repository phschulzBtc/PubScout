import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';

class ConnectivityNotifier extends Notifier<bool> {
  Timer? _timer;

  @override
  bool build() {
    _startPolling();
    ref.onDispose(() => _timer?.cancel());
    return true; // assume online initially
  }

  void _startPolling() {
    _check();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _check());
  }

  Future<void> _check() async {
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 3),
      ));
      await dio.get('$backendBaseUrl/health');
      state = true;
    } catch (_) {
      state = false;
    }
  }

  void setOnline(bool online) => state = online;
}

final connectivityProvider =
    NotifierProvider<ConnectivityNotifier, bool>(ConnectivityNotifier.new);
