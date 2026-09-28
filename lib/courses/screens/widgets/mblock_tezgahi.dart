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
///  * `onNavigationRequest` her gezinmeyi engelliyor. Sayfanin icinde
///    bir baglanti olussa bile cocuk uygulamanin disina cikamaz —
///    ebeveyn kapisi gomulu bir sayfanin baglantilarini korumuyor.
///  * Sayfanin Icerik Guvenligi Politikasi `default-src 'none'`:
///    uzaktan betik, yazi tipi, resim ya da baglanti CEKILEMEZ.
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

  @override
  State<MBlockTezgahi> createState() => MBlockTezgahiState();
}

class MBlockTezgahiState extends State<MBlockTezgahi> {
  WebViewController? _web;

  /// Sayfa `hazir` dedi mi.
  bool _hazir = false;

  /// Kurulum sirasinda bir sey patlarsa cocuga ne yazacagiz.
  String? _hata;

  @override
  void initState() {
    super.initState();
    _kur();
  }

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
            // HICBIR YERE GIDILMEZ.
            onNavigationRequest: (_) => NavigationDecision.prevent,
            onPageFinished: (_) => _sayfaHazir(),
            onWebResourceError: (e) {
              // Ses dosyalari kasten pakete alinmadi; onlarin hatasi
              // tezgahi bozmuyor.
              if (e.url != null && e.url!.contains('/media/')) return;
              if (mounted) setState(() => _hata = e.description);
            },
          ),
        );
      _web = c;
      c.loadFlutterAsset(MBlockTezgahi.sayfa);
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
    await c.runJavaScript(
      'MBlockTezgah.kur(${jsonEncode(kurulumJson(widget.ayar, dil))})',
    );
  }

  void _mesaj(JavaScriptMessage m) {
    final metin = m.message;
    if (metin.contains('"tur":"hazir"')) {
      if (mounted) setState(() => _hazir = true);
      return;
    }
    if (metin.contains('"tur":"hata"')) {
      if (mounted) setState(() => _hata = metin);
      return;
    }
    final yiginlar = MBlockBlok.mesajdanYiginlar(metin);
    if (yiginlar.isEmpty && !metin.contains('"tur":"durum"')) return;
    widget.onDurum(yiginlar);
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
                    child: _bilgi(
                      lessonText(
                        lang,
                        'Bloklar yüklenemedi.',
                        'The blocks could not load.',
                        'Die Blöcke konnten nicht geladen werden.',
                        'No se pudieron cargar los bloques.',
                      ),
                      Icons.error_outline_rounded,
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
