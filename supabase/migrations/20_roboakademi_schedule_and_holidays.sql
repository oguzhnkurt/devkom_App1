-- =============================================
-- ROBOAKADEMI SCHEDULE + HOLIDAYS + PLANNED ABSENCE
-- Adds a lightweight "school calendar" layer on top of the existing
-- RoboAkademi workshop tracking module (19_roboakademi_workshop_schema.sql):
--   * a fixed weekly class day per student (e.g. every Saturday)
--   * a shared table of official/holiday dates with no class
--   * the ability for a PARENT to mark, in advance, that their child
--     will not attend an upcoming session ("planned absence"), separate
--     from the teacher's own after-the-fact attendance record.
--
-- Design notes:
--  * The actual list of upcoming session dates is computed client-side
--    (cohort_start_date + class_weekday + holiday skip), NOT stored here.
--    Only real attendance rows (recorded by the teacher, or a parent's
--    planned-absence marker) live in workshop_attendance.
--  * marked_by_parent distinguishes a parent's advance "we won't attend"
--    marker from the teacher's real post-session record. When the
--    teacher later records the actual attendance for that date, the
--    service layer overwrites the row and clears this flag.
-- =============================================

-- =============================================
-- WEEKLY CLASS DAY (per student)
-- =============================================

-- 1 = Monday ... 7 = Sunday (matches Dart's DateTime.weekday). Defaults to
-- Saturday (6), the typical RoboAkademi workshop day.
ALTER TABLE workshop_students ADD COLUMN IF NOT EXISTS class_weekday SMALLINT NOT NULL DEFAULT 6
    CHECK (class_weekday BETWEEN 1 AND 7);

-- =============================================
-- HOLIDAYS (shared across all RoboAkademi students)
-- =============================================

CREATE TABLE IF NOT EXISTS workshop_holidays (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    holiday_date DATE NOT NULL UNIQUE,
    name TEXT NOT NULL,

    created_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_workshop_holidays_date ON workshop_holidays(holiday_date);

ALTER TABLE workshop_holidays ENABLE ROW LEVEL SECURITY;

-- Any authenticated user (parent or teacher) needs to read the holiday
-- list to compute the upcoming class calendar.
CREATE POLICY "Authenticated users can view holidays"
ON workshop_holidays FOR SELECT
USING (auth.uid() IS NOT NULL);

CREATE POLICY "Teachers can manage holidays"
ON workshop_holidays FOR ALL
USING (EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('teacher', 'admin')));

COMMENT ON TABLE workshop_holidays IS 'Shared calendar of dates with no RoboAkademi class (official holidays, breaks). Applied on top of each student''s weekly class_weekday when computing the upcoming session schedule.';

-- =============================================
-- PLANNED ABSENCE (parent-marked, future dates only)
-- =============================================

ALTER TABLE workshop_attendance ADD COLUMN IF NOT EXISTS marked_by_parent BOOLEAN NOT NULL DEFAULT FALSE;

COMMENT ON COLUMN workshop_attendance.marked_by_parent IS 'TRUE when this row was created by the parent as an advance "we will not attend" notice, rather than the teacher''s real post-session record.';

-- Parents may create a planned-absence row for their own child, only for
-- a future session date, and only as attended = false.
CREATE POLICY "Parents can mark planned absence"
ON workshop_attendance FOR INSERT
WITH CHECK (
    EXISTS (
        SELECT 1 FROM workshop_students ws
        WHERE ws.id = workshop_attendance.workshop_student_id
        AND ws.parent_user_id = auth.uid()
    )
    AND session_date > CURRENT_DATE
    AND attended = FALSE
    AND marked_by_parent = TRUE
);

-- Parents may update/withdraw their own planned-absence marker as long as
-- the session date hasn't passed yet.
CREATE POLICY "Parents can update own planned absence"
ON workshop_attendance FOR UPDATE
USING (
    EXISTS (
        SELECT 1 FROM workshop_students ws
        WHERE ws.id = workshop_attendance.workshop_student_id
        AND ws.parent_user_id = auth.uid()
    )
    AND marked_by_parent = TRUE
    AND session_date > CURRENT_DATE
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM workshop_students ws
        WHERE ws.id = workshop_attendance.workshop_student_id
        AND ws.parent_user_id = auth.uid()
    )
    AND session_date > CURRENT_DATE
    AND attended = FALSE
    AND marked_by_parent = TRUE
);

CREATE POLICY "Parents can delete own planned absence"
ON workshop_attendance FOR DELETE
USING (
    EXISTS (
        SELECT 1 FROM workshop_students ws
        WHERE ws.id = workshop_attendance.workshop_student_id
        AND ws.parent_user_id = auth.uid()
    )
    AND marked_by_parent = TRUE
    AND session_date > CURRENT_DATE
);
