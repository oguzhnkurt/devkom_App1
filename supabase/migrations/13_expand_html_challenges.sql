-- ============================================
-- HTML CHALLENGES EXPANSION (6-15)
-- Adding 10 new visual builder challenges
-- Total: 15 challenges, ~360 XP
-- ============================================

-- Challenge 6: Bold and Italic
INSERT INTO interactive_lessons (
  id,
  course_id,
  title,
  description,
  lesson_type,
  difficulty,
  estimated_minutes,
  xp_reward,
  lesson_order,
  challenge_config,
  success_criteria,
  hints,
  is_active
) VALUES (
  'html-006-bold-italic',
  'html',
  'Kalın ve İtalik - Metin Vurgulama',
  'strong ve em etiketlerini kullan',
  'code_challenge',
  1,
  10,
  15,
  6,
  '{
    "language": "html",
    "starterCode": "<!DOCTYPE html>\n<html>\n<body>\n\n  <p>Bu bir normal paragraf.</p>\n  \n  <!-- Kalın metin ekle (strong) -->\n  \n  \n  <!-- İtalik metin ekle (em) -->\n  \n\n</body>\n</html>",
    "instructions": [
      "<strong> ile kalın metin oluştur",
      "<em> ile italik metin oluştur",
      "Her iki tagı de ayrı satırlarda kullan",
      "Preview''da farkı gör"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "<strong>",
        "description": "strong etiketi olmalı"
      },
      {
        "type": "code_contains",
        "value": "<em>",
        "description": "em etiketi olmalı"
      },
      {
        "type": "preview_check",
        "selector": "strong",
        "description": "Kalın metin görünmeli"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainTags": ["strong", "em"],
    "livePreview": true
  }',
  '["<strong>Kalın metin</strong>", "<em>İtalik metin</em>", "<b> yerine <strong> kullan (semantic HTML)"]'::jsonb,
  true
);

-- Challenge 7: Table
INSERT INTO interactive_lessons (
  id,
  course_id,
  title,
  description,
  lesson_type,
  difficulty,
  estimated_minutes,
  xp_reward,
  lesson_order,
  challenge_config,
  success_criteria,
  hints,
  is_active
) VALUES (
  'html-007-table',
  'html',
  'Tablo Oluştur - Ders Programı',
  'table, tr, td etiketleriyle tablo',
  'code_challenge',
  2,
  15,
  20,
  7,
  '{
    "language": "html",
    "starterCode": "<!DOCTYPE html>\n<html>\n<body>\n\n  <h2>Ders Programı</h2>\n  \n  <table border=\"1\">\n    <!-- Başlık satırı (tr) -->\n    <tr>\n      <!-- Başlık hücreleri (th) -->\n      \n    </tr>\n    \n    <!-- Veri satırları (tr) -->\n    \n  </table>\n\n</body>\n</html>",
    "instructions": [
      "<table> ile tablo başlat",
      "<tr> ile satır ekle",
      "<th> ile başlık hücreleri (Pazartesi, Salı, vb.)",
      "<td> ile veri hücreleri (Matematik, Türkçe, vb.)"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "<table",
        "description": "table etiketi olmalı"
      },
      {
        "type": "code_contains",
        "value": "<tr>",
        "description": "En az 2 satır olmalı"
      },
      {
        "type": "code_contains",
        "value": "<th>",
        "description": "Başlık hücreleri olmalı"
      },
      {
        "type": "code_contains",
        "value": "<td>",
        "description": "Veri hücreleri olmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainTags": ["table", "tr", "th", "td"],
    "livePreview": true
  }',
  '["<tr> = table row (satır)", "<th> = table header (başlık)", "<td> = table data (veri)", "border=\"1\" kenarlık ekler"]'::jsonb,
  true
);

-- Challenge 8: Form Basics
INSERT INTO interactive_lessons (
  id,
  course_id,
  title,
  description,
  lesson_type,
  difficulty,
  estimated_minutes,
  xp_reward,
  lesson_order,
  challenge_config,
  success_criteria,
  hints,
  is_active
) VALUES (
  'html-008-form-basics',
  'html',
  'Form Oluştur - Giriş Formu',
  'form ve input etiketleri',
  'code_challenge',
  2,
  15,
  25,
  8,
  '{
    "language": "html",
    "starterCode": "<!DOCTYPE html>\n<html>\n<body>\n\n  <h2>Giriş Yap</h2>\n  \n  <!-- Form oluştur -->\n  <form>\n    \n    <!-- Ad input ekle -->\n    \n    \n    <!-- Şifre input ekle -->\n    \n    \n    <!-- Gönder butonu -->\n    \n  </form>\n\n</body>\n</html>",
    "instructions": [
      "<form> ile form başlat",
      "<input type=\"text\"> ile metin girişi",
      "<input type=\"password\"> ile şifre girişi",
      "<input type=\"submit\"> ile gönder butonu"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "<form",
        "description": "form etiketi olmalı"
      },
      {
        "type": "code_contains",
        "value": "type=\"text\"",
        "description": "text input olmalı"
      },
      {
        "type": "code_contains",
        "value": "type=\"password\"",
        "description": "password input olmalı"
      },
      {
        "type": "code_contains",
        "value": "type=\"submit\"",
        "description": "submit butonu olmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainTags": ["form", "input"],
    "mustHaveAttributes": {"input": ["type"]},
    "livePreview": true
  }',
  '["<form> içinde inputları yaz", "name attribute ekle: name=\"username\"", "placeholder ile ipucu: placeholder=\"Kullanıcı adı\""]'::jsonb,
  true
);

