import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../unified_home_screen.dart';
import 'login_screen.dart';

/// Premium Onboarding Screen - Smart Education Platform
class PremiumOnboardingScreen extends StatefulWidget {
  const PremiumOnboardingScreen({super.key});

  @override
  State<PremiumOnboardingScreen> createState() => _PremiumOnboardingScreenState();
}

class _PremiumOnboardingScreenState extends State<PremiumOnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<OnboardingData> _slides = [
    OnboardingData(
      title: 'Gelecegin Egitimi',
      subtitle: 'DEVKOM ile Basliyor',
      description: 'Yapay zeka destekli, interaktif ogrenme deneyimi ile cocugunuzun potansiyelini kesfedin.',
      icon: Icons.rocket_launch_rounded,
      gradient: [Color(0xFF667eea), Color(0xFF764ba2)],
      features: ['AI Destekli Ogrenme', 'Kisisellestirilmis Icerik', 'Gercek Zamanli Takip'],
    ),
    OnboardingData(
      title: 'DevAI Asistan',
      subtitle: 'Yapay Zeka Ogretmeniniz',
      description: 'Sorularinizi yanitlayan, odevlerde yardimci olan akilli asistan.',
      icon: Icons.psychology_rounded,
      gradient: [Color(0xFF11998e), Color(0xFF38ef7d)],
      features: ['7/24 Soru Cevap', 'Odev Yardimi', 'Kodlama Destegi'],
    ),
    OnboardingData(
      title: 'Eglenerek Ogren',
      subtitle: 'Oyunlar & Aktiviteler',
      description: 'Satranc, robotik simulasyonlar, kodlama oyunlari ve daha fazlasi.',
      icon: Icons.sports_esports_rounded,
      gradient: [Color(0xFFf093fb), Color(0xFFf5576c)],
      features: ['Interaktif Oyunlar', 'Arduino Simulator', 'Basari Rozetleri'],
    ),
    OnboardingData(
      title: 'Gelisimi Takip Et',
      subtitle: 'Detayli Analizler',
      description: 'Ogrenme istatistikleri, ilerleme raporlari ve performans analizleri.',
      icon: Icons.insights_rounded,
      gradient: [Color(0xFF4facfe), Color(0xFF00f2fe)],
      features: ['Haftalik Raporlar', 'Basari Grafikleri', 'Veli Bildirimleri'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    HapticFeedback.lightImpact();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _continueAnonymously() async {
    setState(() => _isLoading = true);
    try {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      await settingsProvider.markOnboardingAsSeen();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const UnifiedHomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToEmailLogin() async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    await settingsProvider.markOnboardingAsSeen();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentPage];

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: slide.gradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentPage + 1}/${_slides.length}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton(
                      onPressed: _isLoading ? null : _continueAnonymously,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('Kesfet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final data = _slides[index];
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        blurRadius: 30,
                                        spreadRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Icon(data.icon, size: 70, color: Colors.white),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 40),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              data.subtitle,
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            data.title,
                            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            data.description,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 15, height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: data.features.map((f) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white.withValues(alpha: 0.9), size: 14),
                                  const SizedBox(width: 6),
                                  Text(f, style: TextStyle(color: Colors.white.withValues(alpha: 0.95), fontSize: 12)),
                                ],
                              ),
                            )).toList(),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Page indicators
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slides.length, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _currentPage ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _currentPage ? Colors.white : Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )),
                ),
              ),

              // Bottom Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : (_currentPage < _slides.length - 1 ? _nextPage : _continueAnonymously),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: slide.gradient[0],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          elevation: 8,
                          shadowColor: Colors.black26,
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _currentPage < _slides.length - 1 ? 'Devam' : 'Hemen Basla',
                                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(_currentPage < _slides.length - 1 ? Icons.arrow_forward_rounded : Icons.rocket_launch_rounded),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _navigateToEmailLogin,
                      child: Text(
                        'Zaten hesabin var mi? Giris yap',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
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
}

class OnboardingData {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final List<Color> gradient;
  final List<String> features;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.features,
  });
}
