-- =============================================
-- ENHANCED INTERACTIVE CURRICULUM SCHEMA
-- =============================================
-- This migration adds rich interactive content support
-- inspired by freeCodeCamp and The Odin Project

-- =============================================
-- 1. ADD NEW LESSON TYPES
-- =============================================

-- Extend lesson_type enum with new interactive types
COMMENT ON COLUMN course_lessons.lesson_type IS
'Lesson types:
- theory: Text-based theory lessons
- practice: Basic practice exercises
- code_challenge: freeCodeCamp-style coding challenges
- drag_drop: Scratch-style block programming
- quiz: Interactive quiz
- fill_blank: Fill-in-the-blank exercises
- match_pairs: Match pairs game
- sort_order: Sorting/ordering activity
- project: Mini project assignments';

-- =============================================
-- 2. ADD NEW CONTENT TYPES
-- =============================================

COMMENT ON COLUMN lesson_contents.content_type IS
'Content types:
- heading: Section heading
- text: Paragraph text
- code: Code snippet (static)
- note: Info box/note
- image: Image
- video: Video embed
- warning: Warning box
- task: Exercise task
- output: Expected output
- interactive_code: Live code editor
- drag_drop_blocks: Scratch-style blocks
- canvas: Drawing/animation canvas
- terminal: Terminal simulator
- file_tree: File explorer view
- game_preview: Game/animation preview';

-- =============================================
-- 3. ENHANCED INTERACTIVE LESSONS TABLE
-- =============================================

-- Drop and recreate with better structure
DROP TABLE IF EXISTS interactive_lessons CASCADE;

CREATE TABLE IF NOT EXISTS interactive_lessons (
  id TEXT PRIMARY KEY,
  course_id TEXT NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  lesson_order INTEGER NOT NULL,
  lesson_type TEXT NOT NULL, -- code_challenge, drag_drop, quiz, etc.

  -- Challenge configuration
  challenge_config JSONB, -- Instructions, starter code, tests, hints

  -- Interactive workspace config
  workspace_config JSONB, -- Editor settings, available blocks, canvas size

  -- Success criteria
  success_criteria JSONB, -- What needs to be achieved to pass

  -- Solution and hints
  solution_code TEXT, -- Reference solution
  hints JSONB, -- Progressive hints array

  -- Rewards
  xp_reward INTEGER DEFAULT 20,
  estimated_minutes INTEGER DEFAULT 15,

  -- Metadata
  difficulty INTEGER DEFAULT 1, -- 1-5
  tags TEXT[],
  prerequisites TEXT[], -- Array of lesson IDs

  -- Status
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(course_id, lesson_order)
);

CREATE INDEX IF NOT EXISTS idx_interactive_course ON interactive_lessons(course_id);
CREATE INDEX IF NOT EXISTS idx_interactive_type ON interactive_lessons(lesson_type);
CREATE INDEX IF NOT EXISTS idx_interactive_difficulty ON interactive_lessons(difficulty);

-- =============================================
-- 4. CHALLENGE TEMPLATES TABLE
-- =============================================

CREATE TABLE IF NOT EXISTS challenge_templates (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  challenge_type TEXT NOT NULL, -- code_challenge, drag_drop, quiz, etc.
  description TEXT,

  -- Template structure
  template_config JSONB NOT NULL, -- Base configuration for this type

  -- Default settings
  default_workspace JSONB, -- Default workspace settings
  default_success_criteria JSONB,

  -- Usage
  used_count INTEGER DEFAULT 0,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Sample templates
INSERT INTO challenge_templates (id, name, challenge_type, description, template_config) VALUES
('code_basic', 'Basic Code Challenge', 'code_challenge', 'Simple coding exercise',
 '{"editor": "code", "language": "python", "showTests": true, "showHints": true}'::jsonb),

('scratch_blocks', 'Scratch-Style Blocks', 'drag_drop', 'Block-based programming',
 '{"workspace": "blocks", "toolbox": "basic", "maxBlocks": 20}'::jsonb),

('quiz_multi', 'Multiple Choice Quiz', 'quiz', 'Multiple choice questions',
 '{"type": "multiple_choice", "showExplanation": true, "randomize": false}'::jsonb),

('fill_code', 'Fill in Code Blanks', 'fill_blank', 'Complete the code',
 '{"type": "code_completion", "showSolution": false, "attempts": 3}'::jsonb),

('match_game', 'Match Pairs', 'match_pairs', 'Match related items',
 '{"type": "matching", "maxPairs": 8, "showImages": true}'::jsonb),

('mini_project', 'Mini Project', 'project', 'Build a small project',
 '{"type": "project", "files": ["main.py"], "showFileTree": true, "autoSave": true}'::jsonb);

-- =============================================
-- 5. USER CHALLENGE PROGRESS
-- =============================================

CREATE TABLE IF NOT EXISTS challenge_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  challenge_id TEXT NOT NULL REFERENCES interactive_lessons(id) ON DELETE CASCADE,

  -- Progress
  status TEXT NOT NULL DEFAULT 'not_started', -- not_started, in_progress, completed, failed
  attempts INTEGER DEFAULT 0,
  hints_used INTEGER DEFAULT 0,

  -- Solution submitted
  submitted_code TEXT,
  test_results JSONB, -- Array of test results

  -- Performance
  time_spent_seconds INTEGER DEFAULT 0,
  xp_earned INTEGER DEFAULT 0,
  stars_earned INTEGER DEFAULT 0, -- 0-3 stars based on performance

  -- Timestamps
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  last_accessed_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(user_id, challenge_id)
);

CREATE INDEX IF NOT EXISTS idx_challenge_progress_user ON challenge_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_challenge_progress_status ON challenge_progress(status);

