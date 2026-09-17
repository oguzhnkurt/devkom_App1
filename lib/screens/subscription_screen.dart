import 'dart:async';
import 'dart:math' as math;

import 'package:intl/intl.dart';
import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../widgets/mascot.dart';
import 'paywall_sky.dart';
import '../services/subscription_service.dart';
import '../theme.dart';
import '../providers/settings_provider.dart';
import '../ui/motion.dart';
import '../ui/press_button.dart';
import '../utils/lang.dart';
import 'robotics_games_screen.dart' show ProGames;

/// Pro abonelik ekrani (paywall).
///
/// Onceki surumde ekran su sirayla aciliyordu: koyu mavi gradyan, 8 maddelik
/// uzun bir ozellik listesi, yan yana iki kucuk plan kutusu ve "Devam Et"
/// yazan bir buton. Sorunlari tek tek:
///
/// * Kullanici fiyati gormek icin uzun listeyi asmak zorundaydi; buton
///   sayfanin icinde kaliyordu, kaydirmadan gorunmuyordu.
/// * "Devam Et" jenerik bir fiil; ne satin aldigini soylemiyor.
/// * Yillik planda tasarrufun ne kadar oldugu hicbir yerde yazmiyordu;
///   karsilastirilacak bir capa fiyat yoktu.
/// * Ucretsiz deneme varsa bile anlatilmiyordu.
/// * Metinlerin yarisi Turkce karaktersizdi ("Ogrenmeyi", "Yillik", "Aylik",
///   "Isleniyor") — tek basina bile amator duruyordu.
/// * Satin alma sirasinda butonun kendisi bir sey yapmiyor, ekrani kaplayan
///   gri bir katman aciliyordu.
///
/// Yeni duzen egitim uygulamalarinin 2026'daki yerlesik kalibini izliyor:
/// kapat + geri yukle > fayda basligi > ne aldigin > (varsa) deneme takvimi
/// > plan secimi > her zaman gorunen alt buton > yasal satir.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _service = SubscriptionService();

  List<AdaptyPaywallProduct> _products = [];
  AdaptyPaywallProduct? _selected;
  bool _loading = true;
  bool _purchasing = false;

  /// Cikis teklifi bir kez gosterildi mi? Ikinci geri hareketinde ekran
  /// kapaniyor; kullaniciyi ekranda tutan bir dongu kurmuyoruz.
  bool _exitOfferShown = false;

  /// Ekran iki dilli.
  String get _lang =>
      Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;
  bool get _isEn => _lang == 'en';

  /// Metin secici.
  ///
  /// [de] ve [es] verilmemisse Ingilizcesi gosteriliyor. Boylece bir
  /// cumlenin Almancasi henuz yazilmamis olsa bile ekran dogru
  /// calisiyor ve ceviri sonradan tek bir arguman eklenerek
  /// tamamlanabiliyor — 500'den fazla cagri yerini bir anda cevirmek
  /// zorunda kalmadan.
  String _t(String tr, String en, [String? de, String? es]) =>
      AppLang.pick(_lang, tr: tr, en: en, de: de, es: es);

  static const Color _ink = Color(0xFF14161A);
  static const Color _inkSoft = Color(0xFF5B616E);
  static const Color _surface = Color(0xFFF6F7F9);
  static const Color _hairline = Color(0xFFE3E6EB);

  // NOT: Bu liste bilerek yalnizca gercekten sunulan ozellikleri iceriyor.
  // Uygulamada karsiligi olmayan vaatler (sinirsiz AI sohbet, aile paylasimi,
  // 7/24 destek) App Store Kural 3.1.2 riski. Uzun listeyi de kistik:
  // paywall'da okunan madde sayisi 5'i gecmiyor, gerisi "Neler dahil?"
  // basligi altinda aciliyor.
  /// Odeme ekranindaki maddeler.
  ///
  /// ONCEDEN `static const` ve TAMAMEN TURKCE idi. Ekranin geri kalani
  /// dort dile cevriliyken paranin istendigi yer — yani App Store
  /// incelemecisinin en dikkatli baktigi ekran — Ingilizce, Almanca ve
  /// Ispanyolca kullaniciya Turkce goruntyordu.
  List<(IconData, String, String)> get _highlights => [
        (
          Icons.sports_esports_rounded,
          // SAYI GERÇEK OLMALI. Katalogda 16 oyun var, 7'si ücretsiz →
          // Pro'nun açtığı oyun sayısı 9. Burada "13" yazıyordu; hem
          // tutulmayan bir söz, hem de App Store incelemesinin
          // yanıltıcı bulacağı türden bir rakam.
          // Kilidi: test/pro_claims_test.dart
          _t('${ProGames.lockedGameCount} ek oyun',
              '${ProGames.lockedGameCount} more games',
              '${ProGames.lockedGameCount} weitere Spiele',
              '${ProGames.lockedGameCount} juegos más'),
          _t(
            'Satranç, labirentler, devre ve robot simülatörleri',
            'Chess, mazes, circuit and robot simulators',
            'Schach, Labyrinthe, Schaltungs- und Robotersimulatoren',
            'Ajedrez, laberintos y simuladores de circuitos y robots',
          ),
        ),
        (
          Icons.school_rounded,
          // Almancasi "Fortgeschrittene Kurse" idi ve dar kartta
          // kelimenin ORTASINDAN boluniyordu ("Fortgeschritten / e
          // Kurse"). Kisa karsiligi ayni seyi soyluyor.
          _t('İleri kurslar', 'Advanced courses', 'Profi-Kurse',
              'Cursos avanzados'),
          'Arduino IDE, Java, C#',
        ),
        (
          Icons.workspace_premium_rounded,
          _t('Sertifika', 'Certificate', 'Zertifikat', 'Certificado'),
          _t('Kurs bitirme sertifikası', 'A certificate for each course',
              'Ein Zertifikat für jeden Kurs', 'Un certificado por cada curso'),
        ),
        (
          Icons.insights_rounded,
          _t('İlerleme raporu', 'Progress report', 'Fortschrittsbericht',
              'Informe de progreso'),
          _t(
            'Neyi bildiğini, nerede takıldığını gösterir',
            'Shows what they know and where they get stuck',
            'Zeigt, was dein Kind kann und wo es hängt',
            'Muestra lo que sabe y dónde se atasca',
          ),
        ),
        (
          Icons.monetization_on_rounded,
          _t('1000 jeton hediye', '1000 bonus tokens', '1000 Bonus-Münzen',
              '1000 fichas de regalo'),
          _t(
            'Her ay 300 jeton, her kazançta 1.5× jeton',
            '300 tokens a month, 1.5× on every reward',
            '300 Münzen im Monat, 1,5× auf jede Belohnung',
            '300 fichas al mes y 1,5× en cada recompensa',
          ),
        ),
      ];

  List<String> get _extras => [
        _t(
          'İlerleme raporu: neyi bildiğini, nerede takıldığını gösterir',
          'Progress report: what they know and where they get stuck',
          'Fortschrittsbericht: was dein Kind kann und wo es hängt',
          'Informe de progreso: lo que sabe y dónde se atasca',
        ),
        _t(
          '1000 jeton hediye, her ay 300 jeton, her kazançta 1.5× jeton',
          '1000 bonus tokens, 300 a month, 1.5× on every reward',
          '1000 Bonus-Münzen, 300 im Monat, 1,5× auf jede Belohnung',
          '1000 fichas de regalo, 300 al mes y 1,5× en cada recompensa',
        ),
        _t(
            'Pro görevleri ve büyük ödüller',
            'Pro quests and bigger rewards',
            'Pro-Aufgaben und größere Belohnungen',
            'Misiones Pro y recompensas mayores'),
        _t('Pro karakterler ve ekipmanlar', 'Pro characters and gear',
            'Pro-Figuren und Ausrüstung', 'Personajes y equipo Pro'),
        _t('Reklamsız kullanım', 'No ads', 'Keine Werbung', 'Sin anuncios'),
      ];

  /// Ekranda acik duran madde sayisi. Planlarin kaydirmadan gorunmesi
  /// icin liste kisa tutuluyor; gerisi "Neler dahil?" altinda.
  static const int _visibleHighlights = 3;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    // Ekran kapandiysa magazayi beklemenin anlami yok.
    _loadTimer?.cancel();
    super.dispose();
  }

  /// Magazadan urunleri cekerken beklenecek en uzun sure.
  ///
  /// Onceden sure siniri YOKTU: magaza cevap vermezse (yavas ag, App
  /// Store kesintisi, cihazda magaza kapali) ekran sonsuza kadar donen
  /// bir cember gosteriyordu. Cocuk ne oldugunu anlamiyor, geri de
  /// donmuyor. Sure dolunca "planlar su an yuklenemiyor" karti ve
  /// tekrar deneme yolu geliyor.
  static const Duration _loadTimeout = Duration(seconds: 12);

  /// Sure sinirini tutan zamanlayici.
  ///
  /// `Future.timeout` yerine ELDE tutulan bir Timer kullaniliyor: ekran
  /// kapandiginda iptal edilebilsin diye. `.timeout` ile birakilan
  /// zamanlayici, widget agaci soktukten sonra da hayatta kaliyordu ve
  /// testler "A Timer is still pending" ile patliyordu — gercek
  /// uygulamada da bos yere 12 saniye bekleyen bir zamanlayici demek.
  Timer? _loadTimer;

  Future<void> _load() async {
    setState(() => _loading = true);

    final done = Completer<List<AdaptyPaywallProduct>>();
    _loadTimer?.cancel();
    _loadTimer = Timer(_loadTimeout, () {
      if (!done.isCompleted) done.complete(const []);
    });

    _service.getProducts().then((p) {
      if (!done.isCompleted) done.complete(p);
    }, onError: (_) {
      if (!done.isCompleted) done.complete(const []);
    });

    final products = await done.future;
    _loadTimer?.cancel();
    if (!mounted) return;

    final yearly =
        products.where((p) => p.vendorProductId.contains('yearly')).firstOrNull;
    setState(() {
      _products = products;
      // Yillik plan onceden secili: en yuksek degerli plan varsayilan olmali.
      _selected = yearly ?? products.firstOrNull;
      _loading = false;
    });
  }

  // ---------------------------------------------------------------- satin alma

  Future<void> _purchase() async {
    if (_selected == null || _purchasing) return;
    HapticFeedback.mediumImpact();
    setState(() => _purchasing = true);
    try {
      final success = await _service.purchaseProduct(_selected!);
      if (!mounted) return;
      if (success) {
        // Once jetonu al, sonra provider'i yenile. Ters sirada olmaz:
        // refreshUser() Pro kullanici icin bekleyen jetonu zaten sessizce
        // topluyor, o yuzden buradaki cagri 0 doner ve kutlamayi kaciririz.
        final grant = await _service.claimProJeton();
        if (!mounted) return;

        // AuthProvider kullaniciyi onbellekte tutuyor; yenilemezsek satin alma
        // sonrasi arayuz hala "Pro'ya Yükselt" gostermeye devam ediyordu.
        await context.read<AuthProvider>().refreshUser();
        if (!mounted) return;

        // Snackbar / kutlamayi pop'tan ONCE goster: pop sonrasi bu context
        // artik gecerli degil ve mesaj hic gorunmuyordu.
        if (grant != null && grant.hasReward) {
          await _showJetonRewardDialog(grant);
          if (!mounted) return;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("DevEducation Pro'ya hoş geldin!"),
              backgroundColor: Colors.green,
            ),
          );
        }
        Navigator.pop(context, true);
      }
    } catch (e) {
      // Ham StoreKit/Adapty metnini kullaniciya gostermiyoruz; teknik ayrinti
      // yalnizca loga gidiyor.
      debugPrint('Satin alma hatasi: $e');
      if (!mounted) return;
      _showError();
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  Future<void> _restore() async {
    if (_purchasing) return;
    setState(() => _purchasing = true);
    try {
      final restored = await _service.restorePurchases();
      if (!mounted) return;
      if (restored) {
        // Bkz. _purchase(): once jetonu al, sonra provider'i yenile.
        final grant = await _service.claimProJeton();
        if (!mounted) return;

        await context.read<AuthProvider>().refreshUser();
        if (!mounted) return;

        if (grant != null && grant.hasReward) {
          await _showJetonRewardDialog(grant);
          if (!mounted) return;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_t(
                  'Satın almaların geri yüklendi',
                  'Your purchases were restored',
                  'Deine Käufe wurden wiederhergestellt',
                  'Tus compras se han restaurado')),
              backgroundColor: Colors.green,
            ),
          );
        }
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_t(
                'Geri yüklenecek bir satın alma bulunamadı',
                'No purchases found to restore',
                'Keine Käufe zum Wiederherstellen gefunden',
                'No se han encontrado compras que restaurar')),
          ),
        );
      }
    } catch (e) {
      debugPrint('Geri yukleme hatasi: $e');
      if (!mounted) return;
      _showError();
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_t(
            'İşlem tamamlanamadı. İnternetini kontrol edip tekrar dene.',
            'That did not go through. Check your connection and try again.',
            'Das hat nicht geklappt. Prüfe deine Verbindung und versuch es erneut.',
            'No se ha podido completar. Comprueba tu conexión e inténtalo de nuevo.')),
        backgroundColor: AppTheme.errorRed,
      ),
    );
  }

  /// Kapat / geri hareketinde bir kez calisir.
  void _closeRequested() {
    if (_exitOfferShown) {
      Navigator.pop(context);
      return;
    }
    _showExitOffer();
  }

  /// "Bir dakika" teklifi.
  ///
  /// ONEMLI: burada uydurma bir indirim fiyati YAZMIYORUZ. Fiyat her zaman
  /// StoreKit'ten geliyor. Iki durum var:
  ///
  ///  * App Store Connect'te indirimli yillik urun (ya da yillik urune bagli
  ///    bir promosyon teklifi) tanimliysa, teklif o urunun GERCEK fiyatini ve
  ///    standart yilliga gore gercek farkini gosterir.
  ///  * Tanimli degilse teklif indirim iddia etmez; yalnizca yillik planin
  ///    aylik karsiligini ve haftalik/aylik plana gore gercek tasarrufu
  ///    gosterir.
  Future<void> _showExitOffer() async {
    final yearly = _products
        .where(_isYearly)
        .where((p) => !_isDiscountOffer(p))
        .firstOrNull;
    final discounted = _products.where(_isDiscountOffer).firstOrNull;
    final offer = discounted ?? yearly;

    setState(() => _exitOfferShown = true);

    // Gosterilecek bir plan yoksa dogrudan cikiyoruz.
    if (offer == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    // Capa: cocugun/velinin O AN baktigi plan. Once her zaman haftalik
    // plana gore karsilastiriliyordu; yillik plani secmis birine
    // "yillik daha ucuz" demek bir sey soylemiyordu.
    final secili = _selected;
    final anchorProduct = discounted != null
        ? yearly
        : ((secili != null && !_isYearly(secili))
            ? secili
            : (_products.where(_isWeekly).firstOrNull ?? _monthlyProduct));
    final saving = _savingAgainst(offer, anchorProduct);

    // AYNI FIYATI IKINCI KEZ GOSTERMIYORUZ.
    //
    // Indirimli bir urun tanimli degilken, yillik plana bakan birine
    // cikista yine yillik plani ayni fiyatla gostermek "son firsat"
    // kilifinda hicbir sey sunmamak demekti — kullanici ayni 34,99'u
    // iki kez goruyordu. Boyle bir ekran guven kaybettiriyor ve
    // App Store'un karanlik desen tanimina yaklasiyor.
    //
    // Teklif yalnizca SOYLEYECEK YENI BIR SEYI varsa aciliyor:
    // ya gercek bir indirimli urun var, ya da bakilan plana gore
    // yilligin gercek bir tasarrufu var.
    final soyleyecekSeyVar = discounted != null ||
        (anchorProduct != null && saving != null && saving > 0);
    if (!soyleyecekSeyVar) {
      if (mounted) Navigator.pop(context);
      return;
    }

    final take = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _ExitOfferSheet(
        lang: _lang,
        isEn: _isEn,
        title: discounted != null
            ? _t('Gitmeden önce…', 'Before you go…', 'Bevor du gehst…', 'Antes de irte…')
            : _t('Bir dakika…', 'One moment…', 'Einen Moment…', 'Un momento…'),
        headline: discounted != null
            ? _t(
                'Sana özel bir fiyatımız var',
                'We have a special price for you',
                'Wir haben einen besonderen Preis für dich',
                'Tenemos un precio especial para ti')
            : _t(
                'Yıllık plan çok daha uygun',
                'The yearly plan costs far less',
                'Der Jahresplan kostet viel weniger',
                'El plan anual cuesta mucho menos'),
        priceLine: offer.price.localizedString ??
            _formatPrice(offer.price.amount, offer.price.currencyCode),
        perMonth: _t(
            'ayda ${_monthlyEquivalent(offer)}',
            '${_monthlyEquivalent(offer)} / month',
            '${_monthlyEquivalent(offer)} / Monat',
            '${_monthlyEquivalent(offer)} / mes'),
        anchorLine: (anchorProduct != null && saving != null)
            ? _formatPrice(_monthlyAmount(anchorProduct) * 12,
                anchorProduct.price.currencyCode)
            : null,
        saving: saving,
      ),
    );

    if (!mounted) return;
    if (take == true) {
      setState(() => _selected = offer);
      await _purchase();
      return;
    }
    if (mounted) Navigator.pop(context);
  }

  /// Pro jetonu kazanildiginda gosterilen kutlama penceresi.
  Future<void> _showJetonRewardDialog(ProJetonGrant grant) {
    final title = grant.isWelcome
        ? _t("Pro'ya hoş geldin! 🎉", 'Welcome to Pro! 🎉',
            'Willkommen bei Pro! 🎉', '¡Bienvenido a Pro! 🎉')
        : _t(
            'Aylık Pro jetonun hazır 🎉',
            'Your monthly Pro tokens are here 🎉',
            'Deine monatlichen Pro-Münzen sind da 🎉',
            'Tus fichas Pro del mes ya están aquí 🎉');
    final subtitle = grant.isWelcome
        ? _t(
            'Hoş geldin paketin hesabına eklendi. Pro olduğun her ay 300 '
                'jeton daha gelecek.',
            'Your welcome pack has been added. You get 300 more tokens '
                'every month you stay Pro.',
            'Dein Willkommenspaket ist da. Solange du Pro bist, kommen '
                'jeden Monat 300 weitere Münzen dazu.',
            'Tu paquete de bienvenida ya está en tu cuenta. Cada mes que '
                'seas Pro recibirás 300 fichas más.',
          )
        : _t(
            'Bu ayın Pro jetonu hesabına eklendi.',
            'This month\'s Pro tokens have been added.',
            'Die Pro-Münzen für diesen Monat sind da.',
            'Ya tienes las fichas Pro de este mes.',
          );

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🪙', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(
              '+${grant.granted}',
              style:
                  AppTheme.number(fontSize: 40, color: const Color(0xFFF59E0B)),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _inkSoft,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yeni bakiyen: ${grant.balance} jeton',
              style: AppTheme.number(fontSize: 14, color: _ink),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(_t('Markete göz at', 'Browse the shop', 'Zum Shop',
                'Ver la tienda')),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------- yardimci

  /// Urunde ucretsiz deneme varsa gun sayisini dondurur, yoksa null.
  ///
  /// Deneme fazini `paymentMode` enum adiyla degil fiyatinin sifir olmasiyla
  /// tespit ediyoruz: SDK surumleri arasinda enum isimleri degisebiliyor,
  /// "bedava faz" tanimi degismiyor.
  int? _trialDays(AdaptyPaywallProduct? product) {
    final phases = product?.subscription?.offer?.phases;
    if (phases == null || phases.isEmpty) return null;
    for (final phase in phases) {
      if (phase.price.amount > 0) continue;
      final period = phase.subscriptionPeriod;
      final count = period.numberOfUnits *
          (phase.numberOfPeriods <= 0 ? 1 : phase.numberOfPeriods);
      switch (period.unit) {
        case AdaptyPeriodUnit.day:
          return count;
        case AdaptyPeriodUnit.week:
          return count * 7;
        case AdaptyPeriodUnit.month:
          return count * 30;
        case AdaptyPeriodUnit.year:
          return count * 365;
        default:
          return count;
      }
    }
    return null;
  }

  /// "12 Eylül" / "12 September" / "12. September" / "12 de septiembre"
  ///
  /// Deneme takviminde gercek tarih gosteriyoruz; "5. gün" gibi soyut
  /// ifadelerin kullanicinin kafasinda karsiligi yok.
  ///
  /// Ay adlari ONCEDEN elle yazilmis Turkce bir listeden geliyordu; dort
  /// dilde de "12 Eylül" yaziyordu. Artik `intl` bicimliyor: hem dogru
  /// dil, hem her dilin kendi tarih sirasi (Almanca'da gun sonrasi
  /// nokta, Ispanyolca'da "de" gibi).
  String _dateLabel(int daysFromNow) {
    final d = DateTime.now().add(Duration(days: daysFromNow));
    try {
      return DateFormat.MMMMd(_lang).format(d);
    } catch (_) {
      // Dil verisi yuklenmemisse tarihi kaybetmeyelim.
      return DateFormat.MMMMd().format(d);
    }
  }

  bool _isYearly(AdaptyPaywallProduct p) =>
      p.vendorProductId.contains('yearly');
  bool _isWeekly(AdaptyPaywallProduct p) =>
      p.vendorProductId.contains('weekly');
  bool _isDiscountOffer(AdaptyPaywallProduct p) =>
      p.vendorProductId == SubscriptionService.yearlyDiscountProductId;

  /// Planlarin gosterim sirasi: haftalik -> aylik -> yillik.
  /// Kisa taahhutten uzuna dogru; en degerli plan en altta ve secili.
  int _planRank(AdaptyPaywallProduct p) {
    if (_isWeekly(p)) return 0;
    if (_isYearly(p)) return 2;
    return 1;
  }

  String _periodLabel(AdaptyPaywallProduct p) {
    if (_isWeekly(p)) {
      return _t('Haftalık', 'Weekly', 'Wöchentlich', 'Semanal');
    }
    if (_isYearly(p)) return _t('Yıllık', 'Yearly', 'Jährlich', 'Anual');
    return _t('Aylık', 'Monthly', 'Monatlich', 'Mensual');
  }

  String _renewLabel(AdaptyPaywallProduct p) {
    if (_isWeekly(p)) {
      return _t('Her hafta yenilenir', 'Renews weekly',
          'Verlängert sich wöchentlich', 'Se renueva cada semana');
    }
    if (_isYearly(p)) {
      return _isEn
          ? '${_monthlyEquivalent(p)} / month'
          : 'Ayda ${_monthlyEquivalent(p)} yapar';
    }
    return _isEn ? 'Renews monthly' : 'Her ay yenilenir';
  }

  AdaptyPaywallProduct? get _monthlyProduct =>
      _products.where((p) => !_isYearly(p)).firstOrNull;

  String _formatPrice(double amount, String? currency) {
    final symbol = switch (currency) {
      'TRY' => '₺',
      'USD' => r'$',
      'EUR' => '€',
      _ => currency == null ? '' : '$currency ',
    };
    final text = amount
        .toStringAsFixed(2)
        .replaceAll('.', ',')
        .replaceFirst(RegExp(r',00$'), '');
    return symbol.length == 1 ? '$symbol$text' : '$symbol$text';
  }

  /// Planin aylik karsiligi — "yilda 1.199 TL" tek basina anlamsiz,
  /// karsilastirmayi kullanici yapmak zorunda kalmasin.
  String _monthlyEquivalent(AdaptyPaywallProduct product) {
    final price = product.price;
    final divisor =
        _isYearly(product) ? 12.0 : (_isWeekly(product) ? 0.2301 : 1.0);
    return _formatPrice(price.amount / divisor, price.currencyCode);
  }

  /// Bir plani baska bir plana gore aylik maliyet farki (yuzde).
  /// Ikisi de yoksa null — capasi olmayan bir "%X tasarruf" iddiasi
  /// gostermiyoruz.
  int? _savingAgainst(
      AdaptyPaywallProduct cheaper, AdaptyPaywallProduct? anchor) {
    if (anchor == null) return null;
    final a = _monthlyAmount(anchor);
    final b = _monthlyAmount(cheaper);
    if (a <= 0 || b <= 0 || b >= a) return null;
    final saving = (1 - b / a) * 100;
    return saving < 5 ? null : saving.round();
  }

  double _monthlyAmount(AdaptyPaywallProduct p) {
    if (_isYearly(p)) return p.price.amount / 12;
    if (_isWeekly(p)) return p.price.amount / 0.2301;
    return p.price.amount;
  }

  /// Aylik plan x12 ile yillik plan arasindaki tasarruf yuzdesi.
  /// Aylik plan yoksa rozeti hic gostermiyoruz — capasi olmayan bir
  /// "%40 tasarruf" rozeti guven kaybettiriyor.
  int? _savingPercent() {
    final yearly = _products.where(_isYearly).firstOrNull;
    if (yearly == null) return null;
    // Capa: en pahali kisa plan. Haftalik varsa karsilastirma ona gore,
    // yoksa aylik. Ikisi de yoksa rozet gosterilmiyor — karsilastirilacak
    // bir fiyat olmadan "%X tasarruf" iddiasi guven kaybettiriyor.
    final anchor = _products.where(_isWeekly).firstOrNull ?? _monthlyProduct;
    return _savingAgainst(yearly, anchor);
  }

  // ---------------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Kullanici vazgecip geri donerken bir kez daha yillik plani
      // gosteriyoruz. Ikinci kez geri basarsa ekran kapaniyor — kapanisi
      // engelleyen bir tuzak degil.
      canPop: _exitOfferShown,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _showExitOffer();
      },
      child: Scaffold(
        backgroundColor: _surface,
        body: Stack(
          children: [
            const Positioned.fill(child: PaywallSky()),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: _loading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: AppTheme.primaryBlue),
                          )
                        : _buildContent(),
                  ),
                  _buildStickyCta(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
      child: Row(
        children: [
          IconButton(
            tooltip: _t('Kapat', 'Close', 'Schließen', 'Cerrar'),
            // 44x44 dokunma alani: kapat tusu her zaman gorunur ve rahat
            // basilabilir olmali, yoksa App Store bunu karanlik desen sayiyor.
            onPressed: _closeRequested,
            icon: const Icon(Icons.close_rounded, color: _ink),
          ),
          // SPACER + FLEXIBLE IKISI BIRDEN YANLISTI.
          //
          // Spacer bir Expanded(flex: 1); Flexible da flex: 1. Ikisi
          // bos alani ESIT bolusuyordu ve dugme kendi yarisinin BASINA
          // hizalaniyordu — yani ekranin ortasina. Sag ust kosede
          // olmasi gerekiyordu.
          //
          // Expanded + sağa hizalama: dugme sag kenara yapisiyor,
          // uzun ceviriler icin de yer birakiyor.
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
              onPressed: _purchasing ? null : _restore,
              child: Text(
                // Üst çubukta yer dar; uzun cümle her dilde ya taşıyor
                // ya kırpılıyordu. Apple'ın istediği şey "geri yükleme
                // yolu olsun"; kısa etiket bunu bozmuyor.
                _t('Geri yükle', 'Restore', 'Wiederherstellen',
                    'Restaurar'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: _inkSoft,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final trial = _trialDays(_selected);
    // SIRA BILINCLI: planlar KAYDIRMADAN gorunmeli.
    //
    // Onceden ustte kahraman + uc satirlik fayda karti + "Neler dahil?"
    // acilir bolumu vardi ve "Planini sec" ekranin altinda kaliyordu;
    // fiyati gormek icin kaydirmak gerekiyordu. Fiyati saklamak hem
    // satisi dusuruyor hem de App Store'un "teklif acikca gorunsun"
    // beklentisiyle ters. Detay (Neler dahil) planlarin ALTINA indi:
    // isteyen kaydirip okuyor, istemeyen fiyati hemen goruyor.
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        _buildHero(trial),
        const SizedBox(height: 16),
        _buildHighlights(),
        const SizedBox(height: 14),
        _buildPlans(),
        if (trial != null) ...[
          const SizedBox(height: 18),
          _buildTrialTimeline(trial),
        ],
        const SizedBox(height: 14),
        _buildExtras(),
      ],
    );
  }

  Widget _buildHero(int? trial) {
    return Column(
      children: [
        // Soguk bir rozet ikonu yerine COCUGUN ARKADASI duruyor.
        //
        // Paranin istendigi ekran, cocugun ebeveynine gosterdigi ekran.
        // Tanidik bir yuz, kurumsal bir madalyadan cok daha iyi
        // karsilaniyor. Tur elle verilmiyor: cocuk hangi karakteri
        // sectiyse o geliyor (varsayilan Puf).
        const _FloatingMascot(size: 74),
        const SizedBox(height: 6),
        Text(
          // Fayda basligi, ozellik basligi degil: "Sinirsiz ders" degil
          // "daha hizli ogren".
          _t(
              'DevEducation Pro ile\ndaha hızlı öğren',
              'Learn faster with\nDevEducation Pro',
              'Lerne schneller mit\nDevEducation Pro',
              'Aprende más rápido con\nDevEducation Pro'),
          textAlign: TextAlign.center,
          // headlineLarge -> headlineMedium -> headlineSmall. Iki
          // satirlik baslik headlineMedium'da 128 piksel tutuyordu;
          // olculdu (test/paywall_fold_test.dart) ve planlari ekranin
          // disina iten en buyuk kalem oydu.
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: _ink,
                height: 1.15,
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          trial != null
              ? _t(
                  '$trial gün ücretsiz dene, sonra istediğin zaman iptal et.',
                  'Try $trial days free, cancel any time.',
                  '$trial Tage gratis testen, jederzeit kündbar.',
                  'Prueba $trial días gratis y cancela cuando quieras.')
              // Kisaltildi: iki satira saran bir cumle, ucuncu plan
              // kartini ekranin disina itiyordu.
              : _t(
                  'Kilitli kurslar, oyunlar ve sertifika açılır.',
                  'Locked courses, games and the certificate open up.',
                  'Gesperrte Kurse, Spiele und Zertifikat werden frei.',
                  'Se desbloquean cursos, juegos y certificado.'),
          textAlign: TextAlign.center,
          style:
              Theme.of(context).textTheme.bodyLarge?.copyWith(color: _inkSoft),
        ),
      ],
    );
  }

  Widget _card({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _hairline),
      ),
      child: child,
    );
  }

  /// Uc fayda, YAN YANA.
  ///
  /// Onceden alt alta uc satirdi ve tek basina ~150 piksel yer
  /// kapliyordu; planlari ekranin disina iten sey buydu. Aciklama
  /// cumleleri "Neler dahil?" bolumune indi, burada baslik kaldi.
  Widget _buildHighlights() {
    final count = math.min(_highlights.length, _visibleHighlights);
    // Her fayda icin ayri renk: tek renkli bir sira soguk duruyor,
    // ekranin geri kalani renkliyken ozellikle.
    const tones = [
      Color(0xFFFF8A65),
      Color(0xFF4DB6AC),
      Color(0xFF7E6BF0),
    ];
    // IntrinsicHeight: "Ileri seviye kurslar" iki satira sardigi icin
    // ortadaki kart digerlerinden uzun kaliyor ve sira egri
    // gorunuyordu. Ucu de en uzunun boyuna uzuyor.
    return IntrinsicHeight(
      child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white),
              ),
              child: Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: tones[i % tones.length].withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(_highlights[i].$1,
                        size: 18, color: tones[i % tones.length]),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _highlights[i].$2,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _ink,
                        fontWeight: FontWeight.w800,
                        height: 1.25),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
      ),
    );
  }

  Widget _buildExtras() {
    return _card(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      // ExpansionTile bir ListTile: murekkep dalgasini EN YAKIN Material
      // uzerine ciziyor. Kart bir DecoratedBox oldugu icin o dalga
      // gorunmez kaliyordu (Flutter bunu calisma aninda uyari olarak
      // basiyor). Saydam bir Material, dokunma geri bildirimini geri
      // veriyor.
      child: Material(
        color: Colors.transparent,
        child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: 12),
          title: Text(
            _t('Neler dahil?', "What's included?", 'Was ist enthalten?',
              '¿Qué incluye?'),
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: _ink, fontWeight: FontWeight.w700),
          ),
          children: [
            for (final e in _extras)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_rounded,
                        size: 18, color: AppTheme.successGreen),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        e,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: _inkSoft),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        ),
      ),
    );
  }

  /// Deneme takvimi: kullanici parasinin ne zaman cikacagini bilsin.
  /// Bu bolum uzun ozellik listesinden daha iyi calisiyor cunku tek soruyu
  /// cevapliyor: "ne zaman ucretlendirileceğim?"
  Widget _buildTrialTimeline(int trialDays) {
    final reminderDay = trialDays >= 3 ? trialDays - 2 : trialDays;
    final steps = [
      (
        Icons.lock_open_rounded,
        AppTheme.primaryBlue,
        _t('Bugün', 'Today', 'Heute', 'Hoy'),
        _t(
            'Tüm Pro içerik anında açılır.',
            'All Pro content unlocks right away.',
            'Alle Pro-Inhalte sind sofort frei.',
            'Todo el contenido Pro se abre al instante.'),
      ),
      (
        Icons.notifications_active_rounded,
        AppTheme.warningOrange,
        _dateLabel(reminderDay),
        _t(
            'Deneme bitmeden hatırlatma göndeririz.',
            'We send a reminder before the trial ends.',
            'Wir erinnern dich, bevor die Testphase endet.',
            'Te avisamos antes de que acabe la prueba.'),
      ),
      (
        Icons.star_rounded,
        AppTheme.successGreen,
        _dateLabel(trialDays),
        _t(
            'Deneme biter, abonelik başlar. İstersen önce iptal et.',
            'The trial ends and the subscription starts. Cancel before '
                'then if you want.',
            'Die Testphase endet und das Abo beginnt. Du kannst vorher '
                'jederzeit kündigen.',
            'La prueba termina y empieza la suscripción. Puedes cancelar '
                'antes.'),
      ),
    ];

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('Ücretsiz denemen nasıl işliyor?', 'How your free trial works',
              'So funktioniert deine Gratis-Testphase',
              'Cómo funciona tu prueba gratuita'),
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: _ink, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < steps.length; i++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: steps[i].$2.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(steps[i].$1, size: 17, color: steps[i].$2),
                      ),
                      if (i < steps.length - 1)
                        Expanded(
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: _hairline,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          bottom: i < steps.length - 1 ? 18 : 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            steps[i].$3,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                    color: _ink, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            steps[i].$4,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: _inkSoft),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Plan bolumu.
  ///
  /// Bastaki anahtar bir SUS DEGIL: test bu noktanin sabit alt cubuktan
  /// ne kadar uzakta oldugunu olcup uc plan kartinin kaydirmadan sigip
  /// sigmadigina bakiyor (bkz. test/paywall_fold_test.dart).
  Widget _buildPlans() {
    if (_products.isEmpty) {
      return KeyedSubtree(
        key: const ValueKey('paywall-plans'),
        child: _buildPlansUnavailable(),
      );
    }

    // Haftalik -> aylik -> yillik. Kisa taahhutten uzuna; en degerli plan
    // en altta ve onceden secili.
    final sorted = [..._products]
      ..removeWhere(
          _isDiscountOffer) // indirimli urun yalnizca cikis teklifinde
      ..sort((a, b) => _planRank(a).compareTo(_planRank(b)));
    final saving = _savingPercent();

    return Column(
      key: const ValueKey('paywall-plans'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _t('Planını seç', 'Choose your plan', 'Wähle deinen Plan',
              'Elige tu plan'),
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: _ink, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < sorted.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                _buildPlanChip(sorted[i], saving),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Tek bir plan — YAN YANA dizilen kompakt kart.
  ///
  /// Onceden alt alta uc genis satirdi ve tek basina ~270 piksel
  /// tutuyordu; ucuncu plan ekranin altinda kaliyor, fiyati gormek icin
  /// kaydirmak gerekiyordu. Yan yana dizilince ayni bilgi ~120 pikselde
  /// duruyor ve UC PLAN DA ayni anda gorunuyor.
  ///
  /// Karsilastirma fiyati (ustu cizili) ve tasarruf rozeti YALNIZCA
  /// gercek bir capa urun varken ciziliyor; uydurma indirim yok.
  Widget _buildPlanChip(AdaptyPaywallProduct product, int? saving) {
    final isYearly = _isYearly(product);
    final isSelected = _selected?.vendorProductId == product.vendorProductId;
    final price = product.price.localizedString ??
        _formatPrice(product.price.amount, product.price.currencyCode);
    final showBadge = isYearly && saving != null;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selected = product);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryBlue.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? AppTheme.primaryBlue : _hairline,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rozet kartin ICINDE: disari tasan bir rozet yan yana
              // dizilimde komsu karta giriyordu.
              SizedBox(
                height: 18,
                child: showBadge
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _isEn ? '-$saving%' : '%$saving',
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 6),
              Text(
                _periodLabel(product),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: _inkSoft, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(price,
                    style: AppTheme.number(fontSize: 18, color: _ink)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlansUnavailable() {
    // Neden bos oldugunu ayirt edip kullaniciya isine yarayan bir mesaj ver;
    // eskiden her durumda tek bir "Planlar yüklenemedi" gosteriliyordu.
    final failure = _service.lastFailure;
    final String message;
    final String hint;
    switch (failure) {
      case SubscriptionLoadFailure.paywallUnavailable:
        message = _t(
            'Abonelik planlarına şu anda ulaşılamıyor',
            'Subscription plans are unavailable right now',
            'Die Abo-Pläne sind gerade nicht verfügbar',
            'Los planes no están disponibles ahora mismo');
        hint = _t(
            'İnternet bağlantını kontrol edip tekrar dene.',
            'Check your connection and try again.',
            'Prüfe deine Verbindung und versuch es erneut.',
            'Comprueba tu conexión e inténtalo de nuevo.');
        break;
      case SubscriptionLoadFailure.noProducts:
        message = _t(
            'Abonelik planları henüz hazır değil',
            'Subscription plans are not ready yet',
            'Die Abo-Pläne sind noch nicht bereit',
            'Los planes todavía no están listos');
        hint = _t(
            'Kısa bir süre sonra tekrar dene.',
            'Try again in a moment.',
            'Versuch es gleich noch einmal.',
            'Inténtalo dentro de un momento.');
        break;
      case SubscriptionLoadFailure.error:
      case null:
        message = _t(
            'Planlar yüklenemedi',
            'Plans could not be loaded',
            'Die Pläne konnten nicht geladen werden',
            'No se han podido cargar los planes');
        hint = _t('Lütfen tekrar dene.', 'Please try again.',
            'Bitte versuch es erneut.', 'Inténtalo de nuevo.');
        break;
    }

    return _card(
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, color: _inkSoft, size: 36),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: _ink, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: _inkSoft),
          ),
          const SizedBox(height: 8),
          // Sabit Turkce idi: planlar yuklenemedigi anda Alman ya da
          // Ispanyol kullanici tek eylem dugmesini Turkce goruyordu.
          TextButton(
            onPressed: _load,
            child: Text(_t('Tekrar dene', 'Try again', 'Erneut versuchen',
                'Reintentar')),
          ),
        ],
      ),
    );
  }

  /// Alt butonu icerikle birlikte kaydirmiyoruz: fiyat ve buton her an
  /// gorunur kalmali, kullanici uzun listeyi asmak zorunda kalmamali.
  Widget _buildStickyCta() {
    final trial = _trialDays(_selected);
    final enabled = _selected != null && !_purchasing;

    final String label;
    if (_selected == null) {
      label = _t('Plan seç', 'Choose a plan', 'Plan wählen', 'Elige un plan');
    } else if (trial != null) {
      label = _t('Ücretsiz Denemeyi Başlat', 'Start Free Trial', 'Gratis testen',
          'Empezar prueba gratis');
    } else {
      label = _t("Pro'yu Aç", 'Unlock Pro', 'Pro freischalten', 'Desbloquear Pro');
    }

    final String? sub;
    if (_selected == null) {
      sub = null;
    } else if (trial != null) {
      final price = _selected!.price.localizedString ?? '';
      // Deneme kosulu TAM CUMLE olarak yaziliyor: ciplak "7 gün
      // ücretsiz" App Store'un 3.1.2 maddesine gore eksik; sonrasinda ne
      // olacagi ayni ekranda ve ayni okunaklilikta olmali.
      sub = _t(
        '$trial gün ücretsiz, şimdi ödeme yok. Sonra $price.',
        '$trial days free, nothing to pay now. Then $price.',
        '$trial Tage kostenlos, jetzt zahlst du nichts. Danach $price.',
        '$trial días gratis, ahora no pagas nada. Después $price.',
      );
    } else {
      final price = _selected!.price.localizedString ?? '';
      // Yenilenme sikligi ("Her ay yenilenir") eskiden plan kartinda
      // yaziyordu; kartlar yan yana dizilip kucultulunce oraya
      // sigmiyor. Bilgi kaybolmasin diye buraya tasindi — App Store
      // fiyatin yaninda surenin de acikca gorunmesini istiyor.
      final renew = _renewLabel(_selected!);
      sub = _t(
        '$price · $renew · İstediğin zaman iptal et.',
        '$price · $renew · Cancel any time.',
        '$price · $renew · Jederzeit kündbar.',
        '$price · $renew · Cancela cuando quieras.',
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        border: const Border(top: BorderSide(color: _hairline)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          // Alt cubuk ekranin ucte birini kapliyordu. Dolgular
          // kisildi; metinlerin hicbiri kirpilmadi, yalnizca aralar
          // sikilastirildi.
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ana buton uygulamanin geri kalaniyla ayni: basildiginda
              // gercekten cokuyor, yukleniyor durumunu kendi icinde
              // gosteriyor.
              PressButton(
                label: label,
                loading: _purchasing,
                onPressed: enabled ? _purchase : null,
                height: 52,
              ),
              if (sub != null) ...[
                const SizedBox(height: 6),
                Text(
                  sub,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: _inkSoft),
                ),
              ],
              const SizedBox(height: 2),
              _buildLegalRow(),
            ],
          ),
        ),
      ),
    );
  }

  /// Yasal baglanti dugmelerinin sikilastirilmis bicimi.
  ///
  /// Varsayilan TextButton, Material'in 48 piksellik dokunma kutusunu
  /// GORSEL yukseklik olarak da uyguluyor ve iki dugme alt cubukta
  /// ~30 piksel bos yer yiyordu. shrinkWrap o fazlaligi kaldiriyor;
  /// minimumSize ile dokunma alani 40 piksel kaliyor — baglantilar
  /// hala rahat basiliyor.
  static final ButtonStyle _legalLinkStyle = TextButton.styleFrom(
    minimumSize: const Size(0, 40),
    padding: const EdgeInsets.symmetric(horizontal: 8),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
  );

  Widget _buildLegalRow() {
    // Satir yuksekligi sikilastirildi (1.25). Metnin KENDISI
    // kisaltilmadi — App Store bu cumlenin tamamini istiyor — ama uc
    // satir 80 pikselden 66 piksele iniyor ve o fark planlara gidiyor.
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: _inkSoft.withValues(alpha: 0.75),
          height: 1.25,
        );
    return Column(
      children: [
        // YASAL METIN SABIT TURKCE IDI.
        //
        // Odemenin istendigi ekranin en kritik cumlesi — otomatik
        // yenileme aciklamasi — dort dilde de Turkce goruntyordu.
        // App Store incelemesi bu cumleyi kullanicinin dilinde ve satin
        // alma teklifiyle AYNI ekranda gormek istiyor.
        Text(
          _t(
            'Abonelik otomatik yenilenir. Dönem bitmeden en az 24 saat önce '
                'iptal edilmezse yenilenir; ödeme App Store hesabından '
                'tahsil edilir.',
            'The subscription renews automatically. Unless it is cancelled '
                'at least 24 hours before the period ends, it renews and '
                'your App Store account is charged.',
            'Das Abo verlängert sich automatisch. Wird es nicht spätestens '
                '24 Stunden vor Ablauf gekündigt, verlängert es sich und '
                'dein App-Store-Konto wird belastet.',
            'La suscripción se renueva automáticamente. Si no se cancela '
                'al menos 24 horas antes de que acabe el periodo, se '
                'renueva y se cobra en tu cuenta de App Store.',
          ),
          textAlign: TextAlign.center,
          style: style,
        ),
        // TEK SATIR DEĞİL, SARAN SATIR.
        //
        // Bu bir `Row`'du ve iki bağlantı yan yana sığmak zorundaydı.
        // Türkçede sığıyordu; İngilizcede 8.5 piksel, Almancada
        // ("Nutzungsbedingungen · Datenschutzerklärung") 158 piksel
        // taşıyordu — yani ödeme ekranının altında sarı-siyah taşma
        // şeridi. Wrap ile dar ekranda alt alta iniyorlar.
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            TextButton(
              style: _legalLinkStyle,
              onPressed: () => _openUrl(_termsUrl),
              child: Text(
                  _t('Kullanım Koşulları', 'Terms of Use',
                      'Nutzungsbedingungen', 'Condiciones de uso'),
                  style: style),
            ),
            Text('·', style: style),
            TextButton(
              style: _legalLinkStyle,
              onPressed: () => _openUrl(_privacyUrl),
              child: Text(
                  _t('Gizlilik Politikası', 'Privacy Policy',
                      'Datenschutzerklärung', 'Política de privacidad'),
                  style: style),
            ),
          ],
        ),
      ],
    );
  }

  static const String _termsUrl =
      'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';
  static const String _privacyUrl =
      'https://oguzhnkurt.github.io/devkom_App1/privacy-policy.html';

  Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_t(
                  'Bağlantı açılamadı',
                  'The link could not be opened',
                  'Der Link konnte nicht geöffnet werden',
                  'No se ha podido abrir el enlace'))),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_t(
                  'Bağlantı açılamadı',
                  'The link could not be opened',
                  'Der Link konnte nicht geöffnet werden',
                  'No se ha podido abrir el enlace'))),
        );
      }
    }
  }
}

