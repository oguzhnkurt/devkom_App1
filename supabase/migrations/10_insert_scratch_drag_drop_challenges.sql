-- =============================================
-- SCRATCH DRAG-DROP BLOCK CHALLENGES
-- =============================================
-- Scratch-style visual block programming challenges

BEGIN;

-- =============================================
-- SCRATCH DRAG-DROP CHALLENGES
-- =============================================

INSERT INTO interactive_lessons (
  id, course_id, title, description, lesson_order, lesson_type,
  challenge_config, workspace_config, success_criteria, solution_code, hints,
  xp_reward, estimated_minutes, difficulty, tags, prerequisites, is_active
) VALUES

-- Scratch Challenge 1: Say Hello
('scratch_challenge_01', 'scratch', 'Merhaba De', 'Kedi karakteri merhaba desin', 1, 'drag_drop',
'{
  "instructions": [
    "Events bölümünden \"Yeşil bayrak tıklandığında\" bloğunu sürükle",
    "Looks bölümünden \"Merhaba de\" bloğunu ekle",
    "Bloklarını birleştir ve çalıştır"
  ],
  "availableBlocks": [
    {
      "category": "events",
      "blocks": [
        {"id": "event_whenflagclicked", "text": "Yeşil bayrak tıklandığında", "color": "#FFBF00"}
      ]
    },
    {
      "category": "looks",
      "blocks": [
        {"id": "looks_say", "text": "Merhaba de", "color": "#9966FF", "input": "text"}
      ]
    }
  ],
  "sprite": "cat",
  "stage": "blank"
}',
'{
  "workspace": "blocks",
  "showStage": true,
  "showSprite": true,
  "toolbox": "basic",
  "maxBlocks": 2,
  "snapToGrid": true
}',
'{
  "requiredBlocks": ["event_whenflagclicked", "looks_say"],
  "blocksConnected": true,
  "outputContains": "Merhaba"
}',
'event_whenflagclicked -> looks_say(\"Merhaba\")',
'["İpucu 1: Yeşil bayrak bloğu ile başla", "İpucu 2: Looks kategorisinden say bloğunu ekle", "İpucu 3: Blokları üst üste sürükle"]',
20, 10, 1, ARRAY['scratch', 'blocks', 'events', 'looks'], ARRAY[]::TEXT[], true),

-- Scratch Challenge 2: Move and Turn
('scratch_challenge_02', 'scratch', 'Hareket Et', 'Kedi ileri gitsin ve dönsün', 2, 'drag_drop',
'{
  "instructions": [
    "\"Yeşil bayrak\" bloğunu ekle",
    "Motion''dan \"10 adım git\" ekle",
    "\"15 derece sağa dön\" ekle"
  ],
  "availableBlocks": [
    {
      "category": "events",
      "blocks": [
        {"id": "event_whenflagclicked", "text": "Yeşil bayrak tıklandığında", "color": "#FFBF00"}
      ]
    },
    {
      "category": "motion",
      "blocks": [
        {"id": "motion_movesteps", "text": "() adım git", "color": "#4C97FF", "input": "number"},
        {"id": "motion_turnright", "text": "() derece sağa dön", "color": "#4C97FF", "input": "number"}
      ]
    }
  ],
  "sprite": "cat",
  "stage": "blank"
}',
'{
  "workspace": "blocks",
  "showStage": true,
  "showSprite": true,
  "maxBlocks": 3
}',
'{
  "requiredBlocks": ["event_whenflagclicked", "motion_movesteps", "motion_turnright"],
  "blocksConnected": true,
  "spritePosition": {"moved": true, "rotated": true}
}',
'event_whenflagclicked -> motion_movesteps(10) -> motion_turnright(15)',
'["İpucu 1: Motion kategorisine bak", "İpucu 2: Önce adım git, sonra dön", "İpucu 3: Sayıları bloklara yaz"]',
25, 12, 1, ARRAY['scratch', 'motion', 'movement', 'rotation'], ARRAY['scratch_challenge_01'], true),

