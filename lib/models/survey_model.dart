enum SurveyQuestionType {
  multipleChoice,
  text,
  rating,
  yesNo,
}

/// Survey Question Model
class SurveyQuestion {
  final String id;
  final String question;
  final SurveyQuestionType type;
  final List<String>? options; // for multiple choice
  final bool isRequired;

  SurveyQuestion({
    required this.id,
    required this.question,
    required this.type,
    this.options,
    this.isRequired = false,
  });

  factory SurveyQuestion.fromMap(Map<String, dynamic> data, String id) {
    return SurveyQuestion(
      id: id,
      question: data['question'] ?? '',
      type: SurveyQuestionType.values.byName(data['type'] ?? 'text'),
      options: data['options'] != null ? List<String>.from(data['options']) : null,
      isRequired: data['isRequired'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'type': type.name,
      'options': options,
      'isRequired': isRequired,
    };
  }
}

/// Survey Model
class SurveyModel {
  final String id;
  final String title;
  final String description;
  final String createdBy;
  final String createdByName;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isActive;
  final List<SurveyQuestion> questions;
  final List<String> targetRoles; // ['parent', 'student', 'teacher']

  SurveyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    this.expiresAt,
    this.isActive = true,
    required this.questions,
    required this.targetRoles,
  });

  // // REMOVED: Firebase-specific method
  // // factory SurveyModel.fromFirestore(DocumentSnapshot doc) { ... }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'isActive': isActive,
      'questions': questions.map((q) => q.toMap()).toList(),
      'targetRoles': targetRoles,
    };
  }

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
}

/// Survey Response Model
class SurveyResponse {
  final String id;
  final String surveyId;
  final String userId;
  final String userName;
  final String userRole;
  final Map<String, dynamic> answers; // questionId -> answer
  final DateTime submittedAt;

  SurveyResponse({
    required this.id,
    required this.surveyId,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.answers,
    required this.submittedAt,
  });

  // // REMOVED: Firebase-specific method
  // // factory SurveyResponse.fromFirestore(DocumentSnapshot doc) { ... }

  Map<String, dynamic> toMap() {
    return {
      'surveyId': surveyId,
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'answers': answers,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }
}
