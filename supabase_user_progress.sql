-- =====================================================
-- DEVKOM USER PROGRESS TABLE
-- XP/Level, Streak, and Daily Goals Tracking
-- =====================================================

-- Create user_progress table
CREATE TABLE IF NOT EXISTS user_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- XP and Level
  total_xp INTEGER DEFAULT 0,
  level INTEGER DEFAULT 1,

  -- Streak tracking
  streak_days INTEGER DEFAULT 0,
  last_active_date TIMESTAMP WITH TIME ZONE,
  longest_streak INTEGER DEFAULT 0,

  -- Daily goals (resets daily)
  daily_lessons_completed INTEGER DEFAULT 0,
  daily_games_played INTEGER DEFAULT 0,
  daily_quizzes_completed INTEGER DEFAULT 0,
  last_goal_reset_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- Progress tracking
  completed_lesson_ids TEXT[] DEFAULT '{}',
  earned_badge_ids TEXT[] DEFAULT '{}',

  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- Ensure one record per user
  UNIQUE(user_id)
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_user_progress_user_id ON user_progress(user_id);

-- Enable Row Level Security
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Users can only view their own progress
CREATE POLICY "Users can view own progress"
  ON user_progress FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own progress
CREATE POLICY "Users can insert own progress"
  ON user_progress FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own progress
CREATE POLICY "Users can update own progress"
  ON user_progress FOR UPDATE
  USING (auth.uid() = user_id);

-- Function to auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_user_progress_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for auto-updating timestamp
DROP TRIGGER IF EXISTS trigger_update_user_progress_timestamp ON user_progress;
CREATE TRIGGER trigger_update_user_progress_timestamp
  BEFORE UPDATE ON user_progress
  FOR EACH ROW
  EXECUTE FUNCTION update_user_progress_timestamp();

-- Function to reset daily goals at midnight
CREATE OR REPLACE FUNCTION reset_daily_goals_if_needed()
RETURNS TRIGGER AS $$
BEGIN
  -- Check if date has changed
  IF NEW.last_goal_reset_date::date < CURRENT_DATE THEN
    NEW.daily_lessons_completed = 0;
    NEW.daily_games_played = 0;
    NEW.daily_quizzes_completed = 0;
    NEW.last_goal_reset_date = NOW();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to reset daily goals on update
DROP TRIGGER IF EXISTS trigger_reset_daily_goals ON user_progress;
CREATE TRIGGER trigger_reset_daily_goals
  BEFORE UPDATE ON user_progress
  FOR EACH ROW
  EXECUTE FUNCTION reset_daily_goals_if_needed();

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

-- Function to calculate level from XP
CREATE OR REPLACE FUNCTION calculate_level(xp INTEGER)
RETURNS INTEGER AS $$
BEGIN
  IF xp < 100 THEN RETURN 1;
  ELSIF xp < 250 THEN RETURN 2;
  ELSIF xp < 500 THEN RETURN 3;
  ELSIF xp < 850 THEN RETURN 4;
  ELSIF xp < 1300 THEN RETURN 5;
  ELSIF xp < 1850 THEN RETURN 6;
  ELSIF xp < 2500 THEN RETURN 7;
  ELSIF xp < 3250 THEN RETURN 8;
  ELSIF xp < 4100 THEN RETURN 9;
  ELSIF xp < 5050 THEN RETURN 10;
  ELSE RETURN 10 + ((xp - 5050) / 1000) + 1;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to get XP required for next level
CREATE OR REPLACE FUNCTION get_xp_for_next_level(current_level INTEGER)
RETURNS INTEGER AS $$
BEGIN
  CASE current_level
    WHEN 1 THEN RETURN 100;
    WHEN 2 THEN RETURN 250;
    WHEN 3 THEN RETURN 500;
    WHEN 4 THEN RETURN 850;
    WHEN 5 THEN RETURN 1300;
    WHEN 6 THEN RETURN 1850;
    WHEN 7 THEN RETURN 2500;
    WHEN 8 THEN RETURN 3250;
    WHEN 9 THEN RETURN 4100;
    WHEN 10 THEN RETURN 5050;
    ELSE RETURN 5050 + ((current_level - 10) * 1000);
  END CASE;
END;
$$ LANGUAGE plpgsql;

-- Function to add XP and update level
CREATE OR REPLACE FUNCTION add_xp(p_user_id UUID, p_xp INTEGER)
RETURNS user_progress AS $$
DECLARE
  result user_progress;
BEGIN
  UPDATE user_progress
  SET
    total_xp = total_xp + p_xp,
    level = calculate_level(total_xp + p_xp),
    last_active_date = CURRENT_DATE
  WHERE user_id = p_user_id
  RETURNING * INTO result;

  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Function to update streak
CREATE OR REPLACE FUNCTION update_streak(p_user_id UUID)
RETURNS user_progress AS $$
DECLARE
  result user_progress;
  current_record user_progress;
BEGIN
  SELECT * INTO current_record FROM user_progress WHERE user_id = p_user_id;

  IF current_record.last_active_date IS NULL THEN
    -- First activity
    UPDATE user_progress
    SET
      streak_days = 1,
      last_active_date = CURRENT_DATE,
      longest_streak = GREATEST(1, longest_streak)
    WHERE user_id = p_user_id
    RETURNING * INTO result;
  ELSIF current_record.last_active_date = CURRENT_DATE - INTERVAL '1 day' THEN
    -- Consecutive day
    UPDATE user_progress
    SET
      streak_days = streak_days + 1,
      last_active_date = CURRENT_DATE,
      longest_streak = GREATEST(streak_days + 1, longest_streak)
    WHERE user_id = p_user_id
    RETURNING * INTO result;
  ELSIF current_record.last_active_date < CURRENT_DATE - INTERVAL '1 day' THEN
    -- Streak broken
    UPDATE user_progress
    SET
      streak_days = 1,
      last_active_date = CURRENT_DATE
    WHERE user_id = p_user_id
    RETURNING * INTO result;
  ELSE
    -- Same day, no change
    result = current_record;
  END IF;

  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- INITIAL DATA MIGRATION
-- Creates user_progress records for existing users
-- =====================================================

INSERT INTO user_progress (user_id)
SELECT id FROM auth.users
WHERE id NOT IN (SELECT user_id FROM user_progress)
ON CONFLICT (user_id) DO NOTHING;

-- =====================================================
-- SAMPLE QUERIES
-- =====================================================

-- Get user progress:
-- SELECT * FROM user_progress WHERE user_id = 'your-user-id';

-- Add XP to user:
-- SELECT add_xp('your-user-id', 50);

-- Update streak:
-- SELECT update_streak('your-user-id');

-- Get leaderboard (top 10):
-- SELECT u.email, up.total_xp, up.level, up.streak_days
-- FROM user_progress up
-- JOIN auth.users u ON up.user_id = u.id
-- ORDER BY up.total_xp DESC
-- LIMIT 10;
