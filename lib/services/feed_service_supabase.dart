import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import '../models/post_model.dart';
import '../constants/post_limits.dart';

class FeedServiceSupabase {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Table names
  static const String _postsTable = 'posts';
  static const String _commentsTable = 'post_comments';

  /// Get posts stream with pagination - Real-time
  Stream<List<Post>> getPostsStream({int limit = 20}) {
    return _supabase
        .from(_postsTable)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(limit)
        .map((data) => data.map((item) => Post.fromSupabase(item)).toList());
  }

  /// Get posts for a specific user - Real-time
  Stream<List<Post>> getUserPostsStream(String userId, {int limit = 20}) {
    return _supabase
        .from(_postsTable)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit)
        .map((data) => data.map((item) => Post.fromSupabase(item)).toList());
  }

  /// Create a new post
  Future<String> createPost({
    required String userId,
    required String userName,
    String? userPhotoUrl,
    String? userRole,
    required String description,
    File? imageFile,
  }) async {
    try {
      String? imageUrl;

      // Upload image if provided
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile, userId);
      }

      final post = Post(
        id: '',
        userId: userId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        userRole: userRole,
        description: description,
        imageUrl: imageUrl,
        likes: [],
        commentCount: 0,
        createdAt: DateTime.now(),
      );

      final response = await _supabase
          .from(_postsTable)
          .insert(post.toSupabaseMap())
          .select('id')
          .single();

      return response['id'].toString();
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  /// Compress and upload image to Supabase Storage
  Future<String> _uploadImage(File imageFile, String userId) async {
    try {
      // Compress image
      final compressedImage = await _compressImage(imageFile);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${userId}_$timestamp.jpg';
      final storagePath = 'posts/$fileName';

      // Upload compressed image to Supabase Storage
      await _supabase.storage
          .from('posts')
          .upload(storagePath, compressedImage);

      // Get public URL
      final downloadUrl = _supabase.storage
          .from('posts')
          .getPublicUrl(storagePath);

      // Clean up temporary file
      try {
        await compressedImage.delete();
      } catch (e) {
        // Ignore cleanup errors
      }

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Compress image to reduce size while maintaining quality
  Future<File> _compressImage(File file) async {
    try {
      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final targetPath = path.join(
        tempDir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // Compress image with limits from PostLimits
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: PostLimits.compressQuality,
        minWidth: PostLimits.targetImageWidth,
        minHeight: PostLimits.targetImageHeight,
        format: CompressFormat.jpeg,
      );

      if (result == null) {
        // If compression fails, return original file
        return file;
      }

      return File(result.path);
    } catch (e) {
      // If compression fails, return original file
      return file;
    }
  }

  /// Toggle like on a post
  Future<void> toggleLike(String postId, String userId) async {
    try {
      // Sample posts cannot be liked
      if (postId.startsWith('sample_')) {
        return;
      }

      final response = await _supabase
          .from(_postsTable)
          .select('likes')
          .eq('id', postId)
          .single();

      final likes = List<String>.from(response['likes'] ?? []);

      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
      }

      await _supabase
          .from(_postsTable)
          .update({'likes': likes})
          .eq('id', postId);
    } catch (e) {
      throw Exception('Failed to toggle like: $e');
    }
  }

  /// Add comment to a post
  Future<void> addComment({
    required String postId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required String comment,
  }) async {
    try {
      final postComment = PostComment(
        id: '',
        postId: postId,
        userId: userId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        comment: comment,
        createdAt: DateTime.now(),
      );

      // Add comment
      await _supabase
          .from(_commentsTable)
          .insert(postComment.toSupabaseMap());

      // Increment comment count
      final response = await _supabase
          .from(_postsTable)
          .select('comment_count')
          .eq('id', postId)
          .single();

      final currentCount = response['comment_count'] ?? 0;

      await _supabase
          .from(_postsTable)
          .update({'comment_count': currentCount + 1})
          .eq('id', postId);
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  /// Get comments for a post - Real-time
  Stream<List<PostComment>> getCommentsStream(String postId) {
    // Sample posts don't have comments, return empty stream
    if (postId.startsWith('sample_')) {
      return Stream.value([]);
    }

    return _supabase
        .from(_commentsTable)
        .stream(primaryKey: ['id'])
        .eq('post_id', postId)
        .order('created_at')
        .map((data) => data.map((item) => PostComment.fromSupabase(item)).toList());
  }

  /// Delete a post
  Future<void> deletePost(String postId, String? imageUrl) async {
    try {
      // Delete image from storage if exists
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          final uri = Uri.parse(imageUrl);
          final pathSegments = uri.pathSegments;
          if (pathSegments.isNotEmpty) {
            final storagePath = pathSegments.sublist(1).join('/');
            await _supabase.storage.from('posts').remove([storagePath]);
          }
        } catch (e) {
          print('Failed to delete image: $e');
        }
      }

      // Delete all comments
      await _supabase
          .from(_commentsTable)
          .delete()
          .eq('post_id', postId);

      // Delete post
      await _supabase
          .from(_postsTable)
          .delete()
          .eq('id', postId);
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  /// Update post description
  Future<void> updatePost(String postId, String newDescription) async {
    try {
      await _supabase
          .from(_postsTable)
          .update({
            'description': newDescription,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', postId);
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }

  /// Delete comment
  Future<void> deleteComment(String commentId, String postId) async {
    try {
      await _supabase
          .from(_commentsTable)
          .delete()
          .eq('id', commentId);

      // Decrement comment count
      final response = await _supabase
          .from(_postsTable)
          .select('comment_count')
          .eq('id', postId)
          .single();

      final currentCount = response['comment_count'] ?? 0;

      await _supabase
          .from(_postsTable)
          .update({'comment_count': (currentCount - 1).clamp(0, 999999)})
          .eq('id', postId);
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }

  /// Get single post
  Future<Post?> getPost(String postId) async {
    try {
      final response = await _supabase
          .from(_postsTable)
          .select()
          .eq('id', postId)
          .single();

      return Post.fromSupabase(response);
    } catch (e) {
      throw Exception('Failed to get post: $e');
    }
  }

  /// Get today's post count for a user
  Future<int> getTodayPostCount(String userId) async {
    try {
      // Get today's start time (00:00:00)
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      final response = await _supabase
          .from(_postsTable)
          .select()
          .eq('user_id', userId)
          .gte('created_at', todayStart.toIso8601String())
          .count();

      return response.count;
    } catch (e) {
      throw Exception('Failed to get today post count: $e');
    }
  }

  /// Check if user can create post (based on daily limit)
  Future<bool> canCreatePost(String userId, String userRole) async {
    try {
      final limit = PostLimits.getMaxPostsPerDayForRole(userRole);

      // Unlimited posting rights (-1)
      if (limit < 0) {
        return true;
      }

      final todayCount = await getTodayPostCount(userId);
      return todayCount < limit;
    } catch (e) {
      throw Exception('Failed to check if user can create post: $e');
    }
  }

  /// Get posts with pagination (for infinite scroll)
  Future<List<Post>> getPostsPaginated({
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      final response = await _supabase
          .from(_postsTable)
          .select()
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      return (response as List)
          .map((item) => Post.fromSupabase(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to get paginated posts: $e');
    }
  }

  /// Get user posts with pagination
  Future<List<Post>> getUserPostsPaginated(
    String userId, {
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      final response = await _supabase
          .from(_postsTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      return (response as List)
          .map((item) => Post.fromSupabase(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to get paginated user posts: $e');
    }
  }

  /// Get comments with pagination
  Future<List<PostComment>> getCommentsPaginated(
    String postId, {
    int page = 0,
    int pageSize = 50,
  }) async {
    try {
      if (postId.startsWith('sample_')) {
        return [];
      }

      final response = await _supabase
          .from(_commentsTable)
          .select()
          .eq('post_id', postId)
          .order('created_at')
          .range(page * pageSize, (page + 1) * pageSize - 1);

      return (response as List)
          .map((item) => PostComment.fromSupabase(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to get paginated comments: $e');
    }
  }
}
