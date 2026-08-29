import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../models/user_progress_model.dart';
import '../services/user_progress_service.dart';
import 'social/enhanced_feed_screen_v2.dart';
// import 'messaging/conversations_screen.dart'; // Temporarily disabled

import 'devchat_screen.dart'; // DevAiChat Screen
import 'auth/profile_screen.dart';
import 'robotics_games_screen.dart';
import 'worksheets_screen.dart';
import 'w3_courses_screen.dart';
import '../widgets/visitor_cta_widget.dart';
import '../widgets/student_drawer.dart';
import 'market_screen.dart';
import 'character_screen.dart';
import '../utils/social_feed_access.dart';

/// Unified Home Screen - Minimal, modern dashboard for all ages
class UnifiedHomeScreen extends StatefulWidget {
  const UnifiedHomeScreen({super.key});

  @override
  State<UnifiedHomeScreen> createState() => _UnifiedHomeScreenState();
}

class _UnifiedHomeScreenState extends State<UnifiedHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAuthenticated = authProvider.isAuthenticated;

    // Sosyal akis 13 yas alti kullanicilara kapali (Apple yas derecelendirme
    // beyani geregi) - bkz. utils/social_feed_access.dart
    final canUseFeed = SocialFeedAccess.isAllowed(authProvider.currentUser);

    final List<Widget> screens = [
      const UnifiedDashboard(),
      const RoboticsGamesScreen(), // Temporarily replaced ConversationsScreen
      if (canUseFeed) const EnhancedFeedScreenV2(),
      const DevAiChatScreen(),
      const ProfileScreen(),
    ];

    // Feed sekmesi kaldirildiginda eski index sinir disina tasabilir.
    final safeIndex = _selectedIndex.clamp(0, screens.length - 1);

    return Scaffold(
      body: screens[safeIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: Colors.blue.shade400),
            selectedIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.home, color: Colors.white, size: 20),
            ),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(
              isAuthenticated ? Icons.message_outlined : Icons.games_outlined,
              color: Colors.green.shade400,
            ),
            selectedIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isAuthenticated ? Icons.message : Icons.games,
                color: Colors.white,
                size: 20,
              ),
            ),
            label: isAuthenticated ? 'Mesajlar' : 'Oyunlar',
          ),
          if (canUseFeed)
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline, color: Colors.orange.shade400),
              selectedIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.orange.shade600],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add_circle, color: Colors.white, size: 20),
              ),
              label: 'Sosyal Akis',
            ),
          NavigationDestination(
            icon: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ).createShader(bounds),
              child: const Icon(Icons.auto_awesome, color: Colors.white),
            ),
            selectedIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            ),
            label: 'DevAiChat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, color: Colors.purple.shade400),
            selectedIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.purple.shade600],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

/// Unified Dashboard - Minimal, modern design for ages 6-99
class UnifiedDashboard extends StatefulWidget {
  const UnifiedDashboard({super.key});

  @override
  State<UnifiedDashboard> createState() => _UnifiedDashboardState();
}

