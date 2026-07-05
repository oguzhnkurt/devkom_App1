-- ============================================
-- PYTHON CHALLENGES EXPANSION (11-25)
-- Adding 15 new challenges to Python course
-- Total: 25 challenges, ~865 XP
-- ============================================

-- Challenge 11: While Loop
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
  'python-011-while-loop',
  'python',
  'While Döngüsü - Sayı Tahmin',
  'While döngüsü kullanarak sayı tahmin oyunu yap',
  'code_challenge',
  2,
  15,
  30,
  11,
  '{
    "language": "python",
    "starterCode": "# Sayı tahmin oyunu\n# 1-10 arası bir sayı tut\n# Kullanıcı doğru tahmin edene kadar sor\n\nimport random\ntarget = random.randint(1, 10)\nguess = 0\n\n# While döngüsü ile devam et\n",
    "instructions": [
      "While döngüsü kullan",
      "guess != target koşulunu kontrol et",
      "Kullanıcıdan tahmin al: guess = int(input())",
      "Yanlış tahminde ipucu ver (büyük/küçük)"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "while",
        "description": "While döngüsü kullanılmalı"
      },
      {
        "type": "code_contains",
        "value": "input",
        "description": "Kullanıcıdan giriş alınmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["while", "input"],
    "bannedKeywords": []
  }',
  '["While döngüsü: while koşul:", "guess != target şeklinde kontrol et", "Her turda input() ile tahmin al"]'::jsonb,
  true
);

-- Challenge 12: List Methods
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
  'python-012-list-methods',
  'python',
  'Liste Metodları - Öğrenci Notları',
  'append, remove, sort metodlarını kullan',
  'code_challenge',
  2,
  12,
  30,
  12,
  '{
    "language": "python",
    "starterCode": "# Öğrenci notları listesi\nnotlar = []\n\n# 5 not ekle (append kullan)\n\n\n# En düşük notu çıkar (remove kullan)\n\n\n# Notları sırala (sort kullan)\n\n\nprint(notlar)\n",
    "instructions": [
      "5 farklı not ekle (append ile)",
      "min(notlar) ile en düşük notu bul ve çıkar",
      "notlar.sort() ile sırala",
      "Sonucu yazdır"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "append",
        "description": "append metodu kullanılmalı"
      },
      {
        "type": "code_contains",
        "value": "remove",
        "description": "remove metodu kullanılmalı"
      },
      {
        "type": "code_contains",
        "value": "sort",
        "description": "sort metodu kullanılmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["append", "remove", "sort"],
    "bannedKeywords": []
  }',
  '["notlar.append(85) gibi notlar ekle", "notlar.remove(min(notlar)) ile en düşüğü çıkar", "notlar.sort() ile artan sırala"]'::jsonb,
  true
);

-- Challenge 13: Dictionary Basics
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
  'python-013-dictionary-basics',
  'python',
  'Sözlük (Dictionary) - Öğrenci Bilgisi',
  'Dictionary oluştur ve bilgileri sakla',
  'code_challenge',
  2,
  15,
  35,
  13,
  '{
    "language": "python",
    "starterCode": "# Öğrenci bilgilerini dictionary ile sakla\n\nogrenci = {\n    # ad, soyad, yas, sinif bilgilerini ekle\n}\n\nprint(f\"{ogrenci[''ad'']} {ogrenci[''soyad'']} - {ogrenci[''sinif'']}. Sınıf\")\n",
    "instructions": [
      "Dictionary oluştur: { }'''' kullan",
      "Key-value çiftleri ekle",
      "ad, soyad, yas, sinif bilgilerini ekle",
      "f-string ile yazdır"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "{",
        "description": "Dictionary oluşturulmalı"
      },
      {
        "type": "code_contains",
        "value": ":",
        "description": "Key-value çiftleri olmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["ad", "soyad"],
    "bannedKeywords": []
  }',
  '["Dictionary: {\"key\": \"value\"} formatında", "\"ad\": \"Ali\", \"soyad\": \"Yılmaz\" gibi ekle", "ogrenci[\"ad\"] ile değerlere eriş"]'::jsonb,
  true
);

