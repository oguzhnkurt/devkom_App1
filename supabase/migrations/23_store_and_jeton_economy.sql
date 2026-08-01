-- =============================================
-- DEVKOM JETON EKONOMİSİ + MARKET (STORE)
-- Öğrencilerin ders/oyun tamamlayarak kazandığı "jeton" ile
-- Market'ten robot kılıfı, çerçeve ve karakter satın alıp
-- kuşanabildiği (equip) bir ekonomi katmanı.
--
-- jeton_balance: user_progress üzerinde, XP'den bağımsız,
-- harcanabilir bir bakiye. XP asla azalmaz; jeton azalabilir.
-- =============================================

-- ---------------------------------------------
-- 0) user_progress tablosu prod'da hiç oluşturulmamıştı
-- (supabase_user_progress.sql yerel dosyası hiç uygulanmamış) —
-- bu yüzden ana ekrandaki XP/Seviye her zaman sabit varsayılana
-- düşüyordu. Burada oluşturuluyor + jeton_balance ekleniyor.
-- ---------------------------------------------
CREATE TABLE IF NOT EXISTS user_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  total_xp INTEGER DEFAULT 0,
  level INTEGER DEFAULT 1,

  streak_days INTEGER DEFAULT 0,
  last_active_date TIMESTAMP WITH TIME ZONE,
  longest_streak INTEGER DEFAULT 0,

  daily_lessons_completed INTEGER DEFAULT 0,
  daily_games_played INTEGER DEFAULT 0,
  daily_quizzes_completed INTEGER DEFAULT 0,
  last_goal_reset_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  completed_lesson_ids TEXT[] DEFAULT '{}',
  earned_badge_ids TEXT[] DEFAULT '{}',

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  UNIQUE(user_id)
);

CREATE INDEX IF NOT EXISTS idx_user_progress_user_id ON user_progress(user_id);

ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own progress" ON user_progress;
CREATE POLICY "Users can view own progress"
  ON user_progress FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own progress" ON user_progress;
CREATE POLICY "Users can insert own progress"
  ON user_progress FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own progress" ON user_progress;
CREATE POLICY "Users can update own progress"
  ON user_progress FOR UPDATE
  USING (auth.uid() = user_id);

CREATE OR REPLACE FUNCTION update_user_progress_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_user_progress_timestamp ON user_progress;
CREATE TRIGGER trigger_update_user_progress_timestamp
  BEFORE UPDATE ON user_progress
  FOR EACH ROW
  EXECUTE FUNCTION update_user_progress_timestamp();

-- Mevcut tüm kullanıcılar için başlangıç ilerleme kaydı oluştur
INSERT INTO user_progress (user_id)
SELECT id FROM auth.users
WHERE id NOT IN (SELECT user_id FROM user_progress)
ON CONFLICT (user_id) DO NOTHING;

-- ---------------------------------------------
-- 1) user_progress: jeton_balance kolonu
-- ---------------------------------------------
ALTER TABLE user_progress ADD COLUMN IF NOT EXISTS jeton_balance INTEGER NOT NULL DEFAULT 0;

-- ---------------------------------------------
-- 2) store_items: mağaza kataloğu
-- ---------------------------------------------
CREATE TABLE IF NOT EXISTS store_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_key TEXT UNIQUE NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('robot_skin', 'avatar_frame', 'character')),
    name TEXT NOT NULL,
    description TEXT,
    price_jeton INTEGER NOT NULL DEFAULT 0,
    icon_emoji TEXT NOT NULL DEFAULT '🤖',
    color_hex TEXT NOT NULL DEFAULT '#4F8EF7',
    requires_pro BOOLEAN NOT NULL DEFAULT FALSE,
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_store_items_category ON store_items(category);

