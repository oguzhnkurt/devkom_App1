part of 'blok_yorumlayici.dart';

/// PROJE MOTORU — Scratch gibi ESZAMANLI calisan betikler.
///
/// ONCEKI HAL. Proje Atolyesi'nin betikleri birbiri ardina calisiyordu:
/// once bayrak betikleri, sonra her tus betigi bir kez, haber alicilari
/// haberin salindigi anda. Iki `surekli tekrarla` ayni anda donemiyordu;
/// "degiyor mu?" kosullari hep DOGRU sayiliyordu; ikiz yoktu. 3.1 ve
/// 5.1 bu yuzden tek kuklayla kuruluyor, "bilgisayarda devam et" diyordu.
///
/// SIMDI. Her betik bir IS PARCACIGI (`_Is`). Motor Scratch'in kare
/// mantigiyla ilerliyor ([kareHizi] = 30 kare/saniye): her karede
/// butun isler sirayla bir kez calisiyor ve su noktalarda SIRAYI
/// birakiyor:
///
///  * bir dongunun (tekrarla / surekli tekrarla) her turunun sonunda,
///  * `bekle` blogunda (sanal saat [zaman] dolana kadar),
///  * `kay` blogunda (kukla kareler boyunca kayiyor),
///  * `haberini sal ve bekle`de (alicilarin hepsi bitene kadar),
///  * nota/ses bloklarinda (notanin suresi kadar).
///
/// Scratch'ten tek bilincli fark: Scratch bir karede ekran degismedikce
/// donguyu ayni karede tekrar tekrar dondurebiliyor (turbo olmayan
/// modda bile). Burada her tur bir kare: cocuk "4 defa tekrarla"nin dort
/// tur dondugunu sahnede goruyor.
///
/// HABER: `haberini sal` alici betikleri baslatir (ayni betik zaten
/// calisiyorsa bastan baslar — Scratch da boyle); salan betik devam
/// eder, alicilar AYNI karede, sirada ondan sonra calisir.
///
/// TUS VE TIKLAMA: [tusBas] o tusun sapkalarini baslatir ve tusu basili
/// tutar (`... tusu basili mi?` bunu okur); [tusBirak] birakir. [tikla]
/// sahnede bir noktaya dokunur: ustteki kuklanin "bu kuklaya
/// tiklandiginda" betikleri baslar, nokta "fare imleci" olur. Atolyede
/// sahnenin altindaki tus dugmeleri bunlari cagiriyor. Kimse dokunmazsa
/// [OtomatikOyuncu] basiyor (testler ve hedef denetimi de onunla
/// calisiyor; sonuc belirlenimci).
///
/// DEGME (bkz. [_degiyor]): her kukla bir DAIRE ([KuklaTanimi.yaricap],
/// Scratch koordinatinda). Iki kukla, merkezleri arasindaki uzaklik
/// yaricaplar toplaminin [degmePayi] katindan kucukse degiyor (kuklalar
/// tam daire degil; kenarlarindaki bosluk icin pay). Kenar: daire sahne
/// dikdortgeninden (480 x 360) tasiyor. Fare imleci: son dokunulan nokta
/// dairenin icinde (dokunulmadiysa yanlis). RENK: sahnede bilinen renkli
/// bolgeler var — `zemin` sahnenin altindaki yesil serit ([zeminY]'nin
/// alti); bir kuklanin [KuklaTanimi.renk]i varsa o renk o kuklanin
/// dairesi. Gizli kukla hicbir seye degmiyor.
///
/// IKIZLER: `kendimin ikizini yarat` kuklanin o anki halini kopyaliyor ve
/// ikizin "ikiz olarak basladigimda" betiklerini baslatiyor; `bu ikizi
/// sil` ikizi ve betiklerini bitiriyor. En fazla [enFazlaIkiz] ikiz
/// (Scratch'te 300; cocuk sahnesi icin 30).
///
/// SINIRLAR: bir is bir karede en fazla [kareBasinaEnFazlaAdim] blok
/// calistirir (dongusuz sonsuz zincir olmaz ama yine de); butun yurutme
/// en fazla [enFazlaAdim] blok ve [sureSiniri] sanal saniye. `surekli
/// tekrarla` bu sinira kadar doner; [Yurutme.butceBitti] bunu soyler.
///
/// Yurutme bitince ([bitti]): `tumunu durdur` calisti, sure ya da adim
/// siniri doldu, ya da cocugun kuklasinin hicbir betigi calismiyor ve
/// otomatik oyuncunun basacagi tus kalmadi (cocuk kendisi oynuyorsa son
/// dokunustan [elleBeklemeKaresi] kare sonra). Hazir kodlu kuklalarin
/// (Fare, Kase) `surekli tekrarla`si yurutmeyi tek basina ayakta tutmuyor.
class ProjeMotoru {
  ProjeMotoru({
    required BlokYorumlayici yorumlayici,
    required List<ScratchBlock> bloklar,
    KuklaTanimi ana = KuklaTanimi.devi,
    List<KuklaTanimi> kuklalar = const [],
    this.oyuncu = const OtomatikOyuncu(),
    this.sureSiniri = varsayilanSure,
    this.otomatikGecikme = 15,
  }) : _y = BlokYorumlayici(
          butce: yorumlayici.butce,
          dil: yorumlayici.dil,
          // Tek bir kaynak: ayni tohum ayni yurutme.
          rastgele: yorumlayici.rastgele ?? Random(),
        ) {
    final anaProgram = _Program.coz(bloklar);
    _sapkasiz = anaProgram.sapkasiz;
    _ana = SahneKuklasi._(ana, _yeniSahne(ana), anaProgram, _sayac++,
        ana: true);
    _kuklalar.add(_ana);
    for (final t in kuklalar) {
      _kuklalar.add(SahneKuklasi._(
          t, _yeniSahne(t), _Program.coz(t.bloklar), _sayac++));
    }
    _tuslariTopla();
  }

