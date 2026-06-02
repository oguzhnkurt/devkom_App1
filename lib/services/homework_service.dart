import 'package:flutter/foundation.dart';
import '../core/service_locator.dart';

/// Homework Service Stub - Redirects to Supabase
class HomeworkService {
  Future<List<dynamic>> getHomeworksForStudent(String studentId) async {
    debugPrint('🔄 HomeworkService: Redirecting to HomeworkServiceSupabase');
    return await homeworkService.getHomeworksForStudent(studentId);
  }

  Future<List<dynamic>> getHomeworksForTeacher(String teacherId) async {
    debugPrint('🔄 HomeworkService: Redirecting to HomeworkServiceSupabase');
    return await homeworkService.getHomeworksForTeacher(teacherId);
  }

  Future<void> createHomework(Map<String, dynamic> homework) async {
    debugPrint('⚠️ HomeworkService.createHomework: Stub - Map not converted to HomeworkModel');
    // TODO: Convert Map to HomeworkModel and call homeworkService.createHomework()
  }

  Future<void> submitHomework({
    required String homeworkId,
    required String studentId,
    required Map<String, dynamic> submission,
  }) async {
    debugPrint('⚠️ HomeworkService.submitHomework: Stub - named params not converted to HomeworkSubmission');
    // TODO: Convert to HomeworkSubmission and call homeworkService.submitHomework()
  }

  Stream<List<dynamic>> getUserHomework(String userId, String ageGroup) {
    debugPrint('⚠️  getUserHomework - stub');
    return Stream.value([]);
  }

  Stream<List<dynamic>> getUserSubmissions(String userId) {
    debugPrint('⚠️  getUserSubmissions - stub');
    return Stream.value([]);
  }
}