/// Plan kartindaki secim gostergesi.

/// Paywall arka plani.
///
/// Ekran duz beyazdi ve "kurumsal" degil bos duruyordu. Yavasca yer degistiren
/// iki renk kumesi koyduk: dikkat dagitmayacak kadar yavas (12 sn'lik dongu),
/// metnin okunurlugunu bozmayacak kadar soluk. Hareketi azaltma ayari acikken
/// animasyon durur, gradyan sabit kalir.
/// Kullanici vazgecip cikarken gosterilen son teklif.
///
/// Kapatilabilir ve "Hayir, tesekkurler" secenegi acikca duruyor: ikinci
/// kez geri basan kullanici ekrandan cikabiliyor. Kapatilmasi zor bir
/// teklif karanlik desen sayilir ve App Store incelemesinde risk.
class _ExitOfferSheet extends StatelessWidget {
  const _ExitOfferSheet({
    required this.lang,
    required this.isEn,
    required this.title,
    required this.headline,
    required this.priceLine,
    required this.perMonth,
    required this.anchorLine,
    required this.saving,
  });

  /// Arayuz dili. `isEn` iki dil varken yetiyordu; dort dilde yetmiyor.
  final String lang;

  final bool isEn;
  final String title;
  final String headline;
  final String priceLine;
  final String perMonth;