  /// Saniyedeki kare sayisi (Scratch: 30).
  static const int kareHizi = 30;

  /// Varsayilan sure siniri (sanal saniye).
  static const double varsayilanSure = 10;

  /// Bir isin bir karede calistirabilecegi en fazla blok.
  static const int kareBasinaEnFazlaAdim = 500;

  /// Butun yurutmede en fazla blok.
  static const int enFazlaAdim = 40000;

  /// Izde tutulan en fazla adim (sonrasi sayilmaya devam ediyor ama
  /// sahne kopyasi tutulmuyor).
  static const int izSiniri = 12000;

  /// Ayni anda en fazla ikiz.
  static const int enFazlaIkiz = 30;

  /// Bir kuklanin varsayilan yaricapi (Scratch koordinati).
  static const double varsayilanYaricap = 30;

  /// Degme payi: kuklalar tam daire degil.
  static const double degmePayi = 0.85;

  /// Zemin seridinin ust siniri (Scratch y'si). Sahnede bu cizginin
  /// alti yesil; `renk:zemin` buna bakiyor.
  static const double zeminY = -150;

  /// Cocuk kendisi oynuyorsa (bir tusa bastiysa) yurutme, betikleri
  /// bittikten sonra bu kadar kare daha bekliyor.
  static const int elleBeklemeKaresi = 90;

  final BlokYorumlayici _y;
  final OtomatikOyuncu oyuncu;
  final double sureSiniri;

  /// Otomatik oyuncu bu kadar kare bekledikten sonra basmaya basliyor
  /// (canli sahnede cocuga once kendisi basma firsati).
  final int otomatikGecikme;

  final _Baglam _b = _Baglam(0);
  final List<YurutmeAdimi> _adimlar = [];
  final List<SahneKuklasi> _kuklalar = [];
  late final SahneKuklasi _ana;
  final Map<String, num> _degiskenler = {};
  final Map<String, List<String>> _listeler = {};
  final List<_Is> _isler = [];
  final Set<String> _basili = {};
  final List<String> _tuslar = [];
  var _sapkasiz = 0;
  var _sayac = 0;
  var _kare = 0;
  var _toplamAdim = 0;
  var _bitti = false;
  var _butceBitti = false;
  var _durduruldu = false;
  var _elleDurdu = false;
  var _elle = false;
  var _sonElleKare = 0;
  var _klonSayisi = 0;
  var _silinenKlon = 0;
  var _canliIkiz = 0;
  var _tiklamaVar = false;
  var _fareImleciVar = false;
  var _sonKareMesgul = false;
  var _mesgulKare = 0;
  int? _calisanSira;
  Offset? _fare;

  // ------------------------------------------------------------------
  // Disaridan okunan durum (sahne bunlari ciziyor)
  // ------------------------------------------------------------------

  /// Cizim sirasina gore kuklalar (once arkadakiler). Ikizler asil
  /// kuklanin hemen arkasinda.
  List<SahneKuklasi> get kuklalar => _kuklalar;

  /// Kalemin cizdigi parcalar.
  List<KalemCizgisi> get cizgiler => _b.cizgiler;

  /// Ortak degiskenler (sahnedeki "Puan 3" gostergesi).
  Map<String, num> get degiskenler => _degiskenler;

  /// Cocugun kuklasinin (ya da ikizinin) en son calistirdigi blogun kod
  /// alanindaki sirasi.
  int? get calisanSira => _calisanSira;

  /// Gecen kare sayisi ve sanal saat (saniye).
  int get kareNo => _kare;
  double get zaman => _kare / kareHizi;

  bool get bitti => _bitti;
  bool get butceBitti => _butceBitti;

  /// `tumunu durdur` calisti.
  bool get durduruldu => _durduruldu;

  /// Cocuk kirmizi "dur"a basti.
  bool get elleDurdu => _elleDurdu;

  /// Programin kullandigi tuslar (sapka ve "basili mi?"), kod sirasiyla.
  List<String> get tuslar => _tuslar;

  /// Su an basili tuslar.
  Set<String> get basili => _basili;

  /// Program cocugun dokunmasini bekleyebilir mi (tus, tiklama, imlec)?
  bool get etkilesimli => _tuslar.isNotEmpty || _tiklamaVar || _fareImleciVar;

