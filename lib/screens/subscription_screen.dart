import 'dart:async';

import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../widgets/mascot.dart';
import 'pro_ekrani_parcalari.dart';
import '../services/subscription_service.dart';
import '../theme.dart';
import '../providers/settings_provider.dart';
import '../ui/motion.dart';
import '../utils/lang.dart';
import 'teklif_acilisi.dart';
import 'auth/hesap_ekrani.dart';
import '../widgets/parent_gate.dart';
import '../services/firebase_servisi.dart';

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
  const SubscriptionScreen(
      {super.key,
      this.zorunlu = false,
      this.onAcildi,
      this.yenidenKontrol,
      this.servis});

  /// Testler ve ekran goruntusu araci icin (sahte urunler).
  final SubscriptionService? servis;

  /// ZORUNLU (hard paywall) mod: [AbonelikKapisi] uygulamanin onune koyuyor.
  ///
  /// Ucretsiz tanisma suresi (4 dk) bitince geliyor; ucretsiz deneme yok
  /// (karar 6 Kas 2026, bkz. AbonelikKapisi). Bu modda ekran bir route
  /// degil, uygulamanin kendisinin yerinde duruyor; o yuzden:
  ///  * kapat tusu bir kez cikis teklifini aciyor, sonra gizleniyor;
  ///  * geri hareketi ekrani kapatmiyor;
  ///  * satin alma / geri yukleme basarili olunca `Navigator.pop` yerine
  ///    [onAcildi] cagriliyor.
  /// Geri yukleme, deneme takvimi ve yasal baglantilar aynen duruyor
  /// (App Store 3.1.2).
  final bool zorunlu;

  /// Zorunlu modda abonelik acilinca cagrilir.
  final VoidCallback? onAcildi;

  /// Zorunlu modda Hesap ekranindan (giris yap / hesabi sil) donulunce
  /// abonelik yeniden kontrol edilir: baska cihazda abone olmus biri giris
  /// yapinca iceri girebilmeli.
  final Future<void> Function()? yenidenKontrol;

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  late final SubscriptionService _service =
      widget.servis ?? SubscriptionService();

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
  bool get _isEn => _lang != 'tr'; // tr disindaki her dilde Ingilizce bicim

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
  static const Color _hairline = Color(0xFFE3E6EB);

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
    // Paywall gercekten planlarla ekranda: Adapty'ye bildir.
    if (products.isNotEmpty) _service.logShowPaywall();
    FirebaseServisi.instance.olay(Olay.paywallGoruntulendi, {
      'zorunlu': widget.zorunlu ? 1 : 0,
      'plan_sayisi': products.length,
    });
  }

  // ---------------------------------------------------------------- satin alma

  Future<void> _purchase() async {
    if (_selected == null || _purchasing) return;
    // Zorunlu modda ekran tanitimin hemen ardindan, cocugun elindeyken
    // geliyor. Satin alma (deneme dahil) ebeveyn kapisinin arkasinda:
    // magaza aciklamasi "kapidan gecmeden satin almaya ulasilmaz" diyor,
    // cocugun yanlislikla abonelik baslatmasini da onluyor.
    FirebaseServisi.instance.olay(Olay.satinAlmaDenendi, {
      'urun': _selected!.vendorProductId,
    });
    if (widget.zorunlu) {
      final gecti = await ParentGate.verify(context, lang: _lang);
      if (!gecti || !mounted) return;
    }
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
        _basarili();
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
        _basarili();
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

  Future<void> _hesabiAc() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HesapEkrani()),
    );
    if (!mounted) return;
    await widget.yenidenKontrol?.call();
  }

  /// Satin alma / geri yukleme basarili.
  void _basarili() {
    FirebaseServisi.instance.olay(Olay.abonelikBasladi, {
      'urun': _selected?.vendorProductId ?? '',
    });
    if (widget.zorunlu) {
      widget.onAcildi?.call();
    } else {
      Navigator.pop(context, true);
    }
  }

  /// Ekrani kapatir. Zorunlu modda kapatacak bir sey yok: kullanici
  /// planlarin oldugu ekranda kaliyor (kapat tusu da artik gizli).
  void _kapat() {
    if (widget.zorunlu) {
      if (mounted) setState(() {});
      return;
    }
    Navigator.pop(context);
  }

  /// Kapat / geri hareketinde bir kez calisir.
  void _closeRequested() {
    if (_exitOfferShown) {
      _kapat();
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
    // Indirimli urun yalnizca GERCEKTEN daha ucuzsa teklif sayiliyor
    // (bkz. _ucuzsaTeklif).
    final discounted =
        _ucuzsaTeklif(_products.where(_isDiscountOffer).firstOrNull, yearly);
    final offer = discounted ?? yearly;

    setState(() => _exitOfferShown = true);

    // Gosterilecek bir plan yoksa dogrudan cikiyoruz.
    if (offer == null) {
      if (mounted) _kapat();
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
      if (mounted) _kapat();
      return;
    }

    // ACILIS GOSTERISI (hediye -> konfeti -> rozet -> karsilastirma).
    //
    // Bir ornek ekran kaydindan alindi; oradaki "80% OFF FOREVER",
    // "tek seferlik" ve "bugun $240 kazan" iddialari ALINMADI. Buradaki
    // her sayi magazanin gonderdigi fiyatlardan hesaplaniyor
    // (bkz. teklif_acilisi.dart basindaki not).
    final yuzde = saving ??
        (yearly != null && discounted != null && yearly.price.amount > 0
            ? ((1 - discounted.price.amount / yearly.price.amount) * 100)
                .round()
            : 0);
    final capaYillik = anchorProduct == null
        ? null
        : (discounted != null
            ? anchorProduct.price.amount
            : _monthlyAmount(anchorProduct) * 12);
    final farkTutari =
        capaYillik == null ? null : capaYillik - offer.price.amount;
    final take = await TeklifAcilisi.goster(
      context,
      TeklifAcilisi(
        lang: _lang,
        yuzde: yuzde,
        indirimMi: discounted != null,
        teklifFiyati: offer.price.localizedString ??
            _formatPrice(offer.price.amount, offer.price.currencyCode),
        aylikKarsilik: _monthlyEquivalent(offer),
        normalFiyat: (anchorProduct == null || capaYillik == null)
            ? null
            : (discounted != null
                ? (anchorProduct.price.localizedString ??
                    _formatPrice(capaYillik, anchorProduct.price.currencyCode))
                : _formatPrice(capaYillik, anchorProduct.price.currencyCode)),
        normalEtiket: anchorProduct == null
            ? null
            : (discounted != null
                ? _t('Normal fiyat', 'Regular price', 'Normalpreis',
                    'Precio normal')
                : _t(
                    '${_periodLabel(anchorProduct)} plan',
                    '${_periodLabel(anchorProduct)} plan',
                    '${_periodLabel(anchorProduct)}er Plan',
                    'Plan ${_periodLabel(anchorProduct).toLowerCase()}')),
        fark: (farkTutari != null && farkTutari > 0)
            ? _formatPrice(farkTutari, offer.price.currencyCode)
            : null,
        denemeGun: _trialDays(offer),
      ),
    );

    if (!mounted) return;
    if (take == true) {
      setState(() => _selected = offer);
      await _purchase();
      return;
    }
    if (mounted) _kapat();
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

  bool _isYearly(AdaptyPaywallProduct p) =>
      p.vendorProductId.contains('yearly');
  bool _isWeekly(AdaptyPaywallProduct p) =>
      p.vendorProductId.contains('weekly');
  bool _isDiscountOffer(AdaptyPaywallProduct p) =>
      p.vendorProductId == SubscriptionService.yearlyDiscountProductId;

  /// Indirimli urun o ulkede GERCEKTEN daha ucuz mu.
  ///
  /// App Store fiyatlari ulke ulke ayri duruyor ve zamanla birbirinden
  /// kopuyor: standart yillik plan Turkiye'de ₺799,99'da kalmisken,
  /// Apple'in 29,99 $ icin hesapladigi karsilik ₺1.499,99 idi. Boyle bir
  /// ulkede cikista "sana ozel bir fiyatimiz var" demek, DAHA PAHALI bir
  /// urunu indirim diye sunmak olurdu.
  ///
  /// Bu yuzden karar fiyatin kendisine birakiliyor: ayni para biriminde
  /// standart yillik fiyatin altinda degilse teklif yok sayiliyor ve
  /// ekran indirim iddia etmiyor. Boylece 175 ulkenin fiyat tablosu ne
  /// olursa olsun ekran yanlis bir sey soyleyemiyor.
  AdaptyPaywallProduct? _ucuzsaTeklif(
      AdaptyPaywallProduct? teklif, AdaptyPaywallProduct? yillik) {
    if (teklif == null) return null;
    if (yillik == null) return teklif;
    if (teklif.price.currencyCode != yillik.price.currencyCode) return null;
    return teklif.price.amount < yillik.price.amount ? teklif : null;
  }

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
      return _t('Her yıl yenilenir', 'Renews yearly',
          'Verlängert sich jährlich', 'Se renueva cada año');
    }
    return _t('Her ay yenilenir', 'Renews monthly', 'Verlängert sich monatlich',
        'Se renueva cada mes');
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

  bool get _hareketsiz => Motion.reduced(context);

  /// PRO'nun ne actigi: UYGULAMANIN TAMAMI (kullanici karari, 6 Kas 2026).
  /// Tek tek ozellik (sertifika, rapor) satmiyoruz; satirlar "her sey"in
  /// parcalari. Her satir uygulamada gercekten var.
  List<ProSatir> get _satirlar => [
        ProSatir(_t('Tüm kurslar ve dersler', 'Every course and lesson',
            'Alle Kurse und Lektionen', 'Todos los cursos y lecciones')),
        ProSatir(_t('Tüm oyunlar ve atölyeler', 'Every game and workshop',
            'Alle Spiele und Werkstätten', 'Todos los juegos y talleres')),
        ProSatir(
          _t('Kullanım süresi', 'Time to play', 'Spielzeit', 'Tiempo de uso'),
          ucretsiz: _t('4 dk', '4 min', '4 Min.', '4 min'),
          pro: _t('Sınırsız', 'Unlimited', 'Unbegrenzt', 'Ilimitado'),
        ),
        ProSatir(_t('1000 jeton hediye', '1000 bonus coins',
            '1000 Bonus-Münzen', '1000 monedas de regalo')),
      ];

  @override
  Widget build(BuildContext context) {
    final ust = MediaQuery.paddingOf(context).top;
    return PopScope(
      // Kullanici vazgecip geri donerken bir kez daha yillik plani
      // gosteriyoruz. Ikinci kez geri basarsa ekran kapaniyor — kapanisi
      // engelleyen bir tuzak degil.
      // Zorunlu modda geri hareketi hicbir zaman ekrani kapatmiyor.
      canPop: !widget.zorunlu && _exitOfferShown,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_exitOfferShown) _showExitOffer();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      ProGokyuzu(
                        ustBosluk: ust + 44,
                        hareketsiz: _hareketsiz,
                        kurdele: proBuyukHarf(
                            _t('Sonraki seviyen', 'Your next level',
                                'Dein nächstes Level', 'Tu siguiente nivel'),
                            _lang),
                        ilkBaslik: _t(
                            'Asıl eğlence şimdi başlıyor.',
                            'The real fun starts now.',
                            'Jetzt geht der Spaß erst los.',
                            'La diversión empieza ahora.'),
                        baslik: _t(
                            'Her şey açık.\nPRO ile.',
                            'Everything unlocked.\nWith PRO.',
                            'Alles freigeschaltet.\nMit PRO.',
                            'Todo desbloqueado.\nCon PRO.'),
                        altBaslik: widget.zorunlu
                            ? _t(
                                'Tanışma süren doldu. Kaldığın yerden devam et.',
                                'Your free preview is over. Pick up where you left off.',
                                'Deine Vorschau ist vorbei. Mach weiter, wo du warst.',
                                'Tu vista previa terminó. Sigue donde lo dejaste.')
                            : _t(
                                'Tüm uygulama, tek üyelik.',
                                'The whole app, one membership.',
                                'Die ganze App, eine Mitgliedschaft.',
                                'Toda la app, una suscripción.'),
                        maskot: const Mascot(
                          size: 104,
                          mood: MascotMood.cheering,
                          showShadow: false,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
                        child: ProKarsilastirma(
                          satirlar: _satirlar,
                          hareketsiz: _hareketsiz,
                          ucretsizEtiket: proBuyukHarf(
                              _t('Ücretsiz', 'Free', 'Gratis', 'Gratis'),
                              _lang),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                        child: _loading
                            ? const SizedBox(
                                key: ValueKey('paywall-plans'),
                                height: 76,
                                child: Center(
                                  child: CircularProgressIndicator(
                                      color: ProRenk.proMavi),
                                ),
                              )
                            : _buildPlans(),
                      ),
                    ],
                  ),
                  Positioned(
                    top: ust,
                    left: 0,
                    right: 0,
                    child: _buildTopBar(),
                  ),
                ],
              ),
            ),
            _buildStickyCta(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 8, 0),
      child: Row(
        children: [
          // Zorunlu modda cikis teklifi bir kez gosterildikten sonra kapat
          // tusu gizleniyor; ayni yer korunuyor ki "Geri yukle" kaymasin.
          if (widget.zorunlu && _exitOfferShown)
            const SizedBox(width: 48, height: 44)
          else
            IconButton(
              tooltip: _t('Kapat', 'Close', 'Schließen', 'Cerrar'),
              // 44x44 dokunma alani: kapat tusu her zaman gorunur ve rahat
              // basilabilir olmali, yoksa App Store bunu karanlik desen sayiyor.
              onPressed: _closeRequested,
              icon: Icon(Icons.close_rounded,
                  color: Colors.white.withValues(alpha: 0.9)),
            ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _purchasing ? null : _restore,
                child: Text(
                  _t('Geri yükle', 'Restore', 'Wiederherstellen', 'Restaurar'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _hairline),
      ),
      child: child,
    );
  }

  /// Plan bolumu: iki kart yan yana, yillik onceden secili.
  ///
  /// Anahtar bir SUS DEGIL: test bu noktanin sabit alt cubuktan ne kadar
  /// uzakta oldugunu olcuyor (bkz. test/paywall_fold_test.dart).
  Widget _buildPlans() {
    if (_products.isEmpty) {
      return KeyedSubtree(
        key: const ValueKey('paywall-plans'),
        child: _buildPlansUnavailable(),
      );
    }

    // Yillik solda (en degerli, secili), sonra aylik. Indirimli yillik
    // yalnizca cikis teklifinde.
    final sorted = [..._products]
      ..removeWhere(_isDiscountOffer)
      ..sort((a, b) => _planRank(b).compareTo(_planRank(a)));
    final saving = _savingPercent();

    return IntrinsicHeight(
      key: const ValueKey('paywall-plans'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < sorted.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            _buildPlanChip(sorted[i], saving),
          ],
        ],
      ),
    );
  }

  /// Tek plan karti. Tasarruf rozeti YALNIZCA gercek bir capa (aylik plan)
  /// varken ciziliyor; uydurma indirim yok.
  Widget _buildPlanChip(AdaptyPaywallProduct product, int? saving) {
    final isYearly = _isYearly(product);
    final isSelected = _selected?.vendorProductId == product.vendorProductId;
    final price = product.price.localizedString ??
        _formatPrice(product.price.amount, product.price.currencyCode);
    final showBadge = isYearly && saving != null;
    final ayda = _monthlyEquivalent(product);
    final t = Theme.of(context).textTheme;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selected = product);
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.fromLTRB(12, 12, 10, 10),
              decoration: BoxDecoration(
                color: isSelected ? ProRenk.proAcik : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? ProRenk.proMavi : _hairline,
                  width: isSelected ? 2 : 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _periodLabel(product),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.labelLarge?.copyWith(
                              color: ProRenk.lacivertYumusak,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? ProRenk.proMavi
                                : const Color(0xFFC9CCD4),
                            width: isSelected ? 5.5 : 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(price,
                        style: AppTheme.number(
                            fontSize: 19, color: ProRenk.lacivert)),
                  ),
                  Text(
                    isYearly
                        ? _t('Ayda $ayda', '$ayda / month', '$ayda / Monat',
                            '$ayda / mes')
                        : _t(
                            'Her ay', 'Every month', 'Jeden Monat', 'Cada mes'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.bodySmall?.copyWith(color: _inkSoft),
                  ),
                ],
              ),
            ),
            // Tasarruf rozeti kartin ust kenarinda.
            if (showBadge)
              PositionedDirectional(
                top: -10,
                start: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _isEn ? '-$saving%' : '%$saving',
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
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
            child: Text(_t(
                'Tekrar dene', 'Try again', 'Erneut versuchen', 'Reintentar')),
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
      label = _t('Ücretsiz Denemeyi Başlat', 'Start Free Trial',
          'Gratis testen', 'Empezar prueba gratis');
    } else {
      label =
          _t("Pro'ya geç", 'Upgrade to Pro', 'Zu Pro wechseln', 'Pásate a Pro');
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
              ProDugme(
                key: const ValueKey('pro-cta'),
                etiket: proBuyukHarf(label, _lang),
                yukleniyor: _purchasing,
                hareketsiz: _hareketsiz,
                onPressed: enabled ? _purchase : null,
              ),
              if (sub != null) ...[
                // Dugmenin 3B kenari ve golgesi icin yer.
                const SizedBox(height: 11),
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
          _android
              ? _t(
                  'Abonelik otomatik yenilenir. Dönem bitmeden en az 24 saat '
                      'önce iptal edilmezse yenilenir; ödeme Google Play '
                      'hesabından tahsil edilir.',
                  'The subscription renews automatically. Unless it is '
                      'cancelled at least 24 hours before the period ends, it '
                      'renews and your Google Play account is charged.',
                  'Das Abo verlängert sich automatisch. Wird es nicht '
                      'spätestens 24 Stunden vor Ablauf gekündigt, verlängert '
                      'es sich und dein Google-Play-Konto wird belastet.',
                  'La suscripción se renueva automáticamente. Si no se '
                      'cancela al menos 24 horas antes de que acabe el '
                      'periodo, se renueva y se cobra en tu cuenta de '
                      'Google Play.',
                )
              : _t(
                  'Abonelik otomatik yenilenir. Dönem bitmeden en az 24 saat '
                      'önce iptal edilmezse yenilenir; ödeme App Store '
                      'hesabından tahsil edilir.',
                  'The subscription renews automatically. Unless it is '
                      'cancelled at least 24 hours before the period ends, it '
                      'renews and your App Store account is charged.',
                  'Das Abo verlängert sich automatisch. Wird es nicht '
                      'spätestens 24 Stunden vor Ablauf gekündigt, verlängert '
                      'es sich und dein App-Store-Konto wird belastet.',
                  'La suscripción se renueva automáticamente. Si no se '
                      'cancela al menos 24 horas antes de que acabe el '
                      'periodo, se renueva y se cobra en tu cuenta de '
                      'App Store.',
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
            // Zorunlu modda uygulamanin geri kalanina ulasilamiyor; giris
            // yapma ve hesabi silme (App Store 5.1.1(v)) buradan aciliyor.
            if (widget.zorunlu) ...[
              Text('·', style: style),
              TextButton(
                style: _legalLinkStyle,
                onPressed: _hesabiAc,
                child: Text(_t('Hesap', 'Account', 'Konto', 'Cuenta'),
                    style: style),
              ),
            ],
          ],
        ),
      ],
    );
  }

  /// ODEMENIN KOSULLARI MAGAZAYA GORE DEGISIYOR.
  ///
  /// Bu ekran iki magazada birden aciliyor ve abonelik kosullari ayni
  /// degil: parayi iOS'ta Apple, Android'de Google tahsil ediyor.
  ///
  /// Eskiden ikisinde de Apple'in standart EULA'si acikiyor ve metin
  /// "odeme App Store hesabindan tahsil edilir" diyordu. Android'de
  /// bu YANLIS bir beyandi: Play'de Apple EULA'si gecersiz ve Google
  /// faturalandirma bilgisinin dogru olmasini sart kosuyor. Ayrica
  /// Play magaza aciklamasinda "Google Play hesabinizdan tahsil
  /// edilir" yaziyor; uygulama baska sey derse beyanlar celisiyor.
  ///
  /// Dallanma [defaultTargetPlatform] ile yapiliyor, `dart:io`
  /// uzerinden DEGIL: o kutuphane web'de patliyor ve widget
  /// testlerinde bu dal denenemez hale geliyor.
  static bool get _android => defaultTargetPlatform == TargetPlatform.android;

  /// Apple'in standart EULA'si — yalnizca iOS icin.
  static const String _appleTermsUrl =
      'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';

  /// Google Play Hizmet Sartlari — yalnizca Android icin.
  static const String _playTermsUrl =
      'https://play.google.com/about/play-terms/';

  static String get _termsUrl => _android ? _playTermsUrl : _appleTermsUrl;

  static const String _privacyUrl =
      'https://www.devkom.com.tr/deveducation-privacy.html';

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
