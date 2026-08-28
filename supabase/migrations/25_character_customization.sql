-- =============================================
-- KARAKTER ÖZELLEŞTİRME: kolye + şapka kategorileri
--
-- Mevcut Market/jeton altyapısı (bkz. 23_store_and_jeton_economy.sql)
-- zaten robot_skin / avatar_frame / character kategorilerini ve atomik
-- satın alma/kuşanma RPC'lerini içeriyordu. Burada sadece store_items
-- CHECK kısıtına iki yeni kategori ('necklace', 'hat') ekleniyor ve
-- birkaç ürün seed'leniyor — RPC fonksiyonları kategoriye göre generic
-- çalıştığı için değişiklik gerekmiyor.
-- =============================================

ALTER TABLE store_items DROP CONSTRAINT IF EXISTS store_items_category_check;
ALTER TABLE store_items ADD CONSTRAINT store_items_category_check
  CHECK (category IN ('robot_skin', 'avatar_frame', 'character', 'necklace', 'hat'));

INSERT INTO store_items (item_key, category, name, description, price_jeton, icon_emoji, color_hex, requires_pro, sort_order) VALUES
  -- Kolyeler
  ('necklace_star',   'necklace', 'Yıldız Kolye',    'Parlak bir yıldız kolyesi.',              40,  '📿', '#FFC107', false, 0),
  ('necklace_heart',  'necklace', 'Kalp Kolye',      'Sevimli bir kalp kolyesi.',                40,  '💗', '#FF4081', false, 1),
  ('necklace_gem',    'necklace', 'Mücevher Kolye',  'Işıltılı bir mücevher, Pro''ya özel.',     120, '💎', '#40C4FF', true,  2),

  -- Şapkalar
  ('hat_cap',         'hat',      'Spor Şapka',      'Rahat bir spor şapka.',                    35,  '🧢', '#4CAF50', false, 0),
  ('hat_wizard',      'hat',      'Büyücü Şapkası',  'Gizemli bir büyücü şapkası.',               70,  '🎩', '#7C4DFF', false, 1),
  ('hat_crown',       'hat',      'Taç',             'Krallara yakışan bir taç, Pro''ya özel.',  130, '👑', '#FFD700', true,  2)
ON CONFLICT (item_key) DO NOTHING;
