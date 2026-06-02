/// Context-Aware Workspace Model
/// Stores user's work context including code, preferences, and AI conversation history
class WorkspaceContext {
  final String id;
  final String userId;
  final String projectName;
  final String category; // 'software' or 'robotics'

  // Context data
  final Map<String, dynamic> codeFiles; // filename -> code content
  final Map<String, dynamic> preferences; // user preferences (theme, layout, etc.)
  final List<ConversationMessage> aiHistory; // AI conversation history
  final Map<String, dynamic> customTools; // user-created tools and snippets

  // Metadata
  final DateTime createdAt;
  final DateTime lastModified;
  final String lastActiveFile;
  final Map<String, int> filePositions; // cursor positions per file

  WorkspaceContext({
    required this.id,
    required this.userId,
    required this.projectName,
    required this.category,
    required this.codeFiles,
    required this.preferences,
    required this.aiHistory,
    required this.customTools,
    required this.createdAt,
    required this.lastModified,
    required this.lastActiveFile,
    required this.filePositions,
  });

  // // REMOVED: Firebase-specific method
  // // factory WorkspaceContext.fromFirestore(DocumentSnapshot doc) { ... }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'projectName': projectName,
      'category': category,
      'codeFiles': codeFiles,
      'preferences': preferences,
      'aiHistory': aiHistory.map((e) => e.toMap()).toList(),
      'customTools': customTools,
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'lastActiveFile': lastActiveFile,
      'filePositions': filePositions,
    };
  }
}

/// AI Conversation Message
class ConversationMessage {
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata; // code snippets, images, etc.

  ConversationMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    this.metadata,
  });

  factory ConversationMessage.fromMap(Map<String, dynamic> map) {
    return ConversationMessage(
      role: map['role'] ?? 'user',
      content: map['content'] ?? '',
      timestamp: map['timestamp'] is String ? DateTime.parse(map['timestamp']) : DateTime.now(),
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}
