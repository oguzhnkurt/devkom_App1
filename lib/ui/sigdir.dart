import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Icerigi kendisine verilen yukseklige SIGDIRIR.
///
/// NEDEN VAR
///
/// Uygulamadaki secenek listeleri, ders adimlari ve kurulum sorulari
/// sabit dolgu ve yazi boylariyla yazildi. iPhone 17 Pro'da rahat
/// duruyorlar; iPhone SE'de ya da klavye acikken ayni icerik ekrana
/// sigmiyor. O ana kadarki cozum kaydirmaktir: cocuk listenin ilk
/// secenegini gormek icin yukari itmek zorunda kaliyor, ustteki secenek
/// yarim gorunuyor ve "burada daha fazlasi var" bilgisi tamamen
/// kayboluyor. Alti yasindaki bir kullanici icin gormedigi secenek yok
/// demektir.
///
/// [EkranOlcusu] bu isin yaklasik cozumuydu: ekran yuksekligine bakip
/// araliklari 0.85 ya da 0.7 ile carpiyor. Ama o, ICERIGI degil CIHAZI
/// olcuyor; dort secenegi olan bir sayfa ile alti secenegi olan sayfa
/// ayni kucultmeyi aliyor, biri hala tasiyor, oteki bosu bosuna
/// sikisiyor. Burada olculen sey icerigin kendisi.
///
/// NASIL CALISIYOR
///
/// Cocugun dogal yuksekligi [RenderBox.getMaxIntrinsicHeight] ile
/// soruluyor. Sigiyorsa hicbir sey yapilmiyor — olcek 1, tek bir
/// piksel bile oynamiyor. Sigmiyorsa olcek = eldeki yukseklik / dogal
/// yukseklik oluyor ve cocuk hem yatayda hem dikeyde AYNI oranda
/// kucultuluyor. Oranin korunmasi onemli: yalnizca dikeyde ezilen bir
/// yazi okunmaz hale gelir.
///
/// [enAz] bir taban koyuyor. Sonsuza kadar kuculterek her seyi
/// sigdirmak mumkun ama 8 puntoya dusmus bir secenek de gorunmuyor
/// sayilir; tabana dayanan icerik artik gercekten fazladir ve tasarim
/// degismelidir.
///
/// SINIRI: dogal yuksekligini bildirmeyen bir cocuk (kendi icinde
/// kaydirilan bir liste gibi) olculemiyor. Oyle bir durumda olcum
/// sessizce birakiliyor ve yerlesim eskisi gibi calisiyor — kucultmek
/// isten cikiyor, ama hicbir sey de bozulmuyor.
class Sigdir extends SingleChildRenderObjectWidget {
  const Sigdir({
    super.key,
    required Widget super.child,
    this.enAz = 0.55,
    this.hizalama = Alignment.center,
  });

  /// Inilebilecek en kucuk olcek.
  final double enAz;

  /// Kucultulmus icerigin dikeyde nereye oturacagi.
  final Alignment hizalama;

  @override
  RenderSigdir createRenderObject(BuildContext context) =>
      RenderSigdir(enAz: enAz, hizalama: hizalama);

  @override
  void updateRenderObject(BuildContext context, RenderSigdir renderObject) {
    renderObject
      ..enAz = enAz
      ..hizalama = hizalama;
  }
}

