-- ============================================
-- JAVA CHALLENGES (1-20)
-- Creating complete Java curriculum from scratch
-- Total: 20 challenges, ~695 XP
-- Topics: Basics → OOP → Collections → Projects
-- ============================================

-- TEMEL SEVİYE (1-8) --

-- Challenge 1: Hello World
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
  'java-001-hello-world',
  'java',
  'İlk Java Programın - Hello World',
  'System.out.println ile ekrana yazma',
  'code_challenge',
  1,
  8,
  10,
  1,
  '{
    "language": "java",
    "starterCode": "public class Main {\n    public static void main(String[] args) {\n        // \"Merhaba Dünya!\" yazdır\n        \n    }\n}",
    "instructions": [
      "System.out.println() kullan",
      "Çift tırnak içinde metin yaz",
      "Noktalı virgül ile bitir",
      "Java case-sensitive!"
    ],
    "testCases": [
      {
        "type": "output_exact",
        "value": "Merhaba Dünya!",
        "description": "Çıktı tam olmalı"
      },
      {
        "type": "code_contains",
        "value": "System.out.println",
        "description": "println kullanılmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": true,
    "mustContainKeywords": ["System.out.println"],
    "bannedKeywords": []
  }',
  '["System.out.println(\"Merhaba Dünya!\");", "Her statement noktalı virgülle biter", "Java''da class ve method gereklidir"]'::jsonb,
  true
);

-- Challenge 2: Variables
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
  'java-002-variables',
  'java',
  'Değişkenler - int ve String',
  'Değişken tanımlama ve kullanma',
  'code_challenge',
  1,
  10,
  15,
  2,
  '{
    "language": "java",
    "starterCode": "public class Main {\n    public static void main(String[] args) {\n        // İsim değişkeni (String)\n        \n        \n        // Yaş değişkeni (int)\n        \n        \n        // Yazdır\n        System.out.println(\"Adım: \" + isim);\n        System.out.println(\"Yaşım: \" + yas);\n    }\n}",
    "instructions": [
      "String isim = \"Ali\";",
      "int yas = 15;",
      "Değişkenleri yazdır",
      "+ ile string birleştirme"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "String",
        "description": "String değişken olmalı"
      },
      {
        "type": "code_contains",
        "value": "int",
        "description": "int değişken olmalı"
      },
      {
        "type": "output_contains",
        "value": "Adım:",
        "description": "İsim yazdırılmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["String", "int"],
    "bannedKeywords": []
  }',
  '["Java strongly typed: tip belirt", "String isim = \"değer\";", "int yas = 15;", "+ operatörü string birleştirme"]'::jsonb,
  true
);

-- Challenge 3: Math Operations
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
  'java-003-math-operations',
  'java',
  'Matematik İşlemleri - Hesap Makinesi',
  '+, -, *, / operatörleri',
  'code_challenge',
  1,
  12,
  15,
  3,
  '{
    "language": "java",
    "starterCode": "public class Main {\n    public static void main(String[] args) {\n        int a = 20;\n        int b = 5;\n        \n        // Toplama\n        int toplam = a + b;\n        \n        // Diğer işlemleri yap\n        \n        \n        System.out.println(\"Toplam: \" + toplam);\n        // Diğerlerini de yazdır\n    }\n}",
    "instructions": [
      "toplam = a + b",
      "fark = a - b",
      "carpim = a * b",
      "bolum = a / b"
    ],
    "testCases": [
      {
        "type": "output_contains",
        "value": "Toplam: 25",
        "description": "Toplam doğru olmalı"
      },
      {
        "type": "code_contains",
        "value": "+",
        "description": "Toplama olmalı"
      },
      {
        "type": "code_contains",
        "value": "*",
        "description": "Çarpma olmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["+", "-", "*", "/"],
    "bannedKeywords": []
  }',
  '["+ toplama", "- çıkarma", "* çarpma", "/ bölme", "% modulo (kalan)"]'::jsonb,
  true
);

