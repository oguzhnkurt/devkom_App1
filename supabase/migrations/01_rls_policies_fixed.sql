-- =============================================
-- ROW LEVEL SECURITY (RLS) POLICIES - FIXED
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
-- USERS TABLE POLICIES
-- =============================================

-- Users can read all profiles
CREATE POLICY "Users can view all profiles"
ON users FOR SELECT
USING (true);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
ON users FOR UPDATE
USING (auth.uid() = id);

-- Users can insert their own profile (on signup)
CREATE POLICY "Users can insert own profile"
ON users FOR INSERT
WITH CHECK (auth.uid() = id);

-- Admins can do anything with users
CREATE POLICY "Admins can manage all users"
ON users FOR ALL
USING (EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'));

-- =============================================
-- POSTS TABLE POLICIES
-- =============================================

-- Everyone can view approved posts
CREATE POLICY "Anyone can view approved posts"
ON posts FOR SELECT
USING (
    is_approved = true OR
    user_id = auth.uid() OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);

-- Authenticated users can create posts
CREATE POLICY "Authenticated users can create posts"
ON posts FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Users can update their own posts
CREATE POLICY "Users can update own posts"
ON posts FOR UPDATE
USING (auth.uid() = user_id);

-- Users can delete their own posts, admins can delete any
CREATE POLICY "Users can delete own posts"
ON posts FOR DELETE
USING (
    auth.uid() = user_id OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);

-- =============================================
-- POST LIKES POLICIES
-- =============================================

CREATE POLICY "Users can view all likes"
ON post_likes FOR SELECT
USING (true);

CREATE POLICY "Users can like posts"
ON post_likes FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can unlike posts"
ON post_likes FOR DELETE
USING (auth.uid() = user_id);

-- =============================================
-- POST COMMENTS POLICIES
-- =============================================

CREATE POLICY "Users can view all comments"
ON post_comments FOR SELECT
USING (true);

CREATE POLICY "Users can create comments"
ON post_comments FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own comments"
ON post_comments FOR DELETE
USING (
    auth.uid() = user_id OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);

-- =============================================
-- MESSAGES POLICIES
-- =============================================

CREATE POLICY "Users can view their messages"
ON messages FOR SELECT
USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

CREATE POLICY "Users can send messages"
ON messages FOR INSERT
WITH CHECK (auth.uid() = sender_id);

CREATE POLICY "Users can mark received messages as read"
ON messages FOR UPDATE
USING (auth.uid() = receiver_id);

CREATE POLICY "Users can delete own sent messages"
ON messages FOR DELETE
USING (auth.uid() = sender_id);

-- =============================================
-- HOMEWORK POLICIES
-- =============================================

CREATE POLICY "Users can view homeworks"
ON homeworks FOR SELECT
USING (true);

CREATE POLICY "Teachers can create homeworks"
ON homeworks FOR INSERT
WITH CHECK (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'teacher') AND
    auth.uid() = teacher_id
);

CREATE POLICY "Teachers can update own homeworks"
ON homeworks FOR UPDATE
USING (auth.uid() = teacher_id);

CREATE POLICY "Teachers can delete own homeworks"
ON homeworks FOR DELETE
USING (auth.uid() = teacher_id);

-- =============================================
-- HOMEWORK SUBMISSIONS POLICIES
-- =============================================

CREATE POLICY "Users can view relevant submissions"
ON homework_submissions FOR SELECT
USING (
    auth.uid() = user_id OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('teacher', 'admin')) OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'parent' AND user_id = ANY(student_ids))
);

CREATE POLICY "Students can submit homework"
ON homework_submissions FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Students can update own submissions"
ON homework_submissions FOR UPDATE
USING (auth.uid() = user_id AND status = 'pending');

CREATE POLICY "Teachers can grade submissions"
ON homework_submissions FOR UPDATE
USING (EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'teacher'));

-- =============================================
-- GAMES & LEADERBOARDS POLICIES
-- =============================================

CREATE POLICY "Users can view active games"
ON games FOR SELECT
USING (
    is_active = true OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);

CREATE POLICY "Admins can manage games"
ON games FOR ALL
USING (EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Users can view game results"
ON game_results FOR SELECT
USING (true);

CREATE POLICY "Users can submit game results"
ON game_results FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view leaderboards"
ON leaderboards FOR SELECT
USING (true);

CREATE POLICY "System can update leaderboards"
ON leaderboards FOR ALL
USING (true);

-- =============================================
-- ACHIEVEMENTS & QUESTS POLICIES
-- =============================================

CREATE POLICY "Users can view own achievements"
ON achievements FOR SELECT
USING (
    auth.uid() = user_id OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'parent' AND user_id = ANY(student_ids))
);

CREATE POLICY "System can manage achievements"
ON achievements FOR ALL
USING (auth.uid() = user_id);

CREATE POLICY "Users can view own quests"
ON daily_quests FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own quests"
ON daily_quests FOR ALL
USING (auth.uid() = user_id);

-- =============================================
-- NOTIFICATIONS POLICIES
-- =============================================

