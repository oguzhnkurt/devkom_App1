-- =============================================
-- KARAKTER ÖZELLEŞTİRME: gözlük + ayakkabı kategorileri
--
-- 25_character_customization.sql ile eklenen kolye/şapka kategorilerinin
-- devamı. Aynı desen: store_items CHECK kısıtına iki yeni kategori
-- ('glasses', 'shoes') eklenir ve birkaç ürün seed'lenir. RPC
-- fonksiyonları (purchase_store_item / equip_store_item) kategoriye göre
-- generic çalıştığı için değişiklik gerekmiyor.
-- =============================================

ALTER TABLE store_items DROP CONSTRAINT IF EXISTS store_items_category_check;
ALTER TABLE store_items ADD CONSTRAINT store_items_category_check
  CHECK (category IN ('robot_skin', 'avatar_frame', 'character', 'necklace', 'hat', 'glasses', 'shoes'));

INSERT INTO store_items (item_key, category, name, description, price_jeton, icon_emoji, color_hex, requires_pro, sort_order) VALUES
  -- Gözlükler
  ('glasses_cool',    'glasses', 'Havalı Gözlük',   'Serin bir güneş gözlüğü.',                 45,  '🕶️', '#37474F', false, 0),
  ('glasses_nerd',    'glasses', 'İnek Gözlüğü',    'Bilgiye aç bir bakış.',                     30,  '🤓', '#8D6E63', false, 1),
  ('glasses_laser',   'glasses', 'Lazer Gözlük',    'Geleceğin gözlüğü, Pro''ya özel.',         100, '🥽', '#00E5FF', true,  2),

  -- Ayakkabılar
  ('shoes_sneaker',   'shoes',   'Spor Ayakkabı',   'Rahat bir spor ayakkabı.',                  35,  '👟', '#4CAF50', false, 0),
  ('shoes_boot',      'shoes',   'Kaşif Botu',      'Maceraya hazır sağlam bir bot.',            55,  '🥾', '#8D6E63', false, 1),
  ('shoes_skate',     'shoes',   'Parlayan Paten',  'Işıltılı tekerlekli paten, Pro''ya özel.', 110, '🛼', '#FF4081', true,  2)
ON CONFLICT (item_key) DO NOTHING;
