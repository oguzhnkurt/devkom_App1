# Devkom Firestore Veritabanı Mimarisi

## İçindekiler
1. [Genel Bakış](#genel-bakış)
2. [Koleksiyon Yapısı](#koleksiyon-yapısı)
3. [Veri Modelleri](#veri-modelleri)
4. [İlişkiler](#ilişkiler)
5. [Security Rules](#security-rules)
6. [İndexler](#indexler)
7. [Performans Optimizasyonları](#performans-optimizasyonları)

## Genel Bakış

Devkom uygulaması için tasarlanan Firestore veritabanı, eğitim yönetim sistemini destekleyen modüler ve ölçeklenebilir bir yapıya sahiptir.

### Temel Prensipler
- **Denormalizasyon**: Okuma performansı için gerekli yerlerde veri tekrarı
- **Güvenlik Öncelikli**: Rol bazlı erişim kontrolü
- **Ölçeklenebilir**: Alt koleksiyonlarla sınırsız büyüme
- **Gerçek Zamanlı**: Stream desteği ile canlı güncellemeler

## Koleksiyon Yapısı

```
firestore/
├── users/                              # Kullanıcı profilleri
│   ├── {userId}/
│   │   ├── profile (document)
│   │   ├── students/                   # Veli için öğrenci listesi
│   │   │   └── {studentId}
│   │   ├── notifications/              # Kullanıcı bildirimleri
│   │   │   └── {notificationId}
│   │   └── settings/                   # Kullanıcı ayarları
│   │       └── preferences
│
├── students/                           # Öğrenci bilgileri
│   ├── {studentId}/
│   │   ├── profile (document)
│   │   ├── homeworks/                  # Öğrencinin ödevleri
│   │   │   └── {homeworkId}
│   │   ├── gameScores/                 # Oyun skorları
│   │   │   └── {gameId}
│   │   ├── projects/                   # Proje çalışmaları
│   │   │   └── {projectId}
│   │   ├── attendance/                 # Devamsızlık kayıtları
│   │   │   └── {attendanceId}
│   │   └── certificates/               # Sertifikalar
│   │       └── {certificateId}
│
├── classes/                            # Sınıflar
│   ├── {classId}/
│   │   ├── info (document)
│   │   ├── students/                   # Sınıftaki öğrenciler
│   │   │   └── {studentId}
│   │   ├── curriculum/                 # Müfredat
│   │   │   └── {curriculumId}
│   │   ├── schedule/                   # Ders programı
│   │   │   └── {scheduleId}
│   │   └── announcements/              # Duyurular
│   │       └── {announcementId}
│
├── homeworks/                          # Ödevler (Ana koleksiyon)
│   ├── {homeworkId}/
│   │   ├── details (document)
│   │   └── submissions/                # Öğrenci teslimler
│   │       └── {submissionId}
│
├── games/                              # Oyunlar
│   ├── {gameId}/
│   │   ├── info (document)
│   │   ├── leaderboard/                # Lider tablosu
│   │   │   └── {entryId}
│   │   └── levels/                     # Oyun seviyeleri
│   │       └── {levelId}
│
├── curriculum/                         # Müfredat içerikleri
│   ├── {curriculumId}/
│   │   ├── details (document)
│   │   ├── modules/                    # Modüller
│   │   │   └── {moduleId}/
│   │   │       ├── info
│   │   │       └── lessons/            # Dersler
│   │   │           └── {lessonId}
│   │   └── resources/                  # Kaynaklar
│   │       └── {resourceId}
│
├── projects/                           # Proje şablonları
│   ├── {projectId}/
│   │   ├── template (document)
│   │   └── submissions/                # Öğrenci proje teslimler
│   │       └── {submissionId}
│
├── cameraCaptures/                     # Kamera modülü kayıtları
│   ├── {captureId}/
│   │   ├── metadata (document)
│   │   └── analysis/                   # AI analiz sonuçları
│   │       └── {analysisId}
│
├── notifications/                      # Global bildirimler
│   └── {notificationId}
│
├── analytics/                          # Analitik veriler
│   ├── daily/
│   │   └── {date}
│   └── monthly/
│       └── {yearMonth}
│
└── settings/                           # Sistem ayarları
    ├── app/
    └── security/
```

## Veri Modelleri

### 1. Users Collection

#### User Document
```typescript
{
  userId: string;              // Firebase Auth UID
  email: string;
  displayName: string;
  role: 'admin' | 'teacher' | 'parent' | 'student';
  photoURL?: string;
  phoneNumber?: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  isActive: boolean;
  metadata: {
    lastLogin?: Timestamp;
    loginCount: number;
    deviceInfo?: string;
  };
  // Rol özel alanlar
  parentInfo?: {
    studentIds: string[];      // Bağlı öğrenciler
    occupation?: string;
  };
  teacherInfo?: {
    classIds: string[];        // Sorumlu sınıflar
    subjects: string[];
    specialization?: string;
  };
  studentInfo?: {
    studentId: string;         // students koleksiyonuna referans
    classId?: string;
    enrollmentDate: Timestamp;
  };
}
```

### 2. Students Collection

#### Student Document
```typescript
{
  studentId: string;
  userId?: string;             // User koleksiyonuna referans (varsa)
  firstName: string;
  lastName: string;
  dateOfBirth: Timestamp;
  gender: 'male' | 'female' | 'other';
  photoURL?: string;
  classId?: string;
  parentIds: string[];         // Veli user ID'leri

  enrollmentInfo: {
    enrollmentDate: Timestamp;
    currentLevel: string;
    status: 'active' | 'inactive' | 'graduated';
  };

  academicInfo: {
    totalPoints: number;
    currentStreak: number;
    longestStreak: number;
    completedLessons: number;
    completedProjects: number;
    badges: string[];
  };

  contactInfo: {
    address?: string;
    emergencyContact?: string;
    medicalInfo?: string;
  };

  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

### 3. Classes Collection

#### Class Document
```typescript
{
  classId: string;
  name: string;
  level: string;               // Örn: "Beginner", "Intermediate", "Advanced"
  description: string;
  teacherIds: string[];

  capacity: {
    max: number;
    current: number;
  };

  schedule: {
    dayOfWeek: number;         // 0-6 (Pazar-Cumartesi)
    startTime: string;         // "HH:mm"
    endTime: string;
    location?: string;
  }[];

  semester: {
    name: string;              // Örn: "2024-2025 Güz"
    startDate: Timestamp;
    endDate: Timestamp;
  };

  isActive: boolean;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

### 4. Homeworks Collection

#### Homework Document
```typescript
{
  homeworkId: string;
  title: string;
  description: string;
  type: 'coding' | 'theory' | 'project' | 'quiz';
  difficulty: 'easy' | 'medium' | 'hard';

  classId?: string;            // Hangi sınıf için (null ise tüm öğrenciler)
  studentIds?: string[];       // Belirli öğrenciler için

  createdBy: string;           // Teacher userId
  assignedDate: Timestamp;
  dueDate: Timestamp;

  points: number;              // Maksimum puan

  attachments: {
    type: 'pdf' | 'image' | 'video' | 'code' | 'link';
    url: string;
    name: string;
  }[];

  requirements: {
    description: string;
    mandatory: boolean;
  }[];

  status: 'draft' | 'published' | 'closed';

  statistics: {
    totalAssigned: number;
    totalSubmitted: number;
    totalGraded: number;
    averageScore: number;
  };

  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

#### Homework Submission (Sub-collection)
```typescript
{
  submissionId: string;
  studentId: string;
  homeworkId: string;

  submittedAt: Timestamp;
  status: 'submitted' | 'late' | 'graded' | 'returned';

  content: {
    text?: string;
    codeFiles?: {
      filename: string;
      language: string;
      url: string;
    }[];
    attachments?: {
      type: string;
      url: string;
      name: string;
    }[];
  };

  grading: {
    score?: number;
    maxScore: number;
    gradedBy?: string;        // Teacher userId
    gradedAt?: Timestamp;
    feedback?: string;
    rubric?: {
      criterion: string;
      points: number;
      maxPoints: number;
      comment?: string;
    }[];
  };

  isLate: boolean;
  attempts: number;

  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

### 5. Games Collection

#### Game Document
```typescript
{
  gameId: string;
  name: string;
  description: string;
  category: 'robotics' | 'programming' | 'logic' | 'puzzle';
  difficulty: 'easy' | 'medium' | 'hard';
  thumbnailURL: string;

  gameData: {
    type: string;              // Oyun tipi: 'chess', 'car', 'flappy', vb.
    version: string;
    settings: Map<string, any>;
  };

  scoring: {
    pointsPerLevel: number;
    bonusMultiplier: number;
    timeBonus: boolean;
  };

  requirements: {
    minAge?: number;
    prerequisiteGames?: string[];
    requiredBadges?: string[];
  };

  statistics: {
    totalPlays: number;
    uniquePlayers: number;
    averageScore: number;
    completionRate: number;
  };

  isActive: boolean;
  isFeatured: boolean;

  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

#### Game Score (Sub-collection under students/{studentId}/gameScores/)
```typescript
{
  scoreId: string;
  gameId: string;
  studentId: string;

  score: number;
  level: number;
  duration: number;            // Saniye cinsinden

  achievements: string[];

  gameState?: {
    checkpoint?: any;
    inventory?: any;
    progress?: number;
  };

  playedAt: Timestamp;
  isHighScore: boolean;
}
```

### 6. Curriculum Collection

#### Curriculum Document
```typescript
{
  curriculumId: string;
  title: string;
  description: string;
  subject: 'robotics' | 'programming' | 'electronics' | 'ai' | 'general';
  level: 'beginner' | 'intermediate' | 'advanced';

  targetAudience: {
    minAge: number;
    maxAge: number;
    prerequisites?: string[];
  };

  structure: {
    totalModules: number;
    totalLessons: number;
    estimatedHours: number;
  };

  learningOutcomes: string[];

  tags: string[];

  status: 'draft' | 'published' | 'archived';
  version: string;

  createdBy: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

#### Module (Sub-collection)
```typescript
{
  moduleId: string;
  curriculumId: string;
  order: number;
  title: string;
  description: string;

  objectives: string[];

  duration: {
    estimatedHours: number;
    weeks?: number;
  };

  resources: {
    type: 'video' | 'pdf' | 'quiz' | 'interactive' | 'external';
    title: string;
    url: string;
    duration?: number;
  }[];

  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

#### Lesson (Sub-sub-collection)
```typescript
{
  lessonId: string;
  moduleId: string;
  order: number;
  title: string;
  content: string;
  type: 'theory' | 'practical' | 'assessment';

  materials: {
    type: string;
    url: string;
    name: string;
  }[];

  activities: {
    type: 'quiz' | 'coding' | 'discussion' | 'project';
    description: string;
    points: number;
  }[];

  estimatedDuration: number;   // Dakika

  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

### 7. Projects Collection

#### Project Template
```typescript
{
  projectId: string;
  title: string;
  description: string;
  category: 'robot' | 'app' | 'game' | 'electronics' | 'ai';
  difficulty: 'beginner' | 'intermediate' | 'advanced';

  objectives: string[];

  requirements: {
    hardware?: string[];
    software?: string[];
    skills?: string[];
  };

  steps: {
    order: number;
    title: string;
    description: string;
    resources?: {
      type: string;
      url: string;
    }[];
    estimatedTime: number;     // Dakika
  }[];

  evaluation: {
    criteria: {
      name: string;
      description: string;
      maxPoints: number;
    }[];
    totalPoints: number;
  };

  resources: {
    codeTemplates?: string[];
    diagrams?: string[];
    videos?: string[];
  };

  tags: string[];
  estimatedCompletionTime: number; // Saat

  createdBy: string;
  isTemplate: boolean;

  statistics: {
    totalSubmissions: number;
    averageScore: number;
    completionRate: number;
  };

  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

#### Project Submission (Sub-collection)
```typescript
{
  submissionId: string;
  projectId: string;
  studentId: string;

  title: string;
  description: string;

  progress: {
    currentStep: number;
    totalSteps: number;
    percentage: number;
  };

  deliverables: {
    type: 'code' | 'video' | 'document' | 'image' | 'other';
    url: string;
    name: string;
    uploadedAt: Timestamp;
  }[];

  status: 'in_progress' | 'submitted' | 'under_review' | 'completed' | 'returned';

  evaluation?: {
    scores: {
      criterionName: string;
      points: number;
      maxPoints: number;
      feedback?: string;
    }[];
    totalScore: number;
    maxScore: number;
    evaluatedBy: string;
    evaluatedAt: Timestamp;
    overallFeedback: string;
  };

  collaboration?: {
    teamMembers?: string[];    // Diğer öğrenci ID'leri
    role?: string;
  };

  createdAt: Timestamp;
  updatedAt: Timestamp;
  submittedAt?: Timestamp;
}
```

### 8. Camera Captures Collection

#### Capture Document
```typescript
{
  captureId: string;
  studentId: string;

  type: 'photo' | 'video';
  url: string;                 // Firebase Storage URL
  thumbnailURL?: string;

  metadata: {
    duration?: number;         // Video için saniye
    resolution: {
      width: number;
      height: number;
    };
    fileSize: number;          // Bytes
    mimeType: string;
  };

  context: {
    projectId?: string;
    homeworkId?: string;
    activityType?: string;
    location?: string;
  };

  tags: string[];
  description?: string;

  processing: {
    status: 'pending' | 'processing' | 'completed' | 'failed';
    aiAnalysis?: {
      objects?: string[];
      confidence: number;
      labels?: Map<string, number>;
      customAnalysis?: any;
    };
  };

  privacy: {
    isPublic: boolean;
    sharedWith?: string[];     // User IDs
  };

  createdAt: Timestamp;
  uploadedAt: Timestamp;
}
```

### 9. Notifications Collection

#### Notification Document
```typescript
{
  notificationId: string;

  type: 'homework' | 'grade' | 'announcement' | 'reminder' | 'achievement' | 'system';
  priority: 'low' | 'medium' | 'high' | 'urgent';

  title: string;
  body: string;

  recipients: {
    type: 'all' | 'role' | 'class' | 'individual';
    roleFilter?: string[];     // ['parent', 'student']
    classIds?: string[];
    userIds?: string[];
  };

  data?: {
    homeworkId?: string;
    projectId?: string;
    classId?: string;
    actionUrl?: string;
    customData?: Map<string, any>;
  };

  scheduling: {
    sendAt: Timestamp;
    expiresAt?: Timestamp;
  };

  delivery: {
    channels: ('push' | 'email' | 'sms' | 'in_app')[];
    status: 'pending' | 'sent' | 'failed';
    sentAt?: Timestamp;
    failureReason?: string;
  };

  statistics: {
    totalRecipients: number;
    delivered: number;
    read: number;
    clicked: number;
  };

  createdBy: string;
  createdAt: Timestamp;
}
```

### 10. Analytics Collection

#### Daily Analytics
```typescript
{
  date: string;                // YYYY-MM-DD

  users: {
    totalActive: number;
    newRegistrations: number;
    byRole: {
      admin: number;
      teacher: number;
      parent: number;
      student: number;
    };
  };

  activities: {
    homeworksSubmitted: number;
    gamesPlayed: number;
    projectsStarted: number;
    lessonsCompleted: number;
  };

  engagement: {
    averageSessionDuration: number;
    totalSessions: number;
    peakHour: number;
  };

  performance: {
    averageHomeworkScore: number;
    averageGameScore: number;
    completionRates: {
      homeworks: number;
      projects: number;
      lessons: number;
    };
  };

  createdAt: Timestamp;
}
```

## İlişkiler

### 1-to-Many İlişkiler
- **User → Students**: Bir veli birden fazla öğrenciye sahip olabilir
- **Class → Students**: Bir sınıfta birden fazla öğrenci
- **Teacher → Classes**: Bir öğretmen birden fazla sınıfa ders verebilir
- **Curriculum → Modules → Lessons**: Hiyerarşik yapı

### Many-to-Many İlişkiler
- **Students ↔ Homeworks**: Array alanları ve alt koleksiyonlarla
- **Students ↔ Games**: gameScores alt koleksiyonu ile
- **Classes ↔ Teachers**: classIds ve teacherIds array'leri ile

### Referans Stratejileri
1. **Document References**: Küçük, sık değişmeyen ilişkiler için
2. **Embedded Documents**: Genellikle birlikte okunan veriler için
3. **Array of IDs**: Many-to-many ilişkiler için
4. **Sub-collections**: Sınırsız büyüyen veri setleri için

## Security Rules

Detaylı security rules için `firestore.rules` dosyasına bakınız.

### Temel Prensipler
1. **Kimlik Doğrulama**: Tüm işlemler için `request.auth != null`
2. **Rol Bazlı Erişim**: Custom claims ile rol kontrolü
3. **Sahiplik Kontrolü**: Kullanıcılar sadece kendi verilerine erişebilir
4. **Veri Validasyonu**: Schema validation fonksiyonları
5. **Rate Limiting**: Timestamp bazlı kısıtlamalar

## İndexler

### Composite Indexes (Gerekli)

```javascript
// Homeworks - Student ve Durum bazlı sorgular
homeworks/{homeworkId}/submissions
  - studentId ASC, status ASC, submittedAt DESC

// Students - Class ve Durum bazlı sorgular
students
  - classId ASC, enrollmentInfo.status ASC, academicInfo.totalPoints DESC

// Game Scores - Lider tablosu
students/{studentId}/gameScores
  - gameId ASC, score DESC, playedAt DESC

// Notifications - Rol ve Tarih bazlı
notifications
  - recipients.type ASC, priority DESC, scheduling.sendAt DESC

// Projects - Category ve Difficulty
projects
  - category ASC, difficulty ASC, statistics.completionRate DESC
```

### Single Field Indexes (Otomatik)
- `createdAt`, `updatedAt`: Tarih bazlı sıralama
- `status`, `isActive`: Durum filtreleme
- `userId`, `studentId`: Kullanıcı bazlı sorgular

## Performans Optimizasyonları

### 1. Pagination
```dart
// Sayfalama için limit ve startAfter kullanımı
Query query = FirebaseFirestore.instance
  .collection('homeworks')
  .orderBy('createdAt', descending: true)
  .limit(20);

// Sonraki sayfa
query = query.startAfterDocument(lastDocument);
```

### 2. Caching
```dart
// Offline persistence aktif
FirebaseFirestore.instance.settings = Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

### 3. Batch Operations
```dart
// Toplu yazma işlemleri
WriteBatch batch = FirebaseFirestore.instance.batch();
batch.set(docRef1, data1);
batch.update(docRef2, data2);
batch.delete(docRef3);
await batch.commit();
```

### 4. Denormalization
```typescript
// Student document içinde sık kullanılan class bilgisi
{
  studentId: "...",
  classId: "class123",
  className: "Robotik 101",        // Denormalized
  classLevel: "Beginner"            // Denormalized
}
```

### 5. Aggregation
```typescript
// Homework içinde submission istatistikleri
{
  homeworkId: "...",
  statistics: {
    totalAssigned: 30,
    totalSubmitted: 25,              // Gerçek zamanlı güncellenir
    totalGraded: 20,
    averageScore: 85.5
  }
}
```

## Veri Migrasyonu ve Versiyonlama

### Document Versioning
```typescript
{
  version: "2.0",
  schemaVersion: 2,
  migrationDate: Timestamp,
  previousVersion?: any
}
```

### Migration Strategy
1. Yeni alan eklerken varsayılan değer kullan
2. Eski alanları deprecated olarak işaretle
3. Batch migration scripts ile kademeli geçiş
4. Backward compatibility için fallback mekanizması

## Backup ve Recovery

### Automated Backups
- Firebase Console'dan otomatik yedekleme aktif
- Günlük scheduled exports
- Point-in-time recovery (7 gün)

### Manual Backup
```bash
# Firestore export
gcloud firestore export gs://[BUCKET_NAME]
```

## Monitoring ve Logging

### Cloud Functions Triggers
- onCreate: Yeni kayıt bildirimleri
- onUpdate: Durum değişikliği takibi
- onDelete: Silme logları
- Scheduled: Günlük analytics hesaplama

### Metrics to Track
- Read/Write operations per collection
- Hot document warnings
- Query performance
- Storage usage trends

---

**Son Güncelleme**: 2024
**Versiyon**: 1.0
**Yazar**: DevKom Development Team
