import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bilmece/devi_bilmeceleri_api.dart';
import '../theme.dart';
import '../utils/lang.dart';
import 'mascot.dart';

/// Devi'nin bilmecesi: ana sayfada her gun 3 mini soru.
///
/// Soru ana sayfada cevaplaniyor, ayri bir ekran acilmiyor. Cevap verince
/// dogru sik yesil, yanlis sik kirmizi oluyor ve Devi kisa bir aciklama
/// yapiyor. Uc soru bitince ozet; ertesi gun yeni uc soru.
///
/// Cevaplar o gunun anahtariyla cihazda tutuluyor (SharedPreferences):
/// uygulamayi kapatip acan cocuk kaldigi yerden devam ediyor, ayni gun
/// ayni soruyu tekrar cozup puan toplayamiyor. Odul (XP, jeton) YOK —
/// bilerek: odul vaat etmeyen bir merak alani.
class DeviBilmeceKarti extends StatefulWidget {
  const DeviBilmeceKarti({super.key, required this.lang, this.simdi});

  final String lang;

  /// Testler icin sabit gun.
  final DateTime? simdi;

  @override
  State<DeviBilmeceKarti> createState() => _DeviBilmeceKartiState();
}

class _DeviBilmeceKartiState extends State<DeviBilmeceKarti> {
  late final DateTime _gun = widget.simdi ?? DateTime.now();
  late final List<Bilmece> _sorular = DeviBilmeceleri.gunun(_gun);
  late final String _anahtar = 'devi_bilmece_${DeviBilmeceleri.gunAnahtari(_gun)}';

  /// Her soru icin secilen sik (-1 = cevaplanmadi).
  List<int> _secim = [-1, -1, -1];

  /// Cevabi gorulmus ama "Sonraki"ye basilmamis soru.
  bool _aciklamaAcik = false;

