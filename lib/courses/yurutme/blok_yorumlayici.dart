import 'dart:math';
import 'dart:ui' show Color;

import '../models/interactive_lesson_model.dart';
import 'blok_anlami.dart';
import 'blok_sozlugu.dart';
import 'kod_yapisi.dart';

/// Kuklanin ve degiskenlerin o andaki hali.
class Sahne {
  Sahne({
    this.x = 0,
    this.y = 0,
    this.kostum = 1,
    this.yon = 90,
    this.kalemInik = false,
    this.soyledigi,
    Map<String, num>? degiskenler,
    Map<String, List<String>>? listeler,
  })  : degiskenler = degiskenler ?? {},
        listeler = listeler ?? {};

  double x;
  double y;

  /// Kacinci kostum gosteriliyor (1'den baslar). "Sonraki kostum"
  /// blogu bunu arttiriyor; bir karakteri dans ettiren sey bu.
  int kostum;

  /// Kuklanin baktigi yon, derece. Scratch'te 90 saga bakmak demek;
  /// baslangic degeri de o.
  double yon;

  /// Kalem inik mi? Inikken kuklanin gittigi yer cizgi birakir.
  bool kalemInik;

  String? soyledigi;
  final Map<String, num> degiskenler;

  /// Liste adi -> icindekiler. Ekle/sil bloklari burayi degistiriyor,
  /// boylece iz "alisveris: elma, muz" diyebiliyor.
  final Map<String, List<String>> listeler;

  Sahne kopya() => Sahne(
        x: x,
        y: y,
        kostum: kostum,
        yon: yon,
        kalemInik: kalemInik,
        soyledigi: soyledigi,
        degiskenler: Map<String, num>.from(degiskenler),
        listeler: {
          for (final e in listeler.entries) e.key: List<String>.from(e.value)
        },
      );
}

/// Yurutmenin tek bir adimi.
class YurutmeAdimi {
  const YurutmeAdimi({
    required this.blokId,
    required this.derinlik,
    required this.sahne,
    this.tekrarNo,
    this.etkisiz = false,
    this.blokSirasi = -1,
    this.blok,
    this.kosulSonucu,
  });

  final String blokId;

  /// Blogun kod alanindaki sirasi (0'dan). Ayni blok kod alaninda iki kez
  /// bulunabildigi icin (or. iki "1 saniye bekle") kimlik yetmiyor;
  /// sahne oynaticisi o an calisan blogu kod alaninda bununla isaretliyor.
  ///
  /// Kod alaninda OLMAYAN bir tanimin govdesi calisirken (bkz.
  /// [BlokYorumlayici.kutuphane]) burada CAGRI blogunun sirasi var: kod
  /// alaninda o parliyor; calisan asil blok [blok].
  final int blokSirasi;

  /// Calisan blogun kendisi. Kod alanindaki bloklar icin
  /// `bloklar[blokSirasi]` ile ayni; kutuphane tanimlarinda kod alaninda
  /// olmayan blok.
  final ScratchBlock? blok;

  /// Kac C blogunun icinde? Kod alanindaki girintiyle ayni.
  final int derinlik;

  /// Bu adim bittikten SONRAKI sahne.
  final Sahne sahne;

  /// Bir dongunun kacinci turu (1'den baslar), dongude degilse null.
  /// Cocuga "3. tur" diyebilmek icin: bir dongunun gercekten dondugunu
  /// gostermenin en dogrudan yolu.
  final int? tekrarNo;

  /// Blogun gorunur bir etkisi yok; yalnizca sirasi geldi.
  final bool etkisiz;

  /// Degerlendirilen bir `eger` kosulunun sonucu (`puan < 5` gibi).
  /// Algilama kosullarinda (degerlendirilemeyen) null.
  final bool? kosulSonucu;
}

/// Kalemin cizdigi tek bir dogru parcasi (dunya koordinati).
class KalemCizgisi {
  const KalemCizgisi(this.x1, this.y1, this.x2, this.y2);
  final double x1, y1, x2, y2;

  double get uzunluk =>
      sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));

  @override
  String toString() => '($x1,$y1)->($x2,$y2)';
}

/// Bir yurutmenin sonucu.
class Yurutme {
  const Yurutme({
    required this.adimlar,
    required this.sonSahne,
    required this.butceBitti,
    this.yalnizTanim = false,
    this.cizgiler = const [],
    this.soylenenler = const [],
    this.alinanHaberler = const {},
    this.calisanOlaylar = const [],
    this.cagrilar = const [],
    this.sapkasizBlok = 0,
    this.olayBloklari = const {},
  });

  final List<YurutmeAdimi> adimlar;
  final Sahne sonSahne;

