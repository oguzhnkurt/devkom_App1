-- ============================================
-- SCRATCH CHALLENGES EXPANSION (9-20)
-- Adding 12 new drag-drop block challenges
-- Total: 20 challenges, ~785 XP
-- ============================================

-- Challenge 9: Glide Smoothly
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
  'scratch-009-glide-smoothly',
  'scratch',
  'Kayarak Git - Smooth Hareket',
  'glide bloğu ile smooth hareket',
  'drag_drop',
  1,
  10,
  25,
  9,
  '{
    "availableBlocks": [
      {
        "category": "events",
        "blocks": [
          {"id": "event_whenflagclicked", "text": "🏁 Yeşil bayrak tıklandığında", "color": "#FFBF00"}
        ]
      },
      {
        "category": "motion",
        "blocks": [
          {"id": "motion_glideto", "text": "() saniyede x: () y: () konumuna kay", "color": "#4C97FF", "inputs": ["duration", "x", "y"]}
        ]
      }
    ],
    "sprite": "cat",
    "stage": "blank",
    "expectedSequence": ["event_whenflagclicked", "motion_glideto"],
    "successAnimation": "smooth_glide"
  }',
  '{
    "blocksRequired": ["event_whenflagclicked", "motion_glideto"],
    "sequenceMatters": true,
    "parameterRanges": {
      "duration": [1, 3],
      "x": [-200, 200],
      "y": [-150, 150]
    }
  }',
  '["Yeşil bayrak ile başla", "glide bloğu smooth hareket sağlar", "2 saniyede x:100 y:0 konumuna kay"]'::jsonb,
  true
);

-- Challenge 10: Change Size
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
  'scratch-010-change-size',
  'scratch',
  'Boyut Değiştir - Büyü Küçült',
  'set size ve change size blokları',
  'drag_drop',
  1,
  10,
  25,
  10,
  '{
    "availableBlocks": [
      {
        "category": "events",
        "blocks": [
          {"id": "event_whenflagclicked", "text": "🏁 Yeşil bayrak tıklandığında", "color": "#FFBF00"}
        ]
      },
      {
        "category": "looks",
        "blocks": [
          {"id": "looks_setsize", "text": "boyutu %() yap", "color": "#9966FF", "input": "size"},
          {"id": "looks_changesize", "text": "boyutu () değiştir", "color": "#9966FF", "input": "delta"}
        ]
      },
      {
        "category": "control",
        "blocks": [
          {"id": "control_wait", "text": "() saniye bekle", "color": "#FFAB19", "input": "duration"}
        ]
      }
    ],
    "sprite": "cat",
    "stage": "blank",
    "expectedSequence": ["event_whenflagclicked", "looks_setsize", "control_wait", "looks_changesize"],
    "successAnimation": "size_change"
  }',
  '{
    "blocksRequired": ["event_whenflagclicked", "looks_setsize", "looks_changesize"],
    "sequenceMatters": true
  }',
  '["set size %100 ile başlangıç boyutunu ayarla", "1 saniye bekle", "change size 50 ile büyüt"]'::jsonb,
  true
);

-- Challenge 11: Play Sound
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
  'scratch-011-play-sound',
  'scratch',
  'Ses Çal - Miyav',
  'Ses blokları ile etkileşim',
  'drag_drop',
  2,
  12,
  30,
  11,
  '{
    "availableBlocks": [
      {
        "category": "events",
        "blocks": [
          {"id": "event_whenflagclicked", "text": "🏁 Yeşil bayrak tıklandığında", "color": "#FFBF00"}
        ]
      },
      {
        "category": "sound",
        "blocks": [
          {"id": "sound_play", "text": "() sesini çal", "color": "#CF63CF", "input": "sound"},
          {"id": "sound_playuntildone", "text": "() sesini çalıp bitir", "color": "#CF63CF", "input": "sound"}
        ]
      },
      {
        "category": "looks",
        "blocks": [
          {"id": "looks_say", "text": "() de", "color": "#9966FF", "input": "message"}
        ]
      }
    ],
    "sprite": "cat",
    "stage": "blank",
    "expectedSequence": ["event_whenflagclicked", "looks_say", "sound_playuntildone"],
    "successAnimation": "play_sound"
  }',
  '{
    "blocksRequired": ["event_whenflagclicked", "sound_playuntildone", "looks_say"],
    "sequenceMatters": false
  }',
  '["\"Miyav!\" de", "\"meow\" sesini çalıp bitir", "play until done bitene kadar bekler"]'::jsonb,
  true
);

