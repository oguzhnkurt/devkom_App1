import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../ui/motion.dart';

/// Akistaki tek bir adim — bilgi ya da soru.
///
/// Onceden yalnizca tanitim sayfalarini tasiyordu; sorular ayri bir
/// ekrandaydi ve tamamen baska bir gorunume geciyordu (beyaz zemin,
/// baska tipografi, baska ilerleme cubugu). Kullanici acisindan bu, iki
/// farkli uygulamaya girmek gibiydi.
///
/// Artik ikisi de ayni adim tipini kullaniyor: [subtitle] doluysa bilgi
/// sayfasi, [body] doluysa soru sayfasi. Ust panel, tipografi, ilerleme
/// noktalari ve gezinme tuslari her ikisinde de ayni.
class IntroSlide {
  const IntroSlide({
    required this.eyebrow,
    required this.title,
    required this.accent,
    this.subtitle,
    this.art,
    this.body,
    this.canAdvance,
  });

  /// Basligin ustundeki kucuk, buyuk harfli etiket.
  final String eyebrow;

  /// Iki satirlik ana baslik. Kelime kelime beliriyor.
  final String title;

  /// Bilgi sayfasinin aciklama metni.
  final String? subtitle;

  /// Sayfanin rengi. Ust paneldeki gecis ve ilerleme noktalari bundan.
  final Color accent;

  /// Ust paneldeki gorsel.
  final Widget? art;

  /// Soru sayfasinin govdesi (secenekler, metin kutusu ...).
  final Widget? body;

  /// Ileri tusu simdi basilabilir mi? Cevapsiz bir soruyu gecmeyi
  /// engellemek icin.
  final bool Function()? canAdvance;

  bool get isQuestion => body != null;
}

/// Ilk acilis tanitim karuseli.
///
/// YAPI (yukaridan asagi):
///
///  * Ekranin ust ~%52'si: alt koseleri yuvarlatilmis, acik tonda
///    baslayip koyulasan bir renk paneli ve icinde gorsel.
///  * Altta beyaz zemin: kucuk buyuk harfli etiket, iki satirlik kalin
///    baslik, gri alt yazi.
///  * En altta gezinme: gri geri dairesi, birbirine cizgiyle bagli
///    ilerleme noktalari, koyu ileri dairesi.
///
/// HAREKET — bu ekranin butun karakteri burada:
///
///  * Baslik KELIME KELIME beliriyor. Her kelime once soluk gri, sonra
///    koyu; aralarinda ~70 ms var. Butun satirin birden gelmesi
///    "yuklendi" hissi veriyor, kelime kelime gelmesi "anlatiliyor"
///    hissi veriyor — ayni metin, farkli algi.
///  * Gorsel hafifce buyuyerek ve yukselerek giriyor.
///  * Alt yazi baslik bittikten sonra geliyor.
///  * Dairelere basildiginda etrafinda gri bir halka aciliyor.
///
/// Hepsi "hareketi azalt" ayarina saygili: acikken her sey yerinde,
/// tam gorunur duruyor.
class IntroCarousel extends StatefulWidget {
  const IntroCarousel({
    super.key,
    required this.slides,
    required this.onFinish,
    this.trailing,
  });

  final List<IntroSlide> slides;

  /// Son sayfada ileri tusuna basilinca.
  final VoidCallback onFinish;

  /// Sag ustte gosterilecek ek widget (dil secici gibi).
  final Widget? trailing;

  @override
  State<IntroCarousel> createState() => IntroCarouselState();
}

class IntroCarouselState extends State<IntroCarousel> {
  int _index = 0;

  /// Son gecisin yonu: ileri +1, geri -1.
  ///
  /// Gecis animasyonu buna gore calisiyor — ileri giderken icerik
  /// sagdan gelip sola cikiyor, geri gelirken tersi. Yonsuz bir
  /// solma "bir sey degisti" der; yonlu bir kayma "nerede oldugunu"
  /// da soyler.
  int _dir = 1;