  /// Adim butcesi doldu: kod bitmedi, biz durdurduk. `surekli tekrarla`
  /// zaten bitmez; bu bir hata degil, sonsuz donguyu uygulamayi
  /// dondurmadan calistirmanin yolu.
  final bool butceBitti;

  /// Kod alaninda yalnizca kendi blok TANIMI var, onu calistiran yok.
  /// Bayrağa basinca hicbir sey olmuyor — 11.1'in sordugu sey tam bu;
  /// ekran bunu "bloklar calisti" diye degil, nedeniyle soyluyor.
  final bool yalnizTanim;

  /// Kalemin cizdigi parcalar, cizildikleri sirayla ("sil" sonrasi
  /// bastan). Atolye hedefleri ("kapali bir sekil ciz") buna bakiyor.
  final List<KalemCizgisi> cizgiler;

  /// Kuklanin soyledigi her sey, sirayla (son soz degil, hepsi).
  final List<String> soylenenler;

  /// Alinan (en az bir alicisi calisan) haberler.
  final Set<String> alinanHaberler;

  /// Calisan olay betikleri: `bayrak`, `tus:space`, `haber:zipla`,
  /// `tikla`.
  final List<String> calisanOlaylar;

  /// Kendi blok cagrilari: (yordam, girdi).
  final List<(String, num?)> cagrilar;

  /// Hicbir sapkanin altinda olmayan (Proje Atolyesi'nde calismayan)
  /// blok sayisi.
  final int sapkasizBlok;

  /// Her olay betiginin calistirdigi bloklar (`tus:space` -> [...]).
  final Map<String, List<String>> olayBloklari;
}

/// Kod alanindaki (ya da kutuphanedeki) tek bir satir.
class _Satir {
  const _Satir(this.blok, this.sira);
  final ScratchBlock blok;
  final int sira;
}

/// Agacin dugumu: bir satir ve (C blogu ise) govdesi, eger-degilse ise
/// ikinci kolu.
class _Dugum {
  _Dugum(this.satir);
  final _Satir satir;
  List<_Dugum>? govde;
  List<_Dugum>? degilse;
}

/// Kendi blogunun tanimi: girdinin adi ve govdesi.
class _Tanim {
  _Tanim(this.girdi);
  final String? girdi;
  final List<_Satir> govde = [];
  late final List<_Dugum> agac = BlokYorumlayici._agac(govde);
}

/// Bir betik: sapkasi (anlam) ve govdesi.
class _Betik {
  _Betik(this.sapka);
  final BlokAnlami? sapka;
  final List<_Satir> satirlar = [];
  late final List<_Dugum> agac = BlokYorumlayici._agac(satirlar);
}

/// Bir yurutmenin degisen durumu.
class _Baglam {
  _Baglam(this.sinir);
  int sinir;
  final Map<String, _Tanim> tanimlar = {};
  final List<_Betik> alicilar = [];
  final List<KalemCizgisi> cizgiler = [];
  final List<String> soylenenler = [];
  final Set<String> alinanHaberler = {};
  final List<String> calisanOlaylar = [];
  final List<(String, num?)> cagrilar = [];
  final Map<String, List<String>> olayBloklari = {};

  /// Su an calisan olay betigi.
  String? aktifOlay;

  /// Haber salinca alicilar calissin mi (Proje Atolyesi).
  bool haberler = false;
}

/// Blok dizisini GERCEKTEN calistirir.
///
/// IC ICE YAPI: model duz bir liste tutuyor. Eski adimlarda kod alani bir
/// C blogundan sonraki her seyi bir kademe iceri cizilmis gosteriyor;
/// yorumlayici da aynisini yapiyor — cocugun GORDUGU yapi ile calisan
/// yapi birebir ayni olsun diye. Ic ice adimlarda (bkz. [KodYapisi]) C
/// blogunun govdesi kendi KAPANIS isaretine kadar; ardindaki bloklar
/// donguden SONRA calisiyor. "Degilse" isareti eger blogunu ikiye
/// boluyor: kosul yanlissa ikinci kol calisiyor.
///
/// KOSULLAR: durumdan bilinebilen kosullar GERCEKTEN degerlendiriliyor
/// (`eger <puan < 5> ise`: degisken sahnede tutuluyor; kosul yanlissa
/// govde calismiyor). Algilama kosullarinin (`bosluk tusu basili mi?`,
/// `Fare'ye degiyor mu?`) karsiligi yok: ne klavye var ne de sahnede
/// ikinci bir kukla. Bunlar DETERMINIST olarak DOGRU sayiliyor — yani
/// "cocuk tusa basti / kukla degdi" varsayiliyor; govdeyi calistirmak
/// cocugun kurdugu akisi gostermenin en durust yolu. Iz bu kosullarin
/// yanina bir sonuc yazmiyor; yalnizca gercekten olculen kosullarin
/// yanina "dogru/yanlis" yaziyor.
///
/// KENDI BLOGUN: `... tanimla` sapkasi AYRI bir yigin baslatiyor ve o
/// yigin kendi basina calismiyor; yalnizca bir cagri (`kare`, `cokgen 6`)
/// onu calistiriyor. Girdi (`kenar`) cagridan geliyor: `kenar kere
/// tekrarla` gercekten kenar kez donuyor, `360 / kenar derece don` aciyi
/// hesapliyor. Kod alaninda tanim yoksa [kutuphane]deki tanim kullaniliyor
/// (dersin bir onceki adiminda kurulan tanim).
///
/// BUTCE: `surekli tekrarla` bitmez. Butce dolunca duruyoruz ve bunu
/// [Yurutme.butceBitti] ile SOYLUYORUZ. Uygulama donmuyor, ekran da
/// "bitti" diye yalan soylemiyor.
class BlokYorumlayici {
  const BlokYorumlayici({this.butce = 400, this.rastgele, this.dil = 'tr'});

