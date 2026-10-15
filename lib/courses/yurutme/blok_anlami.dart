/// Bir blogun NE YAPTIGI.
///
/// NEDEN AYRI BIR SEY
///
/// Mevcut oynatici (`lib/widgets/block_animation_player.dart`) blogun ne
/// yaptigini KIMLIGINDEN TAHMIN ediyor: `id.startsWith('move_')`,
/// `id.contains('score')`. Bu, calistirmak degil ad esletirmek. Oyle bir
/// oynatici `4 defa tekrarla` blogunun dorde kadar saydigini bilemez,
/// `Puan i 1 kadar degistir` blogundan sonra puanin kac oldugunu
/// soyleyemez, `eger <bosluk basildi> ise` blogunun kosulunu
/// degerlendiremez. Cocuga "kodun calisti" diyen ama kodu calistirmayan
/// bir ekran cikiyor.
///
/// Burada anlam TAHMIN EDILMIYOR, YAZILIYOR: her blok kimligi bir komuta
/// ve argumanlarina acikca bagli. Bir blogun anlami yoksa yorumlayici
/// onu uyduracagina "bu blogun gorunur bir etkisi yok" diyor ve gecerken
/// adini soyluyor — yani sessizce atlamiyor da, yalan da soylemiyor.
library;

/// Yorumlayicinin anladigi islemler.
enum BlokKomutu {
  /// Olay sapkasi: `yesil bayraga tiklandiginda`. Calistirmayi baslatir,
  /// gorunur bir etkisi yoktur.
  baslat,

  /// `%1 adim git`
  ilerle,

  /// `x konumunu %1 degistir`
  xDegistir,

  /// `y konumunu %1 degistir`
  yDegistir,

  /// `x: %1 y: %2 konumuna git`
  gitXY,

  /// `%1 de`
  ///
  /// [BlokAnlami.rastgeleAlt] ve [BlokAnlami.rastgeleUst] doluysa
  /// soylenen sey SABIT DEGIL: her calistirmada o araliktan yeni bir
  /// sayi seciliyor. "1 ile 6 arasinda rastgele bir sayi sec de"
  /// blogunun butun dersi bu — ekranda hep ayni sayi cikarsa ders
  /// kendi anlattigi seyi yalanlar.
  soyle,

  /// `%1 saniye bekle`
  bekle,

  /// `%1 degiskenini %2 yap`
  degiskenAta,

  /// `%1 i %2 kadar degistir`
  degiskenArtir,

  /// `↻ %1 derece don` — bulundugu yonden %1 kadar doner.
  don,

  /// `%1 yonune don` — yonu dogrudan %1 yapar (goreli degil, MUTLAK).
  yonAyarla,

  /// `sonraki kostum` — kuklanin kostum sirasini bir arttirir.
  sonrakiKostum,

  /// `kalem indir` / `kalem kaldir` / `sil`
  kalemIndir,
  kalemKaldir,
  kalemSil,

  /// `%1 i %2 ye ekle` — listeye oge ekler.
  listeyeEkle,

  /// `%2 in %1 ini sil` — listeden oge cikarir.
  listedenSil,

  /// `%1 defa tekrarla` — C blogu, govdesi kendinden sonraki bloklar.
  tekrarla,

  /// `surekli tekrarla` — C blogu. Bitmez; adim butcesi durdurur.
  surekli,

  /// `eger <...> ise` — C blogu. Kosul [BlokAnlami.kosulDegisken] ile
  /// yazilmissa GERCEKTEN degerlendiriliyor (`puan < 5`); algilama
  /// kosullari (tus, degme) DOGRU sayiliyor (bkz. BlokYorumlayici).
  eger,

  /// `%1 i tanimla` — kendi blogunun sapkasi. Altindaki yigin kendi
  /// basina CALISMAZ; yalnizca [cagir] calistirir.
  tanimla,

  /// Kendi blogunun cagrisi (`kare`, `cokgen 6`). Tanimin govdesini
  /// [BlokAnlami.sayi] girdisiyle calistirir.
  cagir,

  /// `%1 haberini sal` — [BlokAnlami.haber]i alan betikleri calistirir.
  ///
  /// Eski (tek yiginli) yurutmede etkisi yok; Proje Atolyesi'nin cok
  /// betikli yurutmesinde ([BlokYorumlayici.yurutProje]) haberi alan
  /// betikler o anda calisiyor.
  haberSal,

  /// `rastgele konuma git` — sahnede rastgele bir yere gider.
  rastgeleKonum,

  /// Gorunur bir etkisi olmayan ama akista yeri olan bloklar: ikiz
  /// yaratma, ses. Adi soyleniyor, sahne degismiyor.
  etkisiz,
}

