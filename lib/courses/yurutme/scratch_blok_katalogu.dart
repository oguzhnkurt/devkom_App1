import '../../widgets/scratch_blok.dart';
import 'scratch_resmi_etiketler.dart';

/// Scratch kursundaki her blogun Scratch 3'teki KARSILIGI.
///
/// Ders verisi bloklari kimlikle tanimliyor (`move_10`, `if_space`...).
/// Bu katalog her kimligi Scratch'teki kategorisine, sekline ve satir
/// parcalarina (yazi, beyaz oval girdi, acilir menu, bayrak simgesi, ic
/// ice blok) ceviriyor.
///
/// ETIKETLER UYDURMA DEGIL. Sabit yazilar Scratch'in kendi dil
/// dosyalarindan geliyor ([scratchResmiEtiketler], kaynagi
/// `tool/bloklar/`): `%1 defa tekrarla` sablonundaki `%1` beyaz ovale,
/// `%1 e tıklandığında`daki `%1` yesil bayraga donusuyor. Elle yazilan
/// tek sey cocugun programina ait DEGERLER: degisken adi ("Puan"), Devi'nin
/// soyledigi cumle ("Miyav!"), liste ogesi ("elma"). Bunlar ders
/// verisindeki cevirilerle ayni.
///
/// Denetim: test/scratch_blok_test.dart — Scratch derslerinde kullanilan
/// her kimlik burada var mi, sablonlar resmi sozlukle ayni mi.
class ScratchBlokKatalogu {
  ScratchBlokKatalogu._();

  /// Ders verisindeki blok kimligi -> Scratch blogu.
  ///
  /// Sonuc (kimlik, dil) basina bir kez kuruluyor: kod alani, palet ve
  /// sahne ayni blogu her karede yeniden istiyordu.
  static ScratchBlokTanimi? tanim(String id, String lang) {
    final l = _dil(lang);
    final anahtar = '$id|$l';
    if (_onbellek.containsKey(anahtar)) return _onbellek[anahtar];
    return _onbellek[anahtar] = _bloklar[id]?.call(l);
  }

  static final Map<String, ScratchBlokTanimi?> _onbellek = {};

  /// Anlatim/siralama/karsilastirma adimlarinda blok gorseli olarak
  /// gecen TURKCE metin -> Scratch blogu.
  ///
  /// Bu adimlarin verisinde kimlik yok, yalnizca metin var. Metnin
  /// Turkcesi (cevirisi degil) anahtar: dil degisince blok kaybolmasin.
  static ScratchBlokTanimi? gorsel(String trMetin, String lang) {
    final id = gorselKimlikleri[trMetin.trim()];
    return id == null ? null : tanim(id, lang);
  }

  /// Anlatimda kategori tanitan gorseller ("Hareket", "Görünüm"...).
  static ScratchKategori? kategoriGorseli(String trMetin) =>
      _kategoriGorselleri[trMetin.trim()];

  static Iterable<String> get kimlikler => _bloklar.keys;

  /// Resmi etiket (sablon, yer tutuculariyla).
  static String etiket(String anahtar, String lang) =>
      scratchResmiEtiketler[_dil(lang)]![anahtar]!;

  static String _dil(String lang) =>
      scratchResmiEtiketler.containsKey(lang) ? lang : 'en';

  static const Map<String, ScratchKategori> _kategoriGorselleri = {
    'Hareket': ScratchKategori.hareket,
    'Görünüm': ScratchKategori.gorunum,
    'Ses': ScratchKategori.ses,
    'Olay': ScratchKategori.olaylar,
    'Olaylar': ScratchKategori.olaylar,
    'Kontrol': ScratchKategori.kontrol,
  };