-- Challenge 14: Dictionary Operations
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
  'python-014-dict-operations',
  'python',
  'Sözlük İşlemleri - Telefon Rehberi',
  'Dictionary''ye ekleme, güncelleme, silme',
  'code_challenge',
  3,
  18,
  40,
  14,
  '{
    "language": "python",
    "starterCode": "# Telefon rehberi\nrehber = {}\n\n# 3 kişi ekle\n\n\n# Bir kişinin numarasını güncelle\n\n\n# Bir kişiyi sil\n\n\nprint(rehber)\n",
    "instructions": [
      "rehber[\"isim\"] = \"numara\" ile ekle",
      "Aynı key ile güncelle",
      "del rehber[\"isim\"] ile sil",
      "Sonucu yazdır"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "del",
        "description": "del ile silme yapılmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["del"],
    "bannedKeywords": []
  }',
  '["rehber[\"Ali\"] = \"5551234567\" ile ekle", "Aynı key kullanarak güncelle", "del rehber[\"Ali\"] ile sil"]'::jsonb,
  true
);

-- Challenge 15: Nested Loops
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
  'python-015-nested-loops',
  'python',
  'İç İçe Döngüler - Çarpım Tablosu',
  'İç içe for döngüleri ile çarpım tablosu',
  'code_challenge',
  3,
  18,
  40,
  15,
  '{
    "language": "python",
    "starterCode": "# 1-10 arası çarpım tablosu\n\nfor i in range(1, 11):\n    # İç döngü yaz\n    \n",
    "instructions": [
      "Dış döngü: for i in range(1, 11)",
      "İç döngü: for j in range(1, 11)",
      "Her satırda i*j değerini yazdır",
      "print() ile satır sonunda yeni satıra geç"
    ],
    "testCases": [
      {
        "type": "output_contains",
        "value": "1 2 3",
        "description": "İlk satır doğru olmalı"
      },
      {
        "type": "code_contains",
        "value": "for",
        "description": "İç içe döngüler olmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["for"],
    "bannedKeywords": []
  }',
  '["İç döngüde for j in range(1, 11) kullan", "print(i*j, end=\" \") ile yan yana yaz", "Dış döngüde print() ile yeni satır"]'::jsonb,
  true
);

-- Challenge 16: String Methods
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
  'python-016-string-methods',
  'python',
  'String Metodları - Metin Düzenleme',
  'upper, lower, strip, replace metodları',
  'code_challenge',
  2,
  15,
  35,
  16,
  '{
    "language": "python",
    "starterCode": "metin = \"  Python Programlama  \"\n\n# Boşlukları temizle (strip)\n\n\n# Büyük harfe çevir (upper)\n\n\n# \"Python\" yerine \"Java\" yaz (replace)\n\n\nprint(temiz_metin)\n",
    "instructions": [
      "strip() ile baş-sondaki boşlukları sil",
      "upper() ile büyük harfe çevir",
      "replace(\"eski\", \"yeni\") ile değiştir",
      "Sonucu yazdır"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "strip",
        "description": "strip() kullanılmalı"
      },
      {
        "type": "code_contains",
        "value": "upper",
        "description": "upper() kullanılmalı"
      },
      {
        "type": "code_contains",
        "value": "replace",
        "description": "replace() kullanılmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["strip", "upper", "replace"],
    "bannedKeywords": []
  }',
  '["temiz = metin.strip()", "buyuk = temiz.upper()", "degisti = buyuk.replace(\"PYTHON\", \"JAVA\")"]'::jsonb,
  true
);

