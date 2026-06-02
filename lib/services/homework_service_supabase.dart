import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/homework_model.dart';

class HomeworkServiceSupabase {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String _homeworksTable = 'homeworks';
  static const String _submissionsTable = 'homework_submissions';

  /// Get all active homework assignments - Real-time
  Stream<List<HomeworkModel>> getAllHomework() {
    return _supabase
        .from(_homeworksTable)
        .stream(primaryKey: ['id'])
        .eq('is_active', true)
        .order('due_date')
        .map((data) => data.map((item) => HomeworkModel.fromSupabase(item)).toList());
  }

  /// Get homework for a specific user - Real-time
  Stream<List<HomeworkModel>> getUserHomework(String userId, AgeGroup userAgeGroup) {
    return _supabase
        .from(_homeworksTable)
        .stream(primaryKey: ['id'])
        .eq('is_active', true)
        .order('due_date')
        .map((data) {
          final homeworks = data.map((item) => HomeworkModel.fromSupabase(item)).toList();
          return homeworks
              .where((hw) => hw.isAssignedToUser(userId, userAgeGroup))
              .toList();
        });
  }

  /// Get homework by age group - Real-time
  Stream<List<HomeworkModel>> getHomeworkByAgeGroup(AgeGroup ageGroup) {
    return _supabase
        .from(_homeworksTable)
        .stream(primaryKey: ['id'])
        .eq('is_active', true)
        .order('due_date')
        .map((data) {
          final homeworks = data.map((item) => HomeworkModel.fromSupabase(item)).toList();
          return homeworks
              .where((hw) => hw.ageGroup == ageGroup || hw.ageGroup == AgeGroup.all)
              .toList();
        });
  }

  /// Get single homework
  Future<HomeworkModel?> getHomework(String homeworkId) async {
    try {
      final response = await _supabase
          .from(_homeworksTable)
          .select()
          .eq('id', homeworkId)
          .single();

      return HomeworkModel.fromSupabase(response);
    } catch (e) {
      throw Exception('Ödev yüklenemedi: $e');
    }
  }

  /// Create new homework (Admin only)
  Future<String> createHomework(HomeworkModel homework) async {
    try {
      final response = await _supabase
          .from(_homeworksTable)
          .insert(homework.toSupabaseMap())
          .select('id')
          .single();

      return response['id'].toString();
    } catch (e) {
      throw Exception('Ödev oluşturulamadı: $e');
    }
  }

  /// Update homework (Admin only)
  Future<void> updateHomework(String homeworkId, Map<String, dynamic> updates) async {
    try {
      await _supabase
          .from(_homeworksTable)
          .update(updates)
          .eq('id', homeworkId);
    } catch (e) {
      throw Exception('Ödev güncellenemedi: $e');
    }
  }

  /// Delete homework (Admin only)
  Future<void> deleteHomework(String homeworkId) async {
    try {
      await _supabase
          .from(_homeworksTable)
          .update({'is_active': false})
          .eq('id', homeworkId);
    } catch (e) {
      throw Exception('Ödev silinemedi: $e');
    }
  }

  /// Submit homework
  Future<String> submitHomework(HomeworkSubmission submission) async {
    try {
      final response = await _supabase
          .from(_submissionsTable)
          .insert(submission.toSupabaseMap())
          .select('id')
          .single();

      return response['id'].toString();
    } catch (e) {
      throw Exception('Ödev teslim edilemedi: $e');
    }
  }

  /// Get submissions for a specific homework (Admin) - Real-time
  Stream<List<HomeworkSubmission>> getHomeworkSubmissions(String homeworkId) {
    return _supabase
        .from(_submissionsTable)
        .stream(primaryKey: ['id'])
        .eq('homework_id', homeworkId)
        .order('submitted_at', ascending: false)
        .map((data) => data.map((item) => HomeworkSubmission.fromSupabase(item)).toList());
  }

  /// Get user's submissions - Real-time
  Stream<List<HomeworkSubmission>> getUserSubmissions(String userId) {
    return _supabase
        .from(_submissionsTable)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('submitted_at', ascending: false)
        .map((data) => data.map((item) => HomeworkSubmission.fromSupabase(item)).toList());
  }