  /// Gorsel metni -> katalog kimligi.
  static const Map<String, String> gorselKimlikleri = {
    // Anlatim adimlari
    '10 adım git': 'move_10',
    'Merhaba de': 'say_hello',
    'tıklandığında': 'green_flag',
    '10 defa tekrarla': 'repeat_10',
    'sürekli tekrarla': 'forever',
    'eğer <...> ise': 'if_empty',
    '<boşluk tuşuna basıldı mı?>': 'key_space_pressed',
    '<fare-imleci e değiyor mu?>': 'touching_pointer',
    '<kenar a değiyor mu?>': 'touching_edge',
    'eğer <...> ise ... değilse ...': 'if_else_empty',
    'x: 100 y: 50 konumuna git': 'goto_100_50',
    'x konumunu 10 değiştir': 'change_x',
    '1 saniyede x: 0 y: 0 konumuna git': 'glide_1_0_0',
    "eğer <yukarı ok> ise y'yi 10 değiştir": 'if_up_change_y',
    'rastgele konuma git': 'goto_random',
    "eğer <Devi'ye değdi mi?> ise": 'if_touching_cat',
    'Puan i 1 kadar değiştir': 'change_score',
    'Puan değişkenini 0 yap': 'set_score_0',
    'kendim in ikizini yarat': 'create_clone',
    'ikiz olarak başladığımda': 'when_clone',
    'oyun_basladi haberini sal': 'broadcast_game',
    'oyun_basladi haberini aldığımda': 'receive_game',
    'Meow sesini başlat': 'play_sound',
    '1 numaralı davulu 0.25 vuruş çal': 'play_drum',
    'kalem indir': 'pen_down',
    'sil': 'pen_clear',
    '4 defa tekrarla': 'repeat_4',
    '1 ile 10 arasında rastgele bir sayı seç': 'random_1_10',
    'puan > 10': 'gt_score_10',
    'elma i alışveriş ye ekle': 'add_apple',
    'sorular in uzunluğu': 'len_questions',
    'kare i tanımla': 'define_square',
    'çokgen (kenar) i tanımla': 'define_polygon',
    // Siralama adimi (1.2)
    'yeşil bayrak tıklandığında': 'green_flag',
    'Bitti! söyle': 'say_done',
    // Dongu karsilastirmasi (3.1)
    '10 defa tekrarla { 10 adım git }': 'repeat_10_move',
  };

  // -------------------------------------------------------------------
  // Yardimcilar
  // -------------------------------------------------------------------

  /// Dil secimi: (tr, en, de, es).
  static String _d(String l, String tr, String en, String de, String es) =>
      switch (l) { 'tr' => tr, 'de' => de, 'es' => es, _ => en };

  /// Resmi sablonu parcalara boler: `%1`/`[NOTE]` yerine [girdiler].
  static List<SbParca> _sablon(String anahtar, String l,
      [List<SbParca> girdiler = const [], List<String> adlar = const []]) {
    final s = etiket(anahtar, l);
    final out = <SbParca>[];
    final yer = RegExp(r'%(\d)|\[([A-Z_]+)\]');
    var son = 0;
    void yazi(String t) {
      final k = t.trim();
      if (k.isNotEmpty) out.add(SbYazi(k));
    }

    for (final m in yer.allMatches(s)) {
      yazi(s.substring(son, m.start));
      final i = m.group(1) != null
          ? int.parse(m.group(1)!) - 1
          : adlar.indexOf(m.group(2)!);
      out.add(girdiler[i]);
      son = m.end;
    }
    yazi(s.substring(son));
    return out;
  }

  static ScratchBlokTanimi _b(
    ScratchKategori k,
    ScratchSekil sekil,
    String anahtar,
    String l, [
    List<SbParca> girdiler = const [],
    List<String> adlar = const [],
  ]) =>
      ScratchBlokTanimi(
          kategori: k,
          sekil: sekil,
          satir: _sablon(anahtar, l, girdiler, adlar));

  static const _hareket = ScratchKategori.hareket;
  static const _gorunum = ScratchKategori.gorunum;
  static const _olaylar = ScratchKategori.olaylar;
  static const _kontrol = ScratchKategori.kontrol;
  static const _algilama = ScratchKategori.algilama;
  static const _islemler = ScratchKategori.islemler;
  static const _degisken = ScratchKategori.degiskenler;
  static const _liste = ScratchKategori.listeler;
  static const _bloklarim = ScratchKategori.bloklarim;
  static const _yigin = ScratchSekil.yigin;

  static ScratchBlokTanimi _git(String l, String n) =>
      _b(_hareket, _yigin, 'MOTION_MOVESTEPS', l, [SbGirdi(n)]);

  static ScratchBlokTanimi _don(String l, SbParca aci) => _b(_hareket, _yigin,
      'MOTION_TURNRIGHT', l, [const SbIkon(ScratchIkon.donSag), aci]);

  static ScratchBlokTanimi _de(String l, SbParca ne) =>
      _b(_gorunum, _yigin, 'LOOKS_SAY', l, [ne]);