-- Challenge 9: Input Types
INSERT INTO interactive_lessons (
  id,
  course_id,
  title,
  description,
  lesson_type,
  difficulty,
  estimated_minutes,
  xp_reward,
  lesson_order,
  challenge_config,
  success_criteria,
  hints,
  is_active
) VALUES (
  'html-009-input-types',
  'html',
  'Input Tipleri - Kayıt Formu',
  'Farklı input typeları kullan',
  'code_challenge',
  2,
  15,
  25,
  9,
  '{
    "language": "html",
    "starterCode": "<!DOCTYPE html>\n<html>\n<body>\n\n  <h2>Kayıt Ol</h2>\n  \n  <form>\n    \n    <!-- Email input -->\n    <label>Email:</label>\n    \n    \n    <!-- Tel input -->\n    <label>Telefon:</label>\n    \n    \n    <!-- Date input -->\n    <label>Doğum Tarihi:</label>\n    \n    \n    <!-- Number input -->\n    <label>Yaş:</label>\n    \n    \n  </form>\n\n</body>\n</html>",
    "instructions": [
      "type=\"email\" ile email girişi",
      "type=\"tel\" ile telefon girişi",
      "type=\"date\" ile tarih seçici",
      "type=\"number\" ile sayı girişi"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "type=\"email\"",
        "description": "email input olmalı"
      },
      {
        "type": "code_contains",
        "value": "type=\"tel\"",
        "description": "tel input olmalı"
      },
      {
        "type": "code_contains",
        "value": "type=\"date\"",
        "description": "date input olmalı"
      },
      {
        "type": "code_contains",
        "value": "type=\"number\"",
        "description": "number input olmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainTags": ["input", "label"],
    "livePreview": true
  }',
  '["<label> ile etiket ekle", "<input type=\"email\"> otomatik @ kontrolü yapar", "<input type=\"date\"> tarih seçici açar"]'::jsonb,
  true
);

-- Challenge 10: Textarea and Button
INSERT INTO interactive_lessons (
  id,
  course_id,
  title,
  description,
  lesson_type,
  difficulty,
  estimated_minutes,
  xp_reward,
  lesson_order,
  challenge_config,
  success_criteria,
  hints,
  is_active
) VALUES (
  'html-010-textarea-button',
  'html',
  'Metin Alanı ve Buton - Yorum Formu',
  'textarea ve button etiketleri',
  'code_challenge',
  2,
  12,
  20,
  10,
  '{
    "language": "html",
    "starterCode": "<!DOCTYPE html>\n<html>\n<body>\n\n  <h2>Yorum Yap</h2>\n  \n  <form>\n    \n    <label>Yorumunuz:</label><br>\n    <!-- Textarea ekle -->\n    \n    \n    <br><br>\n    \n    <!-- Button ekle -->\n    \n  </form>\n\n</body>\n</html>",
    "instructions": [
      "<textarea> ile çok satırlı metin alanı",
      "rows=\"5\" cols=\"30\" ile boyutlandır",
      "<button> ile buton ekle",
      "Buton içine metin yaz"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "<textarea",
        "description": "textarea etiketi olmalı"
      },
      {
        "type": "code_contains",
        "value": "rows",
        "description": "rows attribute olmalı"
      },
      {
        "type": "code_contains",
        "value": "<button",
        "description": "button etiketi olmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainTags": ["textarea", "button"],
    "livePreview": true
  }',
  '["<textarea rows=\"5\" cols=\"30\"></textarea>", "<button>Gönder</button>", "<button> kapanış etiketi gerektirir"]'::jsonb,
  true
);

