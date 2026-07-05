# Test Öğrenci Verilerini Ekleme Kılavuzu

Şu anda Firebase Admin SDK kimlik doğrulama sorunu yaşıyoruz. İki yöntemle test verilerini ekleyebilirsiniz:

## Yöntem 1: Uygulama Üzerinden Kayıt (ÖNERİLEN)

1. **Emülatörde uygulamayı açın** (şu anda giriş ekranındasınız)
2. **"Kayıt Ol" butonuna tıklayın**
3. **Şu bilgilerle kayıt olun:**
   - Ad Soyad: Ahmet Yılmaz
   - E-posta: ahmet@test.com
   - Şifre: 123456
   - Hesap Tipi: **Öğrenci** (şimdi ekli!)

4. **Kayıt tamamlandıktan sonra:**
   - Ben sizin için ödev ve quiz verilerini ekleyeceğim
   - Veya aşağıdaki JSON verilerini Firebase Console'dan manuel olarak ekleyebilirsiniz

## Yöntem 2: Firebase Console'dan Manuel Ekleme

### Adım 1: Öğrenci Oluştur
1. https://console.firebase.google.com/project/devkom-dfdca/firestore adresine gidin
2. `users` koleksiyonunu açın
3. "Belge ekle" butonuna tıklayın
4. **Otomatik kimlik** seçin
5. Şu alanları ekleyin:

```json
{
  "name": "Ahmet Yılmaz",
  "displayName": "Ahmet Yılmaz",
  "email": "ahmet@test.com",
  "role": "student",
  "ageGroup": "7-9",
  "parentId": "VELİ_USER_ID_BURAYA",
  "classId": "class_001",
  "className": "3-A",
  "phoneNumber": "+905551234567",
  "profilePictureUrl": null,
  "isActive": true
}
```

**NOT:** `parentId` kısmına a@devkom.com kullanıcısının ID'sini yazın (users koleksiyonundan bulabilirsiniz)

### Adım 2: Ödev Teslimlerini Ekle
`homework_submissions` koleksiyonuna 4 belge ekleyin:

#### Ödev 1:
```json
{
  "studentId": "ÖĞRENCİ_ID_BURAYA",
  "homeworkTitle": "Robotik Kodlama - Döngüler",
  "status": "graded",
  "grade": 95,
  "feedback": "Harika bir çalışma! Döngüler konusunu çok iyi kavramışsın.",
  "maxGrade": 100,
  "submittedAt": "2025-11-13T10:00:00Z",
  "gradedAt": "2025-11-14T15:30:00Z"
}
```

#### Ödev 2:
```json
{
  "studentId": "ÖĞRENCİ_ID_BURAYA",
  "homeworkTitle": "Arduino LED Kontrol",
  "status": "graded",
  "grade": 88,
  "feedback": "İyi bir başlangıç, kod yapısı daha da geliştirilebilir.",
  "maxGrade": 100,
  "submittedAt": "2025-11-10T14:00:00Z",
  "gradedAt": "2025-11-11T16:00:00Z"
}
```

#### Ödev 3:
```json
{
  "studentId": "ÖĞRENCİ_ID_BURAYA",
  "homeworkTitle": "Blok Kodlama - Koşullar",
  "status": "graded",
  "grade": 92,
  "feedback": "Koşullu ifadeleri doğru kullanmışsın! Tebrikler.",
  "maxGrade": 100,
  "submittedAt": "2025-11-08T11:00:00Z",
  "gradedAt": "2025-11-09T13:00:00Z"
}
```

#### Ödev 4:
```json
{
  "studentId": "ÖĞRENCİ_ID_BURAYA",
  "homeworkTitle": "Sensör Kullanımı",
  "status": "graded",
  "grade": 85,
  "feedback": "Sensör entegrasyonu başarılı.",
  "maxGrade": 100,
  "submittedAt": "2025-11-05T09:00:00Z",
  "gradedAt": "2025-11-06T10:00:00Z"
}
```

### Adım 3: Quiz Sonuçlarını Ekle
`quiz_results` koleksiyonuna 4 belge ekleyin:

#### Quiz 1:
```json
{
  "userId": "ÖĞRENCİ_ID_BURAYA",
  "quizTitle": "Robotik Temelleri Quiz",
  "score": 8,
  "totalQuestions": 10,
  "percentage": 80,
  "completedAt": "2025-11-12T10:00:00Z"
}
```

#### Quiz 2:
```json
{
  "userId": "ÖĞRENCİ_ID_BURAYA",
  "quizTitle": "Arduino Başlangıç",
  "score": 9,
  "totalQuestions": 10,
  "percentage": 90,
  "completedAt": "2025-11-07T14:00:00Z"
}
```

#### Quiz 3:
```json
{
  "userId": "ÖĞRENCİ_ID_BURAYA",
  "quizTitle": "Kodlama Mantığı",
  "score": 7,
  "totalQuestions": 10,
  "percentage": 70,
  "completedAt": "2025-11-05T11:00:00Z"
}
```

#### Quiz 4:
```json
{
  "userId": "ÖĞRENCİ_ID_BURAYA",
  "quizTitle": "Temel Elektronik",
  "score": 8,
  "totalQuestions": 10,
  "percentage": 80,
  "completedAt": "2025-11-02T09:00:00Z"
}
```

## Test Etmek İçin:

1. a@devkom.com hesabıyla giriş yapın (veli hesabı)
2. **Raporlar** sekmesine gidin
3. "Ahmet Yılmaz" öğrencisini seçin
4. Ödevler ve Quiz sonuçlarını görebilirsiniz!
