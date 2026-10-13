import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Ebeveyn ile cocuk arasindaki bag.
class ChildLink {
  const ChildLink({required this.childId, this.childName});

  final String childId;
  final String? childName;
}

/// Eslestirme kodu ile ebeveyn baglama.
///
/// NEDEN KOD:
///
/// Uygulama acilirken kimseye "veli misin, ogrenci misin, ziyaretci
/// misin" diye sormuyoruz. Bu soru hem cocugu ilk ekranda gereksiz bir
/// karara zorluyordu hem de yanlis cevaplandiginda geri donusu olmayan
/// bir role kilitliyordu. Uygulama cocugun uygulamasi.
///
/// Ebeveyn takip etmek istediginde kimligini BEYAN ETMIYOR, cocugun
/// cihazindan aldigi alti karakterlik kodu giriyor. Bu, beyandan daha
/// guvenli: kodu gormek icin cocugun telefonuna fiziksel erisim ve
/// ebeveyn kapisindan gecmek gerekiyor.
///
/// Kod 24 saat sonra oluyor ve tek kullanimlik. Suresiz bir kod, bir
/// kere ekran goruntusune dustugunde kalici bir anahtara donusurdu.
class ChildLinkService {
  ChildLinkService._();

  static SupabaseClient get _db => Supabase.instance.client;

  // ------------------------------------------------ cihazdaki kayitli liste
  //
  // NEDEN (Ekim 2026 geri bildirimi): veli kodu yazip raporu acıyor, geri
  // donunce kart yeniden "kod yaz" kutusunu gosteriyordu. Bag sunucuda
  // kurulmustu ama `child_links` okumasi bos donuyordu (baglanti, oturum
  // ya da okuma izni) ve kart bunu "hic cocuk yok" diye yorumluyordu.
  // Basariyla baglanan cocuk artik bu cihazda da tutuluyor; sunucu
  // okumasi bos ya da hatali donse bile liste kaybolmuyor. Liste yalnizca
  // veli "listeden kaldir" dediginde kisaliyor.
  static const _yerelAnahtar = 'veli_takip_cocuklar_v1';

  static Future<List<ChildLink>> yerelCocuklar() async {
    try {
      final p = await SharedPreferences.getInstance();
      final ham = p.getString(_yerelAnahtar);
      if (ham == null || ham.isEmpty) return const [];
      return [
        for (final m in (jsonDecode(ham) as List).whereType<Map>())
          if ((m['id'] as String?)?.isNotEmpty ?? false)
            ChildLink(childId: m['id'] as String, childName: m['ad'] as String?),
      ];
    } catch (_) {
      return const [];
    }
  }

