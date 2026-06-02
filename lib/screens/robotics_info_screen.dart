import 'package:flutter/material.dart';

class RoboticsInfoScreen extends StatelessWidget {
  const RoboticsInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Robotik Nedir?'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Robotik Nedir?',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Robotik, robotların tasarımı, yapımı, işletimi ve uygulanmasıyla ilgilenen bir mühendislik dalıdır. '
                      'Robotlar, programlanabilir makinelerdir ve genellikle insan gözetimi olmadan veya minimum gözetimle görevleri yerine getirebilirler.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Robotik Alanları',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoItem(
                      context,
                      Icons.factory,
                      'Endüstriyel Robotik',
                      'Üretim ve montaj hatlarında kullanılan robotlar',
                    ),
                    _buildInfoItem(
                      context,
                      Icons.medical_services,
                      'Tıbbi Robotik',
                      'Cerrahi ve rehabilitasyon amaçlı robotlar',
                    ),
                    _buildInfoItem(
                      context,
                      Icons.home,
                      'Hizmet Robotları',
                      'Ev temizliği ve güvenlik robotları',
                    ),
                    _buildInfoItem(
                      context,
                      Icons.explore,
                      'Keşif Robotları',
                      'Uzay ve derin deniz araştırma robotları',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Neden Robotik Öğrenmeliyim?',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    _buildBulletPoint(context, 'Problem çözme becerilerini geliştirir'),
                    _buildBulletPoint(context, 'STEM (Bilim, Teknoloji, Mühendislik, Matematik) becerilerini artırır'),
                    _buildBulletPoint(context, 'Yaratıcılığı ve yenilikçiliği teşvik eder'),
                    _buildBulletPoint(context, 'Takım çalışması ve işbirliği becerilerini güçlendirir'),
                    _buildBulletPoint(context, 'Geleceğin teknolojilerine hazırlar'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: const Color(0xFFf093fb)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 20)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
