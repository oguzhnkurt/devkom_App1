import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../courses/models/interactive_lesson_model.dart';
import '../utils/lang.dart';

/// Cocugun kurdugu blok dizisini sahnede canlandirir.
///
/// ONCEKI SURUM NEREDEYSE HICBIR SEY GOSTERMIYORDU.
///
/// Oynatici yalnizca `say_`, `move_` ve `repeat_` ile baslayan kimlikleri
/// taniyordu; geri kalan her blok sessizce ATLANIYORDU. Ders verisindeki
/// 58 farkli blok kimliginden yalnizca 5'i bu uce giriyor. Yani
/// "KODU CALISTIR" tusuna basan cocuk, cogu derste kedinin kimildamadigi
/// bir sahne ve hemen ardindan "Animasyon tamamlandi!" yazisi
/// goruyordu — kodu calismis gibi yapan, ama hicbir sey yapmayan bir
/// ekran.
///
/// Yeni oynatici iki seyi birden yapiyor:
///
///   1. HER blogu sirayla, adi ekranda yazili olarak calistiriyor. Bir
///      blogun gorsel bir etkisi olmasa bile (yesil bayrak, yayin
///      gonderme, klon) cocuk onun sirasinin geldigini goruyor.
///   2. Tanidigi etkileri sahnede gosteriyor: yurume, ziplama, konusma,
///      bekleme, degisken degeri, ses ve lamba.
///
/// Boylece ekran artik yalan soylemiyor: gercekten calisan bir sey var.
class BlockAnimationPlayer extends StatefulWidget {
  const BlockAnimationPlayer({
    super.key,
    required this.blocks,
    required this.lang,
    this.size = 60,
    this.onComplete,
  });

  final List<ScratchBlock> blocks;
  final String lang;
  final double size;
  final VoidCallback? onComplete;

  @override
  State<BlockAnimationPlayer> createState() => _BlockAnimationPlayerState();
}

/// Bir blogun sahnedeki karsiligi.
enum _Etki { hareket, ziplama, konus, bekle, degisken, ses, isik, yapisal }

class _BlockAnimationPlayerState extends State<BlockAnimationPlayer> {
  static const _adimSuresi = Duration(milliseconds: 500);
  final _rastgele = Random();

  int _sira = -1; // o an calisan blogun sirasi
  double _x = 0; // sahnedeki yatay konum, 0..1
  bool _havada = false;
  String? _konusma;
  bool _bekliyor = false;
  String? _nota;
  Color? _lamba;
  final Map<String, int> _degiskenler = {};
  bool _bitti = false;
  bool _durduruldu = false;

  @override
  void initState() {
    super.initState();
    _calistir();
  }

  @override
  void dispose() {
    _durduruldu = true;
    super.dispose();
  }

  String _t(String tr, String en, String de, String es) =>
      AppLang.pick(widget.lang, tr: tr, en: en, de: de, es: es);

  /// Bir sonraki adima gecmeden once beklerken ekran kapanmis olabilir.
  Future<bool> _bekle(Duration d) async {
    await Future.delayed(d);
    return mounted && !_durduruldu;
  }

  // ---------------------------------------------------------------
  // Blok siniflandirmasi
  // ---------------------------------------------------------------

  _Etki _etkisi(String id) {
    if (id.startsWith('change_y')) return _Etki.ziplama;
    if (id.startsWith('change_x') || id.startsWith('move_') ||
        id.startsWith('goto_')) {
      return _Etki.hareket;
    }
    if (id.startsWith('say_')) return _Etki.konus;
    if (id.startsWith('wait')) return _Etki.bekle;
    if (id.contains('note') || id.contains('sound')) return _Etki.ses;
    if (id.contains('led') ||
        id.startsWith('red_') ||
        id.startsWith('green_') ||
        id.startsWith('yellow_') ||
        id == 'pwm_set') {
      return _Etki.isik;
    }
    if (id.startsWith('set_') ||
        id.startsWith('change_') ||
        id == 'increment') {
      return _Etki.degisken;
    }
    return _Etki.yapisal;
  }

  /// Blok bir dongu mu? Kac kez?
  ///
  /// `forever` sonsuz; sahnede uc tur gosteriyoruz — sonsuza kadar donen
  /// bir animasyon cocugu adimin geri kalanindan koparirdi.
  int? _donguSayisi(String id) {
    if (id == 'forever') return 3;
    final m = RegExp(r'repeat_(\d+)').firstMatch(id);
    if (m != null) return int.tryParse(m.group(1)!) ?? 2;
    return null;
  }

  // ---------------------------------------------------------------
  // Calistirma
  // ---------------------------------------------------------------

  Future<void> _calistir() async {
    for (var i = 0; i < widget.blocks.length; i++) {
      final blok = widget.blocks[i];
      final tekrar = _donguSayisi(blok.id);

      if (tekrar != null) {
        if (!await _blogaGec(i)) return;
        final icerdeki = i + 1 < widget.blocks.length ? widget.blocks[i + 1] : null;
        if (icerdeki == null || _donguSayisi(icerdeki.id) != null) {
          continue; // bos dongu
        }
        for (var t = 0; t < tekrar; t++) {
          if (!await _blogaGec(i + 1)) return;
          if (!await _etkiUygula(icerdeki)) return;
        }
        i++; // icerdeki blok bir daha tek basina calismasin
        continue;
      }

      if (!await _blogaGec(i)) return;
      if (!await _etkiUygula(blok)) return;
    }

    if (!mounted || _durduruldu) return;
    setState(() {
      _sira = -1;
      _bitti = true;
    });
    widget.onComplete?.call();
  }

