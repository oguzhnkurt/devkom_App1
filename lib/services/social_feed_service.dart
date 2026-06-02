import 'dart:io';
import 'package:flutter/foundation.dart';

/// Social Feed Service Stub - Temporary stubs during Firebase to Supabase migration
class SocialFeedService {
  Future<List<dynamic>> getFeed({int page = 0, int pageSize = 20}) async {
    debugPrint('⚠️  SocialFeedService.getFeed - stub');
    return [];
  }

  Future<Map<String, dynamic>> checkDailyPostLimit(String userId) async {
    debugPrint('⚠️ SocialFeedService.checkDailyPostLimit: Supabase migration pending');
    return {'canPost': true, 'postsToday': 0, 'limit': 10};
  }

  Future<void> createPost({
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
    debugPrint('⚠️ SocialFeedService.createPost: Supabase migration pending');
  }

  Future<dynamic> getPost(String postId) async {
    debugPrint('⚠️ SocialFeedService.getPost: Supabase migration pending');
    return null;
  }

  Future<void> likePost(String postId, String userId) async {
    debugPrint('⚠️  SocialFeedService.likePost - stub');
  }

  Future<void> addComment({
    required String postId,
    required String userId,
    required String content,
  }) async {
    debugPrint('⚠️ SocialFeedService.addComment: Supabase migration pending');
  }

  Stream<List<dynamic>> getComments(String postId) {
    debugPrint('⚠️ SocialFeedService.getComments: Supabase migration pending');
    return Stream.value([]);
  }

  Stream<List<dynamic>> getPosts() {
    debugPrint('⚠️  SocialFeedService.getPosts - stub');
    return Stream.value([]);
  }

  Future<void> unlikePost(String postId, String userId) async {
    debugPrint('⚠️  SocialFeedService.unlikePost - stub');
  }

  Future<void> deletePost(String postId, String userId) async {
    debugPrint('⚠️  SocialFeedService.deletePost - stub');
  }
}