  /// En fazla kac adim calistirilir.
  final int butce;

  /// Rastgele sayi kaynagi. Testler tohumlu bir [Random] gecerek ayni
  /// sonucu tekrar uretebiliyor; ekranda null kaliyor, yani her
  /// calistirma gercekten baska bir sayi veriyor.
  final Random? rastgele;

  /// Cocugun dili: ornek listeden soylenen soru bu dilde.
  final String dil;

  /// Ic ice cagri siniri (kendi kendini cagiran blok sonsuza gitmesin).
  static const int _enFazlaCagriDerinligi = 8;

  /// Blogun anlami. Sozlukte yoksa (mBlock/Arduino bloklarinin cogu)
  /// yapisindan cikariliyor.
  ///
  /// C BLOKLARI: kod alani `shape == cBlock` olan her blogun altini
  /// iceri girintili ciziyor. Sozlukte olmayan bir C blogu (or.
  /// `if_pressed`, `k_forever`) burada duz blok sayiliyordu; iz kodu
  /// cocugun gordugu yapidan BASKA bir yapiyla calistiriyordu.
  static BlokAnlami anlamOf(ScratchBlock blok) {
    final yalin = _yalinAnlam(blok);
    // Cocugun tus takimiyla yazdigi sayi.
    final d = blok.deger;
    if (d != null && yalin.sayiDuzenlenebilir) return yalin.sayiIle(d);
    return yalin;
  }

  static BlokAnlami _yalinAnlam(ScratchBlock blok) {
    // Kod alaninin yapi isaretleri (C blogunun sonu, "degilse"): etkisiz.
    if (KodYapisi.isaretMi(blok.id)) {
      return const BlokAnlami(BlokKomutu.etkisiz);
    }
    // mBlock kukla programlari (bkz. mblock_kukla.dart): anlam kimligin
    // ICINDE yazili, sozlukte aranmiyor.
    if (blok.id.startsWith(mblockOneki)) return mblockAnlami(blok.id);
    final bilinen = blokSozlugu[blok.id];
    if (bilinen != null && bilinen.komut != BlokKomutu.etkisiz) {
      return bilinen;
    }
    final id = blok.id;
    if (blok.shape == ScratchBlockShape.cBlock) {
      if (id.contains('forever')) return const BlokAnlami(BlokKomutu.surekli);
      final tekrar = RegExp(r'repeat_(\d+)').firstMatch(id);
      if (tekrar != null) {
        return BlokAnlami(BlokKomutu.tekrarla,
            sayi: int.parse(tekrar.group(1)!));
      }
      // Kosul ya da sayisi bilinmeyen dongu: govde bir kez calisiyor.
      return const BlokAnlami(BlokKomutu.eger);
    }
    if (bilinen != null) return bilinen;
    final git = RegExp(r'^move_(\d+)$').firstMatch(id);
    if (git != null) {
      return BlokAnlami(BlokKomutu.ilerle, sayi: int.parse(git.group(1)!));
    }
    final don = RegExp(r'^turn_(\d+)$').firstMatch(id);
    if (don != null) {
      return BlokAnlami(BlokKomutu.don, sayi: int.parse(don.group(1)!));
    }
    return const BlokAnlami(BlokKomutu.etkisiz);
  }

  BlokAnlami _anlam(ScratchBlock blok) => anlamOf(blok);

  /// mBlock tezgahindan cevrilen bloklarin kimlik oneki.
  static const String mblockOneki = 'mbk|';

  /// mBlock kukla blogunun kimligi: anlami kimligin icinde
  /// (`mbk|ilerle|50||3`). Ders verisindeki kimliklerin aksine bu
  /// bloklarin degerleri cocugun yazdigi sayilar; sozluge sigmazlar.
  static String mblockKimligi(BlokKomutu komut,
          {num? sayi, String? degisken, required int sira}) =>
      '$mblockOneki${komut.name}|${sayi ?? ''}|${degisken ?? ''}|$sira';

