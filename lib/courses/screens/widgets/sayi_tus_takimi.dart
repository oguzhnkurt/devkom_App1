import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme.dart';
import '../../../utils/lang.dart';

/// Blogun sayisini degistiren kucuk tus takimi.
///
/// Scratch'te cocuk beyaz ovale dokunup sayiyi yaziyor: `10 adim git`
/// `50 adim git` oluyor, `4 defa tekrarla` `3 defa tekrarla`. Telefonda
/// sistem klavyesi ekranin yarisini kapatip sahneyi gizliyordu; bu tus
/// takimi yalnizca rakam, eksi ve sil tasiyor, buyuk tuslu.
class SayiTusTakimi extends StatefulWidget {
  const SayiTusTakimi({
    super.key,
    required this.baslangic,
    required this.lang,
    this.renk = const Color(0xFF4C97FF),
    this.enFazlaHane = 4,
  });

  final num baslangic;
  final String lang;
  final Color renk;
  final int enFazlaHane;

  /// Alttan acilan tus takimi; secilen sayiyi (ya da vazgecildiyse null)
  /// dondurur.
  static Future<num?> goster(BuildContext context,
      {required num baslangic, required String lang, Color? renk}) {
    return showModalBottomSheet<num>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SayiTusTakimi(
        baslangic: baslangic,
        lang: lang,
        renk: renk ?? const Color(0xFF4C97FF),
      ),
    );
  }

  @override
  State<SayiTusTakimi> createState() => _SayiTusTakimiState();
}

class _SayiTusTakimiState extends State<SayiTusTakimi> {
  late String _yazi = _bicim(widget.baslangic);

  /// Ilk tus eski sayinin USTUNE yaziyor (Scratch'te de oval secili
  /// aciliyor); sonraki tuslar ekliyor.
  bool _ilk = true;

  static String _bicim(num n) =>
      n == n.roundToDouble() ? '${n.toInt()}' : '$n';

  String _t(String tr, String en, String de, String es) =>
      AppLang.pick(widget.lang, tr: tr, en: en, de: de, es: es);

  void _rakam(String r) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_ilk || _yazi == '0') {
        _yazi = r;
      } else if (_yazi.replaceAll('-', '').length < widget.enFazlaHane) {
        _yazi += r;
      }
      _ilk = false;
    });
  }

  void _eksi() {
    HapticFeedback.selectionClick();
    setState(() {
      _yazi = _yazi.startsWith('-') ? _yazi.substring(1) : '-$_yazi';
      _ilk = false;
    });
  }

  void _sil() {
    HapticFeedback.selectionClick();
    setState(() {
      _yazi = _yazi.length <= 1 || (_yazi.length == 2 && _yazi.startsWith('-'))
          ? '0'
          : _yazi.substring(0, _yazi.length - 1);
      _ilk = false;
    });
  }

  Widget _tus(String yazi, VoidCallback onTap, {Key? key, IconData? ikon}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: const Color(0xFFF2F4F8),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            key: key,
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: SizedBox(
              height: 52,
              child: Center(
                child: ikon != null
                    ? Icon(ikon, color: const Color(0xFF575E75))
                    : Text(
                        yazi,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF575E75),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final alt = MediaQuery.of(context).padding.bottom;
    Widget sira(List<String> r) => Row(children: [
          for (final x in r)
            _tus(x, () => _rakam(x), key: ValueKey('sayi_tus_$x')),
        ]);
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + alt),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _t('Sayıyı yaz', 'Type the number', 'Gib die Zahl ein',
                'Escribe el número'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF575E75),
            ),
          ),
          const SizedBox(height: 10),
          // Scratch'in beyaz ovali.
          Center(
            child: Container(
              key: const ValueKey('sayi_gostergesi'),
              constraints: const BoxConstraints(minWidth: 120),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: widget.renk, width: 2.5),
              ),
              child: Text(
                _yazi,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF575E75),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          sira(['1', '2', '3']),
          sira(['4', '5', '6']),
          sira(['7', '8', '9']),
          Row(children: [
            _tus('−', _eksi, key: const ValueKey('sayi_tus_eksi')),
            _tus('0', () => _rakam('0'), key: const ValueKey('sayi_tus_0')),
            _tus('', _sil,
                key: const ValueKey('sayi_tus_sil'),
                ikon: Icons.backspace_outlined),
          ]),
          const SizedBox(height: 8),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              key: const ValueKey('sayi_tamam'),
              onPressed: () => Navigator.pop(context, num.parse(_yazi)),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.renk,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                _t('Tamam', 'OK', 'OK', 'Aceptar'),
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
