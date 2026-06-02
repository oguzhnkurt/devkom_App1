/// Support Message Model for Visitor-Support communication
class SupportMessageModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String subject;
  final String message;
  final DateTime createdAt;
  final bool isReplied;
  final String? replyMessage;
  final DateTime? repliedAt;
  final String? repliedBy;

  SupportMessageModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.subject,
    required this.message,
    required this.createdAt,
    this.isReplied = false,
    this.replyMessage,
    this.repliedAt,
    this.repliedBy,
  });

  // // REMOVED: Firebase-specific method
  // // factory SupportMessageModel.fromFirestore(DocumentSnapshot doc) { ... }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'subject': subject,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'isReplied': isReplied,
      'replyMessage': replyMessage,
      'repliedAt': repliedAt?.toIso8601String(),
      'repliedBy': repliedBy,
    };
  }
}
