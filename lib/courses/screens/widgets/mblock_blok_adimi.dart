import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../services/sound_service.dart';
import '../../../theme.dart';
import '../../../ui/motion.dart';
import '../../models/course_model.dart';
import '../../models/interactive_lesson_model.dart';
import '../../sahne/mblock_sahnesi.dart';
import '../../sahne/mblock_yigin_cizimi.dart';
import '../../yurutme/mblock_blok_adlari.dart';
import '../../yurutme/mblock_cozum.dart';
import 'devi_tepkisi.dart';
import 'mblock_tezgahi.dart';
import 'step_widgets.dart'
    show BlockBuilderStepWidget, lessonLang, lessonLangRead, lessonText;

/// mBlock kursunda blok kurma adimi — gercek tezgahla.
///
/// Eski `BlockBuilderStepWidget` bloklari SIRAYA DIZDIRIYORDU: cocuk
/// kartlara dokunuyor, alt alta geliyorlardi. Ogrettigimiz sey ise
/// surukleyip yapistirmak, C kutusunun icine blok koymak, acilir
/// listeden pin secmek. mBlock derslerinde artik bunun kendisi
/// yapiliyor.
///
/// SAHNE USTTE, BLOKLAR ALTTA (Scratch dersleriyle ayni duzen). "Kontrol
/// et" programi yalnizca karsilastirmiyor, CALISTIRIYOR: kart
/// programlari sanal Arduino Uno'da (LED yanip soner, buton basilir),
/// kukla programlari Scratch sahnesinde. Yanlis program da calisir —
/// cocuk ne yaptigini gorur.
///
/// YARDIM: uc yanlistan sonra ilk farkin YERI ("3. bloga bak: orada
/// "dijital ayarla ..." olmali"), bes yanlistan sonra "Cozumu goster"
/// (adim tamamlanir, XP'siz).
///
/// YEDEK: tezgah (WebView) acilamazsa ya da hata verirse adim kart dizme
/// ekranina (BlockBuilderStepWidget) geciyor; ayni adimin
/// `availableBlocks` + `correctSequence` verisiyle. Cocuk bekleyen bir
/// carkla kalmiyor.
///
/// Denetim `mblock_cozum.dart` icinde ve WebView'siz sinanabiliyor;
/// burasi yalnizca ekran.
class MBlockBlokAdimi extends StatefulWidget {
  const MBlockBlokAdimi({
    super.key,
    required this.step,
    required this.ayar,
    required this.course,
    required this.isDark,
    required this.onComplete,
    this.onDevam,
    this.zamanOlcegi = 1.0,
  });

  final BlockBuilderStep step;
  final MBlockTezgahAyari ayar;
  final Course course;
  final bool isDark;
  final Function(bool correct) onComplete;

  /// Yedek tezgahin ic DEVAM tusu (ders ekranindaki "Devam" ile ayni).
  final VoidCallback? onDevam;

  /// Kart sahnesinin zaman olcegi (testlerde hizli).
  final double zamanOlcegi;

  /// Kac yanlistan sonra ilk farkin yeri gosteriliyor.
  static const int ipucuEsigi = 3;

  /// Kac yanlistan sonra "Cozumu goster" cikiyor.
  static const int cozumEsigi = 5;

  @override
  State<MBlockBlokAdimi> createState() => MBlockBlokAdimiState();
}

class MBlockBlokAdimiState extends State<MBlockBlokAdimi> {
  final _tezgah = GlobalKey<MBlockTezgahiState>();
  final _sahne = GlobalKey<MBlockSahnesiState>();
  final _sahneYeri = GlobalKey();

  List<List<MBlockBlok>> _yiginlar = const [];
  bool? _sonuc;
  bool _bitti = false;

  /// Kac kez yanlis kontrol edildi.
  int _yanlis = 0;

  /// Kac kez kontrol edildi (Devi'nin tepkisi her seferinde yeniden).
  int _deneme = 0;

  /// Son yanlis kontroldeki ilk fark.
  MBlockFark? _fark;

  /// Tezgah acilamadi: kart dizme ekranindayiz.
  bool _yedek = false;
  bool get yedekte => _yedek;

  /// Cozum gosterildi (adim XP'siz tamamlandi).
  bool _cozumGosterildi = false;

  late final bool _kart = mblockKartProgramiMi(widget.ayar.cozum);