  /// [mblockKimligi]'nin tersi.
  static BlokAnlami mblockAnlami(String id) {
    final p = id.substring(mblockOneki.length).split('|');
    final komut = BlokKomutu.values.firstWhere((k) => k.name == p[0],
        orElse: () => BlokKomutu.etkisiz);
    final sayi = p.length > 1 ? num.tryParse(p[1]) : null;
    final degisken = p.length > 2 && p[2].isNotEmpty ? p[2] : null;
    return BlokAnlami(komut, sayi: sayi, degisken: degisken);
  }

  static ScratchBlock _kb(String id, String tr, String en, String de,
          String es,
          {ScratchBlockShape sekil = ScratchBlockShape.stack,
          Color renk = const Color(0xFF4C97FF)}) =>
      ScratchBlock(
        id: id,
        blockType: ScratchBlockType.motion,
        shape: sekil,
        label: tr,
        labelEn: en,
        labelDe: de,
        labelEs: es,
        color: renk,
      );

  /// Kod alaninda tanimi OLMAYAN cagrilar icin tanimlar.
  ///
  /// 11.1'in ikinci adiminda kod alaninda yalnizca `kare` cagrisi var;
  /// tanim bir onceki adimda kuruldu. Scratch'te de tanim projede durur,
  /// cagri onu calistirir. Govdeler o adimlarin cozumuyle ayni.
  static final Map<String, (String?, List<ScratchBlock>)> kutuphane = {
    'kare': (
      null,
      [
        _kb('repeat_4', '4 defa tekrarla', 'repeat 4', 'wiederhole 4 mal',
            'repetir 4',
            sekil: ScratchBlockShape.cBlock, renk: const Color(0xFFFFAB19)),
        _kb('move_100', '100 adım git', 'move 100 steps', 'gehe 100er Schritt',
            'mover 100 pasos'),
        _kb('turn_90', '90 derece dön', 'turn 90 degrees', 'drehe dich um 90 Grad',
            'girar 90 grados'),
      ]
    ),
    'cokgen': (
      'kenar',
      [
        _kb('repeat_sides', 'kenar defa tekrarla', 'repeat sides',
            'wiederhole Seiten mal', 'repetir lados',
            sekil: ScratchBlockShape.cBlock, renk: const Color(0xFFFFAB19)),
        _kb('move_100_poly', '100 adım git', 'move 100 steps',
            'gehe 100er Schritt', 'mover 100 pasos'),
        _kb('turn_360_over_sides', '360 / kenar derece dön',
            'turn 360 / sides degrees', 'drehe dich um 360 / Seiten Grad',
            'girar 360 / lados grados'),
      ]
    ),
  };

  /// 10.2'nin soru torbasi bos geldiginde (adimda listeyi dolduran blok
  /// yok) kullanilan ornek liste — dersin anlattigi "bes soru".
  static const Map<String, List<String>> ornekSorular = {
    'tr': [
      '2 + 3 kaç eder?',
      'Bir haftada kaç gün var?',
      'Örümceğin kaç bacağı var?',
      'Gökkuşağında kaç renk var?',
      '10 - 4 kaç eder?',
    ],
    'en': [
      'What is 2 + 3?',
      'How many days are in a week?',
      'How many legs does a spider have?',
      'How many colours are in a rainbow?',
      'What is 10 - 4?',
    ],
    'de': [
      'Wie viel ist 2 + 3?',
      'Wie viele Tage hat eine Woche?',
      'Wie viele Beine hat eine Spinne?',
      'Wie viele Farben hat ein Regenbogen?',
      'Wie viel ist 10 - 4?',
    ],
    'es': [
      '¿Cuánto es 2 + 3?',
      '¿Cuántos días tiene una semana?',
      '¿Cuántas patas tiene una araña?',
      '¿Cuántos colores tiene el arcoíris?',
      '¿Cuánto es 10 - 4?',
    ],
  };

  /// Tek yiginli yurutme (blok kurma adimlari).
  ///
  /// `tanimla` sapkasi ayri bir yigin baslatir; o yigin bir sonraki olay
  /// sapkasina kadar surer. Geri kalan her sey — sapkalar dahil — ana
  /// yigin: eski adimlar boyle kuruldu ve boyle calisiyor.
  Yurutme yurut(List<ScratchBlock> bloklar) {
    final sahne = Sahne();
    final adimlar = <YurutmeAdimi>[];
    final b = _Baglam(butce);

    final ana = <_Satir>[];
    _Tanim? acik;
    for (var i = 0; i < bloklar.length; i++) {
      final blok = bloklar[i];
      final a = _anlam(blok);
      if (a.komut == BlokKomutu.tanimla) {
        acik = b.tanimlar[a.yordam ?? '?'] = _Tanim(a.girdi);
        continue;
      }
      if (a.komut == BlokKomutu.baslat) acik = null;
      (acik?.govde ?? ana).add(_Satir(blok, i));
    }

    final butceBitti =
        _calistir(_agac(ana), 0, sahne, adimlar, null, const {}, b, 0);
    return _sonuc(adimlar, sahne, butceBitti, b,
        yalnizTanim: ana.isEmpty && b.tanimlar.isNotEmpty);
  }

