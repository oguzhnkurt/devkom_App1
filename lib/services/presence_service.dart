import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class PresenceService {
  final SupabaseClient _supabase = Supabase.instance.client;
  RealtimeChannel? _presenceChannel;
  Timer? _heartbeatTimer;
  String? _currentUserId;
  static const String _presenceTable = 'user_presence';
  static const Duration _heartbeatInterval = Duration(seconds: 30);
  static const Duration _offlineThreshold = Duration(minutes: 2);

  Future<void> trackOnlineStatus(String userId) async {
    if (_currentUserId == userId && _presenceChannel != null) {
      debugPrint('Presence already tracking for user $userId');
      return;
    }
    _currentUserId = userId;
    try {
      await _updatePresenceInDatabase(userId, isOnline: true);
      _presenceChannel = _supabase.channel('presence');
      _presenceChannel!.subscribe((status, [error]) {
        if (status == RealtimeSubscribeStatus.subscribed) {
          debugPrint('Presence tracking started for user $userId');
          _presenceChannel!.track({
            'user_id': userId,
            'online': true,
            'last_seen': DateTime.now().toIso8601String(),
          });
        } else if (status == RealtimeSubscribeStatus.channelError) {
          debugPrint('Presence tracking error: $error');
        }
      });
      _startHeartbeat(userId);
    } catch (e) {
      debugPrint('Error tracking online status: $e');
      rethrow;
    }
  }

  Future<void> stopTracking() async {
    if (_currentUserId != null) {
      await _updatePresenceInDatabase(_currentUserId!, isOnline: false);
    }
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    await _presenceChannel?.unsubscribe();
    _presenceChannel = null;
    _currentUserId = null;
    debugPrint('Presence tracking stopped');
  }

  void _startHeartbeat(String userId) {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) async {
      try {
        await _updatePresenceInDatabase(userId, isOnline: true);
        _presenceChannel?.track({
          'user_id': userId,
          'online': true,
          'last_seen': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        debugPrint('Error sending heartbeat: $e');
      }
    });
  }

  Future<void> _updatePresenceInDatabase(String userId, {required bool isOnline}) async {
    try {
      final now = DateTime.now().toIso8601String();
      final existing = await _supabase
          .from(_presenceTable)
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      if (existing != null) {
        await _supabase.from(_presenceTable).update({
          'is_online': isOnline,
          'last_seen': now,
          'updated_at': now,
        }).eq('user_id', userId);
      } else {
        await _supabase.from(_presenceTable).insert({
          'user_id': userId,
          'is_online': isOnline,
          'last_seen': now,
          'updated_at': now,
        });
      }
    } catch (e) {
      debugPrint('Error updating presence in database: $e');
    }
  }

  Stream<List<String>> watchOnlineUsers() {
    return _supabase.from(_presenceTable).stream(primaryKey: ['user_id']).eq('is_online', true).map((data) {
      final now = DateTime.now();
      return data.where((item) {
        try {
          final lastSeen = DateTime.parse(item['last_seen']);
          final difference = now.difference(lastSeen);
          return difference < _offlineThreshold;
        } catch (e) {
          return false;
        }
      }).map((item) => item['user_id'] as String).toList();
    });
  }

  Future<bool> isUserOnline(String userId) async {
    try {
      final response = await _supabase.from(_presenceTable).select('is_online, last_seen').eq('user_id', userId).maybeSingle();
      if (response == null) return false;
      final isOnline = response['is_online'] as bool? ?? false;
      final lastSeenStr = response['last_seen'] as String?;
      if (!isOnline || lastSeenStr == null) return false;
      final lastSeen = DateTime.parse(lastSeenStr);
      final difference = DateTime.now().difference(lastSeen);
      return difference < _offlineThreshold;
    } catch (e) {
      debugPrint('Error checking user online status: $e');
      return false;
    }
  }

  Future<DateTime?> getLastSeen(String userId) async {
    try {
      final response = await _supabase.from(_presenceTable).select('last_seen').eq('user_id', userId).maybeSingle();
      if (response == null) return null;
      final lastSeenStr = response['last_seen'] as String?;
      return lastSeenStr != null ? DateTime.parse(lastSeenStr) : null;
    } catch (e) {
      debugPrint('Error getting last seen: $e');
      return null;
    }
  }

  Future<Map<String, bool>> getBulkOnlineStatus(List<String> userIds) async {
    if (userIds.isEmpty) return {};
    try {
      final response = await _supabase.from(_presenceTable).select('user_id, is_online, last_seen').inFilter('user_id', userIds);
      final Map<String, bool> statusMap = {};
      final now = DateTime.now();
      for (final item in response as List) {
        final userId = item['user_id'] as String;
        final isOnline = item['is_online'] as bool? ?? false;
        final lastSeenStr = item['last_seen'] as String?;
        if (isOnline && lastSeenStr != null) {
          final lastSeen = DateTime.parse(lastSeenStr);
          final difference = now.difference(lastSeen);
          statusMap[userId] = difference < _offlineThreshold;
        } else {
          statusMap[userId] = false;
        }
      }
      for (final userId in userIds) {
        statusMap.putIfAbsent(userId, () => false);
      }
      return statusMap;
    } catch (e) {
      debugPrint('Error getting bulk online status: $e');
      return {for (final id in userIds) id: false};
    }
  }

  void dispose() {
    stopTracking();
  }
}