  void _go(int next) {
    if (next < 0) return;
    if (next >= widget.slides.length) {
      widget.onFinish();
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _dir = next > _index ? 1 : -1;
      _index = next;
    });
  }

  /// Yatay kaydirmayla gezinme.
  ///
  /// Cocuk once kaydirmayi deniyor; tusa basmak ikinci refleks. Ileri
  /// kaydirma yalnizca [_canAdvance] ise calisiyor, boylece cevapsiz
  /// bir soru kaydirilarak da atlanamiyor.
  void _onSwipe(DragEndDetails d) {
    final v = d.primaryVelocity ?? 0;
    if (v.abs() < 220) return;
    if (v < 0) {
      if (_canAdvance) _go(_index + 1);
    } else {
      _go(_index - 1);
    }
  }

  bool get _canAdvance => widget.slides[_index].canAdvance?.call() ?? true;

  /// Disaridan bir sonraki adima gecirir.
  ///
  /// Bir secenege dokununca otomatik ilerlemek icin: cocuk icin iki
  /// dokunus yerine bir. Ilerleyecek durumda degilse hicbir sey yapmaz.
  void advance() {
    if (_canAdvance) _go(_index + 1);
  }

  @override
  Widget build(BuildContext context) {
    final slide = widget.slides[_index];
    final size = MediaQuery.of(context).size;

    // Panel yuksekligi adimin turune gore.
    //
    // Soru sayfalarinda panel kuculuyor: seceneklerin yeri lazim. Ama
    // KAYBOLMUYOR — panelin varligi ve rengi, sorularin da ayni akisin
    // parcasi oldugunu soyleyen sey.
    final ratio = slide.isQuestion
        ? (size.height < 700 ? 0.20 : 0.24)
        : (size.height < 700 ? 0.42 : 0.48);
    final panelHeight =
        (size.height * ratio).clamp(slide.isQuestion ? 150.0 : 260.0, 460.0);

    return Scaffold(
      backgroundColor: Colors.white,
      // Klavye acilinca soru sayfasi yeniden olculmesin; panel zipliyordu.
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: _onSwipe,
        child: Column(
          children: [
            _panel(slide, panelHeight),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  children: [
                    Expanded(
                      // AnimatedSwitcher DEGIL: gecis boyunca iki kopya
                      // birden agacta olurdu ve soru sayfasindaki
                      // TextField ayni controller'a iki kez baglanirdi.
                      // _PageSwap her an tek bir icerik tutuyor.
                      child: _PageSwap(
                        index: _index,
                        direction: _dir,
                        child: _SlideText(
                          key: ValueKey(_index),
                          slide: slide,
                        ),
                      ),
                    ),
                    _nav(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _panel(IntroSlide slide, double height) {
    // ÜST PANEL BİR BÜTÜN OLARAK KENDİ KATMANINDA.
    //
    // Panelde iki sürekli animasyon var (bloblar ve süzülen simge) artı
    // gradyan, ClipRRect ve gölgeler. Alttaki gövde her tuş vuruşunda
    // yeniden çizilirken panelin de yeniden rasterlenmesi için hiçbir
    // sebep yok.
    return RepaintBoundary(
      child: SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedContainer(
            duration: Motion.long2,
            curve: Motion.emphasized,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(34),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.alphaBlend(
                    slide.accent.withValues(alpha: 0.10),
                    Colors.white,
                  ),
                  Color.alphaBlend(
                    slide.accent.withValues(alpha: 0.34),
                    Colors.white,
                  ),
                ],
              ),
            ),
          ),
          // Blob animasyonu KENDİ KATMANINDA.
          //
          // Bu, saniyede 60 kez çizilen tam panel boyunda bir
          // CustomPaint. Sınır konmadığında üstündeki başlık, metin ve
          // gölgeler de her karede yeniden rasterleniyordu.
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(34),
            ),
            child: RepaintBoundary(child: _PanelDrift(color: slide.accent)),
          ),
          if (slide.art != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(34),
              ),
              child: _PageSwap(
                index: _index,
                direction: _dir,
                child: _ArtEntrance(
                  key: ValueKey('art$_index'),
                  child: slide.art!,
                ),
              ),
            ),
          if (widget.trailing != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 16,
              child: widget.trailing!,
            ),
        ],
      ),
      ),
    );
  }

  Widget _nav() {
    final isLast = _index == widget.slides.length - 1;
    return Padding(
      padding: EdgeInsets.only(
        bottom: 16 + MediaQuery.of(context).padding.bottom * 0.4,
        top: 8,
      ),
      child: Row(
        children: [
          _CircleNav(
            icon: Icons.arrow_back_rounded,
            onTap: _index == 0 ? null : () => _go(_index - 1),
            background: const Color(0xFFEDEFF2),
            foreground: AppTheme.darkGray,
          ),
          Expanded(
            child: Center(
              child: _ProgressTrail(
                count: widget.slides.length,
                index: _index,
                color: widget.slides[_index].accent,
              ),
            ),
          ),
          _CircleNav(
            icon: isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
            // Cevaplanmamis bir soruyu gecmek yok. Tus kayboluyor degil,
            // sonuyor: cocuk ilerlemek icin ne yapmasi gerektigini
            // gorunen ama basilamayan bir tustan anliyor.
            onTap: _canAdvance ? () => _go(_index + 1) : null,
            background: widget.slides[_index].accent,
            foreground: Colors.white,
          ),
        ],
      ),
    );
  }
}

