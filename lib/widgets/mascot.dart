import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../ui/motion.dart';
import 'mascot_mood.dart';
import 'mascot_species.dart';

export 'mascot_mood.dart';
export 'mascot_species.dart' show MascotSpecies, MascotAnchors, MascotSpec, mascotSpecs, specOf;

/// Uygulamanın maskotu: **Devi**.
///
/// NEDEN TEK BİR KARAKTER
/// ----------------------
/// Uygulamada şimdiye kadar maskot diye bir şey yoktu: her ekran başka bir
/// emoji gösteriyordu (🤖 burada, 🧩 şurada, 🐱 öbür derste). Çocuk için
/// bu, uygulamanın bir "kimse"si olmaması demek. Devi, uygulamanın her
/// yerinde aynı: karşılamada, derste, sonuç ekranında, mağazada.
///
/// Adı "dev" kelimesinden geliyor — hem "developer" hem Türkçede "dev"
/// (kocaman). Ufak tefek, dost canlısı bir dev.
///
/// TASARIM KURALLARI (araştırmaya dayalı, keyfi değil)
/// ---------------------------------------------------
/// * **Neşe ağızda, endişe kaşlarda.** Karikatür yüzlerde duygu tanıma
///   çalışması (Tsinghua, Frontiers in Psychology 2021): mutluluk yalnızca
///   ağızdan %96 doğrulukla tanınıyor (tam yüzde %97), ağız gizlenince
///   %28'e düşüyor. Üzüntüyü ise kaşlar taşıyor. Bu yüzden küçük boyutta
///   ilk feda edilecek şey gözler değil, detaylar; ağız eğrisi ve kaş
///   açısı her boyutta okunur kalıyor.
/// * **Silüet önce.** Duolingo'nun Duo'yu yeniden tasarlarken yazdığı
///   şey: genel şekil çalışmıyorsa içindeki detaylar onu kurtaramaz.
///   Devi'nin silüeti tek bir yuvarlak kafa + iki anten; 28 punto ile
///   200 punto arasında aynı okunuyor.
/// * **Sessiz varsayılan.** Sürekli oynayan bir maskot içerikle dikkat
///   için yarışıyor (Frontiers 2025, n=112: sadece ajan koymak bilgi
///   aktarımını DÜŞÜRÜYOR, geri bildirimi inceleme süresini 443 sn'den
///   ~170 sn'ye indiriyor). Devi bu yüzden fon süsü değil: çocuk bir şey
///   YAPTIĞINDA tepki veriyor.
/// * **Suçluluk yok.** [MascotMood]'da üzgün ya da küsmüş bir hâl
///   bilerek YOK. Duolingo'nun kendi A/B testi, koçun "gelişim
///   zihniyeti" diliyle konuşmasının standart övgüye göre D14 tutmayı
///   %7,2 artırdığını gösteriyor; suçluluk temelli maskot davranışının
///   öğrenmeye yaradığına dair yayımlanmış bir kanıt ise yok. Ayrıca ICO
///   Çocuklara Uygun Tasarım Kuralları'nın 5. maddesi (çocuğun iyilik
///   hâline zarar veren veri kullanımı) ve 13. maddesi (dürtme
///   teknikleri) bu tarafa bakıyor.
class Mascot extends StatefulWidget {
  const Mascot({
    super.key,
    this.species,
    this.mood = MascotMood.idle,
    this.size = 96,
    this.color,
    this.onTap,
    this.showShadow = true,
    this.hat,
    this.glasses,
    this.necklace,
    this.shoes,
    this.chestEmoji,
  });

  /// Hangi karakter.
  ///
  /// VERİLMEZSE çocuğun seçtiği karakter kullanılıyor. Uygulamada
  /// maskot düzinelerce yerde çiziliyor; tür her çağrıya elle
  /// yazılsaydı biri unutulur ve çocuk bir ekranda Mia'yı, diğerinde
  /// Puf'u görürdü. Tek yerden okumak bunu imkânsız kılıyor.
  ///
  /// Yalnızca SEÇİCİ gibi belirli bir karakteri göstermesi gereken
  /// yerlerde elle veriliyor.
  final MascotSpecies? species;

  final MascotMood mood;
  final double size;

