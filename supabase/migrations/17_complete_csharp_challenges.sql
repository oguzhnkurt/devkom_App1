-- =============================================
-- C# CHALLENGES - Part 2 (Challenges 11-20)
-- =============================================
-- Completing the C# curriculum with OOP and advanced topics
-- Total: 10 new challenges (+480 XP)

-- Challenge 11: Methods - Topla Fonksiyonu
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
  'csharp-011-methods',
  'csharp',
  'Metodlar - Toplama Fonksiyonu',
  'Method oluştur ve kullan',
  'code_challenge',
  2,
  12,
  30,
  11,
  '{
    "language": "csharp",
    "starterCode": "using System;\n\nclass Program\n{\n    // Topla metodu yaz (iki int parametre, int döndürür)\n    \n    \n    static void Main()\n    {\n        int sonuc = Topla(5, 3);\n        Console.WriteLine($\"Toplam: {sonuc}\");\n    }\n}",
    "instructions": [
      "static int Topla(int a, int b) metodu oluştur",
      "İki parametreyi topla",
      "return ile sonucu döndür",
      "Main''de çağır ve yazdır"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "static int Topla",
        "description": "Topla metodu tanımlanmalı"
      },
      {
        "type": "code_contains",
        "value": "return",
        "description": "return kullanılmalı"
      },
      {
        "type": "output_contains",
        "value": "8",
        "description": "5+3=8 olmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["static", "int", "Topla", "return"],
    "bannedKeywords": []
  }',
  '["static int Topla(int a, int b) şeklinde yaz", "return a + b; ile toplamı döndür", "Main içinde Topla(5, 3) çağır"]'::jsonb,
  true
);

-- Challenge 12: Method Return - Çift mi Kontrol
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
  'csharp-012-method-return',
  'csharp',
  'Return - Çift Sayı Kontrolü',
  'bool döndüren method yaz',
  'code_challenge',
  2,
  15,
  35,
  12,
  '{
    "language": "csharp",
    "starterCode": "using System;\n\nclass Program\n{\n    static bool CiftMi(int sayi)\n    {\n        // Çift ise true, tek ise false döndür\n        \n    }\n    \n    static void Main()\n    {\n        Console.WriteLine(CiftMi(4));  // True\n        Console.WriteLine(CiftMi(7));  // False\n    }\n}",
    "instructions": [
      "sayi % 2 == 0 kontrolü yap",
      "Çift ise true döndür",
      "Tek ise false döndür",
      "return ile değeri döndür"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "%",
        "description": "Mod operatörü kullanılmalı"
      },
      {
        "type": "code_contains",
        "value": "return",
        "description": "return kullanılmalı"
      },
      {
        "type": "output_contains",
        "value": "True",
        "description": "4 çift, True dönmeli"
      },
      {
        "type": "output_contains",
        "value": "False",
        "description": "7 tek, False dönmeli"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["%", "return", "bool"],
    "bannedKeywords": []
  }',
  '["return (sayi % 2 == 0); tek satırda yapabilirsin", "% 2 == 0 kontrolü çift sayı verir", "bool değer direkt return edilebilir"]'::jsonb,
  true
);

-- Challenge 13: String Methods - ToUpper, ToLower
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
  'csharp-013-string-methods',
  'csharp',
  'String Metodları - Büyük/Küçük Harf',
  'ToUpper, ToLower, Contains kullan',
  'code_challenge',
  2,
  15,
  30,
  13,
  '{
    "language": "csharp",
    "starterCode": "using System;\n\nclass Program\n{\n    static void Main()\n    {\n        string isim = \"Ahmet Yılmaz\";\n        \n        // Büyük harfe çevir\n        \n        \n        // Küçük harfe çevir\n        \n        \n        // \"Ahmet\" kelimesini içeriyor mu?\n        \n    }\n}",
    "instructions": [
      "isim.ToUpper() ile büyük harf yap",
      "isim.ToLower() ile küçük harf yap",
      "isim.Contains(\"Ahmet\") ile kontrol et",
      "Sonuçları Console.WriteLine ile yazdır"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "ToUpper",
        "description": "ToUpper() kullanılmalı"
      },
      {
        "type": "code_contains",
        "value": "ToLower",
        "description": "ToLower() kullanılmalı"
      },
      {
        "type": "code_contains",
        "value": "Contains",
        "description": "Contains() kullanılmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["ToUpper", "ToLower", "Contains"],
    "bannedKeywords": []
  }',
  '["string.ToUpper() büyük harf yapar", "string.ToLower() küçük harf yapar", "string.Contains(\"metin\") bool döner"]'::jsonb,
  true
);