  /// Hata Avcisi: tahtadaki hazir (hatali) program bir kez yuklendi mi.
  bool _baslangicYuklendi = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // HATA AVCISI: hazir program tezgahta (WebView) baslangicXml ile
    // geliyor; burada da ayni program tutuluyor ki cocuk tezgah
    // "durum" bildirmeden once de "Calistir"a basabilsin (ve WebView'siz
    // onizlemede program gorunsun).
    final hazir = widget.ayar.baslangic;
    if (!_baslangicYuklendi && hazir != null && _yiginlar.isEmpty) {
      _baslangicYuklendi = true;
      _yiginlar = [mblockCozumProgrami(hazir, lessonLangRead(context))];
    }
  }

  /// Hata Avcisi: programi DENETLEMEDEN calistir (once hatayi gor).
  void yalnizCalistir() {
    HapticFeedback.lightImpact();
    _sahneyiCalistir(_yiginlar);
  }

  /// Kac blok var (dugmenin acik olup olmayacagini belirliyor).
  int get _blokSayisi => _yiginlar.fold(0, (t, y) => t + _say(y));

  int _say(List<MBlockBlok> liste) =>
      liste.fold(0, (t, b) => t + 1 + _say(b.icerik));

  /// Testler (ve ekran goruntusu araci) tezgahi WebView'siz besleyebilsin.
  @visibleForTesting
  void durumVer(List<List<MBlockBlok>> yiginlar) => _durum(yiginlar);

  void _durum(List<List<MBlockBlok>> yiginlar) {
    if (!mounted) return;
    setState(() {
      _yiginlar = yiginlar;
      // Tahtaya dokunulunca eski not silinir: kirmizi bir uyari,
      // cocuk duzeltmeye baslamisken ekranda asili kalmamali.
      if (!_bitti) _sonuc = null;
    });
  }

  void _yedegeGec() {
    if (!mounted || _yedek) return;
    setState(() => _yedek = true);
  }

  /// Kontrol et: karsilastir VE calistir.
  void kontrolEt() {
    final dogru = mblockCozumDogruMu(_yiginlar, widget.ayar.cozum);
    setState(() {
      _sonuc = dogru;
      _deneme++;
      if (dogru) {
        _bitti = true;
        _fark = null;
      } else {
        _yanlis++;
        _fark = mblockIlkFark(_yiginlar, widget.ayar.cozum);
      }
    });
    _sahneyiCalistir(_yiginlar);
    if (dogru) {
      HapticFeedback.heavyImpact();
      SoundService.playSoruDogru();
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        widget.onComplete(true);
      });
    } else {
      HapticFeedback.lightImpact();
    }
  }

  void _sahneyiCalistir(List<List<MBlockBlok>> program) {
    _sahne.currentState?.calistir(program);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = _sahneYeri.currentContext;
      if (c == null || !mounted) return;
      Scrollable.ensureVisible(c,
          duration: Motion.reduced(context)
              ? Duration.zero
              : const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart);
    });
  }

  /// Cozumu goster: adim tamamlaniyor ama XP'siz.
  void cozumuGoster() {
    if (_bitti) return;
    final lang = lessonLangRead(context);
    setState(() {
      _cozumGosterildi = true;
      _bitti = true;
      _sonuc = null;
    });
    _sahneyiCalistir([mblockCozumProgrami(widget.ayar.cozum, lang)]);
    widget.onComplete(false);
  }

  void _yedekTamam(bool dogru) {
    if (!mounted) return;
    setState(() => _bitti = true);
    // Yedekte sahne cocugun programini goremiyor; dogru dizi cozumun
    // kendisi oldugu icin cozum calisiyor.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _sahne.currentState
          ?.calistir([
        mblockCozumProgrami(widget.ayar.cozum, lessonLangRead(context))
      ]);
    });
    widget.onComplete(dogru);
  }

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    if (_yedek) return _yedekDuzeni(lang);
    final yaziRengi = widget.isDark ? Colors.white : const Color(0xFF1A1A1A);
    // Telefonda sahne + tezgah yaklasik bir ekrana sigsin: yonerge ve
    // hedef sikisik, kukla sahnesi kisa, tezgah ekran boyuna gore
    // sinirli (gercek iPhone'da adim asagi dogru uzuyordu).
    final ekranH = MediaQuery.sizeOf(context).height;
    final kisa = ekranH < 700;
    final tezgahH = (ekranH * 0.34).clamp(250.0, 400.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.ayar.hataAvcisi) ...[
          _hataAvcisiSeridi(lang),
          const SizedBox(height: 10),
        ],
        Text(
          widget.step.instructionFor(lang),
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: kisa ? 15.5 : 16.5,
            height: 1.3,
            fontWeight: FontWeight.w800,
            color: yaziRengi,
          ),
        ),
        const SizedBox(height: 8),
        _hedef(lang),
        const SizedBox(height: 10),

        // SAHNE (ustte).
        KeyedSubtree(
          key: _sahneYeri,
          child: MBlockSahnesi(
            key: _sahne,
            kart: _kart,
            program: _yiginlar,
            lang: lang,
            renk: widget.course.primaryColor,
            dogru: _bitti && !_cozumGosterildi,
            zamanOlcegi: widget.zamanOlcegi,
            kuklaYuksekligi: kisa ? 160 : 180,
          ),
        ),
        const SizedBox(height: 10),

        // BLOKLAR (altta).
        MBlockTezgahi(
          key: _tezgah,
          ayar: widget.ayar,
          onDurum: _durum,
          onHata: _yedegeGec,
          onizleme: _yiginlar,
          yukseklik: tezgahH,
        ),

        const SizedBox(height: 6),
        Text(
          lessonText(
            lang,
            'Blokları soldaki listeden sürükle, alt alta yapıştır.',
            'Drag blocks from the list on the left and snap them together.',
            'Zieh Blöcke aus der Liste links und stecke sie zusammen.',
            'Arrastra bloques de la lista de la izquierda y encájalos.',
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),

        if (_sonuc != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: DeviTepkisi(
              key: ValueKey('mblock_devi_$_deneme'),
              tur: _sonuc! ? DeviTepkiTuru.dogru : DeviTepkiTuru.tekrarDene,
              lang: lang,
              tohum: widget.step.id.hashCode + _deneme,
              koyu: widget.isDark,
            ),
          ),
        const SizedBox(height: 12),

        if (_sonuc == false) ...[
          _yanlisKutusu(lang),
          const SizedBox(height: 12),
        ],

        if (_cozumGosterildi) ...[
          _cozumKarti(lang),
          const SizedBox(height: 12),
        ] else if (_bitti)
          _basariKutusu(lang)
        else ...[
          if (widget.ayar.hataAvcisi) ...[
            OutlinedButton.icon(
              key: const ValueKey('mblock_hatali_calistir'),
              onPressed: _blokSayisi == 0 ? null : yalnizCalistir,
              icon: const Icon(Icons.bug_report_rounded, size: 20),
              label: Text(
                lessonText(lang, 'Programı çalıştır, hatayı gör',
                    'Run the program, spot the bug',
                    'Programm starten, Fehler finden',
                    'Ejecuta el programa y encuentra el error'),
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD9480F),
                side: const BorderSide(color: Color(0xFFD9480F), width: 1.6),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _tezgah.currentState?.temizle(),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(
                    lessonText(lang, 'Temizle', 'Clear', 'Leeren', 'Limpiar'),
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  key: const ValueKey('mblock_kontrol'),
                  // Bos tahtada kontrol yok: cocuga "yanlis" demenin
                  // en anlamsiz hali hicbir sey kurmamisken olur.
                  onPressed: _blokSayisi == 0 ? null : kontrolEt,
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: Text(
                    lessonText(lang, 'Kontrol et ve çalıştır',
                        'Check and run', 'Prüfen und starten',
                        'Comprobar y ejecutar'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: widget.course.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          if (_yanlis >= MBlockBlokAdimi.cozumEsigi) ...[
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                key: const ValueKey('mblock_cozumu_goster'),
                onPressed: cozumuGoster,
                icon: const Icon(Icons.visibility_rounded, size: 18),
                label: Text(
                  lessonText(lang, 'Çözümü göster', 'Show the solution',
                      'Lösung zeigen', 'Mostrar la solución'),
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: TextButton.styleFrom(
                    foregroundColor: widget.course.primaryColor),
              ),
            ),
          ],
        ],
      ],
    );
  }

  /// "Hata Avcisi" seridi: bu adimda program HAZIR ve hatali.
  Widget _hataAvcisiSeridi(String lang) => Container(
        key: const ValueKey('mblock_hata_avcisi'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0E6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFB38A)),
        ),
        child: Row(
          children: [
            const Text('🐞', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Expanded(
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: lessonText(lang, 'HATA AVCISI  ', 'BUG HUNTER  ',
                        'FEHLERJAGD  ', 'CAZAERRORES  '),
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: Color(0xFFD9480F)),
                  ),
                  TextSpan(
                    text: lessonText(
                        lang,
                        'Bu program hazır ama bir hatası var. Önce çalıştır ve ne olduğunu izle, sonra düzelt.',
                        'This program is ready but has a bug. Run it first and watch what happens, then fix it.',
                        'Dieses Programm ist fertig, hat aber einen Fehler. Starte es zuerst und schau, was passiert; dann reparier es.',
                        'Este programa está listo pero tiene un error. Ejecútalo primero y mira qué pasa; luego arréglalo.'),
                  ),
                ]),
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7A2E0B),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _hedef(String lang) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: widget.course.primaryColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.flag_rounded,
                size: 18, color: widget.course.primaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.step.goalFor(lang),
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13.5,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                  color: widget.course.primaryColor,
                ),
              ),
            ),
          ],
        ),
      );

  /// Ilk farkin yerini soyleyen ipucu (cevabi, yani degerleri, soylemez).
  static String ipucuMetni(MBlockFark f, String lang) {
    String ad(String? tip) => tip == null ? '…' : mblockBlokAdi(tip, lang);
    final n = f.sira;
    return switch (f.tur) {
      MBlockFarkTuru.bosTahta => lessonText(
          lang,
          'Tahta boş. Hedefteki ilk bloğu sürükleyerek başla.',
          'The board is empty. Start by dragging the first block of the goal.',
          'Die Fläche ist leer. Fang mit dem ersten Block aus dem Ziel an.',
          'El tablero está vacío. Empieza arrastrando el primer bloque del objetivo.'),
      MBlockFarkTuru.cokYigin => lessonText(
          lang,
          'Bir parça kopuk duruyor. Bütün blokları tek bir yığında birleştir.',
          'A piece is loose. Snap all the blocks into one stack.',
          'Ein Teil hängt lose. Steck alle Blöcke zu einem Stapel zusammen.',
          'Hay una pieza suelta. Une todos los bloques en una sola pila.'),
      MBlockFarkTuru.eksikBlok => lessonText(
          lang,
          '$n. blok eksik: orada "${ad(f.beklenenTip)}" olmalı.',
          'Block $n is missing: "${ad(f.beklenenTip)}" goes there.',
          'Block $n fehlt: Dort gehört „${ad(f.beklenenTip)}“ hin.',
          'Falta el bloque $n: ahí va «${ad(f.beklenenTip)}».'),
      MBlockFarkTuru.fazlaBlok => lessonText(
          lang,
          '$n. blok fazla: "${ad(f.kurulanTip)}" bloğunu çıkar.',
          'Block $n is extra: remove "${ad(f.kurulanTip)}".',
          'Block $n ist zu viel: Nimm „${ad(f.kurulanTip)}“ weg.',
          'El bloque $n sobra: quita «${ad(f.kurulanTip)}».'),
      MBlockFarkTuru.farkliBlok => lessonText(
          lang,
          '$n. bloğa bak: orada "${ad(f.beklenenTip)}" olmalı.',
          'Look at block $n: "${ad(f.beklenenTip)}" goes there.',
          'Schau dir Block $n an: Dort gehört „${ad(f.beklenenTip)}“ hin.',
          'Mira el bloque $n: ahí va «${ad(f.beklenenTip)}».'),
      MBlockFarkTuru.deger => lessonText(
          lang,
          '$n. blok doğru, ama kutudaki değere bak. Hedefte ne yazıyor?',
          'Block $n is right, but check the value in its slot. What does the goal say?',
          'Block $n stimmt, aber prüf den Wert im Feld. Was steht im Ziel?',
          'El bloque $n está bien, pero revisa el valor. ¿Qué dice el objetivo?'),
      MBlockFarkTuru.girdi => lessonText(
          lang,
          '$n. bloğun yuvasına "${ad(f.beklenenTip)}" takılmalı.',
          'Plug "${ad(f.beklenenTip)}" into the slot of block $n.',
          'In das Feld von Block $n gehört „${ad(f.beklenenTip)}“.',
          'En la ranura del bloque $n va «${ad(f.beklenenTip)}».'),
    };
  }

  Widget _yanlisKutusu(String lang) {
    final ipucu = _yanlis >= MBlockBlokAdimi.ipucuEsigi && _fark != null;
    final metin = ipucu
        ? ipucuMetni(_fark!, lang)
        : lessonText(
            lang,
            'Henüz olmadı. Sahnede ne olduğuna bak, hedefi bir daha oku; '
                'blokların sırasına ve kutulardaki sayılara bak.',
            'Not yet. Watch what happened on the stage and read the goal '
                'again; check the order of the blocks and the numbers.',
            'Noch nicht. Schau, was auf der Bühne passiert ist, und lies '
                'das Ziel noch einmal; prüf Reihenfolge und Zahlen.',
            'Todavía no. Mira lo que pasó en el escenario y vuelve a leer '
                'el objetivo; revisa el orden y los números.',
          );
    return Container(
      key: ValueKey(ipucu ? 'mblock_ipucu' : 'mblock_yanlis'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade600, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ipucu ? Icons.tips_and_updates_rounded : Icons.lightbulb_outline,
              color: Colors.orange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              metin,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w700,
                color: widget.isDark
                    ? Colors.orange.shade200
                    : Colors.orange.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _basariKutusu(String lang) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green, width: 2),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                lessonText(lang, 'Program doğru!', 'The program is right!',
                    'Das Programm stimmt!', '¡El programa es correcto!'),
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.green.shade700,
                ),
              ),
            ),
          ],
        ),
      );

  /// Cozum: bloklar kendi renginde, C kutularinin ici girintili.
  Widget _cozumKarti(String lang) {
    final renk = widget.course.primaryColor;
    return Container(
      key: const ValueKey('mblock_cozum_karti'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: renk.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: renk.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lessonText(lang, 'Çözüm', 'Solution', 'Lösung', 'Solución'),
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
              color: renk,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: MBlockYiginCizimi(
              bloklar: mblockCozumProgrami(widget.ayar.cozum, lang),
              lang: lang,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lessonText(
                lang,
                'Bu adımdan XP yok, ama artık nasıl olduğunu biliyorsun. '
                    'Bir sonraki adımda sen yaparsın!',
                'No XP for this step, but now you know how it works. '
                    "You'll do the next one yourself!",
                'Für diesen Schritt gibt es kein XP, aber jetzt weißt du, '
                    'wie es geht. Den nächsten schaffst du selbst!',
                'Este paso no da XP, pero ya sabes cómo se hace. '
                    '¡El siguiente lo harás tú!'),
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // Yedek: tezgah acilamadi
  // ------------------------------------------------------------------

  Widget _yedekDuzeni(String lang) {
    return Column(
      key: const ValueKey('mblock_yedek'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF5FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBFD5F7)),
          ),
          child: Row(
            children: [
              const Icon(Icons.touch_app_rounded,
                  size: 20, color: Color(0xFF3D6FB6)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  lessonText(
                      lang,
                      'Sürükle-bırak tezgahı bu cihazda açılmadı. Bu adımı '
                          'blokları dokunarak sıraya dizerek yapalım.',
                      "The drag-and-drop workbench didn't open on this "
                          "device. Let's do this step by tapping the blocks "
                          'into order.',
                      'Die Drag-and-drop-Werkbank ging auf diesem Gerät '
                          'nicht auf. Wir machen diesen Schritt, indem du '
                          'die Blöcke antippst.',
                      'El taller de arrastrar y soltar no se abrió en este '
                          'dispositivo. Hagamos este paso tocando los '
                          'bloques en orden.'),
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D4F82),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (_bitti) ...[
          KeyedSubtree(
            key: _sahneYeri,
            child: MBlockSahnesi(
              key: _sahne,
              kart: _kart,
              program: [mblockCozumProgrami(widget.ayar.cozum, lang)],
              lang: lang,
              renk: widget.course.primaryColor,
              dogru: true,
              zamanOlcegi: widget.zamanOlcegi,
            ),
          ),
          const SizedBox(height: 14),
        ],
        BlockBuilderStepWidget(
          step: widget.step,
          course: widget.course,
          isDark: widget.isDark,
          onComplete: _yedekTamam,
          onDevam: widget.onDevam,
        ),
      ],
    );
  }
}