  /// Mağazadan alınan ekipmanlar. Emoji olarak veriliyor ve Devi'nin
  /// gerçek geometrisine (bkz. [MascotAnchors]) göre yerleşiyor.
  ///
  /// Bunlar Devi'nin ÜSTÜNE giyiliyor — ayrı bir figüre değil. Mağaza
  /// planı maskot üzerinden yürüdüğü için ikisinin tek bir karakter
  /// olması şart: eskiden maskot ve giydirilen figür iki ayrı çizimdi,
  /// yani çocuğun aldığı şapka maskotun kafasına hiç oturmuyordu.
  final String? hat;
  final String? glasses;
  final String? necklace;
  final String? shoes;

  /// Göğüsteki küçük ekranda görünen simge.
  ///
  /// Mağazadaki "karakter" ürünleri (muz, robot, kedi...) artık Devi'nin
  /// YERİNE geçmiyor — Devi'nin rengini değiştiriyor ve simgeleri onun
  /// göğüs ekranında görünüyor. Böylece hem ürünler kimliğini koruyor
  /// hem de uygulamanın tek bir maskotu oluyor.
  final String? chestEmoji;

  /// Gövde rengi. Ekranın vurgu rengini verirseniz maskot o sayfaya
  /// ait gibi durur; vermezseniz karakterin kendi rengi kullanılıyor.
  final Color? color;

  /// Dokununca. Verilirse Devi dokunmaya küçük bir zıplamayla cevap
  /// veriyor — çocuk için "bu canlı" sinyali.
  final VoidCallback? onTap;

  final bool showShadow;

  /// Karakterin adı. Metinlerde geçtiği için tek yerden okunuyor.
  static String nameOf(MascotSpecies s) => specOf(s).name;

  /// Açılıştaki karakter.
  static const MascotSpecies defaultSpecies = MascotSpecies.puf;

  @override
  State<Mascot> createState() => _MascotState();
}

class _MascotState extends State<Mascot> with TickerProviderStateMixin {
  /// Nefes alma / zıplama.
  late final AnimationController _idle;

  /// Dokunma tepkisi.
  late final AnimationController _poke;