  /// PROJE ATOLYESI: cok betikli yurutme.
  ///
  /// Her sapka (bayrak, tus, haber, kuklaya tiklama, tanimla) kendi
  /// betigini baslatir. Sira Scratch'teki gibi:
  ///
  ///  1. yesil bayrak betikleri (kod alanindaki sirayla),
  ///  2. sonra cocuk her TUSA ve kuklaya bir kez "basmis" sayilir: tus
  ///     ve tiklama betikleri birer kez calisir,
  ///  3. `haberini sal` blogu o haberi alan betikleri O ANDA calistirir
  ///     ("haberini sal ve bekle" gibi; tek kuklali sahnede sirayi
  ///     belirli tutmanin yolu).
  ///
  /// Sapkasi olmayan bloklar CALISMAZ (Scratch'te de oyle); sayisi
  /// [Yurutme.sapkasizBlok]'ta, ekran bunu soyluyor.
  ///
  /// BUTCE: her betik butcenin bir payini aliyor; bayrak betigindeki
  /// `surekli tekrarla` tus betiklerini ac birakmasin.
  Yurutme yurutProje(List<ScratchBlock> bloklar) {
    final sahne = Sahne();
    final adimlar = <YurutmeAdimi>[];
    final b = _Baglam(butce)..haberler = true;

    final betikler = <_Betik>[];
    _Betik? acik;
    _Tanim? tanim;
    var sapkasiz = 0;
    var derinlik = 0;
    for (var i = 0; i < bloklar.length; i++) {
      final blok = bloklar[i];
      final a = _anlam(blok);
      // Yalnizca en distaki sapka yeni betik baslatir.
      if (derinlik == 0 && a.komut == BlokKomutu.tanimla) {
        tanim = b.tanimlar[a.yordam ?? '?'] = _Tanim(a.girdi);
        acik = null;
        continue;
      }
      if (derinlik == 0 && a.komut == BlokKomutu.baslat) {
        tanim = null;
        acik = _Betik(a);
        betikler.add(acik);
        // Sapkanin kendisi de izde gorunsun (sahnede parlasin).
        acik.satirlar.add(_Satir(blok, i));
        continue;
      }
      if (blok.id == KodYapisi.sonId) {
        derinlik = derinlik > 0 ? derinlik - 1 : 0;
      } else if (a.cBlogu) {
        derinlik++;
      }
      if (tanim != null) {
        tanim.govde.add(_Satir(blok, i));
      } else if (acik != null) {
        acik.satirlar.add(_Satir(blok, i));
      } else if (!KodYapisi.isaretMi(blok.id)) {
        sapkasiz++;
      }
    }
    b.alicilar.addAll(betikler.where((t) => t.sapka?.haber != null));

    final calisacak = [
      ...betikler.where((t) => t.sapka?.bayrakSapkasi ?? false),
      ...betikler.where((t) => t.sapka?.tus != null),
      ...betikler.where((t) => t.sapka?.tiklama ?? false),
    ];
    var butceBitti = false;
    for (var k = 0; k < calisacak.length; k++) {
      final t = calisacak[k];
      final kalan = butce - adimlar.length;
      if (kalan <= 0) {
        butceBitti = true;
        break;
      }
      b.sinir = adimlar.length + max(40, kalan ~/ (calisacak.length - k));
      b.calisanOlaylar.add(b.aktifOlay = _olayAdi(t.sapka!));
      final doldu =
          _calistir(t.agac, 0, sahne, adimlar, null, const {}, b, 0);
      butceBitti = butceBitti || doldu;
    }
    return _sonuc(adimlar, sahne, butceBitti, b,
        yalnizTanim: betikler.isEmpty && b.tanimlar.isNotEmpty,
        sapkasiz: sapkasiz);
  }

  static String _olayAdi(BlokAnlami sapka) {
    if (sapka.tus != null) return 'tus:${sapka.tus}';
    if (sapka.haber != null) return 'haber:${sapka.haber}';
    if (sapka.tiklama) return 'tikla';
    return 'bayrak';
  }

