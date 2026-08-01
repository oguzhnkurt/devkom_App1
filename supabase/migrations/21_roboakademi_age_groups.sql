-- =============================================
-- ROBOAKADEMI AGE GROUPS
-- Adds an age_group classification to each RoboAkademi student so the app
-- can show the correct 8-week curriculum for their band:
--   * age_4_6   -> Kreş / Anaokulu grubu (4-6 yaş)
--   * age_7_10  -> İlkokul grubu (7-10 yaş)
--   * age_11_14 -> Ortaokul grubu (11-14 yaş)
--
-- Assignment is done manually by the admin directly in Supabase (no admin
-- UI), per the same "DB-managed" pattern used for class_weekday/holidays in
-- migration 20.
--
-- Default is 'age_4_6' because the original 8-week curriculum content
-- (RoboAkademi_5-6-7_Yas_8_Haftalik_Mufredat.pdf) already targets that
-- band, so existing rows keep showing the same curriculum they always did
-- until the admin reassigns them.
-- =============================================

ALTER TABLE workshop_students ADD COLUMN IF NOT EXISTS age_group TEXT NOT NULL DEFAULT 'age_4_6'
    CHECK (age_group IN ('age_4_6', 'age_7_10', 'age_11_14'));

COMMENT ON COLUMN workshop_students.age_group IS 'Curriculum age band: age_4_6 (kreş/anaokulu), age_7_10, or age_11_14. Assigned manually via Supabase by an admin.';
