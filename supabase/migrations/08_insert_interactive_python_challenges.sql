-- =============================================
-- PYTHON INTERACTIVE CODE CHALLENGES
-- =============================================
-- freeCodeCamp style interactive coding lessons

BEGIN;

-- =============================================
-- 1. PYTHON BASICS CHALLENGES
-- =============================================

INSERT INTO interactive_lessons (
  id, course_id, title, description, lesson_order, lesson_type,
  challenge_config, workspace_config, success_criteria, solution_code, hints,
  xp_reward, estimated_minutes, difficulty, tags, prerequisites, is_active
) VALUES

-- Challenge 1: Print Your Name
('py_challenge_01', 'python', 'Adını Ekrana Yazdır', 'print() fonksiyonunu kullanarak kendi adını ekrana yazdır', 1, 'code_challenge',
'{
  "instructions": [
    "print() fonksiyonunu kullan",
    "Çift tırnak içinde kendi adını yaz",
    "Örnek: print(\"Ahmet\")"
  ],
  "starterCode": "# Buraya kodunu yaz\n",
  "testCases": [
    {"type": "output_contains", "value": "your_name", "description": "Ekrana bir isim yazdırılmalı"}
  ]
}',
'{
  "language": "python",
  "theme": "dark",
  "fontSize": 14,
  "showLineNumbers": true,
  "showOutput": true,
  "runnable": true
}',
'{
  "minLength": 10,
  "mustContain": ["print"],
  "mustNotContain": [],
  "passingTests": 1
}',
'print("Ahmet")',
'["İpucu 1: print() fonksiyonunu kullan", "İpucu 2: Çift tırnak içinde ismini yaz"]',
10, 5, 1, ARRAY['print', 'basics', 'string'], ARRAY[]::TEXT[], true),

-- Challenge 2: Basic Math
('py_challenge_02', 'python', 'Matematik İşlemleri', 'İki sayıyı topla ve sonucu ekrana yazdır', 2, 'code_challenge',
'{
  "instructions": [
    "5 ve 8 sayılarını topla",
    "Sonucu print() ile ekrana yazdır",
    "Çıktı: 13 olmalı"
  ],
  "starterCode": "# 5 + 8 işlemini yap ve sonucu yazdır\n",
  "testCases": [
    {"type": "output_exact", "value": "13", "description": "Çıktı 13 olmalı"}
  ]
}',
'{
  "language": "python",
  "theme": "dark",
  "showOutput": true,
  "runnable": true
}',
'{
  "mustContain": ["print", "+"],
  "passingTests": 1
}',
'print(5 + 8)',
'["İpucu 1: + operatörünü kullan", "İpucu 2: print(5 + 8) şeklinde yazabilirsin"]',
15, 5, 1, ARRAY['math', 'operators', 'print'], ARRAY['py_challenge_01'], true),

-- Challenge 3: Variables
('py_challenge_03', 'python', 'Değişken Oluştur', 'isim adında bir değişken oluştur ve ekrana yazdır', 3, 'code_challenge',
'{
  "instructions": [
    "isim adında bir değişken oluştur",
    "İçine kendi adını yaz",
    "print() ile ekrana yazdır"
  ],
  "starterCode": "# Değişkeni oluştur\nisim = \n\n# Ekrana yazdır\n",
  "testCases": [
    {"type": "variable_exists", "value": "isim", "description": "isim değişkeni tanımlanmalı"},
    {"type": "output_contains", "value": "str", "description": "İsim ekrana yazılmalı"}
  ]
}',
'{
  "language": "python",
  "showOutput": true,
  "runnable": true
}',
'{
  "mustContain": ["isim", "=", "print"],
  "passingTests": 2
}',
'isim = "Ahmet"\nprint(isim)',
'["İpucu 1: isim = \"senin_ismin\" şeklinde yaz", "İpucu 2: Sonra print(isim) ile yazdır"]',
15, 8, 1, ARRAY['variables', 'string', 'print'], ARRAY['py_challenge_02'], true),

