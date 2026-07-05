-- ============================================
-- CSS CHALLENGES EXPANSION (6-15)
-- Adding 10 new styling challenges
-- Total: 15 challenges, ~370 XP
-- ============================================

-- Challenge 6: Border Styling
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
  'css-006-border-styling',
  'css',
  'Kenarlık Stilleri - Border',
  'border width, style, color özellikleri',
  'code_challenge',
  1,
  10,
  15,
  6,
  '{
    "language": "css",
    "htmlContext": "<div class=\"box\">Kutulu Metin</div>",
    "starterCode": ".box {\n  width: 200px;\n  height: 100px;\n  \n  /* Kenarlık ekle */\n  \n}",
    "instructions": [
      "border-width: 3px;",
      "border-style: solid;",
      "border-color: blue;",
      "Veya kısa yol: border: 3px solid blue;"
    ],
    "testCases": [
      {
        "type": "css_property",
        "selector": ".box",
        "property": "border",
        "description": "Border özelliği olmalı"
      },
      {
        "type": "preview_check",
        "selector": ".box",
        "hasStyle": "border",
        "description": "Kenarlık görünmeli"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustHaveProperties": ["border"],
    "livePreview": true
  }',
  '["border: genişlik stil renk;", "border-style: solid, dashed, dotted", "border-radius ile yuvarlak köşeler"]'::jsonb,
  true
);

-- Challenge 7: Box Model
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
  'css-007-box-model',
  'css',
  'Box Model - Kutu Modeli',
  'margin, padding, border ilişkisi',
  'code_challenge',
  2,
  15,
  25,
  7,
  '{
    "language": "css",
    "htmlContext": "<div class=\"card\">Kart İçeriği</div>",
    "starterCode": ".card {\n  width: 250px;\n  background: lightblue;\n  \n  /* Padding ekle (içten boşluk) */\n  \n  \n  /* Border ekle */\n  \n  \n  /* Margin ekle (dıştan boşluk) */\n  \n}",
    "instructions": [
      "padding: 20px; ile içten boşluk",
      "border: 2px solid navy; ile kenarlık",
      "margin: 30px; ile dıştan boşluk",
      "Preview''da farkı gör"
    ],
    "testCases": [
      {
        "type": "css_property",
        "selector": ".card",
        "property": "padding",
        "description": "Padding olmalı"
      },
      {
        "type": "css_property",
        "selector": ".card",
        "property": "margin",
        "description": "Margin olmalı"
      },
      {
        "type": "css_property",
        "selector": ".card",
        "property": "border",
        "description": "Border olmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustHaveProperties": ["padding", "margin", "border"],
    "livePreview": true
  }',
  '["Padding = İçten boşluk", "Margin = Dıştan boşluk", "Border = Kenarlık (ikisinin arasında)", "Box Model: margin > border > padding > content"]'::jsonb,
  true
);

-- Challenge 8: Flexbox Basics
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
  'css-008-flexbox-basics',
  'css',
  'Flexbox Temelleri - Yan Yana Dizme',
  'display: flex ile layout',
  'code_challenge',
  3,
  18,
  30,
  8,
  '{
    "language": "css",
    "htmlContext": "<div class=\"container\">\n  <div class=\"item\">1</div>\n  <div class=\"item\">2</div>\n  <div class=\"item\">3</div>\n</div>",
    "starterCode": ".container {\n  /* Flexbox aç */\n  \n}\n\n.item {\n  width: 100px;\n  height: 100px;\n  background: coral;\n  margin: 10px;\n}",
    "instructions": [
      "display: flex; ile container''ı flex yap",
      "Itemlar otomatik yan yana dizilir",
      "flex-direction: row; (varsayılan)",
      "Preview''da yan yana görün"
    ],
    "testCases": [
      {
        "type": "css_property",
        "selector": ".container",
        "property": "display",
        "value": "flex",
        "description": "display: flex olmalı"
      },
      {
        "type": "preview_check",
        "selector": ".container",
        "layout": "horizontal",
        "description": "Itemlar yan yana olmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustHaveProperties": ["display"],
    "propertyValues": {"display": ["flex"]},
    "livePreview": true
  }',
  '["display: flex; en önemli property", "flex-direction: row (yatay) veya column (dikey)", "Container''a uygulanır, children etkilenir"]'::jsonb,
  true
);

