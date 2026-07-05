-- =============================================
-- HTML/CSS INTERACTIVE CHALLENGES
-- =============================================
-- Visual builder style interactive lessons

BEGIN;

-- =============================================
-- HTML CHALLENGES
-- =============================================

INSERT INTO interactive_lessons (
  id, course_id, title, description, lesson_order, lesson_type,
  challenge_config, workspace_config, success_criteria, solution_code, hints,
  xp_reward, estimated_minutes, difficulty, tags, prerequisites, is_active
) VALUES

-- HTML Challenge 1: First HTML Page
('html_challenge_01', 'html', 'İlk HTML Sayfan', 'Basit bir HTML sayfası oluştur', 1, 'code_challenge',
'{
  "instructions": [
    "<!DOCTYPE html> ile başla",
    "<html> etiketi ekle",
    "<body> içinde <h1>Merhaba</h1> yaz"
  ],
  "starterCode": "<!DOCTYPE html>\n<html>\n<body>\n  <!-- Buraya kod yaz -->\n</body>\n</html>",
  "testCases": [
    {"type": "contains_tag", "value": "h1", "description": "h1 etiketi olmalı"},
    {"type": "output_contains", "value": "Merhaba", "description": "Merhaba yazısı görünmeli"}
  ]
}',
'{
  "language": "html",
  "theme": "light",
  "showPreview": true,
  "previewType": "iframe",
  "runnable": true
}',
'{
  "mustContain": ["<h1>", "</h1>"],
  "passingTests": 2
}',
'<!DOCTYPE html>\n<html>\n<body>\n  <h1>Merhaba</h1>\n</body>\n</html>',
'["İpucu 1: <h1> etiketi kullan", "İpucu 2: Açılış ve kapanış etiketini unutma"]',
15, 10, 1, ARRAY['html', 'basics', 'heading'], ARRAY[]::TEXT[], true),

-- HTML Challenge 2: Paragraphs
('html_challenge_02', 'html', 'Paragraf Ekle', '<p> etiketi ile paragraf oluştur', 2, 'code_challenge',
'{
  "instructions": [
    "Bir <h1> başlık ekle",
    "İki adet <p> paragraf ekle",
    "Paragrafların farklı içerikleri olsun"
  ],
  "starterCode": "<!DOCTYPE html>\n<html>\n<body>\n  <h1>Baslik</h1>\n  <!-- Paragrafları buraya ekle -->\n</body>\n</html>",
  "testCases": [
    {"type": "tag_count", "value": "p", "min": 2, "description": "En az 2 paragraf olmalı"},
    {"type": "output_not_empty", "description": "Sayfa boş olmamalı"}
  ]
}',
'{
  "language": "html",
  "showPreview": true,
  "previewType": "iframe"
}',
'{
  "mustContain": ["<p>", "</p>"],
  "passingTests": 2
}',
'<!DOCTYPE html>\n<html>\n<body>\n  <h1>Baslik</h1>\n  <p>Bu birinci paragraf.</p>\n  <p>Bu ikinci paragraf.</p>\n</body>\n</html>',
'["İpucu 1: <p> etiketi kullan", "İpucu 2: Her paragraf için ayrı <p> etiketi"]',
15, 10, 1, ARRAY['html', 'paragraph', 'p-tag'], ARRAY['html_challenge_01'], true),

-- HTML Challenge 3: Links
('html_challenge_03', 'html', 'Bağlantı Ekle', '<a> etiketi ile link oluştur', 3, 'code_challenge',
'{
  "instructions": [
    "<a> etiketi kullan",
    "href ile Google''a link ver",
    "Link metni \"Google''a Git\" olsun"
  ],
  "starterCode": "<!DOCTYPE html>\n<html>\n<body>\n  <h1>Linkler</h1>\n  <!-- Link buraya -->\n</body>\n</html>",
  "testCases": [
    {"type": "contains_tag", "value": "a", "description": "a etiketi olmalı"},
    {"type": "has_attribute", "tag": "a", "attr": "href", "description": "href özelliği olmalı"}
  ]
}',
'{
  "language": "html",
  "showPreview": true,
  "previewType": "iframe"
}',
'{
  "mustContain": ["<a", "href=", "</a>"],
  "passingTests": 2
}',
'<!DOCTYPE html>\n<html>\n<body>\n  <h1>Linkler</h1>\n  <a href="https://google.com">Google''a Git</a>\n</body>\n</html>',
'["İpucu 1: <a href=\"url\">metin</a> formatı", "İpucu 2: href içine URL yaz"]',
20, 12, 1, ARRAY['html', 'link', 'a-tag', 'href'], ARRAY['html_challenge_02'], true),

