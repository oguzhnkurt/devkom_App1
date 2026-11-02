import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

/// 51 DIL: dort elle yazilmis dilin (tr, en, de, es) disindaki diller.
///
/// KARAR (2 Kasim 2026, kullanici): arayuz ve magaza sayfalari 51 dilde;
/// ders icerigi simdilik dort dilde kalir, diger dillerde Ingilizcesi
/// gorunur.
///
/// NASIL CALISIYOR
/// ---------------
/// Kod tabaninda metinler `AppLang.pick(lang, tr:, en:, de:, es:)` ve onun
/// sarmalayicilariyla (`_t`, `devreT`, `tanitimMetni`) yaziliyor. 1000'i
/// asan cagriyi 47 dil icin tek tek degistirmek yerine Ingilizce metin
/// ANAHTAR olarak kullaniliyor: `assets/l10n/<dil>.json` icinde
/// `"Ingilizce": "ceviri"` eslemesi var. `pick` dort dilin disindaki bir
/// dilde bu tablodan bakiyor; bulamazsa Ingilizceyi gosteriyor (eski
/// davranis). Yani eksik bir ceviri ekrani bozmuyor.
///
/// DEGISKENLI METINLER (`'$n coins'` gibi) calisma aninda doldurulmus
/// geliyor; tabloda birebir bulunamazlar. Bunlar icin JSON'da `{0}`,
/// `{1}` yer tutuculu SABLONLAR var (`"{0} coins": "{0} piéces"`).
/// Sablonlar duzenli ifadeye cevrilip eslesen degerler ceviriye yerine
/// konuyor.
///
/// Tablolar `tool/ceviri_kaynagi.py` ile uretilen `assets/l10n/_kaynak.json`
/// dosyasindan cevrildi. Yeni metin eklenince betik yeniden calistirilir;
/// cevrilmemis yeni metin Ingilizce gorunur.
class Ceviri {
  Ceviri._();

  static String? _dil;
  static Map<String, String> _tablo = const {};
  static List<_Sablon> _sablonlar = const [];

  /// Sablon aramasi pahali (her cagri tum sablonlari dener); sonuc,
  /// bulunamayanlar dahil, onbellekte tutuluyor.
  static final Map<String, String?> _onbellek = {};

  /// Yuklu dil (yoksa null). Geleneksel Cince'de 'zh'.
  static String? get dil => _dil;

  /// Yuklu tablonun dil secimindeki kodu ('zh-Hant' dahil).
  static String? get dosya => _dosya;

  /// Bir dilin tablosunu yukler. Dort elle yazilan dilde tablo yok.
  /// [dil] dil secimindeki kod ('zh-Hant' dahil). `pick` dil kodunu
  /// Locale'den aldigi icin Geleneksel Cince tablosu 'zh' anahtariyla
  /// cevap veriyor.
  static String? _dosya;

  static Future<void> yukle(String dil) async {
    if (_dosya == dil) return;
    _dosya = dil;
    if (const {'tr', 'en', 'de', 'es'}.contains(dil)) {
      _dil = dil;
      _tablo = const {};
      _sablonlar = const [];
      return;
    }
    try {
      final ham = await rootBundle.loadString('assets/l10n/$dil.json');
      tabloyuAyarla(dil == 'zh-Hant' ? 'zh' : dil,
          (jsonDecode(ham) as Map).cast<String, String>());
    } catch (e) {
      debugPrint('⚠️ Ceviri tablosu yuklenemedi ($dil): $e');
      _dil = dil;
      _tablo = const {};
      _sablonlar = const [];
    }
  }

  /// Testler ve [yukle] icin: tabloyu dogrudan ayarlar.
  static void tabloyuAyarla(String dil, Map<String, String> tablo) {
    _dosya ??= dil;
    _dil = dil;
    _tablo = tablo;
    _onbellek.clear();
    // Uzun (daha belirgin) sablon once denenir: "{0} coins left" ile
    // "{0} coins" ayni metne uyabiliyor.
    _sablonlar = [
      for (final e in tablo.entries)
        if (e.key.contains('{0}')) _Sablon(e.key, e.value),
    ]..sort((a, b) => b.uzunluk.compareTo(a.uzunluk));
  }

  /// [en] metninin [dil] cevirisi; yoksa null.
  static String? bul(String dil, String en) {
    if (dil != _dil || _tablo.isEmpty) return null;
    final dogrudan = _tablo[en];
    if (dogrudan != null && dogrudan.isNotEmpty) return dogrudan;
    if (_onbellek.containsKey(en)) return _onbellek[en];
    String? sonuc;
    for (final s in _sablonlar) {
      sonuc = s.uygula(en);
      if (sonuc != null) break;
    }
    if (_onbellek.length > 2000) _onbellek.clear();
    _onbellek[en] = sonuc;
    return sonuc;
  }
}

class _Sablon {
  _Sablon(String kaynak, this.hedef)
      : _re = _derle(kaynak),
        uzunluk = kaynak.replaceAll(RegExp(r'\{\d+\}'), '').length;

  final String hedef;
  final int uzunluk;
  final RegExp _re;

  static RegExp _derle(String kaynak) {
    final b = StringBuffer('^');
    final parca = RegExp(r'\{(\d+)\}');
    var i = 0;
    for (final m in parca.allMatches(kaynak)) {
      b.write(RegExp.escape(kaynak.substring(i, m.start)));
      b.write('(.+?)');
      i = m.end;
    }
    b.write(RegExp.escape(kaynak.substring(i)));
    b.write(r'$');
    return RegExp(b.toString(), dotAll: true);
  }

  String? uygula(String metin) {
    final m = _re.firstMatch(metin);
    if (m == null) return null;
    var s = hedef;
    for (var g = 1; g <= m.groupCount; g++) {
      s = s.replaceAll('{${g - 1}}', m.group(g)!);
    }
    return s;
  }
}
