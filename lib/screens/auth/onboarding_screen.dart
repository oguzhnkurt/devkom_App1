import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:devkom_app/providers/auth_provider.dart';
import 'package:devkom_app/screens/auth/register_screen.dart';
import 'package:devkom_app/screens/auth/login_screen.dart';
import 'package:devkom_app/screens/auth/welcome_screen.dart';
import 'package:devkom_app/widgets/animated_gradient_background.dart';
import '../../utils/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<OnboardingPage> _getPages(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return [
      OnboardingPage(
        title: loc.onboarding1Title,
        description: loc.onboarding1Description,
        icon: Icons.verified_user,
        colors: const [Color(0xFF4A90E2), Color(0xFF2C5AA0), Color(0xFF1E3A8A)], // Profesyonel mavi gradyan
      ),
      OnboardingPage(
        title: loc.onboarding2Title,
        description: loc.onboarding2Description,
        icon: Icons.school,
        colors: const [Color(0xFF50C878), Color(0xFF2E8B57), Color(0xFF16613C)], // Güven veren yeşil gradyan
      ),
      OnboardingPage(
        title: loc.onboarding3Title,
        description: loc.onboarding3Description,
        icon: Icons.analytics,
        colors: const [Color(0xFF9B59B6), Color(0xFF7D3C98), Color(0xFF5B2C6F)], // Kaliteli mor gradyan
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _completeOnboarding() {
    // Navigate to Welcome Screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
  }

  void _navigateToWelcome() {
    // Navigate to Welcome Screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final pages = _getPages(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _navigateToWelcome,
                    child: Text(
                      loc.alreadyHaveAccount,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (_currentPage < pages.length - 1)
                    TextButton(
                      onPressed: () {
                        _pageController.jumpToPage(pages.length - 1);
                      },
                      child: Text(
                        loc.skip,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(pages[index]);
                },
              ),
            ),

            // Page indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (index) => _buildIndicator(index == _currentPage, pages),
                ),
              ),
            ),

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Get Started button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _completeOnboarding,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pages[_currentPage].colors.first,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        loc.letsGetStarted,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildPage(OnboardingPage page) {
    return AnimatedGradientBackground(
      colors: page.colors,
      duration: const Duration(seconds: 5),
      opacity: 0.3,
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pulsing Icon
            PulsingIcon(
              icon: page.icon,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 48),

            // Title
            Text(
              page.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black45,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              page.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                height: 1.5,
                shadows: [
                  Shadow(
                    blurRadius: 8.0,
                    color: Colors.black38,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isActive, List<OnboardingPage> pages) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? pages[_currentPage].colors.first : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> colors;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.colors,
  });
}
