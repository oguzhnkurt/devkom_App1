enum EventType {
  homework,
  exam,
  quiz,
  note,
  task,
  meeting,
  reminder,
}

enum EventPriority {
  low,
  medium,
  high,
}

class AgendaEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final DateTime? dueDate;
  final EventType type;
  final EventPriority priority;
  final bool isCompleted;
  final String userId;
  final DateTime createdAt;
  
  // New fields for teacher/admin events
  final String createdByRole; // 'admin', 'teacher', 'student', 'parent', 'visitor'
  final String createdByName;
  final bool isPublic; // true = herkes görebilir (öğretmen/admin ekledi)

  AgendaEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.dueDate,
    required this.type,
    required this.priority,
    this.isCompleted = false,
    required this.userId,
    required this.createdAt,
    this.createdByRole = 'student',
    this.createdByName = '',
    this.isPublic = false,
  });

  // // REMOVED: Firebase-specific method
  // // factory AgendaEvent.fromFirestore(DocumentSnapshot doc) { ... }

  // // REMOVED: Firebase-specific method
  // // Map<String, dynamic> toFirestore() { ... }

  // Copy with method
  AgendaEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    DateTime? dueDate,
    EventType? type,
    EventPriority? priority,
    bool? isCompleted,
    String? userId,
    DateTime? createdAt,
    String? createdByRole,
    String? createdByName,
    bool? isPublic,
  }) {
    return AgendaEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      createdByRole: createdByRole ?? this.createdByRole,
      createdByName: createdByName ?? this.createdByName,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  // Get event type display name (Turkish)
  String get typeDisplayName {
    switch (type) {
      case EventType.homework:
        return 'Ödev';
      case EventType.exam:
        return 'Sınav';
      case EventType.quiz:
        return 'Quiz';
      case EventType.note:
        return 'Not';
      case EventType.task:
        return 'Görev';
      case EventType.meeting:
        return 'Toplantı';
      case EventType.reminder:
        return 'Hatırlatma';
    }
  }

  // Get event type icon
  String get typeIcon {
    switch (type) {
      case EventType.homework:
        return '📝';
      case EventType.exam:
        return '📚';
      case EventType.quiz:
        return '❓';
      case EventType.note:
        return '📋';
      case EventType.task:
        return '✅';
      case EventType.meeting:
        return '👥';
      case EventType.reminder:
        return '🔔';
    }
  }
  
  // Check if current user can see this event
  bool canBeSeenBy(String currentUserId) {
    if (isPublic) return true; // Public events (from teacher/admin)
    return userId == currentUserId; // Private events (own)
  }

  /// Convert to Map for Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'type': type.name,
      'priority': priority.name,
      'is_completed': isCompleted,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'created_by_role': createdByRole,
      'created_by_name': createdByName,
      'is_public': isPublic,
    };
  }
}
