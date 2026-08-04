import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import '../models/post_model.dart';
import 'package:flutter/foundation.dart';

/// Comprehensive service for managing social feed posts with Supabase
/// Handles posts, likes, comments, media uploads, and daily limits
class SocialFeedServiceSupabase {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Table names
  static const String _postsTable = 'posts';
  static const String _commentsTable = 'post_comments';
  static const String _userPostCountsTable = 'user_post_counts';
  static const String _usersTable = 'users';

  /// Check daily post limit for a user
  /// Admin and Teacher: Unlimited posts
  /// Student and Parent: 2 posts per day
  Future<Map<String, dynamic>> checkDailyPostLimit(String userId) async {
    try {
      // Get user's role
      final userResponse = await _supabase
          .from(_usersTable)
          .select('role')
          .eq('id', userId)
          .single();

      final String? userRole = userResponse['role'];

      // Admin and teacher have unlimited posts
      if (userRole == 'admin' || userRole == 'teacher') {
        return {
          'canPost': true,
          'remaining': -1, // Unlimited
          'isPro': true, // Keep for UI compatibility
        };
      }

      // Check today's post count for student and parent roles
      final today = DateTime.now();
      final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final countResponse = await _supabase
          .from(_userPostCountsTable)
          .select('count')
          .eq('id', '${userId}_$dateKey')
          .maybeSingle();

      int postCount = 0;
      if (countResponse != null) {
        postCount = countResponse['count'] ?? 0;
      }

      const dailyLimit = 2;
      final remaining = dailyLimit - postCount;

      return {
        'canPost': remaining > 0,
        'remaining': remaining > 0 ? remaining : 0,
        'isPro': false,
      };
    } catch (e) {
      debugPrint('Error checking daily post limit: $e');
      return {
        'canPost': false,
        'remaining': 0,
        'isPro': false,
        'error': e.toString(),
      };
    }
  }

