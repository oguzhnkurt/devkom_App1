import 'package:flutter/foundation.dart';

/// Weekly Curriculum Service Stub
class WeeklyCurriculumService {
  Future<List<dynamic>> getCurriculums(String teacherId) async {
    debugPrint('⚠️ WeeklyCurriculumService: Supabase migration pending');
    return [];
  }

  Stream<List<dynamic>> getAllCurriculums() {
    debugPrint('⚠️ WeeklyCurriculumService.getAllCurriculums: Supabase migration pending');
    return Stream.value([]);
  }

  Stream<List<dynamic>> getStudentCurriculums(String studentId) {
    debugPrint('⚠️ WeeklyCurriculumService.getStudentCurriculums: Supabase migration pending');
    return Stream.value([]);
  }

  Stream<List<dynamic>> getTeacherCurriculums(String teacherId) {
    debugPrint('⚠️ WeeklyCurriculumService.getTeacherCurriculums: Supabase migration pending');
    return Stream.value([]);
  }

  Future<void> createCurriculum(Map<String, dynamic> curriculum) async {
    debugPrint('⚠️ WeeklyCurriculumService: Supabase migration pending');
  }
}
