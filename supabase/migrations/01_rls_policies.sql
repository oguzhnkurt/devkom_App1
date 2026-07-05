-- =============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =============================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE homeworks ENABLE ROW LEVEL SECURITY;
ALTER TABLE homework_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE weekly_curriculums ENABLE ROW LEVEL SECURITY;
ALTER TABLE games ENABLE ROW LEVEL SECURITY;
ALTER TABLE game_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE leaderboards ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_quests ENABLE ROW LEVEL SECURITY;
ALTER TABLE parent_invites ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_portfolios ENABLE ROW LEVEL SECURITY;
ALTER TABLE play_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE surveys ENABLE ROW LEVEL SECURITY;
ALTER TABLE survey_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE support_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE camera_links ENABLE ROW LEVEL SECURITY;
ALTER TABLE millionaire_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE arduino_projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE chess_games ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_post_counts ENABLE ROW LEVEL SECURITY;

-- =============================================
-- HELPER FUNCTIONS
-- =============================================

-- Check if user is authenticated
CREATE OR REPLACE FUNCTION auth.is_authenticated()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN auth.uid() IS NOT NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if user is admin
CREATE OR REPLACE FUNCTION auth.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM users
        WHERE id = auth.uid() AND role = 'admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if user is teacher
CREATE OR REPLACE FUNCTION auth.is_teacher()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM users
        WHERE id = auth.uid() AND role = 'teacher'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if user is parent
CREATE OR REPLACE FUNCTION auth.is_parent()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM users
        WHERE id = auth.uid() AND role = 'parent'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if user is parent of student
CREATE OR REPLACE FUNCTION auth.is_parent_of(student_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM users
        WHERE id = student_id AND parent_id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- USERS TABLE POLICIES
-- =============================================

-- Users can read all profiles
CREATE POLICY "Users can view all profiles"
ON users FOR SELECT
TO authenticated
USING (true);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
ON users FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Users can insert their own profile (on signup)
CREATE POLICY "Users can insert own profile"
ON users FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);

-- Admins can do anything with users
CREATE POLICY "Admins can manage all users"
ON users FOR ALL
TO authenticated
USING (auth.is_admin())
WITH CHECK (auth.is_admin());

-- =============================================
-- POSTS TABLE POLICIES
-- =============================================

-- Everyone can view approved posts
CREATE POLICY "Anyone can view approved posts"
ON posts FOR SELECT
TO authenticated
USING (is_approved = true OR user_id = auth.uid() OR auth.is_admin());

-- Authenticated users can create posts
CREATE POLICY "Authenticated users can create posts"
ON posts FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Users can update their own posts
CREATE POLICY "Users can update own posts"
ON posts FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Users can delete their own posts, admins can delete any
CREATE POLICY "Users can delete own posts, admins can delete any"
ON posts FOR DELETE
TO authenticated
USING (auth.uid() = user_id OR auth.is_admin());

-- =============================================
-- POST LIKES POLICIES
-- =============================================

-- Users can view all likes
CREATE POLICY "Users can view all likes"
ON post_likes FOR SELECT
TO authenticated
USING (true);

-- Users can like posts
CREATE POLICY "Users can like posts"
ON post_likes FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Users can unlike their own likes
CREATE POLICY "Users can unlike posts"
ON post_likes FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- =============================================
-- POST COMMENTS POLICIES
-- =============================================

-- Users can view all comments
CREATE POLICY "Users can view all comments"
ON post_comments FOR SELECT
TO authenticated
USING (true);

-- Authenticated users can create comments
CREATE POLICY "Users can create comments"
ON post_comments FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Users can delete their own comments, admins can delete any
CREATE POLICY "Users can delete own comments, admins can delete any"
ON post_comments FOR DELETE
TO authenticated
USING (auth.uid() = user_id OR auth.is_admin());

-- =============================================
-- POST REPORTS POLICIES
-- =============================================

-- Users can report posts
CREATE POLICY "Users can report posts"
ON post_reports FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = reporter_user_id);

-- Admins can view reports
CREATE POLICY "Admins can view reports"
ON post_reports FOR SELECT
TO authenticated
USING (auth.is_admin());

-- =============================================
-- MESSAGES POLICIES
-- =============================================

-- Users can view messages where they are sender or receiver
CREATE POLICY "Users can view their messages"
ON messages FOR SELECT
TO authenticated
USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

-- Users can send messages
CREATE POLICY "Users can send messages"
ON messages FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = sender_id);

-- Users can update messages they received (mark as read)
CREATE POLICY "Users can mark received messages as read"
ON messages FOR UPDATE
TO authenticated
USING (auth.uid() = receiver_id)
WITH CHECK (auth.uid() = receiver_id);

-- Users can delete their own sent messages
CREATE POLICY "Users can delete own sent messages"
ON messages FOR DELETE
TO authenticated
USING (auth.uid() = sender_id);

-- =============================================
-- HOMEWORK POLICIES
-- =============================================

-- Everyone can view homeworks
CREATE POLICY "Users can view homeworks"
ON homeworks FOR SELECT
TO authenticated
USING (true);

