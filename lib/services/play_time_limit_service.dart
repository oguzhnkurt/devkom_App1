import 'package:flutter/foundation.dart';

/// Play Time Limit Service Stub
class PlayTimeLimitService {
  Future<dynamic> getSettings(String userId) async {
    debugPrint('⚠️ PlayTimeLimitService: Supabase migration pending');
    return null;
  }

  Future<void> updateSettings(String userId, Map<String, dynamic> settings) async {
    debugPrint('⚠️ PlayTimeLimitService: Supabase migration pending');
  }

  Future<dynamic> checkPlayTime(String userId) async {
    debugPrint('⚠️ PlayTimeLimitService: Supabase migration pending');
    return PlayTimeCheck(canPlay: true, remainingMinutes: 999, limitType: 'none', message: '');
  }

  Future<PlayTimeCheck> checkPlayTimeLimit(String userId) async {
    debugPrint('⚠️ PlayTimeLimitService.checkPlayTimeLimit: Supabase migration pending');
    return PlayTimeCheck(canPlay: true, remainingMinutes: 999, limitType: 'none', message: '');
  }

  Future<String> startPlaySession(String userId) async {
    debugPrint('⚠️ PlayTimeLimitService.startPlaySession: Supabase migration pending');
    return 'session-id';
  }

  Future<void> endPlaySession(String userId, String sessionId) async {
    debugPrint('⚠️ PlayTimeLimitService.endPlaySession: Supabase migration pending');
  }

  Future<int> getTodayPlayTime(String userId) async {
    debugPrint('⚠️ PlayTimeLimitService.getTodayPlayTime: Supabase migration pending');
    return 0;
  }

  Future<int> getWeeklyPlayTime(String userId) async {
    debugPrint('⚠️ PlayTimeLimitService.getWeeklyPlayTime: Supabase migration pending');
    return 0;
  }
}

class PlayTimeSettings {
  final int dailyLimitMinutes;
  final bool enabled;

  PlayTimeSettings({
    required this.dailyLimitMinutes,
    required this.enabled,
  });
}

class PlayTimeCheck {
  final bool canPlay;
  final int remainingMinutes;
  final String limitType;
  final String message;

  PlayTimeCheck({
    required this.canPlay,
    required this.remainingMinutes,
    required this.limitType,
    required this.message,
  });
}
