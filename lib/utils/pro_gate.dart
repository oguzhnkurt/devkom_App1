import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/robotics_games_screen.dart' show ProGames;
import '../screens/subscription_screen.dart';
import '../services/ads_service.dart';
import 'lang.dart';

/// Pro kilidi — tek giriş noktası.
///
/// [ProFeatureGuard] Adapty'ye ağ isteği atıyor; liste ekranlarında her kart
/// için bunu çağırmak pahalı. Burada `AuthProvider`'daki `isPro` alanına
/// bakıyoruz (Adapty satın alma sonrası bunu Supabase'e senkronluyor), böylece
/// kilit anında ve çevrimdışı da doğru çiziliyor.
/// Kilitli bir bolume erisim sonucu.
enum ProUnlock {
  /// Kullanici zaten Pro (ya da bu akista Pro oldu).
  pro,

  /// Odullu reklam sonuna kadar izlendi; TEK SEFERLIK ya da tek ders acildi.
  reklam,

  /// Erisim yok.
  kapali,
}

/// Kilit sayfasindan cikan secim.
enum _Secim { pro, reklam, iptal }

class ProGate {
  ProGate._();

  /// Hata ayiklama derlemesinde her kilidi acar (Pro simulasyonu).
  ///
  /// NEDEN VAR
  /// ---------
  /// Kilitli oyunlari ve Pro kurslari denemek icin her seferinde gercek
  /// bir abonelik satin almak ya da veritabanindan `isPro` alanini elle
  /// degistirmek gerekiyordu. Ayarlar > Hakkinda altindaki anahtar bunu
  /// tek dokunusla yapiyor.
  ///
  /// GUVENLIK: yalnizca [kDebugMode] icinde dikkate aliniyor. Yayin
  /// derlemesinde bu deger true olsa bile [isPro] onu gormezden geliyor,
  /// yani kilitleri acan bir arka kapi degil. `test/pro_gate_debug_test.dart`
  /// bunu kilitliyor.
  static bool debugHerSeyAcik = false;

  static bool get _debugAcik => kDebugMode && debugHerSeyAcik;

  static bool isPro(BuildContext context) =>
      _debugAcik ||
      (context.read<AuthProvider>().currentUser?.isPro ?? false);

  /// Dinlenebilir sürüm — build içinde kullan.
  static bool watchIsPro(BuildContext context) =>
      _debugAcik ||
      (context.watch<AuthProvider>().currentUser?.isPro ?? false);

