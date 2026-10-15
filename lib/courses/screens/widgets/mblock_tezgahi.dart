import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../theme.dart';
import '../../sahne/mblock_yigin_cizimi.dart';
import '../../yurutme/mblock_cozum.dart';
import 'step_widgets.dart' show lessonLang, lessonLangRead, lessonText;
import 'tezgah_havuzu.dart';

/// mBlock tezgahi — gercek surukle-birak blok editoru.
///
/// NEDEN WEBVIEW
/// -------------
/// Bloklar scratch-blocks ile ciziliyor; mBlock'un ve Scratch'in kendi
/// motoru. Flutter'da yeniden yazmak, Blockly'nin on yilda cozdugu isi
/// (yapisma, C kutusuna girme, golge bloklar, surukleme geri bildirimi)
/// bastan yazmak olurdu ve sonuc mBlock'a "benzer" olurdu, ayni degil.
///
/// GUVENLIK — test/embedded_webview_safety_test.dart ile kilitli
///
///  * Sayfa uygulamanin KENDI paketinden geliyor (`loadFlutterAsset`),
///    hicbir adrese cikilmiyor.
///  * `onNavigationRequest` yalnizca KENDI tezgah sayfamiza izin
///    veriyor, baska her gezinmeyi engelliyor. Sayfanin icinde bir
///    baglanti olussa bile cocuk uygulamanin disina cikamaz —
///    ebeveyn kapisi gomulu bir sayfanin baglantilarini korumuyor.
///  * Sayfanin Icerik Guvenligi Politikasi sema tabanli ve hicbir
///    yerinde http/https yok; `connect-src 'none'` ag isteklerini
///    tamamen kapatiyor. Yani uzaktan hicbir sey CEKILEMEZ.
///  * `runJavaScript` yalnizca KENDI sayfamizi kurmak icin kullaniliyor
///    (`MBlockTezgah.kur(...)`). Yasak ucuncu tarafin sayfasina
///    mudahale etmekle ilgiliydi; burada uzak bir sayfa yok.
class MBlockTezgahi extends StatefulWidget {
  const MBlockTezgahi({
    super.key,
    required this.ayar,
    required this.onDurum,
    this.yukseklik,
    this.onHata,
    this.onizleme = const [],
  });

  /// TEST/ONIZLEME: true iken WebView hic kurulmuyor; tezgahin yerinde
  /// [onizleme] programi salt okunur ciziliyor. Widget testleri ve ekran
  /// goruntusu araci tezgahi boyle besliyor (bkz. MBlockBlokAdimiState.
  /// durumVer). Uygulamada hep false.
  @visibleForTesting
  static bool webviewsiz = false;

  /// [webviewsiz] iken cizilen program.
  final List<List<MBlockBlok>> onizleme;

  final MBlockTezgahAyari ayar;

  /// Tahtadaki program her degistiginde cagriliyor.
  final ValueChanged<List<List<MBlockBlok>>> onDurum;

  /// Verilmezse ekran yuksekligine gore hesaplaniyor.
  final double? yukseklik;

  /// Tezgah acilamadi: WebView kurulamadi, sayfa hata bildirdi ya da
  /// sabir suresi doldu. Ders adimi bunu duyunca yedek tezgaha
  /// (dokunarak dizme) geciyor; cocuk bekleyen bir carkla kalmiyor.
  final VoidCallback? onHata;

  /// Blok olcegi — ekran GENISLIGINE gore.
  ///
  /// Kucuk ekranda tek bir olcek iki sekilde de yaniliyor: buyuk
  /// olcekte arac kutusu calisma alanini yiyor, cok kucukte bloklar
  /// cocuk parmagina gore ufaliyor. Aradaki denge genislige gore
  /// kuruluyor. Ayri bir islev olmasinin sebebi sinanabilir olmasi.
  static double olcekIcin(double genislik) {
    if (genislik < 360) return 0.55; // iPhone SE ve benzeri
    if (genislik < 400) return 0.62;
    return 0.68;
  }

  /// Tezgah yuksekligi — ekran YUKSEKLIGINE gore.
  ///
  /// Sabit 420 piksel kucuk telefonda ekranin neredeyse tamamini
  /// kapliyor, hedef ve dugmeler disarida kaliyordu; buyuk telefonda
  /// ise bosuna kucuk duruyordu.
  static double yukseklikIcin(double ekranYuksekligi) =>
      (ekranYuksekligi * 0.46).clamp(300.0, 520.0);

  /// Sayfanin paket icindeki yolu.
  static const String sayfa = 'assets/mblock/index.html';

