import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_update/in_app_update.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_version.dart';
import '../theme.dart';
import '../utils/lang.dart';

/// "Yeni sürüm mevcut" uyarısı (Ekim 2026).
///
/// NEDEN
/// Mağazada yeni sürüm çıktığında (ör. AdMob askısında reklamların
/// kaldırıldığı 1.0.16) eski sürümde kalan çocuk eski ekranları görmeye
/// devam ediyordu. Uygulama açılınca mağazadaki sürüme bakılıyor; daha
/// yeniyse kısa bir pencere çıkıyor, "Güncelle" mağazada uygulamanın
/// sayfasını (Güncelle düğmesinin olduğu yer) açıyor.
///
/// NEREDEN ÖĞRENİLİYOR
/// * iOS: Apple'ın herkese açık arama servisi
///   (`itunes.apple.com/lookup?bundleId=...`) mağazadaki sürüm adını
///   veriyor; `AppVersion.name` ile karşılaştırılıyor.
/// * Android: Google Play'in kendi güncelleme API'si (`in_app_update`).
///   Yalnızca Play'den kurulmuş uygulamada çalışıyor; değilse sessizce
///   hiçbir şey yapmıyor.
///
/// NE KADAR SIK
/// Oturum başına bir kez; "Sonra" denirse aynı sürüm için günde en fazla
/// bir kez. Ağ yoksa, servis yanıt vermezse ya da cevap anlaşılmazsa uyarı
/// çıkmıyor — çocuğun önüne hiçbir zaman hata penceresi gelmiyor.
class GuncellemeServisi {
  GuncellemeServisi._();

  static const String bundleId = 'com.devkom.app';
  static const String appStoreId = '6775481665';

  static const String _sonSorulanSurum = 'guncelleme.son_sorulan_surum';
  static const String _sonSorulanGun = 'guncelleme.son_sorulan_gun';

  static bool _buOturumdaBakildi = false;

  /// Testler oturum kilidini sıfırlayabilsin diye.
  @visibleForTesting
  static void sifirla() => _buOturumdaBakildi = false;

  /// [magaza] sürümü [yerel]den yeni mi? "1.0.16" > "1.0.15", "1.1" > "1.0.9".
  /// Anlaşılmayan bir değer gelirse false (uyarı yok).
  static bool dahaYeni(String magaza, String yerel) {
    List<int>? parcala(String s) {
      final p = s.trim().split('.');
      final sayilar = <int>[];
      for (final x in p) {
        final n = int.tryParse(x);
        if (n == null) return null;
        sayilar.add(n);
      }
      return sayilar.isEmpty ? null : sayilar;
    }

    final a = parcala(magaza);
    final b = parcala(yerel);
    if (a == null || b == null) return false;
    final uzunluk = a.length > b.length ? a.length : b.length;
    for (var i = 0; i < uzunluk; i++) {
      final x = i < a.length ? a[i] : 0;
      final y = i < b.length ? b[i] : 0;
      if (x != y) return x > y;
    }
    return false;
  }