/// Etiket + baslik + alt yazi, sirayla gelen hâliyle.
class _SlideText extends StatelessWidget {
  const _SlideText({super.key, required this.slide});

  final IntroSlide slide;

  @override
  Widget build(BuildContext context) {
    final wordCount = slide.title.replaceAll('\n', ' ').split(' ').length;
    // Baslik bittikten sonra alt yazi/govde gelsin.
    final afterTitle = Duration(milliseconds: 120 + wordCount * 70 + 120);

    final head = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _FadeIn(
          delay: const Duration(milliseconds: 40),
          child: Text(
            slide.eyebrow.toUpperCase(),
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
              color: slide.accent,
            ),
          ),
        ),
        const SizedBox(height: 10),
        _WordReveal(
          text: slide.title,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            // Soru basliklari biraz daha kucuk: altlarinda secenekler var.
            fontSize: slide.isQuestion ? 23 : 27,
            height: 1.22,
            fontWeight: FontWeight.w800,
            color: AppTheme.darkGray,
          ),
        ),
      ],
    );

    // BILGI SAYFASI — baslik ortada, altinda tek satirlik aciklama.
    if (!slide.isQuestion) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          head,
          if (slide.subtitle != null) ...[
            const SizedBox(height: 12),
            _FadeIn(
              delay: afterTitle,
              child: Text(
                slide.subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13.5,
                  height: 1.45,
                  color: AppTheme.mediumGray,
                ),
              ),
            ),
          ],
        ],
      );
    }

    // SORU SAYFASI — ayni baslik, altinda secenekler.
    //
    // Secenekler kaydirilabilir olmak zorunda: dort yas araligi ya da
    // dort hedef, kucuk bir telefonda ekrana sigmiyor. Baslik yukarida
    // sabit kaliyor, sadece secenekler kayiyor.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        head,
        if (slide.subtitle != null) ...[
          const SizedBox(height: 8),
          _FadeIn(
            delay: afterTitle,
            child: Text(
              slide.subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 13,
                height: 1.4,
                color: AppTheme.mediumGray,
              ),
            ),
          ),
        ],
        const SizedBox(height: 18),
        // Kısa içerik ORTALANIYOR, uzun içerik kayıyor.
        //
        // Önceden gövde doğrudan bir kaydırma görünümündeydi: ilk görev
        // gibi kısa bir içerik yukarı yapışıyor, altında yarım ekran boş
        // kalıyordu — ekran bitmemiş gibi duruyordu. minHeight kadar
        // yükseklik verip ortalayınca kısa içerik ekranın ortasına
        // oturuyor, klavye açıldığında ya da metin uzadığında kaydırma
        // yine çalışıyor.
        Expanded(
          child: _FadeIn(
            delay: afterTitle,
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(child: slide.body),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Basligi kelime kelime getiren yazi.
///
/// Her kelime once soluk gri, sonra tam koyulukta; aralarinda kisa bir
/// gecikme var. Tek bir `TweenAnimationBuilder` ile yapiliyor: kelime
/// basina denetleyici acmak uzun basliklarda pahali olurdu.
///
/// SATIR SONLARI KORUNUYOR. Ilk surum butun basligi bosluklardan bolup
/// tek bir `Wrap` icine koyuyordu; bu, metindeki `\n` karakterlerini
/// yok sayiyor ve "Kod yazmayı / sıfırdan öğren" basligi ekranda
/// "Kod  yazmayı  öğren / sıfırdan" olarak kiriliyordu — kelimeler
/// dogru, satirlar tamamen yanlis. Artik once satirlara, sonra her
/// satir kendi icinde kelimelere bolunuyor.
class _WordReveal extends StatelessWidget {
  const _WordReveal({
    required this.text,
    required this.style,
  });

  final String text;
  final TextStyle style;

  /// Kelimeler arasindaki gecikme.
  static const int stepMs = 70;

  @override
  Widget build(BuildContext context) {
    if (Motion.reduced(context)) {
      return Text(text, textAlign: TextAlign.center, style: style);
    }

    final lines = text.split('\n');
    final wordCount = lines.fold<int>(0, (a, l) => a + l.split(' ').length);
    final total = Duration(milliseconds: 240 + wordCount * stepMs);

    return TweenAnimationBuilder<double>(
      key: ValueKey(text),
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Curves.linear,
      builder: (context, t, _) {
        final elapsed = total.inMilliseconds * t;
        var index = 0;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final line in lines)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final word in line.split(' '))
                    Flexible(
                      child: _word(word, elapsed - (index++) * stepMs),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _word(String word, double localMs) {
    // 240 ms'lik kendi gecisi: soluk griden tam renge.
    final p = (localMs / 240).clamp(0.0, 1.0);
    final eased = Curves.easeOutCubic.transform(p);

    // SOLUKLUK RENGIN ALFASINDA, Opacity WIDGET'INDA DEGIL.
    //
    // Onceden her kelime bir `Opacity` icindeydi. Opacity, cocugu
    // olmayan en kucuk widget'ta bile katman actiriyor (saveLayer):
    // alti kelimelik bir baslik, animasyonun her karesinde alti ayri
    // offscreen katman demekti. Basligin belirmesi bu yuzden
    // takiliyordu. Metnin ustuste binen parcasi olmadigi icin
    // alfayi dogrudan renge koymak GORSEL OLARAK AYNI sonucu
    // veriyor, ama hicbir katman acmiyor.
    final renk = Color.lerp(
      const Color(0xFFC9CDD3),
      style.color ?? AppTheme.darkGray,
      eased,
    )!
        .withValues(alpha: (0.25 + 0.75 * eased).clamp(0.0, 1.0));

    return Transform.translate(
      offset: Offset(0, (1 - eased) * 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3.5),
        child: Text(
          word,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.visible,
          style: style.copyWith(color: renk),
        ),
      ),
    );
  }
}

/// Gorseli hafifce buyuterek ve yukselterek getirir.
class _ArtEntrance extends StatelessWidget {
  const _ArtEntrance({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (Motion.reduced(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Motion.extraLong2,
      curve: Motion.emphasizedDecelerate,
      builder: (context, t, c) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 26),
          child: Transform.scale(scale: 0.94 + 0.06 * t, child: c),
        ),
      ),
      // Gorseller CustomPaint; sinir olmadan giris animasyonunun her
      // karesinde yeniden ciziliyorlardi.
      child: RepaintBoundary(child: child),
    );
  }
}

class _FadeIn extends StatelessWidget {
  const _FadeIn({required this.child, required this.delay});

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    if (Motion.reduced(context)) return child;
    const fade = Duration(milliseconds: 320);
    final total = fade + delay;
    final start = (delay.inMilliseconds / total.inMilliseconds).clamp(0.0, 0.9);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(start, 1, curve: Curves.easeOut),
      builder: (context, t, c) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, (1 - t) * 8), child: c),
      ),
      child: child,
    );
  }
}

