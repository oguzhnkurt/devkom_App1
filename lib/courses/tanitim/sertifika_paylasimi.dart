import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart' as izin;
import 'package:share_plus/share_plus.dart';

import '../../theme.dart';
import '../../widgets/mascot.dart';
import '../../widgets/parent_gate.dart';
import '../models/course_model.dart';
import 'kurs_kapanis_ekrani.dart' show KursSertifikasi;
import 'kurs_tanitimi.dart';

/// SERTIFIKAYI KAYDETME / PAYLASMA SECENEKLERI.
///
/// Dort secenek (+ genel paylasim): PDF olarak indir, Instagram'da paylas,
/// TikTok'ta paylas, galeriye kaydet.
///
/// COCUK GUVENLIGI: Bu bir cocuk uygulamasi (Play Aileler, Apple Kids
/// 1.3). Sertifikada cocugun ADI var; uygulamanin disina cikan her yol
/// (dosya, galeri, sosyal ag, paylasim menusu) [ParentGate]'in arkasinda.
/// Kapi gecilmezse hicbir sey yapilmiyor. Ek kayit/analitik YOK.
///
/// Instagram / TikTok: Android'de PNG dogrudan uygulamaya gonderiliyor
/// (MainActivity'deki kucuk kanal, ACTION_SEND + setPackage). iOS'ta
/// SDK'siz dogrudan bir yol yok: once galeriye kaydediliyor, sonra
/// paylasim menusu aciliyor ve "Instagram'i sec" ipucu gosteriliyor.
/// Facebook/TikTok SDK'si EKLENMEDI.
enum SertifikaIslemi { pdf, instagram, tiktok, galeri, paylas }

/// Paylasim gorselinin bicimi.
enum PaylasimBicimi {
  /// Instagram gonderisi, 4:5 — 1080 x 1350.
  instagram(Size(360, 450)),

  /// TikTok / hikaye, 9:16 — 1080 x 1920.
  tiktok(Size(360, 640));

  const PaylasimBicimi(this.mantiksal);

  /// Mantiksal boyut; [SertifikaCizici.oran] (3) ile piksel boyutu.
  final Size mantiksal;
  Size get piksel => mantiksal * SertifikaCizici.oran;
}

/// Sertifikayi cizmek icin gereken veri.
class SertifikaVerisi {
  const SertifikaVerisi({
    required this.course,
    required this.ad,
    required this.tarih,
    required this.dersSayisi,
    required this.lang,
  });

  final Course course;
  final String ad;
  final DateTime tarih;
  final int dersSayisi;
  final String lang;

  String _t(String tr, String en, String de, String es) =>
      tanitimMetni(lang, tr, en, de, es);

  KursSertifikasi sertifika({bool baski = false}) => KursSertifikasi(
        course: course,
        ad: ad,
        tarih: tarih,
        dersSayisi: dersSayisi,
        lang: lang,
        baski: baski,
      );

  String get paylasimMetni {
    final k = course.nameFor(lang);
    return _t(
        '$k kursunu bitirdim! · DevEducation',
        'I finished the $k course! · DevEducation',
        'Ich habe den Kurs $k geschafft! · DevEducation',
        '¡Terminé el curso de $k! · DevEducation');
  }

  /// `DevEducation_Sertifika_<kurs>_<ad>` — yalnizca ASCII.
  String dosyaAdi([String? ek]) {
    final parcalar = [
      'DevEducation',
      'Sertifika',
      asciiAd(course.nameFor('en')),
      asciiAd(ad),
      if (ek != null) ek,
    ].where((p) => p.isNotEmpty);
    return parcalar.join('_');
  }

