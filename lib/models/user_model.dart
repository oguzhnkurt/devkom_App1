import 'homework_model.dart' show AgeGroup;

enum UserRole {
  student, // Öğrenci - Student access with games and homework
  parent, // Veli - Full access including live camera
  teacher, // Öğretmen - Teacher access with homework grading
  visitor, // Ziyaretçi - Content viewer without teacher assignment
  admin, // Admin - Full access + management
}

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? profilePictureUrl; // Profile picture URL
  final UserRole role;
  final AgeGroup? ageGroup; // For students only
  final String? parentId; // For students - links to parent user
  final List<String>? studentIds; // For parents - links to their students
  final String? classId; // For students - links to their class
  final String? description; // For students - additional notes
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  // Premium features
  final bool isPro; // Premium subscription status
  final DateTime? proExpiryDate; // Pro subscription expiry date
  final DateTime? proTrialStartDate; // Pro trial start date (7 days free)
  final bool hasUsedTrial; // Whether user has used their free trial

  // Daily limits
  final int dailyPostCount; // Number of posts created today
  final DateTime? lastPostResetDate; // Last post count reset date
  final int dailyAiMessageCount; // Number of AI messages today
  final DateTime? lastAiResetDate; // Last AI count reset date
  final int dailyQuestionCount; // Number of questions asked today
  final DateTime? lastQuestionDate; // Last question date for daily limit

  // Optional fields
  final DateTime? birthDate; // Birth date (optional, for age-based features)
  final bool hasSelectedPurpose; // Whether user has selected their purpose

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.profilePictureUrl,
    required this.role,
    this.ageGroup,
    this.parentId,
    this.studentIds,
    this.classId,
    this.description,
    required this.createdAt,
    this.lastLoginAt,
    this.isPro = false,
    this.proExpiryDate,
    this.proTrialStartDate,
    this.hasUsedTrial = false,
    this.dailyPostCount = 0,
    this.lastPostResetDate,
    this.dailyAiMessageCount = 0,
    this.lastAiResetDate,
    this.dailyQuestionCount = 0,
    this.lastQuestionDate,
    this.birthDate,
    this.hasSelectedPurpose = false,
  });

  // Convert to Map for legacy compatibility
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'profilePictureUrl': profilePictureUrl,
      'role': role.name,
      'ageGroup': ageGroup?.name,
      'parentId': parentId,
      'studentIds': studentIds,
      'classId': classId,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isPro': isPro,
      'proExpiryDate': proExpiryDate?.toIso8601String(),
      'proTrialStartDate': proTrialStartDate?.toIso8601String(),
      'hasUsedTrial': hasUsedTrial,
      'dailyPostCount': dailyPostCount,
      'lastPostResetDate': lastPostResetDate?.toIso8601String(),
      'dailyAiMessageCount': dailyAiMessageCount,
      'lastAiResetDate': lastAiResetDate?.toIso8601String(),
      'dailyQuestionCount': dailyQuestionCount,
      'lastQuestionDate': lastQuestionDate?.toIso8601String(),
      'birthDate': birthDate?.toIso8601String(),
      'hasSelectedPurpose': hasSelectedPurpose,
    };
  }

  // Convert to Map for Supabase
  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': uid,
      'email': email,
      'display_name': displayName,
      'profile_picture_url': profilePictureUrl,
      'role': role.name,
      'age_group': ageGroup?.name,
      'parent_id': parentId,
      'student_ids': studentIds,
      'class_id': classId,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'is_pro': isPro,
      'pro_expiry_date': proExpiryDate?.toIso8601String(),
      'pro_trial_start_date': proTrialStartDate?.toIso8601String(),
      'has_used_trial': hasUsedTrial,
      'daily_post_count': dailyPostCount,
      'last_post_reset_date': lastPostResetDate?.toIso8601String(),
      'daily_ai_message_count': dailyAiMessageCount,
      'last_ai_reset_date': lastAiResetDate?.toIso8601String(),
      'daily_question_count': dailyQuestionCount,
      'last_question_date': lastQuestionDate?.toIso8601String(),
      'birth_date': birthDate?.toIso8601String(),
      'has_selected_purpose': hasSelectedPurpose,
    };
  }

  // // REMOVED: Firebase-specific method
  // // factory UserModel.fromFirestore(DocumentSnapshot doc) { ... }

  // Create from Supabase Map
  factory UserModel.fromSupabase(Map<String, dynamic> data) {
    return UserModel(
      uid: data['id'] ?? '',
      email: data['email'] ?? '',
      displayName: data['display_name'] ?? '',
      profilePictureUrl: data['profile_picture_url'],
      role: _parseRole(data['role']),
      ageGroup: _parseAgeGroup(data['age_group']),
      parentId: data['parent_id'],
      studentIds: data['student_ids'] != null ? List<String>.from(data['student_ids']) : null,
      classId: data['class_id'],
      description: data['description'],
      createdAt: data['created_at'] != null ? DateTime.parse(data['created_at']) : DateTime.now(),
      lastLoginAt: data['last_login_at'] != null ? DateTime.parse(data['last_login_at']) : null,
      isPro: data['is_pro'] ?? false,
      proExpiryDate: data['pro_expiry_date'] != null ? DateTime.parse(data['pro_expiry_date']) : null,
      proTrialStartDate: data['pro_trial_start_date'] != null ? DateTime.parse(data['pro_trial_start_date']) : null,
      hasUsedTrial: data['has_used_trial'] ?? false,
      dailyPostCount: data['daily_post_count'] ?? 0,
      lastPostResetDate: data['last_post_reset_date'] != null ? DateTime.parse(data['last_post_reset_date']) : null,
      dailyAiMessageCount: data['daily_ai_message_count'] ?? 0,
      lastAiResetDate: data['last_ai_reset_date'] != null ? DateTime.parse(data['last_ai_reset_date']) : null,
      dailyQuestionCount: data['daily_question_count'] ?? 0,
      lastQuestionDate: data['last_question_date'] != null ? DateTime.parse(data['last_question_date']) : null,
      birthDate: data['birth_date'] != null ? DateTime.parse(data['birth_date']) : null,
      hasSelectedPurpose: data['has_selected_purpose'] ?? false,
    );
  }

  // Create from Map (legacy compatibility)
  factory UserModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return UserModel(
      uid: id ?? map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      profilePictureUrl: map['profilePictureUrl'],
      role: _parseRole(map['role']),
      ageGroup: _parseAgeGroup(map['ageGroup']),
      parentId: map['parentId'],
      studentIds: map['studentIds'] != null ? List<String>.from(map['studentIds']) : null,
      classId: map['classId'],
      description: map['description'],
      createdAt: map['createdAt'] is String ? DateTime.parse(map['createdAt']) : DateTime.now(),
      lastLoginAt: map['lastLoginAt'] is String ? DateTime.parse(map['lastLoginAt']) : null,
      isPro: map['isPro'] ?? false,
      proExpiryDate: map['proExpiryDate'] is String ? DateTime.parse(map['proExpiryDate']) : null,
      proTrialStartDate: map['proTrialStartDate'] is String ? DateTime.parse(map['proTrialStartDate']) : null,
      hasUsedTrial: map['hasUsedTrial'] ?? false,
      dailyPostCount: map['dailyPostCount'] ?? 0,
      lastPostResetDate: map['lastPostResetDate'] is String ? DateTime.parse(map['lastPostResetDate']) : null,
      dailyAiMessageCount: map['dailyAiMessageCount'] ?? 0,
      lastAiResetDate: map['lastAiResetDate'] is String ? DateTime.parse(map['lastAiResetDate']) : null,
      dailyQuestionCount: map['dailyQuestionCount'] ?? 0,
      lastQuestionDate: map['lastQuestionDate'] is String ? DateTime.parse(map['lastQuestionDate']) : null,
      birthDate: map['birthDate'] is String ? DateTime.parse(map['birthDate']) : null,
      hasSelectedPurpose: map['hasSelectedPurpose'] ?? false,
    );
  }

  // Parse role from string
  static UserRole _parseRole(String? roleString) {
    switch (roleString?.toLowerCase()) {
      case 'student':
        return UserRole.student;
      case 'parent':
        return UserRole.parent;
      case 'teacher':
        return UserRole.teacher;
      case 'visitor':
        return UserRole.visitor;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.student; // Default to student
    }
  }

  // Parse age group from string
  static AgeGroup? _parseAgeGroup(String? ageGroupString) {
    switch (ageGroupString?.toLowerCase()) {
      case 'age4to6':
        return AgeGroup.age4to6;
      case 'age7to9':
        return AgeGroup.age7to9;
      case 'age10to12':
        return AgeGroup.age10to12;
      case 'age13plus':
        return AgeGroup.age13plus;
      default:
        return null;
    }
  }

  // Get role display name
  String get roleDisplayName {
    switch (role) {
      case UserRole.student:
        return 'Öğrenci';
      case UserRole.parent:
        return 'Veli';
      case UserRole.teacher:
        return 'Öğretmen';
      case UserRole.visitor:
        return 'Ziyaretçi';
      case UserRole.admin:
        return 'Admin';
    }
  }

  // Get age group display name
  String? get ageGroupDisplayName {
    if (ageGroup == null) return null;
    switch (ageGroup!) {
      case AgeGroup.age4to6:
        return '4-6 Yaş';
      case AgeGroup.age7to9:
        return '7-9 Yaş';
      case AgeGroup.age10to12:
        return '10-12 Yaş';
      case AgeGroup.age13plus:
        return '13+ Yaş';
      case AgeGroup.all:
        return 'Tümü';
    }
  }

  // Check if user has access to live camera
  bool get hasLiveCameraAccess {
    return role == UserRole.parent || role == UserRole.admin;
  }

  // Convenience getters for compatibility
  String get id => uid;
  String get name => displayName;

  // Check if user is admin
  bool get isAdmin => role == UserRole.admin;

  // Check if user is parent
  bool get isParent => role == UserRole.parent;

  // Check if user is student
  bool get isStudent => role == UserRole.student;

  // Check if user is teacher
  bool get isTeacher => role == UserRole.teacher;

  // Check if user is visitor
  bool get isVisitor => role == UserRole.visitor;

  // Check if user has active Pro subscription
  bool get hasActivePro {
    if (!isPro) return false;
    if (proExpiryDate == null) return true; // Lifetime Pro
    return proExpiryDate!.isAfter(DateTime.now());
  }

  // Check if user is in trial period
  bool get isInTrialPeriod {
    if (proTrialStartDate == null || hasUsedTrial) return false;
    final trialEndDate = proTrialStartDate!.add(const Duration(days: 7));
    return DateTime.now().isBefore(trialEndDate);
  }

  // Check if user can use Pro features
  bool get canUseProFeatures => hasActivePro || isInTrialPeriod;

  // Copy with method
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? profilePictureUrl,
    UserRole? role,
    AgeGroup? ageGroup,
    String? parentId,
    List<String>? studentIds,
    String? classId,
    String? description,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isPro,
    DateTime? proExpiryDate,
    DateTime? proTrialStartDate,
    bool? hasUsedTrial,
    int? dailyPostCount,
    DateTime? lastPostResetDate,
    int? dailyAiMessageCount,
    DateTime? lastAiResetDate,
    int? dailyQuestionCount,
    DateTime? lastQuestionDate,
    DateTime? birthDate,
    bool? hasSelectedPurpose,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      role: role ?? this.role,
      ageGroup: ageGroup ?? this.ageGroup,
      parentId: parentId ?? this.parentId,
      studentIds: studentIds ?? this.studentIds,
      classId: classId ?? this.classId,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isPro: isPro ?? this.isPro,
      proExpiryDate: proExpiryDate ?? this.proExpiryDate,
      proTrialStartDate: proTrialStartDate ?? this.proTrialStartDate,
      hasUsedTrial: hasUsedTrial ?? this.hasUsedTrial,
      dailyPostCount: dailyPostCount ?? this.dailyPostCount,
      lastPostResetDate: lastPostResetDate ?? this.lastPostResetDate,
      dailyAiMessageCount: dailyAiMessageCount ?? this.dailyAiMessageCount,
      lastAiResetDate: lastAiResetDate ?? this.lastAiResetDate,
      dailyQuestionCount: dailyQuestionCount ?? this.dailyQuestionCount,
      lastQuestionDate: lastQuestionDate ?? this.lastQuestionDate,
      birthDate: birthDate ?? this.birthDate,
      hasSelectedPurpose: hasSelectedPurpose ?? this.hasSelectedPurpose,
    );
  }
}
