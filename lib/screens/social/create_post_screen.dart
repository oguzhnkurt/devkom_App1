import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/feed_service.dart';
import '../../models/user_model.dart';
import '../../constants/post_limits.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final FeedService _feedService = FeedService();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImage;
  bool _isUploading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: PostLimits.maxImageWidth.toDouble(),
        maxHeight: PostLimits.maxImageHeight.toDouble(),
        imageQuality: PostLimits.imageQuality,
      );

      if (image != null) {
        final file = File(image.path);
        final fileSize = await file.length();

        // Boyut kontrolü
        if (PostLimits.isImageSizeLimitExceeded(fileSize)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(PostLimits.getImageSizeLimitMessage()),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedImage = file;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Görsel seçilirken hata: $e')),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: PostLimits.maxImageWidth.toDouble(),
        maxHeight: PostLimits.maxImageHeight.toDouble(),
        imageQuality: PostLimits.imageQuality,
      );

      if (image != null) {
        final file = File(image.path);
        final fileSize = await file.length();

        // Boyut kontrolü
        if (PostLimits.isImageSizeLimitExceeded(fileSize)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(PostLimits.getImageSizeLimitMessage()),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedImage = file;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fotoğraf çekilirken hata: $e')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Galeriden Seç'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('Fotoğraf Çek'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            if (_selectedImage != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Görseli Kaldır'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedImage = null;
                  });
                },
              ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('İptal'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createPost() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kullanıcı girişi yapılmamış')),
      );
      return;
    }

    // Check daily post limit
    final userRole = currentUser.role.toString().split('.').last;
    final canPost = await _feedService.canCreatePost(currentUser.id, userRole);

    if (!canPost) {
      final limit = PostLimits.getMaxPostsPerDayForRole(userRole);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(PostLimits.getDailyLimitExceededMessage(limit)),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    final description = _descriptionController.text.trim();

    if (description.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir açıklama yazın veya görsel seçin'),
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      await _feedService.createPost(
        userId: currentUser.id,
        userName: currentUser.name,
        userPhotoUrl: currentUser.profilePictureUrl,
        userRole: currentUser.role.toString().split('.').last,
        description: description,
        imageFile: _selectedImage,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paylaşım başarıyla oluşturuldu!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Paylaşım oluşturulurken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Paylaşım'),
        actions: [
          if (_isUploading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _createPost,
              child: const Text(
                'Paylaş',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User info header
            ListTile(
              leading: CircleAvatar(
                backgroundImage: currentUser?.profilePictureUrl != null
                    ? NetworkImage(currentUser!.profilePictureUrl!)
                    : null,
                child: currentUser?.profilePictureUrl == null
                    ? Text(
                        currentUser?.name[0].toUpperCase() ?? 'U',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              title: Text(
                currentUser?.name ?? 'Kullanıcı',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                _getRoleText(currentUser?.role),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),

            const Divider(height: 1),

            // Description input
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _descriptionController,
                    maxLines: null,
                    minLines: 5,
                    maxLength: PostLimits.maxDescriptionLength,
                    decoration: const InputDecoration(
                      hintText: 'Ne düşünüyorsunuz?',
                      border: InputBorder.none,
                      counterText: '',
                    ),
                    style: const TextStyle(fontSize: 16),
                    enabled: !_isUploading,
                    onChanged: (value) {
                      setState(() {}); // Karakter sayacını güncellemek için
                    },
                  ),
                  // Karakter sayacı
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${_descriptionController.text.length}/${PostLimits.maxDescriptionLength}',
                      style: TextStyle(
                        fontSize: 12,
                        color: PostLimits.isDescriptionLimitExceeded(_descriptionController.text)
                            ? Colors.red
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Selected image preview
            if (_selectedImage != null)
              Stack(
                children: [
                  Image.file(
                    _selectedImage!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: _isUploading
                            ? null
                            : () {
                                setState(() {
                                  _selectedImage = null;
                                });
                              },
                      ),
                    ),
                  ),
                ],
              ),

            // Add photo button
            if (_selectedImage == null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: InkWell(
                  onTap: _isUploading ? null : _showImageSourceDialog,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Fotoğraf Ekle',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: OutlinedButton.icon(
                  onPressed: _isUploading ? null : _showImageSourceDialog,
                  icon: const Icon(Icons.edit),
                  label: const Text('Görseli Değiştir'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Tips
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Paylaşım İpuçları',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Paylaşımınız tüm kullanıcılar tarafından görülecektir\n'
                      '• Uygun olmayan içerik paylaşmayınız\n'
                      '• Öğrencilerin başarılarını paylaşın\n'
                      '• Eğitim içerikleri ve etkinlikler hakkında bilgi verin',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue[900],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRoleText(UserRole? role) {
    switch (role) {
      case UserRole.admin:
        return '👑 Admin';
      case UserRole.teacher:
        return '👨‍🏫 Öğretmen';
      case UserRole.parent:
        return '👨‍👩‍👧 Veli';
      case UserRole.student:
        return '🎓 Öğrenci';
      default:
        return 'Kullanıcı';
    }
  }
}
