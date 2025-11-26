import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Simple network status helper using `connectivity_plus`.
/// Emits `true` when device appears online, `false` when offline.
class NetworkService {
  static final Connectivity _connectivity = Connectivity();
  static final StreamController<bool> _controller =
      StreamController<bool>.broadcast();

  /// Stream of online status changes.
  static Stream<bool> get onStatusChanged => _controller.stream;

  /// Initialize the service and start listening for connectivity changes.
  static Future<void> init() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _controller.add(_map(result));
    } catch (_) {
      _controller.add(true);
    }

    _connectivity.onConnectivityChanged.listen((result) {
      _controller.add(_map(result));
    });
  }

  static bool _map(ConnectivityResult result) {
    return result != ConnectivityResult.none;
  }

  /// Dispose the internal controller when app shuts down (not usually needed).
  static Future<void> dispose() async {
    await _controller.close();
  }
}