-- Challenge 4: Multiple Variables
('py_challenge_04', 'python', 'Çoklu Değişkenler', 'İsim ve yaş değişkenleri oluştur', 4, 'code_challenge',
'{
  "instructions": [
    "isim değişkeni oluştur (string)",
    "yas değişkeni oluştur (sayı)",
    "İkisini de ekrana yazdır"
  ],
  "starterCode": "# İsim değişkenini oluştur\n\n# Yaş değişkenini oluştur\n\n# Ekrana yazdır\n",
  "testCases": [
    {"type": "variable_exists", "value": "isim", "description": "isim değişkeni olmalı"},
    {"type": "variable_exists", "value": "yas", "description": "yas değişkeni olmalı"},
    {"type": "output_not_empty", "description": "Çıktı boş olmamalı"}
  ]
}',
'{
  "language": "python",
  "showOutput": true,
  "runnable": true
}',
'{
  "mustContain": ["isim", "yas", "print"],
  "passingTests": 3
}',
'isim = "Ahmet"\nyas = 12\nprint(isim)\nprint(yas)',
'["İpucu 1: İki ayrı değişken oluştur", "İpucu 2: print() her satırda ayrı çağır"]',
20, 10, 1, ARRAY['variables', 'types', 'print'], ARRAY['py_challenge_03'], true),

-- Challenge 5: String Formatting
('py_challenge_05', 'python', 'String Birleştirme', 'f-string kullanarak cümle oluştur', 5, 'code_challenge',
'{
  "instructions": [
    "isim ve yas değişkenleri oluştur",
    "f-string kullanarak \"Benim adim X ve yasim Y\" yazdır"
  ],
  "starterCode": "isim = \"Ahmet\"\nyas = 12\n\n# f-string ile yazdır\nprint(f\"\")",
  "testCases": [
    {"type": "output_contains", "value": "adim", "description": "Çıktıda adım kelimesi olmalı"},
    {"type": "output_contains", "value": "yasim", "description": "Çıktıda yaşım kelimesi olmalı"}
  ]
}',
'{
  "language": "python",
  "showOutput": true,
  "runnable": true
}',
'{
  "mustContain": ["f\"", "isim", "yas"],
  "passingTests": 2
}',
'isim = "Ahmet"\nyas = 12\nprint(f"Benim adim {isim} ve yasim {yas}")',
'["İpucu 1: f-string içinde {isim} ve {yas} kullan", "İpucu 2: print(f\"Benim adim {isim} ve yasim {yas}\")"]',
20, 10, 2, ARRAY['f-string', 'formatting', 'variables'], ARRAY['py_challenge_04'], true),

-- Challenge 6: User Input
('py_challenge_06', 'python', 'Kullanıcıdan Giriş Al', 'input() fonksiyonunu kullan', 6, 'code_challenge',
'{
  "instructions": [
    "Kullanıcıdan ismini iste (input)",
    "\"Merhaba, X!\" şeklinde selamla"
  ],
  "starterCode": "# Kullanıcıdan isim al\nisim = input(\"Ismin nedir? \")\n\n# Selamla\n",
  "testCases": [
    {"type": "uses_input", "description": "input() kullanılmalı"},
    {"type": "output_contains", "value": "Merhaba", "description": "Merhaba kelimesi olmalı"}
  ]
}',
'{
  "language": "python",
  "showOutput": true,
  "runnable": true,
  "simulateInput": "Ahmet"
}',
'{
  "mustContain": ["input", "print"],
  "passingTests": 2
}',
'isim = input("Ismin nedir? ")\nprint(f"Merhaba, {isim}!")',
'["İpucu 1: input() ile kullanıcıdan al", "İpucu 2: f-string ile selamla"]',
25, 12, 2, ARRAY['input', 'interaction', 'f-string'], ARRAY['py_challenge_05'], true),

-- Challenge 7: If Statement
('py_challenge_07', 'python', 'Yaş Kontrolü', 'if-else ile yaş kontrolü yap', 7, 'code_challenge',
'{
  "instructions": [
    "yas değişkeni oluştur",
    "Eğer 18 veya üzeri ise \"Yetiskinsin\" yaz",
    "Değilse \"Cocuksun\" yaz"
  ],
  "starterCode": "yas = 16\n\n# if-else kontrolü yap\n",
  "testCases": [
    {"type": "contains_if", "description": "if kullanılmalı"},
    {"type": "contains_else", "description": "else kullanılmalı"},
    {"type": "output_not_empty", "description": "Çıktı olmalı"}
  ]
}',
'{
  "language": "python",
  "showOutput": true,
  "runnable": true
}',
'{
  "mustContain": ["if", "else", ">="],
  "passingTests": 3
}',
'yas = 16\nif yas >= 18:\n    print("Yetiskinsin")\nelse:\n    print("Cocuksun")',
'["İpucu 1: if yas >= 18: kullan", "İpucu 2: else: ile alternatif durum", "İpucu 3: Girinti (indent) kullanmayı unutma"]',
30, 15, 2, ARRAY['if-else', 'conditions', 'comparison'], ARRAY['py_challenge_06'], true),