-- Challenge 9: Flexbox Layout
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
  'css-009-flexbox-layout',
  'css',
  'Flexbox Hizalama - Justify & Align',
  'justify-content ve align-items',
  'code_challenge',
  3,
  20,
  30,
  9,
  '{
    "language": "css",
    "htmlContext": "<div class=\"container\">\n  <div class=\"box\">A</div>\n  <div class=\"box\">B</div>\n  <div class=\"box\">C</div>\n</div>",
    "starterCode": ".container {\n  display: flex;\n  height: 300px;\n  background: lightgray;\n  \n  /* Yatay hizalama */\n  \n  \n  /* Dikey hizalama */\n  \n}\n\n.box {\n  width: 80px;\n  height: 80px;\n  background: teal;\n  color: white;\n  font-size: 24px;\n  text-align: center;\n  line-height: 80px;\n}",
    "instructions": [
      "justify-content: center; (yatay ortala)",
      "align-items: center; (dikey ortala)",
      "Preview''da tam ortada görün",
      "Diğer değerler: flex-start, flex-end, space-between"
    ],
    "testCases": [
      {
        "type": "css_property",
        "selector": ".container",
        "property": "justify-content",
        "description": "justify-content olmalı"
      },
      {
        "type": "css_property",
        "selector": ".container",
        "property": "align-items",
        "description": "align-items olmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustHaveProperties": ["display", "justify-content", "align-items"],
    "livePreview": true
  }',
  '["justify-content = Ana eksen (yatay)", "align-items = Çapraz eksen (dikey)", "space-between = Aralarına eşit boşluk", "space-around = Etrafına eşit boşluk"]'::jsonb,
  true
);

-- Challenge 10: Grid Basics
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
  'css-010-grid-basics',
  'css',
  'CSS Grid - Izgara Düzeni',
  'display: grid ile 2D layout',
  'code_challenge',
  3,
  22,
  35,
  10,
  '{
    "language": "css",
    "htmlContext": "<div class=\"grid\">\n  <div class=\"item\">1</div>\n  <div class=\"item\">2</div>\n  <div class=\"item\">3</div>\n  <div class=\"item\">4</div>\n  <div class=\"item\">5</div>\n  <div class=\"item\">6</div>\n</div>",
    "starterCode": ".grid {\n  /* Grid aç */\n  \n  \n  /* 3 sütun oluştur */\n  \n  \n  /* Aralarına boşluk */\n  \n}\n\n.item {\n  background: mediumpurple;\n  padding: 20px;\n  text-align: center;\n  color: white;\n}",
    "instructions": [
      "display: grid;",
      "grid-template-columns: 1fr 1fr 1fr; (3 eşit sütun)",
      "gap: 10px; (aralarına boşluk)",
      "Preview''da 3x2 grid görün"
    ],
    "testCases": [
      {
        "type": "css_property",
        "selector": ".grid",
        "property": "display",
        "value": "grid",
        "description": "display: grid olmalı"
      },
      {
        "type": "css_property",
        "selector": ".grid",
        "property": "grid-template-columns",
        "description": "grid-template-columns olmalı"
      },
      {
        "type": "css_property",
        "selector": ".grid",
        "property": "gap",
        "description": "gap olmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustHaveProperties": ["display", "grid-template-columns", "gap"],
    "livePreview": true
  }',
  '["1fr = 1 fractional unit (eşit pay)", "grid-template-columns: 200px 1fr; (sabit+esnek)", "gap = grid-gap (eski adı)", "Grid 2D, Flexbox 1D layoutlar için"]'::jsonb,
  true
);

