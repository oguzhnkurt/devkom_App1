import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/auth_provider.dart';
import '../screens/subscription_screen.dart';
import '../theme.dart';
import '../utils/lang.dart';
import '../widgets/parent_gate.dart';

/// Ilk ders bittikten sonra VELIYE tek seferlik Pro tanitimi (Ekim 2026).
///
/// NEDEN
/// Buyume arastirmasinda (claude/buyume-arastirmasi-ekim-2026.md) en buyuk
/// eksik "kurulum var, paywall'u goren yok" cikti: paywall yalnizca kilitli
/// bir kursa dokunulunca aciliyordu. Rakipler (codeSpark, Lingokids) teklifi
/// ilk basarili anin hemen ardindan gosteriyor.
///
/// NASIL
///  * Ilk ders ya da oyun bitince yalnizca bir bayrak kalkiyor
///    ([basariKaydet]); sayfa, kullanici o ekrandan CIKARKEN aciliyor
///    (AdNavigatorObserver). Kutlama ekraninin ustune binmiyor.
///  * Sayfa cocuga degil veliye konusuyor. "Incele" once [ParentGate]'ten
///    geciyor; abonelik ekranina yalnizca yetiskin ulasiyor.
///  * Toplamda BIR kez gosteriliyor. Pro kullaniciya hic gosterilmiyor.
///  * Fiyat ya da deneme suresi burada YAZILMIYOR: o bilgi magazadan
///    gelir ve abonelik ekraninda gosterilir. Burada uydurma bir sayi
///    olmamali.
class VeliTeklifiServisi {
  VeliTeklifiServisi._();
  static final VeliTeklifiServisi instance = VeliTeklifiServisi._();

  static const _kGosterildi = 'veli_teklifi_gosterildi';

  bool _bekliyor = false;

  /// Bir sonraki ekran gecisinde sayfa acilacak mi?
  bool get bekliyor => _bekliyor;

  @visibleForTesting
  void sifirla() => _bekliyor = false;

  /// Ders ya da oyun bitti. Daha once gosterilmediyse bayrak kaldirir.
  Future<void> basariKaydet() async {
    try {
      final p = await SharedPreferences.getInstance();
      if (p.getBool(_kGosterildi) ?? false) return;
      _bekliyor = true;
    } catch (e) {
      debugPrint('VeliTeklifiServisi.basariKaydet: $e');
    }
  }

  /// Ekran gecisinde cagriliyor. Bayrak kalkiksa ve kullanici Pro degilse
  /// sayfayi acar. Donus: sayfa gosterildi mi.
  Future<bool> bekliyorsaGoster(BuildContext context) async {
    if (!_bekliyor) return false;
    _bekliyor = false;
    try {
      final pro = context.read<AuthProvider>().currentUser?.isPro ?? false;
      if (pro) return false;
      final p = await SharedPreferences.getInstance();
      if (p.getBool(_kGosterildi) ?? false) return false;
      await p.setBool(_kGosterildi, true);
      if (!context.mounted) return false;
      final lang = Localizations.localeOf(context).languageCode;
      final incele = await showModalBottomSheet<bool>(
        context: context,
        backgroundColor: Colors.white,
        isScrollControlled: true,
        useSafeArea: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        builder: (_) => VeliTeklifiSayfasi(lang: lang),
      );
      if (incele != true || !context.mounted) return true;
      final gecti = await ParentGate.verify(context, lang: lang);
      if (!gecti || !context.mounted) return true;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
      );
      return true;
    } catch (e) {
      debugPrint('VeliTeklifiServisi.bekliyorsaGoster: $e');
      return false;
    }
  }
}

/// Ilk dersten sonra cikan veli sayfasi.
class VeliTeklifiSayfasi extends StatelessWidget {
  const VeliTeklifiSayfasi({super.key, required this.lang});

  final String lang;

  String _t(String tr, String en, String de, String es) =>
      AppLang.pick(lang, tr: tr, en: en, de: de, es: es);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 8),
          Text(
            _t('İlk ders tamam!', 'First lesson done!',
                'Erste Lektion geschafft!', '¡Primera lección completada!'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _t(
              'Ebeveynler için: Pro ile tüm kurslar, ileri seviye dersler ve '
                  'sertifikalar açılır. Planları ve ücretsiz deneme '
                  'seçeneklerini görmek için inceleyin.',
              'For parents: Pro unlocks every course, the advanced lessons '
                  'and certificates. Take a look to see the plans and any '
                  'free trial.',
              'Für Eltern: Mit Pro sind alle Kurse, die fortgeschrittenen '
                  'Lektionen und Zertifikate freigeschaltet. Sieh dir die '
                  'Pläne und eine mögliche Gratis-Testphase an.',
              'Para madres y padres: Pro desbloquea todos los cursos, las '
                  'lecciones avanzadas y los certificados. Mira los planes y '
                  'la prueba gratuita si está disponible.',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 15,
              height: 1.4,
              color: AppTheme.mediumGray,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const ValueKey('veli_teklifi_incele'),
              onPressed: () => Navigator.pop(context, true),
              child: Text(_t('Ebeveyn olarak incele', 'Parents: take a look',
                  'Eltern: ansehen', 'Madres y padres: ver')),
            ),
          ),
          const SizedBox(height: 6),
          TextButton(
            key: const ValueKey('veli_teklifi_sonra'),
            onPressed: () => Navigator.pop(context, false),
            child: Text(_t('Derslere devam et', 'Keep learning',
                'Weiterlernen', 'Seguir aprendiendo')),
          ),
        ],
      ),
    );
  }
}