-- Challenge 4: Scanner Input
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
  'java-004-scanner-input',
  'java',
  'Kullanıcıdan Giriş - Scanner',
  'Scanner sınıfı ile input alma',
  'code_challenge',
  1,
  15,
  20,
  4,
  '{
    "language": "java",
    "starterCode": "import java.util.Scanner;\n\npublic class Main {\n    public static void main(String[] args) {\n        Scanner scanner = new Scanner(System.in);\n        \n        System.out.print(\"Adını gir: \");\n        // String girişi al\n        \n        \n        System.out.print(\"Yaşını gir: \");\n        // int girişi al\n        \n        \n        System.out.println(\"Merhaba \" + isim + \", \" + yas + \" yaşındasın.\");\n        \n        scanner.close();\n    }\n}",
    "instructions": [
      "import java.util.Scanner; ile import et",
      "Scanner scanner = new Scanner(System.in);",
      "String isim = scanner.nextLine();",
      "int yas = scanner.nextInt();"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "Scanner",
        "description": "Scanner kullanılmalı"
      },
      {
        "type": "code_contains",
        "value": "nextLine",
        "description": "nextLine() olmalı"
      },
      {
        "type": "code_contains",
        "value": "nextInt",
        "description": "nextInt() olmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["Scanner", "nextLine", "nextInt"],
    "bannedKeywords": []
  }',
  '["nextLine() String okur", "nextInt() int okur", "next() tek kelime okur", "scanner.close() ile kapat"]'::jsonb,
  true
);

-- Challenge 5: If-Else
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
  'java-005-if-else',
  'java',
  'If-Else - Yaş Kontrolü',
  'Koşullu ifadeler',
  'code_challenge',
  2,
  15,
  20,
  5,
  '{
    "language": "java",
    "starterCode": "public class Main {\n    public static void main(String[] args) {\n        int yas = 16;\n        \n        // Yaş kontrolü\n        if (yas >= 18) {\n            // 18 ve üstü\n        } else {\n            // 18''den küçük\n        }\n    }\n}",
    "instructions": [
      "if (koşul) { } kontrolü",
      "else { } alternatif",
      ">=, <=, ==, != karşılaştırma operatörleri",
      "18 ve üstü \"Reşitsin\", altı \"Reşit değilsin\""
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "if",
        "description": "if kontrolü olmalı"
      },
      {
        "type": "code_contains",
        "value": "else",
        "description": "else bloğu olmalı"
      },
      {
        "type": "output_contains",
        "value": "Reşit",
        "description": "Çıktı üretilmeli"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["if", "else"],
    "bannedKeywords": []
  }',
  '["if (koşul) süslü parantez", "== eşitlik kontrolü", "!= eşit değil", "&& ve, || veya mantıksal operatörler"]'::jsonb,
  true
);

-- Challenge 6: Switch Case
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
  'java-006-switch-case',
  'java',
  'Switch-Case - Gün İsimleri',
  'Çoklu seçim yapısı',
  'code_challenge',
  2,
  15,
  25,
  6,
  '{
    "language": "java",
    "starterCode": "public class Main {\n    public static void main(String[] args) {\n        int gun = 3;\n        \n        switch (gun) {\n            case 1:\n                // Pazartesi\n                break;\n            case 2:\n                // Salı\n                break;\n            // Diğer günleri ekle\n            \n            default:\n                System.out.println(\"Geçersiz gün\");\n        }\n    }\n}",
    "instructions": [
      "switch (değişken) { }",
      "case değer: komutlar break;",
      "default: varsayılan durum",
      "7 günü tanımla (1-7)"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "switch",
        "description": "switch kullanılmalı"
      },
      {
        "type": "code_contains",
        "value": "case",
        "description": "case bloğu olmalı"
      },
      {
        "type": "code_contains",
        "value": "break",
        "description": "break kullanılmalı"
      },
      {
        "type": "code_contains",
        "value": "default",
        "description": "default bloğu olmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["switch", "case", "break", "default"],
    "bannedKeywords": []
  }',
  '["Her case''den sonra break", "break olmazsa fall-through olur", "default opsiyonel ama önerilen", "switch sadece int, String, enum ile çalışır"]'::jsonb,
  true
);