/// Birbirine cizgiyle bagli ilerleme noktalari.
///
/// Klasik nokta sirasindan farki, noktalarin bir YOL uzerinde durmasi:
/// gecilenler dolu, siradaki buyuk ve renkli, ilerideler soluk. Bir
/// dizi ayri nokta "kac sayfa var" der; bagli olanlar "neredesin" der.
class _ProgressTrail extends StatelessWidget {
  const _ProgressTrail({
    required this.count,
    required this.index,
    required this.color,
  });

  final int count;
  final int index;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 26,
      width: count * 22.0,
      child: CustomPaint(
        painter: _TrailPainter(count: count, index: index, color: color),
      ),
    );
  }
}

class _TrailPainter extends CustomPainter {
  _TrailPainter({
    required this.count,
    required this.index,
    required this.color,
  });

  final int count;
  final int index;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (count < 2) return;
    final step = size.width / count;
    final cy = size.height / 2;

    Offset at(int i) {
      // Noktalar duz bir cizgide degil, hafif dalgali: yol hissi.
      final dy = math.sin(i * 1.1) * 3.2;
      return Offset(step * (i + 0.5), cy + dy);
    }

    final line = Paint()
      ..color = const Color(0xFFDFE3E8)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final done = Paint()
      ..color = color
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < count - 1; i++) {
      canvas.drawLine(at(i), at(i + 1), i < index ? done : line);
    }

    for (var i = 0; i < count; i++) {
      final p = at(i);
      if (i < index) {
        canvas.drawCircle(p, 4.2, Paint()..color = color);
      } else if (i == index) {
        canvas.drawCircle(p, 7, Paint()..color = color);
        canvas.drawCircle(p, 3, Paint()..color = Colors.white);
      } else {
        canvas.drawCircle(p, 4.2, Paint()..color = const Color(0xFFDFE3E8));
      }
    }
  }

  @override
  bool shouldRepaint(_TrailPainter old) =>
      old.index != index || old.count != count || old.color != color;
}