  Yurutme _sonuc(List<YurutmeAdimi> adimlar, Sahne sahne, bool butceBitti,
          _Baglam b,
          {bool yalnizTanim = false, int sapkasiz = 0}) =>
      Yurutme(
        adimlar: adimlar,
        sonSahne: sahne,
        butceBitti: butceBitti,
        yalnizTanim: yalnizTanim,
        cizgiler: List.unmodifiable(b.cizgiler),
        soylenenler: List.unmodifiable(b.soylenenler),
        alinanHaberler: Set.unmodifiable(b.alinanHaberler),
        calisanOlaylar: List.unmodifiable(b.calisanOlaylar),
        cagrilar: List.unmodifiable(b.cagrilar),
        sapkasizBlok: sapkasiz,
        olayBloklari: b.olayBloklari,
      );

  /// Satirlari agaca cevirir.
  ///
  /// Kapanis isareti olan C blogunun govdesi isaretine kadar; olmayanin
  /// govdesi dilimin sonuna kadar (eski kural). "Degilse" isareti
  /// eger blogunun govdesini ikiye boler.
  static List<_Dugum> _agac(List<_Satir> satirlar) {
    var i = 0;
    // (dugumler, bitis: null | son | degilse)
    (List<_Dugum>, String?) dizi() {
      final out = <_Dugum>[];
      while (i < satirlar.length) {
        final s = satirlar[i];
        if (s.blok.id == KodYapisi.sonId) {
          i++;
          return (out, KodYapisi.sonId);
        }
        if (s.blok.id == KodYapisi.degilseId) {
          i++;
          return (out, KodYapisi.degilseId);
        }
        i++;
        final d = _Dugum(s);
        if (anlamOf(s.blok).cBlogu) {
          final (govde, bitis) = dizi();
          d.govde = govde;
          if (bitis == KodYapisi.degilseId) {
            final (ikinci, _) = dizi();
            d.degilse = ikinci;
          }
        }
        out.add(d);
      }
      return (out, null);
    }

    final hepsi = <_Dugum>[];
    while (i < satirlar.length) {
      // Fazladan (eslesmeyen) isaretler en dista yok sayiliyor.
      hepsi.addAll(dizi().$1);
    }
    return hepsi;
  }

  /// Kosul degerlendirilebiliyorsa sonucu, degilse null (DOGRU sayilir).
  ///
  /// Degisken kosullari (`Puan < 5`) sahnedeki degiskene, `@x` / `@y`
  /// kuklanin konumuna bakar.
  bool? _kosul(BlokAnlami anlam, Sahne sahne) {
    final ad = anlam.kosulDegisken;
    final deger = anlam.kosulDeger;
    if (ad == null || deger == null) return null;
    final num v = switch (ad) {
      '@x' => sahne.x,
      '@y' => sahne.y,
      _ => sahne.degiskenler[ad] ?? 0,
    };
    return switch (anlam.kosulIslem) {
      '<' => v < deger,
      '>' => v > deger,
      _ => v == deger,
    };
  }

