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
  soyle,

  /// `%1 saniye bekle`
  bekle,

  /// `%1 degiskenini %2 yap`
  degiskenAta,

  /// `%1 i %2 kadar degistir`
  degiskenArtir,

  /// `%1 defa tekrarla` — C blogu, govdesi kendinden sonraki bloklar.
  tekrarla,

  /// `surekli tekrarla` — C blogu. Bitmez; adim butcesi durdurur.
  surekli,

  /// `eger <...> ise` — C blogu. Kosul simdilik DOGRU sayiliyor
  /// (bkz. BlokYorumlayici).
  eger,

  /// Gorunur bir etkisi olmayan ama akista yeri olan bloklar: haber
  /// salma, ikiz yaratma, ses. Adi soyleniyor, sahne degismiyor.
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

  bool get cBlogu =>
      komut == BlokKomutu.tekrarla ||
      komut == BlokKomutu.surekli ||
      komut == BlokKomutu.eger;
}
