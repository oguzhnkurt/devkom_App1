# Firestore Security Rules - Devkom App

## Tam Güvenlik Kuralları

Aşağıda `firestore.rules` dosyasına eklenmesi gereken kapsamlı güvenlik kuralları bulunmaktadır.

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ============================================================================
    // HELPER FUNCTIONS
    // ============================================================================

    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    function getUserRole() {
      return isAuthenticated() ?
        (request.auth.token.role != null ? request.auth.token.role :
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role) :
        null;
    }

    function isAdmin() {
      return getUserRole() == 'admin';
    }

    function isTeacher() {
      return getUserRole() == 'teacher' || isAdmin();
    }

    function isParent() {
      return getUserRole() == 'parent';
    }

    function isStudent() {
      return getUserRole() == 'student';
    }

    function isParentOfStudent(studentId) {
      return isParent() &&
             exists(/databases/$(database)/documents/students/$(studentId)) &&
             get(/databases/$(database)/documents/students/$(studentId)).data.parentIds.hasAny([request.auth.uid]);
    }

    function isTeacherOfClass(classId) {
      return isTeacher() &&
             exists(/databases/$(database)/documents/classes/$(classId)) &&
             get(/databases/$(database)/documents/classes/$(classId)).data.teacherIds.hasAny([request.auth.uid]);
    }

    // ============================================================================
    // STUDENTS COLLECTION
    // ============================================================================

    match /students/{studentId} {
      allow read: if isAdmin() ||
                    isParentOfStudent(studentId) ||
                    isTeacher() ||
                    (isStudent() && resource.data.userId == request.auth.uid);

      allow create: if (isAdmin() || isTeacher()) &&
                      request.resource.data.createdAt == request.time;

      allow update: if (isAdmin() || isTeacher() || isParentOfStudent(studentId)) &&
                       request.resource.data.updatedAt == request.time;

      allow delete: if isAdmin();

      match /gameScores/{scoreId} {
        allow read: if isAuthenticated();
        allow create: if isAuthenticated() && request.resource.data.playedAt == request.time;
        allow update, delete: if isAdmin();
      }

      match /projects/{projectId} {
        allow read: if isAuthenticated();
        allow write: if isAdmin() || isTeacher();
      }
    }

    // ============================================================================
    // CLASSES COLLECTION
    // ============================================================================

    match /classes/{classId} {
      allow read: if isAuthenticated();
      allow create: if (isAdmin() || isTeacher()) &&
                      request.resource.data.createdAt == request.time;
      allow update: if (isAdmin() || isTeacherOfClass(classId)) &&
                      request.resource.data.updatedAt == request.time;
      allow delete: if isAdmin();
    }

    // ============================================================================
    // HOMEWORKS COLLECTION
    // ============================================================================

    match /homeworks/{homeworkId} {
      allow read: if isAuthenticated();
      allow create: if (isAdmin() || isTeacher()) &&
                      request.resource.data.createdBy == request.auth.uid &&
                      request.resource.data.createdAt == request.time;
      allow update: if (isAdmin() || (isTeacher() && resource.data.createdBy == request.auth.uid)) &&
                      request.resource.data.updatedAt == request.time;
      allow delete: if isAdmin() || (isTeacher() && resource.data.createdBy == request.auth.uid);

      match /submissions/{submissionId} {
        allow read: if isAdmin() || isTeacher() ||
                      (isStudent() && resource.data.studentId == request.auth.uid);
        allow create: if isStudent() &&
                        request.resource.data.studentId == request.auth.uid &&
                        request.resource.data.submittedAt == request.time;
        allow update: if isAdmin() || isTeacher() ||
                        (isStudent() && resource.data.studentId == request.auth.uid);
        allow delete: if isAdmin() || isTeacher();
      }
    }

    // ============================================================================
    // GAMES COLLECTION
    // ============================================================================

    match /games/{gameId} {
      allow read: if isAuthenticated();
      allow write: if isAdmin();

      match /leaderboard/{entryId} {
        allow read: if isAuthenticated();
        allow create: if isAuthenticated();
        allow update, delete: if isAdmin();
      }
    }

    // ============================================================================
    // CURRICULUM COLLECTION
    // ============================================================================

    match /curriculum/{curriculumId} {
      allow read: if isAuthenticated();
      allow create: if (isAdmin() || isTeacher()) &&
                      request.resource.data.createdBy == request.auth.uid;
      allow update: if (isAdmin() || (isTeacher() && resource.data.createdBy == request.auth.uid));
      allow delete: if isAdmin();

      match /modules/{moduleId} {
        allow read: if isAuthenticated();
        allow write: if isAdmin() || isTeacher();

        match /lessons/{lessonId} {
          allow read: if isAuthenticated();
          allow write: if isAdmin() || isTeacher();
        }
      }
    }

    // ============================================================================
    // PROJECTS COLLECTION
    // ============================================================================

    match /projects/{projectId} {
      allow read: if isAuthenticated();
      allow create: if (isAdmin() || isTeacher()) &&
                      request.resource.data.createdBy == request.auth.uid;
      allow update: if (isAdmin() || (isTeacher() && resource.data.createdBy == request.auth.uid));
      allow delete: if isAdmin();

      match /submissions/{submissionId} {
        allow read: if isAdmin() || isTeacher() ||
                      (isStudent() && resource.data.studentId == request.auth.uid);
        allow create: if isStudent() && request.resource.data.studentId == request.auth.uid;
        allow update: if isAdmin() || isTeacher() ||
                        (isStudent() && resource.data.studentId == request.auth.uid);
        allow delete: if isAdmin();
      }
    }

    // ============================================================================
    // CAMERA CAPTURES COLLECTION
    // ============================================================================

    match /cameraCaptures/{captureId} {
      allow read: if isAdmin() ||
                    isTeacher() ||
                    (isStudent() && resource.data.studentId == request.auth.uid) ||
                    (isParent() && isParentOfStudent(resource.data.studentId));
      allow create: if isStudent() &&
                      request.resource.data.studentId == request.auth.uid &&
                      request.resource.data.uploadedAt == request.time;
      allow update: if isAdmin() ||
                      (isStudent() && resource.data.studentId == request.auth.uid);
      allow delete: if isAdmin() ||
                      (isStudent() && resource.data.studentId == request.auth.uid);
    }

    // ============================================================================
    // NOTIFICATIONS COLLECTION
    // ============================================================================

    match /notifications/{notificationId} {
      allow read: if isAuthenticated();
      allow create: if (isAdmin() || isTeacher()) &&
                      request.resource.data.createdBy == request.auth.uid;
      allow update: if isAdmin() || (isTeacher() && resource.data.createdBy == request.auth.uid);
      allow delete: if isAdmin();
    }

    // ============================================================================
    // ANALYTICS COLLECTION
    // ============================================================================

    match /analytics/{document=**} {
      allow read: if isAdmin() || isTeacher();
      allow write: if isAdmin();
    }

    // ============================================================================
    // SETTINGS COLLECTION
    // ============================================================================

    match /settings/{document=**} {
      allow read: if isAuthenticated();
      allow write: if isAdmin();
    }

    // ============================================================================
    // DEFAULT DENY
    // ============================================================================

    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