  /// Sirayi [i]. bloga alir ve okunacak kadar bekler.
  Future<bool> _blogaGec(int i) async {
    if (!mounted || _durduruldu) return false;
    setState(() => _sira = i);
    return _bekle(_adimSuresi);
  }

  Future<bool> _etkiUygula(ScratchBlock blok) async {
    switch (_etkisi(blok.id)) {
      case _Etki.hareket:
        return _hareket(blok.id);
      case _Etki.ziplama:
        return _zipla();
      case _Etki.konus:
        return _konus(blok);
      case _Etki.bekle:
        return _beklemeGoster();
      case _Etki.degisken:
        return _degiskenGuncelle(blok.id);
      case _Etki.ses:
        return _sesCal();
      case _Etki.isik:
        return _isikYak(blok.id);
      case _Etki.yapisal:
        // Gorsel etkisi yok; adim satiri zaten blogun adini gosterdi.
        return true;
    }
  }

  Future<bool> _hareket(String id) async {
    double hedef;
    if (id == 'goto_corner') {
      hedef = 1;
    } else if (id == 'goto_center') {
      hedef = 0.5;
    } else if (id == 'goto_random') {
      hedef = _rastgele.nextDouble();
    } else {
      final m = RegExp(r'(\d+)').firstMatch(id);
      final adim = m == null ? 10 : (int.tryParse(m.group(1)!) ?? 10);
      hedef = (_x + adim / 40).clamp(0.0, 1.0);
    }
    setState(() => _x = hedef);
    return _bekle(const Duration(milliseconds: 700));
  }

  Future<bool> _zipla() async {
    setState(() => _havada = true);
    if (!await _bekle(const Duration(milliseconds: 350))) return false;
    setState(() => _havada = false);
    return _bekle(const Duration(milliseconds: 350));
  }

  Future<bool> _konus(ScratchBlock blok) async {
    // Metin blogun KENDI yazisindan cikariliyor: "Miyav! de" -> "Miyav!"
    // Eskiden kimlige gore sabit Turkce metinler vardi (say_hello ->
    // 'Merhaba!'), yani Ingilizce derste de Turkce konusuyordu.
    final etiket = blok.labelFor(widget.lang);
    final temiz = etiket
        .replaceAll(RegExp(r'^\s*(say|sage|decir|di)\s+', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+(de|sagen)\s*$', caseSensitive: false), '')
        .trim();
    setState(() => _konusma = temiz.isEmpty ? etiket : temiz);
    if (!await _bekle(const Duration(milliseconds: 1200))) return false;
    setState(() => _konusma = null);
    return true;
  }

  Future<bool> _beklemeGoster() async {
    setState(() => _bekliyor = true);
    if (!await _bekle(const Duration(milliseconds: 900))) return false;
    setState(() => _bekliyor = false);
    return true;
  }

  Future<bool> _degiskenGuncelle(String id) async {
    final ad = _degiskenAdi(id);
    setState(() {
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
  // Cizim
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final calisan = _sira >= 0 && _sira < widget.blocks.length
        ? widget.blocks[_sira]
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200, width: 2),
      ),
      child: Column(
        children: [
          Text(
            _t('🎬 Kodun çalışıyor!', '🎬 Your code is running!',
                '🎬 Dein Code läuft!', '🎬 ¡Tu código se está ejecutando!'),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 10),

          // O AN CALISAN BLOK.
          //
          // Gorsel etkisi olmayan bloklarda bile bir sey olmasini saglayan
          // sey bu satir. Yeri bastan ayrilmis: blok degisince altindaki
          // sahne yerinden oynamiyor.
          SizedBox(
            height: 34,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: calisan == null
                  ? const SizedBox.shrink()
                  : Container(
                      key: ValueKey(_sira),
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
          ),
          const SizedBox(height: 8),

          // Degisken degerleri
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
                                border:
                                    Border.all(color: Colors.orange, width: 1.5),
                              ),
                              child: Text(
                                '${e.key}: ${e.value}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
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
                    border: Border.all(color: Colors.blue, width: 2.5),
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
          const SizedBox(height: 6),

          // Sahne
          LayoutBuilder(
            builder: (context, kutu) {
              final genislik = kutu.maxWidth - widget.size;
              return SizedBox(
                height: 96,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      bottom: 8,
                      child: Container(width: 4, height: 72, color: Colors.green),
                    ),
                    if (_lamba != null)
                      Positioned(
                        right: 6,
                        top: 6,
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
                        bottom: 40,
                        child: Text(_nota!,
                            style: const TextStyle(fontSize: 26)),
                      ),
                    if (_bekliyor)
                      const Positioned(
                        right: 12,
                        bottom: 8,
                        child: Text('⏳', style: TextStyle(fontSize: 24)),
                      ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 650),
                      curve: Curves.easeInOut,
                      left: (genislik * _x).clamp(0.0, genislik),
                      bottom: _havada ? 34 : 8,
                      child: Text('🐱',
                          style: TextStyle(fontSize: widget.size)),
                    ),
                  ],
                ),
              );
            },
          ),

          if (_bitti) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 22),
                const SizedBox(width: 8),
                Text(
                  _t('Kodun sonuna geldin!', 'Your code reached the end!',
                      'Dein Code ist durchgelaufen!',
                      '¡Tu código llegó al final!'),
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
