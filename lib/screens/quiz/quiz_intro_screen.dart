import 'package:flutter/material.dart';
import '../../utils/lang.dart';
import '../../widgets/slide_to_start_button.dart';
import 'quiz_home_screen.dart';

/// Quiz Merkezi'ne giriş ekranı — Quizo tasarımındaki "Pick a Topic, Play,
/// Win!" tanıtım ekranından ilham alındı: dekoratif şekiller + kaydırarak
/// başlatma butonu. Renkler devkom'un mor kimliğinde.
class QuizIntroScreen extends StatelessWidget {
  const QuizIntroScreen({super.key});

  static const _purple = Color(0xFF6C3CE0);

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FF),
      body: Stack(
        children: [
          // Dekoratif şekiller
          Positioned(
            top: -40,
            right: -30,
            child: Transform.rotate(
              angle: 0.5,
              child: Container(
                width: 140,
                height: 220,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_purple.withValues(alpha: 0.25), _purple.withValues(alpha: 0.05)],
                  ),
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
          ),
          Positioned(
            top: 90,
            left: 24,
            child: Icon(Icons.auto_awesome, color: _purple.withValues(alpha: 0.4), size: 22),
          ),
          Positioned(
            top: 160,
            right: 48,
            child: Icon(Icons.auto_awesome, color: _purple.withValues(alpha: 0.3), size: 16),
          ),
          Positioned(
            bottom: 220,
            left: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () => _enter(context),
                      child: Text(
                          AppLang.pick(lang,
                              tr: 'Geç',
                              en: 'Skip',
                              de: 'Überspringen',
                              es: 'Saltar'),
                          style:
                              TextStyle(color: _purple.withValues(alpha: 0.7))),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 56,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _purple,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppLang.pick(lang,
                        tr: 'Konu Seç,\nOyna, Kazan!',
                        en: 'Pick a Topic,\nPlay, Win!',
                        de: 'Thema wählen,\nspielen, gewinnen!',
                        es: 'Elige un tema,\n¡juega y gana!'),
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    AppLang.pick(lang,
                        tr: 'Kodlama derslerine göre onlarca soru seni '
                            'bekliyor.\nDoğru cevapla, jeton ve XP kazan!',
                        en: 'Dozens of questions from the coding lessons are '
                            'waiting.\nAnswer correctly to earn coins and XP!',
                        de: 'Dutzende Fragen aus den Programmierlektionen '
                            'warten auf dich.\nAntworte richtig und verdiene '
                            'Münzen und XP!',
                        es: 'Decenas de preguntas de las lecciones de '
                            'programación te esperan.\n¡Acierta y gana '
                            'monedas y XP!'),
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.4),
                  ),
                  const Spacer(flex: 2),
                  SlideToStartButton(
                    label: AppLang.pick(lang,
                        tr: 'Başlamak için kaydır',
                        en: 'Slide to start',
                        de: 'Zum Starten wischen',
                        es: 'Desliza para empezar'),
                    thumbColor: _purple,
                    labelColor: _purple,
                    onConfirmed: () => _enter(context),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _enter(BuildContext context) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => const QuizHomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
                  .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child,
            ),
          );
        },
      ),
    );
  }
}
