import 'package:flutter/foundation.dart';

/// Logger Service for Production-Ready Logging
/// Following Single Responsibility Principle
/// Provides structured logging with different severity levels
class LoggerService {
  // Private constructor (Singleton pattern)
  LoggerService._();
  static final LoggerService instance = LoggerService._();

  /// Log levels
  static const String _levelDebug = '🐛 DEBUG';
  static const String _levelInfo = 'ℹ️ INFO';
  static const String _levelWarning = '⚠️ WARNING';
  static const String _levelError = '❌ ERROR';
  static const String _levelSuccess = '✅ SUCCESS';

  /// Enable/disable logging (should be false in production)
  bool _isEnabled = kDebugMode;

  /// Set logging state
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Log debug message
  void debug(String message, {String? tag}) {
    _log(_levelDebug, message, tag: tag);
  }

  /// Log info message
  void info(String message, {String? tag}) {
    _log(_levelInfo, message, tag: tag);
  }

  /// Log warning message
  void warning(String message, {String? tag, Object? error}) {
    _log(_levelWarning, message, tag: tag, error: error);
  }

  /// Log error message
  void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(_levelError, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Log success message
  void success(String message, {String? tag}) {
    _log(_levelSuccess, message, tag: tag);
  }

  /// Internal logging method
  void _log(
    String level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_isEnabled) return;

    final timestamp = DateTime.now().toIso8601String();
    final tagStr = tag != null ? '[$tag]' : '';
    final logMessage = '$level $tagStr $message';

    // Print to console in development
    if (kDebugMode) {
      debugPrint('[$timestamp] $logMessage');

      if (error != null) {
        debugPrint('  └─ Error: $error');
      }

      if (stackTrace != null) {
        debugPrint('  └─ StackTrace:\n$stackTrace');
      }
    }

    // TODO: In production, send logs to remote logging service (e.g., Sentry, Firebase Crashlytics)
    // _sendToRemoteLogging(level, message, error, stackTrace);
  }

  /// Log API request
  void apiRequest(String endpoint, {Map<String, dynamic>? params}) {
    debug('API Request: $endpoint', tag: 'API');
    if (params != null && params.isNotEmpty) {
      debug('  └─ Params: $params', tag: 'API');
    }
  }

  /// Log API response
  void apiResponse(String endpoint, {int? statusCode, dynamic data}) {
    info('API Response: $endpoint (Status: $statusCode)', tag: 'API');
  }

  /// Log API error
  void apiError(String endpoint, Object error, {StackTrace? stackTrace}) {
    this.error(
      'API Error: $endpoint',
      tag: 'API',
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log user action
  void userAction(String action, {Map<String, dynamic>? metadata}) {
    info('User Action: $action', tag: 'USER');
    if (metadata != null && metadata.isNotEmpty) {
      debug('  └─ Metadata: $metadata', tag: 'USER');
    }
  }

  /// Log authentication event
  void authEvent(String event, {bool success = true, String? error}) {
    if (success) {
      this.success('Auth: $event', tag: 'AUTH');
    } else {
      this.error('Auth Failed: $event', tag: 'AUTH', error: error);
    }
  }

  /// Log database operation
  void dbOperation(String operation, {String? collection, dynamic result}) {
    info('DB: $operation ${collection != null ? "($collection)" : ""}', tag: 'DB');
  }

  /// Log performance metric
  void performance(String metric, Duration duration) {
    debug('Performance: $metric took ${duration.inMilliseconds}ms', tag: 'PERF');
  }
}