-- Challenge 11: Select Dropdown
INSERT INTO interactive_lessons (
  id,
  course_id,
  title,
  description,
  lesson_type,
  difficulty,
  estimated_minutes,
  xp_reward,
  lesson_order,
  challenge_config,
  success_criteria,
  hints,
  is_active
) VALUES (
  'html-011-select-dropdown',
  'html',
  'Açılır Liste - Şehir Seçimi',
  'select ve option etiketleri',
  'code_challenge',
  2,
  15,
  25,
  11,
  '{
    "language": "html",
    "starterCode": "<!DOCTYPE html>\n<html>\n<body>\n\n  <h2>Şehir Seç</h2>\n  \n  <form>\n    <label>Şehir:</label>\n    \n    <!-- Select dropdown oluştur -->\n    <select name=\"sehir\">\n      <!-- Option''ları ekle -->\n      \n    </select>\n    \n  </form>\n\n</body>\n</html>",
    "instructions": [
      "<select> ile dropdown başlat",
      "<option> ile seçenekler ekle",
      "En az 5 şehir ekle",
      "selected ile varsayılan seç"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "<select",
        "description": "select etiketi olmalı"
      },
      {
        "type": "code_contains",
        "value": "<option",
        "description": "En az 3 option olmalı"
      },
      {
        "type": "preview_check",
        "selector": "select",
        "description": "Dropdown görünmeli"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainTags": ["select", "option"],
    "livePreview": true
  }',
  '["<option value=\"ankara\">Ankara</option>", "selected ile varsayılan: <option selected>", "name attribute ile form gönderiminde kullanılır"]'::jsonb,
  true
);

-- Challenge 12: Div and Span
INSERT INTO interactive_lessons (
  id,
  course_id,
  title,
  description,
  lesson_type,
  difficulty,
  estimated_minutes,
  xp_reward,
  lesson_order,
  challenge_config,
  success_criteria,
  hints,
  is_active
) VALUES (
  'html-012-div-span',
  'html',
  'Containerlar - Div ve Span',
  'div ve span ile içerik gruplama',
  'code_challenge',
  2,
  15,
  25,
  12,
  '{
    "language": "html",
    "starterCode": "<!DOCTYPE html>\n<html>\n<body>\n\n  <!-- Div ile bölüm oluştur -->\n  <div style=\"border: 1px solid black; padding: 10px;\">\n    <h3>Bölüm Başlığı</h3>\n    \n    <!-- Span ile metin vurgula -->\n    <p>Bu bir paragraf. <span style=\"color: red;\">Bu kırmızı</span> olmalı.</p>\n  </div>\n  \n  <!-- İkinci div -->\n  \n\n</body>\n</html>",
    "instructions": [
      "<div> block-level container (yeni satır)",
      "<span> inline container (satır içi)",
      "2 ayrı div bölümü oluştur",
      "Her div''de h3 ve p olsun"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "<div",
        "description": "En az 2 div olmalı"
      },
      {
        "type": "code_contains",
        "value": "<span",
        "description": "span etiketi olmalı"
      },
      {
        "type": "preview_check",
        "selector": "div",
        "description": "Divler görünmeli"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainTags": ["div", "span"],
    "livePreview": true
  }',
  '["<div> yeni satırda başlar (block)", "<span> satır içinde kalır (inline)", "style attribute ile basit CSS eklenebilir"]'::jsonb,
  true
);

-- Challenge 13: Semantic HTML
INSERT INTO interactive_lessons (
  id,
  course_id,
  title,
  description,
  lesson_type,
  difficulty,
  estimated_minutes,
  xp_reward,
  lesson_order,
  challenge_config,
  success_criteria,
  hints,
  is_active
) VALUES (
  'html-013-semantic-html',
  'html',
  'Semantic HTML - Sayfa Yapısı',
  'header, nav, main, footer kullan',
  'code_challenge',
  3,
  20,
  30,
  13,
  '{
    "language": "html",
    "starterCode": "<!DOCTYPE html>\n<html>\n<body>\n\n  <!-- Header bölümü -->\n  <header>\n    <h1>Site Başlığı</h1>\n  </header>\n  \n  <!-- Navigation menü -->\n  <nav>\n    <!-- Link listesi ekle -->\n  </nav>\n  \n  <!-- Ana içerik -->\n  <main>\n    <!-- Article veya section ekle -->\n  </main>\n  \n  <!-- Footer -->\n  <footer>\n    <!-- Copyright bilgisi -->\n  </footer>\n\n</body>\n</html>",
    "instructions": [
      "<header> ile sayfa başlığı",
      "<nav> ile navigasyon menüsü",
      "<main> ile ana içerik",
      "<footer> ile alt bilgi",
      "<article> veya <section> ile bölümler"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "<header",
        "description": "header etiketi olmalı"
      },
      {
        "type": "code_contains",
        "value": "<nav",
        "description": "nav etiketi olmalı"
      },
      {
        "type": "code_contains",
        "value": "<main",
        "description": "main etiketi olmalı"
      },
      {
        "type": "code_contains",
        "value": "<footer",
        "description": "footer etiketi olmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainTags": ["header", "nav", "main", "footer"],
    "livePreview": true
  }',
  '["Semantic HTML = Anlamlı HTML", "SEO ve accessibility için önemli", "<div> yerine anlamlı taglar kullan"]'::jsonb,
  true
);

