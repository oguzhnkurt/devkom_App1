import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../services/proje_deposu.dart';
import '../../../services/sound_service.dart';
import '../../../theme.dart';
import '../../../utils/lang.dart';
import '../../models/course_model.dart';
import '../../models/interactive_lesson_model.dart';
import '../../yurutme/atolye_hedefleri.dart';
import '../../yurutme/blok_yorumlayici.dart';
import '../../yurutme/kod_yapisi.dart';
import 'devi_tepkisi.dart';
import 'ic_ice_kod_alani.dart';
import 'scratch_tezgahi.dart';

/// Hedef listesi: her hedef bir satir; kod calistiktan sonra saglanan
/// hedefin dairesi yesil tike donuyor.
class HedefListesi extends StatelessWidget {
  const HedefListesi({
    super.key,
    required this.hedefler,
    required this.durumlar,
    required this.lang,
    required this.renk,
  });

  final List<AtolyeHedefi> hedefler;

  /// null: henuz calistirilmadi.
  final List<bool>? durumlar;
  final String lang;
  final Color renk;

  @override
  Widget build(BuildContext context) {
    final tamam = durumlar?.where((d) => d).length ?? 0;
    return Container(
      key: const ValueKey('atolye_hedefleri'),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(
        color: renk.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: renk.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('🎯', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                AppLang.pick(lang,
                    tr: 'Hedefler', en: 'Goals', de: 'Ziele', es: 'Objetivos'),
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: renk,
                ),
              ),
            ),
            Text(
              '$tamam/${hedefler.length}',
              key: const ValueKey('atolye_hedef_sayaci'),
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontWeight: FontWeight.w800,
                color: renk,
              ),
            ),
          ]),
          const SizedBox(height: 6),
          for (var i = 0; i < hedefler.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (c, a) =>
                        ScaleTransition(scale: a, child: c),
                    child: (durumlar != null && durumlar![i])
                        ? const Icon(Icons.check_circle_rounded,
                            key: ValueKey('tik'),
                            color: Color(0xFF2FB344),
                            size: 22)
                        : Icon(
                            durumlar == null
                                ? Icons.radio_button_unchecked_rounded
                                : Icons.cancel_outlined,
                            key: ValueKey('bos_${durumlar == null}'),
                            color: durumlar == null
                                ? Colors.grey.shade400
                                : const Color(0xFFE8A13A),
                            size: 22),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hedefler[i].metinFor(lang),
                      key: ValueKey('atolye_hedef_$i'),
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 14,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                        color: (durumlar != null && durumlar![i])
                            ? const Color(0xFF1F7A33)
                            : const Color(0xFF374151),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// PROJE ATOLYESI adimi (ve "Projelerim"den acilan serbest atolye).
///
/// Ustte projenin anlatimi ve hedefler, ortada tezgah (sahne + bloklar
/// + kod alani), altta kaydet. Kod CALISINCA hedefler denetleniyor;
/// tikler sahnedeki oynatma bitince yaniyor. Butun hedefler saglaninca
/// adim BIR KEZ tamamlaniyor (XP). Iki basarisiz calistirmadan sonra
/// ipucu, dorduncuden sonra ornek cozum geliyor.
class ProjeAtolyesiWidget extends StatefulWidget {
  const ProjeAtolyesiWidget({
    super.key,
    required this.step,
    required this.course,
    required this.isDark,
    required this.lang,
    this.onComplete,
    this.onDevam,
    this.kayitli,
    this.onKaydedildi,
  });

  final ProjeAtolyesiStep step;
  final Course course;
  final bool isDark;
  final String lang;

  /// true: butun hedefler saglandi (XP). false: "Sonra devam ederim".
  final ValueChanged<bool>? onComplete;
  final VoidCallback? onDevam;

  /// Projelerim'den acilan kayitli proje.
  final KayitliProje? kayitli;
  final ValueChanged<KayitliProje>? onKaydedildi;

  @override
  State<ProjeAtolyesiWidget> createState() => _ProjeAtolyesiWidgetState();
}

class _ProjeAtolyesiWidgetState extends State<ProjeAtolyesiWidget> {
  final GlobalKey<ScratchTezgahiState> _tezgah = GlobalKey();
  late List<KodOgesi> _kod =
      widget.kayitli?.kod ?? KodYapisi.coz(widget.step.baslangic);

  /// Son calistirmanin hedef durumlari (oynatma bitince gosteriliyor).
  List<bool>? _sonDurum;
  List<bool>? _gosterilen;
  bool _tamam = false;
  bool _bildirildi = false;
  int _basarisiz = 0;
  int _denemeNo = 0;
  KayitliProje? _kayit;

  @override
  void initState() {
    super.initState();
    _kayit = widget.kayitli;
  }

  ProjeAtolyesiStep get _s => widget.step;
  String get _l => widget.lang;
  Color get _renk => widget.course.primaryColor;

  String _t(String tr, String en, String de, String es) =>
      AppLang.pick(_l, tr: tr, en: en, de: de, es: es);

  void _calisti(Yurutme y, List<KodOgesi> kod) {
    final sonuc = AtolyeSonucu(yurutme: y, kod: kod);
    _sonDurum = AtolyeDenetimi.durumlar(_s.hedefler, sonuc);
  }

  void _oynatmaBitti() {
    final d = _sonDurum;
    if (d == null || !mounted) return;
    final hepsi = _s.hedefler.isNotEmpty && d.every((x) => x);
    setState(() {
      _gosterilen = d;
      _denemeNo++;
      if (hepsi) {
        _tamam = true;
      } else if (_s.hedefler.isNotEmpty) {
        _basarisiz++;
      }
    });
    if (hepsi) {
      HapticFeedback.heavyImpact();
      SoundService.playSoruDogru();
      if (!_bildirildi) {
        _bildirildi = true;
        widget.onComplete?.call(true);
      }
    }
  }

  Future<void> _kaydet() async {
    final adKontrol = TextEditingController(
        text: _kayit?.ad ?? _s.titleFor(_l).replaceFirst(RegExp(r'^.*?: '), ''));
    final ad = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(_t('Projeni kaydet', 'Save your project',
            'Projekt speichern', 'Guarda tu proyecto')),
        content: TextField(
          key: const ValueKey('proje_adi'),
          controller: adKontrol,
          autofocus: true,
          maxLength: 40,
          decoration: InputDecoration(
            labelText: _t('Projenin adı', 'Project name', 'Projektname',
                'Nombre del proyecto'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: Text(_t('Vazgeç', 'Cancel', 'Abbrechen', 'Cancelar')),
          ),
          ElevatedButton(
            key: const ValueKey('proje_kaydet_onay'),
            onPressed: () => Navigator.pop(c, adKontrol.text.trim()),
            child: Text(_t('Kaydet', 'Save', 'Speichern', 'Guardar')),
          ),
        ],
      ),
    );
    if (ad == null || !mounted) return;
    final kod = _tezgah.currentState?.kod ?? _kod;
    final proje = await ProjeDeposu.kaydet(_kayit?.copyWith(
            ad: ad.isEmpty ? _kayit!.ad : ad,
            kod: kod,
            tarih: DateTime.now()) ??
        KayitliProje(
          id: ProjeDeposu.yeniKimlik(),
          ad: ad.isEmpty ? _s.titleFor(_l) : ad,
          kursId: widget.course.id,
          adimId: _s.id == ScratchSerbestAtolye.kimlik ? null : _s.id,
          kod: kod,
          tarih: DateTime.now(),
        ));
    if (!mounted) return;
    setState(() => _kayit = proje);
    widget.onKaydedildi?.call(proje);
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
      content: Text(_t(
          '"${proje.ad}" Projelerim\'e kaydedildi.',
          '"${proje.ad}" was saved to My Projects.',
          '„${proje.ad}“ wurde in „Meine Projekte“ gespeichert.',
          '"${proje.ad}" se guardó en Mis proyectos.')),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final yazi = widget.isDark ? Colors.white : const Color(0xFF1A1A1A);
    final not = _s.bilgisayarNotuFor(_l);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _renk,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _t('PROJE ATÖLYESİ', 'PROJECT WORKSHOP', 'PROJEKTWERKSTATT',
                  'TALLER DE PROYECTOS'),
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 0.6,
              ),
            ),
          ),
          if (_kayit != null) ...[
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _kayit!.ad,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: _renk,
                    fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ]),
        const SizedBox(height: 8),
        Text(
          _s.titleFor(_l),
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: yazi,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _s.descriptionFor(_l),
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 14.5,
            height: 1.35,
            fontWeight: FontWeight.w600,
            color: yazi.withValues(alpha: 0.8),
          ),
        ),
        if (_s.hedefler.isNotEmpty) ...[
          const SizedBox(height: 10),
          HedefListesi(
            hedefler: _s.hedefler,
            durumlar: _gosterilen,
            lang: _l,
            renk: _renk,
          ),
        ],
        const SizedBox(height: 12),
        ScratchTezgahi(
          key: _tezgah,
          palet: _s.palet,
          lang: _l,
          renk: _renk,
          baslangic: _kod,
          duzenlenebilir: _s.sayiDuzenlenebilir,
          cokBetik: true,
          dogru: _tamam,
          onKodDegisti: (k) => _kod = k,
          onCalisti: _calisti,
          onOynatmaBitti: _oynatmaBitti,
        ),
        if (_gosterilen != null && _s.hedefler.isNotEmpty) ...[
          const SizedBox(height: 12),
          DeviTepkisi(
            key: ValueKey('atolye_tepki_$_denemeNo'),
            tur: _tamam ? DeviTepkiTuru.dogru : DeviTepkiTuru.tekrarDene,
            lang: _l,
            tohum: _s.id.hashCode + _denemeNo,
            koyu: widget.isDark,
          ),
        ],
        if (!_tamam) ...[
          const SizedBox(height: 10),
          IlerleyenIpucu(
            yanlis: _basarisiz,
            lang: _l,
            ipucu: _s.ipucuFor(_l),
            cozum: cozumSatirlari(_s.ornekCozum, _s.palet, _l),
          ),
        ],
        if (_tamam) ...[
          const SizedBox(height: 12),
          _basari(),
        ],
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              key: const ValueKey('atolye_kaydet'),
              onPressed: _kaydet,
              icon: const Icon(Icons.save_alt_rounded),
              label: Text(_t('Kaydet', 'Save', 'Speichern', 'Guardar')),
              style: OutlinedButton.styleFrom(
                foregroundColor: _renk,
                side: BorderSide(color: _renk, width: 1.6),
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          if (widget.onComplete != null && !_tamam && !_bildirildi) ...[
            const SizedBox(width: 10),
            Expanded(
              child: TextButton(
                key: const ValueKey('atolye_sonra'),
                onPressed: () {
                  _bildirildi = true;
                  widget.onComplete?.call(false);
                  widget.onDevam?.call();
                },
                child: Text(
                  _t('Sonra devam ederim', 'I will finish later',
                      'Später weitermachen', 'Lo termino luego'),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ]),
        if (not != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : const Color(0xFFF4F6FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.computer_rounded,
                    size: 20, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_t('Bilgisayarda devam et', 'Keep going on a computer', 'Am Computer weitermachen', 'Sigue en el ordenador')}: $not',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 13,
                      height: 1.35,
                      color: widget.isDark
                          ? Colors.white70
                          : const Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _basari() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            key: const ValueKey('atolye_basari'),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              const Text('🏆', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _t(
                      'Bütün hedefler tamam! Projen çalışıyor. İstersen kaydet ya da değiştirip yeniden dene.',
                      'Every goal is done! Your project works. Save it, or change it and try again.',
                      'Alle Ziele erreicht! Dein Projekt funktioniert. Speichere es oder ändere es und probier weiter.',
                      '¡Todos los objetivos cumplidos! Tu proyecto funciona. Guárdalo o cámbialo y prueba otra vez.'),
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: Color(0xFF1F7A33),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ]),
          ),
          if (widget.onDevam != null) ...[
            const SizedBox(height: 10),
            ElevatedButton(
              key: const ValueKey('atolye_devam'),
              onPressed: widget.onDevam,
              style: ElevatedButton.styleFrom(
                backgroundColor: _renk,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(_t('DEVAM', 'CONTINUE', 'WEITER', 'CONTINUAR'),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      );
}

/// Serbest (hedefsiz) Scratch atolyesi: "Projelerim"deki "Yeni proje".
class ScratchSerbestAtolye {
  ScratchSerbestAtolye._();
  static const String kimlik = 'scratch_serbest_atolye';
}