  /// Göz kırpma.
  ///
  /// NOT: burada zamanlayıcı YOK. Önceki sürüm `Future.delayed` ile kendini
  /// tekrar çağırıyordu; bu zincir hiç bitmediği için Devi'yi içeren her
  /// widget testi `pumpAndSettle`da ya da teardown'da takılıyordu. Kırpma
  /// artık nefes denetleyicisinin fazından türetiliyor — ek bir zamanlayıcı
  /// da, bitmeyen bir gelecek de yok.
  late final AnimationController _blink;

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(vsync: this, duration: _idleDuration);
    _poke = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _idle.addListener(_maybeBlink);
  }

  /// Nefesin bir turu tamamlanınca göz kırp.
  ///
  /// Her turda değil: `_blinkEvery` turda bir. Sabit ritim mekanik
  /// duruyor, bu yüzden sayaç tek sayılarda da kırpıyor.
  static const int _blinkEvery = 2;
  int _breathCycles = 0;
  bool _wasHigh = false;

  void _maybeBlink() {
    final high = _idle.value > 0.92;
    if (high && !_wasHigh) {
      _breathCycles++;
      if (_breathCycles % _blinkEvery == 0 &&
          widget.mood != MascotMood.happy &&
          widget.mood != MascotMood.cheering &&
          !_blink.isAnimating) {
        _blink.forward(from: 0).then((_) {
          if (mounted) _blink.reverse();
        });
      }
    }
    _wasHigh = high;
  }

  Duration get _idleDuration => switch (widget.mood) {
        MascotMood.cheering => const Duration(milliseconds: 520),
        MascotMood.happy => const Duration(milliseconds: 900),
        _ => const Duration(milliseconds: 2400),
      };

  @override
  void didUpdateWidget(covariant Mascot old) {
    super.didUpdateWidget(old);
    if (old.mood != widget.mood) {
      _idle.duration = _idleDuration;
      _applyMotion();
      // Yeni bir duruma geçmek küçük bir zıplama: geçiş fark edilsin.
      if (!Motion.reduced(context)) _poke.forward(from: 0);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _applyMotion();
  }

  void _applyMotion() {
    // Klavye açıkken nefes alma DURUYOR.
    //
    // Kullanıcı yazarken her tuşta metin alanı yeniden çiziliyor;
    // arkada saniyede 60 kez dönen bir animasyon varken bu, yazmanın
    // takılması olarak hissediliyor. Takma ad düzenleme alt sayfası
    // tam olarak böyle bir yer: sayfa altta kalıyor, Devi nefes almaya
    // devam ediyor, çocuk adını düzenlemeye çalışıyor.
    //
    // Nefes almanın durduğu fark edilmiyor; takılma ediliyor.
    final typing = MediaQuery.viewInsetsOf(context).bottom > 0;
    if (Motion.reduced(context) || typing) {
      _idle.stop();
      _blink.stop();
      return;
    }
    if (!_idle.isAnimating) _idle.repeat(reverse: true);
  }

  @override
  void dispose() {
    _idle.removeListener(_maybeBlink);
    _idle.dispose();
    _poke.dispose();
    _blink.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onTap == null) return;
    if (!Motion.reduced(context)) _poke.forward(from: 0);
    widget.onTap!();
  }

  /// Çizilecek tür: elle verildiyse o, verilmediyse çocuğun seçimi.
  ///
  /// SettingsProvider bulunmayan bir ağaçta (bazı widget testleri)
  /// çağrılabildiği için erişim korumalı: sağlayıcı yoksa açılıştaki
  /// karaktere düşüyoruz, ekran boş kalmıyor.
  MascotSpecies get _species {
    if (widget.species != null) return widget.species!;
    try {
      return context.watch<SettingsProvider>().mascot;
    } on ProviderNotFoundException {
      return Mascot.defaultSpecies;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduced = Motion.reduced(context);

    return Semantics(
      label: '${Mascot.nameOf(_species)} — ${_moodLabel(widget.mood)}',
      button: widget.onTap != null,
      child: GestureDetector(
        onTap: widget.onTap == null ? null : _handleTap,
        behavior: HitTestBehavior.opaque,
        // KENDİ KATMANINDA ÇİZİLİYOR.
        //
        // Devi hiç durmadan nefes alıyor. Sınır konmadığında bu, her
        // karede Devi'nin BULUNDUĞU KATMANIN TAMAMININ yeniden
        // çizilmesi demek — profil ekranında arkadaki kartlar, karşılama
        // ekranında başlık ve bloklar dahil. Alt sayfa (takma ad
        // düzenleme) açıkken sayfa altta kalıp animasyon devam ettiği
        // için yazarken takılma olarak hissediliyordu.
        child: RepaintBoundary(
          child: AnimatedBuilder(
          animation: Listenable.merge([_idle, _poke, _blink]),
          builder: (context, _) {
            // Zıplama: neşeli hâllerde yukarı, diğerlerinde nefes alma.
            final breath = reduced ? 0.0 : Curves.easeInOut.transform(_idle.value);
            final poke = reduced ? 0.0 : Curves.easeOut.transform(_poke.value);
            final pokeBump = math.sin(poke * math.pi);

            final lift = switch (widget.mood) {
              MascotMood.cheering => -breath * widget.size * 0.10,
              MascotMood.happy => -breath * widget.size * 0.04,
              _ => -breath * widget.size * 0.018,
            };
            final squash = switch (widget.mood) {
              MascotMood.cheering => 1 + breath * 0.05,
              _ => 1 + breath * 0.015,
            };

            return Transform.translate(
              offset: Offset(0, lift - pokeBump * widget.size * 0.08),
              child: Transform.scale(
                scaleX: 1 / squash,
                scaleY: squash * (1 + pokeBump * 0.06),
                child: _dressed(reduced, breath),
              ),
            );
            },
          ),
        ),
      ),
    );
  }

  /// Devi + üstündeki ekipmanlar.
  ///
  /// Ekipmanlar figürün İÇİNDE, aynı dönüşümün altında duruyor: Devi
  /// nefes alırken ya da zıplarken şapkası da onunla hareket ediyor.
  /// Dışarıda dursalardı kafa zıplayıp şapka yerinde kalırdı.
  Widget _dressed(bool reduced, double breath) {
    final w = widget.size;
    final spec = specOf(_species);
    final a = spec.anchors;
    final h = w * a.stageHeight;

    final figure = CustomPaint(
      size: Size(w, h),
      painter: mascotPainter(
        species: _species,
        mood: widget.mood,
        color: widget.color ?? spec.defaultColor,
        blink: reduced ? 0 : _blink.value,
        breath: breath,
        shadow: widget.showShadow,
      ),
    );

    final hasGear = widget.hat != null ||
        widget.glasses != null ||
        widget.necklace != null ||
        widget.shoes != null ||
        (widget.chestEmoji?.isNotEmpty ?? false);
    if (!hasGear) return figure;

    /// Bir emojiyi MERKEZİ verilen çıpaya gelecek şekilde koyar.
    ///
    /// Emojinin ÜST kenarını hizalamak işe yaramıyor: emoji glifinin
    /// satır kutusu yazı tipine göre değişiyor, yani aynı `top` değeri
    /// bir cihazda gözün üstüne, başka bir cihazda alnın ortasına
    /// düşüyor. Sabit yükseklikte bir kutunun içine ortalayınca konum
    /// yazı tipinden bağımsız oluyor.
    Widget at(double centerY, String emoji, double scale) {
      final box = w * scale * 1.4;
      return Positioned(
        top: w * centerY - box / 2,
        left: 0,
        right: 0,
        height: box,
        child: Center(
          child: Text(
            emoji,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: w * scale, height: 1.0),
          ),
        ),
      );
    }

    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: figure),

          // Göğüs ekranındaki simge.
          //
          // Painter'ın içinde TextPainter ile çizilmiyor — TextPainter
          // temanın yazı tipini ve platformun emoji yedeğini ALMIYOR,
          // yani emoji bazı cihazlarda boş kare çıkıyordu. Widget olarak
          // çizilince normal metin yolundan geçiyor.
          if (widget.chestEmoji?.isNotEmpty ?? false)
            at(a.chestY, widget.chestEmoji!, 0.105),

          // Kolye — göğsün üst kısmı, boynun hemen altı.
          if (widget.necklace != null)
            at(a.necklaceY, widget.necklace!, 0.13),

          // Ayakkabılar — iki ayak ayrı ayrı.
          if (widget.shoes != null)
            Positioned(
              top: w * a.feetY - w * 0.08,
              left: 0,
              right: 0,
              height: w * 0.16,
              child: Center(
                child: SizedBox(
                  width: w * 0.34,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.shoes!,
                          style: TextStyle(fontSize: w * 0.115)),
                      Text(widget.shoes!,
                          style: TextStyle(fontSize: w * 0.115)),
                    ],
                  ),
                ),
              ),
            ),

          // Gözlük — tam göz hizası.
          if (widget.glasses != null)
            at(a.eyeLineY, widget.glasses!, 0.175),

          // Şapka — kafanın tepesine oturuyor ama antenlerin ucunu
          // KAPATMIYOR: antenler Devi'nin silüetinin imzası, şapka onları
          // yutarsa karakter tanınmaz oluyor.
          if (widget.hat != null) at(a.hatY, widget.hat!, 0.21),
        ],
      ),
    );
  }

  String _moodLabel(MascotMood m) => switch (m) {
        MascotMood.idle => 'bekliyor',
        MascotMood.thinking => 'düşünüyor',
        MascotMood.happy => 'mutlu',
        MascotMood.cheering => 'seviniyor',
        MascotMood.encouraging => 'cesaret veriyor',
        MascotMood.curious => 'merak ediyor',
      };
}