-- Challenge 7: For Loop
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
  'java-007-for-loop',
  'java',
  'For Döngüsü - 1''den 10''a Sayma',
  'Döngü yapısı',
  'code_challenge',
  2,
  15,
  25,
  7,
  '{
    "language": "java",
    "starterCode": "public class Main {\n    public static void main(String[] args) {\n        // 1''den 10''a kadar say\n        for (int i = 1; i <= 10; i++) {\n            // Sayıları yazdır\n        }\n    }\n}",
    "instructions": [
      "for (başlangıç; koşul; artış) { }",
      "int i = 1; başlangıç",
      "i <= 10; koşul",
      "i++; artış (i = i + 1)"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "for",
        "description": "for döngüsü olmalı"
      },
      {
        "type": "output_contains",
        "value": "1",
        "description": "1 yazdırılmalı"
      },
      {
        "type": "output_contains",
        "value": "10",
        "description": "10 yazdırılmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["for"],
    "bannedKeywords": []
  }',
  '["for (int i = 0; i < 10; i++)", "i++ = i artı 1", "i-- = i eksi 1", "Kaç kez çalışacağı belli ise for kullan"]'::jsonb,
  true
);

-- Challenge 8: While Loop
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
  'java-008-while-loop',
  'java',
  'While Döngüsü - Sayı Tahmin',
  'Koşul sağlandığı sürece döngü',
  'code_challenge',
  2,
  15,
  25,
  8,
  '{
    "language": "java",
    "starterCode": "public class Main {\n    public static void main(String[] args) {\n        int sayi = 1;\n        \n        // 10''dan küçük olduğu sürece\n        while (sayi < 10) {\n            System.out.println(sayi);\n            // sayıyı artır\n        }\n    }\n}",
    "instructions": [
      "while (koşul) { }",
      "Koşul true olduğu sürece çalışır",
      "sayi++; ile artır",
      "Sonsuz döngüden kaçın!"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "while",
        "description": "while döngüsü olmalı"
      },
      {
        "type": "code_contains",
        "value": "++",
        "description": "Artış olmalı"
      },
      {
        "type": "output_contains",
        "value": "9",
        "description": "9''a kadar saymalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["while"],
    "bannedKeywords": []
  }',
  '["while koşul kontrolü yapar", "İçerde değişkeni güncelle", "do-while en az 1 kez çalışır", "Kaç kez çalışacağı belli değilse while kullan"]'::jsonb,
  true
);

-- ORTA SEVİYE (9-14) --

-- Challenge 9: Arrays
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
  'java-009-arrays',
  'java',
  'Diziler - Array Tanımlama',
  'Sabit boyutlu diziler',
  'code_challenge',
  2,
  15,
  30,
  9,
  '{
    "language": "java",
    "starterCode": "public class Main {\n    public static void main(String[] args) {\n        // 5 elemanlı int dizisi\n        int[] notlar = new int[5];\n        \n        // Değer ata\n        notlar[0] = 85;\n        notlar[1] = 90;\n        // Diğerlerini de ata\n        \n        // Yazdır\n        System.out.println(\"İlk not: \" + notlar[0]);\n    }\n}",
    "instructions": [
      "int[] dizi = new int[boyut];",
      "dizi[0] ilk eleman (0-indexed)",
      "5 notun hepsini ata",
      "Tüm notları yazdır"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "int[]",
        "description": "Array tanımı olmalı"
      },
      {
        "type": "code_contains",
        "value": "new int",
        "description": "new ile oluşturulmalı"
      },
      {
        "type": "code_contains",
        "value": "[0]",
        "description": "Index kullanılmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["int[]", "new"],
    "bannedKeywords": []
  }',
  '["int[] dizi = new int[5];", "Indexleme 0''dan başlar", "dizi.length ile boyut", "String[] strDizi = {\"a\", \"b\"};"]'::jsonb,
  true
);

