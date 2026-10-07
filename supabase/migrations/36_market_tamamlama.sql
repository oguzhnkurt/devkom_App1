-- 36. Market tamamlama: rozetler, etiketler, afişler, pahalı çerçeveler
--
-- NEDEN (7 Ekim 2026, üretim veritabanı salt okuma kontrolü)
-- ---------------------------------------------------------
-- Kullanıcı "markette bazı şeyler gözükmüyor" dedi. Üretimde aktif ürün
-- olarak YALNIZCA DÖRT çerçeve vardı; 33'teki afiş ve rozetler ile 34'teki
-- 20 çerçevenin hiçbiri yoktu.
--
-- Sebep: store_items üzerindeki `store_items_category_check` kısıtı
-- (26 numaralı göç) yalnızca robot_skin, avatar_frame, character,
-- necklace, hat, glasses, shoes değerlerine izin veriyor. 33 numaralı göç
-- 'profile_banner' ve 'name_badge' ekliyordu; tek bir insert içinde
-- olduğu için kısıt bütün satırları (çerçeveler dahil) düşürdü. 34'ün de
-- üretime hiç yazılmadığı görüldü.
--
-- Bu göç:
--   1. Kısıtı yeni kategorilerle (profile_banner, name_badge, profile_tag)
--      yeniden kuruyor. Eski değerler kısıtta kalıyor: pasif satırlar var.
--   2. 33 ve 34'teki bütün ürünleri ve Ekim 2026 yenilerini ekliyor.
--      `on conflict (item_key) do nothing`: tekrar çalıştırmak zararsız.
--
-- FİYAT: bir ders 8 jeton. Etiketler 50-300, rozetler 60-500, pahalı
-- çerçeveler 450-1000 (≈ 55-125 ders): uzun vadeli hedefler.

begin;

alter table store_items drop constraint if exists store_items_category_check;
alter table store_items add constraint store_items_category_check
  check (category in ('robot_skin', 'avatar_frame', 'character', 'necklace',
                      'hat', 'glasses', 'shoes',
                      'profile_banner', 'name_badge', 'profile_tag'));

insert into store_items
  (item_key, category, name, description, price_jeton, icon_emoji, color_hex,
   requires_pro, sort_order, is_active)
values
  -- 34: çerçeve koleksiyonu
,

  -- Pahalı çerçeveler (Ekim 2026)
  ('frame_cosmic',  'avatar_frame', 'Kozmik Çerçeve',    'Dönen halkalar ve kıvılcımlar', 450, '🪐', '#5E35B1', false, 60, true),
  ('frame_dragon',  'avatar_frame', 'Ejderha Kanatları', 'Çırpan kızıl kanatlar',         600, '🐉', '#D84315', false, 61, true),
  ('frame_angel',   'avatar_frame', 'Melek Kanatları',   'Bembeyaz tüylü kanatlar',       700, '🕊️', '#90CAF9', false, 62, true),
  ('frame_legend',  'avatar_frame', 'Efsane Çerçeve',    'Gökkuşağı ışıltısı',            850, '🌟', '#AA00FF', false, 63, true),
  ('frame_emperor', 'avatar_frame', 'İmparator Tacı',    'Taçlı, mücevherli altın halka', 1000, '👑', '#FFB300', false, 64, true),

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
  ('badge_crown',   'name_badge', 'Taç',            'Sıralamanın tepesi için',        250, '👑', '#FFA000', false, 35, true),

  -- Yeni rozetler (Ekim 2026)
  ('badge_cat',     'name_badge', 'Kedi Rozeti',   'Blok kodlamanın dostu',  70,  '🐱', '#FF8F00', false, 36, true),
  ('badge_gear',    'name_badge', 'Dişli',         'Robot yapanlara',        90,  '⚙️', '#607D8B', false, 37, true),
  ('badge_fire',    'name_badge', 'Ateş Serisi',   'Her gün çalışanlara',   120,  '🔥', '#F4511E', false, 38, true),
  ('badge_unicorn', 'name_badge', 'Tek Boynuz',    'Hayal gücü sınırsız',   200,  '🦄', '#EC407A', false, 39, true),
  ('badge_trophy',  'name_badge', 'Kupa',          'Şampiyonlara özel',     350,  '🏆', '#FFA000', false, 40, true),
  ('badge_diamond', 'name_badge', 'Elmas Rozet',   'En nadir rozet',        500,  '💎', '#00B8D4', false, 41, true),

  -- Etiketler (Ekim 2026): avatar çerçevesinin altındaki kurdele
  ('tag_coder',    'profile_tag', 'Kod Ustası',        'Kod yazmayı sevenlere',       50, '💻', '#5A34E8', false, 50, true),
  ('tag_scratch',  'profile_tag', 'Scratch Yıldızı',   'Scratch projelerinin yıldızı', 60, '🐱', '#FF8F00', false, 51, true),
  ('tag_robot',    'profile_tag', 'Robot Kâşifi',      'Robotlarla oynayanlara',      60, '🤖', '#00897B', false, 52, true),
  ('tag_bug',      'profile_tag', 'Hata Avcısı',       'Hiçbir hata kaçamaz',         80, '🐞', '#E53935', false, 53, true),
  ('tag_inventor', 'profile_tag', 'Küçük Mucit',       'Fikirleri hiç bitmeyenlere',  90, '💡', '#F9A825', false, 54, true),
  ('tag_ninja',    'profile_tag', 'Algoritma Ninjası', 'Adım adım düşünenlere',      120, '🥷', '#37474F', false, 55, true),
  ('tag_circuit',  'profile_tag', 'Devre Sihirbazı',   'Arduino ustalarına',         120, '🔌', '#00979D', false, 56, true),
  ('tag_designer', 'profile_tag', 'Oyun Tasarımcısı',  'Kendi oyununu yapanlara',    150, '🎮', '#7E57C2', false, 57, true),
  ('tag_ai',       'profile_tag', 'YZ Kâşifi',         'Yapay zekâyı merak edenlere', 150, '🧠', '#AB47BC', false, 58, true),
  ('tag_legend',   'profile_tag', 'Efsane Kodcu',      'Herkesin konuştuğu',         300, '🏆', '#C62828', false, 59, true)
on conflict (item_key) do nothing;

commit;
