import 'package:flutter/material.dart';

enum HomeworkStatus {
  pending,
  submitted,
  graded,
  late,
}

enum GradeResult {
  success, // Başarılı
  failed,  // Başarısız
  needsImprovement, // Geliştirilmeli
}

enum AgeGroup {
  age4to6,
  age7to9,
  age10to12,
  age13plus,
  all,
}

// Extension to convert Dart enum to Supabase database format
extension AgeGroupExtension on AgeGroup {
  String? toSupabaseValue() {
    switch (this) {
      case AgeGroup.age4to6:
      case AgeGroup.age7to9:
        return 'age_6_9';
      case AgeGroup.age10to12:
        return 'age_10_14';
      case AgeGroup.age13plus:
        return 'age_15_18';
      case AgeGroup.all:
        return null; // 'all' doesn't have a database equivalent
    }
  }

  static AgeGroup? fromSupabaseValue(String? value) {
    switch (value) {
      case 'age_6_9':
        return AgeGroup.age7to9;
      case 'age_10_14':
        return AgeGroup.age10to12;
      case 'age_15_18':
        return AgeGroup.age13plus;
      default:
        return null;
    }
  }
}

/// Homework Model
class HomeworkModel {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final DateTime createdAt;
  final String createdBy; // Admin user ID or Teacher ID
  final AgeGroup ageGroup;
  final List<String> assignedUserIds; // Empty = all users
  final bool isActive;
  final int maxScore;
  final String? imageUrl; // Optional image for homework
  final String? videoUrl; // Optional YouTube video URL
  final String? topic; // Optional topic/subject
  final String? teacherName; // Teacher name who created it
  final String status; // 'active' or 'inactive'

  HomeworkModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.createdAt,
    required this.createdBy,
    required this.ageGroup,
    required this.assignedUserIds,
    required this.isActive,
    this.maxScore = 100,
    this.imageUrl,
    this.videoUrl,
    this.topic,
    this.teacherName,
    this.status = 'active',
  });

  // Convenience getter for studentIds
  List<String> get studentIds => assignedUserIds;

  // // REMOVED: Firebase-specific method
  // // factory HomeworkModel.fromFirestore(DocumentSnapshot doc) { ... }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'ageGroup': ageGroup.name,
      'assignedUserIds': assignedUserIds,
      'isActive': isActive,
      'maxScore': maxScore,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'topic': topic,
      'teacherName': teacherName,
      'status': status,
    };
  }

  bool isOverdue() {
    return DateTime.now().isAfter(dueDate);
  }

  bool isAssignedToUser(String userId, [AgeGroup? userAgeGroup]) {
    // If assignedUserIds is empty, homework is for all users
    if (!assignedUserIds.isEmpty && !assignedUserIds.contains(userId)) {
      return false;
    }

    // Check age group if provided
    if (userAgeGroup != null && ageGroup != AgeGroup.all && ageGroup != userAgeGroup) {
      return false;
    }

    return true;
  }

  String getAgeGroupDisplayName() {
    switch (ageGroup) {
      case AgeGroup.age4to6:
        return '4-6 Yaş';
      case AgeGroup.age7to9:
        return '7-9 Yaş';
      case AgeGroup.age10to12:
        return '10-12 Yaş';
      case AgeGroup.age13plus:
        return '13+ Yaş';
      case AgeGroup.all:
        return 'Tüm Yaşlar';
    }
  }

  // Convenience getters
  bool get isLate => DateTime.now().isAfter(dueDate);
  bool get isUrgent {
    final daysRemaining = dueDate.difference(DateTime.now()).inDays;
    return daysRemaining <= 3 && daysRemaining >= 0;
  }

  // Supabase methods
  factory HomeworkModel.fromSupabase(Map<String, dynamic> data) {
    return HomeworkModel(
      id: data['id']?.toString() ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dueDate: DateTime.parse(data['due_date']),
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
      createdBy: data['created_by'] ?? data['teacher_id'] ?? '',
      ageGroup: data['age_group'] != null
          ? AgeGroup.values.byName(data['age_group'])
          : AgeGroup.all,
      assignedUserIds: data['assigned_user_ids'] != null
          ? List<String>.from(data['assigned_user_ids'])
          : [],
      isActive: data['is_active'] ?? (data['status'] == 'active'),
      maxScore: data['max_score'] ?? 100,
      imageUrl: data['image_url'],
      videoUrl: data['video_url'],
      topic: data['topic'],
      teacherName: data['teacher_name'],
      status: data['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
      'age_group': ageGroup.name,
      'assigned_user_ids': assignedUserIds,
      'is_active': isActive,
      'max_score': maxScore,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'topic': topic,
      'teacher_name': teacherName,
      'status': status,
    };
  }
}

