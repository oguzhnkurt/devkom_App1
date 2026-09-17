-- JETON HARCAMA: seri kalkanı, profil afişi, isim rozeti ve yeni çerçeveler.
--
-- NEDEN
-- -----
-- Giyilebilir ürünler kalktıktan sonra markette yalnızca 4 avatar çerçevesi
-- kaldı. Pro üyeler her ay 300 jeton alıyor; harcanacak bir şey olmayınca
-- jeton anlamsız bir sayıya dönüşüyor ve kazanma isteği de kayboluyor.
--
-- Eklenen dört şey:
--   1. Seri kalkanı  — TÜKETİLEBİLİR. Bir gün ara verilirse seri kırılmıyor.
--   2. Profil afişi  — profil başlığındaki renkli alan.
--   3. İsim rozeti   — sıralamada adının yanındaki küçük işaret.
--   4. 8 yeni avatar çerçevesi.
--
-- Kalkan neden store_items değil: `purchase_store_item` aynı ürünü ikinci
-- kez almayı "already_owned" diye reddediyor ve haklı — çerçeveyi iki kez
-- almanın anlamı yok. Kalkan ise tüketiliyor, tekrar tekrar alınabilmeli.
-- Bu yüzden kendi sayacı (user_progress.streak_shields) ve kendi RPC'si var.

begin;

-- ---------------------------------------------------------------- 1. kalkan
alter table user_progress
  add column if not exists streak_shields integer not null default 0;

create or replace function purchase_streak_shield(p_count integer default 1)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user   uuid := auth.uid();
  v_price  integer := 60;          -- tek kalkan fiyatı (jeton)
  v_total  integer;
  v_balance integer;
  v_shields integer;
begin
  if v_user is null then
    return jsonb_build_object('success', false, 'error', 'not_authenticated');
  end if;

  -- Tek seferde en fazla 5: bir çocuğun bütün jetonunu tek dokunuşla
  -- harcamasını istemiyoruz.
  if p_count is null or p_count < 1 or p_count > 5 then
    return jsonb_build_object('success', false, 'error', 'invalid_count');
  end if;

  v_total := v_price * p_count;

  -- Satır kilitleniyor: aynı anda iki istek gelirse jeton iki kez düşmesin.
  select jeton_balance, streak_shields into v_balance, v_shields
  from user_progress
  where user_id = v_user
  for update;

  if not found then
    return jsonb_build_object('success', false, 'error', 'no_progress_record');
  end if;

  if v_balance < v_total then
    return jsonb_build_object('success', false, 'error', 'insufficient_balance',
                              'balance', v_balance, 'price', v_total);
  end if;

  -- En fazla 3 kalkan taşınabiliyor. Sınırsız biriktirme, seriyi
  -- "her gün biraz çalışmak" olmaktan çıkarır.
  if v_shields + p_count > 3 then
    return jsonb_build_object('success', false, 'error', 'shield_limit',
                              'shields', v_shields);
  end if;

  update user_progress
  set jeton_balance = v_balance - v_total,
      streak_shields = v_shields + p_count,
      updated_at = now()
  where user_id = v_user
  returning jeton_balance, streak_shields into v_balance, v_shields;

  return jsonb_build_object('success', true, 'new_balance', v_balance,
                            'shields', v_shields, 'price', v_total);
end;
$$;

grant execute on function purchase_streak_shield(integer) to authenticated, anon;

-- ------------------------------------------------- 2-4. yeni katalog ürünleri
--
-- Idempotent: item_key benzersiz olduğu için ikinci çalıştırmada çakışan
-- satırlar atlanıyor.
insert into store_items
  (item_key, category, name, description, price_jeton, icon_emoji, color_hex,
   requires_pro, sort_order, is_active)
values
  -- Avatar çerçeveleri
  ('frame_flame',   'avatar_frame', 'Alev Çerçevesi',   'Turuncu alevli halka',        120, '🔥', '#FF6B35', false, 10, true),
  ('frame_galaxy',  'avatar_frame', 'Galaksi Çerçevesi','Mor-mavi yıldız halkası',     150, '🌌', '#6C3CE0', false, 11, true),
  ('frame_circuit', 'avatar_frame', 'Devre Çerçevesi',  'Yeşil devre yolları',         120, '🔌', '#00979D', false, 12, true),
  ('frame_gold',    'avatar_frame', 'Altın Çerçeve',    'Sarı altın halka',            200, '🏅', '#F2A33C', false, 13, true),
  ('frame_ice',     'avatar_frame', 'Buz Çerçevesi',    'Buz mavisi halka',            120, '❄️', '#4FC3F7', false, 14, true),
  ('frame_forest',  'avatar_frame', 'Orman Çerçevesi',  'Yeşil yaprak halkası',        100, '🌿', '#3BA55C', false, 15, true),
  ('frame_candy',   'avatar_frame', 'Şeker Çerçevesi',  'Pembe şeker halkası',         100, '🍬', '#EC407A', false, 16, true),
  ('frame_robot',   'avatar_frame', 'Robot Çerçevesi',  'Metal cıvatalı halka',        180, '🤖', '#78909C', false, 17, true),
  -- Profil afişleri
  ('banner_night',   'profile_banner', 'Gece Gökyüzü',  'Yıldızlı mor gece',           150, '🌙', '#3949AB', false, 20, true),
  ('banner_circuit', 'profile_banner', 'Devre Kartı',   'Yeşil devre deseni',          150, '🟩', '#00897B', false, 21, true),
  ('banner_sunset',  'profile_banner', 'Gün Batımı',    'Turuncu-pembe geçiş',         150, '🌇', '#F4511E', false, 22, true),
  ('banner_ocean',   'profile_banner', 'Okyanus',       'Mavi derinlik',               150, '🌊', '#0277BD', false, 23, true),
  ('banner_pixel',   'profile_banner', 'Piksel Manzara','8-bit tepeler',               200, '🎮', '#7E57C2', false, 24, true),
  ('banner_lab',     'profile_banner', 'Robot Atölyesi','Gri atölye, kıvılcımlar',     200, '🔧', '#546E7A', false, 25, true),
  -- İsim rozetleri
  ('badge_rocket',  'name_badge', 'Roket Rozeti',   'Adının yanında roket',            80,  '🚀', '#5A34E8', false, 30, true),
  ('badge_bug',     'name_badge', 'Böcek Avcısı',   'Hata avcılarına',                 80,  '🐞', '#EF5350', false, 31, true),
  ('badge_brain',   'name_badge', 'Düşünen Kafa',   'Bulmaca çözenlere',               80,  '🧠', '#AB47BC', false, 32, true),
  ('badge_star',    'name_badge', 'Yıldız',         'Klasik yıldız',                   60,  '⭐', '#FFB300', false, 33, true),
  ('badge_bolt',    'name_badge', 'Şimşek',         'Hızlı çözenlere',                 80,  '⚡', '#FDD835', false, 34, true),
  ('badge_crown',   'name_badge', 'Taç',            'Sıralamanın tepesi için',        250, '👑', '#FFA000', false, 35, true)
on conflict (item_key) do nothing;

commit;
