/// Message types
enum MessageType {
  text,
  image,
  file,
  voice,
}

/// Message Model for Parent-Teacher Communication
class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String senderRole; // 'parent', 'teacher', 'admin', 'student'
  final String receiverId;
  final String receiverName;
  final String content; // Text content or file URL
  final MessageType type; // Message type
  final DateTime createdAt;
  final bool isRead;
  final DateTime? readAt;
  final String? studentId; // Optional: link to specific student
  final String? studentName;

  // Additional fields for media messages
  final String? fileName; // Original file name
  final String? fileSize; // File size in bytes
  final int? voiceDuration; // Voice message duration in seconds
  final String? thumbnailUrl; // Thumbnail for images/videos

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.receiverId,
    required this.receiverName,
    required this.content,
    this.type = MessageType.text,
    required this.createdAt,
    this.isRead = false,
    this.readAt,
    this.studentId,
    this.studentName,
    this.fileName,
    this.fileSize,
    this.voiceDuration,
    this.thumbnailUrl,
  });

  // // REMOVED: Firebase-specific method
  // // factory MessageModel.fromFirestore(DocumentSnapshot doc) { ... }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'content': content,
      'type': type.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'studentId': studentId,
      'studentName': studentName,
      'fileName': fileName,
      'fileSize': fileSize,
      'voiceDuration': voiceDuration,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  // Convert to Map for Supabase
  Map<String, dynamic> toSupabaseMap() {
    return {
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_role': senderRole,
      'receiver_id': receiverId,
      'receiver_name': receiverName,
      'content': content,
      'message_type': type.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'student_id': studentId,
      'student_name': studentName,
      'file_name': fileName,
      'file_size': fileSize,
      'voice_duration': voiceDuration,
      'thumbnail_url': thumbnailUrl,
    };
  }

  // Create from Supabase Map
  factory MessageModel.fromSupabase(Map<String, dynamic> data) {
    return MessageModel(
      id: data['id']?.toString() ?? '',
      senderId: data['sender_id'] ?? '',
      senderName: data['sender_name'] ?? '',
      senderRole: data['sender_role'] ?? '',
      receiverId: data['receiver_id'] ?? '',
      receiverName: data['receiver_name'] ?? '',
      content: data['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${data['message_type'] ?? 'text'}',
        orElse: () => MessageType.text,
      ),
      createdAt: DateTime.parse(data['created_at']),
      isRead: data['is_read'] ?? false,
      readAt: data['read_at'] != null ? DateTime.parse(data['read_at']) : null,
      studentId: data['student_id'],
      studentName: data['student_name'],
      fileName: data['file_name'],
      fileSize: data['file_size'],
      voiceDuration: data['voice_duration'],
      thumbnailUrl: data['thumbnail_url'],
    );
  }

  MessageModel copyWith({
    bool? isRead,
    DateTime? readAt,
  }) {
    return MessageModel(
      id: id,
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      receiverId: receiverId,
      receiverName: receiverName,
      content: content,
      type: type,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      studentId: studentId,
      studentName: studentName,
      fileName: fileName,
      fileSize: fileSize,
      voiceDuration: voiceDuration,
      thumbnailUrl: thumbnailUrl,
    );
  }
}

/// Conversation summary for listing
class ConversationModel {
  final String userId;
  final String userName;
  final String userRole;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  ConversationModel({
    required this.userId,
    required this.userName,
    required this.userRole,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });
}
