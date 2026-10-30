import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
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

/// ZORUNLU ABONELIK KAPISI (hard paywall).
///
/// KARAR (30 Ekim 2026, kullanici): ucretsiz kullanim yok. Tanitim biter
/// bitmez satin alma ekrani geliyor; uygulamaya ya abone olarak ya da
/// yillik planin 7 gunluk ucretsiz denemesiyle giriliyor. Aylik plan
/// denemesiz. Kural MEVCUT kullanicilara da uygulaniyor (atolye ogrencileri
/// dahil): guncelleyen herkes bu kapidan geciyor.
///
/// Neden 7 gun (3 degil): RevenueCat 2026 verisinde 4 gunden kisa
/// denemeler %25,5, uzun denemeler %42,5 donusuyor; 3 gunluk deneme
/// iptallerinin %84'u ilk iki gunde oluyor. Deneme suresi magazada
/// (App Store tanitim teklifi / Play temel plan teklifi) tanimli; uygulama
/// sureyi StoreKit/Play'den okuyor, burada sabit yok.
///
/// Abonelik kontrolu (bkz. [SubscriptionService.aboneMi]):
///  * Adapty aktif diyorsa -> iceri.
///  * Supabase'te SURELI hediye Pro varsa (`is_pro` + gelecekte bir
///    `pro_expiry_date`) -> iceri. Suresiz `is_pro` tek basina YETMIYOR:
///    eski senkron bayragi, iptal edilen denemede de true kaliyor.
///  * Adapty'ye ulasilamiyorsa (cevrimdisi) -> Supabase `hasActivePro`'ya
///    guveniliyor; yoksa satin alma ekrani.
class AbonelikKapisi extends StatefulWidget {
  const AbonelikKapisi({super.key, required this.child, this.servis});

  /// Abone olunca gosterilecek uygulama.
  final Widget child;

  /// Testler icin.
  final SubscriptionService? servis;

  @override
  State<AbonelikKapisi> createState() => _AbonelikKapisiState();
}

enum _Durum { kontrol, kapali, acik }

class _AbonelikKapisiState extends State<AbonelikKapisi> {
  late final SubscriptionService _servis =
      widget.servis ?? SubscriptionService();
  _Durum _durum = _Durum.kontrol;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _kontrolEt());
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
      setState(() => _durum = _Durum.acik);
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
    setState(() => _durum = acik ? _Durum.acik : _Durum.kapali);
  }

  void _acildi() {
    if (mounted) setState(() => _durum = _Durum.acik);
  }

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
      case _Durum.acik:
        return widget.child;
    }
  }
}