/// Devi + konuşma balonu.
///
/// Maskotun tek başına durması "süs" demek; bir şey söylediğinde
/// karakter oluyor. Balon, çocuğun O AN yaptığı şeye bağlı bir cümle
/// taşımalı — genel bir teşvik değil (bkz. Calvert 2020: çocuğun kendi
/// eylemine karşılık veren karakter, öğrenmeyi ölçülebilir biçimde
/// artırıyor; sadece duran ve alkışlayan karakter artırmıyor).
class MascotSays extends StatelessWidget {
  const MascotSays({
    super.key,
    required this.text,
    this.mood = MascotMood.idle,
    this.size = 72,
    this.color,
    this.action,
  });

  final String text;
  final MascotMood mood;
  final double size;
  final Color? color;

  /// Balonun altındaki isteğe bağlı düğme.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    // Balonun kenarlığı ve gölgesi maskotun rengiyle uyumlu. Renk
    // verilmediyse çocuğun seçtiği karakterin kendi rengi kullanılıyor.
    MascotSpecies species;
    try {
      species = context.watch<SettingsProvider>().mascot;
    } on ProviderNotFoundException {
      species = Mascot.defaultSpecies;
    }
    final tone = color ?? specOf(species).defaultColor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Mascot(mood: mood, size: size, color: color),
        SizedBox(width: size * 0.16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: tone.withValues(alpha: 0.18)),
              boxShadow: [
                BoxShadow(
                  color: tone.withValues(alpha: 0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 15.5,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2430),
                  ),
                ),
                if (action != null) ...[
                  const SizedBox(height: 12),
                  action!,
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