  static ScratchBlokTanimi _tekrarla(String l, SbParca kac,
          {List<ScratchBlokTanimi> ic = const []}) =>
      ScratchBlokTanimi(
        kategori: _kontrol,
        sekil: ScratchSekil.c,
        satir: _sablon('CONTROL_REPEAT', l, [kac]),
        tekrarOku: true,
        ic: ic,
      );

  static ScratchBlokTanimi _eger(String l, SbParca kosul,
          {List<ScratchBlokTanimi> ic = const []}) =>
      ScratchBlokTanimi(
        kategori: _kontrol,
        sekil: ScratchSekil.c,
        satir: _sablon('CONTROL_IF', l, [kosul]),
        ic: ic,
      );

  /// <[tus] tusuna basildi mi?>
  static ScratchBlokTanimi _tus(String l, String tusAnahtari) => _b(
      _algilama,
      ScratchSekil.mantiksal,
      'SENSING_KEYPRESSED',
      l,
      [SbAcilir(etiket(tusAnahtari, l))]);

  /// <[ne] e degiyor mu?>
  static ScratchBlokTanimi _degiyor(String l, String ne) => _b(_algilama,
      ScratchSekil.mantiksal, 'SENSING_TOUCHINGOBJECT', l, [SbAcilir(ne)]);

  static ScratchBlokTanimi _rastgele(String l, SbParca a, SbParca b) =>
      _b(_islemler, ScratchSekil.raportor, 'OPERATORS_RANDOM', l, [a, b]);

  /// Turuncu oval degisken blogu.
  static ScratchBlokTanimi _degiskenOvali(String ad) => ScratchBlokTanimi(
      kategori: _degisken, sekil: ScratchSekil.raportor, satir: [SbYazi(ad)]);

  /// Kendi blogunun pembe girdi ovali ("kenar").
  static ScratchBlokTanimi _arguman(String l) => ScratchBlokTanimi(
      kategori: _bloklarim,
      sekil: ScratchSekil.raportor,
      satir: [SbYazi(_d(l, 'kenar', 'sides', 'Seiten', 'lados'))]);

  static String _puan(String l) => _d(l, 'Puan', 'Score', 'Punkte', 'Puntos');
  static String _puanKucuk(String l) =>
      _d(l, 'puan', 'score', 'Punkte', 'puntos');
  static String _alisveris(String l) =>
      _d(l, 'alışveriş', 'shopping', 'Einkauf', 'compra');
  static String _sorular(String l) =>
      _d(l, 'sorular', 'questions', 'Fragen', 'preguntas');

  static ScratchBlokTanimi _uzunluk(String l, String liste) => _b(
      _liste,
      ScratchSekil.raportor,
      'DATA_LENGTHOFLIST',
      l,
      [SbAcilir(liste, kutu: true)]);

  static ScratchBlokTanimi _tanimla(String l, List<SbParca> prototip) =>
      _b(_bloklarim, ScratchSekil.tanim, 'PROCEDURES_DEFINITION', l, [
        SbIcBlok(ScratchBlokTanimi(
          kategori: _bloklarim,
          sekil: _yigin,
          satir: prototip,
          prototip: true,
        )),
      ]);

  static ScratchBlokTanimi _kendiBlok(List<SbParca> p) =>
      ScratchBlokTanimi(kategori: _bloklarim, sekil: _yigin, satir: p);

  static ScratchBlokTanimi _kalem(String anahtar, String l) =>
      _b(ScratchKategori.kalem, _yigin, anahtar, l);

  static ScratchBlokTanimi _nota(String l, String nota) => _b(
      ScratchKategori.muzik,
      _yigin,
      'music.playNoteForBeats',
      l,
      [SbGirdi(nota), const SbGirdi('0.5')],
      const ['NOTE', 'BEATS']);

  static ScratchBlokTanimi _listeyeEkle(String l, String oge) => _b(
      _liste,
      _yigin,
      'DATA_ADDTOLIST',
      l,
      [SbGirdi(oge), SbAcilir(_alisveris(l), kutu: true)]);

  // -------------------------------------------------------------------
  // Katalog
  // -------------------------------------------------------------------

