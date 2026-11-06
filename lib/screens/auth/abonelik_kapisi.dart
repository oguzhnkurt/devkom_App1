import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firebase_servisi.dart';
import '../../services/subscription_service.dart';
import '../../utils/pro_gate.dart';
import '../splash_screen.dart';
import '../subscription_screen.dart';

/// Supabase'te sureli (hediye) Pro: `is_pro` + gelecekte bir bitis tarihi.
/// Hediye vermek icin `users.pro_expiry_date` elle doldurulmali.
bool sureliHediyeVar(UserModel? u, DateTime simdi) =>
    u != null &&
    u.isPro &&
    u.proExpiryDate != null &&
    u.proExpiryDate!.isAfter(simdi);

/// ABONELIK KAPISI: kisa ucretsiz tanisma, sonra zorunlu odeme ekrani.
///
/// KARAR (6 Kasim 2026, kullanici): ucretsiz deneme (7 gun) kaldirildi.
/// Yeni kullanici uygulamada [ucretsizSure] kadar (on planda gecen sure,
/// cihazda saklanir) serbestce dolasiyor; sure bitince odeme ekrani
/// geliyor ve kapatilamiyor. Cikis teklifi (indirimli yillik) duruyor.
///
/// Denge: 4 dakika bir dersi ya da oyunu bitirip "bu ise yariyor" demeye
/// yetiyor, uygulamayi bedava tuketmeye yetmiyor. Sure dolunca cocugu
/// dersin ortasinda kesmiyoruz: ana ekrana donmesi bekleniyor; ama
/// [azamiSure]'de ne olursa olsun kapi kapaniyor.
///
/// Abonelik kontrolu (bkz. [SubscriptionService.aboneMi]):
///  * Adapty aktif diyorsa -> iceri.
///  * Supabase'te SURELI hediye Pro varsa (`is_pro` + gelecekte bir
///    `pro_expiry_date`) -> iceri. Suresiz `is_pro` tek basina YETMIYOR:
///    eski senkron bayragi, iptal edilen denemede de true kaliyor.
///  * Adapty'ye ulasilamiyorsa (cevrimdisi) -> Supabase `hasActivePro`'ya
///    guveniliyor; yoksa (sure kaldiysa) ucretsiz sure, sonra odeme ekrani.
class AbonelikKapisi extends StatefulWidget {
  const AbonelikKapisi(
      {super.key, required this.child, this.servis, this.saat});

  /// Abone olunca gosterilecek uygulama.
  final Widget child;

  /// Testler icin.
  final SubscriptionService? servis;

  /// Testler icin: sure olcumunde kullanilan saat.
  final DateTime Function()? saat;

  /// Odeme ekranindan once serbest kullanim.
  static const Duration ucretsizSure = Duration(minutes: 4);

  /// Sure dolduktan sonra cocuk bir derste/oyundaysa beklenen en uzun an.
  static const Duration azamiSure = Duration(minutes: 6);

  /// Kullanilan ucretsiz sure (saniye) — SharedPreferences anahtari.
  static const String sureAnahtari = 'ucretsiz_sure_sn';

  @override
  State<AbonelikKapisi> createState() => _AbonelikKapisiState();
}

enum _Durum { kontrol, ucretsiz, kapali, acik }

