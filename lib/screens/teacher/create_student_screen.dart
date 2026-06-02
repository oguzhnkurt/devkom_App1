import 'package:flutter/material.dart';
// TODO: Migrate to Supabase
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../models/homework_model.dart' show AgeGroup;

class CreateStudentScreen extends StatefulWidget {
  const CreateStudentScreen({Key? key}) : super(key: key);

  @override
  State<CreateStudentScreen> createState() => _CreateStudentScreenState();
}

class _CreateStudentScreenState extends State<CreateStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  AgeGroup? _selectedAgeGroup;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  AgeGroup _getAgeGroupFromAge(int age) {
    if (age >= 4 && age <= 6) {
      return AgeGroup.age4to6;
    } else if (age >= 7 && age <= 9) {
      return AgeGroup.age7to9;
    } else if (age >= 10 && age <= 12) {
      return AgeGroup.age10to12;
    } else {
      return AgeGroup.age13plus;
    }
  }

  String _getAgeGroupDisplayName(AgeGroup ageGroup) {
    switch (ageGroup) {
      case AgeGroup.age4to6:
        return '4-6 Yaş';
      case AgeGroup.age7to9:
        return '7-9 Yaş';
      case AgeGroup.age10to12:
        return '10-12 Yaş';
      case AgeGroup.age13plus:
        return '13+ Yaş';
      case AgeGroup.all:
        return 'Tümü';
    }
  }

  Future<void> _createStudent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Migrate to Supabase
      // Replace FirebaseAuth and Firestore with Supabase Auth and Database
      /*
      // Create authentication user
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final userId = userCredential.user!.uid;
      final age = int.parse(_ageController.text);
      final ageGroup = _selectedAgeGroup ?? _getAgeGroupFromAge(age);
      final fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';

      // Create user document in Firestore
      final now = DateTime.now();
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'uid': userId,
        'email': _emailController.text.trim(),
        'displayName': fullName,
        'role': 'student',
        'ageGroup': ageGroup.name,
        'description': _descriptionController.text.trim(),
        'createdAt': Timestamp.fromDate(now),
        'lastLoginAt': null,
        'parentId': null,
        'studentIds': null,
        'classId': null,
      });
      */

      // Placeholder - TODO: Implement with Supabase Auth and Database
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Öğrenci oluşturma Supabase geçişini bekliyor'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
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
        title: const Text('Yeni Öğrenci Ekle'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // First Name
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'İsim *',
                  hintText: 'Öğrencinin adı',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen öğrencinin adını girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Last Name
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Soyisim *',
                  hintText: 'Öğrencinin soyadı',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen öğrencinin soyadını girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Age
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: 'Yaş *',
                  hintText: 'Öğrencinin yaşı',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.cake),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen yaş girin';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age < 4 || age > 15) {
                    return 'Yaş 4-15 arasında olmalıdır';
                  }
                  return null;
                },
                onChanged: (value) {
                  final age = int.tryParse(value);
                  if (age != null) {
                    setState(() {
                      _selectedAgeGroup = _getAgeGroupFromAge(age);
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Age Group (auto-selected based on age)
              if (_selectedAgeGroup != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF4CAF50),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF4CAF50),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Yaş Grubu: ${_getAgeGroupDisplayName(_selectedAgeGroup!)}',
                        style: const TextStyle(
                          color: Color(0xFF4CAF50),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'E-posta *',
                  hintText: 'ornek@email.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen e-posta adresi girin';
                  }
                  if (!value.contains('@')) {
                    return 'Geçerli bir e-posta adresi girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Şifre *',
                  hintText: 'En az 6 karakter',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen şifre girin';
                  }
                  if (value.length < 6) {
                    return 'Şifre en az 6 karakter olmalıdır';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Açıklama',
                  hintText: 'Öğrenci hakkında notlar (opsiyonel)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.note),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                maxLength: 500,
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _createStudent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Öğrenciyi Oluştur',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