  /// Get user's submission for specific homework
  Future<HomeworkSubmission?> getUserHomeworkSubmission(
      String userId, String homeworkId) async {
    try {
      final response = await _supabase
          .from(_submissionsTable)
          .select()
          .eq('user_id', userId)
          .eq('homework_id', homeworkId)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        return HomeworkSubmission.fromSupabase(response);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if user has submitted homework
  Future<bool> hasUserSubmitted(String userId, String homeworkId) async {
    final submission = await getUserHomeworkSubmission(userId, homeworkId);
    return submission != null;
  }

  /// Grade homework submission (Admin only)
  Future<void> gradeSubmission(
    String submissionId,
    int score,
    String feedback,
    String gradedBy,
  ) async {
    try {
      await _supabase.from(_submissionsTable).update({
        'status': HomeworkStatus.graded.name,
        'score': score,
        'feedback': feedback,
        'graded_at': DateTime.now().toIso8601String(),
        'graded_by': gradedBy,
      }).eq('id', submissionId);
    } catch (e) {
      throw Exception('Ödev puanlandırılamadı: $e');
    }
  }

  /// Get all submissions (Admin - for tracking) - Real-time
  Stream<List<HomeworkSubmission>> getAllSubmissions() {
    return _supabase
        .from(_submissionsTable)
        .stream(primaryKey: ['id'])
        .order('submitted_at', ascending: false)
        .map((data) => data.map((item) => HomeworkSubmission.fromSupabase(item)).toList());
  }

  /// Get pending submissions (Admin - not yet graded) - Real-time
  Stream<List<HomeworkSubmission>> getPendingSubmissions() {
    return _supabase
        .from(_submissionsTable)
        .stream(primaryKey: ['id'])
        .eq('status', HomeworkStatus.submitted.name)
        .order('submitted_at')
        .map((data) => data.map((item) => HomeworkSubmission.fromSupabase(item)).toList());
  }

  /// Get late submissions - Real-time
  Stream<List<HomeworkSubmission>> getLateSubmissions() {
    return _supabase
        .from(_submissionsTable)
        .stream(primaryKey: ['id'])
        .eq('status', HomeworkStatus.late.name)
        .order('submitted_at', ascending: false)
        .map((data) => data.map((item) => HomeworkSubmission.fromSupabase(item)).toList());
  }

  /// Get submission statistics for a homework
  Future<Map<String, dynamic>> getHomeworkStatistics(String homeworkId) async {
    try {
      final response = await _supabase
          .from(_submissionsTable)
          .select()
          .eq('homework_id', homeworkId);

      int totalSubmissions = response.length;
      int graded = 0;
      int pending = 0;
      int late = 0;
      double totalScore = 0;
      int scoredSubmissions = 0;

      for (var data in response) {
        final submission = HomeworkSubmission.fromSupabase(data);

        if (submission.status == HomeworkStatus.graded) {
          graded++;
          if (submission.score != null) {
            totalScore += submission.score!;
            scoredSubmissions++;
          }
        } else if (submission.status == HomeworkStatus.submitted) {
          pending++;
        } else if (submission.status == HomeworkStatus.late) {
          late++;
        }
      }

      return {
        'totalSubmissions': totalSubmissions,
        'graded': graded,
        'pending': pending,
        'late': late,
        'averageScore': scoredSubmissions > 0 ? totalScore / scoredSubmissions : 0,
      };
    } catch (e) {
      throw Exception('İstatistikler hesaplanamadı: $e');
    }
  }

  /// Get homework with pagination
  Future<List<HomeworkModel>> getHomeworkPaginated({
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      final response = await _supabase
          .from(_homeworksTable)
          .select()
          .eq('is_active', true)
          .order('due_date')
          .range(page * pageSize, (page + 1) * pageSize - 1);

      return (response as List)
          .map((item) => HomeworkModel.fromSupabase(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to get paginated homework: $e');
    }
  }

  /// Get user's homework submissions with pagination
  Future<List<HomeworkSubmission>> getSubmissionsPaginated(
    String userId, {
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      final response = await _supabase
          .from(_submissionsTable)
          .select()
          .eq('user_id', userId)
          .order('submitted_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      return (response as List)
          .map((item) => HomeworkSubmission.fromSupabase(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to get paginated submissions: $e');
    }
  }

  /// Get homeworks for student (stub method for compatibility)
  Future<List<dynamic>> getHomeworksForStudent(String studentId) async {
    final homeworks = await getAllHomework().first;
    return homeworks;
  }

  /// Get homeworks for teacher (stub method for compatibility)
  Future<List<dynamic>> getHomeworksForTeacher(String teacherId) async {
    final homeworks = await getAllHomework().first;
    return homeworks;
  }
}