  /// Tuslara su an otomatik oyuncu mu basiyor (cocuk henuz dokunmadi)?
  bool get otomatikOynuyor =>
      etkilesimli && !_elle && !_bitti && _kare >= otomatikGecikme;

  /// Cocuk en az bir kez kendisi dokundu.
  bool get elleOynandi => _elle;

  /// Son karede bir blok calisti mi (yalnizca bekleme degil)?
  bool get sonKareMesgul => _sonKareMesgul;

  /// Blok calistiran kare sayisi.
  int get mesgulKare => _mesgulKare;

  /// Su an sahnedeki ikiz sayisi.
  int get canliIkiz => _canliIkiz;

  Sahne _yeniSahne(KuklaTanimi t) => Sahne(
        x: t.x,
        y: t.y,
        yon: t.yon,
        gorunur: !t.gizli,
        degiskenler: _degiskenler,
        listeler: _listeler,
      );

  void _tuslariTopla() {
    for (final k in _kuklalar) {
      for (final s in k._program.satirlar) {
        final a = BlokYorumlayici.anlamOf(s.blok);
        if (a.komut == BlokKomutu.baslat && a.tus != null) {
          if (!_tuslar.contains(a.tus)) _tuslar.add(a.tus!);
        }
        if (a.tiklama) _tiklamaVar = true;
        final algi = a.algi;
        if (algi != null && algi.startsWith('tus:')) {
          final t = algi.substring(4);
          if (!_tuslar.contains(t)) _tuslar.add(t);
        }
        if (algi == 'degiyor:fare-imleci') _fareImleciVar = true;
      }
    }
  }

  // ------------------------------------------------------------------
  // Olaylar
  // ------------------------------------------------------------------

  /// Yesil bayrak: her kuklanin bayrak betikleri (once cocugun kuklasi).
  void baslat() {
    for (final k in List.of(_kuklalar)) {
      for (final b in k._program.betikler) {
        if (b.sapka?.bayrakSapkasi ?? false) _baslatIs(k, b, 'bayrak');
      }
    }
  }

  /// Bir tusa basildi. [elle]: cocuk basti (otomatik oyuncu susar).
  void tusBas(String tus, {bool elle = true}) {
    if (_bitti) return;
    if (elle) _elleGirdi();
    if (!_basili.add(tus)) return;
    for (final k in List.of(_kuklalar)) {
      for (final b in k._program.betikler) {
        if (b.sapka?.tus != tus) continue;
        // Tus sapkasi calisan betigi bastan baslatmiyor (Scratch).
        if (_isler.any((t) => !t.bitti && t.kukla == k && t.betik == b)) {
          continue;
        }
        _baslatIs(k, b, 'tus:$tus');
      }
    }
  }

  void tusBirak(String tus, {bool elle = true}) {
    if (elle) _elleGirdi();
    _basili.remove(tus);
  }

  /// Sahnede (x, y) noktasina dokunuldu (Scratch koordinati).
  void tikla(double x, double y, {bool elle = true}) {
    if (_bitti) return;
    if (elle) _elleGirdi();
    _fare = Offset(x, y);
    for (final k in _kuklalar.reversed) {
      if (!k.sahne.gorunur || k.silindi) continue;
      final dx = k.sahne.x - x, dy = k.sahne.y - y;
      if (dx * dx + dy * dy > k.yaricap * k.yaricap) continue;
      for (final b in k._program.betikler) {
        if (b.sapka?.tiklama ?? false) _baslatIs(k, b, 'tikla', yeniden: true);
      }
      return;
    }
  }

  void _elleGirdi() {
    _elle = true;
    _sonElleKare = _kare;
    // Otomatik oyuncunun basili biraktigi tuslar birakiliyor.
    if (_otomatikBasili.isNotEmpty) {
      _basili.removeAll(_otomatikBasili);
      _otomatikBasili.clear();
    }
  }

  /// Yurutmeyi BITMIS sayar (cocuk durdurmadi): sahne hedefler
  /// saglaninca oyunu boyle bitiriyor.
  void tamamla() {
    if (_bitti) return;
    _bitir();
  }

  /// Kirmizi dur.
  void durdur() {
    if (_bitti) return;
    _elleDurdu = true;
    _bitir();
  }

  _Is _baslatIs(SahneKuklasi k, _Betik b, String olay,
      {bool yeniden = false}) {
    if (yeniden) {
      for (final t in _isler) {
        if (t.kukla == k && t.betik == b) t.bitti = true;
      }
    }
    final t = _Is(k, b, olay);
    _isler.add(t);
    if (k.ana) _b.calisanOlaylar.add(olay);
    return t;
  }

  /// Haberi alan betikleri baslatir; baslayan isleri dondurur.
  List<_Is> _haberSal(String? haber) {
    final yeni = <_Is>[];
    if (haber == null) return yeni;
    for (final k in List.of(_kuklalar)) {
      if (k.silindi) continue;
      for (final b in k._program.betikler) {
        if (b.sapka?.haber != haber) continue;
        _b.alinanHaberler.add(haber);
        yeni.add(_baslatIs(k, b, 'haber:$haber', yeniden: true));
      }
    }
    return yeni;
  }