-- Scratch Challenge 3: Repeat Loop
('scratch_challenge_03', 'scratch', 'Tekrar Et', 'Döngü kullanarak 4 kere hareket et', 3, 'drag_drop',
'{
  "instructions": [
    "\"Yeşil bayrak\" ekle",
    "Control''dan \"10 kere tekrarla\" bloğunu ekle",
    "İçine \"10 adım git\" ekle",
    "Kedi düz çizgi çizsin"
  ],
  "availableBlocks": [
    {
      "category": "events",
      "blocks": [
        {"id": "event_whenflagclicked", "text": "Yeşil bayrak tıklandığında", "color": "#FFBF00"}
      ]
    },
    {
      "category": "control",
      "blocks": [
        {"id": "control_repeat", "text": "() kere tekrarla", "color": "#FFAB19", "input": "number", "nested": true}
      ]
    },
    {
      "category": "motion",
      "blocks": [
        {"id": "motion_movesteps", "text": "() adım git", "color": "#4C97FF", "input": "number"}
      ]
    }
  ],
  "sprite": "cat",
  "stage": "blank"
}',
'{
  "workspace": "blocks",
  "showStage": true,
  "showSprite": true,
  "maxBlocks": 4,
  "supportsNesting": true
}',
'{
  "requiredBlocks": ["control_repeat", "motion_movesteps"],
  "nestedBlocks": true,
  "loopExecuted": true
}',
'event_whenflagclicked -> control_repeat(4) [motion_movesteps(10)]',
'["İpucu 1: Tekrarla bloğu C şeklinde - içine blok konur", "İpucu 2: Motion bloğunu tekrarla içine sürükle", "İpucu 3: 4 kere tekrarla yaz"]',
30, 15, 2, ARRAY['scratch', 'loop', 'repeat', 'control'], ARRAY['scratch_challenge_02'], true),

-- Scratch Challenge 4: Color Change
('scratch_challenge_04', 'scratch', 'Renk Değiştir', 'Döngü ile renk değiştir', 4, 'drag_drop',
'{
  "instructions": [
    "\"Yeşil bayrak\" ekle",
    "\"5 kere tekrarla\" ekle",
    "İçine \"renk efekti 25 değiştir\" ekle",
    "Kedi renk değiştirsin"
  ],
  "availableBlocks": [
    {
      "category": "events",
      "blocks": [
        {"id": "event_whenflagclicked", "text": "Yeşil bayrak tıklandığında", "color": "#FFBF00"}
      ]
    },
    {
      "category": "control",
      "blocks": [
        {"id": "control_repeat", "text": "() kere tekrarla", "color": "#FFAB19", "input": "number", "nested": true}
      ]
    },
    {
      "category": "looks",
      "blocks": [
        {"id": "looks_changeeffectby", "text": "renk efekti () değiştir", "color": "#9966FF", "input": "number"}
      ]
    }
  ],
  "sprite": "cat",
  "stage": "blank"
}',
'{
  "workspace": "blocks",
  "showStage": true,
  "showSprite": true,
  "supportsNesting": true
}',
'{
  "requiredBlocks": ["control_repeat", "looks_changeeffectby"],
  "nestedBlocks": true,
  "spriteColorChanged": true
}',
'event_whenflagclicked -> control_repeat(5) [looks_changeeffectby(25)]',
'["İpucu 1: Tekrarla bloğunu al", "İpucu 2: Looks''tan renk efekti ekle", "İpucu 3: 25 değiştir yaz"]',
30, 15, 2, ARRAY['scratch', 'looks', 'effects', 'color', 'loop'], ARRAY['scratch_challenge_03'], true),

