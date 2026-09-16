import 'dart:math';

import 'package:flutter/foundation.dart';
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
      return result as String?;
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