  /// Increment daily post count
  Future<void> _incrementPostCount(String userId) async {
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final docId = '${userId}_$dateKey';

    // Check if document exists
    final existing = await _supabase
        .from(_userPostCountsTable)
        .select()
        .eq('id', docId)
        .maybeSingle();

    if (existing != null) {
      // Update existing
      await _supabase
          .from(_userPostCountsTable)
          .update({
            'count': (existing['count'] ?? 0) + 1,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', docId);
    } else {
      // Insert new
      await _supabase.from(_userPostCountsTable).insert({
        'id': docId,
        'user_id': userId,
        'date': dateKey,
        'count': 1,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Upload media to Supabase Storage
  Future<String> uploadMedia(File file, String type, String userId, String postId) async {
    try {
      final fileName = path.basename(file.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = 'posts/$type/$userId/$postId/${timestamp}_$fileName';

      File uploadFile = file;

      // Compress images before upload
      if (type == 'images') {
        uploadFile = await _compressImage(file);
      }

      // Upload to Supabase Storage
      await _supabase.storage
          .from('posts')
          .upload(storagePath, uploadFile);

      // Get public URL
      final publicUrl = _supabase.storage
          .from('posts')
          .getPublicUrl(storagePath);

      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading media: $e');
      throw Exception('Failed to upload media: $e');
    }
  }

  /// Compress image before upload
  Future<File> _compressImage(File file) async {
    try {
      final filePath = file.absolute.path;
      final lastIndex = filePath.lastIndexOf('.');
      final splitPath = filePath.substring(0, lastIndex);
      final outPath = '${splitPath}_compressed.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        outPath,
        quality: 70,
        minWidth: 1920,
        minHeight: 1080,
      );

      return result != null ? File(result.path) : file;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return file;
    }
  }

  /// Upload PDF to Supabase Storage
  Future<String> uploadPDF(File file, String userId, String postId) async {
    return await uploadMedia(file, 'pdfs', userId, postId);
  }

  /// Fetch link preview metadata
  Future<Map<String, String?>> fetchLinkPreview(String url) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final html = response.body;

        // Extract meta tags using regex
        String? title = _extractMetaTag(html, 'og:title') ??
                       _extractMetaTag(html, 'twitter:title') ??
                       _extractTitle(html);

        String? description = _extractMetaTag(html, 'og:description') ??
                             _extractMetaTag(html, 'twitter:description') ??
                             _extractMetaTag(html, 'description');

        String? image = _extractMetaTag(html, 'og:image') ??
                       _extractMetaTag(html, 'twitter:image');

        return {
          'title': title,
          'description': description,
          'image': image,
        };
      }
    } catch (e) {
      debugPrint('Error fetching link preview: $e');
    }

    return {
      'title': url,
      'description': null,
      'image': null,
    };
  }

  String? _extractMetaTag(String html, String property) {
    final regex = RegExp(
      '<meta[^>]*(?:property|name)=["\']$property["\'][^>]*content=["\']([^"\']*)["\']',
      caseSensitive: false,
    );
    final match = regex.firstMatch(html);
    return match?.group(1);
  }

  String? _extractTitle(String html) {
    final regex = RegExp(r'<title[^>]*>([^<]*)</title>', caseSensitive: false);
    final match = regex.firstMatch(html);
    return match?.group(1);
  }

  /// Create a new post
  Future<String> createPost({
    required String userId,
    required String userName,
    String? userPhotoUrl,
    String? userRole,
    required String description,
    List<File>? imageFiles,
    File? pdfFile,
    String? linkUrl,
    List<String>? tags,
  }) async {
    try {
      // Check daily limit first
      final limitCheck = await checkDailyPostLimit(userId);
      if (!limitCheck['canPost']) {
        throw Exception('Daily post limit reached');
      }

      List<String> mediaUrls = [];
      List<String> mediaTypes = [];

      // Generate post ID first (using UUID from Supabase)
      final tempPost = await _supabase.from(_postsTable).insert({
        'user_id': userId,
        'user_name': userName,
        'user_photo_url': userPhotoUrl,
        'user_role': userRole,
        'description': description,
        'media_urls': [],
        'media_types': [],
        'tags': tags ?? [],
        'likes': [],
        'comment_count': 0,
        'is_approved': true,
        'created_at': DateTime.now().toIso8601String(),
      }).select('id').single();

      final postId = tempPost['id'].toString();

      // Upload images
      if (imageFiles != null && imageFiles.isNotEmpty) {
        for (var imageFile in imageFiles) {
          final url = await uploadMedia(imageFile, 'images', userId, postId);
          mediaUrls.add(url);
          mediaTypes.add('image');
        }
      }

      // Upload PDF
      if (pdfFile != null) {
        final url = await uploadPDF(pdfFile, userId, postId);
        mediaUrls.add(url);
        mediaTypes.add('pdf');
      }

      // Fetch link preview if URL provided
      String? linkTitle;
      String? linkDescription;
      String? linkPreviewImage;

      if (linkUrl != null && linkUrl.isNotEmpty) {
        final preview = await fetchLinkPreview(linkUrl);
        linkTitle = preview['title'];
        linkDescription = preview['description'];
        linkPreviewImage = preview['image'];
      }

      // Update post with media URLs and link preview
      await _supabase.from(_postsTable).update({
        'media_urls': mediaUrls,
        'media_types': mediaTypes,
        'link_url': linkUrl,
        'link_title': linkTitle,
        'link_description': linkDescription,
        'link_preview_image': linkPreviewImage,
      }).eq('id', postId);

      // Increment post count
      await _incrementPostCount(userId);

      return postId;
    } catch (e) {
      debugPrint('Error creating post: $e');
      rethrow;
    }
  }

  /// Like a post
  Future<void> likePost(String postId, String userId) async {
    try {
      final response = await _supabase
          .from(_postsTable)
          .select('likes')
          .eq('id', postId)
          .single();

      final List<String> likes = List<String>.from(response['likes'] ?? []);
      if (!likes.contains(userId)) {
        likes.add(userId);
      }

      await _supabase
          .from(_postsTable)
          .update({'likes': likes})
          .eq('id', postId);
    } catch (e) {
      debugPrint('Error liking post: $e');
      rethrow;
    }
  }

  /// Unlike a post
  Future<void> unlikePost(String postId, String userId) async {
    try {
      final response = await _supabase
          .from(_postsTable)
          .select('likes')
          .eq('id', postId)
          .single();

      final List<String> likes = List<String>.from(response['likes'] ?? []);
      likes.remove(userId);

      await _supabase
          .from(_postsTable)
          .update({'likes': likes})
          .eq('id', postId);
    } catch (e) {
      debugPrint('Error unliking post: $e');
      rethrow;
    }
  }

  /// Add a comment to a post
  Future<void> addComment({
    required String postId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required String comment,
  }) async {
    try {
      final commentDoc = PostComment(
        id: '',
        postId: postId,
        userId: userId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        comment: comment,
        createdAt: DateTime.now(),
      );

      await _supabase.from(_commentsTable).insert(commentDoc.toSupabaseMap());

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
      debugPrint('Error adding comment: $e');
      rethrow;
    }
  }

  /// Get comments for a post (Real-time stream)
  Stream<List<PostComment>> getComments(String postId) {
    return _supabase
        .from(_commentsTable)
        .stream(primaryKey: ['id'])
        .eq('post_id', postId)
        .order('created_at')
        .map((data) => data.map((item) => PostComment.fromSupabase(item)).toList());
  }

  /// Delete a post (only by owner)
  Future<void> deletePost(String postId, String userId) async {
    try {
      final postResponse = await _supabase
          .from(_postsTable)
          .select()
          .eq('id', postId)
          .single();

      if (postResponse['user_id'] != userId) {
        throw Exception('Unauthorized: You can only delete your own posts');
      }

      // Delete all comments
      await _supabase
          .from(_commentsTable)
          .delete()
          .eq('post_id', postId);

      // Delete media from storage
      final mediaUrls = List<String>.from(postResponse['media_urls'] ?? []);
      for (var mediaUrl in mediaUrls) {
        try {
          // Extract path from URL and delete
          final uri = Uri.parse(mediaUrl);
          final pathSegments = uri.pathSegments;
          if (pathSegments.isNotEmpty) {
            final storagePath = pathSegments.sublist(1).join('/');
            await _supabase.storage.from('posts').remove([storagePath]);
          }
        } catch (e) {
          debugPrint('Error deleting media: $e');
        }
      }

      // Delete the post
      await _supabase.from(_postsTable).delete().eq('id', postId);
    } catch (e) {
      debugPrint('Error deleting post: $e');
      rethrow;
    }
  }

  /// Report a post for moderation
  Future<void> reportPost(String postId, String reporterId, String reason) async {
    try {
      await _supabase.from('post_reports').insert({
        'post_id': postId,
        'reporter_id': reporterId,
        'reason': reason,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error reporting post: $e');
      rethrow;
    }
  }

  /// Get posts stream (all approved posts) - Real-time
  Stream<List<Post>> getPosts({String? filterTag, int limit = 20}) {
    var query = _supabase
        .from(_postsTable)
        .stream(primaryKey: ['id'])
        .eq('is_approved', true)
        .order('created_at', ascending: false)
        .limit(limit);

    return query.map((data) {
      final posts = data.map((item) => Post.fromSupabase(item)).toList();

      // Filter by tag if specified
      if (filterTag != null && filterTag.isNotEmpty) {
        return posts.where((post) => post.tags.contains(filterTag)).toList();
      }

      return posts;
    });
  }

  /// Get posts by user - Real-time
  Stream<List<Post>> getUserPosts(String userId) {
    return _supabase
        .from(_postsTable)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) {
          final posts = data.map((item) => Post.fromSupabase(item)).toList();
          return posts.where((post) => post.isApproved).toList();
        });
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
      debugPrint('Error getting post: $e');
      return null;
    }
  }

  /// Search posts by tag - Real-time
  Stream<List<Post>> searchPostsByTag(String tag) {
    return _supabase
        .from(_postsTable)
        .stream(primaryKey: ['id'])
        .eq('is_approved', true)
        .order('created_at', ascending: false)
        .map((data) {
          final posts = data.map((item) => Post.fromSupabase(item)).toList();
          return posts.where((post) => post.tags.contains(tag)).toList();
        });
  }

  /// Get posts with pagination (for infinite scroll)
  Future<List<Post>> getPostsPaginated({
    String? filterTag,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      var query = _supabase
          .from(_postsTable)
          .select()
          .eq('is_approved', true)
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      final response = await query;
      final posts = (response as List)
          .map((item) => Post.fromSupabase(item))
          .toList();

      // Filter by tag if specified
      if (filterTag != null && filterTag.isNotEmpty) {
        return posts.where((post) => post.tags.contains(filterTag)).toList();
      }

      return posts;
    } catch (e) {
      debugPrint('Error getting paginated posts: $e');
      rethrow;
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
          .eq('is_approved', true)
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      return (response as List)
          .map((item) => Post.fromSupabase(item))
          .toList();
    } catch (e) {
      debugPrint('Error getting paginated user posts: $e');
      rethrow;
    }
  }

  /// Get comments with pagination
  Future<List<PostComment>> getCommentsPaginated(
    String postId, {
    int page = 0,
    int pageSize = 50,
  }) async {
    try {
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
      debugPrint('Error getting paginated comments: $e');
      rethrow;
    }
  }

  /// Search posts by tag with pagination
  Future<List<Post>> searchPostsByTagPaginated(
    String tag, {
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      final response = await _supabase
          .from(_postsTable)
          .select()
          .eq('is_approved', true)
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      final posts = (response as List)
          .map((item) => Post.fromSupabase(item))
          .toList();

      return posts.where((post) => post.tags.contains(tag)).toList();
    } catch (e) {
      debugPrint('Error searching posts by tag: $e');
      rethrow;
    }
  }
}