-- Scratch Challenge 5: Wait and Repeat
('scratch_challenge_05', 'scratch', 'Bekle ve Tekrarla', 'Animasyon oluştur: hareket et, bekle, hareket et', 5, 'drag_drop',
'{
  "instructions": [
    "\"Yeşil bayrak\" ekle",
    "\"3 kere tekrarla\" ekle",
    "İçine sırasıyla:",
    "  - \"10 adım git\"",
    "  - \"1 saniye bekle\"",
    "  - \"Merhaba de\"",
    "Animasyon gibi görünsün"
  ],
  "availableBlocks": [
    {
      "category": "events",
      "blocks": [
        {"id": "event_whenflagclicked", "text": "Yeşil bayrak tıklandığında", "color": "#FFBF00"}
      ]
    },
    {
      "category": "control",
      "blocks": [
        {"id": "control_repeat", "text": "() kere tekrarla", "color": "#FFAB19", "input": "number", "nested": true},
        {"id": "control_wait", "text": "() saniye bekle", "color": "#FFAB19", "input": "number"}
      ]
    },
    {
      "category": "motion",
      "blocks": [
        {"id": "motion_movesteps", "text": "() adım git", "color": "#4C97FF", "input": "number"}
      ]
    },
    {
      "category": "looks",
      "blocks": [
        {"id": "looks_say", "text": "() de", "color": "#9966FF", "input": "text"}
      ]
    }
  ],
  "sprite": "cat",
  "stage": "blank"
}',
'{
  "workspace": "blocks",
  "showStage": true,
  "showSprite": true,
  "supportsNesting": true
}',
'{
  "requiredBlocks": ["control_repeat", "motion_movesteps", "control_wait", "looks_say"],
  "nestedBlocks": true,
  "blockOrder": ["motion_movesteps", "control_wait", "looks_say"]
}',
'event_whenflagclicked -> control_repeat(3) [motion_movesteps(10), control_wait(1), looks_say(\"Merhaba\")]',
'["İpucu 1: 3 bloğu tekrarla içine koy", "İpucu 2: Sıra önemli: önce git, sonra bekle, sonra konuş", "İpucu 3: Blokları üst üste sürükle"]',
35, 20, 3, ARRAY['scratch', 'animation', 'timing', 'sequence'], ARRAY['scratch_challenge_04'], true),

-- Scratch Challenge 6: If-Then
('scratch_challenge_06', 'scratch', 'Eğer-O Zaman', 'Kenar kontrolü: eğer kenara değerse geri dön', 6, 'drag_drop',
'{
  "instructions": [
    "\"Yeşil bayrak\" ekle",
    "\"Sonsuza kadar\" döngüsü ekle",
    "İçine \"eğer kenara değiyor ise\"",
    "O zaman \"geri zıpla\""
  ],
  "availableBlocks": [
    {
      "category": "events",
      "blocks": [
        {"id": "event_whenflagclicked", "text": "Yeşil bayrak tıklandığında", "color": "#FFBF00"}
      ]
    },
    {
      "category": "control",
      "blocks": [
        {"id": "control_forever", "text": "Sonsuza kadar", "color": "#FFAB19", "nested": true},
        {"id": "control_if", "text": "Eğer <> ise", "color": "#FFAB19", "nested": true}
      ]
    },
    {
      "category": "sensing",
      "blocks": [
        {"id": "sensing_touchingedge", "text": "kenara değiyor?", "color": "#5CB1D6", "type": "boolean"}
      ]
    },
    {
      "category": "motion",
      "blocks": [
        {"id": "motion_movesteps", "text": "() adım git", "color": "#4C97FF", "input": "number"},
        {"id": "motion_ifonedgebounce", "text": "Eğer kenarda ise sekdir", "color": "#4C97FF"}
      ]
    }
  ],
  "sprite": "cat",
  "stage": "blank"
}',
'{
  "workspace": "blocks",
  "showStage": true,
  "showSprite": true,
  "supportsNesting": true,
  "supportsBoolean": true
}',
'{
  "requiredBlocks": ["control_forever", "motion_movesteps", "motion_ifonedgebounce"],
  "nestedBlocks": true
}',
'event_whenflagclicked -> control_forever [motion_movesteps(10), motion_ifonedgebounce]',
'["İpucu 1: Sonsuza kadar bloğu al", "İpucu 2: İçine git ve sekdir bloklarını koy", "İpucu 3: Sekdir bloğu otomatik kenar kontrol eder"]',
40, 20, 3, ARRAY['scratch', 'conditional', 'if', 'sensing', 'edge'], ARRAY['scratch_challenge_05'], true),

