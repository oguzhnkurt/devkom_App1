-- =============================================
-- CONTENT MANAGEMENT TABLES
-- =============================================
-- This migration creates all tables needed to store
-- courses, lessons, quizzes, and games in Supabase

-- =============================================
-- 1. COURSES TABLE
-- =============================================

CREATE TABLE IF NOT EXISTS courses (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  description TEXT,
  icon TEXT,                    -- Emoji or asset path
  primary_color TEXT,           -- Hex color code
  secondary_color TEXT,         -- Hex color code
  category TEXT NOT NULL,       -- kids, web, mobile, systems, robotics, data, scripting
  difficulty TEXT NOT NULL,     -- beginner, intermediate, advanced
  tags TEXT[],                  -- Array of tags
  total_lessons INTEGER DEFAULT 0,
  estimated_minutes INTEGER DEFAULT 0,
  is_premium BOOLEAN DEFAULT false,
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_courses_category ON courses(category);
CREATE INDEX IF NOT EXISTS idx_courses_difficulty ON courses(difficulty);
CREATE INDEX IF NOT EXISTS idx_courses_active ON courses(is_active);

-- =============================================
-- 2. COURSE LESSONS TABLE
-- =============================================

CREATE TABLE IF NOT EXISTS course_lessons (
  id TEXT PRIMARY KEY,
  course_id TEXT NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  lesson_order INTEGER NOT NULL,  -- Order within course
  estimated_minutes INTEGER DEFAULT 5,
  lesson_type TEXT NOT NULL,      -- theory, practice, project, quiz
  xp_reward INTEGER DEFAULT 10,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(course_id, lesson_order)
);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_lessons_course ON course_lessons(course_id);
CREATE INDEX IF NOT EXISTS idx_lessons_order ON course_lessons(course_id, lesson_order);

-- =============================================
-- 3. LESSON CONTENTS TABLE
-- =============================================

CREATE TABLE IF NOT EXISTS lesson_contents (
  id TEXT PRIMARY KEY,
  lesson_id TEXT NOT NULL REFERENCES course_lessons(id) ON DELETE CASCADE,
  content_order INTEGER NOT NULL,
  content_type TEXT NOT NULL,     -- heading, text, code, note, image, video, warning
  content TEXT NOT NULL,
  language TEXT,                  -- For code blocks (python, javascript, etc.)
  image_url TEXT,                 -- For images
  hint TEXT,                      -- Optional hint
  is_interactive BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(lesson_id, content_order)
);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_contents_lesson ON lesson_contents(lesson_id);

-- =============================================
-- 4. QUIZZES TABLE
-- =============================================

CREATE TABLE IF NOT EXISTS quizzes (
  id TEXT PRIMARY KEY,
  course_id TEXT NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  lesson_id TEXT REFERENCES course_lessons(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  description TEXT,
  passing_score INTEGER DEFAULT 70,  -- Minimum score to pass (%)
  time_limit_minutes INTEGER,        -- Optional time limit
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_quizzes_course ON quizzes(course_id);
CREATE INDEX IF NOT EXISTS idx_quizzes_lesson ON quizzes(lesson_id);

-- =============================================
-- 5. QUIZ QUESTIONS TABLE
-- =============================================

CREATE TABLE IF NOT EXISTS quiz_questions (
  id TEXT PRIMARY KEY,
  quiz_id TEXT NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
  question_order INTEGER NOT NULL,
  question_text TEXT NOT NULL,
  question_type TEXT NOT NULL,    -- multiple_choice, true_false, code
  options JSONB,                  -- Array of options for multiple choice
  correct_answer TEXT NOT NULL,
  explanation TEXT,               -- Explanation shown after answer
  points INTEGER DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(quiz_id, question_order)
);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_questions_quiz ON quiz_questions(quiz_id);

-- =============================================
-- 6. UPDATE GAMES TABLE (Add missing columns)
-- =============================================

-- Add columns that might be missing from games table
ALTER TABLE games ADD COLUMN IF NOT EXISTS category TEXT;
ALTER TABLE games ADD COLUMN IF NOT EXISTS game_type TEXT;
ALTER TABLE games ADD COLUMN IF NOT EXISTS thumbnail_url TEXT;
ALTER TABLE games ADD COLUMN IF NOT EXISTS difficulty INTEGER DEFAULT 1;
ALTER TABLE games ADD COLUMN IF NOT EXISTS estimated_minutes INTEGER DEFAULT 10;
ALTER TABLE games ADD COLUMN IF NOT EXISTS tags TEXT[];
ALTER TABLE games ADD COLUMN IF NOT EXISTS game_data JSONB;
ALTER TABLE games ADD COLUMN IF NOT EXISTS sort_order INTEGER DEFAULT 0;

-- =============================================
-- 7. INTERACTIVE LESSONS TABLE (Scratch-style)
-- =============================================

CREATE TABLE IF NOT EXISTS interactive_lessons (
  id TEXT PRIMARY KEY,
  course_id TEXT REFERENCES courses(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  lesson_order INTEGER NOT NULL,
  lesson_data JSONB NOT NULL,     -- Contains steps, mini-games, etc.
  estimated_minutes INTEGER DEFAULT 15,
  xp_reward INTEGER DEFAULT 20,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_interactive_course ON interactive_lessons(course_id);

-- =============================================
-- 8. USER PROGRESS TABLES
-- =============================================

-- Course progress
CREATE TABLE IF NOT EXISTS course_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  course_id TEXT NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  completed_lessons INTEGER DEFAULT 0,
  total_xp_earned INTEGER DEFAULT 0,
  last_accessed_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, course_id)
);

-- Lesson progress
CREATE TABLE IF NOT EXISTS lesson_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  lesson_id TEXT NOT NULL REFERENCES course_lessons(id) ON DELETE CASCADE,
  is_completed BOOLEAN DEFAULT false,
  xp_earned INTEGER DEFAULT 0,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, lesson_id)
);

-- Quiz attempts
CREATE TABLE IF NOT EXISTS quiz_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  quiz_id TEXT NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
  score INTEGER NOT NULL,
  total_questions INTEGER NOT NULL,
  passed BOOLEAN NOT NULL,
  time_taken_seconds INTEGER,
  answers JSONB,              -- Store user's answers
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for progress tables
CREATE INDEX IF NOT EXISTS idx_course_progress_user ON course_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_lesson_progress_user ON lesson_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_user ON quiz_attempts(user_id);

-- =============================================
-- 9. RLS POLICIES FOR CONTENT TABLES
-- =============================================

-- Courses: Public read access
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view active courses"
ON courses FOR SELECT
TO public
USING (is_active = true);

-- Lessons: Public read access
ALTER TABLE course_lessons ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view active lessons"
ON course_lessons FOR SELECT
TO public
USING (is_active = true);

-- Lesson contents: Public read access
ALTER TABLE lesson_contents ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view lesson contents"
ON lesson_contents FOR SELECT
TO public
USING (true);

-- Quizzes: Public read access
ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view active quizzes"
ON quizzes FOR SELECT
TO public
USING (is_active = true);

-- Quiz questions: Public read access
ALTER TABLE quiz_questions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view quiz questions"
ON quiz_questions FOR SELECT
TO public
USING (true);

-- Interactive lessons: Public read access
ALTER TABLE interactive_lessons ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view active interactive lessons"
ON interactive_lessons FOR SELECT
TO public
USING (is_active = true);

-- Progress tables: Users can only access their own progress
ALTER TABLE course_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own course progress"
ON course_progress FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own course progress"
ON course_progress FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own course progress"
ON course_progress FOR UPDATE
TO authenticated
USING (auth.uid() = user_id);

ALTER TABLE lesson_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own lesson progress"
ON lesson_progress FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own lesson progress"
ON lesson_progress FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own lesson progress"
ON lesson_progress FOR UPDATE
TO authenticated
USING (auth.uid() = user_id);

ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own quiz attempts"
ON quiz_attempts FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own quiz attempts"
ON quiz_attempts FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- =============================================
-- 10. FUNCTIONS FOR AUTOMATIC TIMESTAMPS
-- =============================================

-- Update updated_at timestamp automatically
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to relevant tables
DROP TRIGGER IF EXISTS update_courses_updated_at ON courses;
CREATE TRIGGER update_courses_updated_at
    BEFORE UPDATE ON courses
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_lessons_updated_at ON course_lessons;
CREATE TRIGGER update_lessons_updated_at
    BEFORE UPDATE ON course_lessons
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_quizzes_updated_at ON quizzes;
CREATE TRIGGER update_quizzes_updated_at
    BEFORE UPDATE ON quizzes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_interactive_updated_at ON interactive_lessons;
CREATE TRIGGER update_interactive_updated_at
    BEFORE UPDATE ON interactive_lessons
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =============================================
-- NOTES
-- =============================================
-- This schema supports:
-- ✅ 25 programming courses
-- ✅ Lessons with rich content (text, code, images, videos)
-- ✅ Quizzes and assessments
-- ✅ Interactive Scratch-style lessons
-- ✅ User progress tracking
-- ✅ Games integration
-- ✅ Public access to content
-- ✅ User-specific progress data