-- Challenge 12: Broadcast Messages
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
  'scratch-012-broadcast',
  'scratch',
  'Mesaj Gönder - Broadcast',
  'Sprite''lar arası iletişim',
  'drag_drop',
  2,
  15,
  35,
  12,
  '{
    "availableBlocks": [
      {
        "category": "events",
        "blocks": [
          {"id": "event_whenflagclicked", "text": "🏁 Yeşil bayrak tıklandığında", "color": "#FFBF00"},
          {"id": "event_whenreceive", "text": "() mesajını aldığımda", "color": "#FFBF00", "input": "message"}
        ]
      },
      {
        "category": "events",
        "blocks": [
          {"id": "event_broadcast", "text": "() mesajını gönder", "color": "#FFBF00", "input": "message"}
        ]
      },
      {
        "category": "looks",
        "blocks": [
          {"id": "looks_show", "text": "göster", "color": "#9966FF"},
          {"id": "looks_hide", "text": "gizle", "color": "#9966FF"}
        ]
      }
    ],
    "sprite": "cat",
    "stage": "blank",
    "expectedSequence": ["event_whenflagclicked", "event_broadcast", "event_whenreceive", "looks_show"],
    "successAnimation": "broadcast_demo"
  }',
  '{
    "blocksRequired": ["event_broadcast", "event_whenreceive"],
    "sequenceMatters": false
  }',
  '["broadcast \"başla\" mesajını gönder", "when I receive \"başla\" ile yakala", "Alıcı bloğunda show ile göster"]'::jsonb,
  true
);

-- Challenge 13: Variables
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
  'scratch-013-variables',
  'scratch',
  'Değişkenler - Sayaç',
  'Variable oluştur ve kullan',
  'drag_drop',
  2,
  15,
  35,
  13,
  '{
    "availableBlocks": [
      {
        "category": "events",
        "blocks": [
          {"id": "event_whenflagclicked", "text": "🏁 Yeşil bayrak tıklandığında", "color": "#FFBF00"}
        ]
      },
      {
        "category": "variables",
        "blocks": [
          {"id": "data_setvariableto", "text": "[sayaç] değişkenini () yap", "color": "#FF8C1A", "input": "value"},
          {"id": "data_changevariableby", "text": "[sayaç] değişkenini () değiştir", "color": "#FF8C1A", "input": "delta"}
        ]
      },
      {
        "category": "control",
        "blocks": [
          {"id": "control_repeat", "text": "() kere tekrarla", "color": "#FFAB19", "input": "times"}
        ]
      }
    ],
    "sprite": "cat",
    "stage": "blank",
    "expectedSequence": ["event_whenflagclicked", "data_setvariableto", "control_repeat", "data_changevariableby"],
    "successAnimation": "counter_demo"
  }',
  '{
    "blocksRequired": ["data_setvariableto", "data_changevariableby", "control_repeat"],
    "sequenceMatters": true
  }',
  '["sayaç değişkenini 0 yap", "10 kere tekrarla içinde", "sayaç''ı 1 artır"]'::jsonb,
  true
);

-- Challenge 14: Ask and Wait
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
  'scratch-014-ask-wait',
  'scratch',
  'Sor ve Bekle - İsim Öğren',
  'Kullanıcıdan input al',
  'drag_drop',
  2,
  12,
  30,
  14,
  '{
    "availableBlocks": [
      {
        "category": "events",
        "blocks": [
          {"id": "event_whenflagclicked", "text": "🏁 Yeşil bayrak tıklandığında", "color": "#FFBF00"}
        ]
      },
      {
        "category": "sensing",
        "blocks": [
          {"id": "sensing_askandwait", "text": "() diye sor ve bekle", "color": "#4CBFE6", "input": "question"}
        ]
      },
      {
        "category": "looks",
        "blocks": [
          {"id": "looks_sayforsecs", "text": "() saniye () de", "color": "#9966FF", "inputs": ["duration", "message"]}
        ]
      },
      {
        "category": "sensing",
        "blocks": [
          {"id": "sensing_answer", "text": "cevap", "color": "#4CBFE6"}
        ]
      }
    ],
    "sprite": "cat",
    "stage": "blank",
    "expectedSequence": ["event_whenflagclicked", "sensing_askandwait", "looks_sayforsecs"],
    "successAnimation": "ask_demo"
  }',
  '{
    "blocksRequired": ["sensing_askandwait", "looks_sayforsecs"],
    "sequenceMatters": true,
    "mustUseAnswer": true
  }',
  '["\"Adın ne?\" diye sor", "answer bloğunu say içinde kullan", "\"Merhaba \" + answer şeklinde birleştir"]'::jsonb,
  true
);