  void _ikizYarat(SahneKuklasi k) {
    if (_canliIkiz >= enFazlaIkiz) return;
    final s = k.sahne;
    final ikiz = SahneKuklasi._(
      k.tanim,
      Sahne(
        x: s.x,
        y: s.y,
        kostum: s.kostum,
        yon: s.yon,
        kalemInik: s.kalemInik,
        gorunur: s.gorunur,
        degiskenler: _degiskenler,
        listeler: _listeler,
      ),
      k._program,
      _sayac++,
      ana: k.ana,
      klon: true,
    );
    // Ikiz asil kuklanin hemen ARKASINDA (Scratch da oyle ciziyor).
    _kuklalar.insert(_kuklalar.indexOf(k), ikiz);
    _canliIkiz++;
    if (k.ana) _klonSayisi++;
    for (final b in k._program.betikler) {
      if (b.sapka?.ikizSapkasi ?? false) _baslatIs(ikiz, b, 'ikiz');
    }
  }

  void _ikiziSil(SahneKuklasi k) {
    if (!k.klon || k.silindi) return;
    k.silindi = true;
    _kuklalar.remove(k);
    _canliIkiz--;
    if (k.ana) _silinenKlon++;
    for (final t in _isler) {
      if (t.kukla == k) t.bitti = true;
    }
  }

  void _hepsiniDurdur() {
    _durduruldu = true;
    _bitir();
  }

  void _bitir() {
    _bitti = true;
    for (final t in _isler) {
      t.bitti = true;
    }
    _isler.clear();
    _basili.clear();
    _calisanSira = null;
  }

  // ------------------------------------------------------------------
  // Otomatik oyuncu
  // ------------------------------------------------------------------

  final Set<String> _otomatikBasili = {};

  /// Varsayilan oyuncunun bitis karesi (sonrasinda basacak tus yok).
  int get _otomatikSon => oyuncu.takipEden != null
      ? 0
      : otomatikGecikme + _tuslar.length * 12 + (_tiklamaVar ? 12 : 0);

  void _otomatik() {
    if (_elle || !etkilesimli || _kare < otomatikGecikme) return;
    if (oyuncu.takipEden != null) {
      _takipEt();
      return;
    }
    // Her tusa sirayla bir kez: 12 karede bir, 6 kare basili.
    final n = _kare - otomatikGecikme;
    final i = n ~/ 12, faz = n % 12;
    if (i < _tuslar.length) {
      final tus = _tuslar[i];
      if (faz == 0) {
        _otomatikBasili.add(tus);
        tusBas(tus, elle: false);
      } else if (faz == 6) {
        _otomatikBasili.remove(tus);
        tusBirak(tus, elle: false);
      }
    } else if (i == _tuslar.length && faz == 0 && _tiklamaVar) {
      tikla(_ana.sahne.x, _ana.sahne.y, elle: false);
    }
  }

  /// Takip: [OtomatikOyuncu.takipEden] kuklasi sol/sag oklarla en alttaki
  /// [OtomatikOyuncu.hedef] kuklasinin (ya da ikizinin) altina gidiyor.
  void _takipEt() {
    SahneKuklasi? kim;
    for (final k in _kuklalar) {
      if (k.tanim.ad == oyuncu.takipEden && !k.klon) kim = k;
    }
    if (kim == null) return;
    SahneKuklasi? hedef;
    for (final k in _kuklalar) {
      if (k.tanim.ad != oyuncu.hedef || !k.sahne.gorunur || k.silindi) {
        continue;
      }
      if (k.sahne.y < kim.sahne.y) continue;
      if (hedef == null || k.sahne.y < hedef.sahne.y) hedef = k;
    }
    String? tus;
    if (hedef != null) {
      final fark = hedef.sahne.x - kim.sahne.x;
      if (fark > 5) tus = 'right';
      if (fark < -5) tus = 'left';
    }
    for (final t in ['left', 'right']) {
      if (t == tus) {
        if (_otomatikBasili.add(t)) tusBas(t, elle: false);
      } else if (_otomatikBasili.remove(t)) {
        tusBirak(t, elle: false);
      }
    }
  }

  // ------------------------------------------------------------------
  // Kare
  // ------------------------------------------------------------------

  /// Bir kare ilerler: butun isler sirayla bir kez.
  void kare() {
    if (_bitti) return;
    _otomatik();
    final once = _toplamAdim;
    // Yeni baslayan isler (haber, ikiz) listenin sonuna ekleniyor ve AYNI
    // karede calisiyor.
    for (var i = 0; i < _isler.length && !_bitti; i++) {
      final t = _isler[i];
      if (!t.bitti) _calistir(t);
    }
    if (_bitti) return;
    _isler.removeWhere((t) => t.bitti);
    _sonKareMesgul = _toplamAdim > once;
    if (_sonKareMesgul) _mesgulKare++;
    _kare++;

    final anaCalisiyor = _isler.any((t) => t.kukla.ana);
    if (_toplamAdim >= enFazlaAdim || zaman >= sureSiniri) {
      _butceBitti = anaCalisiyor;
      _bitir();
    } else if (!anaCalisiyor) {
      final bekle = _elle
          ? _kare - _sonElleKare < elleBeklemeKaresi && etkilesimli
          : etkilesimli && _kare <= _otomatikSon;
      if (!bekle) _bitir();
    }
  }