  /// Pro değilse tanıtım sayfasını açar ve false döner.
  /// Pro ise hiçbir şey yapmaz ve true döner.
  static Future<bool> ensure(
    BuildContext context, {
    required String featureName,
    String? explanation,
  }) async {
    if (isPro(context)) return true;

    final secim = await showModalBottomSheet<_Secim>(
      context: context,
      backgroundColor: Colors.white,
      // Sayfa kucuk ekranda 0.25 px tasiyordu ("BOTTOM OVERFLOWED"): icerik
      // sabit yukseklikteydi ve alt guvenli alan hesaba katilmiyordu.
      // `isScrollControlled` + icerideki kaydirma ile her ekranda sigiyor.
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => _ProSheet(
        featureName: featureName,
        explanation: explanation,
      ),
    );

    if (secim == _Secim.pro && context.mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
      );
      if (context.mounted) {
        await context.read<AuthProvider>().refreshUser();
      }
    }
    return false;
  }

  /// [ensure] ile ayni, ama Pro degilse ODULLU REKLAM secenegi de sunar.
  ///
  /// Reklam dugmesi yalnizca gunluk sinir dolmadiysa ve platform reklam
  /// destekliyorsa cikiyor; Pro uyeye hic cikmiyor. [reklamEtiketi] ne
  /// acildigini yazmak icin: "bir tur oyna" ile "bu dersi ac" ayni sey
  /// degil, cocuk neyi kazandigini dugmede gormeli.
  ///
  /// Donen [ProUnlock.reklam] TEK SEFERLIK bir izin: cagiran taraf bunu
  /// ya tek tur oyun olarak kullanir ya da [AdUnlockService] ile kalici
  /// hale getirir.
  static Future<ProUnlock> ensureOrAd(
    BuildContext context, {
    required String featureName,
    String? explanation,
    required String Function(String lang) reklamEtiketi,
  }) async {
    if (isPro(context)) return ProUnlock.pro;

    final reklamVar = await AdsService.instance.canWatchRewarded();
    if (!context.mounted) return ProUnlock.kapali;

    final secim = await showModalBottomSheet<_Secim>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => _ProSheet(
        featureName: featureName,
        explanation: explanation,
        reklamEtiketi: reklamVar ? reklamEtiketi : null,
      ),
    );

    if (!context.mounted) return ProUnlock.kapali;

    if (secim == _Secim.pro) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
      );
      if (!context.mounted) return ProUnlock.kapali;
      await context.read<AuthProvider>().refreshUser();
      if (!context.mounted) return ProUnlock.kapali;
      return isPro(context) ? ProUnlock.pro : ProUnlock.kapali;
    }

    if (secim == _Secim.reklam) {
      final sonuc = await AdsService.instance.showRewarded();
      if (!context.mounted) return ProUnlock.kapali;
      if (sonuc.earned) return ProUnlock.reklam;
      _reklamMesaji(context, sonuc.reason);
      return ProUnlock.kapali;
    }

    return ProUnlock.kapali;
  }

  /// Odul verilmediginde cocugu suclamayan kisa bir aciklama.
  static void _reklamMesaji(BuildContext context, RewardedAdFailure? neden) {
    final lang = Localizations.localeOf(context).languageCode;
    String metin;
    switch (neden) {
      case RewardedAdFailure.dailyCapReached:
        metin = AppLang.pick(lang,
            tr: 'Bugünlük video hakkın doldu. Yarın yeniden deneyebilirsin.',
            en: "You've used today's videos. Try again tomorrow.",
            de: 'Deine Videos für heute sind aufgebraucht. Morgen wieder.',
            es: 'Ya has usado los vídeos de hoy. Inténtalo mañana.');
        break;
      case RewardedAdFailure.dismissedEarly:
        metin = AppLang.pick(lang,
            tr: 'Video tamamlanmadı, bu sefer açılmadı.',
            en: 'The video was not finished, so it did not unlock this time.',
            de: 'Das Video wurde nicht zu Ende geschaut, diesmal klappt es nicht.',
            es: 'El vídeo no terminó, así que esta vez no se desbloqueó.');
        break;
      default:
        metin = AppLang.pick(lang,
            tr: 'Şu an gösterilecek video yok.',
            en: 'No video available right now.',
            de: 'Gerade ist kein Video verfügbar.',
            es: 'Ahora mismo no hay ningún vídeo.');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(metin), behavior: SnackBarBehavior.floating),
    );
  }

  /// Kilitli kartların köşesine konan rozet.
  static Widget badge({double size = 11}) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: size * 0.7, vertical: size * 0.25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA000)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_rounded, size: size, color: Colors.white),
          SizedBox(width: size * 0.35),
          Text(
            'PRO',
            style: TextStyle(
              color: Colors.white,
              fontSize: size,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProSheet extends StatelessWidget {
  final String featureName;
  final String? explanation;

  /// Null ise reklam dugmesi hic cizilmiyor (Pro uye, gunluk sinir dolu
  /// ya da platform reklam desteklemiyor).
  final String Function(String lang)? reklamEtiketi;

  const _ProSheet({
    required this.featureName,
    this.explanation,
    this.reklamEtiketi,
  });

  /// Pro'nun actigi oyun sayisi. Katalogdan okunuyor ki oyun eklenip
  /// cikarildikca bu yazi kendiliginden dogru kalsin.
  int get _lockedGames => ProGames.lockedGameCount;

  /// Pro maddeleri.
  ///
  /// `static const` ve tamamen Turkce idi: kilitli bir oyuna dokunan
  /// Alman kullanici, paranin istendigi bu sayfayi Turkce goruyordu.
  List<(IconData, String, String)> _perks(String lang) {
    String t(String tr, String en, String de, String es) =>
        AppLang.pick(lang, tr: tr, en: en, de: de, es: es);
    return [
      (
        Icons.school_rounded,
        t('İleri seviye kurslar', 'Advanced courses', 'Fortgeschrittene Kurse',
            'Cursos avanzados'),
        'Arduino IDE, Java, C#',
      ),
      (
        Icons.sports_esports_rounded,
        // Sayi ELLE yazilmisti ve 13 diyordu; katalogda Pro'nun actigi
        // oyun sayisi 9. Tutulmayan bir soz hem kullaniciya karsi yanlis
        // hem de App Store Kural 3.1.2 acisindan riskli, o yuzden artik
        // katalogdan okunuyor.
        t('$_lockedGames ek oyun', '$_lockedGames more games',
            '$_lockedGames weitere Spiele', '$_lockedGames juegos más'),
        t(
            'Satranç, labirentler, simülatörler',
            'Chess, mazes and simulators',
            'Schach, Labyrinthe, Simulatoren',
            'Ajedrez, laberintos y simuladores'),
      ),
      (
        Icons.insights_rounded,
        t('İlerleme raporu', 'Progress report', 'Fortschrittsbericht',
            'Informe de progreso'),
        t(
            'Neyde güçlüsün, nerede takılıyorsun',
            'What you are good at and where you get stuck',
            'Worin du gut bist und wo du hängst',
            'En qué destacas y dónde te atascas'),
      ),
      (
        Icons.workspace_premium_rounded,
        t('Sertifika', 'Certificate', 'Zertifikat', 'Certificado'),
        t(
            'Kurs bitince adına düzenlenir',
            'Issued in your name when a course is done',
            'Auf deinen Namen, wenn ein Kurs fertig ist',
            'A tu nombre al terminar un curso'),
      ),
      (
        Icons.flag_rounded,
        t('Pro görevleri', 'Pro quests', 'Pro-Aufgaben', 'Misiones Pro'),
        t(
            'Büyük ödüllü özel görevler',
            'Special quests with bigger rewards',
            'Spezialaufgaben mit größeren Belohnungen',
            'Misiones especiales con recompensas mayores'),
      ),
      (
        Icons.auto_awesome_rounded,
        t('Pro karakterler', 'Pro characters', 'Pro-Figuren', 'Personajes Pro'),
        'Devkom Pro, Devkom Boss',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDE1E7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.lock_rounded,
                    color: Color(0xFFFFA000), size: 22),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    featureName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              explanation ??
                  AppLang.pick(lang,
                      tr: 'Bu bölüm Pro üyeliğe dahil.',
                      en: 'This part is included with Pro.',
                      de: 'Dieser Teil ist in Pro enthalten.',
                      es: 'Esta parte está incluida en Pro.'),
              style:
                  TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4),
            ),
            const SizedBox(height: 18),
            ..._perks(lang).map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(p.$1, size: 19, color: const Color(0xFF6C3CE0)),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.$2,
                                style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700)),
                            Text(p.$3,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600])),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, _Secim.pro),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6C3CE0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(AppLang.pick(lang,
                    tr: 'Pro seçeneklerine bak',
                    en: 'See Pro options',
                    de: 'Pro-Optionen ansehen',
                    es: 'Ver opciones Pro')),
              ),
            ),
            if (reklamEtiketi != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context, _Secim.reklam),
                  icon: const Icon(Icons.play_circle_outline_rounded, size: 20),
                  label: Text(reklamEtiketi!(lang)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6C3CE0),
                    side: const BorderSide(color: Color(0xFF6C3CE0), width: 1.4),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 6),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context, _Secim.iptal),
                child: Text(AppLang.pick(lang,
                    tr: 'Şimdi değil',
                    en: 'Not now',
                    de: 'Jetzt nicht',
                    es: 'Ahora no')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