-- Challenge 10: Array Operations
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
  'java-010-array-operations',
  'java',
  'Dizi İşlemleri - For-Each & Length',
  'Dizi döngüsü ve işlemleri',
  'code_challenge',
  2,
  18,
  30,
  10,
  '{
    "language": "java",
    "starterCode": "public class Main {\n    public static void main(String[] args) {\n        int[] sayilar = {10, 20, 30, 40, 50};\n        \n        // Toplam hesapla\n        int toplam = 0;\n        for (int sayi : sayilar) {\n            // Toplama ekle\n        }\n        \n        System.out.println(\"Toplam: \" + toplam);\n        System.out.println(\"Ortalama: \" + (toplam / sayilar.length));\n    }\n}",
    "instructions": [
      "for (tip eleman : dizi) for-each döngüsü",
      "toplam += sayi; ile topla",
      "sayilar.length ile boyut",
      "Ortalama = toplam / length"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "for",
        "description": "for-each kullanılmalı"
      },
      {
        "type": "code_contains",
        "value": "length",
        "description": "length kullanılmalı"
      },
      {
        "type": "output_contains",
        "value": "150",
        "description": "Toplam 150 olmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["for", "length"],
    "bannedKeywords": []
  }',
  '["for-each = for (int x : array)", "length property (not method!)", "Arrays.sort(array) ile sıralama", "Arrays.toString(array) ile yazdırma"]'::jsonb,
  true
);

-- Challenge 11: Methods
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
  'java-011-methods',
  'java',
  'Metodlar - Fonksiyon Yazma',
  'static void metodlar',
  'code_challenge',
  3,
  20,
  35,
  11,
  '{
    "language": "java",
    "starterCode": "public class Main {\n    \n    // Selamlama metodu\n    public static void selamla(String isim) {\n        // Selamlama mesajı yazdır\n    }\n    \n    public static void main(String[] args) {\n        // Metodu çağır\n        selamla(\"Ali\");\n        selamla(\"Ayşe\");\n    }\n}",
    "instructions": [
      "public static void metodAdi(parametreler) { }",
      "void = değer döndürmez",
      "Parametre alabilir",
      "main dışında tanımla, main içinde çağır"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "public static void",
        "description": "Method tanımı olmalı"
      },
      {
        "type": "code_contains",
        "value": "selamla(",
        "description": "Method çağrılmalı"
      },
      {
        "type": "output_contains",
        "value": "Merhaba",
        "description": "Selamlama yazdırılmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["public static void"],
    "bannedKeywords": []
  }',
  '["Method main''den önce/sonra tanımlanır", "static = nesne oluşturmadan çağrılır", "void = return yok", "Parametreler virgülle ayrılır"]'::jsonb,
  true
);

-- Challenge 12: Method Return
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
  'java-012-method-return',
  'java',
  'Return - Değer Döndüren Metodlar',
  'Hesaplama yapıp sonuç döndürme',
  'code_challenge',
  3,
  20,
  35,
  12,
  '{
    "language": "java",
    "starterCode": "public class Main {\n    \n    // Toplama metodu\n    public static int topla(int a, int b) {\n        // Toplamı döndür\n        \n    }\n    \n    public static void main(String[] args) {\n        int sonuc = topla(5, 3);\n        System.out.println(\"Sonuç: \" + sonuc);\n    }\n}",
    "instructions": [
      "public static int metodAdi() - int döndürür",
      "return değer; ile döndür",
      "sonuc = metod(); ile yakala",
      "Return tipi void değil"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "public static int",
        "description": "int döndüren method olmalı"
      },
      {
        "type": "code_contains",
        "value": "return",
        "description": "return olmalı"
      },
      {
        "type": "output_exact",
        "value": "Sonuç: 8",
        "description": "8 yazdırılmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": true,
    "mustContainKeywords": ["return"],
    "bannedKeywords": []
  }',
  '["Return tipi void değilse return gerekli", "public static int topla()", "return a + b;", "Return değeri değişkene atanabilir"]'::jsonb,
  true
);

