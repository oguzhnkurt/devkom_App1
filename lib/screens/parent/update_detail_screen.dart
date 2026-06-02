import 'package:flutter/material.dart';
import '../../theme.dart';

/// Screen to display detailed information about an update
class UpdateDetailScreen extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;
  final Color iconColor;
  final String type;

  const UpdateDetailScreen({
    super.key,
    required this.title,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gelişme Detayı'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: iconColor.withOpacity(0.1),
                      child: Icon(
                        icon,
                        size: 40,
                        color: iconColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 16, color: AppTheme.mediumGray),
                              const SizedBox(width: 4),
                              Text(
                                time,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.mediumGray,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Content based on type
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (type) {
      case 'homework':
        return _buildHomeworkContent(context);
      case 'game':
        return _buildGameContent(context);
      case 'event':
        return _buildEventContent(context);
      default:
        return _buildDefaultContent(context);
    }
  }

  Widget _buildHomeworkContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ödev Detayları',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          context,
          'Öğrenci',
          'Ahmet Yılmaz',
          Icons.person,
          AppTheme.primaryBlue,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          context,
          'Ödev Başlığı',
          'Robotik Kodlama - Döngüler',
          Icons.assignment,
          AppTheme.accentTeal,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          context,
          'Tamamlanma Durumu',
          'Tamamlandı ✓',
          Icons.check_circle,
          AppTheme.successGreen,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          context,
          'Skor',
          '95/100',
          Icons.star,
          AppTheme.warningOrange,
        ),
        const SizedBox(height: 24),
        Card(
          color: AppTheme.successGreen.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.successGreen),
                    const SizedBox(width: 8),
                    Text(
                      'Öğretmen Notu',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Ahmet ödevini zamanında ve başarıyla tamamladı. Döngüler konusunu çok iyi kavramış. Tebrikler!',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Oyun Detayları',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          context,
          'Öğrenci',
          'Ayşe Yılmaz',
          Icons.person,
          AppTheme.primaryBlue,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          context,
          'Oyun Adı',
          'Blok Yapıları - Yaratıcılık',
          Icons.games,
          AppTheme.accentTeal,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          context,
          'Seviye',
          'Seviye 3 - Orta',
          Icons.trending_up,
          AppTheme.warningOrange,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          context,
          'Kazanılan Puan',
          '850 Puan',
          Icons.stars,
          AppTheme.successGreen,
        ),
        const SizedBox(height: 24),
        Card(
          color: AppTheme.primaryBlue.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.emoji_events, color: AppTheme.primaryBlue),
                    const SizedBox(width: 8),
                    Text(
                      'Başarılar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildAchievementItem('🏆 İlk Kez Tamamlandı'),
                _buildAchievementItem('⭐ Yüksek Skor'),
                _buildAchievementItem('🎯 Hatasız Tamamlama'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Etkinlik Detayları',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          context,
          'Etkinlik Adı',
          'Robotik Kodlama Yarışması',
          Icons.event,
          AppTheme.primaryBlue,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          context,
          'Tarih',
          '15 Kasım 2025, Cumartesi',
          Icons.calendar_today,
          AppTheme.accentTeal,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          context,
          'Saat',
          '10:00 - 16:00',
          Icons.access_time,
          AppTheme.warningOrange,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          context,
          'Konum',
          'Doğa Koleji Spor Salonu',
          Icons.location_on,
          AppTheme.errorRed,
        ),
        const SizedBox(height: 24),
        Card(
          color: AppTheme.warningOrange.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.description, color: AppTheme.warningOrange),
                    const SizedBox(width: 8),
                    Text(
                      'Etkinlik Açıklaması',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.warningOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Değerli Veliler,\n\n'
                  'Öğrencilerimizin yıl boyunca öğrendikleri robotik kodlama becerilerini sergileyecekleri '
                  'bir yarışma düzenliyoruz. Tüm öğrencilerimiz yaş gruplarına göre farklı kategorilerde '
                  'yarışacaklar.\n\n'
                  'Yarışma kategorileri:\n'
                  '• 4-6 Yaş: Temel Blok Kodlama\n'
                  '• 7-9 Yaş: Robotik Hareket Kodlama\n'
                  '• 10+ Yaş: İleri Seviye Otomasyon\n\n'
                  'Tüm velilerimiz davetlidir. Katılım için kayıt gerekmemektedir.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: AppTheme.successGreen.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.successGreen),
                    const SizedBox(width: 8),
                    Text(
                      'Önemli Bilgiler',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildInfoItem('✓ Öğrenciler saat 09:30\'da okulda olmalıdır'),
                _buildInfoItem('✓ Spor kıyafeti giymeleri tavsiye edilir'),
                _buildInfoItem('✓ Öğle yemeği okul tarafından sağlanacaktır'),
                _buildInfoItem('✓ Her öğrenciye katılım sertifikası verilecektir'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement registration
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Katılım onayınız alınmıştır!'),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            icon: const Icon(Icons.check_circle),
            label: const Text('Katılacağım'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: AppTheme.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultContent(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Detay bilgisi bulunmamaktadır.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.mediumGray,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text),
    );
  }
}
