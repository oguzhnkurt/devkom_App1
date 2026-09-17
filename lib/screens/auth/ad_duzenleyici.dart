import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/lang.dart';
import '../../utils/nickname_generator.dart';

/// Takma ad düzenleme sayfası.
///
/// NEDEN AYRI BİR DOSYA
///
/// Bu düzenleyici profil ekranının içinde, `_showNameEditor` diye
/// yazılmıştı. Hesap ekranı açılınca aynı düzenleyiciye ikinci bir yerden
/// ihtiyaç oldu; kopyalamak yerine tek yere taşındı. Kopyalansaydı iki
/// ayrı doğrulama kuralı olurdu ve biri güncellenmeyi unuturdu.
///
/// DENETLEYİCİ SAYFANIN İÇİNDE YAŞIYOR. Önceki sürümde profil ekranının
/// State'ine bağlıydı, çünkü modal içinde oluşturulup `showModalBottomSheet`
/// döner dönmez atılınca kapanma animasyonu sürerken TextField hâlâ onu
/// dinliyor ve "used after being disposed" kırmızı ekranı geliyordu.
/// Burada denetleyici widget'la birlikte yaşayıp onunla birlikte
/// atıldığı için o yarış hiç oluşmuyor.
Future<void> adDuzenleyiciyiAc(BuildContext context, String mevcutAd) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (_) => _AdDuzenleyici(mevcutAd: mevcutAd),
  );
}

class _AdDuzenleyici extends StatefulWidget {
  const _AdDuzenleyici({required this.mevcutAd});

  final String mevcutAd;

  @override
  State<_AdDuzenleyici> createState() => _AdDuzenleyiciState();
}

class _AdDuzenleyiciState extends State<_AdDuzenleyici> {
  late final TextEditingController _c =
      TextEditingController(text: widget.mevcutAd);
  String? _hata;
  bool _kaydediyor = false;

  String get _lang => Localizations.localeOf(context).languageCode;

  String _t(String tr, String en, String de, String es) =>
      AppLang.pick(_lang, tr: tr, en: en, de: de, es: es);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _kaydet() async {
    final hata = NicknameGenerator.validate(_c.text, _lang);
    if (hata != null) {
      setState(() => _hata = hata);
      return;
    }
    setState(() => _kaydediyor = true);
    final ok = await context.read<AuthProvider>().updateDisplayName(_c.text);
    if (!mounted) return;
    setState(() => _kaydediyor = false);
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() => _hata = _t(
          'Kaydedilemedi, tekrar dene.',
          'Could not save. Please try again.',
          'Konnte nicht gespeichert werden. Bitte versuch es erneut.',
          'No se pudo guardar. Inténtalo de nuevo.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.viewInsetsOf(context).bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('Takma adın', 'Your nickname', 'Dein Spitzname', 'Tu apodo'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            // GERÇEK AD İSTEMİYORUZ. Sıralamada görünen bir alan; çocuğun
            // gerçek adını oraya yazması, adını tanımadığı kişilere
            // göstermesi demek.
            _t(
                'Sıralamada ve profilinde bu ad görünüyor. Gerçek adını ya '
                    'da e-postanı yazma.',
                'This name shows on the leaderboard and your profile. Do not '
                    'use your real name or your email.',
                'Dieser Name steht in der Bestenliste und in deinem Profil. '
                    'Nutze weder deinen echten Namen noch deine E-Mail.',
                'Este nombre aparece en la clasificación y en tu perfil. No '
                    'uses tu nombre real ni tu correo.'),
            style: TextStyle(fontSize: 12.5, color: Colors.grey[600], height: 1.4),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _c,
            autofocus: true,
            maxLength: 20,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _kaydet(),
            decoration: InputDecoration(
              hintText: _t('Örn. MeraklıPiksel317', 'e.g. CuriousPixel317',
                  'z. B. NeugierigPixel317', 'p. ej. PixelCurioso317'),
              errorText: _hata,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                _c.text = NicknameGenerator.generate(_lang);
                setState(() => _hata = null);
              },
              icon: const Icon(Icons.casino_rounded, size: 18),
              label: Text(_t('Bana bir ad öner', 'Suggest a name for me',
                  'Schlag mir einen Namen vor', 'Sugiéreme un nombre')),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _kaydediyor ? null : _kaydet,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _kaydediyor
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_t('Kaydet', 'Save', 'Speichern', 'Guardar')),
            ),
          ),
        ],
      ),
    );
  }
}
