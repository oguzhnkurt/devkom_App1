enum Gender { male, female, other }

enum EnrollmentStatus { active, inactive, graduated }

class StudentModel {
  final String studentId;
  final String? userId;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final Gender gender;
  final String? photoURL;
  final String? classId;
  final List<String> parentIds;
  final EnrollmentInfo enrollmentInfo;
  final AcademicInfo academicInfo;
  final ContactInfo? contactInfo;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudentModel({
    required this.studentId,
    this.userId,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    this.photoURL,
    this.classId,
    required this.parentIds,
    required this.enrollmentInfo,
    required this.academicInfo,
    this.contactInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  int get age {
    final today = DateTime.now();
    int age = today.year - dateOfBirth.year;
    if (today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  // // REMOVED: Firebase-specific method
  // // factory StudentModel.fromFirestore(DocumentSnapshot doc) { ... }

  factory StudentModel.fromMap(Map<String, dynamic> map, String id) {
    return StudentModel(
      studentId: id,
      userId: map['userId'],
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      dateOfBirth: map['dateOfBirth'] is String ? DateTime.parse(map['dateOfBirth']) : DateTime.now(),
      gender: Gender.values.firstWhere(
        (e) => e.name == map['gender'],
        orElse: () => Gender.other,
      ),
      photoURL: map['photoURL'],
      classId: map['classId'],
      parentIds: List<String>.from(map['parentIds'] ?? []),
      enrollmentInfo: EnrollmentInfo.fromMap(map['enrollmentInfo']),
      academicInfo: AcademicInfo.fromMap(map['academicInfo']),
      contactInfo: map['contactInfo'] != null
          ? ContactInfo.fromMap(map['contactInfo'])
          : null,
      createdAt: map['createdAt'] is String ? DateTime.parse(map['createdAt']) : DateTime.now(),
      updatedAt: map['updatedAt'] is String ? DateTime.parse(map['updatedAt']) : DateTime.now(),
    );
  }

  // Map oluşturma
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender.name,
      'photoURL': photoURL,
      'classId': classId,
      'parentIds': parentIds,
      'enrollmentInfo': enrollmentInfo.toMap(),
      'academicInfo': academicInfo.toMap(),
      'contactInfo': contactInfo?.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Kopyalama metodu
  StudentModel copyWith({
    String? studentId,
    String? userId,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    Gender? gender,
    String? photoURL,
    String? classId,
    List<String>? parentIds,
    EnrollmentInfo? enrollmentInfo,
    AcademicInfo? academicInfo,
    ContactInfo? contactInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudentModel(
      studentId: studentId ?? this.studentId,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      photoURL: photoURL ?? this.photoURL,
      classId: classId ?? this.classId,
      parentIds: parentIds ?? this.parentIds,
      enrollmentInfo: enrollmentInfo ?? this.enrollmentInfo,
      academicInfo: academicInfo ?? this.academicInfo,
      contactInfo: contactInfo ?? this.contactInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class EnrollmentInfo {
  final DateTime enrollmentDate;
  final String currentLevel;
  final EnrollmentStatus status;

  EnrollmentInfo({
    required this.enrollmentDate,
    required this.currentLevel,
    required this.status,
  });

  factory EnrollmentInfo.fromMap(Map<String, dynamic> map) {
    return EnrollmentInfo(
      enrollmentDate: map['enrollmentDate'] is String ? DateTime.parse(map['enrollmentDate']) : DateTime.now(),
      currentLevel: map['currentLevel'] ?? 'Beginner',
      status: EnrollmentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => EnrollmentStatus.active,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enrollmentDate': enrollmentDate.toIso8601String(),
      'currentLevel': currentLevel,
      'status': status.name,
    };
  }

  EnrollmentInfo copyWith({
    DateTime? enrollmentDate,
    String? currentLevel,
    EnrollmentStatus? status,
  }) {
    return EnrollmentInfo(
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      currentLevel: currentLevel ?? this.currentLevel,
      status: status ?? this.status,
    );
  }
}

class AcademicInfo {
  final int totalPoints;
  final int currentStreak;
  final int longestStreak;
  final int completedLessons;
  final int completedProjects;
  final List<String> badges;

  AcademicInfo({
    required this.totalPoints,
    required this.currentStreak,
    required this.longestStreak,
    required this.completedLessons,
    required this.completedProjects,
    required this.badges,
  });

  factory AcademicInfo.fromMap(Map<String, dynamic> map) {
    return AcademicInfo(
      totalPoints: map['totalPoints'] ?? 0,
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      completedLessons: map['completedLessons'] ?? 0,
      completedProjects: map['completedProjects'] ?? 0,
      badges: List<String>.from(map['badges'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalPoints': totalPoints,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'completedLessons': completedLessons,
      'completedProjects': completedProjects,
      'badges': badges,
    };
  }

  AcademicInfo copyWith({
    int? totalPoints,
    int? currentStreak,
    int? longestStreak,
    int? completedLessons,
    int? completedProjects,
    List<String>? badges,
  }) {
    return AcademicInfo(
      totalPoints: totalPoints ?? this.totalPoints,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      completedLessons: completedLessons ?? this.completedLessons,
      completedProjects: completedProjects ?? this.completedProjects,
      badges: badges ?? this.badges,
    );
  }
}

class ContactInfo {
  final String? address;
  final String? emergencyContact;
  final String? medicalInfo;

  ContactInfo({
    this.address,
    this.emergencyContact,
    this.medicalInfo,
  });

  factory ContactInfo.fromMap(Map<String, dynamic> map) {
    return ContactInfo(
      address: map['address'],
      emergencyContact: map['emergencyContact'],
      medicalInfo: map['medicalInfo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'emergencyContact': emergencyContact,
      'medicalInfo': medicalInfo,
    };
  }

  ContactInfo copyWith({
    String? address,
    String? emergencyContact,
    String? medicalInfo,
  }) {
    return ContactInfo(
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      medicalInfo: medicalInfo ?? this.medicalInfo,
    );
  }
}
