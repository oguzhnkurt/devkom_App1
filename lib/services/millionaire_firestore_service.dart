import 'package:flutter/foundation.dart';

/// Millionaire Firestore Service Stub
/// TODO: Migrate to Supabase
class MillionaireFirestoreService {
  Future<List<dynamic>> getQuestions({String? difficulty}) async {
    debugPrint('⚠️ MillionaireFirestoreService: Supabase migration pending');
    return [];
  }

  Future<List<dynamic>> getRandomQuestions({String? difficulty, int limit = 10}) async {
    debugPrint('⚠️ MillionaireFirestoreService.getRandomQuestions: Supabase migration pending');
    return [];
  }

  Future<void> saveScore(String userId, int score) async {
    debugPrint('⚠️ MillionaireFirestoreService: Supabase migration pending');
  }
}