  /// Verilen dilimi calistirir. `true` donerse butce doldu.
  bool _calistir(
    List<_Dugum> dilim,
    int derinlik,
    Sahne sahne,
    List<YurutmeAdimi> adimlar,
    int? tekrarNo,
    Map<String, num> girdiler,
    _Baglam b,
    int cagriDerinligi,
  ) {
    for (final dugum in dilim) {
      if (adimlar.length >= b.sinir) return true;
      final satir = dugum.satir;
      final blok = satir.blok;
      final anlam = _anlam(blok);

      if (anlam.cBlogu) {
        final govde = dugum.govde ?? const <_Dugum>[];
        final kosul = anlam.komut == BlokKomutu.eger
            ? _kosul(anlam, sahne)
            : null;
        adimlar.add(YurutmeAdimi(
          blokId: blok.id,
          derinlik: derinlik,
          sahne: sahne.kopya(),
          tekrarNo: tekrarNo,
          blokSirasi: satir.sira,
          blok: blok,
          kosulSonucu: kosul,
        ));

        if (anlam.komut == BlokKomutu.eger) {
          final kol = (kosul ?? true) ? govde : dugum.degilse;
          if (kol != null &&
              _calistir(kol, derinlik + 1, sahne, adimlar, tekrarNo,
                  girdiler, b, cagriDerinligi)) {
            return true;
          }
          continue;
        }

        final turSayisi = switch (anlam.komut) {
          BlokKomutu.tekrarla => anlam.girdi != null
              ? (girdiler[anlam.girdi] ?? 0).toInt()
              : (anlam.sayi ?? 1).toInt(),
          _ => -1, // surekli
        };

        var tur = 0;
        while (turSayisi < 0 || tur < turSayisi) {
          tur++;
          final doldu = _calistir(govde, derinlik + 1, sahne, adimlar, tur,
              girdiler, b, cagriDerinligi);
          if (doldu) return true;
          if (govde.isEmpty) break; // bos C blogu sonsuza donmesin
        }
        // `surekli tekrarla` bitmez: altindakiler hic calismaz.
        if (turSayisi < 0) return false;
        continue;
      }

      if (anlam.komut == BlokKomutu.cagir) {
        adimlar.add(YurutmeAdimi(
          blokId: blok.id,
          derinlik: derinlik,
          sahne: sahne.kopya(),
          tekrarNo: tekrarNo,
          etkisiz: true,
          blokSirasi: satir.sira,
          blok: blok,
        ));
        if (cagriDerinligi >= _enFazlaCagriDerinligi) continue;
        final ad = anlam.yordam ?? '?';
        final List<_Dugum> govde;
        final String? girdiAdi;
        final kendi = b.tanimlar[ad];
        if (kendi != null) {
          govde = kendi.agac;
          girdiAdi = kendi.girdi;
        } else if (kutuphane[ad] case final hazir?) {
          girdiAdi = hazir.$1;
          // Kod alaninda olmayan bloklar: kod alaninda cagri parliyor.
          govde = _agac([for (final k in hazir.$2) _Satir(k, satir.sira)]);
        } else {
          continue;
        }
        b.cagrilar.add((ad, anlam.sayi));
        final yeniGirdiler = {
          ...girdiler,
          if (girdiAdi != null && anlam.sayi != null) girdiAdi: anlam.sayi!,
        };
        final doldu = _calistir(govde, derinlik + 1, sahne, adimlar,
            tekrarNo, yeniGirdiler, b, cagriDerinligi + 1);
        if (doldu) return true;
        continue;
      }

      if (KodYapisi.isaretMi(blok.id)) continue;

      _uygula(anlam, sahne, girdiler, b);
      if (b.aktifOlay case final olay?) {
        b.olayBloklari.putIfAbsent(olay, () => []).add(blok.id);
      }
      adimlar.add(YurutmeAdimi(
        blokId: blok.id,
        derinlik: derinlik,
        sahne: sahne.kopya(),
        tekrarNo: tekrarNo,
        etkisiz: anlam.komut == BlokKomutu.etkisiz ||
            anlam.komut == BlokKomutu.baslat ||
            anlam.komut == BlokKomutu.haberSal,
        blokSirasi: satir.sira,
        blok: blok,
      ));

      // Haber: alicilar O ANDA calisiyor (yalnizca atolyede).
      if (anlam.komut == BlokKomutu.haberSal &&
          b.haberler &&
          cagriDerinligi < _enFazlaCagriDerinligi) {
        for (final alici in b.alicilar) {
          if (alici.sapka?.haber != anlam.haber) continue;
          b.alinanHaberler.add(anlam.haber ?? '?');
          final onceki = b.aktifOlay;
          b.calisanOlaylar.add(b.aktifOlay = 'haber:${anlam.haber}');
          final doldu = _calistir(alici.agac, 0, sahne, adimlar, null,
              const {}, b, cagriDerinligi + 1);
          b.aktifOlay = onceki;
          if (doldu) return true;
        }
      }
    }
    return false;
  }

  /// Trigonometri 100 adim yerine 99.99999 gibi kusuratlar uretiyor;
  /// izde "x: 100" yazsin diye virgulden sonra 3 basamaga yuvarliyoruz.
  static double _yuvarla(double v) => (v * 1000).roundToDouble() / 1000;

  void _uygula(
      BlokAnlami anlam, Sahne sahne, Map<String, num> girdiler, _Baglam b) {
    final x0 = sahne.x, y0 = sahne.y;
    _uygulaYalin(anlam, sahne, girdiler, b);
    // Kalem inikken kuklanin gittigi yol cizgi olarak kaliyor.
    if (sahne.kalemInik && (sahne.x != x0 || sahne.y != y0)) {
      b.cizgiler.add(KalemCizgisi(x0, y0, sahne.x, sahne.y));
    }
    if (anlam.komut == BlokKomutu.soyle && sahne.soyledigi != null) {
      b.soylenenler.add(sahne.soyledigi!);
    }
  }

