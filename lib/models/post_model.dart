/// Post model for social feed - Enhanced with multiple media support
class Post {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String? userRole; // student, parent, teacher, admin
  final String description;
  final String? imageUrl; // Kept for backward compatibility
  final List<String> mediaUrls; // Multiple media URLs
  final List<String> mediaTypes; // image, pdf, video
  final String? linkUrl; // External link
  final String? linkTitle;
  final String? linkDescription;
  final String? linkPreviewImage;
  final List<String> tags; // Hashtags like #robotics #coding
  final List<String> likes; // List of user IDs who liked
  final int commentCount;
  final bool isApproved; // Content moderation flag
  final DateTime createdAt;
  final DateTime? updatedAt;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    this.userRole,
    required this.description,
    this.imageUrl,
    this.mediaUrls = const [],
    this.mediaTypes = const [],
    this.linkUrl,
    this.linkTitle,
    this.linkDescription,
    this.linkPreviewImage,
    this.tags = const [],
    required this.likes,
    this.commentCount = 0,
    this.isApproved = true,
    required this.createdAt,
    this.updatedAt,
  });

  // // REMOVED: Firebase-specific method
  // // factory Post.fromFirestore(DocumentSnapshot doc) { ... }

  // // REMOVED: Firebase-specific method
  // // Map<String, dynamic> toFirestore() { ... }

  Post copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    String? userRole,
    String? description,
    String? imageUrl,
    List<String>? mediaUrls,
    List<String>? mediaTypes,
    String? linkUrl,
    String? linkTitle,
    String? linkDescription,
    String? linkPreviewImage,
    List<String>? tags,
    List<String>? likes,
    int? commentCount,
    bool? isApproved,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      userRole: userRole ?? this.userRole,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      mediaTypes: mediaTypes ?? this.mediaTypes,
      linkUrl: linkUrl ?? this.linkUrl,
      linkTitle: linkTitle ?? this.linkTitle,
      linkDescription: linkDescription ?? this.linkDescription,
      linkPreviewImage: linkPreviewImage ?? this.linkPreviewImage,
      tags: tags ?? this.tags,
      likes: likes ?? this.likes,
      commentCount: commentCount ?? this.commentCount,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool isLikedBy(String userId) {
    return likes.contains(userId);
  }

  bool hasMedia() {
    return mediaUrls.isNotEmpty || imageUrl != null;
  }

  bool hasLink() {
    return linkUrl != null && linkUrl!.isNotEmpty;
  }

  bool hasPDF() {
    return mediaTypes.contains('pdf');
  }

  bool hasImages() {
    return mediaTypes.contains('image') || imageUrl != null;
  }

  // Supabase methods
  factory Post.fromSupabase(Map<String, dynamic> data) {
    return Post(
      id: data['id']?.toString() ?? '',
      userId: data['user_id'] ?? '',
      userName: data['user_name'] ?? 'Kullanıcı',
      userPhotoUrl: data['user_photo_url'],
      userRole: data['user_role'],
      description: data['description'] ?? '',
      imageUrl: data['image_url'],
      mediaUrls: data['media_urls'] != null
          ? List<String>.from(data['media_urls'])
          : [],
      mediaTypes: data['media_types'] != null
          ? List<String>.from(data['media_types'])
          : [],
      linkUrl: data['link_url'],
      linkTitle: data['link_title'],
      linkDescription: data['link_description'],
      linkPreviewImage: data['link_preview_image'],
      tags: data['tags'] != null
          ? List<String>.from(data['tags'])
          : [],
      likes: data['likes'] != null
          ? List<String>.from(data['likes'])
          : [],
      commentCount: data['comment_count'] ?? 0,
      isApproved: data['is_approved'] ?? true,
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'user_id': userId,
      'user_name': userName,
      'user_photo_url': userPhotoUrl,
      'user_role': userRole,
      'description': description,
      'image_url': imageUrl,
      'media_urls': mediaUrls,
      'media_types': mediaTypes,
      'link_url': linkUrl,
      'link_title': linkTitle,
      'link_description': linkDescription,
      'link_preview_image': linkPreviewImage,
      'tags': tags,
      'likes': likes,
      'comment_count': commentCount,
      'is_approved': isApproved,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

/// Comment model for posts
class PostComment {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String comment;
  final DateTime createdAt;

  PostComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.comment,
    required this.createdAt,
  });

  // // REMOVED: Firebase-specific method
  // // factory PostComment.fromFirestore(DocumentSnapshot doc) { ... }

  // // REMOVED: Firebase-specific method
  // // Map<String, dynamic> toFirestore() { ... }

  // Supabase methods
  factory PostComment.fromSupabase(Map<String, dynamic> data) {
    return PostComment(
      id: data['id']?.toString() ?? '',
      postId: data['post_id'] ?? '',
      userId: data['user_id'] ?? '',
      userName: data['user_name'] ?? 'Kullanıcı',
      userPhotoUrl: data['user_photo_url'],
      comment: data['comment'] ?? '',
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'post_id': postId,
      'user_id': userId,
      'user_name': userName,
      'user_photo_url': userPhotoUrl,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
