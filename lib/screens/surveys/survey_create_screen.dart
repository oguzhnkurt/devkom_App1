import 'package:flutter/material.dart';

class SurveyCreateScreen extends StatelessWidget {
  const SurveyCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Anket Oluştur'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Anket Oluşturma\nÇok Yakında!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Admin panel üzerinden anket\noluşturabileceksiniz',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