  /// Turkce/Almanca/Ispanyolca harfleri ASCII'ye cevirir; geri kalan her
  /// seyi `_` yapar. Dosya adlari bazi paylasim hedeflerinde (e-posta,
  /// eski Android dosya yoneticileri) bozulmasin.
  static String asciiAd(String s) {
    const harita = {
      'ç': 'c',
      'Ç': 'C',
      'ğ': 'g',
      'Ğ': 'G',
      'ı': 'i',
      'İ': 'I',
      'ö': 'o',
      'Ö': 'O',
      'ş': 's',
      'Ş': 'S',
      'ü': 'u',
      'Ü': 'U',
      'ä': 'ae',
      'Ä': 'Ae',
      'ß': 'ss',
      'ñ': 'n',
      'Ñ': 'N',
      'á': 'a',
      'Á': 'A',
      'é': 'e',
      'É': 'E',
      'í': 'i',
      'Í': 'I',
      'ó': 'o',
      'Ó': 'O',
      'ú': 'u',
      'Ú': 'U',
      'â': 'a',
      'î': 'i',
      'û': 'u',
      'à': 'a',
      'è': 'e',
    };
    final b = StringBuffer();
    for (final r in s.runes) {
      final h = String.fromCharCode(r);
      b.write(harita[h] ?? h);
    }
    return b
        .toString()
        .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }
}

// ---------------------------------------------------------------------
// Ekran disinda cizim
// ---------------------------------------------------------------------

/// Widget'lari EKRANA KOYMADAN PNG'ye cizer (kendi boru hattiyla).
///
/// Ekrandaki sertifika telefon genisliginde ve golgeli; PDF ve paylasim
/// gorselleri ise sabit boyutta ve ekran boyundan bagimsiz olmali.
class SertifikaCizici {
  SertifikaCizici._();

  /// Paylasim gorsellerinin piksel orani: 360 x 450 -> 1080 x 1350.
  static const double oran = 3;

  /// A4 yatay (pt). PDF sayfasi ve PDF'e giden goruntu bu oranda.
  static const Size a4Yatay = Size(842, 595);

  /// [w]'yu [boyut] mantiksal boyutta, [pikselOrani] ile cizer.
  /// [rgba] true ise ham RGBA (PDF icin, PNG cozmeye gerek kalmasin).
  static Future<ui.Image> ciz(Widget w,
      {required Size boyut, double pikselOrani = oran}) async {
    final kutu = RenderRepaintBoundary();
    final gorunum = WidgetsBinding.instance.platformDispatcher.implicitView ??
        WidgetsBinding.instance.platformDispatcher.views.first;
    final renderView = RenderView(
      view: gorunum,
      child: RenderPositionedBox(alignment: Alignment.center, child: kutu),
      configuration: ViewConfiguration(
        logicalConstraints: BoxConstraints.tight(boyut),
        physicalConstraints: BoxConstraints.tight(boyut * pikselOrani),
        devicePixelRatio: pikselOrani,
      ),
    );
    final boru = PipelineOwner()..rootNode = renderView;
    renderView.prepareInitialFrame();
    final odak = FocusManager();
    final kurucu = BuildOwner(focusManager: odak);
    final kok = RenderObjectToWidgetAdapter<RenderBox>(
      container: kutu,
      child: MediaQuery(
        data: MediaQueryData(size: boyut, devicePixelRatio: pikselOrani),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: DefaultTextStyle(
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: Color(0xFF1F2430),
              decoration: TextDecoration.none,
            ),
            child: SizedBox.fromSize(size: boyut, child: w),
          ),
        ),
      ),
    ).attachToRenderTree(kurucu);
    try {
      kurucu.buildScope(kok);
      kurucu.finalizeTree();
      boru.flushLayout();
      boru.flushCompositingBits();
      boru.flushPaint();
      return await kutu.toImage(pixelRatio: pikselOrani);
    } finally {
      // Agaci sok: zamanlayici / dinleyici kalmasin.
      RenderObjectToWidgetAdapter<RenderBox>(container: kutu)
          .attachToRenderTree(kurucu, kok);
      kurucu.finalizeTree();
      odak.dispose();
    }
  }

  static Future<Uint8List> png(Widget w,
      {required Size boyut, double pikselOrani = oran}) async {
    final img = await ciz(w, boyut: boyut, pikselOrani: pikselOrani);
    try {
      final d = await img.toByteData(format: ui.ImageByteFormat.png);
      return d!.buffer.asUint8List();
    } finally {
      img.dispose();
    }
  }

  /// Devi gorselini cozer (paylasim gorseli icin). Bulunamazsa null.
  static Future<ui.Image?> deviGorseli() async {
    try {
      final veri = await rootBundle.load(Mascot.durgunGorsel);
      final codec = await ui.instantiateImageCodec(veri.buffer.asUint8List(),
          targetWidth: 360);
      return (await codec.getNextFrame()).image;
    } catch (_) {
      return null;
    }
  }

  /// Sertifikanin yuksek cozunurluklu PNG'si (galeri / genel paylasim).
  static Future<Uint8List> sertifikaPng(SertifikaVerisi v) =>
      png(v.sertifika(baski: true), boyut: a4Yatay, pikselOrani: 2);

  /// Instagram (4:5) ya da TikTok (9:16) paylasim gorseli.
  static Future<Uint8List> paylasimPng(
      SertifikaVerisi v, PaylasimBicimi b) async {
    final devi = await deviGorseli();
    try {
      return await png(
        SertifikaPaylasimGorseli(veri: v, bicim: b, devi: devi),
        boyut: b.mantiksal,
      );
    } finally {
      devi?.dispose();
    }
  }

  /// A4 yatay, tek sayfa, sertifika sayfanin tamami.
  static Future<Uint8List> pdf(SertifikaVerisi v) async {
    final img =
        await ciz(v.sertifika(baski: true), boyut: a4Yatay, pikselOrani: 3);
    final Uint8List rgba;
    try {
      final d = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
      rgba = d!.buffer.asUint8List();
    } finally {
      img.dispose();
    }
    // PDF 1.4: nesne akisi yok; eski goruntuleyiciler (okul yazicilari,
    // e-posta onizlemeleri) de aciyor.
    final belge = pw.Document(
      version: PdfVersion.pdf_1_4,
      title: v.dosyaAdi(),
      author: 'DevEducation',
      creator: 'DevEducation',
    );
    final resim =
        pw.RawImage(bytes: rgba, width: img.width, height: img.height);
    belge.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: pw.EdgeInsets.zero,
      build: (_) => pw.SizedBox.expand(
        child: pw.Image(resim, fit: pw.BoxFit.fill),
      ),
    ));
    return belge.save();
  }
}

