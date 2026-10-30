import 'dart:async';

import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../firebase_options.dart';

/// FIREBASE: olcum (Analytics) + bildirim (Cloud Messaging).
///
/// 1.0.18 (30 Ekim 2026, kullanici karari):
///  * Kullanici davranisi Firebase Analytics ile izleniyor (ekran
///    gecisleri + birkac anlamli olay; bkz. [Olay]).
///  * Satin alma / deneme donusumleri Firebase'e ADAPTY uzerinden
///    gidiyor: Adapty profiline Firebase `app_instance_id` yaziliyor,
///    Adapty panelindeki Firebase entegrasyonu donusum olaylarini
///    (trial_started, subscription_started, ...) sunucudan gonderiyor.
///    Uygulama tarafinda ayrica gelirli `purchase` olayi ATILMIYOR: iki
///    kaynak ayni geliri iki kez saymasin.
///  * Google Ads donusumleri: Firebase projesi Google Ads'e baglanip bu
///    olaylar orada donusum olarak ice aktariliyor (konsol isi).
///  * Bildirimler Firebase Cloud Messaging ile: herkes `tum_kullanicilar`
///    ve kendi dil konusuna (`dil_en` ...) abone; Firebase konsolundan
///    konu ya da dil secilerek gonderiliyor.
///
/// COCUK KITLESI / AILE POLITIKASI
/// -------------------------------
///  * Reklam kimligi toplanmiyor: Android manifestte AD_ID izni kaldirili
///    ve `google_analytics_adid_collection_enabled=false`; iOS'ta ATT izni
///    hic istenmedigi icin IDFA sifir.
///  * Reklam kisisellestirme kapali (manifest / Info.plist + onay modu).
///  * Onay modu varsayilani: analitik ACIK, reklam depolama / reklam
///    kullanici verisi / kisisellestirme KAPALI. Google Ads donusumleri
///    bu durumda modellenmis olarak sayiliyor; iOS'ta SKAdNetwork kaydi
///    ayrica acik (Info.plist).
class FirebaseServisi {
  FirebaseServisi._();
  static final FirebaseServisi instance = FirebaseServisi._();

  bool _hazir = false;
  bool get hazir => _hazir;

  FirebaseAnalytics? _analytics;

  /// Ekran gecislerini Analytics'e yazan gozlemci. Firebase yoksa bos.
  /// Bir kez olusturuluyor: MaterialApp her yeniden cizildiginde yeni
  /// bir gozlemci vermek Navigator'a gereksiz is.
  late final NavigatorObserver gozlemci = _analytics == null
      ? NavigatorObserver()
      : FirebaseAnalyticsObserver(analytics: _analytics!);

  static const String tumKullanicilarKonusu = 'tum_kullanicilar';
  static String dilKonusu(String dil) => 'dil_$dil';

  /// Uygulama acilisinda bir kez. Hata uygulamayi durdurmaz.
  Future<void> baslat() async {
    if (_hazir) return;
    final secenekler = DefaultFirebaseOptions.currentPlatform;
    if (secenekler == null) return;
    try {
      await Firebase.initializeApp(options: secenekler);
      _analytics = FirebaseAnalytics.instance;
      await _analytics!.setAnalyticsCollectionEnabled(!kDebugMode);
      await _analytics!.setConsent(
        analyticsStorageConsentGranted: true,
        adStorageConsentGranted: false,
        adUserDataConsentGranted: false,
        adPersonalizationSignalsConsentGranted: false,
      );
      FirebaseMessaging.onMessage.listen(_onPlanMesaj);
      _hazir = true;
      unawaited(_adaptyyeBagla());
      debugPrint('✅ Firebase hazir');
    } catch (e) {
      debugPrint('⚠️ Firebase baslatilamadi: $e');
    }
  }

  /// Adapty profiline Firebase kimligini yazar (donusumler icin).
  Future<void> _adaptyyeBagla() async {
    try {
      final id = await _analytics?.appInstanceId;
      if (id == null || id.isEmpty) return;
      await Adapty().setIntegrationIdentifier(
        key: 'firebase_app_instance_id',
        value: id,
      );
    } catch (e) {
      debugPrint('⚠️ Adapty-Firebase baglantisi: $e');
    }
  }

  /// Oturum acilinca: Analytics kullanici kimligi + Adapty esitlemesi.
  ///
  /// Kimlik Supabase'in rastgele UUID'si; ad, e-posta gibi kisisel veri
  /// gonderilmez.
  Future<void> kullaniciAyarla(String? uid) async {
    if (!_hazir) return;
    try {
      await _analytics?.setUserId(id: uid);
      await _adaptyyeBagla();
    } catch (e) {
      debugPrint('⚠️ Firebase kullanici: $e');
    }
  }

  /// Bildirim izni (iOS; Android 13 izni yerel bildirim servisi istiyor)
  /// ve konu aboneligi. Dil degisince yeniden cagrilabilir.
  Future<void> bildirimleriAc(String dil) async {
    if (!_hazir) return;
    try {
      final m = FirebaseMessaging.instance;
      await m.requestPermission(alert: true, badge: true, sound: true);
      await m.setForegroundNotificationPresentationOptions(
          alert: true, badge: true, sound: true);
      await m.subscribeToTopic(tumKullanicilarKonusu);
      for (final d in const ['tr', 'en', 'de', 'es']) {
        if (d != dil) await m.unsubscribeFromTopic(dilKonusu(d));
      }
      await m.subscribeToTopic(dilKonusu(dil));
    } catch (e) {
      // iOS'ta APNs anahtari Firebase'e yuklenmeden konu aboneligi
      // hata verir; uygulama etkilenmez.
      debugPrint('⚠️ Bildirim aboneligi: $e');
    }
  }

  /// Uygulama ondeyken gelen bildirimi Android'de goster (iOS kendisi
  /// gosteriyor: setForegroundNotificationPresentationOptions).
  Future<void> _onPlanMesaj(RemoteMessage mesaj) async {
    final n = mesaj.notification;
    if (n == null || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await FlutterLocalNotificationsPlugin().show(
        mesaj.hashCode,
        n.title,
        n.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'duyurular_channel',
            'Duyurular',
            channelDescription: 'DevEducation duyurulari',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    } catch (e) {
      debugPrint('⚠️ On plan bildirimi: $e');
    }
  }

  /// Ozel olay. Firebase yoksa sessizce hicbir sey yapmaz.
  Future<void> olay(String ad, [Map<String, Object>? parametreler]) async {
    if (!_hazir) return;
    try {
      await _analytics?.logEvent(name: ad, parameters: parametreler);
    } catch (e) {
      debugPrint('⚠️ Analytics olay ($ad): $e');
    }
  }

  Future<void> tanitimBitti() async {
    if (!_hazir) return;
    try {
      await _analytics?.logTutorialComplete();
    } catch (_) {}
  }
}

/// Olay adlari tek yerde (Google Ads'te donusum olarak secilecekler).
class Olay {
  Olay._();

  /// Zorunlu abonelik ekrani gosterildi.
  static const String paywallGoruntulendi = 'paywall_view';

  /// Satin alma dugmesine basildi (ebeveyn kapisindan once).
  static const String satinAlmaDenendi = 'purchase_attempt';

  /// Abonelik / deneme basladi (istemci tarafi, GELIRSIZ). Gelirli
  /// olaylar Adapty entegrasyonundan geliyor.
  static const String abonelikBasladi = 'subscription_unlocked';

  /// Ilk ders tamamlandi.
  static const String ilkDersBitti = 'first_lesson_complete';
}
