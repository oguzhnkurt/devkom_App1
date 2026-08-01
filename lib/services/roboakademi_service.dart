import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../models/workshop_student_model.dart';

/// Service for the RoboAkademi workshop tracking module: child profiles,
/// attendance, and payment status. See
/// supabase/migrations/19_roboakademi_workshop_schema.sql for the schema.
class RoboAkademiService {
  final SupabaseClient _supabase = supabase;

  // ============================================================
  // CHILD PROFILES (workshop_students)
  // ============================================================

  /// Adds a child to the current parent's account.
  Future<WorkshopStudentModel> addChild({
    required String parentUserId,
    required String firstName,
    required String lastName,
    DateTime? birthDate,
    DateTime? cohortStartDate,
  }) async {
    final data = await _supabase
        .from('workshop_students')
        .insert({
          'parent_user_id': parentUserId,
          'first_name': firstName,
          'last_name': lastName,
          'birth_date': birthDate?.toIso8601String().split('T').first,
          'cohort_start_date':
              (cohortStartDate ?? DateTime.now()).toIso8601String().split('T').first,
        })
        .select()
        .single();
    return WorkshopStudentModel.fromMap(data);
  }

  /// Returns all children belonging to a parent account.
  Future<List<WorkshopStudentModel>> getChildrenForParent(String parentUserId) async {
    final data = await _supabase
        .from('workshop_students')
        .select()
        .eq('parent_user_id', parentUserId)
        .order('created_at');
    return (data as List).map((m) => WorkshopStudentModel.fromMap(m)).toList();
  }

  /// Returns all workshop students (for the teacher/admin picker screen).
  Future<List<WorkshopStudentModel>> getAllStudents() async {
    final data = await _supabase
        .from('workshop_students')
        .select()
        .order('first_name');
    return (data as List).map((m) => WorkshopStudentModel.fromMap(m)).toList();
  }

  Future<void> updateCurrentWeek({required String studentId, required int week}) async {
    await _supabase
        .from('workshop_students')
        .update({'current_week': week})
        .eq('id', studentId);
  }

  Future<void> updateTeacherNote({required String studentId, required String note}) async {
    await _supabase
        .from('workshop_students')
        .update({'teacher_note': note})
        .eq('id', studentId);
  }

  /// Updates which weekday (1=Monday..7=Sunday) the child's weekly class
  /// falls on, used to compute the upcoming session calendar.
  Future<void> updateClassWeekday({required String studentId, required int weekday}) async {
    await _supabase
        .from('workshop_students')
        .update({'class_weekday': weekday})
        .eq('id', studentId);
  }

  Future<void> addPoints({required String studentId, required int pointsToAdd}) async {
    // Read-modify-write; fine at this scale (small workshop class sizes).
    final current = await _supabase
        .from('workshop_students')
        .select('total_points')
        .eq('id', studentId)
        .single();
    final newTotal = (current['total_points'] ?? 0) + pointsToAdd;
    await _supabase
        .from('workshop_students')
        .update({'total_points': newTotal})
        .eq('id', studentId);
  }

  Future<void> addBadge({required String studentId, required String badge}) async {
    final current = await _supabase
        .from('workshop_students')
        .select('badges')
        .eq('id', studentId)
        .single();
    final badges = List<String>.from(current['badges'] ?? []);
    if (!badges.contains(badge)) {
      badges.add(badge);
      await _supabase
          .from('workshop_students')
          .update({'badges': badges})
          .eq('id', studentId);
    }
  }

  // ============================================================
  // ATTENDANCE (workshop_attendance)
  // ============================================================

  Future<List<WorkshopAttendanceRecord>> getAttendance(String studentId) async {
    final data = await _supabase
        .from('workshop_attendance')
        .select()
        .eq('workshop_student_id', studentId)
        .order('session_date', ascending: false);
    return (data as List).map((m) => WorkshopAttendanceRecord.fromMap(m)).toList();
  }

  /// Records (or updates, if already recorded that day) attendance for a session.
  Future<void> recordAttendance({
    required String studentId,
    required DateTime sessionDate,
    required bool attended,
    int? weekNumber,
    WorkshopAttendanceFeedback? feedback,
    String? teacherNote,
    required String createdBy,
  }) async {
    try {
      await _supabase.from('workshop_attendance').upsert({
        'workshop_student_id': studentId,
        'session_date': sessionDate.toIso8601String().split('T').first,
        'week_number': weekNumber,
        'attended': attended,
        'feedback': feedback != null ? feedbackToSupabase(feedback) : null,
        'teacher_note': teacherNote,
        'created_by': createdBy,
        // A teacher's real record always supersedes any earlier
        // parent-marked planned absence for the same date.
        'marked_by_parent': false,
      }, onConflict: 'workshop_student_id,session_date');
      debugPrint('✅ Yoklama kaydedildi: $studentId - $sessionDate');
    } catch (e) {
      debugPrint('❌ Yoklama kaydetme hatası: $e');
      rethrow;
    }
  }

