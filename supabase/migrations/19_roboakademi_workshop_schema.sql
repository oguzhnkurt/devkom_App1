-- =============================================
-- ROBOAKADEMI WORKSHOP TRACKING MODULE
-- Adds attendance / payment / curriculum-progress tracking for the
-- real-world "RoboAkademi" robotics coding workshop, on top of the
-- existing users/parent-child architecture.
--
-- Design notes:
--  * Workshop students are young kids (5-6-7 yas) who do NOT have their
--    own login. Only the parent has a Supabase Auth account. So instead
--    of reusing the legacy parent_id/student_ids arrays (which assume the
--    child also has a separate auth user), we give each enrolled child its
--    own row in `workshop_students`, owned directly by the parent's
--    account (parent_user_id). This is much simpler for this use case.
--  * The 8-week curriculum CONTENT itself (theme/activities/kazanimlar)
--    is static and lives in Dart (lib/courses/data/roboakademi_curriculum_data.dart),
--    same pattern as the other course content in this app. Only the
--    per-student PROGRESS (current_week) is dynamic/stored here.
-- =============================================

-- =============================================
-- ENUMS
-- =============================================

CREATE TYPE workshop_attendance_feedback AS ENUM ('cok_iyi', 'iyi', 'gelismeli');
CREATE TYPE workshop_payment_status AS ENUM ('paid', 'pending');
CREATE TYPE workshop_enrollment_status AS ENUM ('active', 'inactive', 'graduated');

-- =============================================
-- USERS TABLE ADDITION
-- =============================================

-- Marks a parent account as belonging to a RoboAkademi workshop family.
-- Surfaces the "RoboAkademi Takip" entry point in the app for this user.
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_roboakademi BOOLEAN DEFAULT FALSE;
CREATE INDEX IF NOT EXISTS idx_users_is_roboakademi ON users(is_roboakademi);

-- =============================================
-- WORKSHOP STUDENTS (child profiles, owned by parent account)
-- =============================================

CREATE TABLE workshop_students (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    parent_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Basic info
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    birth_date DATE,
    photo_url TEXT,

    -- Program tracking
    cohort_start_date DATE NOT NULL DEFAULT CURRENT_DATE,
    current_week INTEGER NOT NULL DEFAULT 1, -- 1-8, which week of the 8-week program
    status workshop_enrollment_status NOT NULL DEFAULT 'active',

    -- Gamification / development
    total_points INTEGER NOT NULL DEFAULT 0,
    badges TEXT[] DEFAULT '{}',
    teacher_note TEXT, -- latest short note from teacher about overall development

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_workshop_students_parent_user_id ON workshop_students(parent_user_id);
CREATE INDEX idx_workshop_students_status ON workshop_students(status);

CREATE TRIGGER update_workshop_students_updated_at BEFORE UPDATE ON workshop_students
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================
-- WORKSHOP ATTENDANCE (per session date)
-- =============================================

CREATE TABLE workshop_attendance (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workshop_student_id UUID NOT NULL REFERENCES workshop_students(id) ON DELETE CASCADE,

    session_date DATE NOT NULL,
    week_number INTEGER, -- which of the 8 weeks this session belongs to
    attended BOOLEAN NOT NULL DEFAULT TRUE,
    feedback workshop_attendance_feedback, -- weekly 'gulumseme karti'
    teacher_note TEXT,

    created_by UUID REFERENCES users(id), -- teacher/admin who recorded it
    created_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(workshop_student_id, session_date)
);

CREATE INDEX idx_workshop_attendance_student_id ON workshop_attendance(workshop_student_id);
CREATE INDEX idx_workshop_attendance_session_date ON workshop_attendance(session_date DESC);

-- =============================================
-- WORKSHOP PAYMENTS (per month status)
-- =============================================

CREATE TABLE workshop_payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workshop_student_id UUID NOT NULL REFERENCES workshop_students(id) ON DELETE CASCADE,

    period_month DATE NOT NULL, -- first day of the relevant month, e.g. 2026-07-01
    status workshop_payment_status NOT NULL DEFAULT 'pending',
    amount NUMERIC,
    note TEXT,

    updated_by UUID REFERENCES users(id),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(workshop_student_id, period_month)
);