  /// Apple arama servisinin cevabından sürüm adı.
  @visibleForTesting
  static String? appStoreSurumu(String govde) {
    try {
      final json = jsonDecode(govde);
      final sonuclar = (json as Map)['results'] as List?;
      if (sonuclar == null || sonuclar.isEmpty) return null;
      final v = (sonuclar.first as Map)['version'];
      return v is String && v.trim().isNotEmpty ? v.trim() : null;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> _iosYeniVar() async {
    final uri = Uri.https('itunes.apple.com', '/lookup', {
      'bundleId': bundleId,
      'country': 'tr',
      // Apple bu cevabı önbellekte tutuyor; her açılışta farklı bir
      // parametre yeni sürümün daha erken görülmesini sağlıyor.
      't': '${DateTime.now().millisecondsSinceEpoch ~/ 3600000}',
    });
    final cevap = await http.get(uri).timeout(const Duration(seconds: 6));
    if (cevap.statusCode != 200) return false;
    final surum = appStoreSurumu(cevap.body);
    return surum != null && dahaYeni(surum, AppVersion.name);
  }

  static Future<bool> _androidYeniVar() async {
    final bilgi =
        await InAppUpdate.checkForUpdate().timeout(const Duration(seconds: 6));
    return bilgi.updateAvailability == UpdateAvailability.updateAvailable;
  }

  /// Mağazadaki sayfa: Güncelle düğmesi orada.
  static Future<void> magazayiAc() async {
    if (!kIsWeb && Platform.isIOS) {
      await launchUrl(Uri.parse('https://apps.apple.com/app/id$appStoreId'),
          mode: LaunchMode.externalApplication);
      return;
    }
    final market = Uri.parse('market://details?id=$bundleId');
    try {
      if (await launchUrl(market, mode: LaunchMode.externalApplication)) {
        return;
      }
    } catch (_) {}
    await launchUrl(
        Uri.parse('https://play.google.com/store/apps/details?id=$bundleId'),
        mode: LaunchMode.externalApplication);
  }

  /// Uygulama açılınca bir kez çağrılıyor (ana sayfa).
  static Future<void> kontrolEt(BuildContext context,
      {required String lang}) async {
    if (_buOturumdaBakildi) return;
    _buOturumdaBakildi = true;
    // Geliştirme derlemesinde mağazadaki sürüm hep "daha yeni" görünür.
    if (!kReleaseMode || kIsWeb) return;
    if (!Platform.isIOS && !Platform.isAndroid) return;

    bool yeniVar;
    try {
      yeniVar = Platform.isIOS ? await _iosYeniVar() : await _androidYeniVar();
    } catch (_) {
      return;
    }
    if (!yeniVar || !context.mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final bugun = DateTime.now().toIso8601String().substring(0, 10);
    if (prefs.getString(_sonSorulanGun) == bugun &&
        prefs.getString(_sonSorulanSurum) == AppVersion.name) {
      return;
    }
    await prefs.setString(_sonSorulanGun, bugun);
    await prefs.setString(_sonSorulanSurum, AppVersion.name);
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (_) => GuncellemePenceresi(lang: lang),
    );
  }
}

/// "Yeni sürüm mevcut" penceresi.
class GuncellemePenceresi extends StatelessWidget {
  const GuncellemePenceresi({super.key, required this.lang});

  final String lang;

  String _t(String tr, String en, String de, String es) =>
      AppLang.pick(lang, tr: tr, en: en, de: de, es: es);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      icon: const Text('🚀', style: TextStyle(fontSize: 40)),
      title: Text(
        _t('Yeni sürüm mevcut', 'A new version is available',
            'Eine neue Version ist da', 'Hay una nueva versión'),
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w900),
      ),
      content: Text(
        _t(
          'DevEducation\'ın yeni sürümü mağazada. En yeni dersler ve '
              'oyunlar için uygulamayı güncelle.',
          'A new version of DevEducation is in the store. Update to get '
              'the latest lessons and games.',
          'Eine neue Version von DevEducation ist im Store. Aktualisiere '
              'für die neuesten Lektionen und Spiele.',
          'Hay una nueva versión de DevEducation en la tienda. Actualiza '
              'para tener las últimas lecciones y juegos.',
        ),
        textAlign: TextAlign.center,
        style: const TextStyle(fontFamily: AppTheme.fontFamily, height: 1.35),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          key: const ValueKey('guncelleme_sonra'),
          onPressed: () => Navigator.pop(context),
          child: Text(_t('Sonra', 'Later', 'Später', 'Más tarde')),
        ),
        FilledButton(
          key: const ValueKey('guncelleme_guncelle'),
          onPressed: () {
            Navigator.pop(context);
            GuncellemeServisi.magazayiAc();
          },
          child: Text(_t('Güncelle', 'Update', 'Aktualisieren', 'Actualizar')),
        ),
      ],
    );
  }
}
