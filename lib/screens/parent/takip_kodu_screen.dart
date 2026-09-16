import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/child_link_service.dart';
import '../../theme.dart';
import '../../utils/lang.dart';

/// "Etkinliklerimi velimle paylaş" — çocuğa yazılmış ekran.
///
/// Başlık bilerek KODU değil PAYLAŞILAN ŞEYİ anlatıyor: "kodunu paylaş"
/// bir çocuğa ne verdiğini söylemiyor, "etkinliklerimi paylaş" söylüyor.
///
/// Aynı kod Ebeveyn Alanı'nda da görünüyor; burası ebeveyn kapısının
/// ÖNÜNDE duruyor, yani kodu çocuk da alıp velisine verebiliyor.
///
/// Bunun bir bedeli var ve ekran o bedeli saklamıyor: kodu alan kişi
/// çocuğun adını ve neler yaptığını görebiliyor. Bu yüzden ekranda üç
/// şey birden var:
///
///  * kodun ne işe yaradığını çocuğun anlayacağı dilde bir cümle,
///  * "bu kodu sadece annene ya da babana ver" uyarısı,
///  * kaç kişinin takip ettiği ve **hepsini kaldırma** düğmesi.
///
/// Son madde en önemlisi: takip özelliğini çocuğun eline veriyorsak,
/// kapatmayı da onun eline vermemiz gerekiyor.
class TakipKoduScreen extends StatefulWidget {
  const TakipKoduScreen({super.key});

  @override
  State<TakipKoduScreen> createState() => _TakipKoduScreenState();
}

class _TakipKoduScreenState extends State<TakipKoduScreen> {
  String? _kod;
  int _takipci = 0;
  bool _yukleniyor = true;

  String get _lang => Localizations.localeOf(context).languageCode;

  String _t(String tr, String en, [String? de, String? es]) =>
      AppLang.pick(_lang, tr: tr, en: en, de: de, es: es);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _yukle());
  }

  Future<void> _yukle() async {
    final kod = await ChildLinkService.currentCode();
    final takipci = await ChildLinkService.watcherCount();
    if (!mounted) return;
    setState(() {
      _kod = kod;
      _takipci = takipci;
      _yukleniyor = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F9),
      appBar: AppBar(
        title: Text(_t(
            'Etkinliklerimi paylaş',
            'Share my activity',
            'Meine Aktivität teilen',
            'Compartir mi actividad')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _kart(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t(
                    'Annen ya da baban bu kodu kendi telefonundaki '
                        'uygulamaya yazarsa, neler öğrendiğini oradan '
                        'görebilir.',
                    'If a parent types this code into the app on their own '
                        'phone, they can see what you are learning.',
                    'Wenn Mama oder Papa diesen Code in der App auf ihrem '
                        'Telefon eingibt, sehen sie, was du lernst.',
                    'Si tu madre o tu padre escribe este código en la app de '
                        'su móvil, podrá ver lo que estás aprendiendo.',
                  ),
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 14,
                    height: 1.45,
                    color: AppTheme.darkGray,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.30),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _yukleniyor || _kod == null
                        ? '••• •••'
                        : ChildLinkService.pretty(_kod!),
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 5,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _t(
                      'Kod 24 saat geçerli.',
                      'The code is valid for 24 hours.',
                      'Der Code gilt 24 Stunden.',
                      'El código vale 24 horas.'),
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12.5,
                    color: AppTheme.mediumGray,
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _kod == null
                        ? null
                        : () async {
                            await ChildLinkService.revokeCode();
                            if (mounted) {
                              setState(() => _yukleniyor = true);
                              _yukle();
                            }
                          },
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(_t('Yeni kod', 'New code', 'Neuer Code',
                        'Código nuevo')),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // UYARI. Bu ekranin var olma sebebi kodun cocugun elinde
          // olmasi; o yuzden riski de cocugun diliyle yaziyoruz.
          _kart(
            renk: AppTheme.warningOrange,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_rounded,
                    color: AppTheme.warningOrange, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _t(
                      'Bu kodu sadece annene ya da babana ver. Kodu alan '
                          'kişi adını ve neler yaptığını görebilir — '
                          'tanımadığın birine verme.',
                      'Only give this code to a parent. Whoever has it can '
                          'see your name and what you do — do not give it to '
                          'someone you do not know.',
                      'Gib diesen Code nur deinen Eltern. Wer ihn hat, sieht '
                          'deinen Namen und was du machst — gib ihn niemandem, '
                          'den du nicht kennst.',
                      'Dale este código solo a tu madre o a tu padre. Quien '
                          'lo tenga verá tu nombre y lo que haces: no se lo '
                          'des a alguien que no conoces.',
                    ),
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 13,
                      height: 1.45,
                      color: AppTheme.darkGray,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Takipciler. Ozelligi acan da kapatan da cocuk olabilmeli.
          _kart(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _takipci == 0
                        ? _t(
                            'Şu an kimse takip etmiyor.',
                            'Nobody is following right now.',
                            'Gerade folgt dir niemand.',
                            'Ahora mismo no te sigue nadie.')
                        : _t(
                            '$_takipci kişi takip ediyor.',
                            '$_takipci following you.',
                            '$_takipci folgen dir.',
                            '$_takipci te siguen.'),
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkGray,
                    ),
                  ),
                ),
                if (_takipci > 0)
                  TextButton(
                    onPressed: () async {
                      await ChildLinkService.unlinkAllWatchers();
                      HapticFeedback.mediumImpact();
                      if (mounted) _yukle();
                    },
                    child: Text(_t('Hepsini kaldır', 'Remove all',
                        'Alle entfernen', 'Quitar a todos')),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kart({required Widget child, Color? renk}) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: renk == null
              ? null
              : Border.all(color: renk.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      );
}