-- Challenge 14: List<T> - Generic List
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
  'csharp-014-list-generic',
  'csharp',
  'List<T> - Öğrenci İsimleri',
  'Generic List kullan - Add, Remove, Count',
  'code_challenge',
  3,
  18,
  40,
  14,
  '{
    "language": "csharp",
    "starterCode": "using System;\nusing System.Collections.Generic;\n\nclass Program\n{\n    static void Main()\n    {\n        // List<string> oluştur\n        List<string> ogrenciler = new List<string>();\n        \n        // 3 öğrenci ismi ekle (Add kullan)\n        \n        \n        // Liste eleman sayısını yazdır\n        \n        \n        // İlk öğrenciyi sil (RemoveAt(0))\n        \n        \n        // Kalan öğrencileri foreach ile yazdır\n        \n    }\n}",
    "instructions": [
      "List<string> oluştur",
      "Add() ile 3 isim ekle",
      "Count ile eleman sayısı yazdır",
      "RemoveAt(0) ile ilk elemanı sil",
      "foreach ile kalan isimleri yazdır"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "List<string>",
        "description": "List<string> tanımlanmalı"
      },
      {
        "type": "code_contains",
        "value": "Add",
        "description": "Add() kullanılmalı"
      },
      {
        "type": "code_contains",
        "value": "RemoveAt",
        "description": "RemoveAt() kullanılmalı"
      },
      {
        "type": "code_contains",
        "value": "foreach",
        "description": "foreach ile yazdır"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["List", "Add", "RemoveAt", "foreach"],
    "bannedKeywords": []
  }',
  '["List<string> ogrenciler = new List<string>(); ile oluştur", "ogrenciler.Add(\"Ali\"); ile ekle", "foreach (string o in ogrenciler) ile döngü"]'::jsonb,
  true
);

-- Challenge 15: OOP Basics - İlk Sınıf
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
  'csharp-015-oop-class',
  'csharp',
  'OOP - İlk Sınıfın (Araba)',
  'Class, field, method kavramları',
  'code_challenge',
  3,
  20,
  45,
  15,
  '{
    "language": "csharp",
    "starterCode": "using System;\n\nclass Araba\n{\n    // Field''lar\n    public string marka;\n    public string model;\n    public int yil;\n    \n    // BilgiYazdir metodu ekle\n    \n}\n\nclass Program\n{\n    static void Main()\n    {\n        // Araba nesnesi oluştur\n        Araba araba1 = new Araba();\n        araba1.marka = \"Toyota\";\n        araba1.model = \"Corolla\";\n        araba1.yil = 2023;\n        \n        araba1.BilgiYazdir();\n    }\n}",
    "instructions": [
      "Araba class''ı içinde public void BilgiYazdir() metodu ekle",
      "Metod içinde marka, model, yil yazdır",
      "Main''de Araba nesnesi oluştur",
      "Field''ları doldur ve BilgiYazdir() çağır"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "public void BilgiYazdir",
        "description": "BilgiYazdir metodu olmalı"
      },
      {
        "type": "code_contains",
        "value": "new Araba()",
        "description": "Araba nesnesi oluşturulmalı"
      },
      {
        "type": "output_contains",
        "value": "Toyota",
        "description": "Marka yazdırılmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["class", "public", "void", "new"],
    "bannedKeywords": []
  }',
  '["public void BilgiYazdir() { } şeklinde metod ekle", "Console.WriteLine($\"{marka} {model} ({yil})\");", "Araba araba1 = new Araba(); ile nesne oluştur"]'::jsonb,
  true
);

-- Challenge 16: Constructor - Yapıcı Metod
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
  'csharp-016-constructor',
  'csharp',
  'Constructor - Yapıcı Metod',
  'Constructor ile nesne başlat',
  'code_challenge',
  3,
  20,
  45,
  16,
  '{
    "language": "csharp",
    "starterCode": "using System;\n\nclass Kitap\n{\n    public string ad;\n    public string yazar;\n    public int sayfaSayisi;\n    \n    // Constructor ekle (3 parametre alsın)\n    \n    \n    public void BilgiYazdir()\n    {\n        Console.WriteLine($\"{ad} - {yazar} ({sayfaSayisi} sayfa)\");\n    }\n}\n\nclass Program\n{\n    static void Main()\n    {\n        // Constructor ile nesne oluştur\n        Kitap kitap1 = new Kitap(\"1984\", \"George Orwell\", 328);\n        kitap1.BilgiYazdir();\n    }\n}",
    "instructions": [
      "public Kitap(string ad, string yazar, int sayfaSayisi) constructor ekle",
      "Constructor içinde this.ad = ad; ile field''ları ata",
      "Main''de new Kitap(...) ile nesne oluştur",
      "BilgiYazdir() çağır"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "public Kitap(",
        "description": "Constructor tanımlanmalı"
      },
      {
        "type": "code_contains",
        "value": "this.",
        "description": "this kullanılmalı"
      },
      {
        "type": "output_contains",
        "value": "1984",
        "description": "Kitap adı yazdırılmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["public Kitap", "this"],
    "bannedKeywords": []
  }',
  '["public Kitap(string ad, string yazar, int sayfaSayisi)", "{ this.ad = ad; this.yazar = yazar; ... }", "Constructor class ile aynı isimde olmalı"]'::jsonb,
  true
);

