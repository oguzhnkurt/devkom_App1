import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `context.watch` build DIŞINDA çağrılmamalı.
///
/// Provider, build dışından dinlemeye kalkınca assertion atıyor:
///
///     Tried to listen to a value exposed with provider,
///     from outside of the widget tree.
///
/// Bu istisna bir `onTap` içinde patladığında **hiçbir şey olmuyor** —
/// ekranda hata görünmüyor, düğme ölü gibi davranıyor. Bu oturumda iki
/// kez bu yüzden özellik kaybedildi:
///
///  * `onboarding_flow_screen` — `_lang` getter'ı `context.watch`
///    kullanıyordu; "Başka bir tane öner" düğmesi ve `_finish()` sessizce
///    çalışmıyordu.
///  * `interactive_course_screen` — `_kilitli()` build içinde `watch`
///    kullanıyor; `_openLesson` (bir onTap işleyicisi) onu çağırınca
///    kilitli derse dokunmak HİÇBİR ŞEY yapmıyordu. Reklamla ders açma
///    özelliği çalışma zamanında tamamen ölüydü.
///
/// Bu test, bilinen riskli çağrıların doğru biçimde yapıldığını kontrol
/// ediyor.
void main() {
  test('interactive_course_screen: _openLesson dinlemiyor', () {
    final k = File('lib/courses/screens/interactive_course_screen.dart')
        .readAsStringSync();

    final govde = k.substring(k.indexOf('Future<void> _openLesson('));
    final ilkKilitli = govde.indexOf('_kilitli(lesson');
    expect(ilkKilitli, isNot(-1));
    expect(
      govde.substring(ilkKilitli, ilkKilitli + 40).contains('dinle: false'),
      isTrue,
      reason: '_openLesson bir onTap işleyicisi; _kilitli oradan '
          'context.watch ile çağrılırsa provider assertion atar ve '
          'dokunma sessizce hiçbir şey yapmaz',
    );
  });

  test('_openLesson lessonLang DEGIL lessonLangRead kullaniyor', () {
    // lessonLang context.watch kullanıyor ve yorumunda "Call this from
    // build()" yazıyor. _openLesson build değil; ilk düzeltmeden sonra
    // hata AYNEN devam etti, çünkü asıl dinleyen çağrı buydu.
    final k = File('lib/courses/screens/interactive_course_screen.dart')
        .readAsStringSync();
    final govde = k.substring(k.indexOf('Future<void> _openLesson('));
    final son = govde.indexOf('MaterialPageRoute(');
    final acilis = govde.substring(0, son == -1 ? govde.length : son);
    expect(acilis.contains('lessonLang(context)'), isFalse,
        reason: 'dinleyen sürüm bir onTap işleyicisinde');
    expect(acilis.contains('lessonLangRead(context)'), isTrue);
  });

  test('_kilitli dinle parametresini tasiyor', () {
    final k = File('lib/courses/screens/interactive_course_screen.dart')
        .readAsStringSync();
    expect(k.contains('bool _kilitli(InteractiveLesson lesson, {bool dinle'),
        isTrue);
    expect(k.contains('ProGate.isPro(context)'), isTrue,
        reason: 'dinlemeyen yol read sürümünü kullanmalı');
  });

  test('onboarding_flow_screen: _lang bir getter degil', () {
    final k =
        File('lib/screens/auth/onboarding_flow_screen.dart').readAsStringSync();
    expect(k.contains('String get _lang'), isFalse,
        reason: 'getter olursa olay işleyicilerinden de çağrılır ve '
            'context.watch build dışına kaçar');
    expect(k.contains('String _lang = AppLang.tr'), isTrue);
  });
}
