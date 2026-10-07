import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../screens/parent/cocuk_raporu_screen.dart';
import '../screens/parent/takip_kodu_screen.dart';
import '../services/child_link_service.dart';
import '../services/cocuk_raporu_kaynagi.dart';
import '../theme.dart';
import '../utils/lang.dart';

/// Profilde, "Ilerlemeni kaydet"in USTUNDE duran veli takibi karti.
///
/// NEDEN BURADA VE NEDEN BU KADAR SADE (Ekim 2026 geri bildirimi):
/// Eskiden kod girmek icin Ayarlar → Ebeveyn Alani → dogum yili kapisi →
/// "Kod gir" → diyalog yolu izleniyordu; veli kodu nereye yazacagini
/// bulamiyordu. Simdi: Profil'i ac, kodu yaz, bitti. Alti karakter
/// tamamlaninca baglanti kendiliginden kuruluyor ve rapor aciliyor.
///
/// Dogum yili sorulmuyor: kodu gormek zaten cocugun cihazina fiziksel
/// erisim gerektiriyor, kod 24 saatlik ve tek kullanimlik. Kapinin
/// koruyacagi bir sey kalmiyordu, yalnizca veliyi yoruyordu.
///
/// Birden fazla cocuk eklenebiliyor; her biri ayri bir satir.
class VeliTakipKarti extends StatefulWidget {
  const VeliTakipKarti({
    super.key,
    this.cocuklariGetir = ChildLinkService.linkedChildren,
    this.kodKullan = ChildLinkService.redeem,
    this.raporYukle = cocukRaporuYukle,
  });

  final Future<List<ChildLink>> Function() cocuklariGetir;
  final Future<String?> Function(String kod) kodKullan;
  final CocukRaporuYukleyici raporYukle;

  @override
  State<VeliTakipKarti> createState() => _VeliTakipKartiState();
}

class _VeliTakipKartiState extends State<VeliTakipKarti> {
  final _kod = TextEditingController();
  final _odak = FocusNode();

  List<ChildLink> _cocuklar = const [];
  bool _yuklendi = false;
  bool _girisAcik = false;
  bool _mesgul = false;
  String? _hata;

  String get _lang => Localizations.localeOf(context).languageCode;
  String _t(String tr, String en, String de, String es) =>
      AppLang.pick(_lang, tr: tr, en: en, de: de, es: es);

  @override
  void initState() {
    super.initState();
    _yenile();
  }

  @override
  void dispose() {
    _kod.dispose();
    _odak.dispose();
    super.dispose();
  }

  Future<void> _yenile() async {
    List<ChildLink> liste;
    try {
      liste = await widget.cocuklariGetir();
    } catch (_) {
      liste = const [];
    }
    if (!mounted) return;
    setState(() {
      _cocuklar = liste;
      _yuklendi = true;
    });
  }

  static String _temiz(String s) =>
      s.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();

