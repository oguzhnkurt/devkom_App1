import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../theme.dart';
import '../../../ui/motion.dart';
import 'step_widgets.dart' show lessonLang, lessonText;

/// Cocugun HTML/CSS yazip sonucunu aninda gordugu calisma tezgahi.
///
/// NEDEN VAR
///
/// Proje adimlari uzun sure "gereksinimler + Projeyi Tamamladim!"
/// ekranindan ibaretti: arada calisma alani yoktu, `validation` alani
/// hicbir yerden okunmuyordu, cocuk hicbir sey yapmadan XP aliyordu.
/// Uygulama ici editorun ilk asamasi burasi — ve bilerek en ucuz
/// olani: HTML ve CSS'i calistirmak icin yorumlayiciya gerek yok,
/// tarayicinin kendisi zaten calistiriyor.
///
/// GUVENLIK — hepsi `test/kod_tezgahi_test.dart` ile kilitli
///
///  * Sayfa `loadHtmlString` ile YERELDEN yukleniyor; hicbir adrese
///    gidilmiyor, ag istegi yok.
///  * `onNavigationRequest` her seyi engelliyor. Cocugun yazdigi bir
///    `<a href="...">` ya da bir form, uygulamanin disina cikaramaz —
///    ebeveyn kapisi gomulu bir sayfanin baglantilarini korumuyor
///    (bkz. test/embedded_webview_safety_test.dart).
///  * `JavaScriptMode.disabled`. HTML/CSS derslerinin JavaScript'e
///    ihtiyaci yok; kapali olmasi, cocugun ya da bir yerden
///    kopyaladigi metnin sayfada betik calistirmasini imkansiz
///    kiliyor.
///  * Icerik Guvenligi Politikasi `default-src 'none'`: yazilan HTML
///    uzaktan resim, yazi tipi ya da stil CEKEMEZ. Onizleme tamamen
///    cevrimdisi.
///  * `runJavaScript` kullanilmiyor.
///
/// KAYIT: cocugun yazdigi kod adim kimligiyle cihazda tutuluyor. Bir
/// dersten cikip donunce yazdigini kaybetmek, editorun hic olmamasindan
/// daha kotu olurdu.
class KodTezgahi extends StatefulWidget {
  const KodTezgahi({
    super.key,
    required this.adimId,
    required this.baslangicKodu,
    this.onDegisti,
  });

  /// Kaydin anahtari.
  final String adimId;

  /// Alan bos acilirsa konulacak iskelet.
  final String baslangicKodu;

  /// Kod her degistiginde cagriliyor (gereksinim kontrolu icin).
  final ValueChanged<String>? onDegisti;

  /// Kaydin SharedPreferences anahtari.
  static String anahtar(String adimId) => 'tezgah_$adimId';

  @override
  State<KodTezgahi> createState() => _KodTezgahiState();
}