  /// Parent-side: marks that the child will NOT attend an upcoming
  /// (strictly future) session. Enforced server-side by RLS as well.
  Future<void> markPlannedAbsence({
    required String studentId,
    required DateTime sessionDate,
    int? weekNumber,
    String? note,
  }) async {
    try {
      await _supabase.from('workshop_attendance').upsert({
        'workshop_student_id': studentId,
        'session_date': sessionDate.toIso8601String().split('T').first,
        'week_number': weekNumber,
        'attended': false,
        'teacher_note': note,
        'marked_by_parent': true,
      }, onConflict: 'workshop_student_id,session_date');
      debugPrint('✅ Devamsızlık bildirimi kaydedildi: $studentId - $sessionDate');
    } catch (e) {
      debugPrint('❌ Devamsızlık bildirimi hatası: $e');
      rethrow;
    }
  }

  /// Parent-side: withdraws a previously marked planned absence for a
  /// future session (e.g. the family changed their mind).
  Future<void> cancelPlannedAbsence({
    required String studentId,
    required DateTime sessionDate,
  }) async {
    try {
      await _supabase
          .from('workshop_attendance')
          .delete()
          .eq('workshop_student_id', studentId)
          .eq('session_date', sessionDate.toIso8601String().split('T').first)
          .eq('marked_by_parent', true);
    } catch (e) {
      debugPrint('❌ Devamsızlık bildirimi iptali hatası: $e');
      rethrow;
    }
  }

  // ============================================================
  // HOLIDAYS (workshop_holidays) — shared "no class" calendar dates
  // ============================================================

  Future<List<WorkshopHolidayModel>> getHolidays() async {
    final data = await _supabase
        .from('workshop_holidays')
        .select()
        .order('holiday_date');
    return (data as List).map((m) => WorkshopHolidayModel.fromMap(m)).toList();
  }

  Future<void> addHoliday({
    required DateTime date,
    required String name,
    required String createdBy,
  }) async {
    await _supabase.from('workshop_holidays').insert({
      'holiday_date': date.toIso8601String().split('T').first,
      'name': name,
      'created_by': createdBy,
    });
  }

  Future<void> deleteHoliday(String id) async {
    await _supabase.from('workshop_holidays').delete().eq('id', id);
  }

  // ============================================================
  // LESSON REQUESTS (workshop_lesson_requests) — parent-initiated
  // "extra lesson" / "makeup (telafi) lesson" requests
  // ============================================================

  /// Parent-side: requests for a single child.
  Future<List<WorkshopLessonRequest>> getLessonRequests(String studentId) async {
    final data = await _supabase
        .from('workshop_lesson_requests')
        .select()
        .eq('workshop_student_id', studentId)
        .order('created_at', ascending: false);
    return (data as List).map((m) => WorkshopLessonRequest.fromMap(m)).toList();
  }

  /// Teacher/admin-side: every request across all students, newest first,
  /// with the student's name embedded via a join.
  Future<List<WorkshopLessonRequest>> getAllLessonRequests() async {
    final data = await _supabase
        .from('workshop_lesson_requests')
        .select('*, workshop_students(first_name, last_name)')
        .order('created_at', ascending: false);
    return (data as List).map((m) => WorkshopLessonRequest.fromMap(m)).toList();
  }

  Future<void> createLessonRequest({
    required String studentId,
    required LessonRequestType type,
    required DateTime date,
    required String time, // "HH:mm"
    String? note,
    required String createdBy,
  }) async {
    try {
      await _supabase.from('workshop_lesson_requests').insert({
        'workshop_student_id': studentId,
        'request_type': requestTypeToSupabase(type),
        'requested_date': date.toIso8601String().split('T').first,
        'requested_time': time,
        'note': note,
        'created_by': createdBy,
      });
      debugPrint('✅ Ders talebi oluşturuldu: $studentId - $type - $date $time');
    } catch (e) {
      debugPrint('❌ Ders talebi oluşturma hatası: $e');
      rethrow;
    }
  }

  /// Parent-side: withdraws a still-pending request.
  Future<void> cancelLessonRequest(String id) async {
    await _supabase.from('workshop_lesson_requests').delete().eq('id', id);
  }

  /// Teacher/admin-side: approves or rejects a request.
  Future<void> updateLessonRequestStatus({
    required String id,
    required LessonRequestStatus status,
    String? adminNote,
  }) async {
    await _supabase.from('workshop_lesson_requests').update({
      'status': requestStatusToSupabase(status),
      'admin_note': adminNote,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  // ============================================================
  // PAYMENTS (workshop_payments)
  // ============================================================

  Future<List<WorkshopPaymentRecord>> getPayments(String studentId) async {
    final data = await _supabase
        .from('workshop_payments')
        .select()
        .eq('workshop_student_id', studentId)
        .order('period_month', ascending: false);
    return (data as List).map((m) => WorkshopPaymentRecord.fromMap(m)).toList();
  }

  Future<void> setPaymentStatus({
    required String studentId,
    required DateTime periodMonth,
    required WorkshopPaymentStatus status,
    double? amount,
    String? note,
    required String updatedBy,
  }) async {
    final firstOfMonth = DateTime(periodMonth.year, periodMonth.month, 1);
    try {
      await _supabase.from('workshop_payments').upsert({
        'workshop_student_id': studentId,
        'period_month': firstOfMonth.toIso8601String().split('T').first,
        'status': status == WorkshopPaymentStatus.paid ? 'paid' : 'pending',
        'amount': amount,
        'note': note,
        'updated_by': updatedBy,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'workshop_student_id,period_month');
      debugPrint('✅ Ödeme durumu güncellendi: $studentId - $firstOfMonth');
    } catch (e) {
      debugPrint('❌ Ödeme güncelleme hatası: $e');
      rethrow;
    }
  }
}