-- Challenge 13: String Methods
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
  'java-013-string-methods',
  'java',
  'String Metodları - Metin İşleme',
  'length, substring, toUpperCase',
  'code_challenge',
  2,
  18,
  30,
  13,
  '{
    "language": "java",
    "starterCode": "public class Main {\n    public static void main(String[] args) {\n        String metin = \"Merhaba Dünya\";\n        \n        // Uzunluk\n        int uzunluk = metin.length();\n        \n        // Büyük harf\n        \n        \n        // Alt string (0-7)\n        \n        \n        System.out.println(\"Uzunluk: \" + uzunluk);\n    }\n}",
    "instructions": [
      "length() - uzunluk",
      "toUpperCase() - büyük harf",
      "substring(başlangıç, bitiş)",
      "charAt(index) - karakter"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "length()",
        "description": "length() kullanılmalı"
      },
      {
        "type": "code_contains",
        "value": "toUpperCase",
        "description": "toUpperCase() kullanılmalı"
      },
      {
        "type": "code_contains",
        "value": "substring",
        "description": "substring() kullanılmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["length()", "toUpperCase", "substring"],
    "bannedKeywords": []
  }',
  '["String immutable (değiştirilemez)", "Metodlar yeni String döndürür", "toLowerCase(), trim(), replace()", "equals() ile karşılaştırma (== değil!)"]'::jsonb,
  true
);

-- Challenge 14: ArrayList
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
  'java-014-arraylist',
  'java',
  'ArrayList - Dinamik Liste',
  'Değişken boyutlu liste',
  'code_challenge',
  3,
  20,
  40,
  14,
  '{
    "language": "java",
    "starterCode": "import java.util.ArrayList;\n\npublic class Main {\n    public static void main(String[] args) {\n        // ArrayList oluştur\n        ArrayList<String> isimler = new ArrayList<>();\n        \n        // Eleman ekle\n        isimler.add(\"Ali\");\n        // 4 isim daha ekle\n        \n        \n        // Yazdır\n        System.out.println(isimler);\n        \n        // Eleman sil\n        \n    }\n}",
    "instructions": [
      "import java.util.ArrayList;",
      "ArrayList<Tip> liste = new ArrayList<>();",
      "add() - eleman ekle",
      "remove() - eleman sil",
      "size() - boyut"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "ArrayList",
        "description": "ArrayList kullanılmalı"
      },
      {
        "type": "code_contains",
        "value": "add",
        "description": "add() kullanılmalı"
      },
      {
        "type": "code_contains",
        "value": "remove",
        "description": "remove() kullanılmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["ArrayList", "add", "remove"],
    "bannedKeywords": []
  }',
  '["ArrayList dinamik boyutlu", "<String> generic tip", "add(), remove(), get(), set()", "size() method (length değil!)"]'::jsonb,
  true
);

-- İLERİ SEVİYE (15-20) --

-- Challenge 15: OOP Basics
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
  'java-015-oop-basics',
  'java',
  'OOP - İlk Sınıfın (Class)',
  'Class ve nesne (object) oluşturma',
  'code_challenge',
  4,
  25,
  45,
  15,
  '{
    "language": "java",
    "starterCode": "// Araba sınıfı\nclass Araba {\n    // Özellikler (fields)\n    String marka;\n    String model;\n    int yil;\n    \n    // Bilgileri göster\n    void bilgiGoster() {\n        System.out.println(marka + \" \" + model + \" (\" + yil + \")\");\n    }\n}\n\npublic class Main {\n    public static void main(String[] args) {\n        // Nesne oluştur\n        Araba araba1 = new Araba();\n        araba1.marka = \"Toyota\";\n        // Diğer özellikleri ata\n        \n        araba1.bilgiGoster();\n    }\n}",
    "instructions": [
      "class ile sınıf tanımla",
      "Araba araba1 = new Araba(); ile nesne",
      "araba1.marka ile erişim",
      "araba1.bilgiGoster(); ile metod çağır"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "class Araba",
        "description": "Class tanımı olmalı"
      },
      {
        "type": "code_contains",
        "value": "new Araba",
        "description": "Nesne oluşturulmalı"
      },
      {
        "type": "output_contains",
        "value": "Toyota",
        "description": "Bilgi yazdırılmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["class", "new"],
    "bannedKeywords": []
  }',
  '["Class = blueprint (taslak)", "Object = instance (örnek)", "new ile nesne oluştur", "Nokta ile field/method erişimi"]'::jsonb,
  true
);