/// Paylasim gorseli: marka gradyani ustunde ortada sertifika, ustte
/// DevEducation yazisi, Devi ve kisa bir cumle.
class SertifikaPaylasimGorseli extends StatelessWidget {
  const SertifikaPaylasimGorseli({
    super.key,
    required this.veri,
    required this.bicim,
    this.devi,
  });

  final SertifikaVerisi veri;
  final PaylasimBicimi bicim;

  /// Onceden cozulmus Devi gorseli (ekran disi cizimde Image.asset
  /// yuklenmeyi beklemiyor).
  final ui.Image? devi;

  static const marka1 = Color(0xFF5A34E8);
  static const marka2 = Color(0xFF00C4E0);

  @override
  Widget build(BuildContext context) {
    final uzun = bicim == PaylasimBicimi.tiktok;
    final lang = veri.lang;
    String t(String tr, String en, String de, String es) =>
        tanitimMetni(lang, tr, en, de, es);
    return Container(
      key: ValueKey('paylasim_${bicim.name}'),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [marka1, Color(0xFF7B4DF0), marka2],
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, uzun ? 56 : 26, 20, uzun ? 56 : 22),
      child: Column(
        children: [
          // Kelime isareti.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.code_rounded, size: 18, color: marka1),
              ),
              const SizedBox(width: 8),
              const Text(
                'DevEducation',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          // Orta: Devi, cumle ve sertifika. Sigmazsa (cok uzun ad, buyuk
          // yazi) butun olarak kuculuyor; tasma yok.
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: 320,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (devi != null)
                        SizedBox(
                          width: uzun ? 132 : 84,
                          height: uzun ? 132 : 84,
                          child: RawImage(image: devi, fit: BoxFit.contain),
                        ),
                      SizedBox(height: uzun ? 10 : 4),
                      Text(
                        t('Kursu bitirdim!', 'I finished the course!',
                            'Kurs geschafft!', '¡Terminé el curso!'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: uzun ? 30 : 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: uzun ? 34 : 14),
                      veri.sertifika(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: uzun ? 24 : 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              t(
                  'Kodlamayı oynayarak öğren',
                  'Learn to code by playing',
                  'Spielend programmieren lernen',
                  'Aprende a programar jugando'),
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Platform
// ---------------------------------------------------------------------

/// Platforma giden her sey tek yerde; testler sahtesini koyuyor.
abstract class SertifikaPlatformu {
  bool get android;
  Future<Directory> geciciDizin();
  Future<void> paylas(List<String> yollar, {String? metin, String? konu});
  Future<bool> galeriIzni();
  Future<void> galeriyeKaydet(Uint8List png, String ad);
  Future<void> ayarlariAc();

  /// Android: dosyayi verilen paketlerden YUKLU OLAN ILKINE gonderir.
  /// Hicbiri yuklu degilse false.
  Future<bool> uygulamayaGonder(String yol, List<String> paketler,
      {String? metin});
}

class VarsayilanSertifikaPlatformu implements SertifikaPlatformu {
  const VarsayilanSertifikaPlatformu();

  static const kanal = MethodChannel('com.devkom.app/sertifika');

  @override
  bool get android => defaultTargetPlatform == TargetPlatform.android;

  @override
  Future<Directory> geciciDizin() async {
    // Android'de cache/sertifika/ — FileProvider yolu bu
    // (res/xml/sertifika_dosya_yollari.xml).
    final d = Directory('${(await getTemporaryDirectory()).path}/sertifika');
    await d.create(recursive: true);
    return d;
  }

  @override
  Future<void> paylas(List<String> yollar, {String? metin, String? konu}) =>
      Share.shareXFiles([for (final y in yollar) XFile(y)],
          text: metin, subject: konu);

  @override
  Future<bool> galeriIzni() async {
    if (await Gal.hasAccess()) return true;
    return Gal.requestAccess();
  }

  @override
  Future<void> galeriyeKaydet(Uint8List png, String ad) =>
      Gal.putImageBytes(png, name: ad);

  @override
  Future<void> ayarlariAc() async {
    await izin.openAppSettings();
  }

  @override
  Future<bool> uygulamayaGonder(String yol, List<String> paketler,
      {String? metin}) async {
    if (!android) return false;
    try {
      final ok = await kanal.invokeMethod<bool>('uygulamayaGonder', {
        'yol': yol,
        'paketler': paketler,
        'tur': 'image/png',
        if (metin != null) 'metin': metin,
      });
      return ok ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}

/// Instagram ve TikTok paket adlari (Android). TikTok'un iki paketi var:
/// cogu ulkede musically, bazi Asya ulkelerinde trill.
const instagramPaketleri = ['com.instagram.android'];
const tiktokPaketleri = [
  'com.zhiliaoapp.musically',
  'com.ss.android.ugc.trill'
];

// ---------------------------------------------------------------------
// Akis
// ---------------------------------------------------------------------

class SertifikaPaylasimi {
  SertifikaPaylasimi._();

  /// Testler sahte platform koyuyor.
  static SertifikaPlatformu platform = const VarsayilanSertifikaPlatformu();

  static String _t(String lang, String tr, String en, String de, String es) =>
      tanitimMetni(lang, tr, en, de, es);

  /// Secenekleri acar, secileni ebeveyn kapisindan gecirip uygular.
  static Future<void> secenekleriAc(
      BuildContext context, SertifikaVerisi veri) async {
    final secim = await showModalBottomSheet<SertifikaIslemi>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SertifikaSecenekleri(lang: veri.lang),
    );
    if (secim == null || !context.mounted) return;
    await uygula(context, veri, secim);
  }

  static String kapiNedeni(String lang, SertifikaIslemi i) {
    final ne = switch (i) {
      SertifikaIslemi.pdf => _t(
          lang,
          'Sertifika PDF olarak kaydedilecek.',
          'The certificate will be saved as a PDF.',
          'Die Urkunde wird als PDF gespeichert.',
          'El certificado se guardará como PDF.'),
      SertifikaIslemi.instagram => _t(
          lang,
          "Sertifika Instagram'da paylaşılacak.",
          'The certificate will be shared on Instagram.',
          'Die Urkunde wird auf Instagram geteilt.',
          'El certificado se compartirá en Instagram.'),
      SertifikaIslemi.tiktok => _t(
          lang,
          "Sertifika TikTok'ta paylaşılacak.",
          'The certificate will be shared on TikTok.',
          'Die Urkunde wird auf TikTok geteilt.',
          'El certificado se compartirá en TikTok.'),
      SertifikaIslemi.galeri => _t(
          lang,
          'Sertifika fotoğraf galerisine kaydedilecek.',
          'The certificate will be saved to the photo gallery.',
          'Die Urkunde wird in der Fotogalerie gespeichert.',
          'El certificado se guardará en la galería de fotos.'),
      SertifikaIslemi.paylas => _t(
          lang,
          'Sertifika başka bir uygulamayla paylaşılacak.',
          'The certificate will be shared with another app.',
          'Die Urkunde wird mit einer anderen App geteilt.',
          'El certificado se compartirá con otra app.'),
    };
    return '$ne ${_t(lang, 'Sertifikada çocuğunuzun adı var. Devam etmek için lütfen doğum yılınızı girin.', "The certificate shows your child's name. Please enter your year of birth to continue.", 'Auf der Urkunde steht der Name deines Kindes. Bitte gib dein Geburtsjahr ein, um fortzufahren.', 'El certificado muestra el nombre de tu hijo o hija. Escribe tu año de nacimiento para continuar.')}';
  }

  /// Kapidan gecerse islemi yapar. Kapi gecilmezse hicbir sey olmaz.
  static Future<bool> uygula(
      BuildContext context, SertifikaVerisi veri, SertifikaIslemi i) async {
    final lang = veri.lang;
    final gecti = await ParentGate.verify(context,
        reason: kapiNedeni(lang, i), lang: lang);
    if (!gecti || !context.mounted) return false;
    final mesaj = ScaffoldMessenger.maybeOf(context);
    void bildir(String m, {SnackBarAction? eylem}) {
      mesaj?.hideCurrentSnackBar();
      mesaj?.showSnackBar(SnackBar(
        content: Text(m),
        action: eylem,
        behavior: SnackBarBehavior.floating,
      ));
    }

    final p = platform;
    try {
      switch (i) {
        case SertifikaIslemi.pdf:
          final bayt = await SertifikaCizici.pdf(veri);
          final f = File('${(await p.geciciDizin()).path}/'
              '${veri.dosyaAdi()}.pdf');
          await f.writeAsBytes(bayt, flush: true);
          // Paylasim menusunde "Dosyalara kaydet" / "Indir" var.
          await p.paylas([f.path], konu: veri.dosyaAdi());
        case SertifikaIslemi.galeri:
          if (!await p.galeriIzni()) {
            if (context.mounted) await _izinYok(context, lang);
            return false;
          }
          await p.galeriyeKaydet(
              await SertifikaCizici.sertifikaPng(veri), veri.dosyaAdi());
          bildir(_t(
              lang,
              'Sertifika galeriye kaydedildi.',
              'Certificate saved to the gallery.',
              'Urkunde in der Galerie gespeichert.',
              'Certificado guardado en la galería.'));
        case SertifikaIslemi.instagram:
        case SertifikaIslemi.tiktok:
          final insta = i == SertifikaIslemi.instagram;
          final uygulama = insta ? 'Instagram' : 'TikTok';
          final bayt = await SertifikaCizici.paylasimPng(
              veri, insta ? PaylasimBicimi.instagram : PaylasimBicimi.tiktok);
          final f = File('${(await p.geciciDizin()).path}/'
              '${veri.dosyaAdi(insta ? 'instagram' : 'tiktok')}.png');
          await f.writeAsBytes(bayt, flush: true);
          if (p.android) {
            final gitti = await p.uygulamayaGonder(
                f.path, insta ? instagramPaketleri : tiktokPaketleri,
                metin: veri.paylasimMetni);
            if (gitti) return true;
            bildir(_t(
                lang,
                '$uygulama bu cihazda bulunamadı. Paylaşım menüsünden başka bir uygulama seçebilirsin.',
                "$uygulama isn't installed on this device. You can pick another app from the share menu.",
                '$uygulama ist auf diesem Gerät nicht installiert. Du kannst im Teilen-Menü eine andere App wählen.',
                '$uygulama no está instalada en este dispositivo. Puedes elegir otra app en el menú de compartir.'));
          } else {
            // iOS: SDK'siz dogrudan yol yok. Once galeriye (Instagram
            // ve TikTok oradan da secebiliyor), sonra paylasim menusu.
            var kaydedildi = false;
            try {
              if (await p.galeriIzni()) {
                await p.galeriyeKaydet(
                    bayt, veri.dosyaAdi(insta ? 'instagram' : 'tiktok'));
                kaydedildi = true;
              }
            } catch (_) {
              // Galeri olmasa da paylasim menusu yine acilir.
            }
            final sec = _t(
                lang,
                insta
                    ? "Paylaşım menüsünden Instagram'ı seç."
                    : "Paylaşım menüsünden TikTok'u seç.",
                'Choose $uygulama in the share menu.',
                'Wähle $uygulama im Teilen-Menü.',
                'Elige $uygulama en el menú de compartir.');
            bildir(kaydedildi
                ? '$sec ${_t(lang, 'Görsel galeriye de kaydedildi.', 'The image was also saved to your photos.', 'Das Bild ist auch in deinen Fotos.', 'La imagen también se guardó en tus fotos.')}'
                : sec);
          }
          await p.paylas([f.path], metin: veri.paylasimMetni);
        case SertifikaIslemi.paylas:
          final f = File('${(await p.geciciDizin()).path}/'
              '${veri.dosyaAdi()}.png');
          await f.writeAsBytes(await SertifikaCizici.sertifikaPng(veri),
              flush: true);
          await p.paylas([f.path], metin: veri.paylasimMetni);
      }
      return true;
    } on GalException catch (e) {
      if (e.type == GalExceptionType.accessDenied && context.mounted) {
        await _izinYok(context, lang);
      } else {
        bildir(_hata(lang));
      }
      return false;
    } catch (e) {
      debugPrint('Sertifika işlemi yapılamadı: $e');
      bildir(_hata(lang));
      return false;
    }
  }

  static String _hata(String lang) => _t(
      lang,
      'Sertifika hazırlanamadı, tekrar dene.',
      'The certificate could not be created. Please try again.',
      'Die Urkunde konnte nicht erstellt werden. Versuch es noch einmal.',
      'No se pudo crear el certificado. Inténtalo de nuevo.');

  /// Galeri izni verilmedi: neden gerektigini anlat, Ayarlar'a goturebil.
  static Future<void> _izinYok(BuildContext context, String lang) async {
    final ayar = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        key: const ValueKey('galeri_izni_yok'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(_t(lang, 'Galeri izni gerekli', 'Photo access needed',
            'Fotozugriff nötig', 'Se necesita acceso a las fotos')),
        content: Text(_t(
            lang,
            'Sertifikayı fotoğraflarına kaydedebilmemiz için izin vermen gerekiyor. Ayarlar\'dan "Fotoğraflar" iznini açabilirsin.',
            'To save the certificate to your photos, please allow photo access. You can turn it on in Settings.',
            'Damit wir die Urkunde in deinen Fotos speichern können, erlaube bitte den Fotozugriff. Du kannst ihn in den Einstellungen einschalten.',
            'Para guardar el certificado en tus fotos, permite el acceso a las fotos. Puedes activarlo en Ajustes.')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: Text(_t(lang, 'Vazgeç', 'Cancel', 'Abbrechen', 'Cancelar')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(c).pop(true),
            child: Text(_t(lang, 'Ayarları aç', 'Open Settings',
                'Einstellungen öffnen', 'Abrir Ajustes')),
          ),
        ],
      ),
    );
    if (ayar == true) await platform.ayarlariAc();
  }
}

/// Alt sayfa: dort secenek + genel paylasim.
class SertifikaSecenekleri extends StatelessWidget {
  const SertifikaSecenekleri({super.key, required this.lang});
  final String lang;

  String _t(String tr, String en, String de, String es) =>
      tanitimMetni(lang, tr, en, de, es);

  @override
  Widget build(BuildContext context) {
    Widget secenek(SertifikaIslemi i, IconData ikon, List<Color> renk,
        String baslik, String alt) {
      return Semantics(
        button: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: ValueKey('sertifika_${i.name}'),
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).pop(i);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: renk,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(ikon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          baslik,
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F2430),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          alt,
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: Colors.grey.shade400),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                _t(
                    'Sertifikanı kaydet ya da paylaş',
                    'Save or share your certificate',
                    'Urkunde speichern oder teilen',
                    'Guarda o comparte tu certificado'),
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1F2430),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lock_outline_rounded,
                      size: 15, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _t(
                          'Her seçenekten önce bir yetişkinden onay istenir.',
                          'An adult is asked to confirm before each option.',
                          'Vor jeder Option bestätigt ein Erwachsener.',
                          'Antes de cada opción, un adulto debe confirmar.'),
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            secenek(
                SertifikaIslemi.pdf,
                Icons.picture_as_pdf_rounded,
                const [Color(0xFFF0564A), Color(0xFFD93A2F)],
                _t('PDF olarak indir', 'Download as PDF',
                    'Als PDF herunterladen', 'Descargar como PDF'),
                _t('A4, yazdırmaya hazır', 'A4, ready to print',
                    'A4, druckfertig', 'A4, lista para imprimir')),
            secenek(
                SertifikaIslemi.instagram,
                Icons.camera_alt_rounded,
                const [Color(0xFFF58529), Color(0xFFDD2A7B), Color(0xFF8134AF)],
                _t("Instagram'da paylaş", 'Share on Instagram',
                    'Auf Instagram teilen', 'Compartir en Instagram'),
                _t('4:5 gönderi görseli', '4:5 post image', '4:5-Beitragsbild',
                    'Imagen de publicación 4:5')),
            secenek(
                SertifikaIslemi.tiktok,
                Icons.music_note_rounded,
                const [Color(0xFF25F4EE), Color(0xFF111111), Color(0xFFFE2C55)],
                _t("TikTok'ta paylaş", 'Share on TikTok', 'Auf TikTok teilen',
                    'Compartir en TikTok'),
                _t('9:16 dikey görsel', '9:16 vertical image',
                    '9:16-Hochformatbild', 'Imagen vertical 9:16')),
            secenek(
                SertifikaIslemi.galeri,
                Icons.photo_library_rounded,
                const [Color(0xFF4CBF56), Color(0xFF2E9A3E)],
                _t('Galeriye kaydet', 'Save to gallery',
                    'In der Galerie speichern', 'Guardar en la galería'),
                _t('Fotoğraflarına resim olarak', 'As a picture in your photos',
                    'Als Bild in deinen Fotos', 'Como imagen en tus fotos')),
            const Divider(height: 14),
            secenek(
                SertifikaIslemi.paylas,
                Icons.ios_share_rounded,
                const [Color(0xFF6B7385), Color(0xFF4A4F5C)],
                _t('Başka bir yolla paylaş', 'Share another way',
                    'Anders teilen', 'Compartir de otra forma'),
                _t('E-posta, mesaj ve diğerleri', 'Email, messages and more',
                    'E-Mail, Nachrichten und mehr', 'Correo, mensajes y más')),
          ],
        ),
      ),
    );
  }
}