-- Teachers can create homeworks
CREATE POLICY "Teachers can create homeworks"
ON homeworks FOR INSERT
TO authenticated
WITH CHECK (auth.is_teacher() AND auth.uid() = teacher_id);

-- Teachers can update their own homeworks
CREATE POLICY "Teachers can update own homeworks"
ON homeworks FOR UPDATE
TO authenticated
USING (auth.uid() = teacher_id)
WITH CHECK (auth.uid() = teacher_id);

-- Teachers can delete their own homeworks
CREATE POLICY "Teachers can delete own homeworks"
ON homeworks FOR DELETE
TO authenticated
USING (auth.uid() = teacher_id);

-- =============================================
-- HOMEWORK SUBMISSIONS POLICIES
-- =============================================

-- Users can view their own submissions, teachers can view all
CREATE POLICY "Users can view relevant submissions"
ON homework_submissions FOR SELECT
TO authenticated
USING (
    auth.uid() = user_id OR
    auth.is_teacher() OR
    auth.is_admin() OR
    auth.is_parent_of(user_id)
);

-- Students can create submissions
CREATE POLICY "Students can submit homework"
ON homework_submissions FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Students can update their own pending submissions
CREATE POLICY "Students can update own submissions"
ON homework_submissions FOR UPDATE
TO authenticated
USING (auth.uid() = user_id AND status = 'pending')
WITH CHECK (auth.uid() = user_id);

-- Teachers can update submissions for grading
CREATE POLICY "Teachers can grade submissions"
ON homework_submissions FOR UPDATE
TO authenticated
USING (auth.is_teacher())
WITH CHECK (auth.is_teacher());

-- =============================================
-- WEEKLY CURRICULUM POLICIES
-- =============================================

-- Everyone can view active curriculums
CREATE POLICY "Users can view curriculums"
ON weekly_curriculums FOR SELECT
TO authenticated
USING (is_active = true OR auth.is_teacher() OR auth.is_admin());

-- Teachers can create curriculums
CREATE POLICY "Teachers can create curriculums"
ON weekly_curriculums FOR INSERT
TO authenticated
WITH CHECK (auth.is_teacher() AND auth.uid() = teacher_id);

-- Teachers can update their own curriculums
CREATE POLICY "Teachers can update own curriculums"
ON weekly_curriculums FOR UPDATE
TO authenticated
USING (auth.uid() = teacher_id)
WITH CHECK (auth.uid() = teacher_id);

-- =============================================
-- GAMES POLICIES
-- =============================================

-- Everyone can view active games
CREATE POLICY "Users can view active games"
ON games FOR SELECT
TO authenticated
USING (is_active = true OR auth.is_admin());

-- Admins can manage games
CREATE POLICY "Admins can manage games"
ON games FOR ALL
TO authenticated
USING (auth.is_admin())
WITH CHECK (auth.is_admin());

-- =============================================
-- GAME RESULTS POLICIES
-- =============================================

-- Users can view their own results and leaderboard
CREATE POLICY "Users can view game results"
ON game_results FOR SELECT
TO authenticated
USING (true);

-- Users can insert their own results
CREATE POLICY "Users can submit game results"
ON game_results FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- =============================================
-- LEADERBOARDS POLICIES
-- =============================================

-- Everyone can view leaderboards
CREATE POLICY "Users can view leaderboards"
ON leaderboards FOR SELECT
TO authenticated
USING (true);

-- System can update leaderboards (via trigger)
CREATE POLICY "System can update leaderboards"
ON leaderboards FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- =============================================
-- ACHIEVEMENTS POLICIES
-- =============================================

-- Users can view their own achievements
CREATE POLICY "Users can view own achievements"
ON achievements FOR SELECT
TO authenticated
USING (auth.uid() = user_id OR auth.is_parent_of(user_id));

-- System can manage achievements
CREATE POLICY "System can manage achievements"
ON achievements FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- =============================================
-- DAILY QUESTS POLICIES
-- =============================================

-- Users can view their own quests
CREATE POLICY "Users can view own quests"
ON daily_quests FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Users can manage their own quests
CREATE POLICY "Users can manage own quests"
ON daily_quests FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- =============================================
-- PARENT FEATURES POLICIES
-- =============================================

-- Users can view invites related to them
CREATE POLICY "Users can view relevant invites"
ON parent_invites FOR SELECT
TO authenticated
USING (auth.uid() = parent_id OR auth.uid() = student_id);

-- Parents can create invites
CREATE POLICY "Parents can create invites"
ON parent_invites FOR INSERT
TO authenticated
WITH CHECK (auth.is_parent() AND auth.uid() = parent_id);

-- Students can update invites sent to them
CREATE POLICY "Students can respond to invites"
ON parent_invites FOR UPDATE
TO authenticated
USING (auth.uid() = student_id)
WITH CHECK (auth.uid() = student_id);

