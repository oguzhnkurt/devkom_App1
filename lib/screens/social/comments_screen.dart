import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../services/feed_service.dart';
import '../../widgets/skeleton_loader.dart';

class CommentsScreen extends StatefulWidget {
  final Post post;
  final UserModel? currentUser;

  const CommentsScreen({
    Key? key,
    required this.post,
    required this.currentUser,
  }) : super(key: key);

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final FeedService _feedService = FeedService();
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendComment() async {
    if (_commentController.text.trim().isEmpty) return;
    if (widget.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yorum yapmak için giriş yapmalısınız')),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    final comment = _commentController.text.trim();
    _commentController.clear();

    try {
      await _feedService.addComment(
        postId: widget.post.id,
        userId: widget.currentUser!.uid,
        content: comment,
      );

      // Scroll to bottom after adding comment
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      print('❌ Comment error: $e');
      print('📋 User data - uid: ${widget.currentUser?.uid}, name: ${widget.currentUser?.displayName}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yorum gönderilirken hata oluştu: $e'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yorumlar'),
      ),
      body: Column(
        children: [
          // Comments list
          Expanded(
            child: StreamBuilder<List<PostComment>>(
              stream: _feedService.getCommentsStream(widget.post.id).map((list) => list.cast<PostComment>()),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Hata: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) => const CommentSkeleton(),
                  );
                }

                final comments = snapshot.data ?? [];

                if (comments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz yorum yok',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'İlk yorumu siz yapın!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return CommentCard(
                      comment: comment,
                      currentUser: widget.currentUser,
                      onDelete: () async {
                        try {
                          await _feedService.deleteComment(comment.id);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Yorum silindi')),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Hata: $e')),
                            );
                          }
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Comment input
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 8,
            ),
            child: SafeArea(
              child: Row(
                children: [
                  if (widget.currentUser?.profilePictureUrl != null)
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: CachedNetworkImageProvider(
                        widget.currentUser!.profilePictureUrl!,
                      ),
                    )
                  else
                    CircleAvatar(
                      radius: 18,
                      child: widget.currentUser != null
                          ? Text(
                              widget.currentUser!.name?[0].toUpperCase() ?? 'U',
                              style: const TextStyle(fontSize: 16),
                            )
                          : const Icon(Icons.person, size: 20),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Yorum yaz...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    onPressed: _isSending ? null : _sendComment,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CommentCard extends StatelessWidget {
  final PostComment comment;
  final UserModel? currentUser;
  final VoidCallback onDelete;

  const CommentCard({
    Key? key,
    required this.comment,
    required this.currentUser,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isOwnComment = currentUser?.id == comment.userId;

    return ListTile(
      leading: CircleAvatar(
        radius: 18,
        backgroundImage: comment.userPhotoUrl != null
            ? CachedNetworkImageProvider(comment.userPhotoUrl!)
            : null,
        child: comment.userPhotoUrl == null
            ? Text(
                comment.userName[0].toUpperCase(),
                style: const TextStyle(fontSize: 14),
              )
            : null,
      ),
      title: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: '${comment.userName} ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: comment.comment),
          ],
        ),
      ),
      subtitle: Text(
        timeago.format(comment.createdAt, locale: 'tr'),
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: isOwnComment
          ? IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.grey),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Yorumu Sil'),
                    content: const Text('Bu yorumu silmek istediğinize emin misiniz?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('İptal'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onDelete();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Sil'),
                      ),
                    ],
                  ),
                );
              },
            )
          : null,
    );
  }
}

class CommentSkeleton extends StatelessWidget {
  const CommentSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircularSkeleton(size: 36),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(
            width: 120,
            height: 14,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 4),
          SkeletonLoader(
            width: double.infinity,
            height: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