  String _t(String tr, String en, String de, String es) =>
      AppLang.pick(widget.lang, tr: tr, en: en, de: de, es: es);

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    try {
      final p = await SharedPreferences.getInstance();
      final kayit = p.getString(_anahtar);
      if (kayit == null || !mounted) return;
      final parca = kayit.split(',').map((e) => int.tryParse(e) ?? -1).toList();
      if (parca.length == 3) setState(() => _secim = parca);
    } catch (_) {
      // Kayit okunamazsa bastan; kart yine calisir.
    }
  }

  Future<void> _kaydet() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_anahtar, _secim.join(','));
    } catch (_) {}
  }

  int get _sira {
    final i = _secim.indexOf(-1);
    return i < 0 ? 3 : i;
  }

  void _sec(int soru, int sik) {
    if (_secim[soru] != -1) return;
    final dogru = sik == _sorular[soru].dogru;
    dogru ? HapticFeedback.mediumImpact() : HapticFeedback.heavyImpact();
    setState(() {
      _secim = [..._secim]..[soru] = sik;
      _aciklamaAcik = true;
    });
    _kaydet();
  }

  String _kategoriAdi(String k) => switch (k) {
        'scratch' => 'Scratch',
        'mblock' => 'mBlock',
        'arduino' => 'Arduino',
        'tinkercad' => 'Tinkercad',
        _ => _t('Donanım', 'Hardware', 'Hardware', 'Hardware'),
      };

  @override
  Widget build(BuildContext context) {
    final koyu = Theme.of(context).brightness == Brightness.dark;
    // Cevabi yeni verilen soru aciklamasiyla ekranda kaliyor.
    final gosterilen = _aciklamaAcik
        ? _secim.lastIndexWhere((s) => s != -1)
        : _sira;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _t("Devi'nin bilmecesi", "Devi's riddle", 'Devis Rätsel', 'El acertijo de Devi'),
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: koyu ? Colors.white : const Color(0xFF14161A),
                ),
              ),
            ),
            for (var i = 0; i < 3; i++)
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(left: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _secim[i] == -1
                      ? const Color(0xFFD9DCE3)
                      : (_secim[i] == _sorular[i].dogru
                          ? const Color(0xFF43A047)
                          : const Color(0xFFE53935)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
            ),
            boxShadow: const [
              BoxShadow(color: Color(0xFF4527A0), offset: Offset(0, 6)),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (c, a) => FadeTransition(
              opacity: a,
              child: SlideTransition(
                position: Tween(begin: const Offset(0.08, 0), end: Offset.zero).animate(a),
                child: c,
              ),
            ),
            child: gosterilen >= 3
                ? _ozet()
                : KeyedSubtree(key: ValueKey(gosterilen), child: _soru(gosterilen)),
          ),
        ),
      ],
    );
  }

  Widget _soru(int i) {
    final b = _sorular[i];
    final secilen = _secim[i];
    final cevaplandi = secilen != -1;
    final siklar = b.siklar(widget.lang);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(Mascot.durgunGorsel,
                width: 54,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.smart_toy_rounded, size: 48, color: Colors.white)),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 9, 12, 11),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_kategoriAdi(b.kategori)} · ${i + 1}/3',
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7C4DFF),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      b.soru(widget.lang),
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 14.5,
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF241C3B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var s = 0; s < 3; s++) ...[
          if (s > 0) const SizedBox(height: 8),
          _sik(siklar[s], s, b.dogru, secilen, () => _sec(i, s)),
        ],
        if (cevaplandi) ...[
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  '${secilen == b.dogru ? _t('Doğru! ', 'Correct! ', 'Richtig! ', '¡Correcto! ') : _t('Bu sefer olmadı. ', 'Not this time. ', 'Diesmal nicht. ', 'Esta vez no. ')}${b.aciklama(widget.lang)}',
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => setState(() => _aciklamaAcik = false),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 8, 10, 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        i < 2
                            ? _t('Sonraki', 'Next', 'Weiter', 'Siguiente')
                            : _t('Bitir', 'Finish', 'Fertig', 'Terminar'),
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF5E35B1),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF5E35B1)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _sik(String yazi, int s, int dogru, int secilen, VoidCallback onTap) {
    final cevaplandi = secilen != -1;
    Color zemin = Colors.white.withValues(alpha: 0.16);
    Color kenar = Colors.white.withValues(alpha: 0.4);
    Color metin = Colors.white;
    IconData? simge;
    if (cevaplandi && s == dogru) {
      zemin = Colors.white;
      kenar = Colors.white;
      metin = const Color(0xFF2E7D32);
      simge = Icons.check_circle_rounded;
    } else if (cevaplandi && s == secilen) {
      zemin = const Color(0xFFE53935);
      kenar = const Color(0xFFE53935);
      simge = Icons.cancel_rounded;
    } else if (cevaplandi) {
      metin = Colors.white.withValues(alpha: 0.6);
    }
    return GestureDetector(
      onTap: cevaplandi ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: zemin,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kenar, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                yazi,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: metin,
                ),
              ),
            ),
            if (simge != null) Icon(simge, size: 20, color: metin),
          ],
        ),
      ),
    );
  }

  Widget _ozet() {
    final dogru = [for (var i = 0; i < 3; i++) if (_secim[i] == _sorular[i].dogru) i].length;
    return Row(
      key: const ValueKey('ozet'),
      children: [
        Image.asset(Mascot.durgunGorsel,
            width: 72,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.smart_toy_rounded, size: 60, color: Colors.white)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dogru == 3
                    ? _t('Harika, 3/3!', 'Awesome, 3/3!', 'Super, 3/3!', '¡Genial, 3/3!')
                    : _t('Bugün $dogru/3 doğru', 'Today: $dogru/3 right', 'Heute: $dogru/3 richtig', 'Hoy: $dogru/3 bien'),
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _t('Yarın üç yeni bilmece seni bekliyor.', 'Three new riddles are waiting tomorrow.',
                    'Morgen warten drei neue Rätsel.', 'Mañana te esperan tres acertijos nuevos.'),
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