  void _calistir(_Is t) {
    if (t.bekleBitis >= 0) {
      if (zaman + 1e-9 < t.bekleBitis) return;
      t.bekleBitis = -1;
    }
    if (t.kayma != null && !_kay(t)) return;
    if (t.beklenen != null) {
      if (t.beklenen!.any((b) => !b.bitti)) return;
      t.beklenen = null;
    }
    var n = 0;
    while (!t.bitti && !_bitti) {
      if (t.yigin.isEmpty) {
        t.bitti = true;
        return;
      }
      final c = t.yigin.last;
      if (c.i >= c.dilim.length) {
        if (c.dongu) {
          c.tur++;
          if (c.turSayisi < 0 || c.tur <= c.turSayisi) {
            c.i = 0;
            return; // her turun sonunda sira bir sonraki ise
          }
        }
        t.yigin.removeLast();
        continue;
      }
      if (++n > kareBasinaEnFazlaAdim || _toplamAdim >= enFazlaAdim) return;
      final d = c.dilim[c.i++];
      if (_dugum(t, c, d)) return;
    }
  }

  /// Bir dugumu calistirir; `true`: is bu karede sirayi birakiyor.
  bool _dugum(_Is t, _Cerceve c, _Dugum d) {
    final blok = d.satir.blok;
    if (KodYapisi.isaretMi(blok.id)) return false;
    final anlam = BlokYorumlayici.anlamOf(blok);
    final k = t.kukla;
    _toplamAdim++;

    if (anlam.cBlogu) {
      final govde = d.govde ?? const <_Dugum>[];
      if (anlam.komut == BlokKomutu.eger) {
        final kosul = _kosul(anlam, k);
        _kaydet(t, c, d, anlam, kosul: kosul, olayBlogu: false);
        final kol = (kosul ?? true) ? govde : d.degilse;
        if (kol != null && kol.isNotEmpty) {
          t.yigin.add(_Cerceve(kol, c.derinlik + 1,
              tekrarNo: c.no,
              girdiler: c.girdiler,
              cagriDerinligi: c.cagriDerinligi));
        }
        return false;
      }
      _kaydet(t, c, d, anlam, olayBlogu: false);
      final tur = anlam.komut == BlokKomutu.tekrarla
          ? (anlam.girdi != null
              ? (c.girdiler[anlam.girdi] ?? 0).toInt()
              : (anlam.sayi ?? 1).toInt())
          : -1;
      if (tur == 0 || (tur > 0 && govde.isEmpty)) return false;
      t.yigin.add(_Cerceve(govde, c.derinlik + 1,
          dongu: true,
          turSayisi: tur,
          girdiler: c.girdiler,
          cagriDerinligi: c.cagriDerinligi));
      return false;
    }

    switch (anlam.komut) {
      case BlokKomutu.cagir:
        _kaydet(t, c, d, anlam, etkisiz: true, olayBlogu: false);
        if (c.cagriDerinligi >= BlokYorumlayici._enFazlaCagriDerinligi) {
          return false;
        }
        final ad = anlam.yordam ?? '?';
        final List<_Dugum> govde;
        final String? girdiAdi;
        final kendi = k._program.tanimlar[ad];
        if (kendi != null) {
          govde = kendi.agac;
          girdiAdi = kendi.girdi;
        } else if (BlokYorumlayici.kutuphane[ad] case final hazir?) {
          girdiAdi = hazir.$1;
          govde = BlokYorumlayici._agac(
              [for (final b in hazir.$2) _Satir(b, d.satir.sira)]);
        } else {
          return false;
        }
        if (k.ana) _b.cagrilar.add((ad, anlam.sayi));
        t.yigin.add(_Cerceve(govde, c.derinlik + 1,
            tekrarNo: c.no,
            girdiler: {
              ...c.girdiler,
              if (girdiAdi != null && anlam.sayi != null)
                girdiAdi: anlam.sayi!,
            },
            cagriDerinligi: c.cagriDerinligi + 1));
        return false;
      case BlokKomutu.bekle:
        _kaydet(t, c, d, anlam);
        t.bekleBitis = zaman + max(0, (anlam.sayi ?? 0).toDouble());
        return true;
      case BlokKomutu.kaydir:
        _kaydet(t, c, d, anlam);
        t.kayma = _Kayma(
          k.sahne.x,
          k.sahne.y,
          (anlam.sayi ?? 0).toDouble(),
          (anlam.sayi2 ?? 0).toDouble(),
          zaman,
          (anlam.saniye ?? 1).toDouble(),
        );
        return true;
      case BlokKomutu.ses:
        final sure = anlam.saniye?.toDouble();
        k.notaBitis = zaman + max(0.4, sure ?? 0.4);
        _kaydet(t, c, d, anlam);
        if (sure == null) return false;
        t.bekleBitis = zaman + sure;
        return true;
      case BlokKomutu.haberSal:
        _kaydet(t, c, d, anlam, etkisiz: true);
        _haberSal(anlam.haber);
        return false;
      case BlokKomutu.haberSalBekle:
        _kaydet(t, c, d, anlam, etkisiz: true);
        t.beklenen = _haberSal(anlam.haber);
        return true;
      case BlokKomutu.ikizYarat:
        _kaydet(t, c, d, anlam);
        _ikizYarat(k);
        return false;
      case BlokKomutu.ikizSil:
        _kaydet(t, c, d, anlam);
        if (!k.klon) return false;
        _ikiziSil(k);
        return true;
      case BlokKomutu.durdurHepsi:
        _kaydet(t, c, d, anlam);
        _hepsiniDurdur();
        return true;
      case BlokKomutu.yoneDogru:
        _yoneDogru(k, anlam.kukla);
        _kaydet(t, c, d, anlam);
        return false;
      case BlokKomutu.kenardaSek:
        BlokYorumlayici.sek(k.sahne, k.yaricap);
        _kaydet(t, c, d, anlam);
        return false;
      default:
        final s = k.sahne;
        final x0 = s.x, y0 = s.y;
        _y._uygulaYalin(anlam, s, c.girdiler, _b);
        _cizgi(k, x0, y0);
        if (anlam.komut == BlokKomutu.soyle && s.soyledigi != null && k.ana) {
          _b.soylenenler.add(s.soyledigi!);
        }
        _kaydet(t, c, d, anlam,
            etkisiz: anlam.komut == BlokKomutu.etkisiz ||
                anlam.komut == BlokKomutu.baslat);
        return false;
    }
  }

