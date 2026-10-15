import 'package:flutter/material.dart';

import '../utils/lang.dart';
import 'package:flutter/services.dart';

import '../ui/motion.dart';
import 'mascot.dart';
import '../courses/yurutme/scratch_blok_katalogu.dart';
import 'scratch_blok.dart';
import '../services/sound_service.dart';

/// Karşılamanın ilk ekranındaki GERÇEK görev.
///
/// NEDEN İLK EKRAN BİR SORU DEĞİL
/// -------------------------------
/// Önceki akış çocuğa sekiz sayfa boyunca soru soruyor, ilk gerçek işi
/// en sona bırakıyordu. Bunun iki ayrı sorunu var:
///
/// * **Ürün açısından:** çocuk uygulamanın ne olduğunu, ne yapabildiğini
///   görmeden önce dört soru cevaplıyor. Duolingo kayıt ekranını akışta
///   birkaç adım geriye aldığında günlük aktif kullanıcı %20 artmıştı —
///   ölçülmüş en büyük tek kazançlarından biri. İnsan önce ürünü görmek
///   istiyor.
/// * **Kural açısından:** Apple'ın 5.1.4(a) maddesi çocuk uygulamaları
///   için açık — yaş ve veli bilgisi yalnızca mevzuata uymak için
///   sorulabilir ve uygulama "kişinin yaşından bağımsız olarak" işe
///   yarar bir işlev sunmalıdır. ICO'nun Çocuklara Uygun Tasarım
///   Kuralları'nın 8. maddesi de yalnızca çocuğun "etkin ve bilerek
///   kullandığı" özellikler için veri toplanmasını istiyor. Sekiz soruyu
///   önden sormak ikisine de ters.
///
/// Bu yüzden ilk ekran bir görev: iki bloğu birleştir, kedi yürüsün.
/// Beş saniye, tek hareket, görünür bir sonuç.
class FirstTask extends StatefulWidget {
  const FirstTask({
    super.key,
    required this.onSolved,
    this.accent = const Color(0xFF2E9E5B),
    this.lang = 'tr',
  });

  /// Görev tamamlandığında. `tries` kaçıncı denemede olduğunu söylüyor.
  final void Function(int tries) onSolved;

  final Color accent;
  final String lang;

  @override
  State<FirstTask> createState() => _FirstTaskState();
}

/// Karşılama görevindeki iki blok.
///
/// GERÇEK SCRATCH 3 BLOĞU
/// ----------------------
/// Çocuğun uygulamada gördüğü İLK şey bu iki blok. Önce elde çizilmiş
/// kutulardı, sonra eski düz yapboz çizimi (`ScratchBlockWidget`). Artık
/// Scratch kursunun kullandığı aynı çizim ([ScratchBlok]) ve aynı katalog
/// ([ScratchBlokKatalogu]): yeşil bayraklı şapka, beyaz oval "10" girdisi,
/// Scratch'in resmi etiketleri ve renkleri — çocuk Scratch'i açınca aynı
/// blokları tanıyor.
const _hatId = 'green_flag';
const _moveId = 'move_10';

/// Karşılama ekranında bloklar biraz büyük: tek hareketlik görev.
const double _olcek = 1.0;

