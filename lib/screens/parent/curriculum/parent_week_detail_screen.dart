import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/weekly_curriculum_model.dart';
import '../../../theme.dart';

class ParentWeekDetailScreen extends StatelessWidget {
  final WeekContentModel weekContent;
  final String curriculumTitle;

  const ParentWeekDetailScreen({
    super.key,
    required this.weekContent,
    required this.curriculumTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hafta ${weekContent.weekNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.darkBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Başlık kartı
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    weekContent.isCompleted
                        ? Colors.green
                        : AppTheme.darkBlue,
                    weekContent.isCompleted
                        ? Colors.green.shade700
                        : AppTheme.darkBlue.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      curriculumTitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Hafta ${weekContent.weekNumber}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        if (weekContent.isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Tamamlandı',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    if (weekContent.completedAt != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Tamamlanma Tarihi: ${_formatDate(weekContent.completedAt!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // İçerik
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Konu başlığı
                  _buildInfoSection(
                    icon: Icons.title,
                    title: 'Konu',
                    content: weekContent.topic,
                  ),
                  const SizedBox(height: 16),

                  // Açıklama
                  if (weekContent.description.isNotEmpty) ...[
                    _buildInfoSection(
                      icon: Icons.description,
                      title: 'Açıklama',
                      content: weekContent.description,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Hedefler
                  if (weekContent.objectives != null && weekContent.objectives!.isNotEmpty) ...[
                    _buildInfoSection(
                      icon: Icons.flag,
                      title: 'Hedefler',
                      content: weekContent.objectives!,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Notlar
                  if (weekContent.notes != null && weekContent.notes!.isNotEmpty) ...[
                    _buildInfoSection(
                      icon: Icons.note,
                      title: 'Öğretmen Notları',
                      content: weekContent.notes!,
                      backgroundColor: Colors.amber.shade50,
                      borderColor: Colors.amber.shade200,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Fotoğraflar bölümü
                  if (weekContent.hasPhotos) ...[
                    Row(
                      children: [
                        Icon(Icons.photo_library, color: AppTheme.darkBlue),
                        const SizedBox(width: 8),
                        Text(
                          'Proje Fotoğrafları',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentTeal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.accentTeal,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${weekContent.projectPhotos.length} fotoğraf',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.accentTeal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Fotoğraf galerisi
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: weekContent.projectPhotos.length,
                      itemBuilder: (context, index) {
                        final photoUrl = weekContent.projectPhotos[index];
                        return GestureDetector(
                          onTap: () => _showFullScreenImage(context, photoUrl, index),
                          child: Hero(
                            tag: 'photo_$index',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                photoUrl,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade300,
                                    child: const Icon(
                                      Icons.broken_image,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ] else ...[
                    Card(
                      color: Colors.grey.shade50,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.photo_library_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Henüz fotoğraf eklenmemiş',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Video Linkler bölümü
                  if (weekContent.hasVideos) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Icon(Icons.video_library, color: AppTheme.darkBlue),
                        const SizedBox(width: 8),
                        Text(
                          'Video Linkler',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${weekContent.videoLinks.length} video',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...weekContent.videoLinks.map((videoUrl) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () => _openUrl(videoUrl),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.play_circle_filled,
                                    color: Colors.red,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        videoUrl,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Videoyu izlemek için tıklayın',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.open_in_new,
                                  color: Colors.grey.shade400,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],

                  // Kaynak Linkler bölümü
                  if (weekContent.hasResources) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Icon(Icons.link, color: AppTheme.darkBlue),
                        const SizedBox(width: 8),
                        Text(
                          'Kaynak Linkler',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentTeal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.accentTeal,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${weekContent.resourceLinks.length} kaynak',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.accentTeal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...weekContent.resourceLinks.map((resourceUrl) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () => _openUrl(resourceUrl),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentTeal.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.link,
                                    color: AppTheme.accentTeal,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        resourceUrl,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Kaynağı açmak için tıklayın',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.open_in_new,
                                  color: Colors.grey.shade400,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
    }
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return Card(
      elevation: 1,
      color: backgroundColor ?? Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: borderColor ?? Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppTheme.darkBlue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String photoUrl, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text('Fotoğraf ${index + 1} / ${weekContent.projectPhotos.length}'),
          ),
          body: Center(
            child: Hero(
              tag: 'photo_$index',
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  photoUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