-- Challenge 15: Mouse Following
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
  'scratch-015-mouse-follow',
  'scratch',
  'Fareyi Takip Et',
  'Mouse pointer''ı sürekli takip et',
  'drag_drop',
  3,
  18,
  40,
  15,
  '{
    "availableBlocks": [
      {
        "category": "events",
        "blocks": [
          {"id": "event_whenflagclicked", "text": "🏁 Yeşil bayrak tıklandığında", "color": "#FFBF00"}
        ]
      },
      {
        "category": "control",
        "blocks": [
          {"id": "control_forever", "text": "sürekli", "color": "#FFAB19"}
        ]
      },
      {
        "category": "motion",
        "blocks": [
          {"id": "motion_pointtowards", "text": "() yönüne bak", "color": "#4C97FF", "input": "target"},
          {"id": "motion_movesteps", "text": "() adım git", "color": "#4C97FF", "input": "steps"}
        ]
      }
    ],
    "sprite": "cat",
    "stage": "blank",
    "expectedSequence": ["event_whenflagclicked", "control_forever", "motion_pointtowards", "motion_movesteps"],
    "successAnimation": "mouse_follow"
  }',
  '{
    "blocksRequired": ["control_forever", "motion_pointtowards", "motion_movesteps"],
    "sequenceMatters": true,
    "nestedBlocks": ["control_forever"]
  }',
  '["forever bloğu kullan", "point towards \"mouse-pointer\"", "10 adım git"]'::jsonb,
  true
);

-- Challenge 16: Nested If-Else
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
  'scratch-016-nested-if',
  'scratch',
  'İç İçe If-Else - Kenar Kontrolü',
  'Nested conditionals ile sınır kontrolü',
  'drag_drop',
  3,
  20,
  45,
  16,
  '{
    "availableBlocks": [
      {
        "category": "events",
        "blocks": [
          {"id": "event_whenflagclicked", "text": "🏁 Yeşil bayrak tıklandığında", "color": "#FFBF00"}
        ]
      },
      {
        "category": "control",
        "blocks": [
          {"id": "control_forever", "text": "sürekli", "color": "#FFAB19"},
          {"id": "control_if", "text": "eğer <> ise", "color": "#FFAB19"},
          {"id": "control_if_else", "text": "eğer <> ise yoksa", "color": "#FFAB19"}
        ]
      },
      {
        "category": "sensing",
        "blocks": [
          {"id": "sensing_touchingedge", "text": "kenara değiyor mu?", "color": "#4CBFE6"}
        ]
      },
      {
        "category": "motion",
        "blocks": [
          {"id": "motion_movesteps", "text": "() adım git", "color": "#4C97FF", "input": "steps"},
          {"id": "motion_turnright", "text": "🔄 () derece sağa dön", "color": "#4C97FF", "input": "degrees"}
        ]
      }
    ],
    "sprite": "cat",
    "stage": "blank",
    "expectedSequence": ["event_whenflagclicked", "control_forever", "control_if", "motion_turnright", "motion_movesteps"],
    "successAnimation": "edge_bounce"
  }',
  '{
    "blocksRequired": ["control_forever", "control_if", "sensing_touchingedge", "motion_turnright"],
    "sequenceMatters": true,
    "nestedBlocks": ["control_forever", "control_if"]
  }',
  '["forever döngüsü içinde if kullan", "touching edge? koşulunu kontrol et", "Kenara değerse 180 derece dön"]'::jsonb,
  true
);

