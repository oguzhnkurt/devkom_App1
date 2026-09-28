import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../theme.dart';
import '../../yurutme/mblock_cozum.dart';
import 'step_widgets.dart' show lessonLang, lessonLangRead, lessonText;

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
    this.yukseklik = 420,
  });

  final MBlockTezgahAyari ayar;

  /// Tahtadaki program her degistiginde cagriliyor.
  final ValueChanged<List<List<MBlockBlok>>> onDurum;

  final double yukseklik;

  /// Sayfanin paket icindeki yolu.
  static const String sayfa = 'assets/mblock/index.html';

  /// Flutter'dan sayfaya gonderilen ayar.
  ///
  /// Ayri bir islev olmasinin sebebi sinanabilir olmasi: gonderilen
  /// JSON'un dogrulugu bir ekran goruntusuyle degil bu dizeye bakarak
  /// denetlenebiliyor.
  static String kurulumJson(MBlockTezgahAyari ayar, String dil) => jsonEncode({
        'dil': dil,
        'bloklar': ayar.bloklar,
        'baslangic': ayar.baslangicXml,
        'saltOkunur': false,
      });

  @override
  State<MBlockTezgahi> createState() => MBlockTezgahiState();
}

class MBlockTezgahiState extends State<MBlockTezgahi> {
  WebViewController? _web;

  /// Sayfa `hazir` dedi mi.
  bool _hazir = false;

  /// Kurulum sirasinda bir sey patlarsa cocuga ne yazacagiz.
  String? _hata;

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
    _kur();
  }

  void _kur() {
    // WebViewController, platform gerceklemesi kayitli degilse (birim
    // testinde oldugu gibi) firlatiyor. Tezgah acilmasa bile ders
    // devam edebilmeli.
    try {
      final c = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFFF9F9F9))
        ..addJavaScriptChannel('TezgahKanali', onMessageReceived: _mesaj)
        ..setNavigationDelegate(
          NavigationDelegate(
            // SAYFANIN KENDI YUKLENMESI DE BIR GEZINME ISTEGIDIR.
            //
            // Burasi once kosulsuz `prevent` donuyordu ve tezgah iOS'ta
            // HIC acilmadi: `loadFlutterAsset` bir file:// gezinmesi
            // baslatiyor, delege onu da engelliyordu. Sayfa hic
            // yuklenmedigi icin ne bir hata dusuyordu ne de sayfadan
            // mesaj geliyordu — ekranda yalnizca sabir sayaci
            // konusuyordu. (kod_tezgahi.dart'ta ayni kalip sorunsuz,
            // cunku orada sayfa `loadHtmlString` ile geliyor ve bu bir
            // gezinme istegi uretmiyor.)
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
              _sayfaHazir();
            },
            onWebResourceError: (e) {
              // Ses dosyalari kasten pakete alinmadi; onlarin hatasi
              // tezgahi bozmuyor.
              if (e.url != null && e.url!.contains('/media/')) return;
              debugPrint('⚠️ mBlock tezgahi kaynak hatasi: '
                  '${e.url} — ${e.description}');
              if (mounted) setState(() => _hata = e.description);
            },
          ),
        );
      _web = c;
      c.loadFlutterAsset(MBlockTezgahi.sayfa);
      _sabir = Timer(_sabirSuresi, () {
        if (!mounted || _hazir) return;
        // Konsola yazdiriyoruz: cocuga teknik metin gostermiyoruz ama
        // `flutter run` ciktisinda sebebi aranabilir olmali.
        debugPrint('⚠️ mBlock tezgahi ${_sabirSuresi.inSeconds} sn icinde '
            'hazir demedi. Yukaridaki "tezgahi durumu" satirina bak: '
            'scratchBlocks/katalog/tezgah "undefined" ise betikler '
            'calismamis, "object" ise sayfa yavas acilmis demektir.');
        setState(() => _hata = 'zaman asimi');
      });
    } catch (_) {
      _web = null;
    }
  }

  Future<void> _sayfaHazir() async {
    final c = _web;
    if (c == null) return;
    // lessonLang() `context.watch` kullaniyor ve yalnizca build
    // icinde cagrilabilir; burasi sayfa yuklenince calisan bir geri
    // cagri. lessonLangRead() ayni degeri abone olmadan veriyor.
    final dil = mounted ? lessonLangRead(context) : 'tr';
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
        '${jsonEncode(MBlockTezgahi.kurulumJson(widget.ayar, dil))})',
      );
    } catch (e) {
      // `MBlockTezgah` tanimsizsa betikler hic yuklenmemis demektir.
      debugPrint('⚠️ mBlock tezgahi kurulamadi: $e');
      if (mounted) setState(() => _hata = '$e');
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
      if (mounted) setState(() => _hata = metin);
      return;
    }
    final yiginlar = MBlockBlok.mesajdanYiginlar(metin);
    if (yiginlar.isEmpty && !metin.contains('"tur":"durum"')) return;
    widget.onDurum(yiginlar);
  }

  @override
  void dispose() {
    _sabir?.cancel();
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

    return Container(
      height: widget.yukseklik,
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