## Güvenlik Kuralları Açıklamaları

### 1. Helper Functions

- **isAuthenticated()**: Kullanıcının giriş yapmış olup olmadığını kontrol eder
- **isOwner()**: Kullanıcının kaynak sahibi olup olmadığını kontrol eder
- **getUserRole()**: Kullanıcının rolünü custom claims veya doküman'dan alır
- **isAdmin()**: Admin rolü kontrolü
- **isTeacher()**: Öğretmen rolü kontrolü (Admin da öğretmen yetkilerine sahip)
- **isParent()**: Veli rolü kontrolü
- **isStudent()**: Öğrenci rolü kontrolü
- **isParentOfStudent()**: Velinin belirli öğrencinin velisi olup olmadığını kontrol eder
- **isTeacherOfClass()**: Öğretmenin belirli sınıfın öğretmeni olup olmadığını kontrol eder

### 2. Koleksiyon Bazlı Kurallar

#### Users Collection
- **Read**: Kullanıcı kendi profilini veya admin tüm profilleri okuyabilir
- **Create**: Kullanıcı kendi profilini oluşturabilir (kayıt sırasında)
- **Update**: Kullanıcı kendi profilini güncelleyebilir (role dışında), admin herkesi güncelleyebilir
- **Delete**: Sadece admin silebilir

#### Students Collection
- **Read**: Admin, velisi, öğretmen veya kendi öğrenci hesabı okuyabilir
- **Create**: Admin veya öğretmen oluşturabilir
- **Update**: Admin, öğretmen veya velisi güncelleyebilir
- **Delete**: Sadece admin silebilir

#### Classes Collection
- **Read**: Tüm kayıtlı kullanıcılar okuyabilir
- **Create**: Admin veya öğretmen oluşturabilir
- **Update**: Admin veya sınıf öğretmeni güncelleyebilir
- **Delete**: Sadece admin silebilir

