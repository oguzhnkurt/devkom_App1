/// Google ile giris ayarlari.
///
/// Android'de Google ile giris Credential Manager uzerinden calisiyor ve
/// yalnizca bir sey istiyor: Google Cloud'da acilmis **Web** OAuth
/// istemcisinin kimligi (`serverClientId`). Uretilen id_token'in hedefi
/// (aud) bu kimlik oluyor; Supabase da token'i bu kimlikle dogruluyor.
///
/// Android OAuth istemcisi (paket adi + imza SHA-1) Google Cloud'da ayrica
/// tanimli olmali ama koda girmiyor; Google cihazdaki imzayla eslestiriyor.
///
/// Istemci kimligi gizli DEGIL (her kullanicinin cihazindaki token'da
/// yaziyor); `.env`'e degil buraya konuyor. Bos oldugu surece giris
/// ekraninda Google dugmesi hic gorunmuyor - yarim kurulum kullaniciya
/// bozuk bir dugme olarak cikmasin.
class GoogleConfig {
  GoogleConfig._();

  /// Google Cloud → APIs & Services → Credentials → OAuth 2.0 Client IDs →
  /// "Web application" turundeki istemcinin kimligi.
  /// Ornek bicim: 1234567890-abc123.apps.googleusercontent.com
  static const String webClientId =
      '995598800817-hsi2cf9b45495f9gu5m85pbsd5aimlie.apps.googleusercontent.com';

  static bool get hazir => webClientId.trim().isNotEmpty;
}