  Future<void> _bagla() async {
    final kod = _temiz(_kod.text);
    if (_mesgul) return;
    if (kod.length != 6) {
      setState(() => _hata = _t(
          'Kod 6 karakter olmalı.',
          'The code has 6 characters.',
          'Der Code hat 6 Zeichen.',
          'El código tiene 6 caracteres.'));
      return;
    }
    setState(() {
      _mesgul = true;
      _hata = null;
    });
    String? cocukId;
    try {
      cocukId = await widget.kodKullan(kod);
    } catch (_) {
      cocukId = null;
    }
    if (!mounted) return;
    if (cocukId == null) {
      HapticFeedback.heavyImpact();
      setState(() {
        _mesgul = false;
        _hata = _t(
          'Bu kod çalışmadı. Kodlar 24 saat geçerli ve bir kez kullanılır; '
              'çocuğunun ekranındaki güncel kodu dene.',
          "That code didn't work. Codes last 24 hours and work once; "
              "try the current code on your child's screen.",
          'Dieser Code hat nicht geklappt. Codes gelten 24 Stunden und nur '
              'einmal; nimm den aktuellen Code vom Gerät deines Kindes.',
          'Ese código no ha funcionado. Los códigos duran 24 horas y sirven '
              'una vez; prueba el código actual de la pantalla de tu hijo/a.',
        );
      });
      return;
    }

    final id = cocukId;
    HapticFeedback.mediumImpact();
    List<ChildLink> liste;
    try {
      liste = await widget.cocuklariGetir();
    } catch (_) {
      liste = const [];
    }
    if (!mounted) return;
    final cocuk = liste.firstWhere(
      (c) => c.childId == id,
      orElse: () => ChildLink(childId: id),
    );
    setState(() {
      _cocuklar = liste.any((c) => c.childId == id)
          ? liste
          : [...liste, cocuk];
      _mesgul = false;
      _girisAcik = false;
      _kod.clear();
    });
    _odak.unfocus();
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF2E7D32),
      content: Text(
        _t('Bağlandı! 🎉 Raporu açıyoruz…', 'Connected! 🎉 Opening the report…',
            'Verbunden! 🎉 Bericht wird geöffnet…', '¡Conectado! 🎉 Abriendo el informe…'),
        style: const TextStyle(
            fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w800),
      ),
    ));
    await _raporuAc(cocuk);
  }

  Future<void> _raporuAc(ChildLink cocuk) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) =>
          CocukRaporuScreen(cocuk: cocuk, yukleyici: widget.raporYukle),
    ));
    if (mounted) _yenile();
  }

  @override
  Widget build(BuildContext context) {
    final koyu = Theme.of(context).brightness == Brightness.dark;
    final zemin = koyu ? const Color(0xFF1E1E2E) : Colors.white;
    final yazi = koyu ? Colors.white : const Color(0xFF1F1B3A);
    final soluk = koyu ? Colors.white70 : const Color(0xFF6E6A85);
    final cocukVar = _cocuklar.isNotEmpty;
    final girisGoster = !cocukVar || _girisAcik;

    return Container(
      key: const ValueKey('veli_takip_karti'),
      decoration: BoxDecoration(
        color: zemin,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00A88F).withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00A88F).withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF00C9A7), Color(0xFF00A0C6)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.family_restroom_rounded,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t('Çocuğumu takip et', "Follow my child",
                            'Mein Kind begleiten', 'Seguir a mi hijo/a'),
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                          color: yazi,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        cocukVar
                            ? _t('Raporu görmek için dokun',
                                'Tap to see the report',
                                'Tippe, um den Bericht zu sehen',
                                'Toca para ver el informe')
                            : _t(
                                'Çocuğunun ekranındaki 6 karakterlik kodu yaz, '
                                    'raporu hemen gör.',
                                "Type the 6-character code from your child's "
                                    'screen and see the report right away.',
                                'Gib den 6-stelligen Code vom Gerät deines '
                                    'Kindes ein und sieh sofort den Bericht.',
                                'Escribe el código de 6 caracteres de la '
                                    'pantalla de tu hijo/a y mira el informe.'),
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12.5,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                          color: soluk,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (cocukVar) ...[
            const SizedBox(height: 12),
            for (var i = 0; i < _cocuklar.length; i++)
              _cocukSatiri(_cocuklar[i], i, yazi, soluk, koyu),
          ],
          if (girisGoster)
            _kodGirisi(koyu, yazi)
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 2, 10, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: const ValueKey('baska_cocuk_ekle'),
                  onPressed: () {
                    setState(() => _girisAcik = true);
                    _odak.requestFocus();
                  },
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                  label: Text(
                    _t('Başka bir çocuk ekle', 'Add another child',
                        'Weiteres Kind hinzufügen', 'Añadir otro hijo/a'),
                    style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontWeight: FontWeight.w800),
                  ),
                  style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF00897B)),
                ),
              ),
            ),
          Divider(
              height: 18,
              indent: 16,
              endIndent: 16,
              color: soluk.withValues(alpha: 0.2)),
          InkWell(
            key: const ValueKey('kodumu_goster'),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(20)),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TakipKoduScreen()),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 12, 14),
              child: Row(
                children: [
                  Icon(Icons.qr_code_2_rounded, size: 20, color: soluk),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _t('Öğrenci misin? Velin için kodunu göster',
                          'Are you the student? Show your code to a parent',
                          'Bist du Schüler? Zeig deinen Code für deine Eltern',
                          '¿Eres estudiante? Muestra tu código a tu familia'),
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: soluk,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: soluk),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _renkler = [
    Color(0xFF7C4DFF),
    Color(0xFFFF7043),
    Color(0xFF26A69A),
    Color(0xFF42A5F5),
    Color(0xFFEC407A),
  ];

  Widget _cocukSatiri(
      ChildLink c, int i, Color yazi, Color soluk, bool koyu) {
    final renk = _renkler[i % _renkler.length];
    final ad = (c.childName ?? '').trim();
    final gosterilen = ad.isEmpty
        ? _t('Çocuğum ${i + 1}', 'Child ${i + 1}', 'Kind ${i + 1}',
            'Hijo/a ${i + 1}')
        : ad;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Material(
        color: renk.withValues(alpha: koyu ? 0.18 : 0.08),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          key: ValueKey('cocuk_${c.childId}'),
          borderRadius: BorderRadius.circular(14),
          onTap: () => _raporuAc(c),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor: renk,
                  child: Text(
                    gosterilen.characters.first.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    gosterilen,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: yazi,
                    ),
                  ),
                ),
                Text(
                  _t('Raporu gör', 'See report', 'Bericht', 'Ver informe'),
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color.lerp(renk, Colors.black, 0.15),
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: Color.lerp(renk, Colors.black, 0.15)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _kodGirisi(bool koyu, Color yazi) {
    const vurgu = Color(0xFF00897B);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  key: const ValueKey('veli_kod_alani'),
                  controller: _kod,
                  focusNode: _odak,
                  enabled: !_mesgul,
                  textCapitalization: TextCapitalization.characters,
                  textAlign: TextAlign.center,
                  autocorrect: false,
                  enableSuggestions: false,
                  inputFormatters: [_KodBicimi()],
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _bagla(),
                  onChanged: (v) {
                    if (_hata != null) setState(() => _hata = null);
                    // Alti karakter tamamlaninca kendiliginden bagla.
                    if (_temiz(v).length == 6) _bagla();
                  },
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    color: yazi,
                  ),
                  decoration: InputDecoration(
                    hintText: 'ABC-123',
                    hintStyle: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 22,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w800,
                      color: yazi.withValues(alpha: 0.22),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 13),
                    filled: true,
                    fillColor: vurgu.withValues(alpha: koyu ? 0.15 : 0.06),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                          color: _hata != null
                              ? const Color(0xFFE57373)
                              : vurgu.withValues(alpha: 0.35),
                          width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: vurgu, width: 2),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          BorderSide(color: vurgu.withValues(alpha: 0.2)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 52,
                child: FilledButton(
                  key: const ValueKey('veli_bagla'),
                  onPressed: _mesgul ? null : _bagla,
                  style: FilledButton.styleFrom(
                    backgroundColor: vurgu,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _mesgul
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(
                          _t('Bağla', 'Link', 'Verbinden', 'Vincular'),
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
              ),
            ],
          ),
          if (_hata != null) ...[
            const SizedBox(height: 8),
            Text(
              _hata!,
              key: const ValueKey('veli_kod_hata'),
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12.5,
                height: 1.35,
                fontWeight: FontWeight.w700,
                color: Color(0xFFD84315),
              ),
            ),
          ],
          if (!_yuklendi) const SizedBox(height: 2),
        ],
      ),
    );
  }
}

/// Yazilani "ABC-123" bicimine sokar: buyuk harf, yalnizca harf/rakam,
/// ucuncu karakterden sonra tire, en fazla 6 karakter.
class _KodBicimi extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var ham = newValue.text.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    if (ham.length > 6) ham = ham.substring(0, 6);
    final metin = ham.length > 3 ? '${ham.substring(0, 3)}-${ham.substring(3)}' : ham;
    return TextEditingValue(
      text: metin,
      selection: TextSelection.collapsed(offset: metin.length),
    );
  }
}