  static Future<void> _yereleYaz(List<ChildLink> liste) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(
        _yerelAnahtar,
        jsonEncode([
          for (final c in liste) {'id': c.childId, 'ad': c.childName},
        ]),
      );
    } catch (_) {}
  }

  /// Basariyla baglanan cocugu cihaza kaydeder (varsa adini gunceller).
  static Future<void> yerelEkle(ChildLink c) async {
    final liste = [...await yerelCocuklar()];
    final i = liste.indexWhere((x) => x.childId == c.childId);
    if (i < 0) {
      liste.add(c);
    } else if ((c.childName ?? '').isNotEmpty) {
      liste[i] = c;
    }
    await _yereleYaz(liste);
  }

  static Future<void> yerelCikar(String childId) async {
    final liste = [...await yerelCocuklar()]
      ..removeWhere((x) => x.childId == childId);
    await _yereleYaz(liste);
  }

  /// Sunucudaki liste + yalnizca bu cihazda kayitli olanlar.
  /// Sira: once sunucunun sirasi, sonra cihazdakiler eklenis sirasiyla.
  /// Ad sunucuda yoksa cihazdaki ad kullanilir.
  static List<ChildLink> birlestir(
      List<ChildLink> sunucu, List<ChildLink> yerel) {
    final yerelAd = {for (final c in yerel) c.childId: c.childName};
    final out = <ChildLink>[
      for (final c in sunucu)
        ChildLink(
          childId: c.childId,
          childName: (c.childName ?? '').trim().isNotEmpty
              ? c.childName
              : yerelAd[c.childId],
        ),
    ];
    final gorulen = {for (final c in out) c.childId};
    for (final c in yerel) {
      if (gorulen.add(c.childId)) out.add(c);
    }
    return out;
  }

  /// Kod alfabesi.
  ///
  /// Karistirilabilecek karakterler (0/O, 1/I/L) bilerek disarida:
  /// kodu telefondan telefona okuyarak aktaracak bir ebeveyn "O" ile
  /// "0"i ayirt etmek zorunda kalmasin.
  static const _alphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  static const int _length = 6;

  static String _generate() {
    final rnd = Random.secure();
    return List.generate(
      _length,
      (_) => _alphabet[rnd.nextInt(_alphabet.length)],
    ).join();
  }

  /// Kodu okunakli hale getirir: "ABC123" -> "ABC-123".
  static String pretty(String code) =>
      code.length == 6 ? '${code.substring(0, 3)}-${code.substring(3)}' : code;

  /// Cocugun cihazinda gecerli bir kod dondurur; yoksa uretir.
  ///
  /// Ayni anda tek kod olmasi veritabaninda benzersiz indeksle garanti;
  /// burada da once var olani ariyoruz ki ebeveyn kodu okurken cocuk
  /// ekrani yenilediginde kod degismesin.
  static Future<String?> currentCode() async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) return null;
    try {
      final row = await _db
          .from('child_link_codes')
          .select('code, expires_at')
          .eq('child_id', uid)
          .maybeSingle();

      if (row != null) {
        final expires = DateTime.tryParse(row['expires_at'] as String? ?? '');
        if (expires != null && expires.isAfter(DateTime.now())) {
          return row['code'] as String;
        }
        // Suresi dolmus: yerine yenisi.
        await _db.from('child_link_codes').delete().eq('child_id', uid);
      }

      final code = _generate();
      await _db.from('child_link_codes').insert({
        'code': code,
        'child_id': uid,
      });
      return code;
    } catch (e) {
      debugPrint('ChildLinkService.currentCode: $e');
      return null;
    }
  }

  /// Kodu iptal eder. Ebeveyn kodu yanlis kisiye gosterdiyse diye.
  static Future<void> revokeCode() async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) return;
    try {
      await _db.from('child_link_codes').delete().eq('child_id', uid);
    } catch (e) {
      debugPrint('ChildLinkService.revokeCode: $e');
    }
  }

  /// Ebeveyn cihazinda kodu kullanir.
  ///
  /// Basarisizsa null doner. Kod tablosunu ISTEMCI OKUYAMIYOR; islem
  /// sunucudaki `redeem_child_code` fonksiyonu uzerinden yapiliyor, aksi
  /// halde alti karakterlik kodlar tek tek denenerek baska cocuklarin
  /// hesabina baglanilabilirdi.
  static Future<String?> redeem(String code) async {
    final cleaned = code.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    if (cleaned.length != _length) return null;
    try {
      final result = await _db.rpc(
        'redeem_child_code',
        params: {'p_code': cleaned},
      );
      final id = result as String?;
      if (id != null && id.isNotEmpty) await yerelEkle(ChildLink(childId: id));
      return id;
    } catch (e) {
      debugPrint('ChildLinkService.redeem: $e');
      return null;
    }
  }

  /// Bu cihaz bir cocuga bagli mi? (Ebeveyn tarafi.)
  static Future<ChildLink?> linkedChild() async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) return null;
    try {
      final row = await _db
          .from('child_links')
          .select('child_id')
          .eq('parent_id', uid)
          .limit(1)
          .maybeSingle();
      if (row == null) return null;

      final childId = row['child_id'] as String;
      String? name;
      try {
        final user = await _db
            .from('users')
            .select('name')
            .eq('id', childId)
            .maybeSingle();
        name = user?['name'] as String?;
      } catch (_) {
        // Ad okunamazsa bag yine gecerli; sadece isimsiz gosteririz.
      }
      return ChildLink(childId: childId, childName: name);
    } catch (e) {
      debugPrint('ChildLinkService.linkedChild: $e');
      return null;
    }
  }

  /// Bu cihazin bagli oldugu BUTUN cocuklar (ebeveyn tarafi).
  ///
  /// Bir ebeveynin birden fazla cocugu olabiliyor; [linkedChild] yalnizca
  /// ilkini donduruyordu. Siralama baglanma zamanina gore: ilk eklenen
  /// cocuk listede hep ayni yerde kaliyor.
  static Future<List<ChildLink>> linkedChildren() async {
    final sunucu = await _sunucudakiCocuklar();
    final yerel = await yerelCocuklar();
    final liste = birlestir(sunucu, yerel);
    // Sunucudan gelen adlari cihaza da yaz: bir sonraki acilista hazir olsun.
    if (sunucu.isNotEmpty) await _yereleYaz(liste);
    return liste;
  }

  static Future<List<ChildLink>> _sunucudakiCocuklar() async {
    try {
      final uid = _db.auth.currentUser?.id;
      if (uid == null) return const [];
      final rows = await _db
          .from('child_links')
          .select('child_id, created_at')
          .eq('parent_id', uid)
          .order('created_at');
      final ids = [for (final r in rows as List) r['child_id'] as String];
      if (ids.isEmpty) return const [];

      final names = <String, String?>{};
      try {
        final users =
            await _db.from('users').select('id, name').inFilter('id', ids);
        for (final u in users as List) {
          names[u['id'] as String] = u['name'] as String?;
        }
      } catch (_) {
        // Ad okunamazsa bag yine gecerli; isimsiz gosteriyoruz.
      }
      return [
        for (final id in ids) ChildLink(childId: id, childName: names[id]),
      ];
    } catch (e) {
      debugPrint('ChildLinkService.linkedChildren: $e');
      return const [];
    }
  }

  /// Cocugun ilerleme satirini YALNIZCA OKUR.
  ///
  /// Eskiden rapor `UserProgressService.loadUserProgress` ile aliniyordu.
  /// O fonksiyon cocugun kendi cihazi icin yazilmis: satir gorunmezse
  /// YENI bir satir olusturuyor, gun donunde seriyi ve gunluk hedefleri
  /// sifirlayip YAZIYOR. Ebeveyn cihazinda bunlarin hicbiri olmamali.
  ///
  /// Satir okunamazsa (baglanti yok ya da veritabaninda ebeveyn okuma
  /// izni yok) null doner; rapor o zaman ilerleme olmadan kuruluyor ve
  /// bunu ekranda durustce soyluyor.
  static Future<Map<String, dynamic>?> childProgressRow(String childId) async {
    try {
      final row = await _db
          .from('user_progress')
          .select()
          .eq('user_id', childId)
          .maybeSingle();
      return row;
    } catch (e) {
      debugPrint('ChildLinkService.childProgressRow: $e');
      return null;
    }
  }

  /// Bu cocugu kimler takip ediyor? (Cocuk tarafi.)
  ///
  /// Cocuk kimin izledigini gorebilmeli — bu bir izleme ozelligi ve
  /// gizli calismasi dogru olmaz.
  static Future<int> watcherCount() async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) return 0;
    try {
      final rows = await _db
          .from('child_links')
          .select('parent_id')
          .eq('child_id', uid);
      return (rows as List).length;
    } catch (e) {
      debugPrint('ChildLinkService.watcherCount: $e');
      return 0;
    }
  }

  /// Cocuk butun takipcileri kaldirir.
  ///
  /// Tek tek kaldirma sunmuyoruz: cocuk ebeveynlerin adini GOREMIYOR
  /// (bunun icin baskasinin `users` satirini okumasi gerekirdi ve
  /// okumamali), dolayisiyla "hangisini kaldiriyorum" sorusuna
  /// durustce cevap veremezdik. "Hepsini kaldir" hem anlasilir hem
  /// geri alinabilir: ebeveyn yeni bir kodla tekrar baglanir.
  static Future<void> unlinkAllWatchers() async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) return;
    try {
      await _db.from('child_links').delete().eq('child_id', uid);
    } catch (e) {
      debugPrint('ChildLinkService.unlinkAllWatchers: $e');
    }
  }

  /// Bagi koparir. Iki taraf da yapabilir.
  static Future<void> unlink({String? childId, String? parentId}) async {
    if (childId != null) await yerelCikar(childId);
    final uid = _db.auth.currentUser?.id;
    if (uid == null) return;
    try {
      if (childId != null) {
        await _db
            .from('child_links')
            .delete()
            .eq('parent_id', uid)
            .eq('child_id', childId);
      } else if (parentId != null) {
        await _db
            .from('child_links')
            .delete()
            .eq('child_id', uid)
            .eq('parent_id', parentId);
      }
    } catch (e) {
      debugPrint('ChildLinkService.unlink: $e');
    }
  }
}
