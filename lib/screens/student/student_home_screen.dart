import 'package:flutter/material.dart';
// import '../messaging/conversations_screen.dart'; // Temporarily disabled
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../theme.dart';
import '../../widgets/student_drawer.dart';
import '../../widgets/progress_indicator_widget.dart';
import '../../widgets/daily_quests_widget.dart';
import '../../widgets/achievements_widget.dart';
import '../robotics_games_screen.dart';
import '../homework_screen.dart';
import '../auth/profile_screen.dart';
import '../arduino_simulator_main_screen.dart';
import '../social/feed_screen.dart';
import '../social/enhanced_feed_screen_v2.dart';
import '../games/millionaire_game_screen.dart';
import '../shared/general_curriculum_screen.dart';
import '../unified_home_screen.dart';
import '../messaging/enhanced_chat_screen.dart';

import '../devchat_screen.dart'; // DevAiChat Screen
import '../worksheets_screen.dart';
import '../../utils/app_localizations.dart';

/// Student home screen with age-appropriate content
/// Shows games and homework based on student's age group
/// Updated with new professional UI screens
class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    // 5 tab navigation: Ana Sayfa, Mesajlar, Sosyal Akış, DevAiChat, Profil
    final List<Widget> _screens = const [
      UnifiedDashboard(), // Using new unified dashboard design
      RoboticsGamesScreen(), // Temporarily replaced ConversationsScreen
      EnhancedFeedScreenV2(),
      DevAiChatScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      drawer: const StudentDrawer(),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
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
            label: loc.home,
          ),
          NavigationDestination(
            icon: Icon(Icons.message_outlined, color: Colors.green.shade400),
            selectedIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.message, color: Colors.white, size: 20),
            ),
            label: loc.messages,
          ),
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
            label: loc.socialFeed,
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
            label: loc.devAiChat,
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
            label: loc.profile,
          ),
        ],
      ),
    );
  }
}

class _StudentDashboard extends StatelessWidget {
  const _StudentDashboard();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    // Format date
    final now = DateTime.now();
    final locale = Localizations.localeOf(context);
    final formattedDate = DateFormat('MMMM d, yyyy', locale.languageCode).format(now);

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with date and profile
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${loc.welcome}, ${user?.displayName ?? loc.student}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      // Drawer menu button
                      Builder(
                        builder: (context) => GestureDetector(
                          onTap: () {
                            Scaffold.of(context).openDrawer();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.menu,
                              color: Colors.grey[700],
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Profile button
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                          child: Icon(
                            Icons.person,
                            color: AppTheme.primaryBlue,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Overview Card
              _buildOverviewCard(context, loc),
              const SizedBox(height: 24),

              // Progress Indicator Widget
              if (user?.uid != null)
                ProgressIndicatorWidget(userId: user!.uid),
              if (user?.uid != null) const SizedBox(height: 24),

              // Daily Quests Widget
              if (user?.uid != null)
                DailyQuestsWidget(userId: user!.uid),
              if (user?.uid != null) const SizedBox(height: 24),

              // Achievements Widget
              if (user?.uid != null)
                AchievementsWidget(userId: user!.uid),
              if (user?.uid != null) const SizedBox(height: 24),

              // Upcoming Activities
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.popularActivities,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey[600]),
                ],
              ),
              const SizedBox(height: 16),
              _buildUpcomingActivities(context, loc),
              const SizedBox(height: 24),

              // Learning Progress Score
              _buildLearningScoreCard(context, loc),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D3436), Color(0xFF000000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.todaysGoals,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '5 ${loc.activities}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.6,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
            ),
          ),
          const SizedBox(height: 20),
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(loc.games, '12', Icons.games),
              _buildStatItem(loc.homework, '5', Icons.assignment),
              _buildStatItem(loc.points, '450', Icons.star),
              _buildStatItem(loc.achievements, '15', Icons.emoji_events),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingActivities(BuildContext context, AppLocalizations loc) {
    return Column(
      children: [
        _buildActivityCard(
          context,
          loc.robotMovementGame,
          loc.educationalGame,
          Icons.smart_toy,
          const Color(0xFF6C5CE7),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RoboticsGamesScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActivityCard(
          context,
          loc.arduinoSimulator,
          loc.circuitDesign,
          Icons.developer_board,
          const Color(0xFFFF9800),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ArduinoSimulatorMainScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActivityCard(
          context,
          loc.myHomework,
          loc.currentHomework,
          Icons.assignment,
          AppTheme.accentTeal,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeworkScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActivityCard(
          context,
          loc.devAiChat,
          loc.aiAssistant,
          Icons.smart_toy,
          const Color(0xFF667eea),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DevAiChatScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActivityCard(
          context,
          loc.millionaireGame,
          loc.quizGame,
          Icons.emoji_events,
          const Color(0xFFFFD700),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MillionaireGameScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActivityCard(
          context,
          loc.worksheets,
          loc.aiRoboticsCoding,
          Icons.description,
          const Color(0xFF00BCD4),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WorksheetsScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningScoreCard(BuildContext context, AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.learningScore,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[600]),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.trending_up, color: AppTheme.successGreen, size: 32),
              const SizedBox(width: 8),
              const Text(
                '8.2',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ' /10',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.82,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.successGreen),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            loc.greatProgress,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
