import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/lang.dart';

/// Bir widget çizilirken istisna fırlarsa gösterilen ekran.
///
/// NEDEN VAR
/// ---------
/// Flutter, bir widget'ın `build`i istisna fırlattığında onun yerine
/// `ErrorWidget` çiziyor. Hata ayıklama derlemesinde bu kırmızı, sarı
/// yazılı meşhur ekran; **yayın derlemesinde ise düz gri bir dikdörtgen**
/// (`0xF0C0C0C0`), tek bir kelime bile yazmadan.
///
/// Kullanıcı bunu böyle yaşıyordu: hesabını oluşturuyor, ekran griye
/// dönüyor ve orada kalıyor. Geri dönüş yok, açıklama yok, bize
/// ulaşacak bir ipucu yok. Aynı hata hata ayıklama derlemesinde
/// "kırmızı ekran" diye bildirilmişti — ikisi aynı şeydi, kimse
/// eşleştirememişti.
///
/// Bu ekran o griliğin yerine geçiyor:
///
///   * Çocuğa anlayacağı bir cümle ve **çıkış yolu** veriyor.
///   * Teknik ayrıntıyı saklıyor ama yok etmiyor: başlığa uzun basınca
///     hata metni ve yığın izi açılıyor, kopyalanabiliyor. Telefon
///     kabloyla bilgisayara bağlanamadığında tek teşhis yolu bu.
///   * Hatayı `debugPrint` ile günlüğe de yazıyor; `debugPrint` yayın
///     derlemesinde de çalışıyor.
///
/// NOT: Bu ekran hatayı DÜZELTMEZ. Yalnızca sessiz bir duvarı,
/// bildirilebilir ve çıkılabilir bir duruma çevirir.
class HataEkrani extends StatefulWidget {
  const HataEkrani({super.key, required this.detay, this.dil = AppLang.tr});

  /// Flutter'ın verdiği hata özeti + yığın izi.
  final String detay;

  final String dil;

  @override
  State<HataEkrani> createState() => _HataEkraniState();
}

class _HataEkraniState extends State<HataEkrani> {
  bool _ayrinti = false;

  String _t(String tr, String en, String de, String es) =>
      AppLang.pick(widget.dil, tr: tr, en: en, de: de, es: es);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        color: const Color(0xFFF5F7FA),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🙈', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 18),
                  GestureDetector(
                    // Gizli tani yolu: teknik ayrinti cocugun karsisina
                    // kendiliginden cikmasin ama kaybolmasin da.
                    onLongPress: () => setState(() => _ayrinti = !_ayrinti),
                    child: Text(
                      _t(
                        'Bir şeyler ters gitti',
                        'Something went wrong',
                        'Etwas ist schiefgelaufen',
                        'Algo ha salido mal',
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF243447),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _t(
                      'Bu ekran açılamadı. Geri dönüp tekrar deneyebilirsin.',
                      'This screen could not open. Go back and try again.',
                      'Dieser Bildschirm konnte nicht geöffnet werden. '
                          'Geh zurück und versuch es erneut.',
                      'Esta pantalla no se ha podido abrir. Vuelve e '
                          'inténtalo de nuevo.',
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14.5,
                      height: 1.35,
                      color: Color(0xFF5B6B7F),
                    ),
                  ),
                  const SizedBox(height: 22),
                  // `Navigator.of` DEGIL `maybeOf`: bu ekran bir hata
                  // yerine geciyor ve agacin Navigator'suz bir yerinde
                  // de cizilebilir. `of` orada firlatirdi -- yani hata
                  // ekraninin kendisi hata verirdi.
                  if (Navigator.maybeOf(context)?.canPop() ?? false)
                    FilledButton(
                      onPressed: () => Navigator.maybeOf(context)?.maybePop(),
                      child: Text(_t('Geri dön', 'Go back', 'Zurück',
                          'Volver')),
                    ),
                  if (_ayrinti) ...[
                    const SizedBox(height: 22),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2430),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SelectableText(
                        widget.detay,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          height: 1.35,
                          color: Color(0xFFE6EDF3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => Clipboard.setData(
                          ClipboardData(text: widget.detay)),
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: Text(_t('Hatayı kopyala', 'Copy the error',
                          'Fehler kopieren', 'Copiar el error')),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// `ErrorWidget.builder`ı bu ekrana bağlar ve hatayı günlüğe yazar.
///
/// `main()` içinde, `runApp`tan ÖNCE çağrılıyor.
void hataEkraniniKur() {
  ErrorWidget.builder = (FlutterErrorDetails ayrinti) {
    // Gunluge yaz: kabloyla bagli bir Mac varsa tek satirdan gorulsun.
    // debugPrint yayin derlemesinde de calisiyor.
    debugPrint('🟥 WIDGET HATASI: ${ayrinti.exception}');
    final iz = ayrinti.stack?.toString();
    if (iz != null) {
      // Yigin izinin tamami gunlugu bogar; ilk satirlar zaten yeter.
      debugPrint(iz.split('\n').take(12).join('\n'));
    }

    final metin = StringBuffer()
      ..writeln(ayrinti.exception.toString())
      ..writeln()
      ..writeln(iz?.split('\n').take(20).join('\n') ?? '');

    return HataEkrani(detay: metin.toString());
  };
}
