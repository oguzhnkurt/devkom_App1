import 'dart:io' show Platform;

import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart';

/// Meta (Facebook) uygulama olayları — yalnızca reklam ölçümü.
///
/// NEDEN VAR
/// ---------
/// Meta'da iOS uygulama yükleme reklamı vermek için kampanyada
/// "iOS 14+ kampanyası" açık olmalı. Meta bunu, uygulamadan olay
/// verisi gelmiyorsa açtırmıyor ("Toplu Olay Ölçümü'nü kullanamaz,
/// iOS için Facebook SDK'sını ayarlayın"). Kapalıyken reklam yalnız
/// iOS 13.7 ve öncesine gidiyor. Bu servis o veriyi sağlıyor.
///
/// NE TOPLANMIYOR
/// --------------
/// * Reklam kimliği (IDFA): `setAdvertiserIdCollectionEnabled(false)` ve
///   Info.plist'te `FacebookAdvertiserIDCollectionEnabled = false`.
/// * İzleme: `setAdvertiserTracking(enabled: false)`. ATT izin ekranı
///   bu uygulamada YOK ve eklenmeyecek; ölçüm SKAdNetwork / Toplu Olay
///   Ölçümü ile, kullanıcıyı uygulamalar arasında izlemeden yapılıyor.
///
/// NE TOPLANIYOR
/// -------------
/// Uygulama açılışı/kurulumu ve SDK'nın otomatik kaydettiği App Store
/// satın alma/abonelik olayları. App Store Connect > App Privacy'de
/// beyan edildi (bkz. docs/META_SDK_KURULUMU.md).
///
/// Android'de şimdilik çalışmıyor: Android sürümü yayında değil ve
/// Meta'daki uygulama kaydında Android platformu yok.
class MetaInstallService {
  const MetaInstallService._();

  static final FacebookAppEvents _events = FacebookAppEvents();

  static Future<void> initialize() async {
    if (kIsWeb || !Platform.isIOS) return;

    await _events.setAdvertiserTracking(enabled: false, collectId: false);
    await _events.setAdvertiserIdCollectionEnabled(false);
    await _events.setAutoLogAppEventsEnabled(true);
    await _events.activateApp();
    debugPrint('✅ Meta olay servisi baslatildi (IDFA kapali)');
  }
}
