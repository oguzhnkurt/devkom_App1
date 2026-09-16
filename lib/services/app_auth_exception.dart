/// Kullanıcıya gösterilebilir kimlik doğrulama hatası.
///
/// Neden ayrı bir tip: platformlar hatalarını geliştirici için yazıyor.
/// Apple `com.apple.AuthenticationServices.AuthorizationError hatası 1000`
/// diyor, Supabase `AuthApiException(statusCode: 400...)` diyor. Bunları
/// olduğu gibi ekrana basmak hem çocuğa hiçbir şey anlatmıyor hem de
/// uygulamayı amatör gösteriyor.
///
/// Kural: servis katmanı yalnızca bu tipi fırlatır ve içindeki [message]
/// doğrudan ekrana basılabilecek, Türkçe, ne yapılacağını söyleyen bir
/// cümledir. Teknik ayrıntı yalnızca [debugDetail] içinde kalır ve sadece
/// konsola yazılır.
class AppAuthException implements Exception {
  const AppAuthException(this.message, {this.debugDetail});

  /// Kullanıcıya gösterilecek cümle.
  final String message;

  /// Yalnızca loglara giden teknik ayrıntı.
  final String? debugDetail;

  @override
  String toString() => message;
}