-- Challenge 11: Hover Effects
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
  'css-011-hover-effects',
  'css',
  'Hover Efektleri - İnteraktif Buton',
  ':hover pseudo-class kullanımı',
  'code_challenge',
  2,
  15,
  20,
  11,
  '{
    "language": "css",
    "htmlContext": "<button class=\"btn\">Üzerime Gel</button>",
    "starterCode": ".btn {\n  padding: 15px 30px;\n  font-size: 16px;\n  background: dodgerblue;\n  color: white;\n  border: none;\n  cursor: pointer;\n  transition: all 0.3s;\n}\n\n/* Hover durumu */\n.btn:hover {\n  /* Hover''da değişiklikler */\n  \n}",
    "instructions": [
      ":hover ile fare üstüne gelince değişim",
      "background: darkblue; (renk değişimi)",
      "transform: scale(1.1); (büyütme)",
      "transition: all 0.3s; ile smooth geçiş"
    ],
    "testCases": [
      {
        "type": "css_selector_exists",
        "selector": ".btn:hover",
        "description": ":hover selector olmalı"
      },
      {
        "type": "css_property",
        "selector": ".btn:hover",
        "property": "background",
        "description": "Hover''da background değişmeli"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustHaveSelectors": [".btn:hover"],
    "livePreview": true
  }',
  '[":hover = Fare üstüne gelince", "transition ile smooth animasyon", "transform: scale, rotate, translate", "cursor: pointer ile fare işareti değişir"]'::jsonb,
  true
);

-- Challenge 12: Classes and IDs
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
  'css-012-classes-ids',
  'css',
  'Class ve ID Seçiciler',
  '.class ve #id farkı',
  'code_challenge',
  2,
  15,
  20,
  12,
  '{
    "language": "css",
    "htmlContext": "<div id=\"header\">Başlık</div>\n<p class=\"text\">Paragraf 1</p>\n<p class=\"text\">Paragraf 2</p>\n<p class=\"text highlight\">Paragraf 3</p>",
    "starterCode": "/* ID seçici (tek eleman) */\n#header {\n  /* Stil ekle */\n}\n\n/* Class seçici (çoklu eleman) */\n.text {\n  /* Stil ekle */\n}\n\n/* Çoklu class */\n.text.highlight {\n  /* Özel stil */\n}",
    "instructions": [
      "#id ile tek elemana stil",
      ".class ile çoklu elemana stil",
      ".class1.class2 ile her ikisine sahip olanlar",
      "ID specificity > Class specificity"
    ],
    "testCases": [
      {
        "type": "css_selector_exists",
        "selector": "#header",
        "description": "#id seçici olmalı"
      },
      {
        "type": "css_selector_exists",
        "selector": ".text",
        "description": ".class seçici olmalı"
      },
      {
        "type": "css_selector_exists",
        "selector": ".text.highlight",
        "description": "Çoklu class seçici olmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustHaveSelectors": ["#header", ".text", ".text.highlight"],
    "livePreview": true
  }',
  '["# = ID (tek kullanım)", ". = Class (çoklu kullanım)", "ID bir sayfada bir kez, class çokça kullanılır", "Specificity: inline > #id > .class > tag"]'::jsonb,
  true
);

-- Challenge 13: Responsive Design
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
  'css-013-responsive-design',
  'css',
  'Responsive Tasarım - Media Queries',
  '@media ile ekran boyutuna göre stil',
  'code_challenge',
  4,
  25,
  35,
  13,
  '{
    "language": "css",
    "htmlContext": "<div class=\"container\">\n  <div class=\"box\">1</div>\n  <div class=\"box\">2</div>\n  <div class=\"box\">3</div>\n</div>",
    "starterCode": ".container {\n  display: grid;\n  grid-template-columns: 1fr 1fr 1fr;\n  gap: 20px;\n}\n\n.box {\n  background: crimson;\n  padding: 40px;\n  color: white;\n  text-align: center;\n}\n\n/* Tablet (max-width: 768px) */\n@media (max-width: 768px) {\n  .container {\n    /* 2 sütun yap */\n  }\n}\n\n/* Mobil (max-width: 480px) */\n@media (max-width: 480px) {\n  .container {\n    /* 1 sütun yap */\n  }\n}",
    "instructions": [
      "@media (max-width: 768px) ile tablet",
      "grid-template-columns: 1fr 1fr; (2 sütun)",
      "@media (max-width: 480px) ile mobil",
      "grid-template-columns: 1fr; (1 sütun)"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "@media",
        "description": "Media query olmalı"
      },
      {
        "type": "css_media_query",
        "query": "max-width: 768px",
        "description": "Tablet breakpoint olmalı"
      },
      {
        "type": "css_media_query",
        "query": "max-width: 480px",
        "description": "Mobil breakpoint olmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustHaveMediaQueries": true,
    "livePreview": true,
    "responsivePreview": true
  }',
  '["max-width = Bu genişlikten küçükse", "Breakpoints: 1200px (desktop), 768px (tablet), 480px (mobile)", "Mobile-first approach: min-width ile başla", "Preview''u küçült-büyüt, değişimi gör"]'::jsonb,
  true
);