/// Cocugun yazdigini tam ve KAPALI bir belgeye sarar.
///
/// Ayri bir islev olmasinin sebebi sinanabilir olmasi: guvenlik
/// basliklarinin varligi bir ekran goruntusuyle degil, bu dizeye
/// bakarak dogrulanabiliyor.
///
/// COCUK TAM BIR BELGE YAZARSA ne olur? HTML dersinde iskelet zaten
/// `<!DOCTYPE html><html><head>...` diye basliyor ve bu, bizim
/// belgemizin govdesine girmis oluyor. Sorun degil: tarayici ic ice
/// `html`/`head` etiketlerini yok sayip duzlestiriyor, `<style>`
/// govdede de calisiyor. Onemli olan, Icerik Guvenligi Politikasinin
/// DIS belgenin basliginda olmasi — cocugun yazdigi hicbir sey onu
/// gevsetemiyor.
String onizlemeBelgesi(String govde) {
  return '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="Content-Security-Policy"
      content="default-src 'none'; style-src 'unsafe-inline'; img-src data:; font-src data:">
<style>
  html, body { margin: 0; padding: 12px; font-family: -apple-system, system-ui, sans-serif; }
</style>
</head>
<body>
$govde
</body>
</html>
''';
}

class _KodTezgahiState extends State<KodTezgahi> {
  late final TextEditingController _kod;
  WebViewController? _web;
  bool _yuklendi = false;

  @override
  void initState() {
    super.initState();
    _kod = TextEditingController(text: widget.baslangicKodu);
    _kod.addListener(() => widget.onDegisti?.call(_kod.text));

    // WebViewController, platform gerceklemesi kayitli degilse (birim
    // testinde oldugu gibi) firlatiyor. Onizleme olmadan da tezgah
    // calismali: cocuk kodunu yazabilsin, yalnizca onizleme yerine bir
    // aciklama gorsun.
    try {
      _web = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.disabled)
        ..setBackgroundColor(Colors.white)
        ..setNavigationDelegate(
          NavigationDelegate(
            // HICBIR YERE GIDILMEZ. Sayfa yalnizca loadHtmlString ile
            // geliyor; her gezinme istegi cocugun yazdigi bir baglanti
            // ya da form demek.
            onNavigationRequest: (_) => NavigationDecision.prevent,
          ),
        );
    } catch (_) {
      _web = null;
    }

    _yukle();
  }

  Future<void> _yukle() async {
    final kayit = await SharedPreferences.getInstance();
    final kayitli = kayit.getString(KodTezgahi.anahtar(widget.adimId));
    if (!mounted) return;
    setState(() {
      if (kayitli != null && kayitli.trim().isNotEmpty) _kod.text = kayitli;
      _yuklendi = true;
    });
    _calistir();
  }

  Future<void> _calistir() async {
    FocusScope.of(context).unfocus();
    await _web?.loadHtmlString(onizlemeBelgesi(_kod.text));
    final kayit = await SharedPreferences.getInstance();
    await kayit.setString(KodTezgahi.anahtar(widget.adimId), _kod.text);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _kod.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    if (!_yuklendi) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _baslik(lessonText(lang, 'Kodun', 'Your code', 'Dein Code', 'Tu código'),
            Icons.code_rounded),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: TextField(
            controller: _kod,
            maxLines: null,
            minLines: 6,
            keyboardType: TextInputType.multiline,
            // Klavyenin buyuk harfe zorlamasi ve otomatik duzeltmesi
            // kod yazarken dusman: <div> yazan cocuga <Div> oneriyor.
            textCapitalization: TextCapitalization.none,
            autocorrect: false,
            enableSuggestions: false,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13.5,
              height: 1.45,
              color: Color(0xFFD4D4D4),
            ),
            cursorColor: Colors.white,
            // `filled: false` SART. Uygulamanin InputDecorationTheme'i
            // butun metin alanlarini BEYAZ dolduruyor; koyu kod kutusu
            // o beyazin altinda kaliyor ve acik gri kod yazisi beyaz
            // zeminde neredeyse gorunmez oluyordu. Ekranda kutu "beyaz
            // icli, siyah cerceveli" duruyordu — cerceve sanilan sey
            // aslinda kutunun gorunen tek parcasiydi.
            decoration: const InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        const SizedBox(height: 10),
        // ikinci satir: sifirla
        // Sabit 44 piksel yukseklik dugmenin yazisini ALTTAN KESIYORDU;
        // ekranda "Calistir" yarim gorunuyordu. Yuksekligi dugmenin
        // kendisi belirlesin, taban olarak 48 verelim (kucuk cocuk icin
        // onerilen dokunma hedefi).
        FilledButton.icon(
          onPressed: _calistir,
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(lessonText(
              lang, 'Çalıştır', 'Run', 'Ausführen', 'Ejecutar')),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),

        // SIFIRLA.
        //
        // Kendi kodunu silip kaybolan bir cocugun geri donus yolu
        // olmaliydi; yoktu. Kayitli kod baslangic kodunun her zaman
        // onune gectigi icin, iskelet sonradan duzeltilse bile eski
        // kullanici onu hic gormuyordu — bu dugme o kapiyi da aciyor.
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              _kod.text = widget.baslangicKodu;
              _calistir();
            },
            icon: const Icon(Icons.restart_alt_rounded, size: 18),
            label: Text(lessonText(
                lang, 'Baştan başla', 'Start over', 'Neu anfangen',
                'Empezar de nuevo')),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.mediumGray,
            ),
          ),
        ),
        const SizedBox(height: 6),
        _baslik(
            lessonText(lang, 'Sonuç', 'Result', 'Ergebnis', 'Resultado'),
            Icons.visibility_rounded),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: Motion.short4,
          height: 260,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDDE1E6)),
          ),
          clipBehavior: Clip.antiAlias,
          child: _web == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      lessonText(
                          lang,
                          'Önizleme bu ekranda açılamadı.',
                          'The preview could not open here.',
                          'Die Vorschau konnte hier nicht geöffnet werden.',
                          'La vista previa no se pudo abrir aquí.'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.mediumGray),
                    ),
                  ),
                )
              : WebViewWidget(controller: _web!),
        ),
      ],
    );
  }

  Widget _baslik(String metin, IconData ikon) => Row(
        children: [
          Icon(ikon, size: 18, color: AppTheme.mediumGray),
          const SizedBox(width: 8),
          Text(
            metin,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontWeight: FontWeight.w800,
              color: AppTheme.darkGray,
            ),
          ),
        ],
      );
}
