import 'package:flutter/foundation.dart';

/// In-memory cache for frequently accessed data
/// Reduces database calls and improves performance
class CacheManager {
  final Map<String, _CacheEntry> _cache = {};
  final Duration defaultTtl = const Duration(minutes: 5);

  /// Get cached value or fetch from source
  Future<T> getOrFetch<T>({
    required String key,
    required Future<T> Function() fetcher,
    Duration? ttl,
  }) async {
    final cached = _get<T>(key);
    if (cached != null) {
      debugPrint('📦 Cache HIT: $key');
      return cached;
    }

    debugPrint('📡 Cache MISS: $key - Fetching...');
    final value = await fetcher();
    _set(key, value, ttl: ttl);
    return value;
  }

  /// Get value from cache
  T? _get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    // Check if expired
    if (entry.isExpired) {
      _cache.remove(key);
      debugPrint('⏰ Cache EXPIRED: $key');
      return null;
    }

    return entry.value as T;
  }

  /// Set value in cache
  void _set<T>(String key, T value, {Duration? ttl}) {
    _cache[key] = _CacheEntry(
      value: value,
      expiresAt: DateTime.now().add(ttl ?? defaultTtl),
    );
    debugPrint('💾 Cache SET: $key (TTL: ${ttl ?? defaultTtl})');
  }

  /// Clear specific key
  void clear(String key) {
    _cache.remove(key);
    debugPrint('🗑️ Cache CLEAR: $key');
  }

  /// Clear all cache
  void clearAll() {
    _cache.clear();
    debugPrint('🗑️ Cache CLEAR ALL');
  }

  /// Clear expired entries
  void cleanExpired() {
    final before = _cache.length;
    _cache.removeWhere((key, entry) => entry.isExpired);
    final removed = before - _cache.length;
    if (removed > 0) {
      debugPrint('🧹 Cache CLEANED: $removed expired entries removed');
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    return {
      'total_entries': _cache.length,
      'expired_entries': _cache.values.where((e) => e.isExpired).length,
      'active_entries': _cache.values.where((e) => !e.isExpired).length,
    };
  }
}

class _CacheEntry {
  final dynamic value;
  final DateTime expiresAt;

  _CacheEntry({
    required this.value,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
