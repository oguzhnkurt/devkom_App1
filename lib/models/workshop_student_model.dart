/// RoboAkademi workshop models: child profile, attendance, and payment
/// records. See supabase/migrations/19_roboakademi_workshop_schema.sql for
/// the backing tables.

enum WorkshopEnrollmentStatus { active, inactive, graduated }

enum WorkshopAttendanceFeedback { cokIyi, iyi, gelismeli }

enum WorkshopPaymentStatus { paid, pending }

WorkshopEnrollmentStatus _parseEnrollmentStatus(String? value) {
  switch (value) {
    case 'inactive':
      return WorkshopEnrollmentStatus.inactive;
    case 'graduated':
      return WorkshopEnrollmentStatus.graduated;
    default:
      return WorkshopEnrollmentStatus.active;
  }
}

WorkshopAttendanceFeedback? _parseFeedback(String? value) {
  switch (value) {
    case 'cok_iyi':
      return WorkshopAttendanceFeedback.cokIyi;
    case 'iyi':
      return WorkshopAttendanceFeedback.iyi;
    case 'gelismeli':
      return WorkshopAttendanceFeedback.gelismeli;
    default:
      return null;
  }
}

String feedbackToSupabase(WorkshopAttendanceFeedback feedback) {
  switch (feedback) {
    case WorkshopAttendanceFeedback.cokIyi:
      return 'cok_iyi';
    case WorkshopAttendanceFeedback.iyi:
      return 'iyi';
    case WorkshopAttendanceFeedback.gelismeli:
      return 'gelismeli';
  }
}

String feedbackDisplayName(WorkshopAttendanceFeedback feedback) {
  switch (feedback) {
    case WorkshopAttendanceFeedback.cokIyi:
      return 'Çok İyi';
    case WorkshopAttendanceFeedback.iyi:
      return 'İyi';
    case WorkshopAttendanceFeedback.gelismeli:
      return 'Gelişmeli';
  }
}

String feedbackEmoji(WorkshopAttendanceFeedback feedback) {
  switch (feedback) {
    case WorkshopAttendanceFeedback.cokIyi:
      return '😄';
    case WorkshopAttendanceFeedback.iyi:
      return '🙂';
    case WorkshopAttendanceFeedback.gelismeli:
      return '💪';
  }
}