class _UnifiedDashboardState extends State<UnifiedDashboard>
    with TickerProviderStateMixin {
  late AnimationController _streakController;
  late Animation<double> _streakAnimation;
  late AnimationController _orbController;
  late Animation<double> _orbAnimation;

  // Progress service for visitor mode
  final UserProgressService _progressService = UserProgressService();

  // Computed values based on progress from AuthProvider
  int get queriesUsed => 0;
  int get queriesTotal => 10;

  @override
  void initState() {
    super.initState();
    _streakController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _streakAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _streakController, curve: Curves.easeInOut),
    );

    _orbController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _orbAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _orbController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _streakController.dispose();
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get progress from AuthProvider or use visitor progress
    final userProgress = authProvider.userProgress ?? _progressService.getVisitorProgress();
    final userLevel = userProgress.level;
    final currentXP = userProgress.totalXP;
    final requiredXP = UserProgress.xpForLevel(userLevel);
    final streakDays = userProgress.streakDays;
    final lessonsCompleted = userProgress.dailyGoalsCompleted;
    final lessonsTarget = userProgress.totalDailyGoals;
    final earnedBadges = _progressService.getUserBadges()
        .where((b) => b.isEarned)
        .map((b) => b.emoji)
        .toList();

    List<Map<String, dynamic>> recentActivities = [];
    if (authProvider.isAuthenticated && userProgress.userId != 'visitor') {
      recentActivities = [
        {'icon': '🎓', 'title': 'Derse basladiniz!', 'time': 'Az once'},
      ];
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      drawer: const StudentDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroSection(user, isDark, userLevel, currentXP, requiredXP, streakDays),
                const SizedBox(height: 20),
                _buildDevAIQueryBar(isDark),
                const SizedBox(height: 20),
                _buildDailyGoalRing(isDark, lessonsCompleted, lessonsTarget),
                const SizedBox(height: 24),
                _buildQuickActionsGrid(context, isDark),
                const SizedBox(height: 24),
                _buildStreakCounter(isDark, streakDays),
                const SizedBox(height: 24),
                _buildActivityTimeline(isDark, recentActivities),
                const SizedBox(height: 24),
                _buildBadgeShowcase(isDark, earnedBadges),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }


  /// Hero Section - User greeting and XP progress
  Widget _buildHeroSection(UserModel? user, bool isDark, int userLevel, int currentXP, int requiredXP, int streakDays) {
    final isVisitor = user == null;
    final xpProgress = requiredXP > 0 ? (currentXP / requiredXP).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Builder(
              builder: (context) => GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.menu_rounded,
                    color: isDark ? Colors.white : Colors.grey.shade800,
                    size: 24,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Text(
                isVisitor ? 'Merhaba, Kasif!' : 'Hosgeldin, ${user.displayName}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.blue.shade400],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Visitor: Show CTA | Auth: Show XP progress
        isVisitor
            ? VisitorCTAWidget(isDark: isDark)
            : XPProgressWidget(
                userLevel: userLevel,
                currentXP: currentXP,
                streakDays: streakDays,
                xpProgress: xpProgress,
                isDark: isDark,
              ),
      ],
    );
  }


  /// DevAI Query Limit Bar - With breathing orb animation
  Widget _buildDevAIQueryBar(bool isDark) {
    final queriesLeft = queriesTotal - queriesUsed;
    final queryProgress = queriesUsed / queriesTotal;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DevAiChatScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF667eea),
              const Color(0xFF764ba2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667eea).withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Breathing AI Orb with DevAI branding
            ScaleTransition(
              scale: _orbAnimation,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.95),
                      const Color(0xFFB8B5FF).withValues(alpha: 0.7),
                      const Color(0xFF667eea).withValues(alpha: 0.4),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.6),
                      blurRadius: 25,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: const Color(0xFF667eea).withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow circle
                      Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF667eea).withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                      ),
                      // DevAI text logo
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: const Text(
                              'Dev',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF764ba2), Color(0xFF667eea)],
                            ).createShader(bounds),
                            child: const Text(
                              'AI',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Sparkle effect
                      Positioned(
                        top: 8,
                        right: 12,
                        child: Icon(
                          Icons.auto_awesome,
                          size: 12,
                          color: const Color(0xFF667eea).withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // DevAI Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DevAI Chat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$queriesLeft/$queriesTotal Soru Hakki',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: 1 - queryProgress,
                      minHeight: 6,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// Daily Goal - Circular progress ring
  Widget _buildDailyGoalRing(bool isDark, int lessonsCompleted, int lessonsTarget) {
    final progress = lessonsTarget > 0 ? lessonsCompleted / lessonsTarget : 0.0;
    final percentage = (progress * 100).toInt();

    Color getProgressColor() {
      if (percentage == 100) return Colors.green;
      if (percentage >= 67) return Colors.purple;
      if (percentage >= 34) return Colors.blue;
      return Colors.orange;
    }

    String getMotivationText() {
      if (percentage == 100) return 'Mukemmel! Hedefini tamamladin! 🎉';
      if (percentage >= 67) return 'Bugun harikasin! ${lessonsTarget - lessonsCompleted} ders daha!';
      if (percentage >= 34) return 'Iyi gidiyorsun! Devam et! 💪';
      return 'Hadi baslayalim! ${lessonsTarget - lessonsCompleted} ders seni bekliyor!';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular progress
          SizedBox(
            width: 100,
            height: 100,
            child: CustomPaint(
              painter: _CircularProgressPainter(
                progress: progress,
                color: getProgressColor(),
                backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$lessonsCompleted/$lessonsTarget',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ders',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Text info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gunluk Hedef',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$percentage% tamamlandi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: getProgressColor(),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  getMotivationText(),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Quick Actions Grid - 2x2 action cards
  Widget _buildQuickActionsGrid(BuildContext context, bool isDark) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        _buildThemedCard(
          context: context,
          icon: Icons.school,
          title: 'Ders',
          subtitle: 'Ogren',
          colors: [const Color(0xFF1A1A2E), const Color(0xFF16213E), const Color(0xFF0F3460)],
          isDark: isDark,
          showStars: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const W3CoursesScreen()),
            );
          },
        ),
        _buildThemedCard(
          context: context,
          icon: Icons.rocket_launch,
          title: 'Oyun',
          subtitle: 'Eglen',
          colors: [const Color(0xFF2E1A47), const Color(0xFF3D2C5D), const Color(0xFF4A3F6B)],
          isDark: isDark,
          showStars: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RoboticsGamesScreen()),
            );
          },
        ),
        _buildThemedCard(
          context: context,
          icon: Icons.assignment,
          title: 'Odev',
          subtitle: 'Gorev',
          colors: [const Color(0xFF0D1F2D), const Color(0xFF1B2F42), const Color(0xFF2A4357)],
          isDark: isDark,
          showStars: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WorksheetsScreen()),
            );
          },
        ),
        _buildThemedCard(
          context: context,
          icon: Icons.face_retouching_natural,
          title: 'Karakterim',
          subtitle: 'Ozellestir',
          colors: [const Color(0xFF1F1D36), const Color(0xFF3F3351), const Color(0xFF5B4B6E)],
          isDark: isDark,
          showStars: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CharacterScreen()),
            );
          },
        ),
        _buildThemedCard(
          context: context,
          icon: Icons.storefront_rounded,
          title: 'Market',
          subtitle: 'Jeton harca',
          colors: [const Color(0xFF3D2B1F), const Color(0xFF6C3CE0), const Color(0xFF9C6ADE)],
          isDark: isDark,
          showStars: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MarketScreen()),
            );
          },
        ),
      ],
    );
  }

  /// Themed Card - Unified design for all quick action cards
  Widget _buildThemedCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> colors,
    required bool isDark,
    required VoidCallback onTap,
    bool showStars = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.last.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Stars overlay for space theme
              if (showStars)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _SpaceStarsPainter(),
                  ),
                ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icon with glow effect
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.2),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Arrow with glow
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Streak Counter - Prominent streak display
  Widget _buildStreakCounter(bool isDark, int streakDays) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ScaleTransition(
            scale: _streakAnimation,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.red.shade400],
                ),
                shape: BoxShape.circle,
              ),
              child: const Text(
                '🔥',
                style: TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streakDays Gunluk Seri',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Harika gidiyorsun! Serini surdur!',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Activity Timeline - Last 3 activities
  Widget _buildActivityTimeline(bool isDark, List<Map<String, dynamic>> recentActivities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Son Aktiviteler',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        if (recentActivities.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'Ilk dersine basla ve buraya kaydedelim! 🚀',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ...recentActivities.take(3).map((activity) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      activity['icon'],
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['title'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          activity['time'],
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  /// Badge Showcase - Horizontal scroll badges
  Widget _buildBadgeShowcase(bool isDark, List<String> earnedBadges) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Rozetlerim (${earnedBadges.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            Text(
              'Tumunu Gor →',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.purple.shade400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (earnedBadges.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'Ilk rozetine cok yakinsin! Bir ders tamamla 🎯',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: earnedBadges.length + 1, // +1 for next badge to unlock
              itemBuilder: (context, index) {
                final isLocked = index == earnedBadges.length;
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isLocked
                          ? (isDark ? Colors.grey.shade800 : Colors.grey.shade300)
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isLocked
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock_outline,
                                size: 32,
                                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sonraki',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            earnedBadges[index],
                            style: const TextStyle(fontSize: 48),
                          ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

/// Circular Progress Painter for Daily Goal
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 8;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start from top
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

/// Space stars painter for games card
class _SpaceStarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw random stars
    final random = Random(42); // Fixed seed for consistent stars
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final starSize = random.nextDouble() * 2 + 0.5;

      canvas.drawCircle(
        Offset(x, y),
        starSize,
        paint..color = Colors.white.withValues(alpha: random.nextDouble() * 0.5 + 0.3),
      );
    }

    // Draw a few larger glowing stars
    for (int i = 0; i < 5; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;

      // Glow effect
      canvas.drawCircle(
        Offset(x, y),
        3,
        paint..color = Colors.cyan.withValues(alpha: 0.2),
      );
      canvas.drawCircle(
        Offset(x, y),
        1.5,
        paint..color = Colors.white.withValues(alpha: 0.8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