  /// Kalem inikse kuklanin gittigi yol cizgi olarak kaliyor.
  void _cizgi(SahneKuklasi k, double x0, double y0) {
    final s = k.sahne;
    if (s.kalemInik && (s.x != x0 || s.y != y0)) {
      _b.cizgiler.add(KalemCizgisi(x0, y0, s.x, s.y));
    }
  }

  /// Kayma: `true` kayma bitti, is devam edebilir.
  bool _kay(_Is t) {
    final m = t.kayma!;
    final s = t.kukla.sahne;
    final x0 = s.x, y0 = s.y;
    final f = m.sure <= 0 ? 1.0 : (zaman - m.bas) / m.sure;
    if (f >= 1) {
      s.x = m.x1;
      s.y = m.y1;
      t.kayma = null;
    } else {
      s.x = BlokYorumlayici._yuvarla(m.x0 + (m.x1 - m.x0) * f);
      s.y = BlokYorumlayici._yuvarla(m.y0 + (m.y1 - m.y0) * f);
    }
    _cizgi(t.kukla, x0, y0);
    return t.kayma == null;
  }

  void _yoneDogru(SahneKuklasi k, String? hedef) {
    double? hx, hy;
    if (hedef == 'fare-imleci') {
      hx = _fare?.dx;
      hy = _fare?.dy;
    } else {
      for (final o in _kuklalar) {
        if (o == k || o.tanim.ad != hedef || o.silindi) continue;
        if (o.klon) continue; // Scratch: asil kukla
        hx = o.sahne.x;
        hy = o.sahne.y;
        break;
      }
    }
    if (hx == null || hy == null) return;
    final dx = hx - k.sahne.x, dy = hy - k.sahne.y;
    if (dx == 0 && dy == 0) return;
    k.sahne.yon =
        BlokYorumlayici._yuvarla((atan2(dx, dy) * 180 / pi + 360) % 360);
  }

  // ------------------------------------------------------------------
  // Kosullar ve degme
  // ------------------------------------------------------------------

  bool? _kosul(BlokAnlami anlam, SahneKuklasi k) {
    final olculen = _y._kosul(anlam, k.sahne);
    if (olculen != null) return olculen;
    final a = anlam.algi;
    if (a == null) return null;
    if (a.startsWith('tus:')) {
      final tus = a.substring(4);
      return tus == 'any' ? _basili.isNotEmpty : _basili.contains(tus);
    }
    if (a.startsWith('degiyor:')) return _degiyor(k, a.substring(8));
    if (a.startsWith('renk:')) return _renge(k, a.substring(5));
    return null;
  }

  /// [k] kuklasi [ne]ye degiyor mu? (`kenar`, `fare-imleci` ya da bir
  /// kuklanin adi — o adli butun kuklalar ve ikizleri.)
  bool _degiyor(SahneKuklasi k, String ne) {
    final s = k.sahne;
    if (!s.gorunur || k.silindi) return false;
    final r = k.yaricap;
    if (ne == 'kenar') {
      return s.x - r <= -BlokYorumlayici.sahneYariGenislik ||
          s.x + r >= BlokYorumlayici.sahneYariGenislik ||
          s.y - r <= -BlokYorumlayici.sahneYariYukseklik ||
          s.y + r >= BlokYorumlayici.sahneYariYukseklik;
    }
    if (ne == 'fare-imleci') {
      final f = _fare;
      if (f == null) return false;
      final dx = f.dx - s.x, dy = f.dy - s.y;
      return dx * dx + dy * dy <= r * r;
    }
    for (final o in _kuklalar) {
      if (o == k || o.tanim.ad != ne) continue;
      if (_ust(k, o)) return true;
    }
    return false;
  }