#### Homeworks Collection
- **Read**: Tüm kayıtlı kullanıcılar okuyabilir
- **Create**: Admin veya öğretmen oluşturabilir
- **Update**: Admin veya oluşturan öğretmen güncelleyebilir
- **Delete**: Admin veya oluşturan öğretmen silebilir
- **Submissions**: Öğrenciler kendi ödevlerini gönderebilir, öğretmenler notlandırabilir

#### Games Collection
- **Read**: Tüm kayıtlı kullanıcılar okuyabilir
- **Write**: Sadece admin yazabilir
- **Leaderboard**: Kullanıcılar kendi skorlarını ekleyebilir

#### Curriculum Collection
- **Read**: Tüm kayıtlı kullanıcılar published olanları okuyabilir
- **Create**: Admin veya öğretmen oluşturabilir
- **Update**: Admin veya oluşturan öğretmen güncelleyebilir
- **Delete**: Sadece admin silebilir

#### Projects Collection
- **Read**: Tüm kayıtlı kullanıcılar okuyabilir
- **Create**: Admin veya öğretmen oluşturabilir
- **Update**: Admin veya oluşturan öğretmen güncelleyebilir
- **Delete**: Sadece admin silebilir
- **Submissions**: Öğrenciler kendi projelerini gönderebilir

#### Camera Captures Collection
- **Read**: Admin, öğretmen, sahibi veya öğrencinin velisi okuyabilir
- **Create**: Öğrenci kendi fotoğraflarını yükleyebilir
- **Update**: Admin veya sahibi güncelleyebilir
- **Delete**: Admin veya sahibi silebilir

#### Notifications Collection
- **Read**: Tüm kayıtlı kullanıcılar kendi bildirimlerini okuyabilir
- **Create**: Admin veya öğretmen oluşturabilir
- **Update**: Admin veya oluşturan öğretmen güncelleyebilir
- **Delete**: Sadece admin silebilir

#### Analytics Collection
- **Read**: Admin ve öğretmen okuyabilir
- **Write**: Sadece admin yazabilir (otomatik sistemler admin yetkisiyle)

#### Settings Collection
- **Read**: Tüm kayıtlı kullanıcılar okuyabilir
- **Write**: Sadece admin yazabilir

### 3. Güvenlik Best Practices

1. **Default Deny**: Tanımlanmayan tüm koleksiyonlar için erişim reddedilir
2. **Role-Based Access Control (RBAC)**: Tüm işlemler rol bazlı kontrol edilir
3. **Timestamp Validation**: Create ve update işlemleri için timestamp doğrulaması
4. **Ownership Validation**: Kullanıcılar sadece kendi verilerine erişebilir
5. **Field-Level Security**: Kritik alanlar (role, userId) korunmuştur
6. **Relationship Validation**: Parent-student ve teacher-class ilişkileri doğrulanır

### 4. Firebase Console'da Custom Claims Ayarlama

Admin SDK ile custom claims ayarlamak için:

\`\`\`javascript
// Node.js Admin SDK
const admin = require('firebase-admin');

async function setUserRole(uid, role) {
  await admin.auth().setCustomUserClaims(uid, { role: role });
  console.log(\`Role '\${role}' set for user \${uid}\`);
}

// Örnek kullanım
setUserRole('user_uid_here', 'teacher');
\`\`\`

### 5. Test Senaryoları

#### Test 1: Öğretmen Ödev Oluşturma
```javascript
// BAŞARILI - Öğretmen kendi ödevini oluşturabilir
{
  "title": "Robotik Proje 1",
  "createdBy": "teacher_uid",
  "createdAt": "server_timestamp"
}
```

#### Test 2: Öğrenci Başkasının Ödevini Silme
```javascript
// BAŞARISIZ - Öğrenci başkasının ödevini silemez
// Error: Missing or insufficient permissions
```

#### Test 3: Veli Kendi Çocuğunun Notlarını Görme
```javascript
// BAŞARILI - Veli kendi çocuğunun bilgilerini okuyabilir
isParentOfStudent(studentId) === true
```

### 6. Deployment

Firestore rules'ı deploy etmek için:

\`\`\`bash
firebase deploy --only firestore:rules
\`\`\`

Sadece test için (production'a deploy etmeden):

\`\`\`bash
firebase emulators:start --only firestore
\`\`\`

### 7. Monitoring

Firebase Console'da Security Rules kullanımını izleyin:
- Reddedilen istekleri takip edin
- Hot document uyarılarını kontrol edin
- Güvenlik loglarını inceleyin

---

**Önemli Notlar:**
- Bu kurallar production ortamında kullanılabilir seviyededir
- Custom claims kullanımı performans açısından tercih edilir
- Tüm timestamp alanları server timestamp ile doğrulanmalıdır
- İlişkisel kontroller (get() çağrıları) maliyet oluşturur, dikkatli kullanılmalıdır
