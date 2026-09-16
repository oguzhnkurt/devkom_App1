-- Ingilizce video katalogunun tamamlanmasi
--
-- Sorun: katalogda 15 aktif seri vardi ama anlatim dili dagilimi
-- 6 tr / 4 de / 4 es / 1 en idi. Ingilizce secen cocuk kendi dilinde
-- tek seri (Scratch) goruyor, yaninda 14 yabanci seri duruyordu.
-- Almanca ve Ispanyolcada Scratch + Web + Python + Arduino dortlusu
-- varken Ingilizcede yalnizca Scratch olmasinin bir sebebi yoktu.
--
-- Bu betik eksik uc seriyi ekliyor: Web (HTML/CSS), Python, Arduino.
-- Her seri de/es karsiligiyla ayni emoji, renk ve seviyeyi kullaniyor.
--
-- DOGRULAMA: 35 videonun HEPSI YouTube oembed ucnoktasindan tek tek
-- sorgulandi; baslik ve kanal adi gercekten dondu (2026-09-15).
-- Dogrulanamayan hicbir video listeye alinmadi. `duration_seconds`
-- bilerek NULL: sureler guvenilir bir kaynaktan teyit edilmedi,
-- tahmin yazilmadi.
--
-- Betik idempotent: ayni slug ikinci kez eklenmeye calisilmaz.

begin;

-- ---------------------------------------------------------------
-- 1) Web (HTML & CSS) — Net Ninja, 11 bolum
-- ---------------------------------------------------------------
with yeni as (
  insert into video_series
    (slug, title, description, cover_emoji, color_hex, level,
     requires_pro, sort_order, is_active, title_en, description_en, audio_lang)
  select
    'web-html-css-en',
    'HTML & CSS Crash Course',
    'İngilizce anlatımlı web serisi: HTML etiketleriyle sayfanı kur, CSS ile biçimlendir, telefonda da düzgün görünsün.',
    '🌐', '#E44D26', 'beginner',
    false, 7, true,
    'HTML & CSS Crash Course',
    'An English crash course in HTML and CSS: build a page with tags, style it with CSS, and make it fit any screen.',
    'en'
  where not exists (select 1 from video_series where slug = 'web-html-css-en')
  returning id
)
insert into video_episodes
  (series_id, title, title_en, description, description_en, youtube_url,
   sort_order, xp_reward, jeton_reward, channel_name, channel_url, is_active)
select yeni.id, b.t, b.t, b.d, b.d,
       'https://www.youtube.com/watch?v=' || b.v,
       b.n, 5, 3, 'Net Ninja', 'https://www.youtube.com/@NetNinja', true
from yeni, (values
  ('HTML & CSS Crash Course Tutorial #1 - Introduction',                'What the course covers and what you will build.',                          'hu-q2zYwEYs',  1),
  ('HTML & CSS Crash Course Tutorial #2 - HTML Basics',                 'The tags a page is made of: headings, paragraphs, links and images.',       'mbeT8mpmtHA',  2),
  ('HTML & CSS Crash Course Tutorial #3 - HTML Forms',                  'Inputs, labels and buttons: how a page asks its visitor a question.',       'YwbIeMlxZAU',  3),
  ('HTML & CSS Crash Course Tutorial #4 - CSS Basics',                  'Colour, size and spacing: your first rules for how a page looks.',          'D3iEE29ZXRM',  4),
  ('HTML & CSS Crash Course Tutorial #5 - CSS Classes & Selectors',     'Naming parts of the page so a rule hits exactly what you mean.',            'FHZn6706e3Q',  5),
  ('HTML & CSS Crash Course Tutorial #6 - HTML 5 Semantics',            'Tags that say what a section is: header, nav, main and footer.',            'kGW8Al_cga4',  6),
  ('HTML & CSS Crash Course Tutorial #7 - Chrome Dev Tools',            'Open the browser''s own tools and inspect your page while it runs.',        '25R1Jl5P7Mw',  7),
  ('HTML & CSS Crash Course Tutorial #8 - CSS Layout & Position',       'Placing boxes where you want them instead of letting them stack.',          'XQaHAAXIVg8',  8),
  ('HTML & CSS Crash Course Tutorial #9 - Pseudo Classes & Elements',   'Styling special states such as hover and first child.',                     'FMu2cKWD90g',  9),
  ('HTML & CSS Crash Course Tutorial #10 - Intro to Media Queries',     'Making one page fit both a phone and a laptop.',                            'Xig7NsIE6DI', 10),
  ('HTML & CSS Crash Course Tutorial #11 - Next Steps',                 'Where to go once the crash course is done.',                                'qES0HypsUK0', 11)
) as b(t, d, v, n);

-- ---------------------------------------------------------------
-- 2) Python — Microsoft Developer, 12 bolum
-- ---------------------------------------------------------------
with yeni as (
  insert into video_series
    (slug, title, description, cover_emoji, color_hex, level,
     requires_pro, sort_order, is_active, title_en, description_en, audio_lang)
  select
    'python-giris-en',
    'Python for Beginners',
    'İngilizce anlatımlı Python serisi: ilk satırından başla, yazdırmayı, yorum satırını ve metinlerle çalışmayı öğren.',
    '🐍', '#3776AB', 'beginner',
    false, 8, true,
    'Python for Beginners',
    'Microsoft''s English beginner series: run your first line of Python, then learn print, comments and strings.',
    'en'
  where not exists (select 1 from video_series where slug = 'python-giris-en')
  returning id
)
insert into video_episodes
  (series_id, title, title_en, description, description_en, youtube_url,
   sort_order, xp_reward, jeton_reward, channel_name, channel_url, is_active)
