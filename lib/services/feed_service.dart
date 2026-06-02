import 'dart:io';
import 'package:flutter/foundation.dart';

/// Feed Service Stub - Temporary stubs during Firebase to Supabase migration
class FeedService {
  Future<List<dynamic>> getFeed({int page = 0, int pageSize = 20}) async {
    debugPrint('⚠️  FeedService.getFeed - stub');
    return [];
  }

  Future<bool> canCreatePost(String userId, String userRole) async {
    debugPrint('⚠️ FeedService.canCreatePost: Supabase migration pending');
    return false;
  }

  Future<void> createPost({
    required String userId,
    required String userName,
    String? userPhotoUrl,
    String? userRole,
    required String description,
    File? imageFile,
  }) async {
    debugPrint('⚠️ FeedService.createPost: Supabase migration pending');
  }

  Future<void> likePost(String postId, String userId) async {
    debugPrint('⚠️  FeedService.likePost - stub');
  }

  Future<void> commentOnPost(String postId, String userId, String comment) async {
    debugPrint('⚠️  FeedService.commentOnPost - stub');
  }

  Stream<List<dynamic>> getPostsStream({int limit = 50}) {
    debugPrint('⚠️  FeedService.getPostsStream - stub');
    return Stream.value([]);
  }

  Future<void> toggleLike(String postId, String userId) async {
    debugPrint('⚠️  FeedService.toggleLike - stub');
  }

  Future<void> updatePost(String postId, Map<String, dynamic> data) async {
    debugPrint('⚠️  FeedService.updatePost - stub');
  }

  Future<void> deletePost(String postId) async {
    debugPrint('⚠️  FeedService.deletePost - stub');
  }

  Future<void> addComment({
    required String postId,
    required String userId,
    required String content,
  }) async {
    debugPrint('⚠️ FeedService.addComment: Supabase migration pending');
  }

  Stream<List<dynamic>> getCommentsStream(String postId) {
    debugPrint('⚠️ FeedService.getCommentsStream: Supabase migration pending');
    return Stream.value([]);
  }

  Future<void> deleteComment(String commentId) async {
    debugPrint('⚠️ FeedService.deleteComment: Supabase migration pending');
  }
}