  void _uygulaYalin(
      BlokAnlami anlam, Sahne sahne, Map<String, num> girdiler, _Baglam b) {
    switch (anlam.komut) {
      case BlokKomutu.ilerle:
        // Kukla BAKTIGI YONE gidiyor. Eskiden yon hic hesaba katilmiyordu:
        // kare cizen kod (4 kez: 100 adim git, 90 derece don) izde
        // "x: 400" diyordu; oysa kukla basladigi yere doner. Scratch'te
        // 90 saga, 0 yukari bakmak.
        final aci = sahne.yon * pi / 180;
        final n = (anlam.sayi ?? 0).toDouble();
        sahne.x = _yuvarla(sahne.x + n * sin(aci));
        sahne.y = _yuvarla(sahne.y + n * cos(aci));
      case BlokKomutu.xDegistir:
        sahne.x += (anlam.sayi ?? 0).toDouble();
      case BlokKomutu.yDegistir:
        sahne.y += (anlam.sayi ?? 0).toDouble();
      case BlokKomutu.gitXY:
        sahne.x = (anlam.sayi ?? 0).toDouble();
        sahne.y = (anlam.sayi2 ?? 0).toDouble();
      case BlokKomutu.soyle:
        // Rastgele araligi olan bloklar her calistirmada baska bir sayi
        // soyluyor; sinirlar dahil (Scratch de boyle davraniyor).
        final kaynak = rastgele ?? Random();
        if (anlam.rastgeleAlt != null && anlam.rastgeleUst != null) {
          final alt = anlam.rastgeleAlt!.toInt();
          final ust = anlam.rastgeleUst!.toInt();
          sahne.soyledigi = '${alt + kaynak.nextInt((ust - alt) + 1)}';
        } else if (anlam.liste != null) {
          // Listenin uzunlugunu soyle.
          sahne.soyledigi = '${sahne.listeler[anlam.liste!]?.length ?? 0}';
        } else if (anlam.degisken != null) {
          // Degiskenin degerini soyle ("zar").
          final v = sahne.degiskenler[anlam.degisken!] ?? 0;
          sahne.soyledigi = v == v.roundToDouble() ? '${v.toInt()}' : '$v';
        } else if (anlam.listeRastgele != null) {
          // Listenin rastgele bir ogesi (1 ile uzunluk arasi, dahil).
          final liste = sahne.listeler[anlam.listeRastgele!];
          final torba = (liste != null && liste.isNotEmpty)
              ? liste
              : (ornekSorular[dil] ?? ornekSorular['en']!);
          sahne.soyledigi = torba[kaynak.nextInt(torba.length)];
        } else {
          sahne.soyledigi = anlam.metin;
        }
      case BlokKomutu.sonrakiKostum:
        sahne.kostum++;
      case BlokKomutu.yonAyarla:
        sahne.yon = (anlam.sayi ?? 90).toDouble() % 360;
      case BlokKomutu.don:
        // Scratch'te yon 0-360 arasinda dolasir. Girdili donus
        // ("360 / kenar"): aci sayi / girdi.
        var aci = (anlam.sayi ?? 0).toDouble();
        if (anlam.girdi != null) {
          final g = girdiler[anlam.girdi];
          aci = (g == null || g == 0) ? 0 : aci / g;
        }
        sahne.yon = _yuvarla((sahne.yon + aci) % 360);
      case BlokKomutu.kalemIndir:
        sahne.kalemInik = true;
      case BlokKomutu.kalemKaldir:
        sahne.kalemInik = false;
      case BlokKomutu.kalemSil:
        // Silmek kalemin inik/kalkik olmasini degistirmiyor; ekrandaki
        // cizimi siliyor.
        b.cizgiler.clear();
      case BlokKomutu.rastgeleKonum:
        // Scratch sahnesi 480 x 360: x -240..240, y -180..180. Kenara
        // yapismasin diye biraz iceride.
        final kaynak = rastgele ?? Random();
        sahne.x = (kaynak.nextInt(361) - 180).toDouble();
        sahne.y = (kaynak.nextInt(241) - 120).toDouble();
      case BlokKomutu.listeyeEkle:
        sahne.listeler
            .putIfAbsent(anlam.liste ?? '?', () => <String>[])
            .add(anlam.metin ?? '');
      case BlokKomutu.listedenSil:
        final l = sahne.listeler[anlam.liste ?? '?'];
        final sira = (anlam.sayi ?? 1).toInt();
        if (l != null && sira >= 1 && sira <= l.length) {
          l.removeAt(sira - 1);
        }
      case BlokKomutu.degiskenAta:
        if (anlam.rastgeleAlt != null && anlam.rastgeleUst != null) {
          final kaynak = rastgele ?? Random();
          final alt = anlam.rastgeleAlt!.toInt();
          final ust = anlam.rastgeleUst!.toInt();
          sahne.degiskenler[anlam.degisken ?? '?'] =
              alt + kaynak.nextInt((ust - alt) + 1);
        } else {
          sahne.degiskenler[anlam.degisken ?? '?'] = anlam.sayi ?? 0;
        }
      case BlokKomutu.degiskenArtir:
        final ad = anlam.degisken ?? '?';
        sahne.degiskenler[ad] =
            (sahne.degiskenler[ad] ?? 0) + (anlam.sayi ?? 0);
      case BlokKomutu.baslat:
      case BlokKomutu.bekle:
      case BlokKomutu.etkisiz:
      case BlokKomutu.tekrarla:
      case BlokKomutu.surekli:
      case BlokKomutu.eger:
      case BlokKomutu.tanimla:
      case BlokKomutu.cagir:
      case BlokKomutu.haberSal:
        break;
    }
  }
}
