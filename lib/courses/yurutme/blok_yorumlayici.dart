import 'dart:math';
import 'dart:ui' show Color;

import '../models/interactive_lesson_model.dart';
import 'blok_anlami.dart';
import 'blok_sozlugu.dart';

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

/// Bir yurutmenin sonucu.
class Yurutme {
  const Yurutme({
    required this.adimlar,
    required this.sonSahne,
    required this.butceBitti,
    this.yalnizTanim = false,
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
}

/// Kod alanindaki (ya da kutuphanedeki) tek bir satir.
class _Satir {
  const _Satir(this.blok, this.sira);
  final ScratchBlock blok;
  final int sira;
}

/// Kendi blogunun tanimi: girdinin adi ve govdesi.
class _Tanim {
  _Tanim(this.girdi);
  final String? girdi;
  final List<_Satir> govde = [];
}

/// Blok dizisini GERCEKTEN calistirir.
///
/// IC ICE YAPI: model duz bir liste tutuyor ve kod alani bir C blogundan
/// sonraki her seyi bir kademe iceri cizilmis gosteriyor. Yorumlayici da
/// aynisini yapiyor — cocugun GORDUGU yapi ile calisan yapi birebir ayni
/// olsun diye. Yani bir C blogunun govdesi, kendisinden sonra gelen
/// butun bloklar.
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

  Yurutme yurut(List<ScratchBlock> bloklar) {
    final sahne = Sahne();
    final adimlar = <YurutmeAdimi>[];

    // YIGINLARI AYIR: bir `tanimla` sapkasi ayri bir yigin baslatir; o
    // yigin bir sonraki olay sapkasina (bayrak) kadar surer. Geri kalan
    // her sey ana yigin.
    final ana = <_Satir>[];
    final tanimlar = <String, _Tanim>{};
    _Tanim? acik;
    for (var i = 0; i < bloklar.length; i++) {
      final b = bloklar[i];
      final a = _anlam(b);
      if (a.komut == BlokKomutu.tanimla) {
        acik = tanimlar[a.yordam ?? '?'] = _Tanim(a.girdi);
        continue;
      }
      if (a.komut == BlokKomutu.baslat) acik = null;
      (acik?.govde ?? ana).add(_Satir(b, i));
    }

    final butceBitti = _calistir(
        ana, 0, sahne, adimlar, null, const {}, tanimlar, 0);
    return Yurutme(
      adimlar: adimlar,
      sonSahne: sahne,
      butceBitti: butceBitti,
      yalnizTanim: ana.isEmpty && tanimlar.isNotEmpty,
    );
  }

  /// Kosul degerlendirilebiliyorsa sonucu, degilse null (DOGRU sayilir).
  bool? _kosul(BlokAnlami anlam, Sahne sahne) {
    final ad = anlam.kosulDegisken;
    final deger = anlam.kosulDeger;
    if (ad == null || deger == null) return null;
    final v = sahne.degiskenler[ad] ?? 0;
    return switch (anlam.kosulIslem) {
      '<' => v < deger,
      '>' => v > deger,
      _ => v == deger,
    };
  }

  /// Verilen dilimi calistirir. `true` donerse butce doldu.
  bool _calistir(
    List<_Satir> dilim,
    int derinlik,
    Sahne sahne,
    List<YurutmeAdimi> adimlar,
    int? tekrarNo,
    Map<String, num> girdiler,
    Map<String, _Tanim> tanimlar,
    int cagriDerinligi,
  ) {
    for (var i = 0; i < dilim.length; i++) {
      if (adimlar.length >= butce) return true;
      final satir = dilim[i];
      final blok = satir.blok;
      final anlam = _anlam(blok);

      if (anlam.cBlogu) {
        // Govde: bu blogun ARDINDAN gelen her sey.
        final govde = dilim.sublist(i + 1);
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

        final turSayisi = switch (anlam.komut) {
          BlokKomutu.tekrarla => anlam.girdi != null
              ? (girdiler[anlam.girdi] ?? 0).toInt()
              : (anlam.sayi ?? 1).toInt(),
          BlokKomutu.eger => (kosul ?? true) ? 1 : 0,
          _ => -1, // surekli
        };

        var tur = 0;
        while (turSayisi < 0 || tur < turSayisi) {
          tur++;
          final doldu = _calistir(
            govde,
            derinlik + 1,
            sahne,
            adimlar,
            anlam.komut == BlokKomutu.eger ? tekrarNo : tur,
            girdiler,
            tanimlar,
            cagriDerinligi,
          );
          if (doldu) return true;
          if (govde.isEmpty) break; // bos C blogu sonsuza donmesin
        }
        // Govde C blogunun icinde tuketildi; dilimin geri kalani yok.
        return false;
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
        final List<_Satir> govde;
        final String? girdiAdi;
        final kendi = tanimlar[ad];
        if (kendi != null) {
          govde = kendi.govde;
          girdiAdi = kendi.girdi;
        } else if (kutuphane[ad] case final hazir?) {
          girdiAdi = hazir.$1;
          // Kod alaninda olmayan bloklar: kod alaninda cagri parliyor.
          govde = [for (final b in hazir.$2) _Satir(b, satir.sira)];
        } else {
          continue;
        }
        final yeniGirdiler = {
          ...girdiler,
          if (girdiAdi != null && anlam.sayi != null) girdiAdi: anlam.sayi!,
        };
        final doldu = _calistir(govde, derinlik + 1, sahne, adimlar,
            tekrarNo, yeniGirdiler, tanimlar, cagriDerinligi + 1);
        if (doldu) return true;
        continue;
      }

      _uygula(anlam, sahne, girdiler);
      adimlar.add(YurutmeAdimi(
        blokId: blok.id,
        derinlik: derinlik,
        sahne: sahne.kopya(),
        tekrarNo: tekrarNo,
        etkisiz: anlam.komut == BlokKomutu.etkisiz ||
            anlam.komut == BlokKomutu.baslat,
        blokSirasi: satir.sira,
        blok: blok,
      ));
    }
    return false;
  }

  /// Trigonometri 100 adim yerine 99.99999 gibi kusuratlar uretiyor;
  /// izde "x: 100" yazsin diye virgulden sonra 3 basamaga yuvarliyoruz.
  static double _yuvarla(double v) => (v * 1000).roundToDouble() / 1000;

  void _uygula(BlokAnlami anlam, Sahne sahne, Map<String, num> girdiler) {
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
        // cizimi siliyor. Sahnede tuttugumuz sey cizim degil kalemin
        // durumu oldugu icin burada gorunur bir degisiklik yok.
        break;
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
        sahne.degiskenler[anlam.degisken ?? '?'] = anlam.sayi ?? 0;
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
        break;
    }
  }
}