class _AbonelikKapisiState extends State<AbonelikKapisi>
    with WidgetsBindingObserver {
  late final SubscriptionService _servis =
      widget.servis ?? SubscriptionService();
  _Durum _durum = _Durum.kontrol;

  Timer? _sayac;
  int _kullanilanSn = 0;
  DateTime? _sonOlcum;
  bool _onPlanda = true;

  DateTime _simdi() => (widget.saat ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _kontrolEt());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sayac?.cancel();
    _kaydet();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final onPlan = state == AppLifecycleState.resumed;
    if (onPlan == _onPlanda) return;
    _olc(); // arka plana gecmeden once biriken sureyi yaz
    _onPlanda = onPlan;
    _sonOlcum = onPlan ? _simdi() : null;
    if (!onPlan) _kaydet();
  }

  /// Debug anahtari (yalnizca hata ayiklama derlemesi).
  bool get _debugAcik => kDebugMode && ProGate.debugHerSeyAcik;

  Future<void> _kontrolEt() async {
    if (!mounted) return;
    if (_debugAcik) {
      setState(() => _durum = _Durum.acik);
      return;
    }
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (sureliHediyeVar(user, DateTime.now())) {
      _bitir(_Durum.acik);
      return;
    }

    final adapty = await _servis.aboneMi(userId: user?.uid);
    if (!mounted) return;

    final acik = adapty ?? (user?.hasActivePro ?? false);
    if (acik && adapty == true && user != null && !user.isPro) {
      try {
        await auth.refreshUser();
      } catch (_) {}
      if (!mounted) return;
    }
    if (acik) {
      _bitir(_Durum.acik);
      return;
    }
    await _ucretsizSureyiBaslat();
  }

  Future<void> _ucretsizSureyiBaslat() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    _kullanilanSn = prefs.getInt(AbonelikKapisi.sureAnahtari) ?? 0;
    if (_kullanilanSn >= AbonelikKapisi.ucretsizSure.inSeconds) {
      _bitir(_Durum.kapali);
      return;
    }
    _sonOlcum = _simdi();
    setState(() => _durum = _Durum.ucretsiz);
    _sayac?.cancel();
    _sayac = Timer.periodic(const Duration(seconds: 2), (_) => _tik());
  }

  /// On planda gecen sureyi ekler.
  void _olc() {
    if (_durum != _Durum.ucretsiz || !_onPlanda || _sonOlcum == null) return;
    final simdi = _simdi();
    final fark = simdi.difference(_sonOlcum!).inSeconds;
    // Saat geri alinirsa ya da cihaz uyuyup donerse buyuk sicramalari
    // saymiyoruz (arka plandaki sure zaten sayilmiyor).
    if (fark > 0 && fark < 60) _kullanilanSn += fark;
    _sonOlcum = simdi;
  }

  void _tik() {
    if (!mounted || _durum != _Durum.ucretsiz) return;
    _olc();
    if (_kullanilanSn % 10 < 2) _kaydet();
    final doldu = _kullanilanSn >= AbonelikKapisi.ucretsizSure.inSeconds;
    if (!doldu) return;
    final azami = _kullanilanSn >= AbonelikKapisi.azamiSure.inSeconds;
    // Cocuk ana ekrandaysa (ustte acik ders/oyun yoksa) hemen; degilse
    // ana ekrana donmesini azami sureye kadar bekle.
    final nav = Navigator.maybeOf(context);
    final anaEkranda = nav == null || !nav.canPop();
    if (anaEkranda || azami) _kapiyiKapat(nav);
  }

  bool _kapatiliyor = false;

  /// Kapatmadan once aboneligi bir kez daha soruyoruz: ucretsiz surede
  /// uygulamanin icinden (Pro ekrani) satin alan biri kilitlenmesin.
  Future<void> _kapiyiKapat(NavigatorState? nav) async {
    if (_kapatiliyor) return;
    _kapatiliyor = true;
    try {
      final user = context.read<AuthProvider>().currentUser;
      if (sureliHediyeVar(user, DateTime.now()) ||
          await _servis.aboneMi(userId: user?.uid) == true) {
        _bitir(_Durum.acik);
        return;
      }
    } catch (_) {
    } finally {
      _kapatiliyor = false;
    }
    if (!mounted || _durum != _Durum.ucretsiz) return;
    _kullanilanSn =
        _kullanilanSn.clamp(AbonelikKapisi.ucretsizSure.inSeconds, 1 << 30);
    if (nav != null && nav.mounted && nav.canPop()) {
      nav.popUntil((r) => r.isFirst);
    }
    FirebaseServisi.instance.olay(Olay.paywallGoruntulendi, {
      'zorunlu': 1,
      'ucretsiz_sure_bitti': 1,
    });
    _bitir(_Durum.kapali);
  }

  void _bitir(_Durum d) {
    _sayac?.cancel();
    _sayac = null;
    _kaydet();
    if (mounted) setState(() => _durum = d);
  }

  void _kaydet() {
    if (_kullanilanSn <= 0) return;
    final sn = _kullanilanSn;
    SharedPreferences.getInstance()
        .then((p) => p.setInt(AbonelikKapisi.sureAnahtari, sn))
        .catchError((_) => false);
  }

  void _acildi() => _bitir(_Durum.acik);

  @override
  Widget build(BuildContext context) {
    switch (_durum) {
      case _Durum.kontrol:
        return const SplashScreen();
      case _Durum.kapali:
        return SubscriptionScreen(
          zorunlu: true,
          onAcildi: _acildi,
          yenidenKontrol: _kontrolEt,
        );
      case _Durum.ucretsiz:
      case _Durum.acik:
        return widget.child;
    }
  }
}