class WorkshopStudentModel {
  final String id;
  final String parentUserId;
  final String firstName;
  final String lastName;
  final DateTime? birthDate;
  final String? photoUrl;
  final DateTime cohortStartDate;
  final int currentWeek;
  final WorkshopEnrollmentStatus status;
  final int totalPoints;
  final List<String> badges;
  final String? teacherNote;
  /// Which weekday the child's weekly class falls on.
  /// 1 = Monday ... 7 = Sunday (matches Dart's [DateTime.weekday]).
  final int classWeekday;
  /// Curriculum age band: 'age_4_6', 'age_7_10', or 'age_11_14'.
  /// Assigned manually via Supabase by an admin (see migration 21).
  final String ageGroup;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkshopStudentModel({
    required this.id,
    required this.parentUserId,
    required this.firstName,
    required this.lastName,
    this.birthDate,
    this.photoUrl,
    required this.cohortStartDate,
    required this.currentWeek,
    required this.status,
    required this.totalPoints,
    required this.badges,
    this.teacherNote,
    this.classWeekday = DateTime.saturday,
    this.ageGroup = 'age_4_6',
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  static const Map<int, String> weekdayNames = {
    DateTime.monday: 'Pazartesi',
    DateTime.tuesday: 'Salı',
    DateTime.wednesday: 'Çarşamba',
    DateTime.thursday: 'Perşembe',
    DateTime.friday: 'Cuma',
    DateTime.saturday: 'Cumartesi',
    DateTime.sunday: 'Pazar',
  };

  String get classWeekdayName => weekdayNames[classWeekday] ?? 'Cumartesi';

  static const Map<String, String> ageGroupNames = {
    'age_4_6': '4-6 Yaş · Kreş/Anaokulu Grubu',
    'age_7_10': '7-10 Yaş · İlkokul Grubu',
    'age_11_14': '11-14 Yaş · Ortaokul Grubu',
  };

  String get ageGroupName => ageGroupNames[ageGroup] ?? ageGroupNames['age_4_6']!;

  factory WorkshopStudentModel.fromMap(Map<String, dynamic> map) {
    return WorkshopStudentModel(
      id: map['id'],
      parentUserId: map['parent_user_id'],
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      birthDate: map['birth_date'] != null ? DateTime.parse(map['birth_date']) : null,
      photoUrl: map['photo_url'],
      cohortStartDate: DateTime.parse(map['cohort_start_date']),
      currentWeek: map['current_week'] ?? 1,
      status: _parseEnrollmentStatus(map['status']),
      totalPoints: map['total_points'] ?? 0,
      badges: map['badges'] != null ? List<String>.from(map['badges']) : [],
      teacherNote: map['teacher_note'],
      classWeekday: map['class_weekday'] ?? DateTime.saturday,
      ageGroup: map['age_group'] ?? 'age_4_6',
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}

class WorkshopAttendanceRecord {
  final String id;
  final String workshopStudentId;
  final DateTime sessionDate;
  final int? weekNumber;
  final bool attended;
  final WorkshopAttendanceFeedback? feedback;
  final String? teacherNote;
  /// TRUE when this row is the parent's advance "we will not attend"
  /// notice rather than the teacher's real post-session record.
  final bool markedByParent;
  final DateTime createdAt;

  WorkshopAttendanceRecord({
    required this.id,
    required this.workshopStudentId,
    required this.sessionDate,
    this.weekNumber,
    required this.attended,
    this.feedback,
    this.teacherNote,
    this.markedByParent = false,
    required this.createdAt,
  });

  factory WorkshopAttendanceRecord.fromMap(Map<String, dynamic> map) {
    return WorkshopAttendanceRecord(
      id: map['id'],
      workshopStudentId: map['workshop_student_id'],
      sessionDate: DateTime.parse(map['session_date']),
      weekNumber: map['week_number'],
      attended: map['attended'] ?? true,
      feedback: _parseFeedback(map['feedback']),
      teacherNote: map['teacher_note'],
      markedByParent: map['marked_by_parent'] ?? false,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

/// A shared "no class today" calendar date (official holiday, break, etc).
class WorkshopHolidayModel {
  final String id;
  final DateTime holidayDate;
  final String name;

  WorkshopHolidayModel({
    required this.id,
    required this.holidayDate,
    required this.name,
  });

  factory WorkshopHolidayModel.fromMap(Map<String, dynamic> map) {
    return WorkshopHolidayModel(
      id: map['id'],
      holidayDate: DateTime.parse(map['holiday_date']),
      name: map['name'] ?? '',
    );
  }
}

/// One row of a student's computed weekly class calendar — merges the
/// deterministic weekday+holiday schedule with any real attendance record
/// that already exists for that date.
class WorkshopScheduleEntry {
  final DateTime date;
  final int weekNumber;
  final WorkshopAttendanceRecord? record;
  final String? holidayName;

  WorkshopScheduleEntry({
    required this.date,
    required this.weekNumber,
    this.record,
    this.holidayName,
  });

  bool get isHoliday => holidayName != null;
  bool get isPast => date.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
  bool get isPlannedAbsence => record?.markedByParent == true;
  bool get hasTeacherRecord => record != null && record!.markedByParent == false;
}

class WorkshopPaymentRecord {
  final String id;
  final String workshopStudentId;
  final DateTime periodMonth;
  final WorkshopPaymentStatus status;
  final double? amount;
  final String? note;
  final DateTime updatedAt;

  WorkshopPaymentRecord({
    required this.id,
    required this.workshopStudentId,
    required this.periodMonth,
    required this.status,
    this.amount,
    this.note,
    required this.updatedAt,
  });

  factory WorkshopPaymentRecord.fromMap(Map<String, dynamic> map) {
    return WorkshopPaymentRecord(
      id: map['id'],
      workshopStudentId: map['workshop_student_id'],
      periodMonth: DateTime.parse(map['period_month']),
      status: map['status'] == 'paid' ? WorkshopPaymentStatus.paid : WorkshopPaymentStatus.pending,
      amount: map['amount'] != null ? (map['amount'] as num).toDouble() : null,
      note: map['note'],
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}

enum LessonRequestType { extra, makeup }

enum LessonRequestStatus { pending, approved, rejected }

LessonRequestType _parseRequestType(String? value) {
  return value == 'makeup' ? LessonRequestType.makeup : LessonRequestType.extra;
}

String requestTypeToSupabase(LessonRequestType type) => type == LessonRequestType.makeup ? 'makeup' : 'extra';

String requestTypeDisplayName(LessonRequestType type) =>
    type == LessonRequestType.makeup ? 'Telafi Dersi' : 'Ek Ders';

LessonRequestStatus _parseRequestStatus(String? value) {
  switch (value) {
    case 'approved':
      return LessonRequestStatus.approved;
    case 'rejected':
      return LessonRequestStatus.rejected;
    default:
      return LessonRequestStatus.pending;
  }
}

String requestStatusToSupabase(LessonRequestStatus status) {
  switch (status) {
    case LessonRequestStatus.approved:
      return 'approved';
    case LessonRequestStatus.rejected:
      return 'rejected';
    case LessonRequestStatus.pending:
      return 'pending';
  }
}

String requestStatusDisplayName(LessonRequestStatus status) {
  switch (status) {
    case LessonRequestStatus.approved:
      return 'Onaylandı';
    case LessonRequestStatus.rejected:
      return 'Reddedildi';
    case LessonRequestStatus.pending:
      return 'Bekliyor';
  }
}

/// A parent-initiated request for an extra lesson, or a "telafi" (makeup)
/// lesson for a session the child missed — with a proposed date and time,
/// reviewed by the teacher/admin. See
/// supabase/migrations/22_roboakademi_lesson_requests.sql.
class WorkshopLessonRequest {
  final String id;
  final String workshopStudentId;
  final LessonRequestType type;
  final DateTime requestedDate;
  /// Stored/displayed as "HH:mm" (24-hour).
  final String requestedTime;
  final String? note;
  final LessonRequestStatus status;
  final String? adminNote;
  final DateTime createdAt;
  /// Populated only when the request is fetched via a join with
  /// workshop_students (used on the teacher screen to show whose request it is).
  final String? studentName;

  WorkshopLessonRequest({
    required this.id,
    required this.workshopStudentId,
    required this.type,
    required this.requestedDate,
    required this.requestedTime,
    this.note,
    this.status = LessonRequestStatus.pending,
    this.adminNote,
    required this.createdAt,
    this.studentName,
  });

  factory WorkshopLessonRequest.fromMap(Map<String, dynamic> map) {
    String? studentName;
    final studentRel = map['workshop_students'];
    if (studentRel is Map) {
      final first = studentRel['first_name'] ?? '';
      final last = studentRel['last_name'] ?? '';
      studentName = '$first $last'.trim();
    }
    return WorkshopLessonRequest(
      id: map['id'],
      workshopStudentId: map['workshop_student_id'],
      type: _parseRequestType(map['request_type']),
      requestedDate: DateTime.parse(map['requested_date']),
      requestedTime: (map['requested_time'] as String).substring(0, 5),
      note: map['note'],
      status: _parseRequestStatus(map['status']),
      adminNote: map['admin_note'],
      createdAt: DateTime.parse(map['created_at']),
      studentName: studentName,
    );
  }
}
