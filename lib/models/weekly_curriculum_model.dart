/// Haftalık Müfredat Modeli - Öğretmen tarafından oluşturulur
class WeeklyCurriculumModel {
  final String id;
  final String teacherId; // Öğretmen ID
  final String teacherName; // Öğretmen adı
  final String className; // Sınıf/Grup adı (örn: "4A Robotik Grubu")
  final String title; // Müfredat başlığı (örn: "2024-2025 Robotik Eğitimi")
  final String description; // Genel açıklama
  final List<String> studentIds; // Bu müfredatı takip eden öğrenci ID'leri
  final int totalWeeks; // Toplam hafta sayısı
  final DateTime startDate; // Başlangıç tarihi
  final DateTime? endDate; // Bitiş tarihi (opsiyonel)
  final bool isActive; // Aktif mi?
  final DateTime createdAt;
  final DateTime updatedAt;

  WeeklyCurriculumModel({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.className,
    required this.title,
    required this.description,
    required this.studentIds,
    required this.totalWeeks,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // // REMOVED: Firebase-specific method
  // // factory WeeklyCurriculumModel.fromFirestore(DocumentSnapshot doc) { ... }

  Map<String, dynamic> toMap() {
    return {
      'teacherId': teacherId,
      'teacherName': teacherName,
      'className': className,
      'title': title,
      'description': description,
      'studentIds': studentIds,
      'totalWeeks': totalWeeks,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  WeeklyCurriculumModel copyWith({
    String? id,
    String? teacherId,
    String? teacherName,
    String? className,
    String? title,
    String? description,
    List<String>? studentIds,
    int? totalWeeks,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WeeklyCurriculumModel(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      className: className ?? this.className,
      title: title ?? this.title,
      description: description ?? this.description,
      studentIds: studentIds ?? this.studentIds,
      totalWeeks: totalWeeks ?? this.totalWeeks,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Haftalık İçerik Modeli - Her hafta için ayrı döküman
class WeekContentModel {
  final String id;
  final String curriculumId; // Hangi müfredata ait
  final int weekNumber; // Hafta numarası (1, 2, 3...)
  final String topic; // Konu başlığı
  final String description; // Hafta açıklaması
  final String? objectives; // Hedefler (opsiyonel)
  final bool isCompleted; // İşlendi mi?
  final DateTime? completedAt; // İşlenme tarihi
  final List<String> projectPhotos; // Proje fotoğrafları (Firebase Storage URLs)
  final List<String> videoLinks; // YouTube veya herhangi video linkleri
  final List<String> resourceLinks; // Diğer kaynaklar (web siteleri vb.)
  final String? notes; // Öğretmen notları
  final DateTime createdAt;
  final DateTime updatedAt;

  WeekContentModel({
    required this.id,
    required this.curriculumId,
    required this.weekNumber,
    required this.topic,
    required this.description,
    this.objectives,
    this.isCompleted = false,
    this.completedAt,
    this.projectPhotos = const [],
    this.videoLinks = const [],
    this.resourceLinks = const [],
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // // REMOVED: Firebase-specific method
  // // factory WeekContentModel.fromFirestore(DocumentSnapshot doc) { ... }

  Map<String, dynamic> toMap() {
    return {
      'curriculumId': curriculumId,
      'weekNumber': weekNumber,
      'topic': topic,
      'description': description,
      'objectives': objectives,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'projectPhotos': projectPhotos,
      'videoLinks': videoLinks,
      'resourceLinks': resourceLinks,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  WeekContentModel copyWith({
    String? id,
    String? curriculumId,
    int? weekNumber,
    String? topic,
    String? description,
    String? objectives,
    bool? isCompleted,
    DateTime? completedAt,
    List<String>? projectPhotos,
    List<String>? videoLinks,
    List<String>? resourceLinks,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WeekContentModel(
      id: id ?? this.id,
      curriculumId: curriculumId ?? this.curriculumId,
      weekNumber: weekNumber ?? this.weekNumber,
      topic: topic ?? this.topic,
      description: description ?? this.description,
      objectives: objectives ?? this.objectives,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      projectPhotos: projectPhotos ?? this.projectPhotos,
      videoLinks: videoLinks ?? this.videoLinks,
      resourceLinks: resourceLinks ?? this.resourceLinks,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Hafta durumu göstergeleri
  String get statusText {
    if (isCompleted) {
      return 'Tamamlandı';
    } else if (weekNumber == 1) {
      return 'Başlanmadı';
    } else {
      return 'Beklemede';
    }
  }

  bool get hasPhotos => projectPhotos.isNotEmpty;
  bool get hasVideos => videoLinks.isNotEmpty;
  bool get hasResources => resourceLinks.isNotEmpty;
  bool get hasAnyMedia => hasPhotos || hasVideos || hasResources;
}