-- Challenge 16: Constructor
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
  'java-016-constructor',
  'java',
  'Constructor - Yapıcı Metod',
  'Nesne oluşturulurken çalışan metod',
  'code_challenge',
  4,
  25,
  45,
  16,
  '{
    "language": "java",
    "starterCode": "class Ogrenci {\n    String ad;\n    int yas;\n    \n    // Constructor\n    Ogrenci(String ad, int yas) {\n        // this.ad ile field, ad ile parametre\n        \n    }\n    \n    void bilgiYazdir() {\n        System.out.println(ad + \" - \" + yas + \" yaşında\");\n    }\n}\n\npublic class Main {\n    public static void main(String[] args) {\n        // Constructor ile oluştur\n        Ogrenci ogrenci1 = new Ogrenci(\"Ali\", 15);\n        ogrenci1.bilgiYazdir();\n    }\n}",
    "instructions": [
      "Constructor = sınıf ismiyle aynı",
      "Return type yok",
      "this.field = parametre;",
      "new Ogrenci(\"Ali\", 15) ile çağrılır"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "Ogrenci(",
        "description": "Constructor olmalı"
      },
      {
        "type": "code_contains",
        "value": "this.",
        "description": "this kullanılmalı"
      },
      {
        "type": "output_contains",
        "value": "Ali",
        "description": "Bilgi yazdırılmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["this"],
    "bannedKeywords": []
  }',
  '["Constructor nesne oluşturulurken çalışır", "this.field field''ı işaret eder", "Overloading: birden fazla constructor", "Default constructor otomatik oluşur"]'::jsonb,
  true
);

-- Challenge 17: Inheritance
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
  'java-017-inheritance',
  'java',
  'Kalıtım - Inheritance',
  'Üst sınıftan miras alma',
  'code_challenge',
  4,
  28,
  50,
  17,
  '{
    "language": "java",
    "starterCode": "// Ana sınıf\nclass Hayvan {\n    void sesCikar() {\n        System.out.println(\"Hayvan ses çıkarıyor\");\n    }\n}\n\n// Alt sınıf\nclass Kedi extends Hayvan {\n    // Override et\n    @Override\n    void sesCikar() {\n        System.out.println(\"Miyav!\");\n    }\n}\n\npublic class Main {\n    public static void main(String[] args) {\n        Kedi kedi = new Kedi();\n        kedi.sesCikar();\n    }\n}",
    "instructions": [
      "extends ile miras al",
      "@Override ile üst metodları değiştir",
      "super ile üst sınıfa erişim",
      "Kedi Hayvan''dan miras alır"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "extends",
        "description": "extends kullanılmalı"
      },
      {
        "type": "code_contains",
        "value": "@Override",
        "description": "@Override olmalı"
      },
      {
        "type": "output_exact",
        "value": "Miyav!",
        "description": "Miyav yazdırılmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": true,
    "mustContainKeywords": ["extends", "@Override"],
    "bannedKeywords": []
  }',
  '["class B extends A - B, A''dan miras alır", "@Override üst metodları değiştirir", "super.metod() üst sınıf metodunu çağırır", "Java single inheritance (bir üstten)"]'::jsonb,
  true
);

-- Challenge 18: Encapsulation
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
  'java-018-encapsulation',
  'java',
  'Kapsülleme - Getter/Setter',
  'private field, public method',
  'code_challenge',
  4,
  25,
  45,
  18,
  '{
    "language": "java",
    "starterCode": "class Hesap {\n    private double bakiye;\n    \n    // Constructor\n    public Hesap(double bakiye) {\n        this.bakiye = bakiye;\n    }\n    \n    // Getter\n    public double getBakiye() {\n        // bakiye''yi döndür\n    }\n    \n    // Setter\n    public void setBakiye(double bakiye) {\n        if (bakiye >= 0) {\n            // bakiye''yi güncelle\n        }\n    }\n}\n\npublic class Main {\n    public static void main(String[] args) {\n        Hesap hesap = new Hesap(1000);\n        System.out.println(\"Bakiye: \" + hesap.getBakiye());\n    }\n}",
    "instructions": [
      "private ile field''ları gizle",
      "public getter/setter ile eriş",
      "get + FieldName formatı",
      "set + FieldName formatı"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "private",
        "description": "private field olmalı"
      },
      {
        "type": "code_contains",
        "value": "public",
        "description": "public method olmalı"
      },
      {
        "type": "code_contains",
        "value": "get",
        "description": "getter olmalı"
      },
      {
        "type": "code_contains",
        "value": "set",
        "description": "setter olmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["private", "public", "get", "set"],
    "bannedKeywords": []
  }',
  '["Encapsulation = veri gizleme", "private field, public getter/setter", "Setter''da validation eklenebilir", "Access modifiers: public, private, protected, default"]'::jsonb,
  true
);

