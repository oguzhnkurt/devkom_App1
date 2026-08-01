import '../models/workshop_student_model.dart';

/// Computes a RoboAkademi student's full class calendar (8 weekly sessions)
/// by combining:
///  * the student's [WorkshopStudentModel.cohortStartDate] and
///    [WorkshopStudentModel.classWeekday] (a fixed weekly rule, e.g.
///    "every Saturday"),
///  * the shared [WorkshopHolidayModel] list (dates with no class — those
///    weeks are skipped and the schedule simply continues the following
///    week),
///  * any real [WorkshopAttendanceRecord]s already on file for a date
///    (either the teacher's actual record, or the parent's own advance
///    "will not attend" marker).
///
/// This calendar is NOT persisted — it's recomputed on the fly from the
/// simple weekly rule, so changing the class day or adding a holiday
/// immediately reflects in everyone's view without a migration step.
List<WorkshopScheduleEntry> computeWorkshopSchedule({
  required WorkshopStudentModel student,
  required List<WorkshopHolidayModel> holidays,
  required List<WorkshopAttendanceRecord> attendance,
  int totalWeeks = 8,
}) {
  final holidayDates = <DateTime, String>{
    for (final h in holidays) _dateOnly(h.holidayDate): h.name,
  };
  final recordsByDate = <DateTime, WorkshopAttendanceRecord>{
    for (final r in attendance) _dateOnly(r.sessionDate): r,
  };

  final entries = <WorkshopScheduleEntry>[];
  DateTime cursor = _firstOccurrenceOnOrAfter(student.cohortStartDate, student.classWeekday);
  int weekNumber = 1;

  // Safety cap so a misconfigured holiday list (e.g. every week marked as
  // a holiday) can never spin this loop forever.
  var guard = 0;
  while (entries.length < totalWeeks && guard < totalWeeks * 6) {
    guard++;
    final day = _dateOnly(cursor);
    final holidayName = holidayDates[day];
    if (holidayName == null) {
      entries.add(WorkshopScheduleEntry(
        date: day,
        weekNumber: weekNumber,
        record: recordsByDate[day],
      ));
      weekNumber++;
    } else {
      // Show the skipped holiday date too, so parents understand why the
      // calendar "jumps" — but it doesn't consume a week number.
      entries.add(WorkshopScheduleEntry(
        date: day,
        weekNumber: weekNumber - 1,
        holidayName: holidayName,
      ));
    }
    cursor = cursor.add(const Duration(days: 7));
  }

  return entries;
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime _firstOccurrenceOnOrAfter(DateTime start, int weekday) {
  final startDay = _dateOnly(start);
  final diff = (weekday - startDay.weekday) % 7;
  return startDay.add(Duration(days: diff < 0 ? diff + 7 : diff));
}

const List<String> turkishMonthNames = [
  'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
  'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
];

const List<String> turkishWeekdayNames = [
  'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar',
];

String formatWorkshopDate(DateTime date) {
  final weekday = turkishWeekdayNames[date.weekday - 1];
  return '$weekday, ${date.day} ${turkishMonthNames[date.month - 1]} ${date.year}';
}
