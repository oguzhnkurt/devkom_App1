-- =============================================
-- INSERT COURSES DATA
-- =============================================
-- This script inserts all 25 programming courses into the database

BEGIN;

-- Insert all courses
INSERT INTO courses (id, name, slug, description, icon, primary_color, secondary_color, category, difficulty, tags, total_lessons, estimated_minutes, sort_order, is_premium, is_active) VALUES

-- KIDS
('scratch', 'Scratch', 'scratch', 'Blok tabanli gorsel programlama. Kodlamaya ilk adim!', '🧩', '#FF8C1A', '#FFAB40', 'kids', 'beginner', ARRAY['gorsel', 'oyun', 'animasyon', 'cocuk'], 15, 180, 1, false, true),

-- WEB
('html', 'HTML', 'html', 'Web sayfalarinin temeli. Icerik yapilandirma dili.', '🌐', '#E44D26', '#F16529', 'web', 'beginner', ARRAY['web', 'frontend', 'markup'], 20, 240, 2, false, true),
('css', 'CSS', 'css', 'Web sayfalarini guzelleştir. Stil ve tasarim dili.', '🎨', '#264DE4', '#2965F1', 'web', 'beginner', ARRAY['web', 'frontend', 'stil', 'tasarim'], 18, 220, 3, false, true),
('javascript', 'JavaScript', 'javascript', 'Web''in programlama dili. Etkilesimli sayfalar olustur.', '⚡', '#F7DF1E', '#FFE066', 'web', 'beginner', ARRAY['web', 'frontend', 'backend', 'dinamik'], 25, 360, 4, false, true),
('typescript', 'TypeScript', 'typescript', 'JavaScript''in guvenli versiyonu. Tip sistemli JS.', '📘', '#3178C6', '#4B8FD6', 'web', 'intermediate', ARRAY['web', 'tip-guvenli', 'microsoft'], 18, 270, 5, false, true),
('php', 'PHP', 'php', 'Sunucu tarafli web gelistirme. Dinamik web siteleri.', '🐘', '#777BB4', '#8892BF', 'web', 'intermediate', ARRAY['web', 'backend', 'sunucu'], 20, 300, 6, false, true),
('sql', 'SQL', 'sql', 'Veritabani sorgulama dili. Verileri yonet ve analiz et.', '🗃️', '#00758F', '#00A3CC', 'web', 'beginner', ARRAY['veritabani', 'veri', 'sorgu'], 16, 200, 7, false, true),

-- MOBILE
('dart', 'Dart', 'dart', 'Flutter''in dili. Modern, hizli, cok platformlu.', '🎯', '#0175C2', '#02569B', 'mobile', 'beginner', ARRAY['flutter', 'mobil', 'google'], 22, 330, 8, false, true),
('swift', 'Swift', 'swift', 'Apple ekosistemi. iOS ve macOS uygulama gelistirme.', '🍎', '#FA7343', '#FF8A65', 'mobile', 'intermediate', ARRAY['ios', 'macos', 'apple'], 20, 300, 9, false, true),
('kotlin', 'Kotlin', 'kotlin', 'Modern Android gelistirme. Java''nin yeni nesil hali.', '🤖', '#7F52FF', '#A87FFF', 'mobile', 'intermediate', ARRAY['android', 'jvm', 'jetbrains'], 20, 300, 10, false, true),
('java', 'Java', 'java', 'Kurumsal standart. Her yerde calisan guvenilir dil.', '☕', '#ED8B00', '#FFA726', 'mobile', 'intermediate', ARRAY['android', 'kurumsal', 'jvm'], 25, 400, 11, false, true),
('csharp', 'C#', 'csharp', 'Microsoft''un gucu. Oyun, web, masaustu hepsi bir arada.', '💜', '#68217A', '#9B4DCA', 'mobile', 'intermediate', ARRAY['unity', 'windows', 'microsoft', '.net'], 22, 350, 12, false, true),