-- Challenge 17: Inheritance - Kalıtım
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
  'csharp-017-inheritance',
  'csharp',
  'Inheritance - Kalıtım (: base)',
  'Base class''tan türet',
  'code_challenge',
  4,
  25,
  50,
  17,
  '{
    "language": "csharp",
    "starterCode": "using System;\n\nclass Hayvan\n{\n    public string ad;\n    \n    public void SesCikar()\n    {\n        Console.WriteLine(\"Hayvan ses çıkarıyor\");\n    }\n}\n\n// Kopek class''ını Hayvan''dan türet\nclass Kopek\n{\n    // : Hayvan ekle\n    \n    public void Havla()\n    {\n        Console.WriteLine($\"{ad} havlıyor: Hav hav!\");\n    }\n}\n\nclass Program\n{\n    static void Main()\n    {\n        Kopek kopek1 = new Kopek();\n        kopek1.ad = \"Karabaş\";\n        kopek1.SesCikar();  // Hayvan''dan gelen metod\n        kopek1.Havla();     // Kendi metodu\n    }\n}",
    "instructions": [
      "class Kopek : Hayvan şeklinde türet",
      "Kopek, Hayvan''ın ad field''ını ve SesCikar metodunu miras alır",
      "Kendi Havla() metodunu ekle",
      "Main''de test et"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": ": Hayvan",
        "description": ": Hayvan ile kalıtım yapılmalı"
      },
      {
        "type": "output_contains",
        "value": "Hayvan ses",
        "description": "Base class metodu çalışmalı"
      },
      {
        "type": "output_contains",
        "value": "Hav hav",
        "description": "Türetilmiş class metodu çalışmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": [": Hayvan"],
    "bannedKeywords": []
  }',
  '["class Kopek : Hayvan ile kalıtım yap", "Kopek, Hayvan''ın tüm field ve metodlarını miras alır", "ad ve SesCikar() otomatik gelir"]'::jsonb,
  true
);

-- Challenge 18: Properties - Get/Set
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
  'csharp-018-properties',
  'csharp',
  'Properties - Get ve Set',
  'C# property''leri kullan',
  'code_challenge',
  3,
  20,
  40,
  18,
  '{
    "language": "csharp",
    "starterCode": "using System;\n\nclass Ogrenci\n{\n    private string ad;\n    private int yas;\n    \n    // Ad property''si ekle (get; set;)\n    public string Ad\n    {\n        get { return ad; }\n        set { ad = value; }\n    }\n    \n    // Yas property''si ekle (sadece 0-150 arası kabul et)\n    \n}\n\nclass Program\n{\n    static void Main()\n    {\n        Ogrenci ogr = new Ogrenci();\n        ogr.Ad = \"Ali\";\n        ogr.Yas = 15;\n        \n        Console.WriteLine($\"{ogr.Ad} - {ogr.Yas} yaşında\");\n    }\n}",
    "instructions": [
      "Yas için public int Yas { get; set; } property ekle",
      "set içinde if (value >= 0 && value <= 150) kontrolü yap",
      "Geçersiz değer için hata mesajı yazdır",
      "Main''de test et"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "get",
        "description": "get accessor olmalı"
      },
      {
        "type": "code_contains",
        "value": "set",
        "description": "set accessor olmalı"
      },
      {
        "type": "code_contains",
        "value": "value",
        "description": "value keyword kullanılmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["get", "set", "value"],
    "bannedKeywords": []
  }',
  '["public int Yas { get {...} set {...} }", "set içinde value geçerlilik kontrolü yap", "value >= 0 && value <= 150 kontrolü"]'::jsonb,
  true
);