  /// Iki kuklanin daireleri ortusuyor mu?
  bool _ust(SahneKuklasi a, SahneKuklasi b) {
    if (!a.sahne.gorunur || !b.sahne.gorunur || a.silindi || b.silindi) {
      return false;
    }
    final dx = a.sahne.x - b.sahne.x, dy = a.sahne.y - b.sahne.y;
    final r = (a.yaricap + b.yaricap) * degmePayi;
    return dx * dx + dy * dy < r * r;
  }

  /// Renk: `zemin` sahnenin altindaki yesil serit; diger renkler o renkte
  /// cizilen kuklalar ([KuklaTanimi.renk]).
  bool _renge(SahneKuklasi k, String renk) {
    final s = k.sahne;
    if (!s.gorunur || k.silindi) return false;
    if (renk == 'zemin') return s.y - k.yaricap * degmePayi <= zeminY;
    for (final o in _kuklalar) {
      if (o != k && o.tanim.renk == renk && _ust(k, o)) return true;
    }
    return false;
  }

  // ------------------------------------------------------------------
  // Iz
  // ------------------------------------------------------------------

  void _kaydet(_Is t, _Cerceve c, _Dugum d, BlokAnlami anlam,
      {bool? kosul, bool etkisiz = false, bool olayBlogu = true}) {
    final k = t.kukla;
    if (!k.ana) return; // hazir kodlu kuklalar izde yok
    final blok = d.satir.blok;
    _calisanSira = d.satir.sira;
    if (olayBlogu) _b.olayBloklari.putIfAbsent(t.olay, () => []).add(blok.id);
    if (_adimlar.length >= izSiniri) return;
    _adimlar.add(YurutmeAdimi(
      blokId: blok.id,
      derinlik: c.derinlik,
      sahne: k.sahne.kopya(),
      tekrarNo: c.no,
      etkisiz: etkisiz,
      blokSirasi: d.satir.sira,
      blok: blok,
      kosulSonucu: kosul,
      klon: k.klon,
    ));
  }

  /// Simdiye kadarki (ya da bitmis) yurutme.
  Yurutme sonuc() => Yurutme(
        adimlar: List.unmodifiable(_adimlar),
        sonSahne: _ana.sahne.kopya(),
        butceBitti: _butceBitti,
        yalnizTanim: _ana._program.betikler.isEmpty &&
            _ana._program.tanimlar.isNotEmpty,
        cizgiler: List.unmodifiable(_b.cizgiler),
        soylenenler: List.unmodifiable(_b.soylenenler),
        alinanHaberler: Set.unmodifiable(_b.alinanHaberler),
        calisanOlaylar: List.unmodifiable(_b.calisanOlaylar),
        cagrilar: List.unmodifiable(_b.cagrilar),
        sapkasizBlok: _sapkasiz,
        olayBloklari: {
          for (final e in _b.olayBloklari.entries) e.key: List.of(e.value)
        },
        klonSayisi: _klonSayisi,
        silinenKlon: _silinenKlon,
        sure: zaman,
        durduruldu: _durduruldu,
      );
}

/// Bir kuklanin gorunusu (sahne ciziyor).
enum KuklaGorunumu { devi, fare, elma, kase }

/// Kuklanin donus stili: Scratch'teki "her yone" ya da "sol-sag".
enum DonusStili { herYone, solSag }

/// Sahnedeki bir kukla: adi, gorunusu, baslangici ve (hazir kodlu
/// kuklalarda) kodu.
class KuklaTanimi {
  const KuklaTanimi({
    required this.ad,
    this.gorunum = KuklaGorunumu.devi,
    this.x = 0,
    this.y = 0,
    this.yon = 90,
    this.yaricap = ProjeMotoru.varsayilanYaricap,
    this.gizli = false,
    this.renk,
    this.donusStili = DonusStili.herYone,
    this.kod = '',
    this.palet = const [],
    this.adEn,
    this.adDe,
    this.adEs,
  });

  /// Algilamadaki adi (`degiyor:Fare`). Turkce; ekranda [adFor].
  final String ad;
  final String? adEn, adDe, adEs;
  final KuklaGorunumu gorunum;
  final double x, y, yon;

  /// Degme dairesinin yaricapi (Scratch koordinati).
  final double yaricap;
  final bool gizli;

  /// "renge degiyor mu?" icin kuklanin rengi (`kase`).
  final String? renk;
  final DonusStili donusStili;

  /// Hazir kod (belirtec dizisi, bkz. [KodYapisi.coz]) ve bloklari.
  final String kod;
  final List<ScratchBlock> palet;

  String adFor(String lang) => switch (lang) {
        'en' => adEn ?? ad,
        'de' => adDe ?? adEn ?? ad,
        'es' => adEs ?? adEn ?? ad,
        _ => ad,
      };