-- ---------------------------------------------
-- 3) user_inventory: kullanıcının sahip olduğu / kuşandığı ürünler
-- ---------------------------------------------
CREATE TABLE IF NOT EXISTS user_inventory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    item_id UUID NOT NULL REFERENCES store_items(id) ON DELETE CASCADE,
    equipped BOOLEAN NOT NULL DEFAULT FALSE,
    purchased_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, item_id)
);

CREATE INDEX IF NOT EXISTS idx_user_inventory_user ON user_inventory(user_id);

ALTER TABLE store_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_inventory ENABLE ROW LEVEL SECURITY;

-- Herkes (giriş yapmış kullanıcı) aktif ürünleri görebilir
CREATE POLICY "Anyone can view active store items"
ON store_items FOR SELECT
USING (is_active = true);

-- Sadece admin katalog yönetebilir
CREATE POLICY "Admins manage store items"
ON store_items FOR ALL
USING (EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'));

-- Kullanıcılar sadece kendi envanterini görebilir
CREATE POLICY "Users view own inventory"
ON user_inventory FOR SELECT
USING (user_id = auth.uid());

-- ---------------------------------------------
-- 4) purchase_store_item: atomik satın alma
-- (bakiye kontrolü + düşme + envantere ekleme tek transaction'da)
-- ---------------------------------------------
CREATE OR REPLACE FUNCTION purchase_store_item(p_item_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id UUID := auth.uid();
  v_price INTEGER;
  v_requires_pro BOOLEAN;
  v_is_pro BOOLEAN;
  v_already_owned BOOLEAN;
  v_balance INTEGER;
BEGIN
  IF v_user_id IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'not_authenticated');
  END IF;

  SELECT price_jeton, requires_pro INTO v_price, v_requires_pro
  FROM store_items WHERE id = p_item_id AND is_active = true;

  IF v_price IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'item_not_found');
  END IF;

  SELECT EXISTS(
    SELECT 1 FROM user_inventory WHERE user_id = v_user_id AND item_id = p_item_id
  ) INTO v_already_owned;

  IF v_already_owned THEN
    RETURN json_build_object('success', false, 'error', 'already_owned');
  END IF;

  IF v_requires_pro THEN
    SELECT COALESCE(is_pro, false) INTO v_is_pro FROM users WHERE id = v_user_id;
    IF NOT COALESCE(v_is_pro, false) THEN
      RETURN json_build_object('success', false, 'error', 'requires_pro');
    END IF;
  END IF;

  SELECT jeton_balance INTO v_balance FROM user_progress WHERE user_id = v_user_id FOR UPDATE;

  IF v_balance IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'no_progress_record');
  END IF;

  IF v_balance < v_price THEN
    RETURN json_build_object('success', false, 'error', 'insufficient_balance', 'balance', v_balance, 'price', v_price);
  END IF;

  UPDATE user_progress
  SET jeton_balance = jeton_balance - v_price, updated_at = NOW()
  WHERE user_id = v_user_id;

  INSERT INTO user_inventory (user_id, item_id, equipped)
  VALUES (v_user_id, p_item_id, false);

  RETURN json_build_object('success', true, 'new_balance', v_balance - v_price);
END;
$$;

GRANT EXECUTE ON FUNCTION purchase_store_item(UUID) TO authenticated;

-- ---------------------------------------------
-- 5) equip_store_item: kuşanma (aynı kategoride başka ürün varsa çıkar)
-- ---------------------------------------------
CREATE OR REPLACE FUNCTION equip_store_item(p_item_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id UUID := auth.uid();
  v_category TEXT;
  v_owned BOOLEAN;
BEGIN
  IF v_user_id IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'not_authenticated');
  END IF;

  SELECT category INTO v_category FROM store_items WHERE id = p_item_id;
  IF v_category IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'item_not_found');
  END IF;

  SELECT EXISTS(
    SELECT 1 FROM user_inventory WHERE user_id = v_user_id AND item_id = p_item_id
  ) INTO v_owned;

  IF NOT v_owned THEN
    RETURN json_build_object('success', false, 'error', 'not_owned');
  END IF;

  UPDATE user_inventory
  SET equipped = false
  WHERE user_id = v_user_id
    AND item_id IN (SELECT id FROM store_items WHERE category = v_category);

  UPDATE user_inventory
  SET equipped = true
  WHERE user_id = v_user_id AND item_id = p_item_id;

  RETURN json_build_object('success', true);
