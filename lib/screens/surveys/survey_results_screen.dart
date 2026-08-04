import 'package:flutter/material.dart';
import '../../models/survey_model.dart';

class SurveyResultsScreen extends StatelessWidget {
  final SurveyModel survey;

  const SurveyResultsScreen({super.key, required this.survey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anket Sonuçları'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Anket İstatistikleri\nÇok Yakında!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Detaylı anket sonuçları ve\nistatistikler burada görünecek',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
