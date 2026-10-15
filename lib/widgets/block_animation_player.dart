import '../courses/yurutme/degisken_adlari.dart';
import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';

import '../courses/models/interactive_lesson_model.dart';
import '../courses/yurutme/blok_anlami.dart';
import '../courses/yurutme/blok_sozlugu.dart';
import '../courses/yurutme/blok_yorumlayici.dart';
import '../courses/sahne/scratch_sahnesi.dart';
import '../courses/tanitim/tanitim_parcalari.dart' show YesilBayrak;
import '../courses/yurutme/konusma_metni.dart';
import '../ui/motion.dart';
import '../utils/lang.dart';
import 'mascot.dart';
import 'scratch_blok.dart';
import '../courses/yurutme/scratch_blok_katalogu.dart';

/// Cocugun kurdugu blok dizisini sahnede canlandirir.
///
/// ONCEKI SURUM NEREDEYSE HICBIR SEY GOSTERMIYORDU.
///
/// Oynatici yalnizca `say_`, `move_` ve `repeat_` ile baslayan kimlikleri
/// taniyordu; geri kalan her blok sessizce ATLANIYORDU. Yeni oynatici her
/// blogu sirayla, adi ekranda yazili olarak calistiriyor; gorsel bir etkisi
/// olmasa bile (yesil bayrak, yayin gonderme, klon) cocuk onun sirasinin
/// geldigini goruyor.
///
/// SIRA ARTIK YORUMLAYICIDAN GELIYOR (Ekim 2026).
///
/// Oynatici dongulerin govdesini kendi tahmin ediyordu: "tekrarla"dan
/// sonra YALNIZCA BIR blogu donguye aliyordu. Kod alani ise (ve "Kodun ne
/// yapti" izi) dongunun altindaki HER SEYI govde sayiyor. Yani
/// `4 kere tekrarla { 10 adim git, Miyav de }` kodunda iz dort miyav
/// yazarken sahne bir kez miyavliyordu. Simdi sahne de, iz de ayni
/// [Yurutme]'yu oynatiyor; ayni rastgele sayiyi bile soyluyorlar.
///
/// SAHNE IKI BOYUTLU: kukla baktigi yone gidiyor, kalem inikse arkasinda
/// cizgi kaliyor (kare dersi artik gercekten kare ciziyor), baslangic
/// yeri yesil bayrakla, kodun bitirdigi yer damali bayrakla isaretli.
class BlockAnimationPlayer extends StatefulWidget {
  const BlockAnimationPlayer({
    super.key,
    required this.blocks,
    required this.lang,
    this.size = 60,
    this.onComplete,
    this.yurutme,
    this.onAdim,
    this.dogru = false,
    this.baslamaGecikmesi = Duration.zero,
    this.renk,
    this.scratch = false,
    this.sahne = false,
  });

  /// Acilis sahnesindeki gorunum: yalnizca sahnenin GOVDESI (gokyuzu,
  /// bulutlar, zemin) — baslik, bayrak ve dur [ScratchSahneKarti]'nda.
  /// Calisan blok ve tur ustte, konusma kuklanin ustunde balon, sonuc
  /// seridi ustte (sabit yerlerde; sahne boyu degismiyor).
  final bool sahne;

  final List<ScratchBlock> blocks;

  /// Scratch kursu: "su an calisan blok" cipi Scratch 3 blogu olarak
  /// ciziliyor (kod alanindakiyle ayni gorunum).
  final bool scratch;
  final String lang;
  final double size;
  final VoidCallback? onComplete;

  /// Onceden hesaplanmis yurutme. Calisma iziyle AYNI sonucu gostermek
  /// icin (rastgele sayi dahil) cagiran bir kez hesaplayip ikisine de
  /// veriyor. Verilmezse oynatici kendisi hesapliyor.
  final Yurutme? yurutme;

  /// O an calisan blogun kod alanindaki sirasi; bitince null.
  /// Kod alani bu blogu parlatarak sahneyle senkron gidiyor.
  final ValueChanged<int?>? onAdim;

  /// Kod hedefe uygun mu? Oyleyse sonda kucuk bir kutlama var. Degilse
  /// ceza yok: yalnizca "hedefle karsilastir" diye nazik bir cumle.
  final bool dogru;

  /// Sahne ekrana kaydirilirken animasyon baslamasin diye bekleme.
  final Duration baslamaGecikmesi;

  /// Sahnenin vurgu rengi (kursun rengi). Verilmezse mavi.
  final Color? renk;

  /// Bitmeyen kodda ("surekli tekrarla") sahnede gosterilen adim: birkac
  /// tur yetiyor, otuz saniyelik bir dongu cocugu adimdan koparir.
  static const int sonsuzdaEnFazlaAdim = 12;

  /// Sahnede gosterilen en fazla adim. "Surekli tekrarla" bitmez; sahne
  /// birkac tur gosterip durdugunu SOYLUYOR.
  static const int enFazlaAdim = 36;

  @override
  State<BlockAnimationPlayer> createState() => BlockAnimationPlayerState();
}

/// Bir blogun sahnedeki karsiligi.
enum _Etki { hareket, ziplama, konus, bekle, degisken, ses, isik, yapisal }

