import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme.dart';
import 'devre_metinleri.dart';
import 'devre_modeli.dart';
import 'devre_simulasyonu.dart';

/// Devrenin GIRIS KONTROLLERI ve seri port: sahnenin altinda.
///
/// Devrede hangi parca varsa onun kontrolu cikiyor: buton (basili tut),
/// potansiyometre (cevir), LDR (ortam isigi), sicaklik sensoru (ortam
/// sicakligi), mesafe sensoru (engelin uzakligi). Hicbiri yoksa ve seri
/// port bossa panel hic yer kaplamiyor.
class DevreGirdiPaneli extends StatelessWidget {
  const DevreGirdiPaneli({
    super.key,
    required this.sim,
    required this.lang,
    this.seriGoster = false,
  });

  final DevreSimulasyonu sim;
  final String lang;

  /// Program seri porta yaziyor: monitoru goster.
  final bool seriGoster;

  String _t(String tr, String en, String de, String es) => devreT(lang, tr, en, de, es);

  @override
  Widget build(BuildContext context) {
    final parcalar = sim.devre.parcalar;
    final butonlar = parcalar.where((p) => p.tur == ParcaTuru.buton).toList();
    final potlar = parcalar.where((p) => p.tur == ParcaTuru.pot).toList();
    final ldr = parcalar.any((p) => p.tur == ParcaTuru.ldr);
    final sicak = parcalar.any((p) => p.tur == ParcaTuru.sicaklik);
    final mesafe = parcalar.any((p) => p.tur == ParcaTuru.mesafe);
    final satirlar = <Widget>[
      if (butonlar.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Wrap(spacing: 10, runSpacing: 6, children: [
            for (final b in butonlar) _BasiliTutDugmesi(sim: sim, parca: b, lang: lang),
          ]),
        ),
      for (final p in potlar)
        _surgu(
          anahtar: ValueKey('devre_pot_${p.id}'),
          ikon: Icons.tune_rounded,
          ad: potlar.length > 1 ? '${parcaTuruAdi(p.tur, lang)} ${p.id}' : parcaTuruAdi(p.tur, lang),
          deger: () => sim.girdiler.pot(p.id),
          min: 0,
          max: 1,
          yazi: () => '${(sim.girdiler.pot(p.id) * 100).round()}%',
          degisti: (v) => sim.potAyarla(p.id, v),
        ),
      if (ldr)
        _surgu(
          anahtar: const ValueKey('devre_isik'),
          ikon: Icons.wb_sunny_rounded,
          ad: _t('Ortam ışığı', 'Room light', 'Umgebungslicht', 'Luz ambiente'),
          deger: () => sim.girdiler.isik,
          min: 0,
          max: 100,
          yazi: () => '${sim.girdiler.isik.round()}%',
          degisti: (v) => sim.isik = v,
        ),
      if (sicak)
        _surgu(
          anahtar: const ValueKey('devre_sicaklik'),
          ikon: Icons.thermostat_rounded,
          ad: _t('Ortam sıcaklığı', 'Room temperature', 'Raumtemperatur', 'Temperatura'),
          deger: () => sim.girdiler.sicaklik,
          min: -10,
          max: 50,
          yazi: () => '${sim.girdiler.sicaklik.round()} °C',
          degisti: (v) => sim.sicaklik = v,
        ),
      if (mesafe)
        _surgu(
          anahtar: const ValueKey('devre_mesafe'),
          ikon: Icons.sensors_rounded,
          ad: _t('Engelin uzaklığı', 'Obstacle distance', 'Abstand zum Hindernis', 'Distancia al obstáculo'),
          deger: () => sim.girdiler.mesafe.toDouble(),
          min: 2,
          max: 200,
          yazi: () => '${sim.girdiler.mesafe} cm',
          degisti: (v) => sim.mesafe = v.round(),
        ),
      if (seriGoster) SeriMonitor(sim: sim, lang: lang),
    ];
    if (satirlar.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        key: const ValueKey('devre_girdi_paneli'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: satirlar,
      ),
    );
  }