-- Challenge 17: Clone Sprites
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
  'scratch-017-clones',
  'scratch',
  'Klonlar - Çoklu Sprite',
  'Clone blokları ile çoğalma',
  'drag_drop',
  3,
  20,
  50,
  17,
  '{
    "availableBlocks": [
      {
        "category": "events",
        "blocks": [
          {"id": "event_whenflagclicked", "text": "🏁 Yeşil bayrak tıklandığında", "color": "#FFBF00"},
          {"id": "event_whenstartasclone", "text": "🎭 Klon olarak başladığında", "color": "#FFBF00"}
        ]
      },
      {
        "category": "control",
        "blocks": [
          {"id": "control_repeat", "text": "() kere tekrarla", "color": "#FFAB19", "input": "times"},
          {"id": "control_createclone", "text": "kendinin klonunu oluştur", "color": "#FFAB19"},
          {"id": "control_deleteclone", "text": "bu klonu sil", "color": "#FFAB19"}
        ]
      },
      {
        "category": "motion",
        "blocks": [
          {"id": "motion_movesteps", "text": "() adım git", "color": "#4C97FF", "input": "steps"}
        ]
      }
    ],
    "sprite": "cat",
    "stage": "blank",
    "expectedSequence": ["event_whenflagclicked", "control_repeat", "control_createclone", "event_whenstartasclone", "motion_movesteps"],
    "successAnimation": "clones_demo"
  }',
  '{
    "blocksRequired": ["control_createclone", "event_whenstartasclone"],
    "sequenceMatters": false,
    "mustHaveTwoScripts": true
  }',
  '["İki ayrı script yaz", "Bayrak script''inde: 5 kere klon oluştur", "Klon script''inde: 50 adım git"]'::jsonb,
  true
);

-- Challenge 18: Draw Circle
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
  'scratch-018-draw-circle',
  'scratch',
  'Daire Çiz - Pen İleri Seviye',
  'Pen ile smooth daire çizimi',
  'drag_drop',
  3,
  22,
  50,
  18,
  '{
    "availableBlocks": [
      {
        "category": "events",
        "blocks": [
          {"id": "event_whenflagclicked", "text": "🏁 Yeşil bayrak tıklandığında", "color": "#FFBF00"}
        ]
      },
      {
        "category": "pen",
        "blocks": [
          {"id": "pen_clear", "text": "hepsini sil", "color": "#0FBD8C"},
          {"id": "pen_pendown", "text": "kalemi indir", "color": "#0FBD8C"},
          {"id": "pen_penup", "text": "kalemi kaldır", "color": "#0FBD8C"}
        ]
      },
      {
        "category": "control",
        "blocks": [
          {"id": "control_repeat", "text": "() kere tekrarla", "color": "#FFAB19", "input": "times"}
        ]
      },
      {
        "category": "motion",
        "blocks": [
          {"id": "motion_movesteps", "text": "() adım git", "color": "#4C97FF", "input": "steps"},
          {"id": "motion_turnright", "text": "🔄 () derece sağa dön", "color": "#4C97FF", "input": "degrees"}
        ]
      }
    ],
    "sprite": "cat",
    "stage": "blank",
    "expectedSequence": ["event_whenflagclicked", "pen_clear", "pen_pendown", "control_repeat", "motion_movesteps", "motion_turnright"],
    "successAnimation": "draw_circle"
  }',
  '{
    "blocksRequired": ["pen_clear", "pen_pendown", "control_repeat", "motion_movesteps", "motion_turnright"],
    "sequenceMatters": true,
    "nestedBlocks": ["control_repeat"],
    "parameters": {
      "repeat": 36,
      "steps": 10,
      "turn": 10
    }
  }',
  '["36 kere tekrarla (360/36 = 10 derece)", "10 adım git", "10 derece dön", "Bu smooth bir daire oluşturur"]'::jsonb,
  true
);