-- SYSTEMS
('c', 'C', 'c', 'Tum dillerin atasi. Sistem programlamanin temeli.', '⚙️', '#00599C', '#004482', 'systems', 'intermediate', ARRAY['sistem', 'performans', 'temel'], 20, 320, 13, false, true),
('cpp', 'C++', 'cpp', 'Yuksek performans. Oyun motorlari ve sistem yazilimi.', '🔧', '#00599C', '#659AD2', 'systems', 'advanced', ARRAY['oyun', 'sistem', 'performans'], 25, 420, 14, false, true),
('go', 'Go', 'go', 'Google''in basit ve hizli dili. Mikroservisler icin ideal.', '🐹', '#00ADD8', '#5DC9E2', 'systems', 'intermediate', ARRAY['google', 'mikroservis', 'bulut'], 18, 280, 15, false, true),
('rust', 'Rust', 'rust', 'Guvenli sistem programlama. Bellek hatasi yok!', '🦀', '#DEA584', '#B7410E', 'systems', 'advanced', ARRAY['guvenli', 'sistem', 'performans'], 20, 350, 16, false, true),

-- ROBOTICS
('arduino', 'Arduino', 'arduino', 'Elektronik projelerin beyni. LED''den robota!', '🔌', '#00979D', '#00BCD4', 'robotics', 'beginner', ARRAY['elektronik', 'robot', 'maker'], 18, 270, 17, false, true),
('micropython', 'MicroPython', 'micropython', 'Python ile mikrodenetleyici programla.', '🐍', '#2B5B84', '#3776AB', 'robotics', 'beginner', ARRAY['python', 'iot', 'esp32'], 15, 220, 18, false, true),
('raspberrypi', 'Raspberry Pi', 'raspberrypi', 'Mini bilgisayar ile projeler. Linux ve GPIO.', '🍓', '#C51A4A', '#E91E63', 'robotics', 'intermediate', ARRAY['linux', 'iot', 'proje'], 16, 260, 19, false, true),

-- DATA
('python', 'Python', 'python', 'En populer dil. Veri bilimi, AI, otomasyon.', '🐍', '#3776AB', '#FFD43B', 'data', 'beginner', ARRAY['veri', 'ai', 'otomasyon', 'baslangic'], 25, 360, 20, false, true),
('r', 'R', 'r', 'Istatistik ve veri analizi. Bilim insanlarinin tercihi.', '📊', '#276DC3', '#4A90D9', 'data', 'intermediate', ARRAY['istatistik', 'veri', 'analiz'], 16, 260, 21, false, true),
('julia', 'Julia', 'julia', 'Yuksek performansli bilimsel hesaplama.', '🔬', '#9558B2', '#389826', 'data', 'advanced', ARRAY['bilim', 'hesaplama', 'performans'], 14, 240, 22, false, true),

-- SCRIPTING
('ruby', 'Ruby', 'ruby', 'Mutlu programci dili. Rails ile web gelistirme.', '💎', '#CC342D', '#E57373', 'scripting', 'intermediate', ARRAY['web', 'rails', 'elegant'], 18, 280, 23, false, true),
('lua', 'Lua', 'lua', 'Hafif ve hizli. Oyun scriptleri ve gomulu sistemler.', '🌙', '#000080', '#3949AB', 'scripting', 'beginner', ARRAY['oyun', 'script', 'hafif'], 14, 200, 24, false, true),
('bash', 'Bash', 'bash', 'Linux/Mac terminal. Otomasyon ve sistem yonetimi.', '💻', '#4EAA25', '#66BB6A', 'scripting', 'beginner', ARRAY['linux', 'terminal', 'otomasyon'], 15, 180, 25, false, true);

COMMIT;

-- Verify insertion
SELECT COUNT(*) as total_courses FROM courses;
SELECT category, COUNT(*) as count FROM courses GROUP BY category ORDER BY count DESC;