-- Challenge 17: List Comprehension
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
  'python-017-list-comprehension',
  'python',
  'List Comprehension - Kareler',
  'Tek satırda liste oluşturma',
  'code_challenge',
  3,
  20,
  45,
  17,
  '{
    "language": "python",
    "starterCode": "# 1-10 arası sayıların karelerini al\n# List comprehension kullan\n\nkareler = # [x**2 for x in ...]\n\nprint(kareler)\n",
    "instructions": [
      "List comprehension: [ifade for x in liste]",
      "x**2 ile karesini al",
      "range(1, 11) ile 1-10 arası",
      "Tek satırda yaz"
    ],
    "testCases": [
      {
        "type": "output_exact",
        "value": "[1, 4, 9, 16, 25, 36, 49, 64, 81, 100]",
        "description": "Kareler doğru olmalı"
      },
      {
        "type": "code_contains",
        "value": "for",
        "description": "List comprehension kullanılmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": true,
    "mustContainKeywords": ["for"],
    "bannedKeywords": ["append"]
  }',
  '["[x**2 for x in range(1, 11)] formatında", "Köşeli parantez içinde for kullan", "append kullanma, tek satırda yaz"]'::jsonb,
  true
);

-- Challenge 18: Function Parameters
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
  'python-018-function-params',
  'python',
  'Fonksiyon Parametreleri - Selamlama',
  'Parametreli fonksiyon yaz',
  'code_challenge',
  2,
  15,
  35,
  18,
  '{
    "language": "python",
    "starterCode": "# Selamlama fonksiyonu\ndef selamla(isim, soyisim):\n    # Selamlama mesajı yazdır\n    \n\n# Fonksiyonu çağır\nselamla(\"Ali\", \"Yılmaz\")\nselamla(\"Ayşe\", \"Demir\")\n",
    "instructions": [
      "def ile fonksiyon tanımla",
      "2 parametre al: isim, soyisim",
      "print ile \"Merhaba {isim} {soyisim}\" yazdır",
      "Fonksiyonu 2 kez çağır"
    ],
    "testCases": [
      {
        "type": "output_contains",
        "value": "Merhaba Ali Yılmaz",
        "description": "İlk çağrı doğru olmalı"
      },
      {
        "type": "output_contains",
        "value": "Merhaba Ayşe Demir",
        "description": "İkinci çağrı doğru olmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["def", "isim", "soyisim"],
    "bannedKeywords": []
  }',
  '["def selamla(isim, soyisim): ile tanımla", "print(f\"Merhaba {isim} {soyisim}\") kullan", "Fonksiyonu isim ve soyisimle çağır"]'::jsonb,
  true
);

-- Challenge 19: Return Values
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
  'python-019-return-values',
  'python',
  'Return - Alan Hesaplama',
  'Değer döndüren fonksiyon',
  'code_challenge',
  2,
  15,
  35,
  19,
  '{
    "language": "python",
    "starterCode": "# Dikdörtgen alanı hesapla\ndef alan_hesapla(uzunluk, genislik):\n    # Alan hesapla ve return et\n    \n\n# Fonksiyonu çağır ve sonucu yazdır\nsonuc = alan_hesapla(5, 3)\nprint(f\"Alan: {sonuc}\")\n",
    "instructions": [
      "alan = uzunluk * genislik hesapla",
      "return alan ile döndür",
      "Fonksiyonu çağır ve sonucu değişkene ata",
      "Sonucu yazdır"
    ],
    "testCases": [
      {
        "type": "output_exact",
        "value": "Alan: 15",
        "description": "Alan doğru hesaplanmalı"
      },
      {
        "type": "code_contains",
        "value": "return",
        "description": "return kullanılmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": true,
    "mustContainKeywords": ["return"],
    "bannedKeywords": []
  }',
  '["alan = uzunluk * genislik", "return alan ile sonucu döndür", "sonuc değişkenine fonksiyon çağrısı ata"]'::jsonb,
  true
);