-- HTML Challenge 4: Image
('html_challenge_04', 'html', 'Resim Ekle', '<img> etiketi kullan', 4, 'code_challenge',
'{
  "instructions": [
    "<img> etiketi ekle",
    "src ile resim URL''si ver",
    "alt metni ekle"
  ],
  "starterCode": "<!DOCTYPE html>\n<html>\n<body>\n  <h1>Resimler</h1>\n  <!-- img etiketi buraya -->\n</body>\n</html>",
  "testCases": [
    {"type": "contains_tag", "value": "img", "description": "img etiketi olmalı"},
    {"type": "has_attribute", "tag": "img", "attr": "src", "description": "src olmalı"},
    {"type": "has_attribute", "tag": "img", "attr": "alt", "description": "alt olmalı"}
  ]
}',
'{
  "language": "html",
  "showPreview": true,
  "previewType": "iframe"
}',
'{
  "mustContain": ["<img", "src=", "alt="],
  "passingTests": 3
}',
'<!DOCTYPE html>\n<html>\n<body>\n  <h1>Resimler</h1>\n  <img src="https://via.placeholder.com/150" alt="Ornek resim">\n</body>\n</html>',
'["İpucu 1: <img src=\"url\" alt=\"aciklama\">", "İpucu 2: img etiketi self-closing (kapanışsız)"]',
20, 12, 1, ARRAY['html', 'image', 'img-tag'], ARRAY['html_challenge_03'], true),

-- HTML Challenge 5: List
('html_challenge_05', 'html', 'Liste Oluştur', '<ul> ve <li> kullan', 5, 'code_challenge',
'{
  "instructions": [
    "<ul> ile sırasız liste oluştur",
    "3 adet <li> ekle",
    "Her li farklı meyve ismi içersin"
  ],
  "starterCode": "<!DOCTYPE html>\n<html>\n<body>\n  <h1>Meyveler</h1>\n  <!-- Liste buraya -->\n</body>\n</html>",
  "testCases": [
    {"type": "contains_tag", "value": "ul", "description": "ul olmalı"},
    {"type": "tag_count", "value": "li", "min": 3, "description": "En az 3 li olmalı"}
  ]
}',
'{
  "language": "html",
  "showPreview": true,
  "previewType": "iframe"
}',
'{
  "mustContain": ["<ul>", "<li>", "</ul>", "</li>"],
  "passingTests": 2
}',
'<!DOCTYPE html>\n<html>\n<body>\n  <h1>Meyveler</h1>\n  <ul>\n    <li>Elma</li>\n    <li>Armut</li>\n    <li>Muz</li>\n  </ul>\n</body>\n</html>',
'["İpucu 1: <ul> içinde <li> kullan", "İpucu 2: Her meyve için ayrı <li>"]',
25, 15, 2, ARRAY['html', 'list', 'ul', 'li'], ARRAY['html_challenge_04'], true),

-- =============================================
-- CSS CHALLENGES
-- =============================================

-- CSS Challenge 1: Text Color
('css_challenge_01', 'css', 'Yazı Rengini Değiştir', 'color özelliğini kullan', 1, 'code_challenge',
'{
  "instructions": [
    "h1 etiketini seç",
    "color: blue; ekle",
    "Başlık mavi olmalı"
  ],
  "starterCode": "<!DOCTYPE html>\n<html>\n<head>\n<style>\n  /* CSS buraya */\n  h1 {\n    \n  }\n</style>\n</head>\n<body>\n  <h1>Merhaba</h1>\n  <p>Bu bir paragraf</p>\n</body>\n</html>",
  "testCases": [
    {"type": "css_property", "selector": "h1", "property": "color", "description": "h1 rengi tanımlanmalı"}
  ]
}',
'{
  "language": "html",
  "showPreview": true,
  "previewType": "iframe",
  "highlightCSS": true
}',
'{
  "mustContain": ["color:", "blue"],
  "passingTests": 1
}',
'<style>\n  h1 {\n    color: blue;\n  }\n</style>',
'["İpucu 1: h1 { } içinde yaz", "İpucu 2: color: blue;"]',
15, 8, 1, ARRAY['css', 'color', 'styling'], ARRAY[]::TEXT[], true),

-- CSS Challenge 2: Background
('css_challenge_02', 'css', 'Arka Plan Rengi', 'background-color kullan', 2, 'code_challenge',
'{
  "instructions": [
    "body seç",
    "background-color: lightblue; ekle",
    "Sayfa arka planı açık mavi olmalı"
  ],
  "starterCode": "<!DOCTYPE html>\n<html>\n<head>\n<style>\n  body {\n    /* Arka plan rengini buraya */\n  }\n</style>\n</head>\n<body>\n  <h1>Renkli Sayfa</h1>\n</body>\n</html>",
  "testCases": [
    {"type": "css_property", "selector": "body", "property": "background-color", "description": "body arka planı olmalı"}
  ]
}',
'{
  "language": "html",
  "showPreview": true,
  "previewType": "iframe"
}',
'{
  "mustContain": ["background-color:", "lightblue"],
  "passingTests": 1
}',
'<style>\n  body {\n    background-color: lightblue;\n  }\n</style>',
'["İpucu 1: background-color özelliği", "İpucu 2: lightblue veya başka renk"]',
15, 8, 1, ARRAY['css', 'background', 'background-color'], ARRAY['css_challenge_01'], true),

