import 'package:flutter/material.dart';

import '../screens/leaderboard/leaderboard_screen.dart';
import '../services/siralama_servisi.dart';
import '../utils/lang.dart';

/// Ana sayfanın en altında: "Sıralamadaki yerini gör".
///
/// İki kulvarın ikisinde de çocuğun KENDİ yeri yazıyor (genel XP ve
/// satranç). Henüz yeri yoksa (hiç XP ya da satranç galibiyeti yok)
/// "henüz yok" diyor; kart yine de duruyor ki tabloya ulaşılabilsin.
///
/// Veri gelmezse (çevrimdışı, sunucu fonksiyonu henüz yok) kart sayıları
/// göstermeden, yalnızca tabloya giden bir kart olarak çiziliyor.
class SiralamaKarti extends StatefulWidget {
  const SiralamaKarti({super.key, required this.lang});
  final String lang;

  @override
  State<SiralamaKarti> createState() => _SiralamaKartiState();
}

class _SiralamaKartiState extends State<SiralamaKarti> {
  SiralamaSatiri? _genel;
  SiralamaSatiri? _satranc;
  bool _yuklendi = false;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    SiralamaSatiri? g;
    SiralamaSatiri? s;
    try {
      // Yalnızca kendi satırımız lazım; limit 1 yeter, sunucu kendi
      // satırımızı ilk N'de olmasak da ekliyor.
      final r = await Future.wait([
        SiralamaServisi.getir(SiralamaKulvari.genel, limit: 1),
        SiralamaServisi.getir(SiralamaKulvari.satranc, limit: 1),
      ]);
      g = SiralamaServisi.benimSatirim(r[0]);
      s = SiralamaServisi.benimSatirim(r[1]);
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _genel = g;
      _satranc = s;
      _yuklendi = true;
    });
  }

  String _t(String tr, String en, String de, String es) =>
      AppLang.pick(widget.lang, tr: tr, en: en, de: de, es: es);

  Future<void> _ac() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => const LeaderboardScreen()));
    if (mounted) _yukle();
  }

  @override
  Widget build(BuildContext context) {
    final yok = _t('henüz yok', 'not yet', 'noch nicht', 'aún no');
    String yer(SiralamaSatiri? s) => s == null
        ? yok
        : AppLang.pick(widget.lang,
            tr: '${s.sira}.', en: '#${s.sira}', de: '${s.sira}.', es: '${s.sira}.º');

    return Material(
      key: const ValueKey('siralama_karti'),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: _ac,
        child: Ink(
          padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3B1E8F), Color(0xFF6C3CE0)],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF6C3CE0).withValues(alpha: 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 8)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 26)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _t('Sıralamadaki yerini gör', 'See your place in the ranking',
                          'Sieh deinen Platz in der Rangliste', 'Mira tu puesto en el ranking'),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 17),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.white),
                ],
              ),
              if (_yuklendi) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _Kulvar(
                        key: const ValueKey('siralama_karti_genel'),
                        baslik: _t('⭐ Genel', '⭐ Overall', '⭐ Gesamt', '⭐ General'),
                        deger: yer(_genel),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Kulvar(
                        key: const ValueKey('siralama_karti_satranc'),
                        baslik: _t('♞ Satranç', '♞ Chess', '♞ Schach', '♞ Ajedrez'),
                        deger: yer(_satranc),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Kulvar extends StatelessWidget {
  const _Kulvar({super.key, required this.baslik, required this.deger});
  final String baslik;
  final String deger;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(baslik,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(deger,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
