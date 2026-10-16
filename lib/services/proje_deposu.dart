import 'dart:convert';
import 'dart:ui' show Offset;

import 'package:shared_preferences/shared_preferences.dart';

import '../courses/yurutme/kod_yapisi.dart';

/// Cocugun Proje Atolyesi'nde kaydettigi bir proje.
class KayitliProje {
  const KayitliProje({
    required this.id,
    required this.ad,
    required this.kursId,
    required this.kod,
    required this.tarih,
    this.adimId,
    this.konumlar = const {},
  });

  final String id;
  final String ad;
  final String kursId;

  /// Projenin acildigi atolye adimi (hedefleri ve paleti oradan). Bos
  /// atolyede null.
  final String? adimId;

  final List<KodOgesi> kod;

  /// Son kaydedilme zamani.
  final DateTime tarih;

  /// Cocugun sahnede surukleyip biraktigi kuklalarin BASLANGIC yerleri
  /// (kukla adi -> Scratch koordinati). Bos: atolyenin kendi yerleri.
  /// Eski kayitlarda yok; onlar varsayilan yerlerle aciliyor.
  final Map<String, Offset> konumlar;

  KayitliProje copyWith(
          {String? ad,
          List<KodOgesi>? kod,
          DateTime? tarih,
          Map<String, Offset>? konumlar}) =>
      KayitliProje(
        id: id,
        ad: ad ?? this.ad,
        kursId: kursId,
        adimId: adimId,
        kod: kod ?? this.kod,
        tarih: tarih ?? this.tarih,
        konumlar: konumlar ?? this.konumlar,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'ad': ad,
        'kurs': kursId,
        if (adimId != null) 'adim': adimId,
        'kod': [for (final o in kod) o.toJson()],
        't': tarih.millisecondsSinceEpoch,
        if (konumlar.isNotEmpty)
          'konum': {
            for (final e in konumlar.entries)
              e.key: [e.value.dx.round(), e.value.dy.round()],
          },
      };

  /// `{"Devi": [120, -40]}`; bozuk girdi atlaniyor (proje yine aciliyor).
  static Map<String, Offset> _konumlar(Object? j) {
    if (j is! Map) return const {};
    final out = <String, Offset>{};
    for (final e in j.entries) {
      final v = e.value;
      if (e.key is String &&
          v is List &&
          v.length == 2 &&
          v[0] is num &&
          v[1] is num) {
        out[e.key as String] =
            Offset((v[0] as num).toDouble(), (v[1] as num).toDouble());
      }
    }
    return out;
  }

  static KayitliProje? fromJson(Object? j) {
    if (j is! Map) return null;
    try {
      return KayitliProje(
        id: j['id'] as String,
        ad: j['ad'] as String,
        kursId: j['kurs'] as String,
        adimId: j['adim'] as String?,
        kod: [
          for (final o in (j['kod'] as List))
            KodOgesi.fromJson(Map<String, Object?>.from(o as Map)),
        ],
        tarih: DateTime.fromMillisecondsSinceEpoch(j['t'] as int),
        konumlar: _konumlar(j['konum']),
      );
    } catch (_) {
      // Bozuk kayit butun listeyi kaybettirmesin.
      return null;
    }
  }
}

/// "Projelerim": kayitli projeler cihazda (SharedPreferences, JSON).
///
/// Neden bulutta degil: projeler kucuk, cocugun kendi cihazinda; hesap
/// istemeden calismali (misafir oturumu). Ileride ilerleme gibi bulutla
/// esitlenebilir; bicim surumlu ([anahtar]).
class ProjeDeposu {
  ProjeDeposu._();

  static const String anahtar = 'projelerim_v1';

  /// En fazla bu kadar proje tutuluyor (en eskiler dusuyor).
  static const int sinir = 50;

  static Future<List<KayitliProje>> tumu({String? kursId}) async {
    final p = await SharedPreferences.getInstance();
    final ham = p.getString(anahtar);
    if (ham == null) return [];
    List<Object?> liste;
    try {
      liste = jsonDecode(ham) as List<Object?>;
    } catch (_) {
      return [];
    }
    final out = [
      for (final j in liste)
        if (KayitliProje.fromJson(j) case final k?)
          if (kursId == null || k.kursId == kursId) k,
    ]..sort((a, b) => b.tarih.compareTo(a.tarih));
    return out;
  }

  static Future<void> _yaz(List<KayitliProje> liste) async {
    final p = await SharedPreferences.getInstance();
    liste.sort((a, b) => b.tarih.compareTo(a.tarih));
    final kirp = liste.take(sinir).toList();
    await p.setString(
        anahtar, jsonEncode([for (final k in kirp) k.toJson()]));
  }

  /// Kaydeder (ayni kimlik varsa ustune yazar). Kaydedileni dondurur.
  static Future<KayitliProje> kaydet(KayitliProje proje) async {
    final liste = await tumu();
    liste.removeWhere((k) => k.id == proje.id);
    liste.add(proje);
    await _yaz(liste);
    return proje;
  }

  static Future<KayitliProje?> bul(String id) async {
    for (final k in await tumu()) {
      if (k.id == id) return k;
    }
    return null;
  }

  static Future<void> sil(String id) async {
    final liste = await tumu();
    liste.removeWhere((k) => k.id == id);
    await _yaz(liste);
  }

  /// Yeni bir proje kimligi.
  static String yeniKimlik() =>
      'p${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}';
}
