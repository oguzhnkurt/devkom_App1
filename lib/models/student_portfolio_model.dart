/// Skill tags for portfolio items
enum SkillTag {
  problemSolving('Problem Çözme', '🧩'),
  teamwork('Grup Çalışması', '🤝'),
  fineMotorSkills('İnce Motor Beceriler', '✋'),
  grossMotorSkills('Kaba Motor Beceriler', '🏃'),
  creativity('Yaratıcılık', '🎨'),
  communication('İletişim', '💬'),
  criticalThinking('Eleştirel Düşünme', '🤔'),
  timeManagement('Zaman Yönetimi', '⏰'),
  leadership('Liderlik', '👑'),
  concentration('Odaklanma', '🎯'),
  independence('Bağımsızlık', '🦸'),
  emotionalDevelopment('Duygusal Gelişim', '❤️'),
  socialSkills('Sosyal Beceriler', '👥'),
  mathSkills('Matematik Becerileri', '🔢'),
  languageSkills('Dil Becerileri', '📖'),
  scientificThinking('Bilimsel Düşünme', '🔬'),
  artisticExpression('Sanatsal İfade', '🎭'),
  technicalSkills('Teknik Beceriler', '⚙️');

  final String label;
  final String emoji;

  const SkillTag(this.label, this.emoji);

  String get displayName => '$emoji $label';
}

/// Portfolio item type
enum PortfolioItemType {
  photo('Fotoğraf', '📷'),
  video('Video', '🎥'),
  project('Proje', '📁'),
  artwork('Sanat Eseri', '🎨'),
  achievement('Başarı', '🏆'),
  milestone('Kilometre Taşı', '🎯');

  final String label;
  final String emoji;

  const PortfolioItemType(this.label, this.emoji);

  String get displayName => '$emoji $label';
}

/// Student Portfolio Item Model
class StudentPortfolioItem {
  final String id;
  final String studentId;
  final String teacherId;
  final String teacherName;
  final String? teacherPhotoUrl;
  final String title;
  final String description;
  final PortfolioItemType itemType;
  final List<String> mediaUrls; // Photos or videos
  final List<SkillTag> skillTags;
  final String teacherFeedback;
  final DateTime activityDate; // When the activity happened
  final DateTime createdAt; // When it was uploaded
  final DateTime? updatedAt;

  // Parent engagement
  final List<String> likes; // Parent user IDs who liked
  final int commentCount;
  final bool isHighlight; // Featured/highlighted by teacher

  StudentPortfolioItem({
    required this.id,
    required this.studentId,
    required this.teacherId,
    required this.teacherName,
    this.teacherPhotoUrl,
    required this.title,
    required this.description,
    required this.itemType,
    required this.mediaUrls,
    required this.skillTags,
    required this.teacherFeedback,
    required this.activityDate,
    required this.createdAt,
    this.updatedAt,
    this.likes = const [],
    this.commentCount = 0,
    this.isHighlight = false,
  });

  // // REMOVED: Firebase-specific method
  // // factory StudentPortfolioItem.fromFirestore(DocumentSnapshot doc) { ... }

  // // REMOVED: Firebase-specific method
  // // Map<String, dynamic> toFirestore() { ... }

  StudentPortfolioItem copyWith({
    String? id,
    String? studentId,
    String? teacherId,
    String? teacherName,
    String? teacherPhotoUrl,
    String? title,
    String? description,
    PortfolioItemType? itemType,
    List<String>? mediaUrls,
    List<SkillTag>? skillTags,
    String? teacherFeedback,
    DateTime? activityDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? likes,
    int? commentCount,
    bool? isHighlight,
  }) {
    return StudentPortfolioItem(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      teacherPhotoUrl: teacherPhotoUrl ?? this.teacherPhotoUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      itemType: itemType ?? this.itemType,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      skillTags: skillTags ?? this.skillTags,
      teacherFeedback: teacherFeedback ?? this.teacherFeedback,
      activityDate: activityDate ?? this.activityDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likes: likes ?? this.likes,
      commentCount: commentCount ?? this.commentCount,
      isHighlight: isHighlight ?? this.isHighlight,
    );
  }

  bool isLikedBy(String userId) {
    return likes.contains(userId);
  }
}

/// Portfolio Comment Model
class PortfolioComment {
  final String id;
  final String portfolioItemId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String userRole; // parent, teacher, admin
  final String comment;
  final DateTime createdAt;

  PortfolioComment({
    required this.id,
    required this.portfolioItemId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.userRole,
    required this.comment,
    required this.createdAt,
  });

  // // REMOVED: Firebase-specific method
  // // factory PortfolioComment.fromFirestore(DocumentSnapshot doc) { ... }

  // // REMOVED: Firebase-specific method
  // // Map<String, dynamic> toFirestore() { ... }
}

/// Statistics for portfolio analytics
class PortfolioStatistics {
  final int totalItems;
  final Map<SkillTag, int> skillCounts;
  final Map<PortfolioItemType, int> typeCounts;
  final int totalLikes;
  final int totalComments;
  final DateTime? lastUpdate;

  PortfolioStatistics({
    required this.totalItems,
    required this.skillCounts,
    required this.typeCounts,
    required this.totalLikes,
    required this.totalComments,
    this.lastUpdate,
  });

  factory PortfolioStatistics.empty() {
    return PortfolioStatistics(
      totalItems: 0,
      skillCounts: {},
      typeCounts: {},
      totalLikes: 0,
      totalComments: 0,
    );
  }
}
