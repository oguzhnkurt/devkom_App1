-- =============================================
-- REMOVE ADMIN FEATURES AND FIX INFINITE RECURSION
-- =============================================
-- This migration removes all admin-related RLS policies and helper functions
-- that cause infinite recursion by querying the users table

-- =============================================
-- 1. DROP HELPER FUNCTIONS THAT CAUSE RECURSION
-- =============================================

-- Drop admin check function (causes infinite recursion)
DROP FUNCTION IF EXISTS auth.is_admin();

-- Drop teacher check function (causes infinite recursion)
DROP FUNCTION IF EXISTS auth.is_teacher();

-- Drop parent check function (causes infinite recursion)
DROP FUNCTION IF EXISTS auth.is_parent();

-- Drop parent_of check function (causes infinite recursion)
DROP FUNCTION IF EXISTS auth.is_parent_of(UUID);

-- =============================================
-- 2. DROP ALL ADMIN-RELATED POLICIES
-- =============================================

-- Users table admin policies
DROP POLICY IF EXISTS "Admins can manage all users" ON users;

-- Posts admin policies
DROP POLICY IF EXISTS "Users can delete own posts, admins can delete any" ON posts;

-- Comments admin policies
DROP POLICY IF EXISTS "Users can delete own comments, admins can delete any" ON post_comments;

-- Reports admin policies
DROP POLICY IF EXISTS "Admins can view reports" ON post_reports;

-- Games admin policies
DROP POLICY IF EXISTS "Admins can manage games" ON games;

-- Surveys admin policies
DROP POLICY IF EXISTS "Admins can manage surveys" ON surveys;

-- Survey responses admin policies (partial)
DROP POLICY IF EXISTS "Users can view own responses" ON survey_responses;

-- Camera links admin policies
DROP POLICY IF EXISTS "Admins can manage camera links" ON camera_links;
DROP POLICY IF EXISTS "Users with camera access can view links" ON camera_links;

-- Millionaire questions admin policies
DROP POLICY IF EXISTS "Admins can manage questions" ON millionaire_questions;

-- Support messages admin policies
DROP POLICY IF EXISTS "Admins can manage support messages" ON support_messages;
DROP POLICY IF EXISTS "Users can view own support messages" ON support_messages;

-- Weekly curriculum admin policies
DROP POLICY IF EXISTS "Users can view curriculums" ON weekly_curriculums;

-- Games view policy that checks admin
DROP POLICY IF EXISTS "Users can view active games" ON games;

-- Play sessions admin policy
DROP POLICY IF EXISTS "Users can view own sessions, parents can view children" ON play_sessions;

-- Homework submissions policies with admin checks
DROP POLICY IF EXISTS "Users can view relevant submissions" ON homework_submissions;

-- Student portfolios policies
DROP POLICY IF EXISTS "Users can view portfolios" ON student_portfolios;

-- Surveys view policy
DROP POLICY IF EXISTS "Users can view active surveys" ON surveys;

-- Posts view policy with admin check
DROP POLICY IF EXISTS "Anyone can view approved posts" ON posts;

-- =============================================
-- 3. FIX USERS TABLE INSERT POLICY
-- =============================================

-- Drop restrictive insert policy
DROP POLICY IF EXISTS "Users can insert own profile" ON users;
DROP POLICY IF EXISTS "Users can insert own profile during signup" ON users;

-- Create new policy that allows registration before full authentication
CREATE POLICY "Users can insert own profile during signup"
ON users FOR INSERT
TO public  -- Allow both authenticated and anon
WITH CHECK (auth.uid() = id);

-- Fix SELECT policy to allow public access
DROP POLICY IF EXISTS "Users can view all profiles" ON users;

CREATE POLICY "Users can view all profiles"
ON users FOR SELECT
TO public  -- Allow both authenticated and anon
USING (true);

-- =============================================
-- 4. RECREATE SIMPLIFIED POLICIES (NO ADMIN CHECKS)
-- =============================================

-- Posts: Users can delete only their own posts
DROP POLICY IF EXISTS "Users can delete own posts" ON posts;
CREATE POLICY "Users can delete own posts"
ON posts FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Comments: Users can delete only their own comments
DROP POLICY IF EXISTS "Users can delete own comments" ON post_comments;
CREATE POLICY "Users can delete own comments"
ON post_comments FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Posts: Everyone can view approved posts, users can see their own
DROP POLICY IF EXISTS "Users can view posts" ON posts;
CREATE POLICY "Users can view posts"
ON posts FOR SELECT
TO authenticated
USING (is_approved = true OR user_id = auth.uid());

-- Games: Everyone can view active games
DROP POLICY IF EXISTS "Users can view games" ON games;
CREATE POLICY "Users can view games"
ON games FOR SELECT
TO authenticated
USING (is_active = true);

-- Surveys: Users can view active surveys
DROP POLICY IF EXISTS "Users can view surveys" ON surveys;
CREATE POLICY "Users can view surveys"
ON surveys FOR SELECT
TO authenticated
USING (is_active = true);

-- Survey responses: Users can view only their own responses
DROP POLICY IF EXISTS "Users can view own survey responses" ON survey_responses;
CREATE POLICY "Users can view own survey responses"
ON survey_responses FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Support messages: Users can view only their own messages
DROP POLICY IF EXISTS "Users can view own messages" ON support_messages;
CREATE POLICY "Users can view own messages"
ON support_messages FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Camera links: No special access - disabled
-- (Admin feature removed)

-- Weekly curriculum: Users can view active curriculums
DROP POLICY IF EXISTS "Users can view active curriculums" ON weekly_curriculums;
CREATE POLICY "Users can view active curriculums"
ON weekly_curriculums FOR SELECT
TO authenticated
USING (is_active = true);

-- Homework submissions: Users can view their own submissions
DROP POLICY IF EXISTS "Users can view own submissions" ON homework_submissions;
CREATE POLICY "Users can view own submissions"
ON homework_submissions FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Student portfolios: Students can view their own portfolio
DROP POLICY IF EXISTS "Students can view own portfolio" ON student_portfolios;
CREATE POLICY "Students can view own portfolio"
ON student_portfolios FOR SELECT
TO authenticated
USING (auth.uid() = student_id);

-- Play sessions: Users can view their own sessions
DROP POLICY IF EXISTS "Users can view own play sessions" ON play_sessions;
CREATE POLICY "Users can view own play sessions"
ON play_sessions FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- =============================================
-- NOTES
-- =============================================
-- This migration removes all admin functionality to prevent infinite recursion
-- The infinite recursion occurred because:
-- 1. auth.is_admin() function queries the users table
-- 2. users table has RLS enabled
-- 3. Some policies on users table call auth.is_admin()
-- 4. This creates an infinite loop

-- After this migration:
-- - No admin privileges
-- - No teacher-specific features
-- - No parent-specific features
-- - All users have the same basic permissions
-- - Users can only manage their own data
-- - Registration will work without infinite recursion