-- Scratch Challenge 7: Draw a Square
('scratch_challenge_07', 'scratch', 'Kare Çiz', 'Döngü ve dönüşle kare çiz', 7, 'drag_drop',
'{
  "instructions": [
    "Kalemi indir (pen down)",
    "4 kere tekrarla:",
    "  - 100 adım git",
    "  - 90 derece sağa dön",
    "Kare çizilsin"
  ],
  "availableBlocks": [
    {
      "category": "events",
      "blocks": [
        {"id": "event_whenflagclicked", "text": "Yeşil bayrak tıklandığında", "color": "#FFBF00"}
      ]
    },
    {
      "category": "pen",
      "blocks": [
        {"id": "pen_penDown", "text": "Kalemi indir", "color": "#0FBD8C"},
        {"id": "pen_penUp", "text": "Kalemi kaldır", "color": "#0FBD8C"}
      ]
    },
    {
      "category": "control",
      "blocks": [
        {"id": "control_repeat", "text": "() kere tekrarla", "color": "#FFAB19", "input": "number", "nested": true}
      ]
    },
    {
      "category": "motion",
      "blocks": [
        {"id": "motion_movesteps", "text": "() adım git", "color": "#4C97FF", "input": "number"},
        {"id": "motion_turnright", "text": "() derece sağa dön", "color": "#4C97FF", "input": "number"}
      ]
    }
  ],
  "sprite": "cat",
  "stage": "blank",
  "penEnabled": true
}',
'{
  "workspace": "blocks",
  "showStage": true,
  "showSprite": true,
  "supportsNesting": true,
  "showPenTrail": true
}',
'{
  "requiredBlocks": ["pen_penDown", "control_repeat", "motion_movesteps", "motion_turnright"],
  "nestedBlocks": true,
  "drawsShape": "square"
}',
'event_whenflagclicked -> pen_penDown -> control_repeat(4) [motion_movesteps(100), motion_turnright(90)]',
'["İpucu 1: Kare 4 kenardan oluşur", "İpucu 2: Her kenarda 100 adım git, 90 derece dön", "İpucu 3: Kalemi indirmeyi unutma!"]',
50, 25, 3, ARRAY['scratch', 'pen', 'drawing', 'geometry', 'loop'], ARRAY['scratch_challenge_06'], true),

-- Scratch Challenge 8: Interactive Game
('scratch_challenge_08', 'scratch', 'Etkileşimli Oyun', 'Ok tuşlarıyla kedii hareket ettir', 8, 'drag_drop',
'{
  "instructions": [
    "4 ayrı olay bloğu:",
    "\"Sağ ok tuşuna basıldığında\" -> x: 10 değiştir",
    "\"Sol ok tuşuna basıldığında\" -> x: -10 değiştir",
    "\"Yukarı ok tuşuna basıldığında\" -> y: 10 değiştir",
    "\"Aşağı ok tuşuna basıldığında\" -> y: -10 değiştir"
  ],
  "availableBlocks": [
    {
      "category": "events",
      "blocks": [
        {"id": "event_whenkeypressed", "text": "() tuşuna basıldığında", "color": "#FFBF00", "input": "key"}
      ]
    },
    {
      "category": "motion",
      "blocks": [
        {"id": "motion_changexby", "text": "x: () değiştir", "color": "#4C97FF", "input": "number"},
        {"id": "motion_changeyby", "text": "y: () değiştir", "color": "#4C97FF", "input": "number"}
      ]
    }
  ],
  "sprite": "cat",
  "stage": "blank"
}',
'{
  "workspace": "blocks",
  "showStage": true,
  "showSprite": true,
  "interactiveMode": true
}',
'{
  "requiredBlocks": ["event_whenkeypressed", "motion_changexby", "motion_changeyby"],
  "blockCount": 8,
  "keysHandled": ["right", "left", "up", "down"]
}',
'4 separate scripts:\nevent_whenkeypressed(right) -> motion_changexby(10)\nevent_whenkeypressed(left) -> motion_changexby(-10)\nevent_whenkeypressed(up) -> motion_changeyby(10)\nevent_whenkeypressed(down) -> motion_changeyby(-10)',
'["İpucu 1: 4 ayrı script yap (4 yeşil blok)", "İpucu 2: Her ok tuşu için bir tane", "İpucu 3: Sağ/Sol için x değiştir, Yukarı/Aşağı için y değiştir"]',
60, 30, 4, ARRAY['scratch', 'keyboard', 'control', 'game', 'interactive'], ARRAY['scratch_challenge_07'], true);

COMMIT;

-- =============================================
-- VERIFY INSERTION
-- =============================================
SELECT
  course_id,
  lesson_type,
  COUNT(*) as challenge_count,
  SUM(xp_reward) as total_xp,
  AVG(difficulty) as avg_difficulty
FROM interactive_lessons
WHERE course_id = 'scratch'
GROUP BY course_id, lesson_type;

-- Overall summary
SELECT
  course_id,
  COUNT(*) as total_challenges,
  SUM(xp_reward) as total_xp,
  MIN(difficulty) as min_difficulty,
  MAX(difficulty) as max_difficulty
FROM interactive_lessons
GROUP BY course_id
ORDER BY course_id;