  /// Karsilastirma fiyati; yoksa null ve hicbir indirim iddiasi yazilmaz.
  final String? anchorLine;
  final int? saving;

  String _t(String tr, String en, [String? de, String? es]) =>
      AppLang.pick(lang, tr: tr, en: en, de: de, es: es);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDE1E7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: Color(0xFF5B616E),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                headline,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 22,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF14161A),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (anchorLine != null) ...[
                    Text(
                      anchorLine!,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 15,
                        color: Color(0xFF9AA1AD),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Text(priceLine,
                      style: AppTheme.number(
                          fontSize: 30, color: const Color(0xFF14161A))),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                perMonth,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5B616E),
                ),
              ),
              if (saving != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isEn ? 'Save $saving%' : '%$saving tasarruf',
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.successGreen,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              PressButton(
                label: isEn ? 'Get This Price' : 'Bu Fiyattan Al',
                height: 54,
                onPressed: () => Navigator.pop(context, true),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  isEn
                      ? 'No thanks'
                      : _t('Hayır, teşekkürler', 'No thanks', 'Nein, danke',
                          'No, gracias'),
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13.5,
                    color: Color(0xFF5B616E),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/// Pro ekranındaki maskot: yavaşça süzülüyor.
///
/// [Mascot] zaten nefes alıp göz kırpıyor; buradaki ek hareket yukarı
/// aşağı küçük bir süzülme. Bulutların arasında duran bir karakter
/// hissi veriyor. Hareket azaltılmışsa sabit duruyor.
class _FloatingMascot extends StatefulWidget {
  const _FloatingMascot({required this.size});

  final double size;

  @override
  State<_FloatingMascot> createState() => _FloatingMascotState();
}

class _FloatingMascotState extends State<_FloatingMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !Motion.reduced(context)) _c.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(_c.value);
          return Transform.translate(
            offset: Offset(0, -t * widget.size * 0.06),
            child: child,
          );
        },
        // Maskot AnimatedBuilder'in disinda kuruluyor: her karede
        // yeniden yaratilmasi gerekmiyor, yalnizca taşınıyor.
        child: Mascot(
          size: widget.size,
          mood: MascotMood.cheering,
          showShadow: false,
        ),
      ),
    );
  }
}