-- Challenge 8: For Loop
('py_challenge_08', 'python', 'Döngü ile Sayma', 'for loop kullanarak 1-5 arası say', 8, 'code_challenge',
'{
  "instructions": [
    "for döngüsü kullan",
    "range(1, 6) ile 1-5 arası dön",
    "Her sayıyı ekrana yazdır"
  ],
  "starterCode": "# for döngüsü oluştur\n",
  "testCases": [
    {"type": "contains_for", "description": "for döngüsü kullanılmalı"},
    {"type": "output_contains", "value": "1", "description": "Çıktıda 1 olmalı"},
    {"type": "output_contains", "value": "5", "description": "Çıktıda 5 olmalı"}
  ]
}',
'{
  "language": "python",
  "showOutput": true,
  "runnable": true
}',
'{
  "mustContain": ["for", "range", "print"],
  "passingTests": 3
}',
'for i in range(1, 6):\n    print(i)',
'["İpucu 1: for i in range(1, 6): kullan", "İpucu 2: print(i) ile her sayıyı yazdır", "İpucu 3: Girinti kullan"]',
30, 15, 2, ARRAY['for-loop', 'range', 'iteration'], ARRAY['py_challenge_07'], true),

-- Challenge 9: List Creation
('py_challenge_09', 'python', 'Liste Oluştur', 'Python listesi oluştur ve yazdır', 9, 'code_challenge',
'{
  "instructions": [
    "meyveler adında bir liste oluştur",
    "İçine 3 meyve ismi ekle",
    "Listeyi ekrana yazdır"
  ],
  "starterCode": "# Liste oluştur\nmeyveler = \n\n# Yazdır\n",
  "testCases": [
    {"type": "variable_type", "name": "meyveler", "value": "list", "description": "meyveler bir liste olmalı"},
    {"type": "list_length", "name": "meyveler", "min": 3, "description": "En az 3 eleman olmalı"}
  ]
}',
'{
  "language": "python",
  "showOutput": true,
  "runnable": true
}',
'{
  "mustContain": ["meyveler", "[", "]", "print"],
  "passingTests": 2
}',
'meyveler = ["elma", "armut", "muz"]\nprint(meyveler)',
'["İpucu 1: [] ile liste oluştur", "İpucu 2: Virgül ile ayır", "İpucu 3: meyveler = [\"elma\", \"armut\", \"muz\"]"]',
25, 12, 2, ARRAY['list', 'data-structures', 'array'], ARRAY['py_challenge_08'], true),

-- Challenge 10: Function Definition
('py_challenge_10', 'python', 'Fonksiyon Yaz', 'Selamlama fonksiyonu oluştur', 10, 'code_challenge',
'{
  "instructions": [
    "selamla adında fonksiyon oluştur",
    "isim parametresi alsın",
    "\"Merhaba, X!\" döndürsün"
  ],
  "starterCode": "# Fonksiyonu tanımla\ndef selamla(isim):\n    # Buraya kod yaz\n    \n\n# Fonksiyonu test et\nprint(selamla(\"Ahmet\"))",
  "testCases": [
    {"type": "function_exists", "value": "selamla", "description": "selamla fonksiyonu tanımlanmalı"},
    {"type": "function_returns", "value": "str", "description": "String döndürmeli"},
    {"type": "output_contains", "value": "Merhaba", "description": "Merhaba içermeli"}
  ]
}',
'{
  "language": "python",
  "showOutput": true,
  "runnable": true
}',
'{
  "mustContain": ["def", "selamla", "return"],
  "passingTests": 3
}',
'def selamla(isim):\n    return f"Merhaba, {isim}!"\n\nprint(selamla("Ahmet"))',
'["İpucu 1: def selamla(isim): ile başla", "İpucu 2: return ile değer döndür", "İpucu 3: f-string kullan"]',
35, 20, 3, ARRAY['function', 'def', 'return', 'parameters'], ARRAY['py_challenge_09'], true);

COMMIT;

-- =============================================
-- VERIFY INSERTION
-- =============================================
SELECT
  id,
  title,
  lesson_type,
  difficulty,
  xp_reward,
  estimated_minutes
FROM interactive_lessons
WHERE course_id = 'python'
ORDER BY lesson_order;

-- Summary
SELECT
  lesson_type,
  COUNT(*) as count,
  SUM(xp_reward) as total_xp
FROM interactive_lessons
WHERE course_id = 'python'
GROUP BY lesson_type;