-- Challenge 14: Animations
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
  'css-014-animations',
  'css',
  'CSS Animasyonları - @keyframes',
  'Keyframe animasyonları oluştur',
  'code_challenge',
  3,
  20,
  30,
  14,
  '{
    "language": "css",
    "htmlContext": "<div class=\"spinner\"></div>",
    "starterCode": ".spinner {\n  width: 50px;\n  height: 50px;\n  background: orangered;\n  border-radius: 50%;\n  \n  /* Animasyon uygula */\n  animation: spin 2s linear infinite;\n}\n\n/* Keyframe tanımla */\n@keyframes spin {\n  /* Başlangıç */\n  from {\n    \n  }\n  \n  /* Bitiş */\n  to {\n    \n  }\n}",
    "instructions": [
      "@keyframes spin tanımla",
      "from { transform: rotate(0deg); }",
      "to { transform: rotate(360deg); }",
      "animation: name duration timing-function iteration;"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "@keyframes",
        "description": "@keyframes olmalı"
      },
      {
        "type": "css_property",
        "selector": ".spinner",
        "property": "animation",
        "description": "animation property olmalı"
      },
      {
        "type": "code_contains",
        "value": "rotate",
        "description": "rotate transform olmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustHaveKeyframes": true,
    "mustHaveProperties": ["animation"],
    "livePreview": true
  }',
  '["@keyframes ile animasyon adı ver", "from-to veya 0%-100% kullan", "animation: name 2s ease-in-out infinite;", "timing-function: linear, ease, ease-in-out"]'::jsonb,
  true
);

-- Challenge 15: Mini Project - Styled Card
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
  'css-015-styled-card',
  'css',
  'Mini Proje - Profil Kartı',
  'Tüm CSS bilgilerini kullan',
  'code_challenge',
  3,
  25,
  35,
  15,
  '{
    "language": "css",
    "htmlContext": "<div class=\"card\">\n  <img src=\"avatar.jpg\" alt=\"Avatar\" class=\"avatar\">\n  <h2>Ali Yılmaz</h2>\n  <p class=\"title\">Yazılım Geliştirici</p>\n  <button class=\"btn\">İletişim</button>\n</div>",
    "starterCode": ".card {\n  /* Card container */\n  \n}\n\n.avatar {\n  /* Profil resmi */\n  \n}\n\nh2 {\n  /* İsim */\n  \n}\n\n.title {\n  /* Ünvan */\n  \n}\n\n.btn {\n  /* Buton */\n  \n}\n\n.btn:hover {\n  /* Hover efekti */\n  \n}",
    "instructions": [
      "Card: padding, border, border-radius, box-shadow",
      "Avatar: border-radius: 50%; (yuvarlak)",
      "Button: hover efekti ekle",
      "Flexbox veya Grid ile ortala",
      "Tüm öğrendiğin teknikleri kullan"
    ],
    "testCases": [
      {
        "type": "css_property",
        "selector": ".card",
        "property": "box-shadow",
        "description": "box-shadow olmalı"
      },
      {
        "type": "css_property",
        "selector": ".avatar",
        "property": "border-radius",
        "description": "Avatar yuvarlak olmalı"
      },
      {
        "type": "css_selector_exists",
        "selector": ".btn:hover",
        "description": "Hover efekti olmalı"
      },
      {
        "type": "line_count_min",
        "value": 30,
        "description": "En az 30 satır CSS"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustHaveSelectors": [".card", ".avatar", ".btn", ".btn:hover"],
    "livePreview": true,
    "isProject": true
  }',
  '["box-shadow: 0 4px 8px rgba(0,0,0,0.2);", "text-align: center; ile ortala", "transition ile smooth efektler", "Öğrendiğin her şeyi birleştir"]'::jsonb,
  true
);

-- ============================================
-- CSS EXPANSION SUMMARY
-- ============================================
-- Added: 10 new challenges (#6-15)
-- Total CSS challenges: 15
-- New XP: 275 XP
-- Total CSS XP: 370 XP
-- Difficulty range: 1-4 (Kolay → Çok Zor)
-- Topics: Layout (Flexbox, Grid), Responsive, Animations, Effects
-- ============================================
