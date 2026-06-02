import 'package:flutter/material.dart';
// TODO: Migrate to Supabase
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

class CreateHomeworkScreen extends StatefulWidget {
  const CreateHomeworkScreen({Key? key}) : super(key: key);

  @override
  State<CreateHomeworkScreen> createState() => _CreateHomeworkScreenState();
}

class _CreateHomeworkScreenState extends State<CreateHomeworkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _topicController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _videoUrlController = TextEditingController();

  DateTime? _dueDate;
  File? _selectedImage;
  String? _imageUrl;
  final List<UserModel> _selectedStudents = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _topicController.dispose();
    _descriptionController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    try {
      // TODO: Migrate to Supabase
      // Replace Firebase Storage with Supabase Storage
      /*
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('homework_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putFile(_selectedImage!);
      return await storageRef.getDownloadURL();
      */

      // Placeholder - TODO: Implement Supabase storage upload
      print('Image upload pending Supabase migration');
      return null;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _selectStudents() async {
    final students = await _fetchStudents();

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Öğrenci Seç'),
        content: SizedBox(
          width: double.maxFinite,
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  final isSelected = _selectedStudents.any((s) => s.uid == student.uid);

                  return CheckboxListTile(
                    title: Text(student.displayName),
                    subtitle: Text(student.email),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setDialogState(() {
                        if (value == true) {
                          _selectedStudents.add(student);
                        } else {
                          _selectedStudents.removeWhere((s) => s.uid == student.uid);
                        }
                      });
                      setState(() {}); // Update parent state too
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  Future<List<UserModel>> _fetchStudents() async {
    try {
      // TODO: Migrate to Supabase
      // Replace Firestore with Supabase
      /*
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
      */

      // Placeholder - TODO: Implement with Supabase
      print('Fetch students pending Supabase migration');
      return [];
    } catch (e) {
      print('Error fetching students: $e');
      return [];
    }
  }

  Future<void> _createHomework() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen teslim tarihi seçin')),
      );
      return;
    }
    if (_selectedStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen en az bir öğrenci seçin')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload image if selected
      if (_selectedImage != null) {
        _imageUrl = await _uploadImage();
      }

      final authProvider = context.read<AuthProvider>();
      final teacherId = authProvider.currentUser?.uid;
      final teacherName = authProvider.currentUser?.displayName ?? 'Teacher';

      // TODO: Migrate to Supabase
      // Replace Firestore with Supabase
      /*
      // Create homework document
      await FirebaseFirestore.instance.collection('homeworks').add({
        'title': _titleController.text.trim(),
        'topic': _topicController.text.trim(),
        'description': _descriptionController.text.trim(),
        'imageUrl': _imageUrl ?? '',
        'videoUrl': _videoUrlController.text.trim().isNotEmpty
            ? _videoUrlController.text.trim()
            : null,
        'dueDate': Timestamp.fromDate(_dueDate!),
        'createdAt': FieldValue.serverTimestamp(),
        'teacherId': teacherId,
        'teacherName': teacherName,
        'studentIds': _selectedStudents.map((s) => s.uid).toList(),
        'status': 'active',
      });
      */

      // Placeholder - TODO: Implement with Supabase
      print('Create homework pending Supabase migration');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ödev oluşturma Supabase geçişini bekliyor!'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Ödev Oluştur'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Başlık',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Lütfen bir başlık girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Topic
                    TextFormField(
                      controller: _topicController,
                      decoration: const InputDecoration(
                        labelText: 'Konu',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.subject),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Lütfen bir konu girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Açıklama',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Lütfen bir açıklama girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // YouTube Video URL
                    TextFormField(
                      controller: _videoUrlController,
                      decoration: const InputDecoration(
                        labelText: 'YouTube Video Linki (İsteğe Bağlı)',
                        hintText: 'https://www.youtube.com/watch?v=...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.video_library),
                        helperText: 'Ödevle ilgili bir YouTube video linki ekleyebilirsiniz',
                      ),
                      keyboardType: TextInputType.url,
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          // Basic YouTube URL validation
                          if (!value.contains('youtube.com') && !value.contains('youtu.be')) {
                            return 'Geçerli bir YouTube linki girin';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Image picker
                    Card(
                      child: InkWell(
                        onTap: _pickImage,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              if (_selectedImage != null)
                                Image.file(
                                  _selectedImage!,
                                  height: 200,
                                  fit: BoxFit.cover,
                                )
                              else
                                const Icon(
                                  Icons.add_photo_alternate,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedImage != null
                                    ? 'Görseli Değiştir'
                                    : 'Görsel Ekle (İsteğe Bağlı)',
                                style: const TextStyle(color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Due date picker
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(
                          _dueDate == null
                              ? 'Teslim Tarihi Seç'
                              : 'Teslim Tarihi: ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 7)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() {
                              _dueDate = date;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Student selection
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.people),
                        title: Text(
                          _selectedStudents.isEmpty
                              ? 'Öğrenci Seç'
                              : '${_selectedStudents.length} öğrenci seçildi',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: _selectStudents,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Create button
                    ElevatedButton.icon(
                      onPressed: _createHomework,
                      icon: const Icon(Icons.check),
                      label: const Text('Ödevi Oluştur'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
