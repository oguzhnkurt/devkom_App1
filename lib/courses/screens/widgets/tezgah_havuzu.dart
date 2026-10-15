import 'package:flutter/foundation.dart';

/// Tek bir pahali nesneyi (mBlock tezgahinin WebView denetcisi) adimlar
/// arasinda paylastiran havuz.
///
/// NEDEN
/// -----
/// mBlock dersinde her blok kurma adimi yeni bir WebView aciyor ve
/// 2,1 MB'lik `scratch_blocks.min.js`'i bastan ayristiriyordu: her adimda
/// saniyelerce donen bir cark. Sayfa bir kez yuklenince ayni sayfaya
/// yalnizca yeni ayar (`MBlockTezgah.kur`) gondermek yetiyor.
///
/// SAHIPLIK: ayni denetci ayni anda IKI WebViewWidget'ta gosterilemez
/// (Android'de ayni yerel gorunum iki ebeveyne takilamaz). Yeni adim
/// denetciyi aldiginda eski sahibe [al]'daki `birakildi` ile haber
/// veriliyor; eski adim (cikis animasyonunda olabilir) WebView yerine
/// sade bir yer tutucu ciziyor. Yeni sahip WebView'i BIR KARE sonra
/// ciziyor ki eski gorunum agactan cikmis olsun.
///
/// Platformdan bagimsiz ve WebView'siz sinanabilsin diye genel:
/// test/mblock_tezgah_havuzu_test.dart sahte bir nesneyle sinar.
class TezgahHavuzu<T> {
  TezgahHavuzu(this._uret, {this.kapat});

  final T Function() _uret;

  /// Havuz sifirlanirken eski nesneyi kapatmak icin (istege bagli).
  final void Function(T nesne)? kapat;

  T? _nesne;
  Object? _sahip;
  VoidCallback? _birakildi;

  /// Kac kez yeni nesne uretildi (testler ve tanilama icin).
  int uretimSayisi = 0;

  /// Nesnenin sayfasi yuklendi mi (WebView: `onPageFinished`). Yeni
  /// nesnede false.
  bool sayfaYuklendi = false;

  T? get nesne => _nesne;
  Object? get sahip => _sahip;
  bool get bos => _sahip == null;

  T _yeni() {
    uretimSayisi++;
    sayfaYuklendi = false;
    return _uret();
  }

  /// Nesneyi onceden uretir (ders acilisinda isitma). Sahip atamaz.
  T isit() => _nesne ??= _yeni();

  /// Nesneyi [sahip]e verir; yoksa uretir. Baska bir sahip varsa ona
  /// `birakildi` ile haber verilir.
  T al(Object sahip, {VoidCallback? birakildi}) {
    final n = _nesne ??= _yeni();
    final eski = _sahip;
    if (eski != null && !identical(eski, sahip)) {
      final haber = _birakildi;
      _sahip = null;
      _birakildi = null;
      haber?.call();
    }
    _sahip = sahip;
    _birakildi = birakildi;
    return n;
  }

  /// [sahip] nesneyi birakiyor. Nesne baska birine gecmisse hicbir sey
  /// olmaz (gec gelen dispose yeni sahibi dusurmesin).
  void birak(Object sahip) {
    if (!identical(_sahip, sahip)) return;
    _sahip = null;
    _birakildi = null;
  }

  /// Nesneyi atar (hata sonrasi yeniden deneme, dersten cikis). Sahip
  /// varsa ona da haber verilir.
  void sifirla() {
    final n = _nesne;
    final haber = _birakildi;
    _nesne = null;
    _sahip = null;
    _birakildi = null;
    sayfaYuklendi = false;
    if (n != null) kapat?.call(n);
    haber?.call();
  }
}