  /// Flutter'dan sayfaya gonderilen ayar.
  ///
  /// Ayri bir islev olmasinin sebebi sinanabilir olmasi: gonderilen
  /// JSON'un dogrulugu bir ekran goruntusuyle degil bu dizeye bakarak
  /// denetlenebiliyor.
  static String kurulumJson(MBlockTezgahAyari ayar, String dil,
          {double olcek = 0.68}) =>
      jsonEncode({
        'dil': dil,
        'bloklar': ayar.bloklar,
        'baslangic': ayar.baslangicXmlFor(dil),
        'saltOkunur': false,
        'olcek': olcek,
      });

  @override
  State<MBlockTezgahi> createState() => MBlockTezgahiState();
}

/// Ders boyunca TEK WebView: sayfa (ve 2,1 MB'lik scratch-blocks) bir
/// kez yukleniyor; her blok kurma adimi ayni sayfaya yalnizca yeni ayari
/// gonderiyor (`MBlockTezgah.kur`). Bkz. [TezgahHavuzu].
class MBlockWebHavuzu {
  MBlockWebHavuzu._();

  static final TezgahHavuzu<WebViewController> havuz =
      TezgahHavuzu<WebViewController>(_uret);

  /// Su an denetciyi kullanan tezgah: sayfanin mesajlari ona gidiyor.
  static MBlockTezgahiState? aktif;

  /// Ders acilisinda (tanitim adimi) sayfayi onceden yukler: ilk blok
  /// kurma adimina gelindiginde tezgah hazir.
  static void isit() {
    if (MBlockTezgahi.webviewsiz) return;
    try {
      havuz.isit();
    } catch (_) {
      // Platform gerceklemesi yok (birim testi): isitma yok, zarar da yok.
    }
  }

  /// Dersten cikista WebView'i birakir (bellek). Kullanan varsa dokunmaz.
  static void serbestBirak() {
    if (havuz.bos) havuz.sifirla();
  }

  static WebViewController _uret() {
    final c = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFF9F9F9))
      ..addJavaScriptChannel('TezgahKanali',
          onMessageReceived: (m) => aktif?._mesaj(m))
      ..setNavigationDelegate(
        NavigationDelegate(
          // SAYFANIN KENDI YUKLENMESI DE BIR GEZINME ISTEGIDIR.
          //
          // Burasi once kosulsuz `prevent` donuyordu ve tezgah iOS'ta
          // HIC acilmadi: `loadFlutterAsset` bir file:// gezinmesi
          // baslatiyor, delege onu da engelliyordu.
          //
          // Kural: yalnizca KENDI paketimizdeki tezgah sayfasi.
          // Baska her sey — cocugun ya da bir hatanin uretebilecegi
          // her baglanti — engelleniyor.
          onNavigationRequest: (istek) {
            final adres = istek.url;
            final bizim = adres.contains('assets/mblock/') ||
                adres.startsWith('about:');
            if (!bizim) {
              debugPrint('⛔ mBlock tezgahi gezinmeyi engelledi: $adres');
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageFinished: (url) {
            debugPrint('🔎 mBlock tezgahi sayfasi yuklendi: $url');
            havuz.sayfaYuklendi = true;
            aktif?._sayfaHazir();
          },
          onWebResourceError: (e) {
            // Ses dosyalari kasten pakete alinmadi; onlarin hatasi
            // tezgahi bozmuyor.
            if (e.url != null && e.url!.contains('/media/')) return;
            debugPrint('⚠️ mBlock tezgahi kaynak hatasi: '
                '${e.url} — ${e.description}');
            aktif?._hataVer(e.description);
          },
        ),
      );
    c.loadFlutterAsset(MBlockTezgahi.sayfa);
    return c;
  }
}

class MBlockTezgahiState extends State<MBlockTezgahi> {
  WebViewController? _web;

  /// Sayfa `hazir` dedi mi.
  bool _hazir = false;

  /// Kurulum sirasinda bir sey patlarsa cocuga ne yazacagiz.
  String? _hata;

  /// WebView bu karede cizilebilir mi? Denetci baska bir adimdan
  /// devralindiysa bir kare bekleniyor (eski gorunum agactan ciksin).
  bool _gosterilebilir = false;

  /// Denetci baska bir tezgaha gecti (bu adim cikis animasyonunda).
  bool _devredildi = false;

  /// Sabir sayaci.
  ///
  /// NEDEN: sayfa acilmazsa ekranda donen bir cark kaliyordu ve
  /// sonsuza kadar donuyordu. Bir cocuk icin bu "bozuk" degil
  /// "yukleniyor" demek; bekler, bekler, dersi birakir. En olasi
  /// sebep betiklerin hic calismamasi (Icerik Guvenligi Politikasi ya
  /// da paketin eksik gitmesi) ve o durumda sayfadan HICBIR mesaj
  /// gelmiyor — yani hatayi ancak sure ile anlayabiliyoruz.
  Timer? _sabir;