-- Challenge 19: Exception Handling - Try-Catch
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
  'csharp-019-exception-handling',
  'csharp',
  'Exception Handling - Hata Yönetimi',
  'try-catch-finally kullan',
  'code_challenge',
  4,
  25,
  50,
  19,
  '{
    "language": "csharp",
    "starterCode": "using System;\n\nclass Program\n{\n    static void Main()\n    {\n        Console.WriteLine(\"Bir sayı girin:\");\n        string input = Console.ReadLine();\n        \n        // try-catch bloğu ekle\n        \n            int sayi = int.Parse(input);\n            Console.WriteLine($\"Girilen sayı: {sayi}\");\n            Console.WriteLine($\"Karesi: {sayi * sayi}\");\n        \n    }\n}",
    "instructions": [
      "try { } bloğu ekle",
      "catch (FormatException ex) bloğu ekle",
      "Hata durumunda mesaj yazdır",
      "finally bloğu ekle (opsiyonel)"
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
        "value": "FormatException",
        "description": "FormatException yakalanmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["try", "catch", "FormatException"],
    "bannedKeywords": []
  }',
  '["try { ... } catch (FormatException ex) { ... }", "catch bloğunda Console.WriteLine(\"Hata: \" + ex.Message);", "finally { } bloğu her durumda çalışır"]'::jsonb,
  true
);

-- Challenge 20: Mini Project - Kütüphane Sistemi
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
  'csharp-020-library-project',
  'csharp',
  'Mini Proje - Kütüphane Sistemi',
  'Tüm öğrendiklerini kullan',
  'code_challenge',
  4,
  30,
  60,
  20,
  '{
    "language": "csharp",
    "starterCode": "using System;\nusing System.Collections.Generic;\n\nclass Kitap\n{\n    public string Baslik { get; set; }\n    public string Yazar { get; set; }\n    public int SayfaSayisi { get; set; }\n    \n    public Kitap(string baslik, string yazar, int sayfaSayisi)\n    {\n        Baslik = baslik;\n        Yazar = yazar;\n        SayfaSayisi = sayfaSayisi;\n    }\n    \n    public void BilgiYazdir()\n    {\n        Console.WriteLine($\"{Baslik} - {Yazar} ({SayfaSayisi} sayfa)\");\n    }\n}\n\nclass Kutuphane\n{\n    // List<Kitap> field ekle\n    \n    \n    // Constructor\n    \n    \n    // KitapEkle metodu\n    \n    \n    // TumKitaplariListele metodu\n    \n}\n\nclass Program\n{\n    static void Main()\n    {\n        Kutuphane kutuphane = new Kutuphane();\n        \n        kutuphane.KitapEkle(new Kitap(\"1984\", \"George Orwell\", 328));\n        kutuphane.KitapEkle(new Kitap(\"Suç ve Ceza\", \"Dostoyevski\", 671));\n        \n        Console.WriteLine(\"=== KÜTÜPHANE KİTAPLARI ===\");\n        kutuphane.TumKitaplariListele();\n    }\n}",
    "instructions": [
      "Kutuphane class''ında private List<Kitap> kitaplar field''ı ekle",
      "Constructor''da kitaplar = new List<Kitap>(); ile başlat",
      "KitapEkle(Kitap kitap) metodu ekle - kitaplar.Add(kitap)",
      "TumKitaplariListele() metodu ekle - foreach ile yazdır"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "List<Kitap>",
        "description": "List<Kitap> kullanılmalı"
      },
      {
        "type": "code_contains",
        "value": "KitapEkle",
        "description": "KitapEkle metodu olmalı"
      },
      {
        "type": "code_contains",
        "value": "TumKitaplariListele",
        "description": "TumKitaplariListele metodu olmalı"
      },
      {
        "type": "output_contains",
        "value": "1984",
        "description": "Kitaplar listelensin"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["List<Kitap>", "Add", "foreach"],
    "bannedKeywords": []
  }',
  '["private List<Kitap> kitaplar = new List<Kitap>();", "public void KitapEkle(Kitap kitap) { kitaplar.Add(kitap); }", "foreach (Kitap k in kitaplar) { k.BilgiYazdir(); }"]'::jsonb,
  true
);

-- ========================================
-- C# CHALLENGES SUMMARY (Part 2)
-- ========================================
-- Total: 10 new challenges (#11-20)
-- Total C# XP: 215 (Part 1) + 480 (Part 2) = 695 XP
-- Difficulty range: 1-4 (Kolay → Çok Zor)
--
-- Topics: Methods, Return Values, String Methods, List<T>,
--         OOP (Class, Constructor, Inheritance, Properties),
--         Exception Handling, Mini Project
--
-- C#-specific features:
-- - Properties (get; set;)
-- - List<T> generic collections
-- - : base inheritance syntax
-- - value keyword in setters
-- - FormatException handling
-- ========================================
