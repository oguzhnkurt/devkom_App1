-- 34. Avatar çerçevesi koleksiyonu
--
-- NEDEN
-- -----
-- Markette jetonun gidebileceği yer azdı ve çerçeveler birbirine
-- benziyordu: hepsi aynı şekilde çizilen, yalnızca rengi değişen bir
-- halkaydı. Çocuk 120 jeton biriktirip aldığında gördüğü tek yenilik
-- turuncuydu. Koleksiyon hissi oluşmuyordu — oysa marketin bütün amacı
-- o his.
--
-- Artık her çerçevenin kendi çizimi ve kendi hareketi var
-- (lib/widgets/avatar_cercevesi.dart → CerceveStili). Bu göç de
-- koleksiyonu genişletiyor.
--
-- 33 numaralı göçteki sekiz çerçeve BURADA TEKRARLANIYOR. Sebebi:
-- `on conflict (item_key) do nothing` sayesinde tekrar çalıştırmak
-- zararsız, ama o göç canlı veritabanında eksik kaldıysa bu göç onu da
-- tamamlıyor. Kullanıcı markette yalnızca dört çerçeve görüyordu;
-- sekizinin hiç yazılmamış olma ihtimali vardı ve iki ayrı yerde
-- aramaktansa tek bir göçün tamamlaması daha güvenli.
--
-- FİYATLANDIRMA
-- Bir ders 8 jeton veriyor, ödüllü reklam 5. Yani 100 jeton ≈ 12 ders.
-- Aralık bilerek geniş: 60 jetonluk bir çerçeve ilk haftada ulaşılabilir
-- olsun, 260 jetonluk biri uzun vadeli bir hedef kalsın. Hepsi aynı
-- fiyatta olsaydı seçim "hangisi güzel" değil "hangisi kaldı" olurdu.

begin;

insert into store_items
  (item_key, category, name, description, price_jeton, icon_emoji, color_hex,
   requires_pro, sort_order, is_active)
values
  -- 33 numaralı göçten gelenler (varsa atlanır)
  ('frame_flame',   'avatar_frame', 'Alev Çerçevesi',    'Dalgalanan turuncu alevler',   120, '🔥', '#FF6B35', false, 10, true),
  ('frame_galaxy',  'avatar_frame', 'Galaksi Çerçevesi', 'Dönen mor yıldızlar',          150, '🌌', '#6C3CE0', false, 11, true),
  ('frame_circuit', 'avatar_frame', 'Devre Çerçevesi',   'Halkada dolaşan sinyal',       120, '🔌', '#00979D', false, 12, true),
  ('frame_gold',    'avatar_frame', 'Altın Çerçeve',     'Dönen altın parıltısı',        200, '🏅', '#F2A33C', false, 13, true),
  ('frame_ice',     'avatar_frame', 'Buz Çerçevesi',     'Işıldayan buz kristalleri',    120, '❄️', '#4FC3F7', false, 14, true),
  ('frame_forest',  'avatar_frame', 'Orman Çerçevesi',   'Rüzgârda sallanan yapraklar',  100, '🌿', '#3BA55C', false, 15, true),
  ('frame_candy',   'avatar_frame', 'Şeker Çerçevesi',   'Dönen pembe şeker şeritleri',  100, '🍬', '#EC407A', false, 16, true),
  ('frame_robot',   'avatar_frame', 'Robot Çerçevesi',   'Cıvatalı metal ve tarayıcı',   180, '🤖', '#78909C', false, 17, true),

  -- Yeni koleksiyon
  ('frame_bronze',  'avatar_frame', 'Bronz Çerçeve',     'İlk madalyan',                  60, '🥉', '#B87333', false, 18, true),
  ('frame_ocean',   'avatar_frame', 'Okyanus Çerçevesi', 'Salınan deniz yosunları',       90, '🌊', '#0288D1', false, 19, true),
  ('frame_sakura',  'avatar_frame', 'Kiraz Çiçeği',      'Sallanan pembe yapraklar',     110, '🌸', '#F48FB1', false, 40, true),
  ('frame_neon',    'avatar_frame', 'Neon Çerçevesi',    'Halkada koşan neon ışık',      130, '💡', '#00E5FF', false, 41, true),
  ('frame_thunder', 'avatar_frame', 'Şimşek Çerçevesi',  'Çakan sarı enerji',            140, '⚡', '#FFD600', false, 42, true),
  ('frame_lava',    'avatar_frame', 'Lav Çerçevesi',     'Kızgın kırmızı diller',        160, '🌋', '#D32F2F', false, 43, true),
  ('frame_rainbow', 'avatar_frame', 'Gökkuşağı',         'Dönen renk şeritleri',         170, '🌈', '#7C4DFF', false, 44, true),
  ('frame_pixel',   'avatar_frame', 'Piksel Çerçevesi',  '8-bit cıvatalar',              150, '🎮', '#5C6BC0', false, 45, true),
  ('frame_comet',   'avatar_frame', 'Kuyruklu Yıldız',   'Etrafında koşan kuyruklar',    190, '☄️', '#FF7043', false, 46, true),
  ('frame_crystal', 'avatar_frame', 'Kristal Çerçeve',   'Keskin ışık kırılmaları',      210, '🔮', '#AB47BC', false, 47, true),
  ('frame_aurora',  'avatar_frame', 'Kuzey Işıkları',    'Süzülen yeşil-mor ışıklar',    230, '🌠', '#26C6DA', false, 48, true),
  ('frame_royal',   'avatar_frame', 'Kraliyet Çerçevesi','Mor kadife ve altın',          260, '👑', '#7B1FA2', false, 49, true)
on conflict (item_key) do nothing;

commit;
