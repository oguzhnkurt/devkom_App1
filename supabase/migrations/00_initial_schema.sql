-- =============================================
-- DEVKOM APP - SUPABASE MIGRATION
-- Initial Database Schema
-- =============================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================
-- ENUMS
-- =============================================

CREATE TYPE user_role AS ENUM ('student', 'parent', 'teacher', 'visitor', 'admin');
CREATE TYPE age_group AS ENUM ('age_6_9', 'age_10_14', 'age_15_18');
CREATE TYPE homework_status AS ENUM ('pending', 'submitted', 'graded', 'late');
CREATE TYPE grade_result AS ENUM ('success', 'failed', 'needs_improvement');
CREATE TYPE message_type AS ENUM ('text', 'image', 'file', 'voice');
CREATE TYPE notification_type AS ENUM ('homework', 'game', 'announcement', 'camera_alert');
CREATE TYPE leaderboard_type AS ENUM ('high_score', 'fastest_time', 'win_rate');
CREATE TYPE post_media_type AS ENUM ('image', 'pdf', 'video');

-- =============================================
-- CORE TABLES
-- =============================================

-- Users table (extends Supabase auth.users)
CREATE TABLE users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    display_name TEXT,
    photo_url TEXT,
    role user_role NOT NULL DEFAULT 'student',
    age_group age_group,

    -- Premium subscription
    is_pro BOOLEAN DEFAULT FALSE,
    pro_expiry_date TIMESTAMPTZ,
    trial_start_date TIMESTAMPTZ,
    trial_end_date TIMESTAMPTZ,
    has_used_trial BOOLEAN DEFAULT FALSE,

    -- Parent-Child relationship
    parent_id UUID REFERENCES users(id) ON DELETE SET NULL,
    student_ids UUID[] DEFAULT '{}',

    -- Daily limits
    daily_post_limit INTEGER DEFAULT 5,
    daily_ai_message_limit INTEGER DEFAULT 20,
    daily_question_limit INTEGER DEFAULT 50,

    -- Settings
    live_camera_enabled BOOLEAN DEFAULT FALSE,
    class_info TEXT,
    school_name TEXT,
    bio TEXT,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_login_at TIMESTAMPTZ
);

-- Create indexes for users
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_parent_id ON users(parent_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_is_pro ON users(is_pro);

-- =============================================
-- SOCIAL FEATURES
-- =============================================

-- Posts table (social feed)
CREATE TABLE posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,

    -- Media
    media_urls TEXT[] DEFAULT '{}',
    media_types post_media_type[] DEFAULT '{}',

    -- Link preview
    link_url TEXT,
    link_title TEXT,
    link_description TEXT,
    link_image_url TEXT,

    -- Engagement
    tags TEXT[] DEFAULT '{}',
    likes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,

    -- Moderation
    is_approved BOOLEAN DEFAULT FALSE,
    is_reported BOOLEAN DEFAULT FALSE,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX idx_posts_is_approved ON posts(is_approved);
CREATE INDEX idx_posts_tags ON posts USING GIN(tags);

-- Post likes (many-to-many)
CREATE TABLE post_likes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(post_id, user_id)
);

CREATE INDEX idx_post_likes_post_id ON post_likes(post_id);
CREATE INDEX idx_post_likes_user_id ON post_likes(user_id);

-- Post comments
CREATE TABLE post_comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    user_name TEXT NOT NULL,
    user_role user_role NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_post_comments_post_id ON post_comments(post_id);
CREATE INDEX idx_post_comments_user_id ON post_comments(user_id);
CREATE INDEX idx_post_comments_created_at ON post_comments(created_at);

-- Post reports (content moderation)
CREATE TABLE post_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    reporter_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- MESSAGING
-- =============================================

-- Messages table
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    sender_name TEXT NOT NULL,
    sender_role user_role NOT NULL,
    receiver_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    receiver_name TEXT NOT NULL,

    -- Content
    content TEXT NOT NULL,
    message_type message_type DEFAULT 'text',

    -- File metadata (for image/file/voice messages)
    file_name TEXT,
    file_url TEXT,
    thumbnail_url TEXT,
    file_size BIGINT,
    duration INTEGER, -- for voice messages (seconds)

    -- Status
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMPTZ,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_messages_sender_receiver ON messages(sender_id, receiver_id, created_at);
CREATE INDEX idx_messages_receiver_sender ON messages(receiver_id, sender_id, created_at);
CREATE INDEX idx_messages_is_read ON messages(receiver_id, is_read) WHERE NOT is_read;