-- Student portfolios
CREATE POLICY "Users can view portfolios"
ON student_portfolios FOR SELECT
TO authenticated
USING (
    auth.uid() = student_id OR
    auth.is_teacher() OR
    auth.is_admin() OR
    auth.is_parent_of(student_id)
);

CREATE POLICY "Teachers can create portfolios"
ON student_portfolios FOR INSERT
TO authenticated
WITH CHECK (auth.is_teacher());

CREATE POLICY "Teachers can manage portfolios"
ON student_portfolios FOR UPDATE
TO authenticated
USING (auth.is_teacher())
WITH CHECK (auth.is_teacher());

-- Play sessions
CREATE POLICY "Users can view own sessions, parents can view children"
ON play_sessions FOR SELECT
TO authenticated
USING (auth.uid() = user_id OR auth.is_parent_of(user_id) OR auth.is_admin());

CREATE POLICY "Users can create own sessions"
ON play_sessions FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- =============================================
-- NOTIFICATIONS POLICIES
-- =============================================

-- Users can view their own notifications
CREATE POLICY "Users can view own notifications"
ON notifications FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- System can create notifications
CREATE POLICY "System can create notifications"
ON notifications FOR INSERT
TO authenticated
WITH CHECK (true);

-- Users can update their own notifications (mark as read)
CREATE POLICY "Users can mark own notifications as read"
ON notifications FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Users can delete their own notifications
CREATE POLICY "Users can delete own notifications"
ON notifications FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- =============================================
-- SURVEYS POLICIES
-- =============================================

-- Users can view active surveys
CREATE POLICY "Users can view active surveys"
ON surveys FOR SELECT
TO authenticated
USING (is_active = true OR auth.is_admin());

-- Admins can manage surveys
CREATE POLICY "Admins can manage surveys"
ON surveys FOR ALL
TO authenticated
USING (auth.is_admin())
WITH CHECK (auth.is_admin());

-- Survey responses
CREATE POLICY "Users can view own responses"
ON survey_responses FOR SELECT
TO authenticated
USING (auth.uid() = user_id OR auth.is_admin());

CREATE POLICY "Users can submit responses"
ON survey_responses FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- =============================================
-- SUPPORT MESSAGES POLICIES
-- =============================================

-- Users can view their own support messages
CREATE POLICY "Users can view own support messages"
ON support_messages FOR SELECT
TO authenticated
USING (auth.uid() = user_id OR auth.is_admin());

-- Users can create support messages
CREATE POLICY "Users can create support messages"
ON support_messages FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Admins can update support messages
CREATE POLICY "Admins can manage support messages"
ON support_messages FOR UPDATE
TO authenticated
USING (auth.is_admin())
WITH CHECK (auth.is_admin());

-- =============================================
-- CAMERA LINKS POLICIES
-- =============================================

-- Users with camera access can view links
CREATE POLICY "Users with camera access can view links"
ON camera_links FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM users
        WHERE id = auth.uid() AND live_camera_enabled = true
    ) OR auth.is_admin()
);

-- Admins can manage camera links
CREATE POLICY "Admins can manage camera links"
ON camera_links FOR ALL
TO authenticated
USING (auth.is_admin())
WITH CHECK (auth.is_admin());

-- =============================================
-- MILLIONAIRE QUESTIONS POLICIES
-- =============================================

-- Everyone can view questions
CREATE POLICY "Users can view questions"
ON millionaire_questions FOR SELECT
TO authenticated
USING (true);

-- Admins can manage questions
CREATE POLICY "Admins can manage questions"
ON millionaire_questions FOR ALL
TO authenticated
USING (auth.is_admin())
WITH CHECK (auth.is_admin());

-- =============================================
-- ARDUINO PROJECTS POLICIES
-- =============================================

-- Users can view public projects and their own
CREATE POLICY "Users can view projects"
ON arduino_projects FOR SELECT
TO authenticated
USING (is_public = true OR auth.uid() = user_id);

-- Users can create projects
CREATE POLICY "Users can create projects"
ON arduino_projects FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Users can update their own projects
CREATE POLICY "Users can update own projects"
ON arduino_projects FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Users can delete their own projects
CREATE POLICY "Users can delete own projects"
ON arduino_projects FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- =============================================
-- CHESS GAMES POLICIES
-- =============================================

-- Users can view their own games
CREATE POLICY "Users can view own chess games"
ON chess_games FOR SELECT
TO authenticated
USING (auth.uid() = player1_id OR auth.uid() = player2_id);

-- Users can create games
CREATE POLICY "Users can create chess games"
ON chess_games FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = player1_id);

-- Players can update their games
CREATE POLICY "Players can update games"
ON chess_games FOR UPDATE
TO authenticated
USING (auth.uid() = player1_id OR auth.uid() = player2_id)
WITH CHECK (auth.uid() = player1_id OR auth.uid() = player2_id);

-- =============================================
-- USER POST COUNTS POLICIES
-- =============================================

-- Users can view their own counts
CREATE POLICY "Users can view own post counts"
ON user_post_counts FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- System can manage counts
CREATE POLICY "System can manage post counts"
ON user_post_counts FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);
