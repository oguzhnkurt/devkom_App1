import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/store_item_model.dart';
import '../providers/settings_provider.dart';
import 'mascot.dart';

/// Karakterin canlı gösterimi — "Karakterim" ekranı ve Market'in canlı
/// önizleme başlığı burayı paylaşıyor.
///
/// ARTIK AYRI BİR FİGÜR ÇİZMİYOR
/// ------------------------------
/// Önceden burada kendi çizdiği insansı bir gövde vardı: kafa, boyun,
/// gövde, kollar, bacaklar. Uygulamanın maskotu Devi ise apayrı bir
/// çizimdi. Sonuç şuydu — çocuk mağazadan bir şapka alıyordu ama o şapka
/// maskotun kafasına hiç oturmuyordu, çünkü giydirilen figürle
/// karşılaştığı karakter aynı "kişi" değildi. Kıyafet planı maskot
/// üzerinden yürüyorsa bu, planın temelindeki çatlak.
///
/// Artık tek bir figür var: [Mascot]. Bu sınıf onu sarmalıyor,
/// mağazanın [StoreItem] dünyasını Devi'nin çıpalarına
/// ([MascotAnchors]) çeviriyor ve dokunma/kutlama efektlerini ekliyor.
/// Ekranların API'si değişmedi.
///
/// MAĞAZADAKİ "KARAKTER" ÜRÜNLERİ NE OLDU
/// ---------------------------------------
/// Muz, robot, kedi gibi karakter ürünleri Devi'nin YERİNE geçmiyor —
/// yerine geçselerdi uygulamanın yine tek bir maskotu olmazdı. Bunun
/// yerine ikisini birden yapıyorlar: seçilen ürünün rengi Devi'nin
/// gövde rengi oluyor, simgesi de göğsündeki küçük ekranda beliriyor.
/// Ürün kimliğini koruyor, maskot tek kalıyor.
class CharacterStage extends StatefulWidget {
  final StoreItem? character;
  final StoreItem? hat;
  final StoreItem? necklace;
  final StoreItem? glasses;
  final StoreItem? shoes;
  final double size;
  final bool interactive;
  final Color accentColor;
  final bool previewMode;

  /// Maskotun ruh hâli. Market önizlemesinde meraklı, kutlama
  /// anlarında sevinçli göstermek için.
  final MascotMood mood;

  /// Hangi karakter gösterilecek.
  ///
  /// VERİLMEZSE çocuğun seçtiği karakter. Burada varsayılanı Puf yapmak
  /// bir HATAYDI: sahne türü [Mascot]'a HER ZAMAN elle geçirdiği için,
  /// çocuk Mia'yı seçse bile profil ekranındaki sahne Puf gösteriyordu.
  /// Türü boş geçmek kararı tek yere — [Mascot] içindeki çözümlemeye —
  /// bırakıyor.
  final MascotSpecies? species;

  const CharacterStage({
    super.key,
    this.character,
    this.hat,
    this.necklace,
    this.glasses,
    this.shoes,
    this.size = 200,
    this.interactive = true,
    this.accentColor = const Color(0xFF7C4DFF),
    this.previewMode = false,
    this.mood = MascotMood.idle,
    this.species,
  });

  /// Hiçbir karakter seçilmemişken göğüs ekranında ne görünsün.
  static const String defaultEmoji = '🍌';

  static Color parseColorHex(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF7C4DFF);
    }
  }

  @override
  State<CharacterStage> createState() => _CharacterStageState();
}

class _CharacterStageState extends State<CharacterStage> {
  final List<int> _burstIds = [];
  int _nextBurstId = 0;

  /// Dokununca kısa bir sevinç hâli. Devi'nin kendi zıplaması zaten
  /// [Mascot] içinde; buradaki sadece yüzü değiştiriyor.
  bool _celebrating = false;

  void _onTap() {
    if (!widget.interactive) return;
    HapticFeedback.mediumImpact();
    final id = _nextBurstId++;
    setState(() {
      _burstIds.add(id);
      _celebrating = true;
    });
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) setState(() => _celebrating = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    MascotSpecies species;
    if (widget.species != null) {
      species = widget.species!;
    } else {
      // Sağlayıcı olmayan bir ağaçta da çizilebilmeli (ekran görüntüsü
      // araçları, bazı widget testleri).
      try {
        species = context.watch<SettingsProvider>().mascot;
      } on ProviderNotFoundException {
        species = Mascot.defaultSpecies;
      }
    }
    final stageHeight = size * specOf(species).anchors.stageHeight;

    // Seçili karakterin rengi Devi'nin gövde rengi oluyor.
    final baseColor = widget.character != null
        ? CharacterStage.parseColorHex(widget.character!.colorHex)
        : widget.accentColor;

    final stage = SizedBox(
      width: size,
      height: stageHeight,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Mascot(
            species: species,
            size: size,
            color: baseColor,
            mood: _celebrating ? MascotMood.cheering : widget.mood,
            hat: widget.hat?.iconEmoji,
            glasses: widget.glasses?.iconEmoji,
            necklace: widget.necklace?.iconEmoji,
            shoes: widget.shoes?.iconEmoji,
            chestEmoji:
                widget.character?.iconEmoji ?? CharacterStage.defaultEmoji,
          ),

          ..._burstIds.map(
            (id) => _SparkleBurst(
              key: ValueKey(id),
              onDone: () {
                if (mounted) setState(() => _burstIds.remove(id));
              },
            ),
          ),

          if (widget.previewMode)
            Positioned(
              bottom: -2,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Önizleniyor',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    if (!widget.interactive) return stage;
    return GestureDetector(onTap: _onTap, child: stage);
  }
}

/// Dokununca etrafa saçılan yıldızlar.
class _SparkleBurst extends StatefulWidget {
  final VoidCallback onDone;
  const _SparkleBurst({super.key, required this.onDone});

  @override
  State<_SparkleBurst> createState() => _SparkleBurstState();
}

class _SparkleBurstState extends State<_SparkleBurst> {
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final rnd = math.Random();
    _particles = List.generate(6, (i) {
      final angle = (i / 6) * 2 * math.pi + rnd.nextDouble() * 0.4;
      final distance = 46.0 + rnd.nextDouble() * 22;
      const emojis = ['✨', '⭐', '💫'];
      return _Particle(
        angle: angle,
        distance: distance,
        emoji: emojis[i % emojis.length],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 750),
      curve: Curves.easeOut,
      onEnd: widget.onDone,
      builder: (context, t, child) {
        return Stack(
          alignment: Alignment.center,
          children: _particles.map((p) {
            final dx = math.cos(p.angle) * p.distance * t;
            final dy = math.sin(p.angle) * p.distance * t;
            return Transform.translate(
              offset: Offset(dx, dy),
              child: Opacity(
                opacity: (1 - t).clamp(0.0, 1.0),
                child: Text(
                  p.emoji,
                  style: TextStyle(fontSize: 14 + 8 * (1 - t)),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _Particle {
  final double angle;
  final double distance;
  final String emoji;
  const _Particle({
    required this.angle,
    required this.distance,
    required this.emoji,
  });
}