/// Alttaki yuvarlak gezinme tusu.
///
/// Her zaman DAIRE. Once son sayfada etiketli bir hap oluyordu ve bu
/// bir yerlesim hatasi doguruyordu: bir satirdaki esnek olmayan cocuk
/// sinirsiz genislikle olculur, genisligi verilmemis hap da sonsuza
/// uzanip satiri tasirdi. Ayrica gerek de yoktu — son sayfada oldugunu
/// ilerleme noktalari zaten soyluyor, tusun ikonu da oka degil onaya
/// donuyor.
///
/// Basildiginda etrafinda gri bir halka aciliyor: dokunusun islendigini
/// gosteren en hizli geri bildirim.
class _CircleNav extends StatefulWidget {
  const _CircleNav({
    required this.icon,
    required this.onTap,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color background;
  final Color foreground;

  @override
  State<_CircleNav> createState() => _CircleNavState();
}

class _CircleNavState extends State<_CircleNav> {
  bool _down = false;

  static const double _size = 54;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: disabled ? null : (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: SizedBox(
        width: _size + 22,
        height: _size + 22,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_down && !Motion.reduced(context))
              TweenAnimationBuilder<double>(
                key: const ValueKey('ring'),
                tween: Tween(begin: 0, end: 1),
                duration: Motion.medium2,
                curve: Curves.easeOut,
                builder: (context, t, _) => Container(
                  width: _size + 22 * t,
                  height: _size + 22 * t,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.mediumGray
                        .withValues(alpha: 0.20 * (1 - t) + 0.06),
                  ),
                ),
              ),
            AnimatedContainer(
              duration: Motion.short3,
              curve: Motion.emphasized,
              width: _size,
              height: _size,
              decoration: BoxDecoration(
                color: disabled
                    ? widget.background.withValues(alpha: 0.45)
                    : widget.background,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                widget.icon,
                color: disabled
                    ? widget.foreground.withValues(alpha: 0.45)
                    : widget.foreground,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sayfa degisince icerigi yonlu bir kaymayla degistirir.
///
/// Neden AnimatedSwitcher degil: AnimatedSwitcher gecis boyunca eski ve
/// yeni cocugu ayni anda agacta tutuyor. Soru sayfalarinin govdesinde
/// bir TextField ve ona bagli tek bir TextEditingController var; iki
/// kopya birden var olunca ayni controller iki alana baglaniyor ve
/// imlec/secim davranisi bozuluyor. Burada her an TEK bir icerik var:
/// animasyonun ilk yarisinda eski icerik cikiyor, tam ortada icerik
/// degisiyor, ikinci yarisinda yeni icerik giriyor.
class _PageSwap extends StatefulWidget {
  const _PageSwap({
    required this.index,
    required this.direction,
    required this.child,
  });

  /// Hangi adimdayiz. Degisince gecis basliyor.
  final int index;

  /// Gecis yonu: ileri +1, geri -1.
  final int direction;

  final Widget child;

  @override
  State<_PageSwap> createState() => _PageSwapState();
}

class _PageSwapState extends State<_PageSwap>
    with SingleTickerProviderStateMixin {
  // NOT: `late final ... = AnimationController(...)` DEGIL.
  // Hareket azaltilmisken build erken donuyor ve denetleyiciye hic
  // dokunulmuyordu; sonra dispose() ona ilk kez erisince denetleyici
  // TAM DA agactan cikarilirken kuruluyor ve TickerMode aramasi
  // "Looking up a deactivated widget's ancestor is unsafe" ile
  // patliyordu. initState'te kurunca boyle bir an olmuyor.
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: Motion.long2);
  }

  /// Gecisin ilk yarisinda gosterilen, bir onceki adimin icerigi.
  Widget? _outgoing;

  @override
  void didUpdateWidget(covariant _PageSwap old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) {
      _outgoing = old.child;
      _c.forward(from: 0);
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

    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        if (t == 0 || t == 1) return widget.child;

        final leaving = t < 0.5;
        // 0 -> 1 arasi iki yariyi kendi icinde 0 -> 1'e aciyoruz.
        final half = leaving ? t * 2 : (t - 0.5) * 2;
        final eased = Curves.easeOut.transform(half);

        // Cikan icerik ters yone kayiyor, giren icerik ayni yonden geliyor.
        final dx = leaving
            ? -widget.direction * 26.0 * eased
            : widget.direction * 26.0 * (1 - eased);
        final opacity = leaving ? 1 - eased : eased;

        // RepaintBoundary ONEMLI: Opacity butun sayfa icerigini
        // (baslik, gorsel, secenek listesi) kapsiyor. Sinir olmadan bu
        // agac gecisin HER karesinde bastan boyaniyordu; sinirla bir
        // kez rasterlenip hazir katman olarak soluyor.
        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(dx, 0),
            child: RepaintBoundary(
              child: leaving ? (_outgoing ?? widget.child) : widget.child,
            ),
          ),
        );
      },
    );
  }
}

