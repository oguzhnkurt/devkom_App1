import 'package:flutter/material.dart';

import '../../devre/devre_modeli.dart';
import '../../models/interactive_lesson_model.dart';
import '../../yurutme/mblock_blok_adlari.dart';
import '../../yurutme/mblock_cozum.dart';

/// Arduino kursunun KOD ADIMI: gercek mBlock tezgahi + devreli sahne.
///
/// Cocuk bloklari tezgahta kuruyor; "Kontrol et" programi denetliyor ve
/// sahnede, derste kurdugu devrede ([devre]) CALISTIRIYOR: LED yaniyor,
/// buzzer caliyor, servo donuyor; buton/potansiyometre/sensorler
/// sahnenin altindaki kontrollerle degisiyor.
///
/// YEDEK (tezgah acilamazsa kart dizme ekrani) cozumden KENDILIGINDEN
/// uretiliyor: ayni bloklar, ayni sira, mBlock'un kendi etiketleriyle.
/// Ders yazari ayni programi iki kez yazmiyor.
BlockBuilderStep arduinoKodAdimi({
  required String id,
  required String talimat,
  required String talimatEn,
  required String talimatDe,
  required String talimatEs,
  required String hedef,
  required String hedefEn,
  required String hedefDe,
  required String hedefEs,
  required List<String> bloklar,
  required List<MBlockBeklenen> cozum,
  Devre? devre,
  List<MBlockBeklenen>? baslangic,
  bool hataAvcisi = false,
  int xp = 30,
}) {
  final yedek = <ScratchBlock>[];
  final sira = <String>[];
  final programlar = {
    for (final l in const ['tr', 'en', 'de', 'es']) l: mblockCozumProgrami(cozum, l),
  };
  var n = 0;
  void gez(List<MBlockBlok> tr, List<MBlockBlok> en, List<MBlockBlok> de, List<MBlockBlok> es) {
    for (var i = 0; i < tr.length; i++) {
      final b = tr[i];
      final t = mblockBlokTanimlari[b.tip];
      final kimlik = b.tip == 'dev_kart_acilis' ? 'board_launch' : '${b.tip}_${n++}';
      yedek.add(ScratchBlock(
        id: kimlik,
        blockType: switch (t?.kategori) {
          'olaylar' => ScratchBlockType.events,
          'kontrol' => ScratchBlockType.control,
          'islemler' => ScratchBlockType.operators,
          'degisken' => ScratchBlockType.variables,
          'sensor' => ScratchBlockType.sensing,
          _ => ScratchBlockType.motion,
        },
        shape: switch (t?.sekil) {
          'sapka' => ScratchBlockShape.cap,
          'c' || 'cson' => ScratchBlockShape.cBlock,
          _ => ScratchBlockShape.stack,
        },
        label: mblockBlokYazisi(b, 'tr'),
        labelEn: mblockBlokYazisi(en[i], 'en'),
        labelDe: mblockBlokYazisi(de[i], 'de'),
        labelEs: mblockBlokYazisi(es[i], 'es'),
        color: t?.renk ?? const Color(0xFF4A90E2),
      ));
      sira.add(kimlik);
      gez(b.icerik, en[i].icerik, de[i].icerik, es[i].icerik);
    }
  }

  gez(programlar['tr']!, programlar['en']!, programlar['de']!, programlar['es']!);
  return BlockBuilderStep(
    id: id,
    instruction: talimat,
    instructionEn: talimatEn,
    instructionDe: talimatDe,
    instructionEs: talimatEs,
    goal: hedef,
    goalEn: hedefEn,
    goalDe: hedefDe,
    goalEs: hedefEs,
    availableBlocks: yedek,
    correctSequence: sira,
    mblock: MBlockTezgahAyari(
      bloklar: bloklar,
      cozum: cozum,
      baslangic: baslangic,
      hataAvcisi: hataAvcisi,
      devre: devre,
    ),
    xpReward: xp,
  );
}

// Kisa yazimlar (ders dosyalarinda program kurmak icin).

const MBlockBeklenen kartAcilis = MBlockBeklenen('dev_kart_acilis');

MBlockBeklenen surekli(List<MBlockBeklenen> ic) => MBlockBeklenen('dev_surekli', icerik: ic);

MBlockBeklenen tekrarla(int kere, List<MBlockBeklenen> ic) =>
    MBlockBeklenen('dev_tekrarla', alanlar: {'KERE': '$kere'}, icerik: ic);

