import 'package:flutter/foundation.dart';
import '../core/service_locator.dart';

/// Messaging Service Stub - Redirects to Supabase
class MessagingService {
  Future<void> sendMessage(dynamic message) async {
    debugPrint('🔄 MessagingService: Redirecting to MessagingServiceSupabase');
    await messagingService.sendMessage(message);
  }

  Stream<List<dynamic>> getConversation(String userId1, String userId2) {
    debugPrint('🔄 MessagingService: Redirecting to MessagingServiceSupabase');
    return messagingService.getConversation(userId1, userId2);
  }

  Future<void> markConversationAsRead(String userId, String otherUserId) async {
    debugPrint('⚠️ MessagingService.markConversationAsRead: Supabase migration pending');
  }

  Future<void> deleteMessage(String messageId) async {
    debugPrint('⚠️ MessagingService.deleteMessage: Supabase migration pending');
  }

  Future<void> markAsRead(String messageId) async {
    debugPrint('🔄 MessagingService: Redirecting to MessagingServiceSupabase');
    await messagingService.markAsRead(messageId);
  }
}
