import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/store_item_model.dart';

/// Sıralamanın iki kulvarı.
enum SiralamaKulvari {
  /// Toplam XP.
  genel,

  /// En zor seviyeyi en hızlı yenen üstte.
  satranc,
}

/// Sıralamadaki bir satır. Sunucu yalnızca sıralama için gereken alanları
/// veriyor: ilk ad + soyadın baş harfi, değer, takılı ürünler
/// (bkz. `supabase/migrations/37_siralama.sql`).
class SiralamaSatiri {
  const SiralamaSatiri({
    required this.sira,
    required this.ad,
    required this.ben,
    this.xp,
    this.seviye,
    this.zorluk,
    this.sure,
    this.cerceve,
    this.rozet,
    this.etiket,
  });

  final int sira;
  final String ad;
  final bool ben;

  /// Genel kulvar.
  final int? xp;
  final int? seviye;

  /// Satranç kulvarı: 0 Kolay, 1 Orta, 2 Zor, 3 İmkânsız; süre saniye.
  final int? zorluk;
  final int? sure;

  final StoreItem? cerceve;
  final StoreItem? rozet;
  final StoreItem? etiket;

  static StoreItem? _urun(dynamic v) {
    if (v is! Map) return null;
    try {
      return StoreItem.fromMap(Map<String, dynamic>.from(v));
    } catch (_) {
      return null;
    }
  }

  static int? _int(dynamic v) =>
      v is int ? v : (v is num ? v.toInt() : int.tryParse('${v ?? ''}'));

  factory SiralamaSatiri.fromMap(Map<String, dynamic> m) => SiralamaSatiri(
        sira: _int(m['sira']) ?? 0,
        ad: (m['ad'] as String?)?.trim().isNotEmpty == true
            ? (m['ad'] as String).trim()
            : 'DevEducation',
        ben: m['ben'] == true,
        xp: _int(m['xp']),
        seviye: _int(m['seviye']),
        zorluk: _int(m['zorluk']),
        sure: _int(m['sure']),
        cerceve: _urun(m['cerceve']),
        rozet: _urun(m['rozet']),
        etiket: _urun(m['etiket']),
      );
}

/// Sıralama verisi. Testlerde [rpcCagir] yerine sahtesi konuyor.
class SiralamaServisi {
  SiralamaServisi._();

  static const int varsayilanLimit = 50;

  @visibleForTesting
  static Future<dynamic> Function(String fn, Map<String, dynamic> params)?
      rpcCagir;

  static Future<dynamic> _rpc(String fn, Map<String, dynamic> p) {
    final sahte = rpcCagir;
    if (sahte != null) return sahte(fn, p);
    return Supabase.instance.client.rpc(fn, params: p);
  }

  /// İlk [limit] satır; çağıran ilk [limit]'te değilse kendi satırı da
  /// listenin sonunda (gerçek sırasıyla) geliyor.
  static Future<List<SiralamaSatiri>> getir(SiralamaKulvari k,
      {int limit = varsayilanLimit}) async {
    final fn = k == SiralamaKulvari.genel ? 'siralama_genel' : 'siralama_satranc';
    final cevap = await _rpc(fn, {'p_limit': limit});
    if (cevap is! List) return const [];
    return cevap
        .whereType<Map>()
        .map((m) => SiralamaSatiri.fromMap(Map<String, dynamic>.from(m)))
        .toList(growable: false);
  }

  /// Çağıranın kendi satırı (yoksa null).
  static SiralamaSatiri? benimSatirim(List<SiralamaSatiri> liste) {
    for (final s in liste) {
      if (s.ben) return s;
    }
    return null;
  }

  /// "4:07" gibi.
  static String sureYazisi(int saniye) {
    final d = saniye ~/ 60;
    final s = saniye % 60;
    return '$d:${s.toString().padLeft(2, '0')}';
  }
}