END;
$$;

GRANT EXECUTE ON FUNCTION equip_store_item(UUID) TO authenticated;

-- ---------------------------------------------
-- 6) Başlangıç kataloğu (varsayılan/ücretsiz ürünler dahil)
-- ---------------------------------------------
INSERT INTO store_items (item_key, category, name, description, price_jeton, icon_emoji, color_hex, requires_pro, sort_order) VALUES
  -- Robot kılıfları (Robot Simülatörü'nde kullanılır)
  ('robot_classic',   'robot_skin', 'Klasik Gri',        'Standart robotun varsayılan rengi.',            0,   '🤖', '#9AA5B1', false, 0),
  ('robot_fire',      'robot_skin', 'Ateş Kırmızısı',     'Alev gibi kırmızı bir gövde.',                   50,  '🤖', '#FF5252', false, 1),
  ('robot_ocean',     'robot_skin', 'Okyanus Mavisi',     'Serin ve sakin bir mavi ton.',                   50,  '🤖', '#2196F3', false, 2),
  ('robot_neon',      'robot_skin', 'Neon Yeşil',         'Karanlıkta parlayan neon yeşil.',                75,  '🤖', '#39FF14', false, 3),
  ('robot_gold',      'robot_skin', 'Altın Robot',        'Parlak altın kaplama, sadece Pro üyelere özel.', 150, '🤖', '#FFD700', true,  4),
  ('robot_rainbow',   'robot_skin', 'Gökkuşağı',          'Her an renk değiştiren efsanevi kılıf.',         200, '🤖', '#B24BF3', true,  5),

  -- Avatar çerçeveleri (profil/ana ekranda kullanılabilir)
  ('frame_simple',    'avatar_frame', 'Basit Çerçeve',    'Varsayılan sade çerçeve.',                       0,   '⚪', '#9AA5B1', false, 0),
  ('frame_star',      'avatar_frame', 'Yıldızlı Çerçeve', 'Etrafında parlayan yıldızlar.',                  40,  '⭐', '#FFC107', false, 1),
  ('frame_fire',      'avatar_frame', 'Alev Çerçeve',     'Ateşten bir çerçeve.',                           80,  '🔥', '#FF7043', false, 2),
  ('frame_diamond',   'avatar_frame', 'Elmas Çerçeve',    'Parıldayan elmas çerçeve, Pro''ya özel.',        150, '💎', '#40C4FF', true,  3),

  -- Karakterler / maskotlar
  ('char_pixel',      'character', 'Pixel',               'Meraklı küçük piksel dostu.',                    30,  '👾', '#7C4DFF', false, 0),
  ('char_astro',      'character', 'Astro',               'Uzaydan gelen minik robot.',                     60,  '🛸', '#00BCD4', false, 1),
  ('char_byte',       'character', 'Byte',                'Enerjik şimşek maskotu.',                        90,  '⚡', '#FFEB3B', false, 2),
  ('char_kral',       'character', 'Kodlama Kralı',       'En yüksek rütbeli maskot, Pro''ya özel.',        120, '👑', '#FFD700', true,  3)
ON CONFLICT (item_key) DO NOTHING;

COMMENT ON TABLE store_items IS 'Market kataloğu: jeton karşılığı satın alınabilir robot kılıfı, çerçeve ve karakterler.';
COMMENT ON TABLE user_inventory IS 'Kullanıcıların satın aldığı ve kuşandığı store_items kayıtları.';
COMMENT ON COLUMN user_progress.jeton_balance IS 'Market''te harcanabilir jeton bakiyesi (XP''den bağımsız).';