/// Bir blogun komutu ve argumanlari.
class BlokAnlami {
  const BlokAnlami(
    this.komut, {
    this.sayi,
    this.sayi2,
    this.metin,
    this.degisken,
    this.liste,
    this.rastgeleAlt,
    this.rastgeleUst,
    this.yordam,
    this.girdi,
    this.kosulDegisken,
    this.kosulIslem,
    this.kosulDeger,
    this.listeRastgele,
    this.haber,
    this.tus,
  });

  final BlokKomutu komut;

  /// Birinci sayisal arguman (adim sayisi, tekrar sayisi, deger...).
  final num? sayi;

  /// Ikinci sayisal arguman (gitXY'nin y'si).
  final num? sayi2;

  /// `soyle` icin sozun kendisi.
  final String? metin;

  /// Degisken adi.
  final String? degisken;

  /// Liste adi (`listeyeEkle`, `listedenSil`).
  final String? liste;

  /// `soyle` icin rastgele araligin alt ve ust siniri. Doluysa [metin]
  /// yok sayilir ve her calistirmada yeni bir sayi soylenir.
  final num? rastgeleAlt;
  final num? rastgeleUst;

  /// [tanimla] ve [cagir] icin kendi blogunun adi (`kare`, `cokgen`).
  final String? yordam;

  /// Kendi blogunun GIRDISI (`kenar`).
  ///
  /// * [tanimla]: tanimin girdisinin adi.
  /// * [tekrarla]: tur sayisi bu girdinin degeri ("kenar kere tekrarla").
  /// * [don]: aci [sayi] / girdi ("360 / kenar derece don").
  final String? girdi;

  /// [eger] icin degerlendirilebilen kosul: `kosulDegisken kosulIslem
  /// kosulDeger` (or. `Puan < 5`). Bos ise kosul bir algilama kosulu
  /// (tus, degme) ve yorumlayici onu DOGRU sayiyor.
  final String? kosulDegisken;

  /// '<', '>' ya da '='.
  final String? kosulIslem;
  final num? kosulDeger;

  /// [soyle] icin: bu listenin rastgele bir ogesi soyleniyor.
  final String? listeRastgele;

  /// [haberSal] ve haber sapkasi ([baslat]) icin haberin adi.
  final String? haber;

  /// Tus sapkasi ([baslat]) icin tusun adi (`space`, `right`...).
  final String? tus;

  /// Sapkanin olayi: bayrak (null), tus, haber ya da kuklaya tiklama.
  /// Yalnizca [baslat] icin anlamli.
  bool get bayrakSapkasi => komut == BlokKomutu.baslat && haber == null &&
      tus == null && !tiklama;

  /// `bu kuklaya tiklandiginda` sapkasi.
  bool get tiklama => komut == BlokKomutu.baslat && metin == 'tikla';

  /// Bu blogun sayisini cocuk degistirebilir mi (sayi tus takimi)?
  ///
  /// Yalnizca TEK sayili ve sayisi gercekten blogun anlami olan bloklar:
  /// `10 adim git`, `90 derece don`, `4 defa tekrarla`, `y'yi 10
  /// degistir`, `Puan i 1 kadar degistir`... Rastgele araligi, girdili
  /// (kenar) ya da iki sayili (x, y) bloklar degil.
  bool get sayiDuzenlenebilir {
    if (girdi != null || rastgeleAlt != null || sayi2 != null) return false;
    return switch (komut) {
      BlokKomutu.ilerle ||
      BlokKomutu.don ||
      BlokKomutu.yonAyarla ||
      BlokKomutu.xDegistir ||
      BlokKomutu.yDegistir ||
      BlokKomutu.degiskenAta ||
      BlokKomutu.degiskenArtir ||
      BlokKomutu.bekle =>
        true,
      BlokKomutu.tekrarla || BlokKomutu.cagir => sayi != null,
      _ => false,
    };
  }

  /// Ayni anlam, baska bir sayiyla (cocugun yazdigi sayi).
  BlokAnlami sayiIle(num yeni) => BlokAnlami(
        komut,
        sayi: yeni,
        sayi2: sayi2,
        metin: metin,
        degisken: degisken,
        liste: liste,
        rastgeleAlt: rastgeleAlt,
        rastgeleUst: rastgeleUst,
        yordam: yordam,
        girdi: girdi,
        kosulDegisken: kosulDegisken,
        kosulIslem: kosulIslem,
        kosulDeger: kosulDeger,
        listeRastgele: listeRastgele,
        haber: haber,
        tus: tus,
      );

  bool get cBlogu =>
      komut == BlokKomutu.tekrarla ||
      komut == BlokKomutu.surekli ||
      komut == BlokKomutu.eger;
}