  /// 10 saniye AZDI. Hata ayiklama derlemesinde 2,1 MB'lik betigin ilk
  /// ayrıstirilmasi soguk baslangicta bunu asabiliyor; ayni yapi ikinci
  /// acilista saniyeler icinde geliyordu. "Az once vardi simdi yok"
  /// sikayetinin sebebi buydu.
  static const Duration _sabirSuresi = Duration(seconds: 25);

  @override
  void initState() {
    super.initState();
    if (MBlockTezgahi.webviewsiz) {
      _hazir = true;
      return;
    }
    _kur();
  }

  /// Hata bir kez bildiriliyor (ust uste gelen kaynak hatalari icin
  /// ders adimi birden cok kez yedege gecmesin).
  bool _hataBildirildi = false;

  void _hataVer(String neden) {
    if (!mounted) return;
    setState(() => _hata = neden);
    _bildir();
  }

  void _bildir() {
    if (_hataBildirildi || widget.onHata == null) return;
    _hataBildirildi = true;
    // Kurulum initState icinden de patlayabiliyor: bildirim build
    // bittikten sonra.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onHata?.call();
    });
  }

  /// Havuzdaki denetciyi devralir; sayfa zaten yukluyse hemen kurar.
  void _kur() {
    // WebViewController, platform gerceklemesi kayitli degilse (birim
    // testinde oldugu gibi) firlatiyor. Tezgah acilmasa bile ders
    // devam edebilmeli.
    try {
      final havuz = MBlockWebHavuzu.havuz;
      final c = havuz.al(this, birakildi: _devret);
      MBlockWebHavuzu.aktif = this;
      _web = c;
      _devredildi = false;
      _gosterilebilir = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _devredildi) return;
        setState(() => _gosterilebilir = true);
        // Ayni sayfa onceki adimdan yuklu: yalnizca yeni ayar.
        if (havuz.sayfaYuklendi) _sayfaHazir();
      });
      _sabir?.cancel();
      _sabir = Timer(_sabirSuresi, () {
        if (!mounted || _hazir) return;
        // Konsola yazdiriyoruz: cocuga teknik metin gostermiyoruz ama
        // `flutter run` ciktisinda sebebi aranabilir olmali.
        debugPrint('⚠️ mBlock tezgahi ${_sabirSuresi.inSeconds} sn icinde '
            'hazir demedi. Yukaridaki "tezgahi durumu" satirina bak: '
            'scratchBlocks/katalog/tezgah "undefined" ise betikler '
            'calismamis, "object" ise sayfa yavas acilmis demektir.');
        _hataVer('zaman asimi');
      });
    } catch (_) {
      _web = null;
      _bildir();
    }
  }

  /// Denetci baska bir adima gecti: WebView'i agactan cikar.
  void _devret() {
    _sabir?.cancel();
    if (identical(MBlockWebHavuzu.aktif, this)) MBlockWebHavuzu.aktif = null;
    if (!mounted) return;
    setState(() {
      _devredildi = true;
      _gosterilebilir = false;
    });
  }

  Future<void> _sayfaHazir() async {
    final c = _web;
    // WebView henuz ekranda degilse (devralinan denetci bir kare
    // bekliyor) kurulum o karede yapiliyor: gorunmeyen sayfanin
    // genisligi 0 ve tezgah dar ekran sanip yanlis olcekleniyordu.
    if (c == null || _devredildi || !_gosterilebilir) return;
    // lessonLang() `context.watch` kullaniyor ve yalnizca build
    // icinde cagrilabilir; burasi sayfa yuklenince calisan bir geri
    // cagri. lessonLangRead() ayni degeri abone olmadan veriyor.
    final dil = mounted ? lessonLangRead(context) : 'tr';
    final olcek = mounted
        ? MBlockTezgahi.olcekIcin(MediaQuery.sizeOf(context).width)
        : 0.68;
    // Sayfaya AYARI veriyoruz; sayfanin icerigine mudahale etmiyoruz.
    // TANILAMA: sayfanin gercekten yuklenip yuklenmedigini ve
    // betiklerin calisip calismadigini ayirt etmenin tek yolu bu.
    // Tezgah acilmadiginda "sayfa mi gelmedi, betik mi engellendi"
    // sorusunun cevabini tahminle degil bu satirla veriyoruz.
    try {
      final tanilama = await c.runJavaScriptReturningResult(
        'JSON.stringify({'
        'baslik: document.title,'
        'betikSayisi: document.scripts.length,'
        'scratchBlocks: typeof window.ScratchBlocks,'
        'katalog: typeof window.MBlockKatalog,'
        'tezgah: typeof window.MBlockTezgah'
        '})',
      );
      debugPrint('🔎 mBlock tezgahi durumu: $tanilama');
    } catch (e) {
      debugPrint('⚠️ mBlock tezgahi tanilama calismadi: $e');
    }

    try {
      await c.runJavaScript(
        'MBlockTezgah.kur('
        '${jsonEncode(MBlockTezgahi.kurulumJson(widget.ayar, dil, olcek: olcek))})',
      );
    } catch (e) {
      // `MBlockTezgah` tanimsizsa betikler hic yuklenmemis demektir.
      debugPrint('⚠️ mBlock tezgahi kurulamadi: $e');
      _hataVer('$e');
    }
  }

  void _mesaj(JavaScriptMessage m) {
    final metin = m.message;
    if (metin.contains('"tur":"hazir"')) {
      _sabir?.cancel();
      // HATAYI DA TEMIZLIYORUZ. Sabir sayaci dolduktan SONRA sayfa
      // hazir derse ekran "Bloklar yuklenemedi" diye kalakaliyordu —
      // tezgah calisir haldeyken. Sayaci gecikme olcusu olarak
      // kullaniyoruz, kesin hukum olarak degil.
      if (mounted) {
        setState(() {
          _hazir = true;
          _hata = null;
        });
      }
      return;
    }
    if (metin.contains('"tur":"hata"')) {
      debugPrint('⚠️ mBlock tezgahi hata bildirdi: $metin');
      _hataVer(metin);
      return;
    }
    // Onceki adimin tahtasindan gec gelen durum mesaji bu adima
    // karismasin: bu adimin kurulumu "hazir" deyince dinliyoruz.
    if (!_hazir) return;
    final yiginlar = MBlockBlok.mesajdanYiginlar(metin);
    if (yiginlar.isEmpty && !metin.contains('"tur":"durum"')) return;
    widget.onDurum(yiginlar);
  }

  @override
  void dispose() {
    _sabir?.cancel();
    MBlockWebHavuzu.havuz.birak(this);
    if (identical(MBlockWebHavuzu.aktif, this)) MBlockWebHavuzu.aktif = null;
    super.dispose();
  }

  /// Sayfayi bastan yukler.
  ///
  /// Hata durumu bir cikmaz sokak olmamali: cocuk (ya da biz) tezgahi
  /// yeniden deneyebilmeli, dersten cikip girmek zorunda kalmamali.
  void yenidenDene() {
    setState(() {
      _hata = null;
      _hazir = false;
    });
    _sabir?.cancel();
    _web = null;
    _hataBildirildi = false;
    // Bozuk sayfa havuzda kalmasin: yeni denetci, sayfa bastan.
    MBlockWebHavuzu.havuz.sifirla();
    _kur();
  }

  /// Tahtayi bosaltir.
  Future<void> temizle() async {
    await _web?.runJavaScript('MBlockTezgah.temizle()');
  }

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    final c = _web;

    if (MBlockTezgahi.webviewsiz) {
      return Container(
        key: const ValueKey('mblock_tezgah_onizleme'),
        height: widget.yukseklik ??
            MBlockTezgahi.yukseklikIcin(MediaQuery.sizeOf(context).height),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final y in widget.onizleme) ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: MBlockYiginCizimi(bloklar: y, lang: lang, olcek: 0.92),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      );
    }

    return Container(
      height: widget.yukseklik ??
          MBlockTezgahi.yukseklikIcin(MediaQuery.sizeOf(context).height),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: c == null
          ? _bilgi(
              lessonText(
                lang,
                'Blok tezgahı bu cihazda açılamadı.',
                'The block workbench could not open on this device.',
                'Die Blockwerkbank konnte auf diesem Gerät nicht öffnen.',
                'El taller de bloques no pudo abrirse en este dispositivo.',
              ),
              Icons.extension_off_rounded,
            )
          : Stack(
              children: [
                if (_gosterilebilir && !_devredildi)
                  WebViewWidget(controller: c),
                if (!_hazir && _hata == null)
                  const ColoredBox(
                    color: Color(0xFFF9F9F9),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (_hata != null)
                  ColoredBox(
                    color: const Color(0xFFF9F9F9),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _bilgi(
                            lessonText(
                              lang,
                              'Bloklar yüklenemedi.',
                              'The blocks could not load.',
                              'Die Blöcke konnten nicht geladen werden.',
                              'No se pudieron cargar los bloques.',
                            ),
                            Icons.error_outline_rounded,
                          ),
                          FilledButton.icon(
                            onPressed: yenidenDene,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: Text(
                              lessonText(lang, 'Yeniden dene', 'Try again',
                                  'Nochmal versuchen', 'Reintentar'),
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _bilgi(String metin, IconData simge) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(simge, size: 34, color: Colors.grey.shade500),
              const SizedBox(height: 10),
              Text(
                metin,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      );
}
