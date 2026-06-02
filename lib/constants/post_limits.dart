/// Sosyal akış paylaşım limitleri
/// Veritabanı şişmesini önlemek için belirlenen limitler
class PostLimits {
  // Metin limitleri
  static const int maxDescriptionLength = 5000; // 5000 karakter
  static const int maxCommentLength = 500; // Yorumlar için 500 karakter

  // Fotoğraf limitleri
  static const int maxImageSizeMB = 5; // Maksimum 5MB (yüklemeden önce)
  static const int maxImageSizeBytes = maxImageSizeMB * 1024 * 1024; // 5MB in bytes

  // Resize ayarları (kalite kaybı minimum)
  static const int maxImageWidth = 1920; // Full HD genişlik
  static const int maxImageHeight = 1920; // Full HD yükseklik
  static const int imageQuality = 85; // 85% kalite (optimal)

  // Sıkıştırma sonrası hedef boyutlar
  static const int targetImageWidth = 1200; // Hedef genişlik
  static const int targetImageHeight = 1200; // Hedef yükseklik
  static const int compressQuality = 85; // Sıkıştırma kalitesi

  // Kullanıcı başına günlük limitler
  static const int studentMaxPostsPerDay = 3; // Öğrenci: Günde 3 paylaşım
  static const int parentMaxPostsPerDay = 3; // Veli: Günde 3 paylaşım
  static const int teacherMaxPostsPerDay = -1; // Öğretmen: Sınırsız (-1)
  static const int adminMaxPostsPerDay = -1; // Admin: Sınırsız (-1)
  static const int maxImagesPerPost = 1; // Post başına 1 fotoğraf

  // Video desteği (şu an kapalı)
  static const bool videoEnabled = false; // Video paylaşımı kapalı

  /// Karakter limiti mesajı
  static String getDescriptionLimitMessage() {
    return 'Açıklama en fazla $maxDescriptionLength karakter olabilir';
  }

  /// Yorum limiti mesajı
  static String getCommentLimitMessage() {
    return 'Yorum en fazla $maxCommentLength karakter olabilir';
  }

  /// Fotoğraf boyutu mesajı
  static String getImageSizeLimitMessage() {
    return 'Fotoğraf boyutu en fazla ${maxImageSizeMB}MB olabilir';
  }

  /// Kalan karakter sayısını hesapla
  static int getRemainingCharacters(String text, int maxLength) {
    return maxLength - text.length;
  }

  /// Karakter limiti aşıldı mı kontrol et
  static bool isDescriptionLimitExceeded(String text) {
    return text.length > maxDescriptionLength;
  }

  /// Yorum limiti aşıldı mı kontrol et
  static bool isCommentLimitExceeded(String text) {
    return text.length > maxCommentLength;
  }

  /// Fotoğraf boyutu limiti aşıldı mı kontrol et
  static bool isImageSizeLimitExceeded(int fileSizeBytes) {
    return fileSizeBytes > maxImageSizeBytes;
  }

  /// Rol bazlı günlük paylaşım limiti
  static int getMaxPostsPerDayForRole(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return studentMaxPostsPerDay;
      case 'parent':
        return parentMaxPostsPerDay;
      case 'teacher':
        return teacherMaxPostsPerDay;
      case 'admin':
        return adminMaxPostsPerDay;
      default:
        return studentMaxPostsPerDay; // Varsayılan: öğrenci limiti
    }
  }

  /// Günlük limit mesajı
  static String getDailyLimitMessage(String role, int limit) {
    if (limit < 0) {
      return 'Sınırsız paylaşım hakkınız var';
    }
    return 'Günlük paylaşım limitiniz: $limit';
  }

  /// Günlük limit aşıldı mesajı
  static String getDailyLimitExceededMessage(int limit) {
    return 'Günlük paylaşım limitiniz ($limit) dolmuştur. Yarın tekrar deneyin.';
  }
}
