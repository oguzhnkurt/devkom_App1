/// Maskotun ruh hâlleri.
///
/// Gövdeden ve türden bağımsız: beş karakterin hepsi bu altı hâli
/// gösterebiliyor.
enum MascotMood {
  /// Bekliyor. Hafifçe nefes alıyor, arada göz kırpıyor.
  idle,

  /// Çocuk bir şeyle uğraşıyor. Kafa hafif yana eğik, bir kaş yukarıda.
  thinking,

  /// Oldu. Ağız geniş, gözler kısılmış.
  happy,

  /// Büyük an — ders bitti, rozet geldi. Zıplıyor.
  cheering,

  /// Olmadı ama sorun değil. DİKKAT: bu üzgün bir yüz DEĞİL — kaşlar
  /// hafif kalkık, ağız küçük ve yukarı kıvrık. "Devam et" diyen bir
  /// yüz, "hayal kırıklığına uğradım" diyen bir yüz değil.
  encouraging,

  /// Bir şey soruyor / gösteriyor. Gözler büyük, bir kaş kalkık.
  curious,
}