CREATE INDEX idx_workshop_payments_student_id ON workshop_payments(workshop_student_id);
CREATE INDEX idx_workshop_payments_period_month ON workshop_payments(period_month DESC);

-- =============================================
-- ROW LEVEL SECURITY
-- =============================================

ALTER TABLE workshop_students ENABLE ROW LEVEL SECURITY;
ALTER TABLE workshop_attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE workshop_payments ENABLE ROW LEVEL SECURITY;

-- Workshop students: parent can see/manage their own children;
-- teachers/admins can see and manage all (they run the sessions).
CREATE POLICY "Parents can view own children"
ON workshop_students FOR SELECT
USING (
    auth.uid() = parent_user_id OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('teacher', 'admin'))
);

CREATE POLICY "Parents can add own children"
ON workshop_students FOR INSERT
WITH CHECK (auth.uid() = parent_user_id);

CREATE POLICY "Parents can update own children basic info"
ON workshop_students FOR UPDATE
USING (
    auth.uid() = parent_user_id OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('teacher', 'admin'))
);

CREATE POLICY "Teachers can manage all workshop students"
ON workshop_students FOR ALL
USING (EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('teacher', 'admin')));

-- Attendance: parent can view their child's records; only teacher/admin write.
CREATE POLICY "Parents can view child attendance"
ON workshop_attendance FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM workshop_students ws
        WHERE ws.id = workshop_attendance.workshop_student_id
        AND ws.parent_user_id = auth.uid()
    ) OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('teacher', 'admin'))
);

CREATE POLICY "Teachers can manage attendance"
ON workshop_attendance FOR ALL
USING (EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('teacher', 'admin')));

-- Payments: parent can view (read-only status, no editing); only teacher/admin write.
CREATE POLICY "Parents can view child payments"
ON workshop_payments FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM workshop_students ws
        WHERE ws.id = workshop_payments.workshop_student_id
        AND ws.parent_user_id = auth.uid()
    ) OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('teacher', 'admin'))
);

CREATE POLICY "Teachers can manage payments"
ON workshop_payments FOR ALL
USING (EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('teacher', 'admin')));

-- =============================================
-- COMMENTS
-- =============================================

COMMENT ON TABLE workshop_students IS 'RoboAkademi workshop-enrolled children, owned directly by the parent auth account (children do not have their own login)';
COMMENT ON TABLE workshop_attendance IS 'Per-session attendance + weekly smiley-card feedback for RoboAkademi students';
COMMENT ON TABLE workshop_payments IS 'Per-month tuition payment status for RoboAkademi students (display only, no real payment processing)';

-- =============================================
-- SIGNUP TRIGGER UPDATE
-- Extend handle_new_user() (see 18_auto_create_user_profile_on_signup.sql)
-- so the 'is_roboakademi' flag chosen at signup/purpose-selection time is
-- also written into the server-side-created profile row.
-- =============================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.users (
    id,
    email,
    display_name,
    role,
    age_group,
    parent_id,
    is_roboakademi,
    created_at,
    last_login_at
  )
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),
    COALESCE(NULLIF(NEW.raw_user_meta_data->>'role', '')::user_role, 'student'),
    NULLIF(NEW.raw_user_meta_data->>'age_group', '')::age_group,
    NULLIF(NEW.raw_user_meta_data->>'parent_id', '')::uuid,
    COALESCE(NULLIF(NEW.raw_user_meta_data->>'is_roboakademi', '')::boolean, FALSE),
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO NOTHING;

  RETURN NEW;
END;
$$;