-- CSS Challenge 3: Font Size
('css_challenge_03', 'css', 'Yazı Boyutu', 'font-size özelliği', 3, 'code_challenge',
'{
  "instructions": [
    "h1 için font-size: 48px;",
    "p için font-size: 18px;",
    "Farklı boyutlar görünmeli"
  ],
  "starterCode": "<!DOCTYPE html>\n<html>\n<head>\n<style>\n  h1 {\n    /* Büyük font */\n  }\n  \n  p {\n    /* Normal font */\n  }\n</style>\n</head>\n<body>\n  <h1>Buyuk Baslik</h1>\n  <p>Normal paragraf</p>\n</body>\n</html>",
  "testCases": [
    {"type": "css_property", "selector": "h1", "property": "font-size", "description": "h1 font boyutu olmalı"},
    {"type": "css_property", "selector": "p", "property": "font-size", "description": "p font boyutu olmalı"}
  ]
}',
'{
  "language": "html",
  "showPreview": true,
  "previewType": "iframe"
}',
'{
  "mustContain": ["font-size:", "px"],
  "passingTests": 2
}',
'<style>\n  h1 {\n    font-size: 48px;\n  }\n  p {\n    font-size: 18px;\n  }\n</style>',
'["İpucu 1: font-size: 48px;", "İpucu 2: İki farklı seçici için ayrı tanımla"]',
20, 10, 1, ARRAY['css', 'font-size', 'typography'], ARRAY['css_challenge_02'], true),

-- CSS Challenge 4: Text Align
('css_challenge_04', 'css', 'Metni Ortala', 'text-align: center kullan', 4, 'code_challenge',
'{
  "instructions": [
    "h1''i ortala (text-align: center)",
    "p''yi sağa hizala (text-align: right)"
  ],
  "starterCode": "<!DOCTYPE html>\n<html>\n<head>\n<style>\n  h1 {\n    /* Ortaya hizala */\n  }\n  \n  p {\n    /* Sağa hizala */\n  }\n</style>\n</head>\n<body>\n  <h1>Ortalanmis Baslik</h1>\n  <p>Saga hizalanmis paragraf</p>\n</body>\n</html>",
  "testCases": [
    {"type": "css_property", "selector": "h1", "property": "text-align", "value": "center"},
    {"type": "css_property", "selector": "p", "property": "text-align", "value": "right"}
  ]
}',
'{
  "language": "html",
  "showPreview": true,
  "previewType": "iframe"
}',
'{
  "mustContain": ["text-align:", "center", "right"],
  "passingTests": 2
}',
'<style>\n  h1 {\n    text-align: center;\n  }\n  p {\n    text-align: right;\n  }\n</style>',
'["İpucu 1: text-align: center;", "İpucu 2: text-align: right;"]',
20, 10, 1, ARRAY['css', 'text-align', 'alignment'], ARRAY['css_challenge_03'], true),

-- CSS Challenge 5: Padding & Margin
('css_challenge_05', 'css', 'Boşluk Ekle', 'padding ve margin kullan', 5, 'code_challenge',
'{
  "instructions": [
    "div oluştur",
    "padding: 20px; ekle (iç boşluk)",
    "margin: 10px; ekle (dış boşluk)",
    "background-color ile renklendir"
  ],
  "starterCode": "<!DOCTYPE html>\n<html>\n<head>\n<style>\n  div {\n    /* Stilleri buraya */\n    background-color: lightcoral;\n  }\n</style>\n</head>\n<body>\n  <div>Kutulu Metin</div>\n  <div>Kutulu Metin 2</div>\n</body>\n</html>",
  "testCases": [
    {"type": "css_property", "selector": "div", "property": "padding", "description": "padding olmalı"},
    {"type": "css_property", "selector": "div", "property": "margin", "description": "margin olmalı"}
  ]
}',
'{
  "language": "html",
  "showPreview": true,
  "previewType": "iframe"
}',
'{
  "mustContain": ["padding:", "margin:"],
  "passingTests": 2
}',
'<style>\n  div {\n    padding: 20px;\n    margin: 10px;\n    background-color: lightcoral;\n  }\n</style>',
'["İpucu 1: padding: 20px; (iç boşluk)", "İpucu 2: margin: 10px; (dış boşluk)"]',
25, 15, 2, ARRAY['css', 'padding', 'margin', 'box-model'], ARRAY['css_challenge_04'], true);

COMMIT;

-- =============================================
-- VERIFY INSERTION
-- =============================================
SELECT
  course_id,
  COUNT(*) as challenge_count,
  SUM(xp_reward) as total_xp
FROM interactive_lessons
WHERE course_id IN ('html', 'css')
GROUP BY course_id;
