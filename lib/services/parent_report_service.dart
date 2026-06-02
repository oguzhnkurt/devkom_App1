import 'package:flutter/foundation.dart';

/// Parent Report Service Stub
class ParentReportService {
  Future<dynamic> getChildReport(String childId) async {
    debugPrint('⚠️ ParentReportService: Supabase migration pending');
    return null;
  }
}

class GameActivityReport {
  final String gameId;
  final int playCount;
  final DateTime date;

  GameActivityReport({
    required this.gameId,
    required this.playCount,
    required this.date,
  });
}
