import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../theme.dart';

/// Enhanced Chat Screen with voice messages and file attachments
/// Inspired by modern messaging apps like Slack
class EnhancedChatScreen extends StatefulWidget {
  final String chatTitle;
  final String? subtitle;

  const EnhancedChatScreen({
    super.key,
    required this.chatTitle,
    this.subtitle,
  });

  @override
  State<EnhancedChatScreen> createState() => _EnhancedChatScreenState();
}

class _EnhancedChatScreenState extends State<EnhancedChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isRecording = false;
  double _recordingProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadSampleMessages();
  }

  void _loadSampleMessages() {
    setState(() {
      _messages.addAll([
        ChatMessage(
          text: 'Hey Arthur, just sent over the new logo brief 👋',
          isSent: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          senderName: 'Maya',
        ),
        ChatMessage(
          text: null,
          isSent: true,
          timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
          attachment: MessageAttachment(
            fileName: 'logo-brief.pdf',
            fileSize: '2.5 MB',
            fileType: 'pdf',
          ),
          replyTo: 'Hey Arthur, just sent over the new logo brief 👋',
        ),
        ChatMessage(
          text: 'Oooh nice! Can we use the for the tagline?',
          isSent: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
          senderName: 'Maya',
        ),
        ChatMessage(
          text: 'Sure, give me 10 min 👍',
          isSent: true,
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
        ChatMessage(
          text: null,
          isSent: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
          senderName: 'Maya',
          voiceMessage: VoiceMessage(
            duration: '0:42',
            isPlaying: false,
          ),
        ),
      ]);
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: _messageController.text.trim(),
        isSent: true,
        timestamp: DateTime.now(),
      ));
    });

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'png'],
      );

      if (result != null) {
        String fileName = result.files.single.name;
        int? fileSize = result.files.single.size;
        String fileSizeStr = '${(fileSize / 1024 / 1024).toStringAsFixed(1)} MB';

        setState(() {
          _messages.add(ChatMessage(
            text: null,
            isSent: true,
            timestamp: DateTime.now(),
            attachment: MessageAttachment(
              fileName: fileName,
              fileSize: fileSizeStr,
              fileType: fileName.split('.').last,
            ),
          ));
        });
        _scrollToBottom();
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
      if (_isRecording) {
        _startRecording();
      } else {
        _stopRecording();
      }
    });
  }

  void _startRecording() {
    // Simulated recording progress
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_isRecording && _recordingProgress < 1.0) {
        setState(() {
          _recordingProgress += 0.02;
        });
        _startRecording();
      }
    });
  }

  void _stopRecording() {
    if (_recordingProgress > 0.1) {
      // Add voice message
      setState(() {
        _messages.add(ChatMessage(
          text: null,
          isSent: true,
          timestamp: DateTime.now(),
          voiceMessage: VoiceMessage(
            duration: '0:${(_recordingProgress * 60).toInt().toString().padLeft(2, '0')}',
            isPlaying: false,
          ),
        ));
      });
      _scrollToBottom();
    }
    _recordingProgress = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chatTitle,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.subtitle != null)
                  Text(
                    widget.subtitle!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Today indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          // Input area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isSent) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue[100],
              child: Text(
                message.senderName?.substring(0, 1) ?? 'M',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isSent
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (message.replyTo != null) _buildReplyIndicator(message.replyTo!),
                if (message.text != null) _buildTextBubble(message),
                if (message.attachment != null)
                  _buildAttachmentBubble(message.attachment!),
                if (message.voiceMessage != null)
                  _buildVoiceMessageBubble(message.voiceMessage!, message.isSent),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('HH:mm a').format(message.timestamp).toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (message.isSent) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.done_all,
                        size: 14,
                        color: Colors.blue[600],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (message.isSent) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildReplyIndicator(String replyText) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: AppTheme.primaryBlue, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Replied to:',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            replyText,
            style: const TextStyle(fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTextBubble(ChatMessage message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: message.isSent ? AppTheme.primaryBlue : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message.text!,
        style: TextStyle(
          fontSize: 14,
          color: message.isSent ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildAttachmentBubble(MessageAttachment attachment) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getFileIcon(attachment.fileType),
              color: Colors.red,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.fileName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  attachment.fileSize,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceMessageBubble(VoiceMessage voiceMsg, bool isSent) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSent ? AppTheme.primaryBlue : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              // Toggle play/pause
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSent ? Colors.white : AppTheme.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                voiceMsg.isPlaying ? Icons.pause : Icons.play_arrow,
                color: isSent ? AppTheme.primaryBlue : Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                // Waveform simulation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    20,
                    (index) => Container(
                      width: 2,
                      height: (index % 4 + 1) * 4.0,
                      decoration: BoxDecoration(
                        color: isSent ? Colors.white70 : Colors.grey[400],
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      voiceMsg.duration,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSent ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                    Text(
                      '1x',
                      style: TextStyle(
                        fontSize: 11,
                        color: isSent ? Colors.white70 : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    if (_isRecording) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.mic, color: Colors.red, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Voice Message Recording...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: _recordingProgress,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.stop_circle, color: Colors.red, size: 32),
              onPressed: _toggleRecording,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.attach_file, color: Colors.grey[700]),
            onPressed: _pickFile,
          ),
          IconButton(
            icon: Icon(Icons.image_outlined, color: Colors.grey[700]),
            onPressed: () {
              // Pick image
            },
          ),
          IconButton(
            icon: Icon(Icons.sentiment_satisfied_alt, color: Colors.grey[700]),
            onPressed: () {
              // Show emoji picker
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Message ${widget.chatTitle}...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[500]),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          IconButton(
            icon: Icon(Icons.mic_none, color: Colors.grey[700]),
            onPressed: _toggleRecording,
          ),
          Container(
            decoration: const BoxDecoration(
              color: AppTheme.primaryBlue,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// Models
class ChatMessage {
  final String? text;
  final bool isSent;
  final DateTime timestamp;
  final String? senderName;
  final MessageAttachment? attachment;
  final VoiceMessage? voiceMessage;
  final String? replyTo;

  ChatMessage({
    this.text,
    required this.isSent,
    required this.timestamp,
    this.senderName,
    this.attachment,
    this.voiceMessage,
    this.replyTo,
  });
}

class MessageAttachment {
  final String fileName;
  final String fileSize;
  final String fileType;

  MessageAttachment({
    required this.fileName,
    required this.fileSize,
    required this.fileType,
  });
}

class VoiceMessage {
  final String duration;
  final bool isPlaying;

  VoiceMessage({
    required this.duration,
    required this.isPlaying,
  });
}