/// Homework Submission Model
class HomeworkSubmission {
  final String id;
  final String homeworkId;
  final String userId;
  final String userName;
  final DateTime submittedAt;
  final List<String> fileUrls; // PDF or image URLs
  final String? notes;
  final HomeworkStatus status;
  final int? score;
  final GradeResult? gradeResult; // Başarılı/Başarısız/Geliştirilmeli
  final String? feedback;
  final DateTime? gradedAt;
  final String? gradedBy; // Teacher or admin user ID

  HomeworkSubmission({
    required this.id,
    required this.homeworkId,
    required this.userId,
    required this.userName,
    required this.submittedAt,
    required this.fileUrls,
    this.notes,
    required this.status,
    this.score,
    this.gradeResult,
    this.feedback,
    this.gradedAt,
    this.gradedBy,
  });

  // // REMOVED: Firebase-specific method
  // // factory HomeworkSubmission.fromFirestore(DocumentSnapshot doc) { ... }

  Map<String, dynamic> toMap() {
    return {
      'homeworkId': homeworkId,
      'userId': userId,
      'userName': userName,
      'submittedAt': submittedAt.toIso8601String(),
      'fileUrls': fileUrls,
      'notes': notes,
      'status': status.name,
      'score': score,
      'gradeResult': gradeResult?.name,
      'feedback': feedback,
      'gradedAt': gradedAt?.toIso8601String(),
      'gradedBy': gradedBy,
    };
  }

  String getStatusDisplayName() {
    switch (status) {
      case HomeworkStatus.pending:
        return 'Beklemede';
      case HomeworkStatus.submitted:
        return 'Teslim Edildi';
      case HomeworkStatus.graded:
        return 'Değerlendirildi';
      case HomeworkStatus.late:
        return 'Geç Teslim';
    }
  }

  Color getStatusColor() {
    switch (status) {
      case HomeworkStatus.pending:
        return Colors.orange;
      case HomeworkStatus.submitted:
        return Colors.blue;
      case HomeworkStatus.graded:
        return Colors.green;
      case HomeworkStatus.late:
        return Colors.red;
    }
  }

  String? getGradeResultDisplayName() {
    if (gradeResult == null) return null;
    switch (gradeResult!) {
      case GradeResult.success:
        return 'Başarılı';
      case GradeResult.failed:
        return 'Başarısız';
      case GradeResult.needsImprovement:
        return 'Geliştirilmeli';
    }
  }

  Color? getGradeResultColor() {
    if (gradeResult == null) return null;
    switch (gradeResult!) {
      case GradeResult.success:
        return Colors.green;
      case GradeResult.failed:
        return Colors.red;
      case GradeResult.needsImprovement:
        return Colors.orange;
    }
  }

  // Supabase methods
  factory HomeworkSubmission.fromSupabase(Map<String, dynamic> data) {
    return HomeworkSubmission(
      id: data['id']?.toString() ?? '',
      homeworkId: data['homework_id'] ?? '',
      userId: data['user_id'] ?? '',
      userName: data['user_name'] ?? '',
      submittedAt: DateTime.parse(data['submitted_at']),
      fileUrls: data['file_urls'] != null
          ? List<String>.from(data['file_urls'])
          : [],
      notes: data['notes'],
      status: HomeworkStatus.values.byName(data['status'] ?? 'pending'),
      score: data['score'],
      gradeResult: data['grade_result'] != null
          ? GradeResult.values.byName(data['grade_result'])
          : null,
      feedback: data['feedback'],
      gradedAt: data['graded_at'] != null
          ? DateTime.parse(data['graded_at'])
          : null,
      gradedBy: data['graded_by'],
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'homework_id': homeworkId,
      'user_id': userId,
      'user_name': userName,
      'submitted_at': submittedAt.toIso8601String(),
      'file_urls': fileUrls,
      'notes': notes,
      'status': status.name,
      'score': score,
      'grade_result': gradeResult?.name,
      'feedback': feedback,
      'graded_at': gradedAt?.toIso8601String(),
      'graded_by': gradedBy,
    };
  }
}