-- Challenge 20: Multiple Returns
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
  'python-020-multiple-returns',
  'python',
  'Çoklu Return - Min ve Max',
  'Birden fazla değer döndür',
  'code_challenge',
  3,
  18,
  40,
  20,
  '{
    "language": "python",
    "starterCode": "# Liste içindeki min ve max değerleri döndür\ndef min_max(liste):\n    # min ve max bul\n    # return ile iki değer döndür\n    \n\n# Fonksiyonu çağır\nsayilar = [5, 2, 9, 1, 7]\nen_kucuk, en_buyuk = min_max(sayilar)\nprint(f\"Min: {en_kucuk}, Max: {en_buyuk}\")\n",
    "instructions": [
      "min(liste) ve max(liste) kullan",
      "return minimum, maximum formatında döndür",
      "Tuple unpacking ile iki değişkene ata",
      "Sonuçları yazdır"
    ],
    "testCases": [
      {
        "type": "output_exact",
        "value": "Min: 1, Max: 9",
        "description": "Min ve max doğru olmalı"
      },
      {
        "type": "code_contains",
        "value": "return",
        "description": "return kullanılmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": true,
    "mustContainKeywords": ["return", "min", "max"],
    "bannedKeywords": []
  }',
  '["minimum = min(liste)", "maximum = max(liste)", "return minimum, maximum ile iki değer döndür"]'::jsonb,
  true
);

-- Challenge 21: Try-Except
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
  'python-021-try-except',
  'python',
  'Hata Yönetimi - Sayı Kontrolü',
  'try-except ile hata yakala',
  'code_challenge',
  3,
  20,
  45,
  21,
  '{
    "language": "python",
    "starterCode": "# Kullanıcıdan sayı al, hata kontrolü yap\n\ntry:\n    # Kullanıcıdan giriş al ve int''e çevir\n    \nexcept ValueError:\n    # Hata mesajı ver\n    \n",
    "instructions": [
      "try bloğunda input() ve int() kullan",
      "except ValueError ile hatayı yakala",
      "Hata durumunda uyarı mesajı ver",
      "Başarılı durumda sayıyı yazdır"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "try",
        "description": "try bloğu olmalı"
      },
      {
        "type": "code_contains",
        "value": "except",
        "description": "except bloğu olmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["try", "except"],
    "bannedKeywords": []
  }',
  '["try: bloğunda risky kodu yaz", "except ValueError: ile spesifik hata yakala", "Hata mesajı kullanıcı dostu olmalı"]'::jsonb,
  true
);

-- Challenge 22: File Reading
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
  'python-022-file-reading',
  'python',
  'Dosya Okuma - Metin Analizi',
  'Dosyadan okuma ve işleme',
  'code_challenge',
  4,
  25,
  50,
  22,
  '{
    "language": "python",
    "starterCode": "# Dosyayı oku ve satır sayısını bul\n\nwith open(\"test.txt\", \"r\", encoding=\"utf-8\") as dosya:\n    # Dosyayı oku\n    \n\nprint(f\"Toplam {satir_sayisi} satır\")\n",
    "instructions": [
      "with open() ile dosya aç",
      "readlines() ile satırları oku",
      "len() ile satır sayısını bul",
      "Sonucu yazdır"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "with",
        "description": "with statement kullanılmalı"
      },
      {
        "type": "code_contains",
        "value": "open",
        "description": "open() kullanılmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["with", "open"],
    "bannedKeywords": []
  }',
  '["with open(\"dosya.txt\", \"r\") as f: formatı kullan", "satirlar = dosya.readlines()", "len(satirlar) ile sayıyı bul"]'::jsonb,
  true
);

-- Challenge 23: Classes Basics
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
  'python-023-classes-basics',
  'python',
  'Sınıf (Class) - Öğrenci Sınıfı',
  'İlk sınıfını oluştur',
  'code_challenge',
  4,
  25,
  55,
  23,
  '{
    "language": "python",
    "starterCode": "# Öğrenci sınıfı oluştur\nclass Ogrenci:\n    def __init__(self, ad, yas):\n        # Özellikleri ata\n        \n\n# Öğrenci nesnesi oluştur\nogrenci1 = Ogrenci(\"Ali\", 15)\nprint(f\"{ogrenci1.ad} - {ogrenci1.yas} yaşında\")\n",
    "instructions": [
      "class Ogrenci: ile sınıf tanımla",
      "__init__ metodu ekle",
      "self.ad ve self.yas özelliklerini ata",
      "Nesne oluştur ve yazdır"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "class",
        "description": "Class tanımı olmalı"
      },
      {
        "type": "code_contains",
        "value": "__init__",
        "description": "__init__ metodu olmalı"
      },
      {
        "type": "output_contains",
        "value": "Ali",
        "description": "Ad yazdırılmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["class", "__init__", "self"],
    "bannedKeywords": []
  }',
  '["class Ogrenci: ile başla", "def __init__(self, ad, yas): tanımla", "self.ad = ad ile özellikleri ata"]'::jsonb,
  true
);

