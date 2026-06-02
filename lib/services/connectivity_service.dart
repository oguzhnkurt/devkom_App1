import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Internet Connectivity Service
/// Monitors internet connection status and provides connection checks
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _isConnected = false;
  final _connectionController = StreamController<bool>.broadcast();

  /// Get current connection status
  bool get isConnected => _isConnected;

  /// Stream of connection status changes
  Stream<bool> get connectionStream => _connectionController.stream;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    try {
      // Check initial connectivity
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);

      // Listen for connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _updateConnectionStatus,
        onError: (error) {
          debugPrint('❌ Connectivity error: $error');
        },
      );

      debugPrint('✅ Connectivity service initialized');
    } catch (e) {
      debugPrint('❌ Error initializing connectivity service: $e');
    }
  }

  /// Update connection status based on connectivity result
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // Consider connected if any connection type is available (except none)
    final wasConnected = _isConnected;
    _isConnected = results.any((result) =>
      result != ConnectivityResult.none
    );

    // Notify listeners if status changed
    if (wasConnected != _isConnected) {
      _connectionController.add(_isConnected);
      debugPrint('📡 Connection status changed: ${_isConnected ? "ONLINE" : "OFFLINE"}');
    }
  }

  /// Check current connectivity status (one-time check)
  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
      return _isConnected;
    } catch (e) {
      debugPrint('❌ Error checking connectivity: $e');
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionController.close();
  }
}