-- =============================================
-- EDUCATION - HOMEWORK
-- =============================================

-- Homeworks table
CREATE TABLE homeworks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    teacher_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    teacher_name TEXT NOT NULL,

    -- Content
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    age_group age_group,

    -- Assignment
    assigned_student_ids UUID[] DEFAULT '{}',

    -- Deadlines
    due_date TIMESTAMPTZ,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_homeworks_teacher_id ON homeworks(teacher_id);
CREATE INDEX idx_homeworks_created_at ON homeworks(created_at DESC);
CREATE INDEX idx_homeworks_due_date ON homeworks(due_date);
CREATE INDEX idx_homeworks_age_group ON homeworks(age_group);

-- Homework submissions
CREATE TABLE homework_submissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    homework_id UUID NOT NULL REFERENCES homeworks(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    user_name TEXT NOT NULL,

    -- Content
    content TEXT,
    file_urls TEXT[] DEFAULT '{}',

    -- Status
    status homework_status DEFAULT 'pending',

    -- Grading
    grade_result grade_result,
    feedback TEXT,
    score INTEGER,
    graded_by UUID REFERENCES users(id),
    graded_at TIMESTAMPTZ,

    -- Timestamps
    submitted_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(homework_id, user_id)
);

CREATE INDEX idx_homework_submissions_homework_id ON homework_submissions(homework_id);
CREATE INDEX idx_homework_submissions_user_id ON homework_submissions(user_id);
CREATE INDEX idx_homework_submissions_status ON homework_submissions(status);

-- =============================================
-- EDUCATION - CURRICULUM
-- =============================================

-- Weekly curriculum
CREATE TABLE weekly_curriculums (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    teacher_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Content
    title TEXT NOT NULL,
    description TEXT,
    week_number INTEGER,
    year INTEGER,

    -- Planning
    monday_plan TEXT,
    tuesday_plan TEXT,
    wednesday_plan TEXT,
    thursday_plan TEXT,
    friday_plan TEXT,

    -- Status
    is_active BOOLEAN DEFAULT TRUE,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_weekly_curriculums_teacher_id ON weekly_curriculums(teacher_id);
CREATE INDEX idx_weekly_curriculums_is_active ON weekly_curriculums(is_active);
CREATE INDEX idx_weekly_curriculums_week_year ON weekly_curriculums(week_number, year);

-- =============================================
-- GAMIFICATION
-- =============================================

-- Games table
CREATE TABLE games (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    url TEXT NOT NULL,
    description TEXT,
    thumbnail_url TEXT,
    age_group age_group,
    leaderboard_type leaderboard_type,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_games_category ON games(category);
CREATE INDEX idx_games_age_group ON games(age_group);
CREATE INDEX idx_games_is_active ON games(is_active);

-- Game results
CREATE TABLE game_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    user_name TEXT NOT NULL,
    game_id UUID REFERENCES games(id) ON DELETE SET NULL,
    game_name TEXT NOT NULL,

    -- Results
    score INTEGER NOT NULL,
    duration INTEGER, -- seconds
    level_reached INTEGER,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_game_results_user_id ON game_results(user_id);
CREATE INDEX idx_game_results_game_id ON game_results(game_id);
CREATE INDEX idx_game_results_score ON game_results(score DESC);
CREATE INDEX idx_game_results_created_at ON game_results(created_at DESC);

-- Leaderboards (materialized view for performance)
CREATE TABLE leaderboards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    user_name TEXT NOT NULL,
    game_id UUID REFERENCES games(id) ON DELETE CASCADE,
    game_name TEXT NOT NULL,

    -- Stats
    total_score INTEGER DEFAULT 0,
    best_score INTEGER DEFAULT 0,
    games_played INTEGER DEFAULT 0,
    average_score NUMERIC DEFAULT 0,
    rank INTEGER,

    -- Timestamps
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(user_id, game_id)
);

CREATE INDEX idx_leaderboards_game_id_score ON leaderboards(game_id, total_score DESC);
CREATE INDEX idx_leaderboards_rank ON leaderboards(rank);

-- Achievements
CREATE TABLE achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Achievement data
    badge_id TEXT NOT NULL,
    badge_name TEXT NOT NULL,
    badge_description TEXT,
    badge_icon_url TEXT,

    -- Progress
    current_progress INTEGER DEFAULT 0,
    required_progress INTEGER NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,

    -- Timestamps
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(user_id, badge_id)
);

