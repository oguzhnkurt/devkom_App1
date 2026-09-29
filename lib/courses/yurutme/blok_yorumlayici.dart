import 'dart:math';

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
  });

  final String blokId;

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
}

/// Bir yurutmenin sonucu.
class Yurutme {
  const Yurutme({
    required this.adimlar,
    required this.sonSahne,
    required this.butceBitti,
  });

  final List<YurutmeAdimi> adimlar;
  final Sahne sonSahne;

  /// Adim butcesi doldu: kod bitmedi, biz durdurduk. `surekli tekrarla`
  /// zaten bitmez; bu bir hata degil, sonsuz donguyu uygulamayi
  /// dondurmadan calistirmanin yolu.
  final bool butceBitti;
}

/// Blok dizisini GERCEKTEN calistirir.
///
/// IC ICE YAPI: model duz bir liste tutuyor ve kod alani bir C blogundan
/// sonraki her seyi bir kademe iceri cizilmis gosteriyor. Yorumlayici da
/// aynisini yapiyor — cocugun GORDUGU yapi ile calisan yapi birebir ayni
/// olsun diye. Yani bir C blogunun govdesi, kendisinden sonra gelen
/// butun bloklar.
///
/// KOSULLAR simdilik DOGRU sayiliyor. `eger <bosluk basildi> ise`
/// blogunun gercek bir klavyesi yok; govdesini calistirmak, cocugun
/// kurduğu akisi gostermenin en durust yolu. Kosul degerlendirme
/// (algilama bloklari) sonraki adim.
///
/// BUTCE: `surekli tekrarla` bitmez. Butce dolunca duruyoruz ve bunu
/// [Yurutme.butceBitti] ile SOYLUYORUZ. Uygulama donmuyor, ekran da
/// "bitti" diye yalan soylemiyor.
class BlokYorumlayici {
  const BlokYorumlayici({this.butce = 400, this.rastgele});

  /// En fazla kac adim calistirilir.
  final int butce;

  /// Rastgele sayi kaynagi. Testler tohumlu bir [Random] gecerek ayni
  /// sonucu tekrar uretebiliyor; ekranda null kaliyor, yani her
  /// calistirma gercekten baska bir sayi veriyor.
  final Random? rastgele;

  BlokAnlami _anlam(ScratchBlock blok) =>
      blokSozlugu[blok.id] ?? const BlokAnlami(BlokKomutu.etkisiz);

  Yurutme yurut(List<ScratchBlock> bloklar) {
    final sahne = Sahne();
    final adimlar = <YurutmeAdimi>[];
    final butceBitti = _calistir(bloklar, 0, sahne, adimlar, null);
    return Yurutme(
      adimlar: adimlar,
      sonSahne: sahne,
      butceBitti: butceBitti,
    );
  }

  /// Verilen dilimi calistirir. `true` donerse butce doldu.
  bool _calistir(
    List<ScratchBlock> dilim,
    int derinlik,
    Sahne sahne,
    List<YurutmeAdimi> adimlar,
    int? tekrarNo,
  ) {
    for (var i = 0; i < dilim.length; i++) {
      if (adimlar.length >= butce) return true;
      final blok = dilim[i];
      final anlam = _anlam(blok);

      if (anlam.cBlogu) {
        // Govde: bu blogun ARDINDAN gelen her sey.
        final govde = dilim.sublist(i + 1);
        adimlar.add(YurutmeAdimi(
          blokId: blok.id,
          derinlik: derinlik,
          sahne: sahne.kopya(),
          tekrarNo: tekrarNo,
        ));

        final turSayisi = switch (anlam.komut) {
          BlokKomutu.tekrarla => (anlam.sayi ?? 1).toInt(),
          BlokKomutu.eger => 1,
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
          );
          if (doldu) return true;
          if (govde.isEmpty) break; // bos C blogu sonsuza donmesin
        }
        // Govde C blogunun icinde tuketildi; dilimin geri kalani yok.
        return false;
      }

      _uygula(anlam, sahne);
      adimlar.add(YurutmeAdimi(
        blokId: blok.id,
        derinlik: derinlik,
        sahne: sahne.kopya(),
        tekrarNo: tekrarNo,
        etkisiz: anlam.komut == BlokKomutu.etkisiz ||
            anlam.komut == BlokKomutu.baslat,
      ));
    }
    return false;
  }

  void _uygula(BlokAnlami anlam, Sahne sahne) {
    switch (anlam.komut) {
      case BlokKomutu.ilerle:
        sahne.x += (anlam.sayi ?? 0).toDouble();
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
        if (anlam.rastgeleAlt != null && anlam.rastgeleUst != null) {
          final alt = anlam.rastgeleAlt!.toInt();
          final ust = anlam.rastgeleUst!.toInt();
          final kaynak = rastgele ?? Random();
          sahne.soyledigi = '${alt + kaynak.nextInt((ust - alt) + 1)}';
        } else {
          sahne.soyledigi = anlam.metin;
        }
      case BlokKomutu.sonrakiKostum:
        sahne.kostum++;
      case BlokKomutu.yonAyarla:
        sahne.yon = (anlam.sayi ?? 90).toDouble() % 360;
      case BlokKomutu.don:
        // Scratch'te yon 0-360 arasinda dolasir.
        sahne.yon = (sahne.yon + (anlam.sayi ?? 0).toDouble()) % 360;
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
        break;
    }
  }
}
