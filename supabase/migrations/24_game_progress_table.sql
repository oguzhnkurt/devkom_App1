-- =============================================
-- GAME_PROGRESS TABLOSU
--
-- Kritik bulgu: Dart tarafında (GamesServiceSupabase, GameProgress modeli,
-- AchievementService) 'game_progress' tablosu zaten kullanılıyordu ama bu
-- tablo prod veritabanında hiç oluşturulmamıştı (user_progress'in başına
-- gelen sorunun aynısı, bkz. 23_store_and_jeton_economy.sql). Bu yüzden:
--   - Oyun sonunda ilerleme kaydetme işlemleri sessizce başarısız oluyordu
--   - "Kazanım Analizleri" ekranı hiçbir zaman gerçek veri bulamıyordu
--
-- game_id kasıtlı olarak TEXT: embedded oyunlar 'embedded_chess' gibi
-- string id kullanıyor, Supabase'deki 'games' tablosundakiler UUID —
-- ikisini de karşılayabilmek için games(id) foreign key'i yok.
-- =============================================

CREATE TABLE IF NOT EXISTS game_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  game_id TEXT NOT NULL,
  score INTEGER DEFAULT 0,
  completed BOOLEAN DEFAULT false,
  time_spent_minutes INTEGER DEFAULT 0,
  played_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  progress_data JSONB DEFAULT '{}'::jsonb,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_game_progress_user_id ON game_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_game_progress_user_game ON game_progress(user_id, game_id);
CREATE INDEX IF NOT EXISTS idx_game_progress_played_at ON game_progress(played_at DESC);

ALTER TABLE game_progress ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own game progress" ON game_progress;
CREATE POLICY "Users can view own game progress"
  ON game_progress FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own game progress" ON game_progress;
CREATE POLICY "Users can insert own game progress"
  ON game_progress FOR INSERT
  WITH CHECK (auth.uid() = user_id);