select yeni.id, b.t, b.t, b.d, b.d,
       'https://www.youtube.com/watch?v=' || b.v,
       b.n, 5, 3, 'Microsoft Developer', 'https://www.youtube.com/@MicrosoftDeveloper', true
from yeni, (values
  ('Programming with Python | Python for Beginners [1 of 44]',        'What programming is, and why Python is a good first language.',      'jFCNu1-Xdsw',  1),
  ('Introducing Python | Python for Beginners [2 of 44]',             'A tour of the language and what people build with it.',              '7XOhibxgBlQ',  2),
  ('Getting Started | Python for Beginners [3 of 44]',                'Installing Python and running your very first line of code.',        'CXZYvNRIAKM',  3),
  ('Configuring Visual Studio Code | Python for Beginners [4 of 44]', 'Setting up the editor you will write Python in.',                    'EU8eayHWoZg',  4),
  ('Using Print | Python for Beginners [5 of 44]',                    'The print command: making the computer say something back.',         'FhoASwgvZHk',  5),
  ('Demo: Hello World | Python for Beginners [6 of 44]',              'Writing and running the classic first program.',                     'wWwr0tDSqnE',  6),
  ('Comments | Python for Beginners [7 of 44]',                       'Notes in your code that Python ignores and people read.',            'kEuVvUc1Zec',  7),
  ('Demo: Comments | Python for Beginners [8 of 44]',                 'Adding comments to a real script.',                                  'fbek7n6ecWM',  8),
  ('String Concepts | Python for Beginners [9 of 44]',                'Text in Python: how strings work.',                                  'tSebLz1hNpA',  9),
  ('Demo: Strings | Python for Beginners [10 of 44]',                 'Trying strings out in code.',                                        'zv3cVJHCqXA', 10),
  ('Formatting Strings | Python for Beginners [11 of 44]',            'Putting a value neatly inside a sentence.',                          'bQQqxysLIGE', 11),
  ('Demo: Formatting Strings | Python for Beginners [12 of 44]',      'String formatting in practice.',                                     'E850-MF22P0', 12)
) as b(t, d, v, n);

-- ---------------------------------------------------------------
-- 3) Arduino — Paul McWhorter, 12 bolum
-- ---------------------------------------------------------------
with yeni as (
  insert into video_series
    (slug, title, description, cover_emoji, color_hex, level,
     requires_pro, sort_order, is_active, title_en, description_en, audio_lang)
  select
    'arduino-temel-en',
    'Arduino Lessons for Beginners',
    'İngilizce anlatımlı Arduino serisi: devreyi kur, LED''i yak, seri porttan kartla konuş.',
    '🔌', '#00979D', 'intermediate',
    false, 9, true,
    'Arduino Lessons for Beginners',
    'An English Arduino course from the very first blink: build circuits, read voltages and talk to the board over the serial port.',
    'en'
  where not exists (select 1 from video_series where slug = 'arduino-temel-en')
  returning id
)
insert into video_episodes
  (series_id, title, title_en, description, description_en, youtube_url,
   sort_order, xp_reward, jeton_reward, channel_name, channel_url, is_active)
select yeni.id, b.t, b.t, b.d, b.d,
       'https://www.youtube.com/watch?v=' || b.v,
       b.n, 5, 3, 'Paul McWhorter', 'https://www.youtube.com/@paulmcwhorter', true
from yeni, (values
  ('LESSON 1: Simple Introduction to the Arduino',                                             'A first look at the board and the sketch that blinks an LED.',   'd8_xXNcGYgo',  1),
  ('LESSON 2: Simple Arduino Breadboard Tutorial',                                             'Building your first circuit on a breadboard.',                   'uHUSsSlZa24',  2),
  ('LESSON 3 - Arduino For Loops and LED Circuit',                                             'For loops: repeating an action in code.',                        'O4JACbIQX_w',  3),
  ('LESSON 4: Printing Over the Arduino Serial Port',                                          'Making the board talk back to you.',                             'ysHY5JUkpUQ',  4),
  ('LESSON 5: Working with Strings in Arduino',                                                'Working with text on the Arduino.',                              'DwOLDLDqWUk',  5),
  ('LESSON 6: Reading Data from Arduino Serial Monitor',                                       'Reading what you type into the serial monitor.',                 '-3Xg8x2ibeY',  6),
  ('LESSON 7 Using While Loops with Arduino',                                                  'While loops: repeating until something changes.',                'Y64Ev-pWqFs',  7),
  ('LESSON 8: Write Analog Voltages on the Arduino',                                           'Fading instead of switching, with analog output.',               '9FBMVt-iFrM',  8),
  ('LESSON 9: Ohm''s Law and Potentiometers with Arduino',                                     'Ohm''s law, and turning a knob into a number.',                  'J7t338s6l1I',  9),
  ('LESSON 10: Reading Analog Voltages with Arduino',                                          'Reading analog voltages into your sketch.',                      'QsYcYknKbB0', 10),
  ('LESSON 11: Using Arduino to Create Dimmable LED',                                          'Building a dimmable LED from what you have learned.',            'afurKLOqqSg', 11),
  ('LESSON 12: Simple and Easy Way to Read Strings Floats and Ints over Arduino Serial Port',  'Reading strings, floats and ints over the serial port.',         'VIa_QZWIonQ', 12)
) as b(t, d, v, n);

commit;

-- Kontrol:
--   select audio_lang, count(*) from video_series where is_active group by 1;
--   -> tr 6, de 4, es 4, en 4