-- Challenge 19: Maze Game
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
  'scratch-019-maze-game',
  'scratch',
  'Labirent Oyunu',
  'Ok tuşları ile labirent kontrolü',
  'drag_drop',
  4,
  30,
  60,
  19,
  '{
    "availableBlocks": [
      {
        "category": "events",
        "blocks": [
          {"id": "event_whenflagclicked", "text": "🏁 Yeşil bayrak tıklandığında", "color": "#FFBF00"}
        ]
      },
      {
        "category": "control",
        "blocks": [
          {"id": "control_forever", "text": "sürekli", "color": "#FFAB19"},
          {"id": "control_if", "text": "eğer <> ise", "color": "#FFAB19"}
        ]
      },
      {
        "category": "sensing",
        "blocks": [
          {"id": "sensing_keypressed", "text": "<> tuşuna basıldı mı?", "color": "#4CBFE6", "input": "key"},
          {"id": "sensing_touchingcolor", "text": "<> rengine değiyor mu?", "color": "#4CBFE6"}
        ]
      },
      {
        "category": "motion",
        "blocks": [
          {"id": "motion_changex", "text": "x''i () değiştir", "color": "#4C97FF", "input": "dx"},
          {"id": "motion_changey", "text": "y''yi () değiştir", "color": "#4C97FF", "input": "dy"},
          {"id": "motion_gotoxyorigin", "text": "x: -200 y: 0''a git", "color": "#4C97FF"}
        ]
      },
      {
        "category": "looks",
        "blocks": [
          {"id": "looks_say", "text": "() de", "color": "#9966FF", "input": "message"}
        ]
      }
    ],
    "sprite": "cat",
    "stage": "maze_background",
    "expectedSequence": ["event_whenflagclicked", "motion_gotoxyorigin", "control_forever", "control_if", "sensing_keypressed", "motion_changex"],
    "successAnimation": "maze_solve"
  }',
  '{
    "blocksRequired": ["control_forever", "control_if", "sensing_keypressed", "motion_changex", "motion_changey", "sensing_touchingcolor"],
    "sequenceMatters": false,
    "nestedBlocks": ["control_forever", "control_if"],
    "multipleIfBlocks": 4
  }',
  '["4 if bloğu: yukarı, aşağı, sol, sağ", "Tuş kontrolü: \"up arrow\" key pressed?", "Duvara değerse başa dön: touching color black?"]'::jsonb,
  true
);

-- Challenge 20: Catch Game
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
  'scratch-020-catch-game',
  'scratch',
  'Yakalama Oyunu - Skorlu',
  'Düşen objeleri yakala, skor tut',
  'drag_drop',
  4,
  30,
  60,
  20,
  '{
    "availableBlocks": [
      {
        "category": "events",
        "blocks": [
          {"id": "event_whenflagclicked", "text": "🏁 Yeşil bayrak tıklandığında", "color": "#FFBF00"}
        ]
      },
      {
        "category": "variables",
        "blocks": [
          {"id": "data_setvariableto", "text": "[skor] değişkenini () yap", "color": "#FF8C1A", "input": "value"},
          {"id": "data_changevariableby", "text": "[skor] değişkenini () değiştir", "color": "#FF8C1A", "input": "delta"}
        ]
      },
      {
        "category": "control",
        "blocks": [
          {"id": "control_forever", "text": "sürekli", "color": "#FFAB19"},
          {"id": "control_if", "text": "eğer <> ise", "color": "#FFAB19"},
          {"id": "control_wait", "text": "() saniye bekle", "color": "#FFAB19", "input": "duration"}
        ]
      },
      {
        "category": "motion",
        "blocks": [
          {"id": "motion_gotoxy", "text": "x: () y: () git", "color": "#4C97FF", "inputs": ["x", "y"]},
          {"id": "motion_changey", "text": "y''yi () değiştir", "color": "#4C97FF", "input": "dy"},
          {"id": "motion_setx_random", "text": "x''i rastgele -200 ile 200 arası yap", "color": "#4C97FF"}
        ]
      },
      {
        "category": "sensing",
        "blocks": [
          {"id": "sensing_touchingsprite", "text": "<> sprite''ına değiyor mu?", "color": "#4CBFE6"}
        ]
      },
      {
        "category": "sound",
        "blocks": [
          {"id": "sound_play", "text": "() sesini çal", "color": "#CF63CF", "input": "sound"}
        ]
      }
    ],
    "sprite": "cat",
    "stage": "blank",
    "expectedSequence": ["event_whenflagclicked", "data_setvariableto", "control_forever", "motion_changey", "control_if", "sensing_touchingsprite", "data_changevariableby"],
    "successAnimation": "catch_game"
  }',
  '{
    "blocksRequired": ["data_setvariableto", "data_changevariableby", "control_forever", "control_if", "sensing_touchingsprite", "motion_changey"],
    "sequenceMatters": false,
    "nestedBlocks": ["control_forever", "control_if"],
    "variables": ["skor"]
  }',
  '["skor = 0 ile başla", "forever içinde y''yi -5 değiştir (düşsün)", "touching sprite? ile çarpışma kontrol et", "Çarpışırsa: skor +1, obje rastgele x''e geri çık"]'::jsonb,
  true
);

-- ============================================
-- SCRATCH EXPANSION SUMMARY
-- ============================================
-- Added: 12 new challenges (#9-20)
-- Total Scratch challenges: 20
-- New XP: 505 XP
-- Total Scratch XP: 785 XP
-- Difficulty range: 1-4 (Kolay → Çok Zor)
-- Topics: Animation, Sound, Variables, Clones, Games
-- ============================================