MBlockBeklenen dijitalYaz(int pin, bool yuksek) => MBlockBeklenen('dev_dijital_yaz',
    alanlar: {'PIN': '$pin', 'SEVIYE': yuksek ? 'HIGH' : 'LOW'});

MBlockBeklenen bekle(num sn) => MBlockBeklenen('dev_bekle', alanlar: {'SANIYE': '$sn'});

MBlockBeklenen eger(MBlockBeklenen kosul, List<MBlockBeklenen> ic) =>
    MBlockBeklenen('dev_eger', girdiler: {'KOSUL': kosul}, icerik: ic);

MBlockBeklenen olanaKadarBekle(MBlockBeklenen kosul) =>
    MBlockBeklenen('dev_bekle_kadar', girdiler: {'KOSUL': kosul});

MBlockBeklenen dijitalOku(int pin) => MBlockBeklenen('dev_dijital_oku', alanlar: {'PIN': '$pin'});

MBlockBeklenen analogOku(int pin) => MBlockBeklenen('dev_analog_oku', alanlar: {'PIN': '$pin'});

MBlockBeklenen degil(MBlockBeklenen kosul) =>
    MBlockBeklenen('dev_degil', girdiler: {'KOSUL': kosul});

/// `a < b`: [a] bir oval blok, [b] sayi.
MBlockBeklenen kucuktur(MBlockBeklenen a, num b) =>
    MBlockBeklenen('dev_kucuktur', alanlar: {'B': '$b'}, girdiler: {'A': a});

/// `a > b`.
MBlockBeklenen buyuktur(MBlockBeklenen a, num b) =>
    MBlockBeklenen('dev_buyuktur', alanlar: {'B': '$b'}, girdiler: {'A': a});

MBlockBeklenen pwmYaz(int pin, {int? guc, MBlockBeklenen? deger}) => MBlockBeklenen('dev_pwm_yaz',
    alanlar: {'PIN': '$pin', if (guc != null) 'GUC': '$guc'},
    girdiler: {if (deger != null) 'GUC': deger});

MBlockBeklenen servoYaz(int pin, {int? aci, MBlockBeklenen? deger}) => MBlockBeklenen('dev_servo',
    alanlar: {'PIN': '$pin', if (aci != null) 'ACI': '$aci'},
    girdiler: {if (deger != null) 'ACI': deger});

MBlockBeklenen tonCal(int pin, int hz, num sn) => MBlockBeklenen('dev_ton',
    alanlar: {'PIN': '$pin', 'FREKANS': '$hz', 'SANIYE': '$sn'});

MBlockBeklenen seriYaz({String? metin, MBlockBeklenen? deger}) => MBlockBeklenen('dev_seri_yaz',
    alanlar: {if (metin != null) 'METIN': metin},
    girdiler: {if (deger != null) 'METIN': deger});

MBlockBeklenen mesafeOku(int trig, int echo) =>
    MBlockBeklenen('dev_mesafe', alanlar: {'TRIG': '$trig', 'ECHO': '$echo'});

MBlockBeklenen sicaklikOku(int pin) => MBlockBeklenen('dev_sicaklik', alanlar: {'PIN': '$pin'});

/// `harita (deger) [a, b] -> [c, d]`.
MBlockBeklenen harita(MBlockBeklenen deger, num a, num b, num c, num d) => MBlockBeklenen('dev_harita',
    alanlar: {'A': '$a', 'B': '$b', 'C': '$c', 'D': '$d'}, girdiler: {'DEGER': deger});

/// Degisken: `parlaklik`, `sayac`, `aci`.
MBlockBeklenen degiskenYap(String ad, {num? deger, MBlockBeklenen? blok}) => MBlockBeklenen('dev_degisken_yap',
    alanlar: {'AD': ad, if (deger != null) 'DEGER': '$deger'},
    girdiler: {if (blok != null) 'DEGER': blok});

MBlockBeklenen degiskenDegistir(String ad, num miktar) =>
    MBlockBeklenen('dev_degisken_degistir', alanlar: {'AD': ad, 'DEGER': '$miktar'});

/// Degiskenin ovali.
MBlockBeklenen degiskenOku(String ad) => MBlockBeklenen(switch (ad) {
      'sayac' => 'dev_sayac_oku',
      'aci' => 'dev_aci_oku',
      _ => 'dev_degisken_oku',
    });