class RenderSigdir extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  RenderSigdir({required double enAz, required Alignment hizalama})
      : _enAz = enAz,
        _hizalama = hizalama;

  double _enAz;
  double get enAz => _enAz;
  set enAz(double deger) {
    if (deger == _enAz) return;
    _enAz = deger;
    markNeedsLayout();
  }

  Alignment _hizalama;
  Alignment get hizalama => _hizalama;
  set hizalama(Alignment deger) {
    if (deger == _hizalama) return;
    _hizalama = deger;
    markNeedsLayout();
  }

  /// null ise olcek 1: hicbir donusum uygulanmiyor.
  Matrix4? _donusum;

  // KATMANLAR DUZ ALANDA DEGIL, LayerHandle ICINDE.
  //
  // `context.pushTransform(..., oldLayer: ...)` cagrisina bir onceki
  // karenin katmani veriliyor. O katmani duz bir alanda tutarsak
  // cerceve onu sahiplenmis saymiyor, uygun gordugu anda atiyor ve
  // bir sonraki karede atilmis katmani geri verdigimizde
  // "Failed assertion: '!_debugDisposed'" ile patliyor. Simulatorde
  // acilis ekrani bu hatayi saniyede onlarca kez basiyordu.
  //
  // LayerHandle katmani canli tutuyor; RenderTransform ve RenderClipRect
  // da aynisini yapiyor.
  final LayerHandle<TransformLayer> _katman = LayerHandle<TransformLayer>();
  final LayerHandle<ClipRectLayer> _kirpmaKatmani =
      LayerHandle<ClipRectLayer>();

  @override
  void dispose() {
    _katman.layer = null;
    _kirpmaKatmani.layer = null;
    super.dispose();
  }

  /// Taban olcege dayanildiginda icerik hala tasiyor; tasan kismi
  /// kirpiyoruz.
  bool _kirp = false;

  @override
  double computeMinIntrinsicWidth(double height) =>
      child?.getMinIntrinsicWidth(height) ?? 0;

  @override
  double computeMaxIntrinsicWidth(double height) =>
      child?.getMaxIntrinsicWidth(height) ?? 0;

  @override
  double computeMinIntrinsicHeight(double width) =>
      child?.getMinIntrinsicHeight(width) ?? 0;

  @override
  double computeMaxIntrinsicHeight(double width) =>
      child?.getMaxIntrinsicHeight(width) ?? 0;

  /// Cocugun dogal yuksekligi, olculemiyorsa null.
  ///
  /// Kendi icinde kaydirilan bir liste "ne kadar uzunum" sorusuna cevap
  /// vermek yerine hata atiyor. Bu bir cokme sebebi degil: olcemedigimiz
  /// seyi kucultmuyoruz, o kadar.
  double? _dogalYukseklik(RenderBox cocuk, double genislik) {
    try {
      final h = cocuk.getMaxIntrinsicHeight(genislik);
      return h.isFinite && h > 0 ? h : null;
    } catch (_) {
      return null;
    }
  }

  @override
  void performLayout() {
    final cocuk = child;
    if (cocuk == null) {
      size = constraints.smallest;
      _donusum = null;
      _kirp = false;
      return;
    }

    final genislik = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : constraints.minWidth;

    var olcek = 1.0;
    double? dogal;
    if (constraints.hasBoundedHeight && constraints.maxHeight > 0) {
      dogal = _dogalYukseklik(cocuk, genislik);
      if (dogal != null && dogal > constraints.maxHeight) {
        olcek = (constraints.maxHeight / dogal).clamp(_enAz, 1.0);
      }
    }

    // Cocuga kendi olceginde yer veriyoruz: 0.8'e kuculecekse eldeki
    // alanin 1/0.8 kati kadar genis ve yuksek bir tuval aliyor, kuculunce
    // tam oturuyor.
    final tavan = constraints.hasBoundedHeight
        ? constraints.maxHeight / olcek
        : double.infinity;

    // TABANA DAYANDIYSA cocuga DOGAL yuksekligini veriyoruz.
    //
    // Yoksa bir Column'a sigmayacagi yukseklik dayatilmis olurdu ve
    // Flutter'in kendi tasma uyarisi (sarili-siyah seritler) devreye
    // girerdi. Icerik zaten fazla; onu bir de bozuk gostermenin anlami
    // yok. Tasan kisim kirpiliyor.
    final cocukTavani =
        (dogal != null && dogal > tavan) ? dogal : tavan;

    cocuk.layout(
      BoxConstraints(
        minWidth: genislik / olcek,
        maxWidth: genislik / olcek,
        maxHeight: cocukTavani,
      ),
      parentUsesSize: true,
    );

    size = constraints.constrain(
      Size(cocuk.size.width * olcek, cocuk.size.height * olcek),
    );

    if (olcek == 1.0) {
      _donusum = null;
      _kirp = false;
      return;
    }

    final olcekliGenislik = cocuk.size.width * olcek;
    final olcekliYukseklik = cocuk.size.height * olcek;
    final dx = (size.width - olcekliGenislik) / 2;
    final dy = (size.height - olcekliYukseklik) * ((_hizalama.y + 1) / 2);

    _kirp = olcekliYukseklik > size.height + 0.01 ||
        olcekliGenislik > size.width + 0.01;

    // Matrix4.diagonal3Values(s, s, 1) olcek matrisi; setTranslationRaw
    // son sutunu yaziyor ve T * S sonucunu veriyor. `translate`/`scale`
    // cagrilarinin surumden surume degisen imzalarina bagli kalmiyoruz.
    _donusum = Matrix4.diagonal3Values(olcek, olcek, 1.0)
      ..setTranslationRaw(dx, dy, 0);
  }

  @override
  bool get isRepaintBoundary => false;

  @override
  void paint(PaintingContext context, Offset offset) {
    final cocuk = child;
    if (cocuk == null) return;

    final donusum = _donusum;
    if (donusum == null) {
      _katman.layer = null;
      _kirpmaKatmani.layer = null;
      context.paintChild(cocuk, offset);
      return;
    }

    void ciz(PaintingContext ctx, Offset off) {
      _katman.layer = ctx.pushTransform(
        needsCompositing,
        off,
        donusum,
        (PaintingContext ic, Offset io) => ic.paintChild(cocuk, io),
        oldLayer: _katman.layer,
      );
    }

    if (_kirp) {
      _kirpmaKatmani.layer = context.pushClipRect(
        needsCompositing,
        offset,
        Offset.zero & size,
        ciz,
        oldLayer: _kirpmaKatmani.layer,
      );
    } else {
      _kirpmaKatmani.layer = null;
      ciz(context, offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final cocuk = child;
    if (cocuk == null) return false;

    final donusum = _donusum;
    if (donusum == null) {
      return result.addWithPaintOffset(
        offset: Offset.zero,
        position: position,
        hitTest: (BoxHitTestResult r, Offset p) => cocuk.hitTest(r, position: p),
      );
    }

    // Dokunuslar da ayni donusumden gecmeli; yoksa kucultulmus bir
    // secenege basildiginda dokunus eski, buyuk yerine gidiyor.
    return result.addWithPaintTransform(
      transform: donusum,
      position: position,
      hitTest: (BoxHitTestResult r, Offset p) => cocuk.hitTest(r, position: p),
    );
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    final donusum = _donusum;
    if (donusum != null) transform.multiply(donusum);
  }
}