-- =============================================
-- 6. CODE SNIPPETS LIBRARY
-- =============================================

CREATE TABLE IF NOT EXISTS code_snippets (
  id TEXT PRIMARY KEY,
  course_id TEXT REFERENCES courses(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  language TEXT NOT NULL,
  code TEXT NOT NULL,

  -- Categorization
  category TEXT, -- example, template, reference, solution
  tags TEXT[],
  difficulty INTEGER DEFAULT 1,

  -- Usage
  used_in_lessons TEXT[], -- Array of lesson IDs
  view_count INTEGER DEFAULT 0,

  -- Metadata
  is_public BOOLEAN DEFAULT true,
  created_by UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_snippets_course ON code_snippets(course_id);
CREATE INDEX IF NOT EXISTS idx_snippets_language ON code_snippets(language);
CREATE INDEX IF NOT EXISTS idx_snippets_category ON code_snippets(category);

-- =============================================
-- 7. PROJECTS TABLE
-- =============================================

CREATE TABLE IF NOT EXISTS course_projects (
  id TEXT PRIMARY KEY,
  course_id TEXT NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,

  -- Project details
  project_type TEXT NOT NULL, -- website, game, app, animation, robot
  difficulty INTEGER DEFAULT 1,
  estimated_hours INTEGER DEFAULT 2,

  -- Requirements
  requirements JSONB, -- What needs to be built
  starter_files JSONB, -- Initial file structure
  resources JSONB, -- Links, images, assets

  -- Milestones
  milestones JSONB, -- Step-by-step checkpoints

  -- Rewards
  xp_reward INTEGER DEFAULT 100,
  certificate_eligible BOOLEAN DEFAULT false,

  -- Order and status
  project_order INTEGER,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(course_id, project_order)
);

CREATE INDEX IF NOT EXISTS idx_projects_course ON course_projects(course_id);
CREATE INDEX IF NOT EXISTS idx_projects_type ON course_projects(project_type);

-- =============================================
-- 8. USER PROJECT SUBMISSIONS
-- =============================================

CREATE TABLE IF NOT EXISTS project_submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  project_id TEXT NOT NULL REFERENCES course_projects(id) ON DELETE CASCADE,

  -- Submission
  submission_url TEXT, -- GitHub, CodePen, etc.
  files JSONB, -- File contents if inline
  description TEXT,
  screenshots TEXT[], -- Array of image URLs

  -- Review
  status TEXT DEFAULT 'submitted', -- submitted, approved, needs_revision, rejected
  reviewer_feedback TEXT,
  reviewed_at TIMESTAMPTZ,
  reviewed_by UUID REFERENCES users(id) ON DELETE SET NULL,

  -- Scoring
  score INTEGER, -- 0-100
  xp_earned INTEGER DEFAULT 0,

  -- Timestamps
  submitted_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(user_id, project_id)
);

CREATE INDEX IF NOT EXISTS idx_submissions_user ON project_submissions(user_id);
CREATE INDEX IF NOT EXISTS idx_submissions_project ON project_submissions(project_id);
CREATE INDEX IF NOT EXISTS idx_submissions_status ON project_submissions(status);

-- =============================================
-- 9. RLS POLICIES
-- =============================================

-- Interactive lessons: Public read
ALTER TABLE interactive_lessons ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view active interactive lessons"
ON interactive_lessons FOR SELECT
TO public
USING (is_active = true);

-- Challenge templates: Public read
ALTER TABLE challenge_templates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view challenge templates"
ON challenge_templates FOR SELECT
TO public
USING (true);

-- Code snippets: Public read for public snippets
ALTER TABLE code_snippets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view public snippets"
ON code_snippets FOR SELECT
TO public
USING (is_public = true);

-- Projects: Public read
ALTER TABLE course_projects ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view active projects"
ON course_projects FOR SELECT
TO public
USING (is_active = true);

-- Challenge progress: Users can only access their own
ALTER TABLE challenge_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own challenge progress"
ON challenge_progress FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own challenge progress"
ON challenge_progress FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own challenge progress"
ON challenge_progress FOR UPDATE
TO authenticated
USING (auth.uid() = user_id);

-- Project submissions: Users can view and manage their own
ALTER TABLE project_submissions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own submissions"
ON project_submissions FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own submissions"
ON project_submissions FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own submissions"
ON project_submissions FOR UPDATE
TO authenticated
USING (auth.uid() = user_id);

-- =============================================
-- 10. TRIGGERS
-- =============================================

DROP TRIGGER IF EXISTS update_interactive_updated_at ON interactive_lessons;
CREATE TRIGGER update_interactive_updated_at
    BEFORE UPDATE ON interactive_lessons
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_templates_updated_at ON challenge_templates;
CREATE TRIGGER update_templates_updated_at
    BEFORE UPDATE ON challenge_templates
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_snippets_updated_at ON code_snippets;
CREATE TRIGGER update_snippets_updated_at
    BEFORE UPDATE ON code_snippets
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_projects_updated_at ON course_projects;
CREATE TRIGGER update_projects_updated_at
    BEFORE UPDATE ON course_projects
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =============================================
-- SUMMARY
-- =============================================
-- This schema supports:
-- ✅ Code challenges (freeCodeCamp style)
-- ✅ Drag-drop block programming (Scratch style)
-- ✅ Multiple lesson types (quiz, fill-blank, matching, etc.)
-- ✅ Rich interactive content
-- ✅ Project-based learning
-- ✅ Progress tracking with stars/XP
-- ✅ Code snippet library
-- ✅ Project submissions and review
-- ✅ Template-based challenge creation