CREATE INDEX idx_achievements_user_id ON achievements(user_id);
CREATE INDEX idx_achievements_is_completed ON achievements(is_completed);

-- Daily quests
CREATE TABLE daily_quests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Quest data
    quest_id TEXT NOT NULL,
    quest_title TEXT NOT NULL,
    quest_description TEXT,

    -- Progress
    progress INTEGER DEFAULT 0,
    target INTEGER NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,

    -- Rewards
    reward_points INTEGER DEFAULT 0,

    -- Date tracking
    quest_date DATE NOT NULL,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(user_id, quest_id, quest_date)
);

CREATE INDEX idx_daily_quests_user_date ON daily_quests(user_id, quest_date);
CREATE INDEX idx_daily_quests_is_completed ON daily_quests(is_completed);

-- =============================================
-- PARENT FEATURES
-- =============================================

-- Parent invites
CREATE TABLE parent_invites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    parent_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'pending', -- pending, accepted, rejected
    created_at TIMESTAMPTZ DEFAULT NOW(),
    responded_at TIMESTAMPTZ
);

-- Student portfolios
CREATE TABLE student_portfolios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Content
    title TEXT NOT NULL,
    description TEXT,
    image_urls TEXT[] DEFAULT '{}',

    -- Metadata
    created_by UUID REFERENCES users(id),
    tags TEXT[] DEFAULT '{}',

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_student_portfolios_student_id ON student_portfolios(student_id);

-- Play sessions (screen time tracking)
CREATE TABLE play_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Session data
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ,
    duration INTEGER, -- seconds

    -- Context
    activity_type TEXT, -- game, homework, chat, etc.
    activity_id TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_play_sessions_user_id ON play_sessions(user_id);
CREATE INDEX idx_play_sessions_start_time ON play_sessions(start_time);

-- =============================================
-- NOTIFICATIONS
-- =============================================

-- Notifications table
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Content
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    notification_type notification_type NOT NULL,

    -- Navigation
    screen TEXT,
    data JSONB DEFAULT '{}',

    -- Status
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMPTZ,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(user_id, is_read) WHERE NOT is_read;
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);

-- =============================================
-- SPECIALIZED FEATURES
-- =============================================

-- Surveys
CREATE TABLE surveys (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT,

    -- Questions (stored as JSONB array)
    questions JSONB NOT NULL,

    -- Targeting
    target_roles user_role[] DEFAULT '{}',

    -- Status
    is_active BOOLEAN DEFAULT TRUE,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ
);

-- Survey responses
CREATE TABLE survey_responses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    survey_id UUID NOT NULL REFERENCES surveys(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Responses (stored as JSONB)
    answers JSONB NOT NULL,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(survey_id, user_id)
);

-- Support messages
CREATE TABLE support_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    user_name TEXT NOT NULL,

    -- Content
    subject TEXT NOT NULL,
    message TEXT NOT NULL,

    -- Status
    status TEXT DEFAULT 'open', -- open, in_progress, resolved, closed
    priority TEXT DEFAULT 'normal', -- low, normal, high, urgent

    -- Response
    admin_response TEXT,
    responded_by UUID REFERENCES users(id),
    responded_at TIMESTAMPTZ,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_support_messages_user_id ON support_messages(user_id);
CREATE INDEX idx_support_messages_status ON support_messages(status);
CREATE INDEX idx_support_messages_created_at ON support_messages(created_at DESC);