class _FirstTaskState extends State<FirstTask>
    with SingleTickerProviderStateMixin {
  /// Alt bloğun yuvaya oturup oturmadığı.
  bool _snapped = false;

  /// Sürükleme sırasında yuvanın üstünde mi.
  bool _hovering = false;

  int _tries = 0;

  /// Oturduktan sonraki kutlama.
  ///
  /// `late final ... = AnimationController(...)` DEĞİL, initState.
  /// Görev çözülmeden ekrandan çıkılırsa denetleyiciye hiç
  /// dokunulmuyor; sonra `dispose()` ona ilk kez erişince denetleyici
  /// tam da widget ağaçtan çıkarılırken kuruluyor ve TickerMode araması
  /// "Looking up a deactivated widget's ancestor is unsafe" ile
  /// patlıyor. (Aynı hata daha önce tanıtım karuselinde de yaşandı.)
  late final AnimationController _celebrate;

  @override
  void initState() {
    super.initState();
    _celebrate = AnimationController(vsync: this, duration: Motion.long4);
  }

  @override
  void dispose() {
    _celebrate.dispose();
    super.dispose();
  }

  /// Dort dilli kisa yardimci.
  ///
  /// Onceki hali `lang == 'tr' ? tr : en` idi: Almanca ya da Ispanyolca
  /// secen cocuk bu ekrandaki maskot replikasini Ingilizce goruyordu.
  /// Ilk gorev uygulamayla ilk temas oldugu icin en gorunur yerdeydi.
  String _t(String tr, String en, [String? de, String? es]) =>
      AppLang.pick(widget.lang, tr: tr, en: en, de: de, es: es);

  void _onAccepted() {
    if (_snapped) return;
    setState(() {
      _snapped = true;
      _hovering = false;
      _tries++;
    });
    // UYGULAMADAKI ILK BASARI — ama MUZIK DEGIL.
    //
    // Burada bir sure uc saniyelik bir big band kutlamasi caliyordu;
    // kullanici "bloklar birlesince calan muzigi begenmedim, daha basit
    // bir ses koy" dedi. Simdi her yerde blok oturunca duyulan ayni
    // kisa "tok" sesi, ardindan iki notalik kucuk bir "tamam".
    SoundService.playBlokTak();
    Future.delayed(const Duration(milliseconds: 160), () {
      if (mounted) SoundService.playBlokTamam();
    });
    if (!Motion.reduced(context)) _celebrate.forward(from: 0);
    // Kutlamanın görülmesi için kısa bir bekleme; hemen sayfa
    // değiştirmek çocuğun başardığını görmesine izin vermiyor.
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) widget.onSolved(_tries);
    });
  }

  void _onMissed() {
    // Yanlış yere bırakmak bir HATA DEĞİL. Sayaç artıyor ama ekranda
    // kırmızı bir şey, "yanlış" yazısı ya da ses yok — blok yerine
    // dönüyor, hepsi bu.
    setState(() => _tries++);
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    // Tek maskot: karakter secimi kalkti, ad da sabit.
    const mascotName = Mascot.ad;
    final hat = ScratchBlokKatalogu.tanim(_hatId, widget.lang)!;
    final move = ScratchBlokKatalogu.tanim(_moveId, widget.lang)!;
    Widget moveBlok() => ScratchBlok(
          tanim: move,
          olcek: _olcek,
          kimlik: _moveId,
        );
    final moveW = ScratchBlokOlcer.genislik(move, _olcek);
    final moveH = ScratchBlokOlcer.yukseklik(move, _olcek);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MascotSays(
          mood: _snapped ? MascotMood.cheering : MascotMood.curious,
          color: widget.accent,
          size: 64,
          text: _snapped
              ? _t(
                  'İşte bu! Kodlama tam olarak bu — blokları birleştirmek.',
                  "That's it! Coding is exactly this — snapping blocks together.",
                  'Super! Genau das ist Programmieren — Blöcke zusammenstecken.',
                  '¡Eso es! Programar es exactamente esto: unir bloques.')
              : _t(
                  'Selam, ben $mascotName! Şu iki bloğu birleştirir misin?',
                  "Hi, I'm $mascotName! Can you snap these two blocks "
                      'together?',
                  'Hallo, ich bin $mascotName! Kannst du diese zwei Blöcke zusammenstecken?',
                  '¡Hola, soy $mascotName! ¿Puedes unir estos dos bloques?'),
        ),
        const SizedBox(height: 28),
        Center(
          child: SizedBox(
            width: 300,
            height: 210,
            child: Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                // --- üstteki sabit blok + yuva ---
                Positioned(
                  top: 4,
                  child: Column(
                    // Şapka blok ile yuva SOLDAN hizalı: gerçek bir
                    // yığında bloklar sol kenarlarından hizalanır.
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ScratchBlok(tanim: hat, olcek: _olcek, kimlik: _hatId),
                      // Bloklar birbirine GEÇİYOR: ScratchBlok'un
                      // yerleşim yüksekliği tırnağı içermiyor, tırnak
                      // alttaki bloğun çentiğine oturuyor — arada boşluk
                      // ya da kaydırma gerekmiyor.
                      DragTarget<String>(
                        onWillAcceptWithDetails: (_) {
                          if (!_snapped) setState(() => _hovering = true);
                          return !_snapped;
                        },
                        onLeave: (_) => setState(() => _hovering = false),
                        onAcceptWithDetails: (_) => _onAccepted(),
                        builder: (context, candidate, rejected) {
                          if (_snapped) {
                            return AnimatedBuilder(
                              animation: _celebrate,
                              builder: (context, child) {
                                final t = Curves.elasticOut
                                    .transform(_celebrate.value.clamp(0, 1));
                                return Transform.scale(
                                  scale: 1 + 0.10 * (1 - (1 - t).abs()),
                                  child: child,
                                );
                              },
                              child: moveBlok(),
                            );
                          }
                          // Yuva, oturacak bloğun TAM ölçüsünde.
                          //
                          // Sabit bir genişlik yazmak yerine bloğun
                          // görünmez bir kopyası ölçüyü veriyor:
                          // yazı değişince (dil, uzun etiket) yuva
                          // da kendiliğinden uyuyor. Sabit 176 px
                          // yazdığımızda yuva bloktan geniş kalıyor
                          // ve "buraya bu oturur" hissi bozuluyor.
                          return AnimatedScale(
                            scale: _hovering ? 1.04 : 1.0,
                            duration: Motion.short2,
                            curve: Curves.easeOut,
                            // Scratch'in bırakma önizlemesi gibi: bloğun
                            // gri, yarı saydam gölgesi.
                            child: Opacity(
                              opacity: _hovering ? 0.55 : 0.3,
                              child: ColorFiltered(
                                colorFilter: const ColorFilter.matrix([
                                  0, 0, 0, 0, 110, //
                                  0, 0, 0, 0, 110, //
                                  0, 0, 0, 0, 110, //
                                  0, 0, 0, 1, 0,
                                ]),
                                child: moveBlok(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // --- sürüklenecek blok ---
                if (!_snapped)
                  Positioned(
                    bottom: 0,
                    child: _DragHint(
                      accent: widget.accent,
                      child: Draggable<String>(
                        data: 'move',
                        dragAnchorStrategy: pointerDragAnchorStrategy,
                        feedback: Transform.translate(
                          offset: Offset(-moveW / 2, -moveH / 2),
                          child: Material(
                            color: Colors.transparent,
                            child: Transform.scale(
                              scale: 1.06,
                              child: moveBlok(),
                            ),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.25,
                          child: moveBlok(),
                        ),
                        onDraggableCanceled: (_, __) => _onMissed(),
                        child: moveBlok(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Sürüklenecek bloğun altında yukarı doğru süzülen küçük bir el.
///
/// codeSpark'ın tamamen yazısız arayüzü hakkında yazılan eleştiri şu:
/// çocuk bir yerde takılırsa hiçbir şey ona ne yapacağını söylemiyor ve
/// bu doğrudan hüsrana dönüyor. Burada yazı da var, gösterim de: ne
/// yapılacağı cümleyle söyleniyor, ELLE de gösteriliyor.
class _DragHint extends StatefulWidget {
  const _DragHint({required this.child, required this.accent});

  final Widget child;
  final Color accent;

  @override
  State<_DragHint> createState() => _DragHintState();
}

class _DragHintState extends State<_DragHint>
    with SingleTickerProviderStateMixin {
  // Bkz. _FirstTaskState._celebrate: denetleyici initState'te kuruluyor.
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Klavye açıkken el işareti de duruyor: bkz. mascot.dart. Süsleme
    // animasyonları, kullanıcı yazarken frame bütçesini paylaşmamalı.
    final typing = MediaQuery.viewInsetsOf(context).bottom > 0;
    if (Motion.reduced(context) || typing) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Motion.reduced(context)) return widget.child;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        widget.child,
        Positioned(
          right: -6,
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              // 0 -> 1 boyunca yukarı süzülüyor, sonda soluyor.
              final t = _c.value;
              final rise = Curves.easeInOut.transform(t);
              final fade = t < 0.15
                  ? t / 0.15
                  : t > 0.75
                      ? (1 - t) / 0.25
                      : 1.0;
              return Transform.translate(
                offset: Offset(0, 26 - rise * 62),
                child: Opacity(
                  opacity: fade.clamp(0.0, 1.0),
                  child: Icon(
                    Icons.touch_app_rounded,
                    size: 30,
                    color: widget.accent.withValues(alpha: 0.85),
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
