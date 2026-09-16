import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import '../ui/press_button.dart';
import '../utils/lang.dart';

/// Ebeveyn kapisi.
///
/// Apple'in Cocuklar kategorisi kurali (1.3) satin alma, dis bag ve
/// ayarlarin "yetiskin seviyesinde bir gorevin arkasinda" olmasini
/// istiyor. Apple'in ornekleri arasinda basit bir carpma sorusu da var —
/// ama BIZ ONU KULLANAMAYIZ: bu uygulama 7-14 yasa mantik ve kodlama
/// ogretiyor, yani kendi mufredatimiz kapiyi kirmayi ogretiyor. 12
/// yasinda bir cocuk "12 x 4" sorusunu aninda gecer.
///
/// Bunun yerine ABCmouse'un kullandigi yontemi aliyoruz: **ebeveynin
/// dogum yili**. Bir cocuk kendi dogum yilini bilir ama ebeveyninkini
/// genelde bilmez, ve bilse bile bu bir bilgi sorusu — cozulecek bir
/// bulmaca degil.
///
/// Girilen yil HICBIR YERDE SAKLANMIYOR; sadece makul bir yetiskin
/// araligina dusuyor mu diye bakiliyor. Ekranda da bunu yaziyoruz,
/// cunku ebeveynden dogum yili istemek aciklama gerektirir.
class ParentGate {
  ParentGate._();

  /// Bir yetiskinin dogmus olabilecegi aralik. Ust sinir dinamik:
  /// en genc ebeveyn bugunden 18 yil once dogmus sayiliyor.
  static bool _plausible(int year) {
    final now = DateTime.now().year;
    return year >= now - 100 && year <= now - 18;
  }

  /// Kapiyi acar. Gecerse true doner.
  static Future<bool> verify(
    BuildContext context, {
    String? reason,
    String lang = AppLang.tr,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => _ParentGateDialog(reason: reason, lang: lang),
    );
    return ok ?? false;
  }
}

class _ParentGateDialog extends StatefulWidget {
  const _ParentGateDialog({this.reason, this.lang = AppLang.tr});

  final String? reason;
  final String lang;

  @override
  State<_ParentGateDialog> createState() => _ParentGateDialogState();
}

class _ParentGateDialogState extends State<_ParentGateDialog> {
  final _controller = TextEditingController();
  bool _wrong = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final year = int.tryParse(_controller.text.trim());
    if (year != null && ParentGate._plausible(year)) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() => _wrong = true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Text(
        AppLang.pick(widget.lang,
            tr: 'Bu bölüm ebeveynler için',
            en: 'This part is for parents',
            de: 'Dieser Bereich ist für Eltern',
            es: 'Esta sección es para madres y padres'),
        style: const TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontWeight: FontWeight.w800,
          fontSize: 19,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.reason ??
                AppLang.pick(widget.lang,
                    tr: 'Devam etmek için lütfen doğum yılınızı girin.',
                    en: 'Please enter your year of birth to continue.',
                    de: 'Bitte gib dein Geburtsjahr ein, um fortzufahren.',
                    es: 'Escribe tu año de nacimiento para continuar.'),
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 14,
              height: 1.4,
              color: AppTheme.mediumGray,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: 6,
            ),
            decoration: InputDecoration(
              hintText: '19••',
              errorText: _wrong
                  ? AppLang.pick(widget.lang,
                      tr: 'Bu bir doğum yılı gibi görünmüyor.',
                      en: 'That does not look like a year of birth.',
                      de: 'Das sieht nicht nach einem Geburtsjahr aus.',
                      es: 'Eso no parece un año de nacimiento.')
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onChanged: (_) {
              if (_wrong) setState(() => _wrong = false);
            },
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lock_outline_rounded,
                  size: 15, color: AppTheme.mediumGray),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  AppLang.pick(widget.lang,
                      tr: 'Girdiğiniz yıl kaydedilmiyor, hiçbir yere '
                          'gönderilmiyor. Sadece bu bölümü açmak için '
                          'kullanılıyor.',
                      en: 'The year you enter is not saved and never sent '
                          'anywhere. It is only used to open this section.',
                      de: 'Das eingegebene Jahr wird nicht gespeichert und '
                          'nirgendwohin gesendet. Es öffnet nur diesen '
                          'Bereich.',
                      es: 'El año que escribas no se guarda ni se envía a '
                          'ningún sitio. Solo sirve para abrir esta '
                          'sección.'),
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 11.5,
                    height: 1.35,
                    color: AppTheme.mediumGray.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(AppLang.pick(widget.lang,
              tr: 'Vazgeç', en: 'Cancel', de: 'Abbrechen', es: 'Cancelar')),
        ),
        PressButton(
          label: AppLang.pick(widget.lang,
              tr: 'Devam', en: 'Continue', de: 'Weiter', es: 'Continuar'),
          expand: false,
          onPressed: _submit,
        ),
      ],
    );
  }
}