class BlockAnimationPlayerState extends State<BlockAnimationPlayer>
    with TickerProviderStateMixin {
  static const _adimSuresi = Duration(milliseconds: 450);
  static const _yurumeSuresi = Duration(milliseconds: 650);
  final _rastgele = Random();

  late final Yurutme _yurutme = widget.yurutme ??
      BlokYorumlayici(dil: widget.lang).yurut(widget.blocks);

  /// Sahnede oynatilacak adim sayisi.
  late final int _sinir = min(
      _yurutme.adimlar.length,
      _yurutme.butceBitti
          ? BlockAnimationPlayer.sonsuzdaEnFazlaAdim
          : BlockAnimationPlayer.enFazlaAdim);

  /// Hareket animasyonu: [_onceki]'den [_hedef]'e. Kukla ve kalem cizgisi
  /// AYNI degeri okuyor, yani cizgi kuklanin tam arkasindan uzuyor.
  late final AnimationController _hareketC =
      AnimationController(vsync: this, duration: _yurumeSuresi);

  /// Yururken adim adim sallanma.
  late final AnimationController _adimC = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 260));

  int _sira = -1; // o an calisan blogun sirasi
  int? _tur;
  Offset _onceki = Offset.zero;
  Offset _hedef = Offset.zero;
  double _yon = 90;
  bool _ayna = false;
  bool _kalemInik = false;
  bool _havada = false;

  /// Bitmis kalem cizgileri (dunya koordinatinda).
  final List<(Offset, Offset)> _cizgiler = [];

  /// Kalem inikken su an cizilmekte olan parca var mi?
  bool _cizerekGidiyor = false;

  /// Kuklanin ugradigi noktalar: sahnede noktali iz olarak ciziliyor
  /// ("buradan buraya yurudu").
  final List<Offset> _yol = [Offset.zero];

  String? _konusma;
  bool _bekliyor = false;
  String? _nota;
  Color? _lamba;
  final Map<String, num> _degiskenler = {};
  bool _bitti = false;
  bool _yarida = false; // sahne birkac turdan sonra durdu
  bool _durduruldu = false;

  /// Cocuk kirmizi "dur"a basti.
  bool _elleDurdu = false;

  /// Kod hala calisiyor mu (bitmedi, durdurulmadi)?
  bool get calisiyor => !_bitti && !_durduruldu;

  /// Kirmizi dur: oynatma o anda biter, kukla oldugu yerde kalir.
  void durdur() {
    if (!calisiyor) return;
    _durduruldu = true;
    _zamanlayici?.cancel();
    if (_bekleyen != null && !_bekleyen!.isCompleted) {
      _bekleyen!.complete(false);
    }
    // Kukla yarim adimda kalmasin: bulundugu yere otursun.
    final simdi = _konum;
    _hareketC.stop();
    _adimC.stop();
    _adimC.value = 0;
    setState(() {
      _onceki = simdi;
      _hedef = simdi;
      _hareketC.value = 0;
      _cizerekGidiyor = false;
      _konusma = null;
      _bekliyor = false;
      _nota = null;
      _sira = -1;
      _tur = null;
      _elleDurdu = true;
    });
    widget.onAdim?.call(null);
  }

  @override
  void initState() {
    super.initState();
    unawaited(_calistir());
  }

  @override
  void dispose() {
    _durduruldu = true;
    // Bekleyen zamanlayici kalmasin: ekran kapaninca (ya da cocuk kodu
    // degistirince) oynatma o anda biter.
    _zamanlayici?.cancel();
    if (_bekleyen != null && !_bekleyen!.isCompleted) {
      _bekleyen!.complete(false);
    }
    _hareketC.dispose();
    _adimC.dispose();
    super.dispose();
  }

  String _t(String tr, String en, String de, String es) =>
      AppLang.pick(widget.lang, tr: tr, en: en, de: de, es: es);

  Color get _renk => widget.renk ?? Colors.blue;

  Timer? _zamanlayici;
  Completer<bool>? _bekleyen;

  /// Bir sonraki adima gecmeden once bekler. Beklerken ekran kapanirsa
  /// `false` doner ve zamanlayici iptal edilir (asili zamanlayici yok).
  Future<bool> _bekle(Duration d) {
    final c = Completer<bool>();
    _bekleyen = c;
    _zamanlayici = Timer(d, () {
      if (!c.isCompleted) c.complete(mounted && !_durduruldu);
    });
    return c.future;
  }

  bool get _hareketAzalt => Motion.reduced(context);

  // ---------------------------------------------------------------
  // Blok siniflandirmasi
  // ---------------------------------------------------------------

  _Etki _etkisi(ScratchBlock blok) {
    final id = blok.id;
    final anlam = BlokYorumlayici.anlamOf(blok);
    switch (anlam.komut) {
      case BlokKomutu.ilerle:
      case BlokKomutu.xDegistir:
      case BlokKomutu.gitXY:
      case BlokKomutu.don:
      case BlokKomutu.yonAyarla:
        return _Etki.hareket;
      case BlokKomutu.yDegistir:
        return _Etki.ziplama;
      case BlokKomutu.soyle:
        return _Etki.konus;
      case BlokKomutu.bekle:
        return _Etki.bekle;
      case BlokKomutu.degiskenAta:
      case BlokKomutu.degiskenArtir:
        return _Etki.degisken;
      default:
        break;
    }
    if (id == 'goto_random') return _Etki.hareket;
    // Yesil bayrak sapkasi bir isik DEGIL ('green_' oneki Arduino'nun
    // trafik isigi kimlikleri icin): sahnede sari lamba yakiyordu.
    if (id == 'green_flag' || id.startsWith('when_')) return _Etki.yapisal;
    if (id.startsWith('wait')) return _Etki.bekle;
    if (id.contains('note') || id.contains('sound')) return _Etki.ses;
    if (id.contains('led') ||
        id.startsWith('red_') ||
        id.startsWith('green_') ||
        id.startsWith('yellow_') ||
        id == 'pwm_set') {
      return _Etki.isik;
    }
    if (id.startsWith('set_') || id == 'increment') {
      return _Etki.degisken;
    }
    return _Etki.yapisal;
  }

  // ---------------------------------------------------------------
  // Calistirma
  // ---------------------------------------------------------------

  Future<void> _calistir() async {
    if (widget.baslamaGecikmesi > Duration.zero &&
        !await _bekle(widget.baslamaGecikmesi)) {
      return;
    }
    final adimlar = _yurutme.adimlar;
    final sinir = _sinir;
    for (var k = 0; k < sinir; k++) {
      final adim = adimlar[k];
      final sira = adim.blokSirasi >= 0
          ? adim.blokSirasi
          : widget.blocks.indexWhere((b) => b.id == adim.blokId);
      if (sira < 0 || sira >= widget.blocks.length) continue;
      if (!mounted || _durduruldu) return;
      setState(() {
        _sira = sira;
        _tur = adim.tekrarNo;
      });
      widget.onAdim?.call(sira);
      if (!await _bekle(_adimSuresi)) return;
      // Calisan blok kod alanindakiyle cogu zaman ayni; kendi blogunun
      // govdesi calisirken (kare, cokgen) kod alaninda cagri parliyor,
      // sahnede ise govdedeki blok etki ediyor.
      final blok = adim.blok ?? widget.blocks[sira];
      if (BlokYorumlayici.anlamOf(blok).cBlogu) continue;
      if (!await _etkiUygula(blok, adim)) return;
    }

    if (!mounted || _durduruldu) return;
    setState(() {
      _sira = -1;
      _tur = null;
      _bitti = true;
      _yarida = _yurutme.butceBitti || adimlar.length > _sinir;
    });
    widget.onAdim?.call(null);
    widget.onComplete?.call();
    // Kucuk kutlama: dogru kodda Devi bir kez sevincle zipliyor.
    if (widget.dogru && !_hareketAzalt) {
      setState(() => _havada = true);
      if (!await _bekle(const Duration(milliseconds: 260))) return;
      setState(() => _havada = false);
    }
  }

  Future<bool> _etkiUygula(ScratchBlock blok, YurutmeAdimi adim) async {
    switch (_etkisi(blok)) {
      case _Etki.hareket:
        return _hareket(blok, adim);
      case _Etki.ziplama:
        return _hareket(blok, adim, zipla: true);
      case _Etki.konus:
        return _konus(blok, adim);
      case _Etki.bekle:
        return _beklemeGoster();
      case _Etki.degisken:
        return _degiskenGuncelle(blok.id, adim);
      case _Etki.ses:
        return _sesCal();
      case _Etki.isik:
        return _isikYak(blok.id);
      case _Etki.yapisal:
        // Gorsel etkisi yok; adim satiri zaten blogun adini gosterdi.
        // Kalem ve kostum durumu yine de sahneye yansiyor.
        setState(() {
          _kalemInik = adim.sahne.kalemInik;
          if (adim.sahne.kostum.isEven != _ayna) _ayna = !_ayna;
        });
        return true;
    }
  }

  Offset get _konum {
    final t = Curves.easeInOut.transform(_hareketC.value);
    return Offset.lerp(_onceki, _hedef, t)!;
  }

  Future<bool> _hareket(ScratchBlock blok, YurutmeAdimi adim,
      {bool zipla = false}) async {
    // Rastgele konum da yorumlayicidan: sahne ve iz ayni yeri gosteriyor.
    final hedef = Offset(adim.sahne.x, adim.sahne.y);
    final simdi = _konum;
    final yeniYon = adim.sahne.yon;
    setState(() {
      _onceki = simdi;
      _hedef = hedef;
      _yon = yeniYon;
      _kalemInik = adim.sahne.kalemInik;
      _cizerekGidiyor = _kalemInik && hedef != simdi;
    });
    final yuruyor = hedef != simdi;
    if (yuruyor) {
      if (!_hareketAzalt) unawaited(_adimC.repeat(reverse: true));
      _hareketC.forward(from: 0);
    }
    final ok = await _bekle(yuruyor ? _yurumeSuresi : _adimSuresi);
    if (!ok) return false;
    _adimC.stop();
    _adimC.value = 0;
    setState(() {
      if (_cizerekGidiyor) _cizgiler.add((simdi, hedef));
      _cizerekGidiyor = false;
      if (hedef != simdi) _yol.add(hedef);
    });
    if (zipla && !yuruyor) {
      // Konumu degismeyen y blogu (ornegin "y'yi 0 yap"): kucuk bir
      // ziplama ki blogun calistigi gorulsun.
      setState(() => _havada = true);
      if (!await _bekle(const Duration(milliseconds: 300))) return false;
      setState(() => _havada = false);
    }
    return true;
  }

  Future<bool> _konus(ScratchBlock blok, YurutmeAdimi adim) async {
    // RASTGELE BLOKLAR. "1 ile 6 arasinda rastgele bir sayi sec de"
    // blogunun balonuna o cumlenin kendisini degil bir SAYI yazmak
    // gerekiyor. Sayi yorumlayicinin urettigi sayi: izde yazan sayiyla
    // ayni (bkz. blok_sozlugu.dart).
    final anlam = blokSozlugu[blok.id];
    String metin;
    if (anlam != null &&
        anlam.komut == BlokKomutu.soyle &&
        anlam.rastgeleAlt != null &&
        anlam.rastgeleUst != null) {
      metin = adim.sahne.soyledigi ??
          '${anlam.rastgeleAlt!.toInt() + _rastgele.nextInt((anlam.rastgeleUst! - anlam.rastgeleAlt!).toInt() + 1)}';
    } else if (anlam != null &&
        anlam.komut == BlokKomutu.soyle &&
        anlam.listeRastgele != null &&
        adim.sahne.soyledigi != null) {
      // Listenin rastgele ogesi: yorumlayicinin sectigi oge (izde de o).
      metin = adim.sahne.soyledigi!;
    } else if (BlokYorumlayici.anlamOf(blok) case final a
        when a.komut == BlokKomutu.soyle &&
            a.metin == null &&
            adim.sahne.soyledigi != null) {
      // Degiskenin ya da listenin degeri ("zar", "alisveris in
      // uzunlugu"): yorumlayicinin hesapladigi deger.
      metin = adim.sahne.soyledigi!;
    } else {
      // Metin blogun KENDI yazisindan cikariliyor: "Miyav! de" -> "Miyav!"
      metin = konusmaMetni(blok, widget.lang);
    }
    setState(() => _konusma = metin);
    if (!await _bekle(const Duration(milliseconds: 1200))) return false;
    setState(() => _konusma = null);
    return true;
  }

  Future<bool> _beklemeGoster() async {
    setState(() => _bekliyor = true);
    if (!await _bekle(const Duration(milliseconds: 800))) return false;
    setState(() => _bekliyor = false);
    return true;
  }

  Future<bool> _degiskenGuncelle(String id, YurutmeAdimi adim) async {
    setState(() {
      if (adim.sahne.degiskenler.isNotEmpty && blokSozlugu.containsKey(id)) {
        _degiskenler
          ..clear()
          ..addAll(adim.sahne.degiskenler);
        return;
      }
      // Sozlukte olmayan (Arduino) degiskenler: adindan tahmin.
      final ad = _degiskenAdi(id);
      if (id.startsWith('set_')) {
        _degiskenler[ad] = id.endsWith('_0') ? 0 : _rastgele.nextInt(600) + 200;
      } else {
        _degiskenler[ad] = (_degiskenler[ad] ?? 0) + 1;
      }
    });
    return _bekle(const Duration(milliseconds: 600));
  }

  String _degiskenAdi(String id) {
    if (id.contains('score')) {
      return _t('Puan', 'Score', 'Punkte', 'Puntos');
    }
    if (id.contains('counter') || id == 'increment') {
      return _t('Sayaç', 'Counter', 'Zähler', 'Contador');
    }
    if (id.contains('pot')) return 'Pot';
    if (id.contains('ldr')) return 'LDR';
    return _t('Değişken', 'Variable', 'Variable', 'Variable');
  }

  Future<bool> _sesCal() async {
    setState(() => _nota = '🎵');
    if (!await _bekle(const Duration(milliseconds: 700))) return false;
    setState(() => _nota = null);
    return true;
  }

  Future<bool> _isikYak(String id) async {
    // Trafik isigi dersindeki kimlikler bilesik: 'red_off_green_on'.
    // Gecerli olan SON durum: kirmizi soner, yesil yanar.
    const renkler = {
      'red': Colors.red,
      'green': Colors.green,
      'yellow': Colors.amber,
    };
    Color? renk;
    for (final e in renkler.entries) {
      if (id.contains('${e.key}_on')) renk = e.value;
    }
    if (renk == null) {
      final sonuyor = id.endsWith('_off') || id == 'led_low';
      renk = sonuyor ? null : Colors.amber;
    }
    setState(() => _lamba = renk);
    return _bekle(const Duration(milliseconds: 700));
  }

  // ---------------------------------------------------------------
  // Sahne geometrisi
  // ---------------------------------------------------------------

  /// Kodun gidecegi butun noktalarin cercevesi (dunya koordinati).
  /// Sahne bunu kutuya sigdiriyor: 10 adim da 200 adim da gorunur.
  late final Rect _sinirlar = () {
    var r = Rect.fromLTRB(0, 0, 0, 0);
    final sinir = _sinir;
    for (var k = 0; k < sinir; k++) {
      final s = _yurutme.adimlar[k].sahne;
      r = r.expandToInclude(Rect.fromLTWH(s.x, s.y, 0, 0));
    }
    return r;
  }();

  /// Kodun sahnede bitirdigi yer (bitis bayragi).
  Offset get _bitisNoktasi {
    final sinir = _sinir;
    if (sinir == 0) return Offset.zero;
    final s = _yurutme.adimlar[sinir - 1].sahne;
    return Offset(s.x, s.y);
  }

  // ---------------------------------------------------------------
  // Cizim
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final calisan = _sira >= 0 && _sira < widget.blocks.length
        ? widget.blocks[_sira]
        : null;

    // Sahne kendi katmaninda: kukla her karede sallanirken sayfanin geri
    // kalani yeniden boyanmiyor.
    if (widget.sahne) return RepaintBoundary(child: _sahneGorunumu(calisan));

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: Color.alphaBlend(_renk.withValues(alpha: 0.06), Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _renk.withValues(alpha: 0.45), width: 2),
      ),
      child: Column(
        children: [
          Text(
            _bitti
                ? _t('🎬 Kodun çalıştı!', '🎬 Your code ran!',
                    '🎬 Dein Code ist gelaufen!', '🎬 ¡Tu código se ejecutó!')
                : _t('🎬 Kodun çalışıyor!', '🎬 Your code is running!',
                    '🎬 Dein Code läuft!', '🎬 ¡Tu código se está ejecutando!'),
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: _renk,
            ),
          ),
          const SizedBox(height: 8),

          // O AN CALISAN BLOK (ve dongudeyse kacinci tur).
          //
          // Yeri bastan ayrilmis: blok degisince altindaki sahne yerinden
          // oynamiyor.
          SizedBox(
            height: widget.scratch ? 40 : 32,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: calisan == null
                  ? const SizedBox.shrink()
                  : Row(
                      key: ValueKey('$_sira-$_tur'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: _scratchCipi(calisan) ??
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: calisan.color,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  calisan.labelFor(widget.lang),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                        ),
                        if (_tur != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF4D6),
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: const Color(0xFFFFBF00)),
                            ),
                            child: Text(
                              _t('$_tur. tur', 'turn $_tur', '$_tur. Runde',
                                  'vuelta $_tur'),
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF8A6100),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 6),

          // Degisken degerleri — yeri bastan ayrilmis.
          SizedBox(
            height: 26,
            child: _degiskenler.isEmpty
                ? null
                : Wrap(
                    spacing: 8,
                    children: _degiskenler.entries
                        .map((e) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.orange, width: 1.5),
                              ),
                              child: Text(
                                '${yorumlayiciAdi(e.key, widget.lang)}: ${e.value % 1 == 0 ? e.value.toInt() : e.value}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
          ),

          // Konusma balonu — yeri bastan ayrilmis (kayma olmasin).
          SizedBox(
            height: 44,
            child: AnimatedOpacity(
              opacity: _konusma != null ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _renk, width: 2.5),
                  ),
                  child: Text(
                    _konusma ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),

          // SAHNE YALNIZCA GEREKIYORSA.
          //
          // "1 ile 6 arasinda rastgele bir sayi sec de" gibi bir kodun
          // sahnede isi yok: kukla yurumuyor, ziplamiyor, isik yanmiyor.
          // Hareketi olmayan kodda yalnizca maskot ve konusma balonu var.
          if (_hareketVar)
            RepaintBoundary(child: _sahne())
          else
            _sadeMaskot(),

          // BITIS SERIDI — yeri bastan ayrilmis: belirdiginde sayfa
          // kaymiyor.
          SizedBox(
            height: 44,
            child: AnimatedOpacity(
              opacity: _bitti ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: AnimatedScale(
                scale: _bitti ? 1 : 0.85,
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeOutBack,
                child: _bitisSeridi(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Calisan blok, Scratch kursunda Scratch blogu olarak. C bloklari tek
  /// satir (ust kol) halinde; 40 piksellik yuvaya tirnagiyla sigacak
  /// olcekte.
  Widget? _scratchCipi(ScratchBlock b, {double yuva = 40}) {
    if (!widget.scratch) return null;
    final t = ScratchBlokKatalogu.tanim(b.id, widget.lang);
    if (t == null) return null;
    final h1 = ScratchBlokOlcer.yukseklik(t, 1, parca: ScratchCParcasi.bas) +
        ScratchBlokOlcer.tirnakPayi(1);
    final s = min(0.62, yuva / h1);
    return Align(
      alignment: widget.sahne ? Alignment.centerLeft : Alignment.topCenter,
      child: ScratchBlok(tanim: t, olcek: s, parca: ScratchCParcasi.bas),
    );
  }

  Widget _bitisSeridi({double yazi = 13.5}) {
    final String metin;
    final IconData ikon;
    final Color renk;
    if (_yurutme.yalnizTanim && !_elleDurdu) {
      // 11.1: kod alaninda yalnizca tanim var. "Kodun sonuna geldi"
      // demek yanlis olurdu: hicbir blok calismadi.
      metin = _t(
          'Tanım tek başına çalışmaz; onu bir çağrı bloğu çalıştırır.',
          'A definition does not run on its own; a call block runs it.',
          'Eine Definition läuft nicht von selbst; ein Aufruf-Block startet sie.',
          'Una definición no se ejecuta sola; la ejecuta un bloque de llamada.');
      ikon = Icons.menu_book_rounded;
      renk = const Color(0xFF3D5A80);
    } else if (_elleDurdu) {
      metin = _t(
          'Kodu durdurdun. Yeşil bayrakla yeniden başlat.',
          'You stopped the code. Press the green flag to start again.',
          'Du hast den Code gestoppt. Mit der grünen Flagge startest du neu.',
          'Detuviste el código. Pulsa la bandera verde para empezar de nuevo.');
      ikon = Icons.stop_circle_rounded;
      renk = const Color(0xFFB84848);
    } else if (_yarida) {
      metin = _t(
          'Bu kod hiç durmuyor; birkaç turdan sonra biz durdurduk.',
          'This code never stops; we paused it after a few turns.',
          'Dieser Code hört nie auf; wir haben nach ein paar Runden gestoppt.',
          'Este código no para nunca; lo pausamos tras unas vueltas.');
      ikon = Icons.all_inclusive_rounded;
      renk = const Color(0xFFB26A00);
    } else if (widget.dogru) {
      metin = _t(
          'Harika! Kodun hedefe ulaştı! 🎉',
          'Great! Your code reached the goal! 🎉',
          'Super! Dein Code hat das Ziel erreicht! 🎉',
          '¡Genial! ¡Tu código llegó a la meta! 🎉');
      ikon = Icons.check_circle;
      renk = Colors.green.shade700;
    } else {
      // Ceza yok: yanlis kod da calisir. Cocuga yalnizca neye
      // bakacagini soyluyoruz.
      metin = _t(
          'Kodun sonuna geldi. Hedefle karşılaştır!',
          'Your code reached the end. Compare it with the goal!',
          'Dein Code ist durchgelaufen. Vergleich ihn mit dem Ziel!',
          'Tu código llegó al final. ¡Compáralo con el objetivo!');
      ikon = Icons.flag_circle_rounded;
      renk = const Color(0xFF3D5A80);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(ikon, color: renk, size: 22),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            metin,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: renk,
              fontWeight: FontWeight.bold,
              fontSize: yazi,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  /// ACILIS SAHNESIYLE AYNI GORUNUM (Scratch kursu ders adimlari).
  ///
  /// Kart ve baslik (bayrak, dur) cagiranin [ScratchSahneKarti]'nda;
  /// burada yalnizca govde. Her sey sabit yerlerde: ustte 40 pt'lik bant
  /// (calisirken calisan blok + tur, bitince sonuc seridi), kuklanin
  /// ustunde konusma balonu, zeminde noktali yol ve kalem cizgisi.
  Widget _sahneGorunumu(ScratchBlock? calisan) {
    const ustBant = 40.0;
    return ScratchSahneZemini(builder: (context, boyut, zemin) {
      final kukla = widget.size;
      final dolgu = kukla / 2 + 6;
      final harita = _Harita(
        sinirlar: _sinirlar,
        genislik: boyut.width,
        // En alttaki noktada kuklanin ayaklari zemin cizgisinde.
        yukseklik: zemin + dolgu - kukla / 2 + 4,
        dolgu: dolgu,
        ustPay: ustBant,
        altaYasla: true,
      );
      final baslangic = harita.ekrana(Offset.zero);
      final bitis = harita.ekrana(_bitisNoktasi);
      final bitisFarkli = (bitis - baslangic).distance > 4;
      final w = boyut.width;

      return AnimatedBuilder(
        animation: Listenable.merge([_hareketC, _adimC]),
        builder: (context, _) {
          final simdi = harita.ekrana(_konum);
          final sallanma = _adimC.value;
          final kuklaUst = simdi.dy -
              kukla / 2 -
              (_havada ? 22 : 0) -
              sin(sallanma * pi) * 4;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _SahneBoyaci(
                    harita: harita,
                    cizgiler: [
                      ..._cizgiler,
                      if (_cizerekGidiyor) (_onceki, _konum),
                    ],
                    yol: [..._yol, _konum],
                    renk: _renk,
                    zeminCiz: false,
                  ),
                ),
              ),
              // Baslangic: yesil bayrak; bitis: damali bayrak.
              Positioned(
                left: baslangic.dx - 7,
                top: baslangic.dy + kukla / 2 - 20,
                child: const YesilBayrak(boyut: 15),
              ),
              if (bitisFarkli)
                Positioned(
                  left: bitis.dx - 8,
                  top: bitis.dy + kukla / 2 - 22,
                  child: AnimatedOpacity(
                    opacity: _bitti ? 1 : 0.55,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.sports_score_rounded,
                        size: 18, color: Color(0xFF3D5A80)),
                  ),
                ),
              // Lamba / nota / bekleme: sol ustte, bandin altinda.
              Positioned(
                left: 10,
                top: ustBant + 2,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (_lamba != null)
                    Container(
                      width: 22,
                      height: 22,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: _lamba,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _lamba!.withValues(alpha: 0.7),
                            blurRadius: 14,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  if (_nota != null)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(Icons.music_note_rounded,
                          size: 22, color: Color(0xFFCF63CF)),
                    ),
                  if (_bekliyor)
                    const Icon(Icons.hourglass_top_rounded,
                        size: 20, color: Color(0xFF5CB1D6)),
                ]),
              ),
              // Degiskenler: sag ustte, bandin altinda.
              if (_degiskenler.isNotEmpty)
                Positioned(
                  right: 8,
                  top: ustBant + 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final e in _degiskenler.entries.take(3))
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE2C2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: const Color(0xFFFF8C1A), width: 1.4),
                          ),
                          child: Text(
                            '${yorumlayiciAdi(e.key, widget.lang)}: ${e.value % 1 == 0 ? e.value.toInt() : e.value}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11.5,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              // Kukla (Devi).
              Positioned(
                left: simdi.dx - kukla / 2,
                top: kuklaUst,
                child: Transform.rotate(
                  angle: (_yon - 90) * pi / 180 +
                      (sallanma - 0.5) * 0.12 * (_adimC.isAnimating ? 1 : 0),
                  child: Transform.flip(
                    flipX: _ayna,
                    child: Mascot(
                      size: kukla,
                      showShadow: false,
                      mood: _bitti && widget.dogru
                          ? MascotMood.happy
                          : MascotMood.idle,
                    ),
                  ),
                ),
              ),
              // Konusma balonu kuklanin ustunde, onunla birlikte gidiyor.
              Positioned(
                left: 8,
                right: 8,
                bottom: boyut.height - kuklaUst + 2,
                child: IgnorePointer(
                  child: Align(
                    alignment: Alignment(
                        ((simdi.dx / max(w, 1)) * 2 - 1).clamp(-1.0, 1.0), 1),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: w * 0.7),
                      child: AnimatedOpacity(
                        opacity: _konusma != null ? 1 : 0,
                        duration: _hareketAzalt
                            ? Duration.zero
                            : const Duration(milliseconds: 200),
                        child: SahneBalonu(
                          key: const ValueKey('sahne_balonu'),
                          metin: _konusma ?? '',
                          kenar: _renk.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // UST BANT: calisirken calisan blok (+ tur), bitince sonuc.
              Positioned(
                left: 8,
                right: 8,
                top: 4,
                height: ustBant - 4,
                child: AnimatedSwitcher(
                  duration: _hareketAzalt
                      ? Duration.zero
                      : const Duration(milliseconds: 200),
                  child: (_bitti || _elleDurdu)
                      ? Container(
                          key: const ValueKey('sonuc'),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: _bitisSeridi(yazi: 12.5),
                        )
                      : calisan == null
                          ? const SizedBox.shrink()
                          : Align(
                              key: ValueKey('$_sira-$_tur'),
                              alignment: Alignment.centerLeft,
                              child: _calisanCipi(calisan),
                            ),
                ),
              ),
            ],
          );
        },
      );
    });
  }

  Widget _calisanCipi(ScratchBlock calisan) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: _scratchCipi(calisan, yuva: 32) ??
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: calisan.color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  calisan.labelFor(widget.lang),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
              ),
        ),
        if (_tur != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4D6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFBF00)),
            ),
            child: Text(
              _t('$_tur. tur', 'turn $_tur', '$_tur. Runde', 'vuelta $_tur'),
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF8A6100),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Hareket sahnesi: zemin, baslangic/bitis bayraklari, kalem cizgisi,
  /// lamba, nota ve maskot.
  Widget _sahne() {
    const yukseklik = 132.0;
    return LayoutBuilder(
      builder: (context, kutu) {
        final harita = _Harita(
          sinirlar: _sinirlar,
          genislik: kutu.maxWidth,
          yukseklik: yukseklik,
          dolgu: widget.size / 2 + 6,
        );
        final baslangic = harita.ekrana(Offset.zero);
        final bitis = harita.ekrana(_bitisNoktasi);
        final bitisFarkli = (bitis - baslangic).distance > 4;

        return SizedBox(
          height: yukseklik,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFEAF4FF),
                    Color.alphaBlend(
                        _renk.withValues(alpha: 0.08), Colors.white),
                  ],
                ),
              ),
              child: AnimatedBuilder(
                animation: Listenable.merge([_hareketC, _adimC]),
                builder: (context, _) {
                  final simdi = harita.ekrana(_konum);
                  final adimSallanma = _adimC.value;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Zemin ve kalem cizgileri.
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _SahneBoyaci(
                            harita: harita,
                            cizgiler: [
                              ..._cizgiler,
                              if (_cizerekGidiyor) (_onceki, _konum),
                            ],
                            yol: [..._yol, _konum],
                            renk: _renk,
                          ),
                        ),
                      ),
                      // Baslangic: yesil bayrak.
                      Positioned(
                        left: baslangic.dx - 9,
                        top: baslangic.dy + widget.size / 2 - 22,
                        child: const Text('🚩', style: TextStyle(fontSize: 16)),
                      ),
                      // Bitis: kodun gidecegi yer.
                      if (bitisFarkli)
                        Positioned(
                          left: bitis.dx - 9,
                          top: bitis.dy + widget.size / 2 - 22,
                          child: AnimatedOpacity(
                            opacity: _bitti ? 1 : 0.55,
                            duration: const Duration(milliseconds: 300),
                            child: const Text('🏁',
                                style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      if (_lamba != null)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: _lamba,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _lamba!.withValues(alpha: 0.7),
                                  blurRadius: 16,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (_nota != null)
                        Positioned(
                          right: 12,
                          top: 10,
                          child: Text(_nota!,
                              style: const TextStyle(fontSize: 26)),
                        ),
                      if (_bekliyor)
                        const Positioned(
                          right: 12,
                          bottom: 8,
                          child: Text('⏳', style: TextStyle(fontSize: 24)),
                        ),
                      // Kukla. Yururken adim adim sallaniyor; baktigi yone
                      // donuyor; "sonraki kostum"da aynalaniyor.
                      Positioned(
                        left: simdi.dx - widget.size / 2,
                        top: simdi.dy -
                            widget.size / 2 -
                            (_havada ? 22 : 0) -
                            sin(adimSallanma * pi) * 4,
                        child: Transform.rotate(
                          angle: (_yon - 90) * pi / 180 +
                              (adimSallanma - 0.5) *
                                  0.12 *
                                  (_adimC.isAnimating ? 1 : 0),
                          child: Transform.flip(
                            flipX: _ayna,
                            child: Mascot(
                              size: widget.size,
                              showShadow: false,
                              mood: _bitti && widget.dogru
                                  ? MascotMood.happy
                                  : MascotMood.idle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /// Hareketsiz kodda sahne yerine sade maskot.
  Widget _sadeMaskot() => SizedBox(
        height: 96,
        child: Center(
          child: AnimatedSlide(
            offset: _havada ? const Offset(0, -0.15) : Offset.zero,
            duration: const Duration(milliseconds: 200),
            child: Transform.flip(
              flipX: _ayna,
              child: Mascot(
                size: widget.size + 10,
                mood:
                    _bitti && widget.dogru ? MascotMood.happy : MascotMood.idle,
              ),
            ),
          ),
        ),
      );

  /// Kodda sahnede gorunur bir sey yapan blok var mi?
  ///
  /// Kendi blogunun govdesindeki bloklar da sayiliyor: `cokgen 6`
  /// cagrisi kod alaninda tek bir blok ama sahnede altigen ciziyor.
  bool get _hareketVar => [
        ...widget.blocks,
        for (final a in _yurutme.adimlar)
          if (a.blok != null) a.blok!,
      ].any((b) {
        final e = _etkisi(b);
        return e == _Etki.hareket ||
            e == _Etki.ziplama ||
            e == _Etki.isik ||
            e == _Etki.ses;
      });
}

/// Dunya koordinatini (Scratch adimlari, y yukari) sahne kutusuna
/// (piksel, y asagi) ceviren esleme. Tek olcek: kare kare kalsin.
class _Harita {
  _Harita({
    required this.sinirlar,
    required this.genislik,
    required this.yukseklik,
    required this.dolgu,
    this.ustPay = 0,
    this.altaYasla = false,
  });

  final Rect sinirlar;
  final double genislik;
  final double yukseklik;
  final double dolgu;

  /// Ustte kuklanin cikmayacagi bant (sahne gorunumunde cip/serit yeri).
  final double ustPay;

  /// En alttaki nokta hep zeminde (sahne gorunumu): dikeyde ortalanmiyor.
  final bool altaYasla;

  late final double _icGenislik = max(1, genislik - 2 * dolgu);
  late final double _icYukseklik = max(1, yukseklik - 2 * dolgu - ustPay);

  late final double _olcek = () {
    final sx =
        sinirlar.width > 0 ? _icGenislik / sinirlar.width : double.infinity;
    final sy =
        sinirlar.height > 0 ? _icYukseklik / sinirlar.height : double.infinity;
    final o = min(sx, sy);
    return o.isFinite ? o : 1.0;
  }();

  Offset ekrana(Offset dunya) {
    // Yatay hareket yoksa kukla ortada; dikey hareket yoksa zeminde.
    final double x = sinirlar.width > 0
        ? dolgu +
            (_icGenislik - sinirlar.width * _olcek) / 2 +
            (dunya.dx - sinirlar.left) * _olcek
        : genislik / 2;
    final double y = sinirlar.height > 0
        ? yukseklik -
            dolgu -
            (altaYasla ? 0 : (_icYukseklik - sinirlar.height * _olcek) / 2) -
            (dunya.dy - sinirlar.top) * _olcek
        : yukseklik - dolgu;
    return Offset(x, y);
  }

  /// Ayni olcuyle mi kurulmus? (Boyacinin yeniden cizip cizmeyecegi.)
  bool ayni(_Harita o) =>
      o.sinirlar == sinirlar &&
      o.genislik == genislik &&
      o.yukseklik == yukseklik &&
      o.dolgu == dolgu &&
      o.ustPay == ustPay &&
      o.altaYasla == altaYasla;

  /// Zemin cizgisinin yuksekligi: en alttaki noktada kuklanin ayaklari.
  double get zemin =>
      ekrana(Offset(sinirlar.left, sinirlar.top)).dy + (dolgu - 6);
}

class _SahneBoyaci extends CustomPainter {
  _SahneBoyaci({
    required this.harita,
    required this.cizgiler,
    required this.yol,
    required this.renk,
    this.zeminCiz = true,
  });

  final _Harita harita;
  final bool zeminCiz;
  final List<(Offset, Offset)> cizgiler;

  /// Kuklanin ugradigi noktalar (dunya koordinati), sonuncusu su anki yer.
  final List<Offset> yol;
  final Color renk;

  @override
  void paint(Canvas canvas, Size size) {
    // Zemin (sahne gorunumunde zemini ScratchSahneZemini ciziyor).
    final zeminY = min(size.height - 4, harita.zemin);
    if (zeminCiz) {
      canvas.drawLine(
        Offset(8, zeminY),
        Offset(size.width - 8, zeminY),
        Paint()
          ..color = const Color(0xFF7CB342).withValues(alpha: 0.55)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }

    // Yurunen yol: noktali iz.
    final nokta = Paint()..color = renk.withValues(alpha: 0.35);
    for (var k = 0; k + 1 < yol.length; k++) {
      final a = harita.ekrana(yol[k]);
      final b = harita.ekrana(yol[k + 1]);
      final uzunluk = (b - a).distance;
      if (uzunluk < 6) continue;
      final adet = (uzunluk / 12).floor();
      for (var i = 0; i <= adet; i++) {
        canvas.drawCircle(Offset.lerp(a, b, i / max(adet, 1))!, 2.2, nokta);
      }
    }

    // Kalem cizgileri.
    final kalem = Paint()
      ..color = renk
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    for (final (p, q) in cizgiler) {
      canvas.drawLine(harita.ekrana(p), harita.ekrana(q), kalem);
    }
  }

  /// Yalnizca cizilen sey degistiyse. Eskiden her zaman `true`: kukla
  /// her karede sallanirken kalem cizgileri ve noktali yol da bastan
  /// ciziliyordu.
  @override
  bool shouldRepaint(covariant _SahneBoyaci old) =>
      old.renk != renk ||
      old.zeminCiz != zeminCiz ||
      !old.harita.ayni(harita) ||
      !listEquals(old.cizgiler, cizgiler) ||
      !listEquals(old.yol, yol);
}