CREATE POLICY "Users can view own notifications"
ON notifications FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "System can create notifications"
ON notifications FOR INSERT
WITH CHECK (true);

CREATE POLICY "Users can mark own notifications as read"
ON notifications FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own notifications"
ON notifications FOR DELETE
USING (auth.uid() = user_id);

-- =============================================
-- PARENT FEATURES POLICIES
-- =============================================

CREATE POLICY "Users can view relevant invites"
ON parent_invites FOR SELECT
USING (auth.uid() = parent_id OR auth.uid() = student_id);

CREATE POLICY "Parents can create invites"
ON parent_invites FOR INSERT
WITH CHECK (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'parent') AND
    auth.uid() = parent_id
);

CREATE POLICY "Students can respond to invites"
ON parent_invites FOR UPDATE
USING (auth.uid() = student_id);

CREATE POLICY "Users can view portfolios"
ON student_portfolios FOR SELECT
USING (
    auth.uid() = student_id OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('teacher', 'admin')) OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'parent' AND student_id = ANY(student_ids))
);

CREATE POLICY "Teachers can create portfolios"
ON student_portfolios FOR INSERT
WITH CHECK (EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'teacher'));

CREATE POLICY "Teachers can manage portfolios"
ON student_portfolios FOR UPDATE
USING (EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'teacher'));

CREATE POLICY "Users can view own sessions"
ON play_sessions FOR SELECT
USING (
    auth.uid() = user_id OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'parent' AND user_id = ANY(student_ids)) OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);

CREATE POLICY "Users can create own sessions"
ON play_sessions FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- =============================================
-- SURVEYS POLICIES
-- =============================================

CREATE POLICY "Users can view active surveys"
ON surveys FOR SELECT
USING (
    is_active = true OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);

CREATE POLICY "Admins can manage surveys"
ON surveys FOR ALL
USING (EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Users can view own responses"
ON survey_responses FOR SELECT
USING (
    auth.uid() = user_id OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);

CREATE POLICY "Users can submit responses"
ON survey_responses FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- =============================================
-- SUPPORT MESSAGES POLICIES
-- =============================================

CREATE POLICY "Users can view own support messages"
ON support_messages FOR SELECT
USING (
    auth.uid() = user_id OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);

CREATE POLICY "Users can create support messages"
ON support_messages FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can manage support messages"
ON support_messages FOR UPDATE
USING (EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'));

-- =============================================
-- CAMERA LINKS POLICIES
-- =============================================

CREATE POLICY "Users with camera access can view links"
ON camera_links FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM users
        WHERE id = auth.uid() AND (live_camera_enabled = true OR role = 'admin')
    )
);

CREATE POLICY "Admins can manage camera links"
ON camera_links FOR ALL
USING (EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'));

-- =============================================
-- MILLIONAIRE QUESTIONS POLICIES
-- =============================================

CREATE POLICY "Users can view questions"
ON millionaire_questions FOR SELECT
USING (true);

CREATE POLICY "Admins can manage questions"
ON millionaire_questions FOR ALL
USING (EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'));

-- =============================================
-- ARDUINO PROJECTS POLICIES
-- =============================================

CREATE POLICY "Users can view projects"
ON arduino_projects FOR SELECT
USING (is_public = true OR auth.uid() = user_id);

CREATE POLICY "Users can create projects"
ON arduino_projects FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own projects"
ON arduino_projects FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own projects"
ON arduino_projects FOR DELETE
USING (auth.uid() = user_id);

-- =============================================
-- CHESS GAMES POLICIES
-- =============================================

CREATE POLICY "Users can view own chess games"
ON chess_games FOR SELECT
USING (auth.uid() = player1_id OR auth.uid() = player2_id);

CREATE POLICY "Users can create chess games"
ON chess_games FOR INSERT
WITH CHECK (auth.uid() = player1_id);

CREATE POLICY "Players can update games"
ON chess_games FOR UPDATE
USING (auth.uid() = player1_id OR auth.uid() = player2_id);

-- =============================================
-- USER POST COUNTS POLICIES
-- =============================================

CREATE POLICY "Users can view own post counts"
ON user_post_counts FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "System can manage post counts"
ON user_post_counts FOR ALL
USING (auth.uid() = user_id);

-- =============================================
-- WEEKLY CURRICULUM POLICIES
-- =============================================

CREATE POLICY "Users can view curriculums"
ON weekly_curriculums FOR SELECT
USING (
    is_active = true OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('teacher', 'admin'))
);

CREATE POLICY "Teachers can create curriculums"
ON weekly_curriculums FOR INSERT
WITH CHECK (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'teacher') AND
    auth.uid() = teacher_id
);

CREATE POLICY "Teachers can update own curriculums"
ON weekly_curriculums FOR UPDATE
USING (auth.uid() = teacher_id);

-- =============================================
-- POST REPORTS POLICIES
-- =============================================

CREATE POLICY "Users can report posts"
ON post_reports FOR INSERT
WITH CHECK (auth.uid() = reporter_user_id);

CREATE POLICY "Admins can view reports"
ON post_reports FOR SELECT
USING (EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'));