  static final Map<String, ScratchBlokTanimi Function(String l)> _bloklar = {
    // --- Olaylar ---------------------------------------------------
    'green_flag': (l) => _b(_olaylar, ScratchSekil.sapka,
        'EVENT_WHENFLAGCLICKED', l, [const SbIkon(ScratchIkon.bayrak)]),
    'when_clicked_sprite': (l) =>
        _b(_olaylar, ScratchSekil.sapka, 'EVENT_WHENTHISSPRITECLICKED', l),
    'receive_jump': (l) => _b(
        _olaylar,
        ScratchSekil.sapka,
        'EVENT_WHENBROADCASTRECEIVED',
        l,
        [SbAcilir(_d(l, 'zıpla', 'jump', 'springen', 'saltar'), kutu: true)]),
    'receive_game': (l) =>
        _b(_olaylar, ScratchSekil.sapka, 'EVENT_WHENBROADCASTRECEIVED', l, [
          SbAcilir(
              _d(l, 'oyun_basladi', 'game_started', 'spiel_gestartet',
                  'juego_iniciado'),
              kutu: true)
        ]),
    'broadcast': (l) => _b(_olaylar, _yigin, 'EVENT_BROADCAST', l,
        [SbAcilir(_d(l, 'zıpla', 'jump', 'springen', 'saltar'))]),
    'broadcast_game': (l) => _b(_olaylar, _yigin, 'EVENT_BROADCAST', l, [
          SbAcilir(_d(l, 'oyun_basladi', 'game_started', 'spiel_gestartet',
              'juego_iniciado'))
        ]),

    // --- Hareket ---------------------------------------------------
    'move_10': (l) => _git(l, '10'),
    'move_100': (l) => _git(l, '100'),
    'move_100_poly': (l) => _git(l, '100'),
    'move_150': (l) => _git(l, '150'),
    'turn_90': (l) => _don(l, const SbGirdi('90')),
    'turn_90_fixed': (l) => _don(l, const SbGirdi('90')),
    'turn_120': (l) => _don(l, const SbGirdi('120')),
    'turn_60_extra': (l) => _don(l, const SbGirdi('60')),
    'turn_360_over_sides': (l) => _don(
        l,
        SbIcBlok(_b(_islemler, ScratchSekil.raportor, 'OPERATORS_DIVIDE', l,
            [const SbGirdi('360'), SbIcBlok(_arguman(l))]))),
    'goto_corner': (l) => _b(_hareket, _yigin, 'MOTION_GOTOXY', l,
        [const SbGirdi('200'), const SbGirdi('150')]),
    'goto_center': (l) => _b(_hareket, _yigin, 'MOTION_GOTOXY', l,
        [const SbGirdi('0'), const SbGirdi('0')]),
    'goto_100_50': (l) => _b(_hareket, _yigin, 'MOTION_GOTOXY', l,
        [const SbGirdi('100'), const SbGirdi('50')]),
    'goto_random': (l) => _b(_hareket, _yigin, 'MOTION_GOTO', l,
        [SbAcilir(etiket('MOTION_GOTO_RANDOM', l))]),
    'glide_1_0_0': (l) => _b(_hareket, _yigin, 'MOTION_GLIDESECSTOXY', l,
        [const SbGirdi('1'), const SbGirdi('0'), const SbGirdi('0')]),
    'change_x': (l) =>
        _b(_hareket, _yigin, 'MOTION_CHANGEXBY', l, [const SbGirdi('10')]),
    'change_y_up': (l) =>
        _b(_hareket, _yigin, 'MOTION_CHANGEYBY', l, [const SbGirdi('10')]),
    'change_y': (l) =>
        _b(_hareket, _yigin, 'MOTION_CHANGEYBY', l, [const SbGirdi('50')]),

    // --- Gorunum ---------------------------------------------------
    'say_hello': (l) => _de(l, SbGirdi(etiket('LOOKS_HELLO', l))),
    'say_meow': (l) =>
        _de(l, SbGirdi(_d(l, 'Miyav!', 'Meow!', 'Miau!', '¡Miau!'))),
    'say_jump': (l) => _de(
        l,
        SbGirdi(_d(l, 'Zıpladın!', 'You jumped!', 'Du bist gesprungen!',
            '¡Saltaste!'))),
    'say_keep_going': (l) => _de(
        l, SbGirdi(_d(l, 'Devam et!', 'Keep going!', 'Weiter so!', '¡Sigue!'))),
    'say_done': (l) =>
        _de(l, SbGirdi(_d(l, 'Bitti!', 'Done!', 'Fertig!', '¡Listo!'))),
    'say_random_die': (l) =>
        _de(l, SbIcBlok(_rastgele(l, const SbGirdi('1'), const SbGirdi('6')))),
    'say_random_question': (l) => _de(
        l,
        SbIcBlok(_b(_liste, ScratchSekil.raportor, 'DATA_ITEMOFLIST', l, [
          SbIcBlok(_rastgele(
              l, const SbGirdi('1'), SbIcBlok(_uzunluk(l, _sorular(l))))),
          SbAcilir(_sorular(l), kutu: true),
        ]))),

    // --- Ses ve muzik ----------------------------------------------
    'play_sound': (l) => _b(ScratchKategori.ses, _yigin, 'SOUND_PLAY', l,
        [SbAcilir(_d(l, 'Meow', 'Meow', 'Miau', 'Miau'))]),
    'play_note_60': (l) => _nota(l, '60'),
    'play_note_62': (l) => _nota(l, '62'),
    'play_note_64': (l) => _nota(l, '64'),
    'play_drum': (l) => _b(
        ScratchKategori.muzik,
        _yigin,
        'music.playDrumForBeats',
        l,
        [SbAcilir(etiket('music.drumSnare', l)), const SbGirdi('0.25')],
        const ['DRUM', 'BEATS']),

    // --- Kalem -----------------------------------------------------
    'pen_clear': (l) => _kalem('pen.clear', l),
    'pen_down': (l) => _kalem('pen.penDown', l),
    'pen_up': (l) => _kalem('pen.penUp', l),

    // --- Kontrol ---------------------------------------------------
    'wait_2': (l) =>
        _b(_kontrol, _yigin, 'CONTROL_WAIT', l, [const SbGirdi('2')]),
    'repeat_3': (l) => _tekrarla(l, const SbGirdi('3')),
    'repeat_4': (l) => _tekrarla(l, const SbGirdi('4')),
    'repeat_10': (l) => _tekrarla(l, const SbGirdi('10')),
    'repeat_10_move': (l) =>
        _tekrarla(l, const SbGirdi('10'), ic: [_git(l, '10')]),
    'repeat_sides': (l) => _tekrarla(l, SbIcBlok(_arguman(l))),
    'forever': (l) => ScratchBlokTanimi(
          kategori: _kontrol,
          sekil: ScratchSekil.cKapak,
          satir: _sablon('CONTROL_FOREVER', l),
          tekrarOku: true,
        ),
    'if_empty': (l) => _eger(l, const SbBosKosul()),
    'if_else_empty': (l) => ScratchBlokTanimi(
          kategori: _kontrol,
          sekil: ScratchSekil.c,
          satir: _sablon('CONTROL_IF', l, [const SbBosKosul()]),
          degilse: _sablon('CONTROL_ELSE', l),
        ),
    'if_space': (l) =>
        _eger(l, SbIcBlok(_tus(l, 'EVENT_WHENKEYPRESSED_SPACE'))),
    'if_right': (l) =>
        _eger(l, SbIcBlok(_tus(l, 'EVENT_WHENKEYPRESSED_RIGHT'))),
    'if_up': (l) => _eger(l, SbIcBlok(_tus(l, 'EVENT_WHENKEYPRESSED_UP'))),
    'if_up_change_y': (l) => _eger(
          l,
          SbIcBlok(_tus(l, 'EVENT_WHENKEYPRESSED_UP')),
          ic: [
            _b(_hareket, _yigin, 'MOTION_CHANGEYBY', l, [const SbGirdi('10')])
          ],
        ),
    // 4.2'de yakalanan sey oyundaki FARE karakteri (kukla), fare imleci
    // degil: blok "fare-imleci" diyordu. Etiket bicimi Scratch'in kendi
    // "%1 e degiyor mu?" kalibi; acilir listede kuklanin adi var.
    'if_touching': (l) =>
        _eger(l, SbIcBlok(_degiyor(l, _d(l, 'Fare', 'Mouse', 'Maus', 'Ratón')))),
    'if_touching_cat': (l) =>
        _eger(l, SbIcBlok(_degiyor(l, _d(l, 'Devi', 'Devi', 'Devi', 'Devi')))),
    'if_score_low': (l) => _eger(
        l,
        SbIcBlok(_b(_islemler, ScratchSekil.mantiksal, 'OPERATORS_LT', l, [
          SbIcBlok(_degiskenOvali(_puanKucuk(l))),
          const SbGirdi('5'),
        ]))),
    'when_clone': (l) =>
        _b(_kontrol, ScratchSekil.sapka, 'CONTROL_STARTASCLONE', l),
    'create_clone': (l) => _b(_kontrol, _yigin, 'CONTROL_CREATECLONEOF', l,
        [SbAcilir(etiket('CONTROL_CREATECLONEOF_MYSELF', l))]),
    'delete_clone': (l) =>
        _b(_kontrol, ScratchSekil.kapak, 'CONTROL_DELETETHISCLONE', l),

    // --- Algilama --------------------------------------------------
    'key_space_pressed': (l) => _tus(l, 'EVENT_WHENKEYPRESSED_SPACE'),
    'touching_pointer': (l) =>
        _degiyor(l, etiket('SENSING_TOUCHINGOBJECT_POINTER', l)),
    'touching_edge': (l) =>
        _degiyor(l, etiket('SENSING_TOUCHINGOBJECT_EDGE', l)),

    // --- Islemler --------------------------------------------------
    'random_1_6': (l) => _rastgele(l, const SbGirdi('1'), const SbGirdi('6')),
    'random_1_10': (l) => _rastgele(l, const SbGirdi('1'), const SbGirdi('10')),
    'lt_score_5': (l) => _b(_islemler, ScratchSekil.mantiksal, 'OPERATORS_LT',
        l, [SbIcBlok(_degiskenOvali(_puanKucuk(l))), const SbGirdi('5')]),
    'lt_5_score': (l) => _b(_islemler, ScratchSekil.mantiksal, 'OPERATORS_LT',
        l, [const SbGirdi('5'), SbIcBlok(_degiskenOvali(_puanKucuk(l)))]),
    'gt_score_10': (l) => _b(_islemler, ScratchSekil.mantiksal, 'OPERATORS_GT',
        l, [SbIcBlok(_degiskenOvali(_puanKucuk(l))), const SbGirdi('10')]),

    // --- Degiskenler ve listeler -----------------------------------
    'set_score_0': (l) => _b(_degisken, _yigin, 'DATA_SETVARIABLETO', l,
        [SbAcilir(_puan(l), kutu: true), const SbGirdi('0')]),
    'change_score': (l) => _b(_degisken, _yigin, 'DATA_CHANGEVARIABLEBY', l,
        [SbAcilir(_puan(l), kutu: true), const SbGirdi('1')]),
    'add_apple': (l) =>
        _listeyeEkle(l, _d(l, 'elma', 'apple', 'Apfel', 'manzana')),
    'add_banana': (l) =>
        _listeyeEkle(l, _d(l, 'muz', 'banana', 'Banane', 'plátano')),
    'delete_first': (l) => _b(_liste, _yigin, 'DATA_DELETEOFLIST', l,
        [const SbGirdi('1'), SbAcilir(_alisveris(l), kutu: true)]),
    'len_questions': (l) => _uzunluk(l, _sorular(l)),
    'item_1_questions': (l) => _b(
        _liste,
        ScratchSekil.raportor,
        'DATA_ITEMOFLIST',
        l,
        [const SbGirdi('1'), SbAcilir(_sorular(l), kutu: true)]),

    // --- Bloklarim -------------------------------------------------
    'define_square': (l) =>
        _tanimla(l, [SbYazi(_d(l, 'kare', 'square', 'Quadrat', 'cuadrado'))]),
    'define_square_2': (l) =>
        _tanimla(l, [SbYazi(_d(l, 'kare', 'square', 'Quadrat', 'cuadrado'))]),
    'define_polygon': (l) => _tanimla(l, [
          SbYazi(_d(l, 'çokgen', 'polygon', 'Vieleck', 'polígono')),
          SbIcBlok(_arguman(l)),
        ]),
    'call_square': (l) =>
        _kendiBlok([SbYazi(_d(l, 'kare', 'square', 'Quadrat', 'cuadrado'))]),
    'call_polygon_6': (l) => _kendiBlok([
          SbYazi(_d(l, 'çokgen', 'polygon', 'Vieleck', 'polígono')),
          const SbGirdi('6'),
        ]),
    'call_polygon_4': (l) => _kendiBlok([
          SbYazi(_d(l, 'çokgen', 'polygon', 'Vieleck', 'polígono')),
          const SbGirdi('4'),
        ]),
  };
}