-- Challenge 24: Class Methods
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
  'python-024-class-methods',
  'python',
  'Sınıf Metodları - Hesap Makinesi',
  'Sınıfa metod ekle',
  'code_challenge',
  4,
  25,
  55,
  24,
  '{
    "language": "python",
    "starterCode": "class Hesap:\n    def __init__(self, sayi):\n        self.sayi = sayi\n    \n    def kare(self):\n        # Sayının karesini döndür\n        \n    \n    def kupu(self):\n        # Sayının küpünü döndür\n        \n\nhesap = Hesap(3)\nprint(f\"Kare: {hesap.kare()}\")\nprint(f\"Küp: {hesap.kupu()}\")\n",
    "instructions": [
      "kare() metodunda return self.sayi ** 2",
      "kupu() metodunda return self.sayi ** 3",
      "Metodları self ile çağır",
      "Sonuçları yazdır"
    ],
    "testCases": [
      {
        "type": "output_contains",
        "value": "Kare: 9",
        "description": "Kare hesabı doğru olmalı"
      },
      {
        "type": "output_contains",
        "value": "Küp: 27",
        "description": "Küp hesabı doğru olmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["def", "self", "return"],
    "bannedKeywords": []
  }',
  '["def kare(self): ile metod tanımla", "return self.sayi ** 2", "nesne.metod() şeklinde çağır"]'::jsonb,
  true
);

-- Challenge 25: Mini Project - Calculator
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
  'python-025-mini-calculator',
  'python',
  'Mini Proje - Hesap Makinesi',
  'Tam fonksiyonel hesap makinesi yap',
  'code_challenge',
  4,
  30,
  60,
  25,
  '{
    "language": "python",
    "starterCode": "# Hesap makinesi\n\ndef topla(a, b):\n    return a + b\n\ndef cikar(a, b):\n    # Çıkarma işlemi\n    \n\ndef carp(a, b):\n    # Çarpma işlemi\n    \n\ndef bol(a, b):\n    # Bölme işlemi (0''a bölme kontrolü)\n    \n\n# Kullanıcıdan işlem al\nprint(\"1: Toplama\")\nprint(\"2: Çıkarma\")\nprint(\"3: Çarpma\")\nprint(\"4: Bölme\")\n\n# Seçim ve sayıları al, hesapla\n",
    "instructions": [
      "4 fonksiyon tamamla (topla zaten var)",
      "Kullanıcıdan işlem seçimi al (1-4)",
      "İki sayı al",
      "If-elif ile işlemi yap ve sonucu yazdır"
    ],
    "testCases": [
      {
        "type": "code_contains",
        "value": "def",
        "description": "Fonksiyonlar tanımlı olmalı"
      },
      {
        "type": "code_contains",
        "value": "if",
        "description": "Koşullu kontrol olmalı"
      }
    ]
  }',
  '{
    "requiresExactOutput": false,
    "mustContainKeywords": ["def", "if", "return"],
    "bannedKeywords": []
  }',
  '["Her fonksiyonda return kullan", "bol() fonksiyonunda b == 0 kontrolü yap", "if-elif-else ile seçime göre fonksiyon çağır"]'::jsonb,
  true
);

-- ============================================
-- PYTHON EXPANSION SUMMARY
-- ============================================
-- Added: 15 new challenges (#11-25)
-- Total Python challenges: 25
-- New XP: 640 XP
-- Total Python XP: 865 XP
-- Difficulty range: 2-4 (Orta → Çok Zor)
-- Topics: Loops, Collections, Functions, OOP, File I/O
-- ============================================