/// Panelin arkasinda cok yavas suzulen yumusak sekiller.
///
/// Panel duz bir renk gecisiydi ve sabit duruyordu. Burada dort
/// yumusak daire, ekranin renginde ama cok soluk, farkli hizlarda
/// suzuluyor: ekran "canli" ama hicbir sey dikkat calmiyor — cocuk
/// hala basligi okuyor. Sabit bir tohum kullaniliyor, yani her acilista
/// ayni duzen. "Hareketi azalt" acikken hic cizilmiyor.
class _PanelDrift extends StatefulWidget {
  const _PanelDrift({required this.color});

  final Color color;

  @override
  State<_PanelDrift> createState() => _PanelDriftState();
}

class _PanelDriftState extends State<_PanelDrift>
    with SingleTickerProviderStateMixin {
  // Bkz. _PageSwapState: denetleyici initState'te kuruluyor.
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 26),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Hareket azaltilmisken tik bile atmiyor: hem pil, hem de surekli
    // donen bir denetleyici agacin hicbir zaman "durulmamasi" demek.
    //
    // KLAVYE ACIKKEN DE DURUYOR. Kullanici takma adini duzenlerken her
    // tusa basista metin alani yeniden ciziliyor; arka planda saniyede
    // 60 kez donen bir animasyon varken bu, yazmanin takilmasi olarak
    // hissediliyor. Susleme, isin onune gecmemeli.
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
    if (Motion.reduced(context)) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => CustomPaint(
        painter: _DriftPainter(t: _c.value, color: widget.color),
        size: Size.infinite,
      ),
    );
  }
}

class _DriftPainter extends CustomPainter {
  _DriftPainter({required this.t, required this.color});

  final double t;
  final Color color;

  /// (baslangic x, baslangic y, yaricap, hiz) — sabit, rastgele degil:
  /// duzen her acilista ayni olsun.
  static const List<(double, double, double, double)> _blobs = [
    (0.18, 0.30, 0.30, 1.0),
    (0.78, 0.22, 0.22, -0.7),
    (0.62, 0.74, 0.26, 0.55),
    (0.30, 0.82, 0.18, -1.15),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < _blobs.length; i++) {
      final (bx, by, br, speed) = _blobs[i];
      final phase = (t * speed + i * 0.27) * 2 * math.pi;
      final dx = math.cos(phase) * size.width * 0.06;
      final dy = math.sin(phase * 0.8) * size.height * 0.07;
      paint.color = color.withValues(alpha: i.isEven ? 0.10 : 0.07);
      canvas.drawCircle(
        Offset(bx * size.width + dx, by * size.height + dy),
        br * size.shortestSide,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DriftPainter old) =>
      old.t != t || old.color != color;
}