-- Challenge 19: Exception Handling
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
  'java-019-exception-handling',
  'java',
  'Hata Yönetimi - Try-Catch',
  'Exception yakalama ve işleme',
  'code_challenge',
  4,
  25,
  50,
  19,
  '{
    "language": "java",
    "starterCode": "public class Main {\n    public static void main(String[] args) {\n        int[] sayilar = {1, 2, 3};\n        \n        try {\n            // Hata oluşabilecek kod\n            System.out.println(sayilar[5]);  // ArrayIndexOutOfBoundsException\n        } catch (ArrayIndexOutOfBoundsException e) {\n            // Hata yakalandı\n            \n        } finally {\n            // Her zaman çalışır\n            System.out.println(\"İşlem tamamlandı\");\n        }\n    }\n}",
    "instructions": [
      "try { } riskli kod",
      "catch (ExceptionType e) { } yakala",
      "finally { } her zaman çalışır",
      "e.getMessage() hata mesajı"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "try",
        "description": "try bloğu olmalı"
      },
      {
        "type": "code_contains",
        "value": "catch",
        "description": "catch bloğu olmalı"
      },
      {
        "type": "code_contains",
        "value": "finally",
        "description": "finally bloğu olmalı"
      },
      {
        "type": "output_contains",
        "value": "tamamlandı",
        "description": "finally çalışmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["try", "catch", "finally"],
    "bannedKeywords": []
  }',
  '["try-catch hata yönetimi", "catch birden fazla olabilir", "finally opsiyonel", "throw ile hata fırlatma", "Common exceptions: NullPointerException, ArrayIndexOutOfBoundsException"]'::jsonb,
  true
);

-- Challenge 20: Mini Project - Student Management
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
  'java-020-student-management',
  'java',
  'Mini Proje - Öğrenci Yönetim Sistemi',
  'Tüm Java bilgilerini kullan',
  'code_challenge',
  4,
  35,
  60,
  20,
  '{
    "language": "java",
    "starterCode": "import java.util.ArrayList;\n\nclass Ogrenci {\n    private String ad;\n    private int numara;\n    private ArrayList<Integer> notlar;\n    \n    // Constructor, getter/setter, metodlar ekle\n    \n}\n\npublic class Main {\n    public static void main(String[] args) {\n        ArrayList<Ogrenci> ogrenciler = new ArrayList<>();\n        \n        // 3 öğrenci ekle\n        \n        \n        // Öğrenci bilgilerini yazdır\n        \n    }\n}",
    "instructions": [
      "Ogrenci sınıfı: ad, numara, notlar",
      "Constructor, getter/setter ekle",
      "ortalamaHesapla() metodu",
      "ArrayList<Ogrenci> ile öğrencileri tut",
      "Tüm kavramları birleştir"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "class Ogrenci",
        "description": "Ogrenci sınıfı olmalı"
      },
      {
        "type": "code_contains",
        "value": "private",
        "description": "Encapsulation olmalı"
      },
      {
        "type": "code_contains",
        "value": "ArrayList",
        "description": "ArrayList kullanılmalı"
      },
      {
        "type": "line_count_min",
        "value": 40,
        "description": "En az 40 satır kod"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["class", "private", "ArrayList", "get", "set"],
    "isProject": true
  }',
  '["OOP prensiplerini uygula", "Encapsulation kullan", "ArrayList ile öğrenci listesi", "Ortalama hesaplama metodu ekle", "Tüm öğrendiklerini birleştir"]'::jsonb,
  true
);

-- ============================================
-- JAVA CHALLENGES SUMMARY
-- ============================================
-- Total: 20 new challenges (#1-20)
-- Total Java XP: 695 XP
-- Difficulty range: 1-4 (Kolay → Çok Zor)
-- Topics: Basics, Control Flow, OOP, Collections, Exception Handling
-- Complete curriculum: Hello World → Mini Project
-- ============================================