  List<ScratchBlock> get bloklar =>
      KodYapisi.blokla(KodYapisi.coz(kod), palet);

  /// Cocugun varsayilan kuklasi: Devi, sahnenin ortasinda.
  static const devi = KuklaTanimi(ad: 'Devi');
}

/// Kimse dokunmazsa tuslara basan oyuncu.
///
/// Varsayilan: programin kullandigi her tusa sirayla bir kez basar,
/// tiklama betigi varsa cocugun kuklasina bir kez dokunur (eski
/// "her tusa bir kez basilmis sayilir" kurali). [takipEden] verilirse
/// o kukla sol/sag oklarla [hedef] kuklalarinin (en alttakinin) altina
/// gider — 5.1'de kaseyi elmalara goturen oyuncu.
class OtomatikOyuncu {
  const OtomatikOyuncu({this.takipEden, this.hedef});
  final String? takipEden;
  final String? hedef;
}

/// Sahnedeki bir kuklanin o anki hali (asil ya da ikiz).
class SahneKuklasi {
  SahneKuklasi._(this.tanim, this.sahne, this._program, this.no,
      {this.ana = false, this.klon = false});

  final KuklaTanimi tanim;

  /// Yurutmedeki kimligi (sahne kuklanin widget'ini bununla tutuyor).
  final int no;
  final Sahne sahne;
  final _Program _program;

  /// Cocugun kuklasi (ya da onun ikizi).
  final bool ana;
  final bool klon;
  bool silindi = false;
  double notaBitis = -1;

  double get yaricap => tanim.yaricap;

  /// Nota calarken (♪) — sahne kuklanin yaninda gosteriyor.
  bool notaCaliyor(double zaman) => zaman < notaBitis;
}

/// Bir kuklanin programi: betikleri, kendi blok tanimlari, sapkasiz
/// blok sayisi. Ikizler asil kuklanin programini paylasiyor.
class _Program {
  _Program(this.satirlar);
  final List<_Satir> satirlar;
  final List<_Betik> betikler = [];
  final Map<String, _Tanim> tanimlar = {};
  int sapkasiz = 0;

  static _Program coz(List<ScratchBlock> bloklar) {
    final p = _Program([
      for (var i = 0; i < bloklar.length; i++) _Satir(bloklar[i], i),
    ]);
    _Betik? acik;
    _Tanim? tanim;
    var derinlik = 0;
    for (final satir in p.satirlar) {
      final blok = satir.blok;
      final a = BlokYorumlayici.anlamOf(blok);
      // Yalnizca en distaki sapka yeni betik baslatir.
      if (derinlik == 0 && a.komut == BlokKomutu.tanimla) {
        tanim = p.tanimlar[a.yordam ?? '?'] = _Tanim(a.girdi);
        acik = null;
        continue;
      }
      if (derinlik == 0 && a.komut == BlokKomutu.baslat) {
        tanim = null;
        acik = _Betik(a);
        p.betikler.add(acik);
        // Sapkanin kendisi de izde gorunsun (kod alaninda parlasin).
        acik.satirlar.add(satir);
        continue;
      }
      if (blok.id == KodYapisi.sonId) {
        derinlik = derinlik > 0 ? derinlik - 1 : 0;
      } else if (a.cBlogu) {
        derinlik++;
      }
      if (tanim != null) {
        tanim.govde.add(satir);
      } else if (acik != null) {
        acik.satirlar.add(satir);
      } else if (!KodYapisi.isaretMi(blok.id)) {
        p.sapkasiz++;
      }
    }
    return p;
  }
}

/// Bir betigin calisan hali (is parcacigi).
class _Is {
  _Is(this.kukla, this.betik, this.olay) {
    yigin.add(_Cerceve(betik.agac, 0));
  }
  final SahneKuklasi kukla;
  final _Betik betik;
  final String olay;
  final List<_Cerceve> yigin = [];
  double bekleBitis = -1;
  _Kayma? kayma;
  List<_Is>? beklenen;
  bool bitti = false;
}

/// Calisan bir dilim: betigin govdesi, bir dongunun govdesi ya da bir
/// eger kolu.
class _Cerceve {
  _Cerceve(
    this.dilim,
    this.derinlik, {
    this.dongu = false,
    this.turSayisi = 0,
    this.tekrarNo,
    this.girdiler = const {},
    this.cagriDerinligi = 0,
  });
  final List<_Dugum> dilim;
  final int derinlik;
  final bool dongu;

  /// Dongunun tur sayisi; -1 surekli.
  final int turSayisi;
  final int? tekrarNo;
  final Map<String, num> girdiler;
  final int cagriDerinligi;
  int i = 0;
  int tur = 1;

  /// Bu dilimdeki bloklarin "kacinci tur"u: dongu ise kendi turu,
  /// degilse icinde bulundugu dongununki.
  int? get no => dongu ? tur : tekrarNo;
}

class _Kayma {
  _Kayma(this.x0, this.y0, this.x1, this.y1, this.bas, this.sure);
  final double x0, y0, x1, y1, bas, sure;
}
