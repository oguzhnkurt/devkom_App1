# 📚 İçerik Migration Rehberi

## Ne Yaptık?

Uygulamadaki **tüm hardcoded içerikleri** Supabase'e taşıyacağız:

| İçerik | Satır Sayısı | Durum |
|--------|--------------|-------|
| Kurslar (25 adet) | 463 | ✅ Hazır |
| Ders İçerikleri | 806 | ✅ Hazır |
| Quiz Soruları | 493 | ✅ Hazır |
| Scratch Dersleri | 1,104 | ⏳ Planlı |
| Demo Oyunlar | 1,242 | ⏳ Planlı |

## 🎯 Adım 1: SQL Schema'yı Çalıştır

### 1.1 Supabase Dashboard'a Git
1. https://supabase.com
2. Projenizi açın
3. **SQL Editor**'ü açın

### 1.2 SQL'i Çalıştır
1. Şu dosyayı açın:
   ```
   C:\Users\Oguzhan\devkom_app\supabase\migrations\05_content_tables_schema.sql
   ```
2. Tüm içeriği kopyalayın
3. Supabase SQL Editor'e yapıştırın
4. **RUN** butonuna basın

**Beklenen Sonuç:**
```
✅ Success
Created tables:
- courses
- course_lessons
- lesson_contents
- quizzes
- quiz_questions
- interactive_lessons
- course_progress
- lesson_progress
- quiz_attempts
```

## 🔄 Adım 2: Migration Script'i Çalıştır

### 2.1 Supabase Credentials Ekle

`scripts/migrate_content_to_supabase.dart` dosyasını açın ve değiştirin:

```dart
// Bu satırları bulun (satır 15-16):
url: 'YOUR_SUPABASE_URL',
anonKey: 'YOUR_SUPABASE_ANON_KEY',

// Şununla değiştirin:
url: 'https://[YOUR-PROJECT].supabase.co',
anonKey: 'eyJ...',  // Supabase Settings > API > anon/public key
```

**Credentials Nerede?**
1. Supabase Dashboard → Project Settings
2. API sekmesi
3. "Project URL" ve "anon/public" key'i kopyalayın

### 2.2 Script'i Çalıştır

Terminal'de:
```bash
cd C:\Users\Oguzhan\devkom_app
dart scripts/migrate_content_to_supabase.dart
```

**Beklenen Çıktı:**
```
🚀 Starting content migration to Supabase...

📚 Migrating courses...
  ✅ Scratch
  ✅ HTML
  ✅ CSS
  ... (25 kurs)
✅ Migrated 25 courses

📖 Migrating lessons...
  ✅ Python'a Giris (5 contents)
  ✅ Veri Tipleri (7 contents)
  ... (yüzlerce ders)
✅ Migrated 150+ lessons with 800+ content blocks

❓ Migrating quizzes...
  ✅ Python Quiz (10 questions)
  ...
✅ Migrated 50+ quizzes with 500+ questions

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎉 Migration Complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📚 Courses:         25
📖 Lessons:         150+
📝 Lesson Contents: 800+
❓ Quizzes:         50+
❔ Questions:       500+
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## ✅ Adım 3: Supabase'de Kontrol Et

1. Supabase Dashboard → Table Editor
2. Şu tabloları kontrol et:
   - `courses` → 25 satır olmalı
   - `course_lessons` → 150+ satır olmalı
   - `lesson_contents` → 800+ satır olmalı
   - `quizzes` → 50+ satır olmalı
   - `quiz_questions` → 500+ satır olmalı

## 🔧 Sorun Giderme

### Hata: "relation courses does not exist"
**Sebep:** SQL schema çalıştırılmamış
**Çözüm:** Adım 1'i tekrar yap

### Hata: "duplicate key value violates unique constraint"
**Sebep:** Veriler zaten migration edilmiş
**Çözüm:** Normal, veriler zaten Supabase'de

### Hata: "permission denied for table courses"
**Sebep:** RLS politikaları sorunu
**Çözüm:** SQL'de CREATE POLICY komutlarını kontrol et

### Hata: Import hatası (migrate_content_to_supabase.dart)
**Sebep:** Script doğru dizinde değil
**Çözüm:** Script'i `scripts/` klasöründe çalıştır

## 📋 Sonraki Adımlar

Migration başarılı olduktan sonra:

1. ✅ **Service'leri güncelleyeceğiz** (Supabase'den çekmek için)
2. ✅ **Fallback ekleyeceğiz** (Offline mode için)
3. ✅ **Cache ekleyeceğiz** (Hız için)
4. ✅ **Test edeceğiz**

## 🎯 Migration Durumu

- [✅] SQL Schema oluşturuldu
- [✅] Migration script hazır
- [⏳] SQL çalıştırılacak (Adım 1)
- [⏳] Data migration yapılacak (Adım 2)
- [⏳] Service'ler güncellenecek
- [⏳] Test edilecek

## 📞 Yardım

Sorun olursa:
1. Hata mesajını kopyala
2. Hangi adımda olduğunu söyle
3. Ekran görüntüsü paylaş

Ben yardımcı olurum!