  Widget _surgu({
    required Key anahtar,
    required IconData ikon,
    required String ad,
    required double Function() deger,
    required double min,
    required double max,
    required String Function() yazi,
    required ValueChanged<double> degisti,
  }) {
    return SizedBox(
      height: 44,
      child: Row(children: [
        Icon(ikon, size: 18, color: const Color(0xFF00838F)),
        const SizedBox(width: 6),
        Flexible(
          flex: 4,
          child: Text(ad,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF39404F))),
        ),
        Expanded(
          flex: 6,
          child: AnimatedBuilder(
            animation: sim,
            builder: (context, _) => Slider(
              key: anahtar,
              value: deger().clamp(min, max),
              min: min,
              max: max,
              activeColor: const Color(0xFF00838F),
              onChanged: degisti,
            ),
          ),
        ),
        SizedBox(
          width: 56,
          child: AnimatedBuilder(
            animation: sim,
            builder: (context, _) => Text(yazi(),
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF00838F))),
          ),
        ),
      ]),
    );
  }
}

class _BasiliTutDugmesi extends StatelessWidget {
  const _BasiliTutDugmesi({required this.sim, required this.parca, required this.lang});
  final DevreSimulasyonu sim;
  final Parca parca;
  final String lang;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sim,
      builder: (context, _) {
        final b = sim.basili(parca.id);
        return Listener(
          key: ValueKey('devre_buton_${parca.id}'),
          onPointerDown: (_) {
            HapticFeedback.lightImpact();
            sim.butonBas(parca.id, true);
          },
          onPointerUp: (_) => sim.butonBas(parca.id, false),
          onPointerCancel: (_) => sim.butonBas(parca.id, false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: b ? const Color(0xFFB71C1C) : const Color(0xFFE53935),
              borderRadius: BorderRadius.circular(22),
              boxShadow: b
                  ? const []
                  : [const BoxShadow(color: Color(0xFF8E1616), offset: Offset(0, 3))],
            ),
            transform: Matrix4.translationValues(0, b ? 3 : 0, 0),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.radio_button_checked_rounded, size: 18, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                devreT(lang, '${parca.id} · basılı tut', '${parca.id} · hold', '${parca.id} · gedrückt halten',
                    '${parca.id} · mantén'),
                style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white),
              ),
            ]),
          ),
        );
      },
    );
  }
}

/// Seri port monitoru: kartin son satirlari.
class SeriMonitor extends StatelessWidget {
  const SeriMonitor({super.key, required this.sim, required this.lang});
  final DevreSimulasyonu sim;
  final String lang;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('devre_seri'),
      height: 88,
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      decoration: BoxDecoration(
        color: const Color(0xFF14181F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(devreT(lang, 'Seri port', 'Serial monitor', 'Serieller Monitor', 'Monitor serie'),
            style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: Color(0xFF7ED321))),
        const SizedBox(height: 2),
        Expanded(
          child: AnimatedBuilder(
            animation: sim.kart,
            builder: (context, _) {
              final s = sim.kart.seri;
              final son = s.length > 4 ? s.sublist(s.length - 4) : s;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  for (final x in son)
                    Text(x,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontFamily: 'monospace', fontSize: 12.5, color: Color(0xFFB8F28A), height: 1.2)),
                ],
              );
            },
          ),
        ),
      ]),
    );
  }
}

/// Devrenin uyarilari (ters LED, direncsiz LED, kisa devre...): sahnenin
/// altinda tek satir, en onemlisi.
class DevreUyariSeridi extends StatelessWidget {
  const DevreUyariSeridi({super.key, required this.sim, required this.lang});
  final DevreSimulasyonu sim;
  final String lang;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sim,
      builder: (context, _) {
        final u = sim.sonuc.uyarilar;
        if (u.isEmpty) return const SizedBox.shrink();
        final sirali = [...u]..sort((a, b) => a.tur.index.compareTo(b.tur.index));
        final ilk = sirali.first;
        final kritik = ilk.tur == DevreUyariTuru.kisaDevre;
        return Container(
          key: const ValueKey('devre_uyari'),
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: kritik ? const Color(0xFFFFEBEE) : const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kritik ? const Color(0xFFEF9A9A) : const Color(0xFFFFE082)),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(kritik ? Icons.flash_on_rounded : Icons.warning_amber_rounded,
                size: 18, color: kritik ? const Color(0xFFC62828) : const Color(0xFFB26A00)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(uyariMetni(ilk, lang, sim.devre),
                  style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12.5,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                      color: kritik ? const Color(0xFFB71C1C) : const Color(0xFF6D4C00))),
            ),
          ]),
        );
      },
    );
  }
}