-- Challenge 14: Video Embed
INSERT INTO interactive_lessons (
  id,
  course_id,
  title,
  description,
  lesson_type,
  difficulty,
  estimated_minutes,
  xp_reward,
  lesson_order,
  challenge_config,
  success_criteria,
  hints,
  is_active
) VALUES (
  'html-014-video-embed',
  'html',
  'Video Gömme - HTML5 Video',
  'video etiketi ile video ekleme',
  'code_challenge',
  2,
  15,
  25,
  14,
  '{
    "language": "html",
    "starterCode": "<!DOCTYPE html>\n<html>\n<body>\n\n  <h2>Video Oynatıcı</h2>\n  \n  <!-- Video ekle -->\n  <video controls width=\"400\">\n    <source src=\"video.mp4\" type=\"video/mp4\">\n    <!-- Tarayıcı desteklemezse mesaj -->\n    \n  </video>\n  \n  <br><br>\n  \n  <!-- YouTube embed (iframe) -->\n  \n\n</body>\n</html>",
    "instructions": [
      "<video> ile video player oluştur",
      "controls attribute ile kontrolleri göster",
      "<source> ile video dosyası belirt",
      "Fallback mesajı ekle"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "<video",
        "description": "video etiketi olmalı"
      },
      {
        "type": "code_contains",
        "value": "controls",
        "description": "controls attribute olmalı"
      },
      {
        "type": "code_contains",
        "value": "<source",
        "description": "source etiketi olmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainTags": ["video", "source"],
    "livePreview": true
  }',
  '["controls ile play/pause butonları görünür", "width ve height ile boyutlandır", "<source> ile farklı formatlar eklenebilir"]'::jsonb,
  true
);

-- Challenge 15: Mini Webpage Project
INSERT INTO interactive_lessons (
  id,
  course_id,
  title,
  description,
  lesson_type,
  difficulty,
  estimated_minutes,
  xp_reward,
  lesson_order,
  challenge_config,
  success_criteria,
  hints,
  is_active
) VALUES (
  'html-015-mini-webpage',
  'html',
  'Mini Web Sayfası - Portfolio',
  'Tüm bilgilerini kullanarak sayfa yap',
  'code_challenge',
  3,
  25,
  35,
  15,
  '{
    "language": "html",
    "starterCode": "<!DOCTYPE html>\n<html>\n<head>\n  <title>Benim Portfolyom</title>\n</head>\n<body>\n\n  <!-- Header: Adın ve mesleğin -->\n  \n  \n  <!-- Nav: Ana Sayfa, Hakkımda, İletişim -->\n  \n  \n  <!-- Main: Hakkımda bölümü -->\n  \n  \n  <!-- Projeler bölümü (liste) -->\n  \n  \n  <!-- İletişim formu -->\n  \n  \n  <!-- Footer: Copyright -->\n  \n\n</body>\n</html>",
    "instructions": [
      "header, nav, main, footer kullan",
      "h1 ile isim, p ile açıklama",
      "ul ile proje listesi",
      "form ile iletişim formu",
      "Minimum 30 satır kod"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "<header",
        "description": "header olmalı"
      },
      {
        "type": "code_contains",
        "value": "<nav",
        "description": "nav olmalı"
      },
      {
        "type": "code_contains",
        "value": "<form",
        "description": "form olmalı"
      },
      {
        "type": "code_contains",
        "value": "<ul",
        "description": "liste olmalı"
      },
      {
        "type": "line_count_min",
        "value": 30,
        "description": "En az 30 satır olmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainTags": ["header", "nav", "main", "form", "ul", "footer"],
    "livePreview": true,
    "isProject": true
  }',
  '["Tüm semantic tagları kullan", "Form: name, email, message", "Öğrendiğin her şeyi birleştir"]'::jsonb,
  true
);

-- ============================================
-- HTML EXPANSION SUMMARY
-- ============================================
-- Added: 10 new challenges (#6-15)
-- Total HTML challenges: 15
-- New XP: 265 XP
-- Total HTML XP: 360 XP
-- Difficulty range: 1-3 (Kolay → Zor)
-- Topics: Text formatting, Tables, Forms, Semantic HTML, Media
-- ============================================
