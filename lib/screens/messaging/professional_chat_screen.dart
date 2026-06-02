import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../models/message_model.dart';
import '../../services/messaging_service.dart';
import '../../services/storage_service.dart';
import '../../services/voice_recording_service.dart';
import '../../theme.dart';

/// Professional Chat Screen - inspired by modern messaging apps
/// Supports text, voice, images, and file attachments
class ProfessionalChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String receiverRole;

  const ProfessionalChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
    required this.receiverRole,
  });

  @override
  State<ProfessionalChatScreen> createState() => _ProfessionalChatScreenState();
}

class _ProfessionalChatScreenState extends State<ProfessionalChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final MessagingService _messagingService = MessagingService();
  final StorageService _storageService = StorageService();
  final VoiceRecordingService _voiceService = VoiceRecordingService();
  final ImagePicker _imagePicker = ImagePicker();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRecording = false;
  int _recordingDuration = 0;
  String? _playingMessageId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markMessagesAsRead();
    });
  }

  void _markMessagesAsRead() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    if (currentUser != null) {
      _messagingService.markConversationAsRead(currentUser.id, widget.receiverId);
    }
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

  Future<void> _sendTextMessage() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser == null || _messageController.text.trim().isEmpty) {
      return;
    }

    final message = MessageModel(
      id: '',
      senderId: currentUser.id,
      senderName: currentUser.name,
      senderRole: currentUser.role.name,
      receiverId: widget.receiverId,
      receiverName: widget.receiverName,
      content: _messageController.text.trim(),
      type: MessageType.text,
      createdAt: DateTime.now(),
    );

    await _messagingService.sendMessage(message);
    _messageController.clear();
    _scrollToBottom();
  }

  Future<void> _sendImageMessage(ImageSource source) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return;

    try {
      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) return;

      // Show loading
      _showLoadingDialog('Resim yükleniyor...');

      final imageUrl = await _storageService.uploadImage(
        filePath: image.path,
        folder: currentUser.id,
      );

      // Get file size
      final file = File(image.path);
      final fileSize = await file.length();

      Navigator.pop(context); // Close loading dialog

      // Send message
      final message = MessageModel(
        id: '',
        senderId: currentUser.id,
        senderName: currentUser.name,
        senderRole: currentUser.role.name,
        receiverId: widget.receiverId,
        receiverName: widget.receiverName,
        content: imageUrl,
        type: MessageType.image,
        createdAt: DateTime.now(),
        fileName: image.name,
        fileSize: await _storageService.getFileSizeString(fileSize),
      );

      await _messagingService.sendMessage(message);
      _scrollToBottom();
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorDialog('Resim gönderilemedi: $e');
    }
  }

  Future<void> _sendFileMessage() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx'],
      );

      if (result == null) return;

      _showLoadingDialog('Dosya yükleniyor...');

      final file = File(result.files.single.path!);
      final fileUrl = await _storageService.uploadFile(file.path, currentUser.id);

      Navigator.pop(context); // Close loading dialog

      final message = MessageModel(
        id: '',
        senderId: currentUser.id,
        senderName: currentUser.name,
        senderRole: currentUser.role.name,
        receiverId: widget.receiverId,
        receiverName: widget.receiverName,
        content: fileUrl ?? '',
        type: MessageType.file,
        createdAt: DateTime.now(),
        fileName: result.files.single.name,
        fileSize: await _storageService.getFileSizeString(result.files.single.size),
      );

      await _messagingService.sendMessage(message);
      _scrollToBottom();
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog('Dosya gönderilemedi: $e');
    }
  }

  Future<void> _toggleVoiceRecording() async {
    if (_isRecording) {
      // Stop recording
      final path = await _voiceService.stopRecording();
      if (path != null) {
        await _sendVoiceMessage(path);
      }
      setState(() {
        _isRecording = false;
        _recordingDuration = 0;
      });
    } else {
      // Start recording
      final started = await _voiceService.startRecording();
      if (started) {
        setState(() => _isRecording = true);
        _updateRecordingDuration();
      } else {
        _showErrorDialog('Mikrofon izni gerekli');
      }
    }
  }

  void _updateRecordingDuration() {
    if (!_isRecording) return;
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _isRecording) {
        setState(() {
          _recordingDuration = _voiceService.recordingDuration;
        });
        _updateRecordingDuration();
      }
    });
  }

  Future<void> _sendVoiceMessage(String filePath) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return;

    try {
      _showLoadingDialog('Ses kaydı gönderiliyor...');

      final voiceUrl = await _storageService.uploadVoice(filePath, currentUser.id);

      Navigator.pop(context);

      final message = MessageModel(
        id: '',
        senderId: currentUser.id,
        senderName: currentUser.name,
        senderRole: currentUser.role.name,
        receiverId: widget.receiverId,
        receiverName: widget.receiverName,
        content: voiceUrl ?? '',
        type: MessageType.voice,
        createdAt: DateTime.now(),
        voiceDuration: _recordingDuration,
      );

      await _messagingService.sendMessage(message);
      _scrollToBottom();
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog('Ses kaydı gönderilemedi: $e');
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hata'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.receiverName)),
        body: const Center(child: Text('Lütfen giriş yapın')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTodayIndicator(),
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _messagingService.getConversation(currentUser.id, widget.receiverId).map((list) => list.cast<MessageModel>()),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;

                if (messages.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageBubble(messages[index], currentUser.id);
                  },
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  // UI Components will be continued in next part...
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
                backgroundColor: AppTheme.primaryBlue.withOpacity(0.2),
                child: Text(
                  widget.receiverName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiverName,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.receiverRole == 'teacher' ? 'Öğretmen' : 'Yönetici',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: const [],
    );
  }

  Widget _buildTodayIndicator() {
    return Container(
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
    );
  }

  Widget _buildEmptyState() {
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
            'Henüz mesaj yok',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İlk mesajı gönderin!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, String currentUserId) {
    final isSent = message.senderId == currentUserId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isSent) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue[100],
              child: Text(
                message.senderName.substring(0, 1),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isSent)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      message.senderName,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                _buildMessageContent(message, isSent),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('HH:mm a').format(message.createdAt).toUpperCase(),
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    if (isSent) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.isRead ? Icons.done_all : Icons.done,
                        size: 14,
                        color: message.isRead ? Colors.blue[600] : Colors.grey,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(MessageModel message, bool isSent) {
    switch (message.type) {
      case MessageType.text:
        return _buildTextBubble(message.content, isSent);
      case MessageType.image:
        return _buildImageBubble(message.content, isSent);
      case MessageType.file:
        return _buildFileBubble(message, isSent);
      case MessageType.voice:
        return _buildVoiceBubble(message, isSent);
    }
  }

  Widget _buildTextBubble(String text, bool isSent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isSent ? AppTheme.primaryBlue : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: isSent ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildImageBubble(String imageUrl, bool isSent) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: 200,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 200,
          height: 150,
          color: Colors.grey[300],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          width: 200,
          height: 150,
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        ),
      ),
    );
  }

  Widget _buildFileBubble(MessageModel message, bool isSent) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSent ? AppTheme.primaryBlue.withOpacity(0.1) : Colors.grey[200],
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
            child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.fileName ?? 'file.pdf',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  message.fileSize ?? '0 KB',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceBubble(MessageModel message, bool isSent) {
    final isPlaying = _playingMessageId == message.id;

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
            onTap: () => _playVoice(message),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSent ? Colors.white : AppTheme.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: isSent ? AppTheme.primaryBlue : Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                Row(
                  children: List.generate(
                    20,
                    (index) => Container(
                      width: 2,
                      height: (index % 4 + 1) * 4.0,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
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
                      '0:${(message.voiceDuration ?? 0).toString().padLeft(2, '0')}',
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

  void _playVoice(MessageModel message) async {
    if (_playingMessageId == message.id) {
      await _audioPlayer.pause();
      setState(() => _playingMessageId = null);
    } else {
      await _audioPlayer.play(UrlSource(message.content));
      setState(() => _playingMessageId = message.id);
    }
  }

  Widget _buildInputArea() {
    if (_isRecording) {
      return _buildRecordingArea();
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
            icon: const Icon(Icons.attach_file, color: Colors.grey),
            onPressed: _sendFileMessage,
          ),
          IconButton(
            icon: const Icon(Icons.image_outlined, color: Colors.grey),
            onPressed: () => _showImageSourceDialog(),
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Message ${widget.receiverName}...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[500]),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.mic_none, color: Colors.grey),
            onPressed: _toggleVoiceRecording,
          ),
          Container(
            decoration: const BoxDecoration(
              color: AppTheme.primaryBlue,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _sendTextMessage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingArea() {
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
                Text(
                  'Ses kaydediliyor... ${_recordingDuration}s',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.stop_circle, color: Colors.red, size: 32),
            onPressed: _toggleVoiceRecording,
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resim Seç'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _sendImageMessage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _sendImageMessage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _voiceService.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}