-- Camera links
CREATE TABLE camera_links (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    url TEXT NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Millionaire questions
CREATE TABLE millionaire_questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    question TEXT NOT NULL,
    options TEXT[] NOT NULL, -- 4 options
    correct_answer INTEGER NOT NULL, -- 0-3
    difficulty INTEGER DEFAULT 1, -- 1-15
    category TEXT,
    age_group age_group,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_millionaire_questions_difficulty ON millionaire_questions(difficulty);
CREATE INDEX idx_millionaire_questions_age_group ON millionaire_questions(age_group);

-- Arduino projects
CREATE TABLE arduino_projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Project data
    name TEXT NOT NULL,
    description TEXT,

    -- Code/blocks (stored as JSONB)
    blocks JSONB,
    arduino_code TEXT,

    -- Metadata
    is_public BOOLEAN DEFAULT FALSE,
    thumbnail_url TEXT,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_arduino_projects_user_id ON arduino_projects(user_id);
CREATE INDEX idx_arduino_projects_is_public ON arduino_projects(is_public);

-- Chess games
CREATE TABLE chess_games (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player1_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    player2_id UUID,

    -- Game state
    pgn TEXT, -- Portable Game Notation
    fen TEXT, -- Forsyth-Edwards Notation (current position)
    moves JSONB DEFAULT '[]',

    -- Status
    status TEXT DEFAULT 'active', -- active, completed, abandoned
    winner_id UUID REFERENCES users(id),

    -- Timestamps
    started_at TIMESTAMPTZ DEFAULT NOW(),
    ended_at TIMESTAMPTZ
);

CREATE INDEX idx_chess_games_player1_id ON chess_games(player1_id);
CREATE INDEX idx_chess_games_player2_id ON chess_games(player2_id);
CREATE INDEX idx_chess_games_status ON chess_games(status);

-- =============================================
-- USAGE TRACKING
-- =============================================

-- User post counts (daily limit tracking)
CREATE TABLE user_post_counts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_date DATE NOT NULL,
    count INTEGER DEFAULT 0,
    UNIQUE(user_id, post_date)
);

CREATE INDEX idx_user_post_counts_user_date ON user_post_counts(user_id, post_date);

-- =============================================
-- FUNCTIONS & TRIGGERS
-- =============================================

-- Updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger to relevant tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_posts_updated_at BEFORE UPDATE ON posts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_homeworks_updated_at BEFORE UPDATE ON homeworks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_homework_submissions_updated_at BEFORE UPDATE ON homework_submissions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_weekly_curriculums_updated_at BEFORE UPDATE ON weekly_curriculums
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_student_portfolios_updated_at BEFORE UPDATE ON student_portfolios
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_support_messages_updated_at BEFORE UPDATE ON support_messages
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_arduino_projects_updated_at BEFORE UPDATE ON arduino_projects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Increment post likes count
CREATE OR REPLACE FUNCTION increment_post_likes()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE posts SET likes_count = likes_count + 1 WHERE id = NEW.post_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER post_liked AFTER INSERT ON post_likes
    FOR EACH ROW EXECUTE FUNCTION increment_post_likes();

-- Decrement post likes count
CREATE OR REPLACE FUNCTION decrement_post_likes()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE posts SET likes_count = likes_count - 1 WHERE id = OLD.post_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER post_unliked AFTER DELETE ON post_likes
    FOR EACH ROW EXECUTE FUNCTION decrement_post_likes();

-- Increment post comments count
CREATE OR REPLACE FUNCTION increment_post_comments()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE posts SET comments_count = comments_count + 1 WHERE id = NEW.post_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER post_commented AFTER INSERT ON post_comments
    FOR EACH ROW EXECUTE FUNCTION increment_post_comments();

-- Decrement post comments count
CREATE OR REPLACE FUNCTION decrement_post_comments()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE posts SET comments_count = comments_count - 1 WHERE id = OLD.post_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER post_comment_deleted AFTER DELETE ON post_comments
    FOR EACH ROW EXECUTE FUNCTION decrement_post_comments();

-- Update leaderboard on new game result
CREATE OR REPLACE FUNCTION update_leaderboard()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO leaderboards (user_id, user_name, game_id, game_name, total_score, best_score, games_played, average_score)
    VALUES (NEW.user_id, NEW.user_name, NEW.game_id, NEW.game_name, NEW.score, NEW.score, 1, NEW.score)
    ON CONFLICT (user_id, game_id) DO UPDATE SET
        total_score = leaderboards.total_score + NEW.score,
        best_score = GREATEST(leaderboards.best_score, NEW.score),
        games_played = leaderboards.games_played + 1,
        average_score = (leaderboards.total_score + NEW.score) / (leaderboards.games_played + 1),
        updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_leaderboard_on_game_result AFTER INSERT ON game_results
    FOR EACH ROW EXECUTE FUNCTION update_leaderboard();

-- =============================================
-- INITIAL DATA SEEDING
-- =============================================

-- You can add seed data here if needed
-- Example: Default games, admin users, etc.

COMMENT ON TABLE users IS 'Core user profiles extending Supabase auth';
COMMENT ON TABLE posts IS 'Social feed posts with media support';
COMMENT ON TABLE messages IS 'Direct messaging between users';
COMMENT ON TABLE homeworks IS 'Teacher-created homework assignments';
COMMENT ON TABLE game_results IS 'Individual game completion records';
COMMENT ON TABLE leaderboards IS 'Aggregated game leaderboard rankings';
