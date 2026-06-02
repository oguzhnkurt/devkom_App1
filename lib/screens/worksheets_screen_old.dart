import 'package:flutter/material.dart';
import '../theme.dart';
import 'worksheet_detail_screen.dart';

/// Professional Worksheets Screen
/// Smart Education Platform - AI, Robotics, Coding, Software
class WorksheetsScreen extends StatefulWidget {
  const WorksheetsScreen({super.key});

  @override
  State<WorksheetsScreen> createState() => _WorksheetsScreenState();
}

class _WorksheetsScreenState extends State<WorksheetsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> categories = ['Tümü', 'AI', 'Robotik', 'Kodlama', 'Yazılım'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Modern Header
            _buildHeader(context),

            // Category Tabs
            _buildCategoryTabs(),

            // Worksheets Grid
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: categories.map((category) {
                  return _buildWorksheetsGrid(category);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Çalışma Kağıtları',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Smart Education Platform',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Progress indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '12/24',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 50,
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: AppTheme.primaryBlue,
        labelColor: AppTheme.primaryBlue,
        unselectedLabelColor: Colors.grey,
        indicatorWeight: 3,
        tabs: categories.map((category) {
          return Tab(
            child: Text(
              category,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWorksheetsGrid(String category) {
    final worksheets = _getWorksheetsForCategory(category);

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: worksheets.length,
      itemBuilder: (context, index) {
        final worksheet = worksheets[index];
        return _buildWorksheetCard(worksheet);
      },
    );
  }

  Widget _buildWorksheetCard(Map<String, dynamic> worksheet) {
    final isCompleted = worksheet['completed'] ?? false;
    final difficulty = worksheet['difficulty'] ?? 'Orta';
    final category = worksheet['category'] ?? '';

    Color getCategoryColor() {
      switch (category) {
        case 'AI':
          return const Color(0xFF667eea);
        case 'Robotik':
          return const Color(0xFFFF9800);
        case 'Kodlama':
          return const Color(0xFF4CAF50);
        case 'Yazılım':
          return const Color(0xFFE91E63);
        default:
          return AppTheme.primaryBlue;
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorksheetDetailScreen(worksheet: worksheet),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Header with Icon
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    getCategoryColor(),
                    getCategoryColor().withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  // Completed badge
                  if (isCompleted)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.green,
                          size: 16,
                        ),
                      ),
                    ),
                  // Icon
                  Center(
                    child: Icon(
                      worksheet['icon'] ?? Icons.description,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Card Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      worksheet['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Difficulty & Duration
                    Row(
                      children: [
                        Icon(
                          Icons.signal_cellular_alt,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          difficulty,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${worksheet['duration'] ?? 15}dk',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: getCategoryColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: getCategoryColor(),
                        ),
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

  List<Map<String, dynamic>> _getWorksheetsForCategory(String category) {
    final allWorksheets = [
      // AI Worksheets
      {
        'title': 'Yapay Zeka Nedir?',
        'category': 'AI',
        'icon': Icons.psychology,
        'difficulty': 'Kolay',
        'duration': 15,
        'completed': true,
      },
      {
        'title': 'Makine Öğrenmesi Temelleri',
        'category': 'AI',
        'icon': Icons.auto_awesome,
        'difficulty': 'Orta',
        'duration': 25,
        'completed': false,
      },
      {
        'title': 'Chatbot Tasarımı',
        'category': 'AI',
        'icon': Icons.smart_toy,
        'difficulty': 'Orta',
        'duration': 30,
        'completed': false,
      },

      // Robotik Worksheets
      {
        'title': 'Robot Hareket Sistemleri',
        'category': 'Robotik',
        'icon': Icons.precision_manufacturing,
        'difficulty': 'Kolay',
        'duration': 20,
        'completed': true,
      },
      {
        'title': 'Sensör Kullanımı',
        'category': 'Robotik',
        'icon': Icons.sensors,
        'difficulty': 'Orta',
        'duration': 25,
        'completed': false,
      },
      {
        'title': 'Arduino ile LED Kontrolü',
        'category': 'Robotik',
        'icon': Icons.lightbulb,
        'difficulty': 'Kolay',
        'duration': 15,
        'completed': true,
      },

      // Kodlama Worksheets
      {
        'title': 'Python Temelleri',
        'category': 'Kodlama',
        'icon': Icons.code,
        'difficulty': 'Kolay',
        'duration': 20,
        'completed': false,
      },
      {
        'title': 'Döngüler ve Koşullar',
        'category': 'Kodlama',
        'icon': Icons.loop,
        'difficulty': 'Orta',
        'duration': 30,
        'completed': false,
      },
      {
        'title': 'Fonksiyonlar',
        'category': 'Kodlama',
        'icon': Icons.functions,
        'difficulty': 'Orta',
        'duration': 25,
        'completed': false,
      },

      // Yazılım Worksheets
      {
        'title': 'Mobil Uygulama Tasarımı',
        'category': 'Yazılım',
        'icon': Icons.phone_android,
        'difficulty': 'Zor',
        'duration': 40,
        'completed': false,
      },
      {
        'title': 'Web Geliştirme Temelleri',
        'category': 'Yazılım',
        'icon': Icons.language,
        'difficulty': 'Orta',
        'duration': 35,
        'completed': false,
      },
      {
        'title': 'Veritabanı Yönetimi',
        'category': 'Yazılım',
        'icon': Icons.storage,
        'difficulty': 'Zor',
        'duration': 45,
        'completed': false,
      },
    ];

    if (category == 'Tümü') {
      return allWorksheets;
    }

    return allWorksheets.where((w) => w['category'] == category).toList();
  }
}
