-- =============================================
-- ROBOAKADEMI LESSON REQUESTS
-- Lets a parent request either:
--   * 'extra'  -> an additional lesson beyond the normal weekly schedule
--   * 'makeup' -> a replacement ("telafi") lesson for a session the child
--                 missed, with a proposed date and time
-- The teacher/admin reviews the request and marks it approved or rejected.
-- =============================================

CREATE TABLE IF NOT EXISTS workshop_lesson_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workshop_student_id UUID NOT NULL REFERENCES workshop_students(id) ON DELETE CASCADE,
    request_type TEXT NOT NULL CHECK (request_type IN ('extra', 'makeup')),
    requested_date DATE NOT NULL,
    requested_time TIME NOT NULL,
    note TEXT,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    admin_note TEXT,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_workshop_lesson_requests_student ON workshop_lesson_requests(workshop_student_id);
CREATE INDEX IF NOT EXISTS idx_workshop_lesson_requests_status ON workshop_lesson_requests(status);

ALTER TABLE workshop_lesson_requests ENABLE ROW LEVEL SECURITY;

-- Parents can see and create requests for their own child, and withdraw
-- (delete) their own request while it's still pending.
CREATE POLICY "Parents can view own lesson requests"
ON workshop_lesson_requests FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM workshop_students ws
        WHERE ws.id = workshop_lesson_requests.workshop_student_id
        AND ws.parent_user_id = auth.uid()
    )
);

CREATE POLICY "Parents can create lesson requests"
ON workshop_lesson_requests FOR INSERT
WITH CHECK (
    EXISTS (
        SELECT 1 FROM workshop_students ws
        WHERE ws.id = workshop_lesson_requests.workshop_student_id
        AND ws.parent_user_id = auth.uid()
    )
    AND status = 'pending'
);

CREATE POLICY "Parents can cancel own pending lesson requests"
ON workshop_lesson_requests FOR DELETE
USING (
    EXISTS (
        SELECT 1 FROM workshop_students ws
        WHERE ws.id = workshop_lesson_requests.workshop_student_id
        AND ws.parent_user_id = auth.uid()
    )
    AND status = 'pending'
);

-- Teachers/admins can see every request and update its status (approve /
-- reject), optionally leaving an admin_note.
CREATE POLICY "Teachers can view all lesson requests"
ON workshop_lesson_requests FOR SELECT
USING (EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('teacher', 'admin')));

CREATE POLICY "Teachers can update lesson requests"
ON workshop_lesson_requests FOR UPDATE
USING (EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('teacher', 'admin')));

COMMENT ON TABLE workshop_lesson_requests IS 'Parent-initiated requests for an extra lesson or a makeup ("telafi") lesson, reviewed by the teacher/admin.';
