# Firestore Kurulum ve Kullanım Kılavuzu

## İçerik

1. [Genel Bakış](#genel-bakış)
2. [Kurulum Adımları](#kurulum-adımları)
3. [Veri Modelleri](#veri-modelleri)
4. [Servis Kullanımı](#servis-kullanımı)
5. [Güvenlik Kuralları](#güvenlik-kuralları)
6. [Best Practices](#best-practices)

## Genel Bakış

Devkom uygulaması için tasarlanan Firestore veritabanı mimarisi:

- **10+ Ana Koleksiyon**: Users, Students, Classes, Homeworks, Games, Curriculum, vb.
- **Rol Bazlı Erişim**: Admin, Teacher, Parent, Student
- **Gerçek Zamanlı Sync**: Stream desteği ile canlı güncellemeler
- **Offline Support**: Otomatik cache ve persistence
- **Güvenlik Öncelikli**: Kapsamlı Security Rules

### Oluşturulan Dosyalar

```
devkom_app/
├── docs/
│   ├── FIRESTORE_ARCHITECTURE.md     # Detaylı mimari dökümanı
│   ├── FIRESTORE_SECURITY_RULES.md   # Güvenlik kuralları açıklaması
│   └── FIRESTORE_SETUP.md             # Bu dosya
├── lib/
│   ├── models/
│   │   ├── student_model.dart         # Öğrenci veri modeli
│   │   ├── class_model.dart           # Sınıf veri modeli
│   │   ├── curriculum_model.dart      # Müfredat veri modeli
│   │   ├── user_model.dart            # (Mevcut)
│   │   ├── game_model.dart            # (Mevcut)
│   │   └── homework_model.dart        # (Mevcut)
│   └── services/
│       └── firestore/
│           └── student_firestore_service.dart  # Student CRUD servisi
└── firestore.rules                     # Güncellenmiş security rules
```

## Kurulum Adımları

### 1. Firebase Projesi Oluşturma

```bash
# Firebase CLI kurulumu
npm install -g firebase-tools

# Firebase'e giriş
firebase login

# Proje başlatma
firebase init firestore
```

### 2. Flutter Bağımlılıkları

`pubspec.yaml` dosyasına eklenmiş olmalı:

```yaml
dependencies:
  cloud_firestore: ^4.13.0
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
```

### 3. Firebase Konfigürasyonu

```dart
// lib/main.dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Offline persistence aktif
  FirebaseFirestore.instance.settings = Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(MyApp());
}
```

### 4. Security Rules Deploy

```bash
# Firestore rules'ı deploy et
firebase deploy --only firestore:rules

# Sadece test için emulator
firebase emulators:start --only firestore
```

## Veri Modelleri

### Student Model Kullanımı

```dart
import 'package:devkom_app/models/student_model.dart';

// Yeni öğrenci oluşturma
final student = StudentModel(
  studentId: 'auto_generated',
  firstName: 'Ahmet',
  lastName: 'Yılmaz',
  dateOfBirth: DateTime(2010, 5, 15),
  gender: Gender.male,
  parentIds: ['parent_user_id'],
  enrollmentInfo: EnrollmentInfo(
    enrollmentDate: DateTime.now(),
    currentLevel: 'Beginner',
    status: EnrollmentStatus.active,
  ),
  academicInfo: AcademicInfo(
    totalPoints: 0,
    currentStreak: 0,
    longestStreak: 0,
    completedLessons: 0,
    completedProjects: 0,
    badges: [],
  ),
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

// Firestore'a kaydetme
final studentService = StudentFirestoreService();
final studentId = await studentService.createStudent(student);
```

### Class Model Kullanımı

```dart
import 'package:devkom_app/models/class_model.dart';

final classModel = ClassModel(
  classId: 'auto_generated',
  name: 'Robotik 101',
  level: 'Beginner',
  description: 'Temel robotik eğitimi',
  teacherIds: ['teacher_user_id'],
  capacity: ClassCapacity(max: 20, current: 0),
  schedule: [
    ClassSchedule(
      dayOfWeek: 1, // Pazartesi
      startTime: '14:00',
      endTime: '16:00',
      location: 'Lab 1',
    ),
  ],
  semester: Semester(
    name: '2024-2025 Güz',
    startDate: DateTime(2024, 9, 1),
    endDate: DateTime(2025, 1, 31),
  ),
  isActive: true,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
```

## Servis Kullanımı

### Student Firestore Service

#### CREATE Operasyonları

```dart
final studentService = StudentFirestoreService();

// Tek öğrenci oluşturma
final studentId = await studentService.createStudent(student);

// Toplu öğrenci oluşturma
await studentService.createStudentsBatch([student1, student2, student3]);
```

#### READ Operasyonları

```dart
// ID ile öğrenci getirme
final student = await studentService.getStudentById('student_id');

// Tüm öğrencileri getirme
final allStudents = await studentService.getAllStudents();

// Sınıfa göre filtreleme
final classStudents = await studentService.getStudentsByClass('class_id');

// Veliye göre filtreleme
final parentStudents = await studentService.getStudentsByParent('parent_id');

// Top 10 öğrenci (puana göre)
final topStudents = await studentService.getTopStudentsByPoints(limit: 10);
```

#### UPDATE Operasyonları

```dart
// Tam öğrenci güncellemesi
await studentService.updateStudent(updatedStudent);

// Belirli alanları güncelleme
await studentService.updateStudentFields('student_id', {
  'firstName': 'Yeni İsim',
  'photoURL': 'new_photo_url',
});

// Akademik bilgileri güncelleme
await studentService.updateAcademicInfo(
  'student_id',
  pointsToAdd: 50,
  lessonsToAdd: 1,
  badgeToAdd: 'first_project',
  newStreak: 5,
);

// Sınıf değiştirme
await studentService.changeClass('student_id', 'new_class_id');

// Durum değiştirme
await studentService.changeStatus('student_id', EnrollmentStatus.graduated);
```

#### DELETE Operasyonları

```dart
// Hard delete (kalıcı silme)
await studentService.deleteStudent('student_id');

// Soft delete (inactive yapma)
await studentService.softDeleteStudent('student_id');
```

#### STREAM Kullanımı (Gerçek Zamanlı)

```dart
// Tek öğrenci stream
StreamBuilder<StudentModel?>(
  stream: studentService.streamStudent('student_id'),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final student = snapshot.data!;
      return Text(student.fullName);
    }
    return CircularProgressIndicator();
  },
);

// Sınıf öğrencileri stream
StreamBuilder<List<StudentModel>>(
  stream: studentService.streamStudentsByClass('class_id'),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final students = snapshot.data!;
      return ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) => StudentTile(students[index]),
      );
    }
    return CircularProgressIndicator();
  },
);
```

#### Alt Koleksiyonlar

```dart
// Oyun skoru ekleme
await studentService.addGameScore(
  'student_id',
  'game_id',
  score: 1500,
  level: 5,
  duration: 120,
);

// Öğrencinin oyun skorlarını getirme
final scores = await studentService.getGameScores('student_id');
```

## Güvenlik Kuralları

### Custom Claims Ayarlama

Admin SDK (Cloud Functions veya Admin Console) kullanarak:

```javascript
// Cloud Function örneği
const functions = require('firebase-functions');
const admin = require('firebase-admin');

exports.setUserRole = functions.https.onCall(async (data, context) => {
  // Sadece admin çağırabilir
  if (context.auth.token.role !== 'admin') {
    throw new functions.https.HttpsError('permission-denied');
  }

  await admin.auth().setCustomUserClaims(data.uid, {
    role: data.role
  });

  return { success: true };
});
```

### Client-side Custom Claims Kullanımı

```dart
import 'package:firebase_auth/firebase_auth.dart';

Future<String?> getUserRole() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;

  final idTokenResult = await user.getIdTokenResult();
  return idTokenResult.claims?['role'] as String?;
}

// Kullanımı
final role = await getUserRole();
if (role == 'admin') {
  // Admin özel işlemler
} else if (role == 'teacher') {
  // Öğretmen özel işlemler
}
```

## Best Practices

### 1. Error Handling

```dart
try {
  final student = await studentService.getStudentById('student_id');
  if (student == null) {
    // Öğrenci bulunamadı
    showError('Öğrenci bulunamadı');
    return;
  }
  // İşlemler
} on FirebaseException catch (e) {
  if (e.code == 'permission-denied') {
    showError('Yetkiniz yok');
  } else {
    showError('Bir hata oluştu: ${e.message}');
  }
} catch (e) {
  showError('Beklenmeyen hata: $e');
}
```

### 2. Pagination

```dart
// İlk sayfa
Query query = FirebaseFirestore.instance
  .collection('students')
  .orderBy('createdAt', descending: true)
  .limit(20);

final firstPage = await query.get();

// Sonraki sayfa
if (firstPage.docs.isNotEmpty) {
  final lastDoc = firstPage.docs.last;
  final nextPage = await query
    .startAfterDocument(lastDoc)
    .get();
}
```

### 3. Batch Operations

```dart
// 500'den fazla işlem için chunking gerekir
Future<void> batchUpdatePoints(Map<String, int> studentPoints) async {
  const batchSize = 500;
  final entries = studentPoints.entries.toList();

  for (var i = 0; i < entries.length; i += batchSize) {
    final batch = FirebaseFirestore.instance.batch();
    final chunk = entries.skip(i).take(batchSize);

    for (final entry in chunk) {
      final docRef = FirebaseFirestore.instance
        .collection('students')
        .doc(entry.key);
      batch.update(docRef, {
        'academicInfo.totalPoints': FieldValue.increment(entry.value),
      });
    }

    await batch.commit();
  }
}
```

### 4. Offline Persistence

```dart
// Ana uygulama başlangıcında bir kez ayarla
await FirebaseFirestore.instance.enablePersistence(
  const PersistenceSettings(synchronizeTabs: true),
);

// Offline veriye erişim
final students = await studentService.getAllStudents();
// Cache'den gelir, bağlantı kurulduğunda sync olur
```

### 5. Listeners Temizleme

```dart
class StudentListScreen extends StatefulWidget {
  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  StreamSubscription<List<StudentModel>>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = studentService.streamAllStudents().listen((students) {
      setState(() {
        // State güncelleme
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

## Performans İpuçları

1. **Index Kullanımı**: Composite query'ler için Firebase Console'dan index oluşturun
2. **Denormalization**: Sık kullanılan veriyi çoğaltın (örn: student içinde className)
3. **Aggregation**: İstatistikleri önceden hesaplayın
4. **Pagination**: Büyük listelerde limit ve startAfter kullanın
5. **Cache**: Stream'ler yerine get() + cache kullanın (statik veriler için)

## Deployment Checklist

- [ ] Firebase projesi oluşturuldu
- [ ] Flutter app Firebase'e bağlandı
- [ ] Firestore rules deploy edildi
- [ ] Indexes oluşturuldu
- [ ] Custom claims ayarlandı
- [ ] Test kullanıcıları oluşturuldu
- [ ] Backup ayarlandı
- [ ] Monitoring aktif edildi

## Yardımcı Kaynaklar

- [Firebase Docs](https://firebase.google.com/docs/firestore)
- [FlutterFire Docs](https://firebase.flutter.dev/)
- [Security Rules Reference](https://firebase.google.com/docs/firestore/security/rules-structure)
- `docs/FIRESTORE_ARCHITECTURE.md` - Detaylı mimari
- `docs/FIRESTORE_SECURITY_RULES.md` - Güvenlik kuralları

---

**Son Güncelleme**: 2024
**Versiyon**: 1.0
