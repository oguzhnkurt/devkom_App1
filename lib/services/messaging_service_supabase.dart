import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message_model.dart';
import '../main.dart';

class MessagingServiceSupabase {
  final SupabaseClient _supabase = supabase;

  // Send a message
  Future<void> sendMessage(MessageModel message) async {
    try {
      final data = message.toSupabaseMap();
      // Remove id as it will be auto-generated
      data.remove('id');

      await _supabase.from('messages').insert(data);
      debugPrint('✅ Message sent successfully');
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
      rethrow;
    }
  }

  // Get messages between two users (realtime)
  Stream<List<MessageModel>> getConversation(String userId1, String userId2) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .map((data) {
          // Filter to only include messages between the two users
          final filteredMessages = data.where((msg) {
            final senderId = msg['sender_id'];
            final receiverId = msg['receiver_id'];
            return (senderId == userId1 && receiverId == userId2) ||
                (senderId == userId2 && receiverId == userId1);
          }).toList();

          return filteredMessages
              .map((msg) => MessageModel.fromSupabase(msg))
              .toList();
        });
  }

  // Get all conversations for a user
  Stream<List<ConversationModel>> getUserConversations(String userId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) {
          // Filter messages for this user
          final userMessages = data.where((msg) {
            return msg['sender_id'] == userId || msg['receiver_id'] == userId;
          }).toList();

          final messages = userMessages.map((msg) => MessageModel.fromSupabase(msg)).toList();

          // Group by conversation partner
          final Map<String, List<MessageModel>> conversations = {};
          for (final msg in messages) {
            final partnerId = msg.senderId == userId ? msg.receiverId : msg.senderId;
            conversations.putIfAbsent(partnerId, () => []);
            conversations[partnerId]!.add(msg);
          }

          // Create conversation models
          final List<ConversationModel> result = [];
          conversations.forEach((partnerId, msgs) {
            msgs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            final latestMsg = msgs.first;
            final unreadCount = msgs.where((m) => !m.isRead && m.receiverId == userId).length;

            result.add(ConversationModel(
              userId: partnerId,
              userName: latestMsg.senderId == userId ? latestMsg.receiverName : latestMsg.senderName,
              userRole: latestMsg.senderId == userId ? 'other' : latestMsg.senderRole,
              lastMessage: latestMsg.content,
              lastMessageTime: latestMsg.createdAt,
              unreadCount: unreadCount,
            ));
          });

          result.sort((a, b) => (b.lastMessageTime ?? DateTime(2000))
              .compareTo(a.lastMessageTime ?? DateTime(2000)));

          return result;
        });
  }

  // Mark message as read
  Future<void> markAsRead(String messageId) async {
    try {
      await _supabase
          .from('messages')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('id', messageId);
      debugPrint('✅ Message marked as read');
    } catch (e) {
      debugPrint('❌ Error marking message as read: $e');
      rethrow;
    }
  }

  // Mark all messages from a user as read
  Future<void> markConversationAsRead(String currentUserId, String otherUserId) async {
    try {
      await _supabase
          .from('messages')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('sender_id', otherUserId)
          .eq('receiver_id', currentUserId)
          .eq('is_read', false);
      debugPrint('✅ Conversation marked as read');
    } catch (e) {
      debugPrint('❌ Error marking conversation as read: $e');
      rethrow;
    }
  }

  // Get unread message count
  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select('id')
          .eq('receiver_id', userId)
          .eq('is_read', false);

      return (response as List).length;
    } catch (e) {
      debugPrint('❌ Error getting unread count: $e');
      return 0;
    }
  }

  // Delete a message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _supabase
          .from('messages')
          .delete()
          .eq('id', messageId);
      debugPrint('✅ Message deleted');
    } catch (e) {
      debugPrint('❌ Error deleting message: $e');
      rethrow;
    }
  }

  /// Get conversation messages with pagination
  Future<List<MessageModel>> getConversationPaginated(
    String userId1,
    String userId2, {
    int page = 0,
    int pageSize = 50,
  }) async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      // Filter to only include messages between the two users
      final filteredMessages = (response as List).where((msg) {
        final senderId = msg['sender_id'];
        final receiverId = msg['receiver_id'];
        return (senderId == userId1 && receiverId == userId2) ||
            (senderId == userId2 && receiverId == userId1);
      }).toList();

      return filteredMessages
          .map((msg) => MessageModel.fromSupabase(msg))
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting paginated conversation: $e');
      rethrow;
    }
  }

  /// Get all user conversations with pagination
  Future<List<ConversationModel>> getUserConversationsPaginated(
    String userId, {
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      final messages = (response as List)
          .map((msg) => MessageModel.fromSupabase(msg))
          .toList();

      // Group by conversation partner
      final Map<String, List<MessageModel>> conversations = {};
      for (final msg in messages) {
        final partnerId = msg.senderId == userId ? msg.receiverId : msg.senderId;
        conversations.putIfAbsent(partnerId, () => []);
        conversations[partnerId]!.add(msg);
      }

      // Create conversation models
      final List<ConversationModel> result = [];
      conversations.forEach((partnerId, msgs) {
        msgs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final latestMsg = msgs.first;
        final unreadCount = msgs.where((m) => !m.isRead && m.receiverId == userId).length;

        result.add(ConversationModel(
          userId: partnerId,
          userName: latestMsg.senderId == userId ? latestMsg.receiverName : latestMsg.senderName,
          userRole: latestMsg.senderId == userId ? 'other' : latestMsg.senderRole,
          lastMessage: latestMsg.content,
          lastMessageTime: latestMsg.createdAt,
          unreadCount: unreadCount,
        ));
      });

      result.sort((a, b) => (b.lastMessageTime ?? DateTime(2000))
          .compareTo(a.lastMessageTime ?? DateTime(2000)));

      return result;
    } catch (e) {
      debugPrint('❌ Error getting paginated conversations: $e');
      rethrow;
    }
  }

  // ========== TYPING INDICATOR ==========

  /// Set typing status for current user in a conversation
  /// Uses Supabase realtime for instant updates
  Future<void> setTypingStatus(String conversationId, String userId, bool isTyping) async {
    try {
      final channelName = 'typing:$conversationId';

      if (isTyping) {
        // Broadcast typing event
        await _supabase.channel(channelName).sendBroadcastMessage(
          event: 'typing',
          payload: {
            'user_id': userId,
            'is_typing': true,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      } else {
        // Broadcast stop typing event
        await _supabase.channel(channelName).sendBroadcastMessage(
          event: 'typing',
          payload: {
            'user_id': userId,
            'is_typing': false,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      }

      debugPrint('✅ Typing status set: $isTyping for user $userId in $conversationId');
    } catch (e) {
      debugPrint('❌ Error setting typing status: $e');
      // Don't rethrow - typing indicator is not critical
    }
  }

  /// Watch typing status for a conversation
  /// Returns a stream of user IDs who are currently typing
  Stream<Map<String, bool>> watchTypingStatus(String conversationId, String currentUserId) {
    final channelName = 'typing:$conversationId';
    final typingUsers = <String, bool>{};

    final controller = StreamController<Map<String, bool>>.broadcast();

    final channel = _supabase.channel(channelName);

    channel.onBroadcast(
      event: 'typing',
      callback: (payload) {
        try {
          final userId = payload['user_id'] as String?;
          final isTyping = payload['is_typing'] as bool? ?? false;

          // Ignore own typing events
          if (userId != null && userId != currentUserId) {
            if (isTyping) {
              typingUsers[userId] = true;
            } else {
              typingUsers.remove(userId);
            }

            controller.add(Map.from(typingUsers));
          }
        } catch (e) {
          debugPrint('❌ Error processing typing event: $e');
        }
      },
    );

    channel.subscribe((status, [error]) {
      if (status == RealtimeSubscribeStatus.subscribed) {
        debugPrint('✅ Subscribed to typing indicator for $conversationId');
      } else if (status == RealtimeSubscribeStatus.channelError) {
        debugPrint('❌ Error subscribing to typing indicator: $error');
      }
    });

    // Cleanup when stream is cancelled
    controller.onCancel = () {
      channel.unsubscribe();
      debugPrint('🔌 Unsubscribed from typing indicator for $conversationId');
    };

    return controller.stream;
  }

  /// Helper method to get conversation ID from two user IDs
  /// Always returns IDs in same order for consistency
  String getConversationId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }
}
