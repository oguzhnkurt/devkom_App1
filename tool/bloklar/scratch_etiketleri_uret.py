#!/usr/bin/env python3
"""Scratch blok etiketlerini resmi dil dosyalarindan Dart'a tasir.

Kaynaklar (uydurma etiket YOK):
  tool/bloklar/scratch_{tr,en,de,es}.json
      scratch-l10n, editor/blocks/<dil>.json  (blok sozlugu)
  tool/bloklar/scratch_eklenti_{tr,en,de,es}.json
      scratch-l10n, editor/extensions/<dil>.json  (Kalem, Muzik)

Cikti: lib/courses/yurutme/scratch_resmi_etiketler.dart

Uygulama JSON'u calisma aninda okumuyor (asset degil, ve blok cizimi
senkron olmali); yalnizca kullanilan anahtarlar const bir haritaya
kopyalaniyor. test/scratch_blok_test.dart haritanin bu JSON'larla
BIREBIR ayni oldugunu denetliyor: biri elle degistirilirse test patlar.

Calistirma:  python3 tool/bloklar/scratch_etiketleri_uret.py
"""
import json
import os

KOK = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DILLER = ['tr', 'en', 'de', 'es']

ANAHTARLAR = [
    # Kategori adlari (paletin solundaki daireler)
    'CATEGORY_MOTION', 'CATEGORY_LOOKS', 'CATEGORY_SOUND', 'CATEGORY_EVENTS',
    'CATEGORY_CONTROL', 'CATEGORY_SENSING', 'CATEGORY_OPERATORS',
    'CATEGORY_VARIABLES', 'CATEGORY_MYBLOCKS',
    'pen.categoryName', 'music.categoryName',
    # Olaylar
    'EVENT_WHENFLAGCLICKED', 'EVENT_WHENTHISSPRITECLICKED',
    'EVENT_WHENBROADCASTRECEIVED', 'EVENT_BROADCAST',
    'EVENT_WHENKEYPRESSED_SPACE', 'EVENT_WHENKEYPRESSED_RIGHT',
    'EVENT_WHENKEYPRESSED_UP',
    # Hareket
    'MOTION_MOVESTEPS', 'MOTION_TURNRIGHT', 'MOTION_GOTO',
    'MOTION_GOTO_RANDOM', 'MOTION_GOTOXY', 'MOTION_GLIDESECSTOXY',
    'MOTION_CHANGEXBY', 'MOTION_CHANGEYBY',
    # Gorunum
    'LOOKS_SAY', 'LOOKS_HELLO',
    # Ses
    'SOUND_PLAY',
    # Kontrol
    'CONTROL_FOREVER', 'CONTROL_REPEAT', 'CONTROL_IF', 'CONTROL_ELSE',
    'CONTROL_WAIT', 'CONTROL_STARTASCLONE', 'CONTROL_CREATECLONEOF',
    'CONTROL_CREATECLONEOF_MYSELF', 'CONTROL_DELETETHISCLONE',
    # Algilama
    'SENSING_KEYPRESSED', 'SENSING_TOUCHINGOBJECT',
    'SENSING_TOUCHINGOBJECT_POINTER', 'SENSING_TOUCHINGOBJECT_EDGE',
    # Islemler
    'OPERATORS_RANDOM', 'OPERATORS_LT', 'OPERATORS_GT', 'OPERATORS_DIVIDE',
    # Degiskenler ve listeler
    'DATA_SETVARIABLETO', 'DATA_CHANGEVARIABLEBY', 'DATA_ADDTOLIST',
    'DATA_DELETEOFLIST', 'DATA_LENGTHOFLIST', 'DATA_ITEMOFLIST',
    # Bloklarim
    'PROCEDURES_DEFINITION',
    # Eklentiler
    'pen.clear', 'pen.penDown', 'pen.penUp',
    'music.playNoteForBeats', 'music.playDrumForBeats', 'music.drumSnare',
]


def yukle(dil):
    s = {}
    for ad in (f'scratch_{dil}.json', f'scratch_eklenti_{dil}.json'):
        with open(os.path.join(KOK, 'tool', 'bloklar', ad), encoding='utf-8') as f:
            s.update(json.load(f))
    return s


def dart_dizgi(s):
    return "'" + s.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$') + "'"


def main():
    satirlar = [
        '// URETILMIS DOSYA — elle degistirme.',
        '// Kaynak: tool/bloklar/scratch_*.json (scratch-l10n).',
        '// Uretici: python3 tool/bloklar/scratch_etiketleri_uret.py',
        '// Denetim: test/scratch_blok_test.dart',
        '',
        '/// Scratch 3\'un resmi blok etiketleri, dort dilde.',
        '///',
        '/// `%1`, `%2` (cekirdek bloklar) ve `[NOTE]` gibi (eklentiler) yer',
        '/// tutucular Scratch\'teki gibi duruyor; blok cizimi onlari girdi',
        '/// yuvasina ceviriyor.',
        'const Map<String, Map<String, String>> scratchResmiEtiketler = {',
    ]
    for dil in DILLER:
        s = yukle(dil)
        satirlar.append(f"  '{dil}': {{")
        for k in ANAHTARLAR:
            if k not in s:
                raise SystemExit(f'{dil}: {k} sozlukte yok')
            satirlar.append(f'    {dart_dizgi(k)}: {dart_dizgi(s[k])},')
        satirlar.append('  },')
    satirlar.append('};')
    yol = os.path.join(KOK, 'lib', 'courses', 'yurutme', 'scratch_resmi_etiketler.dart')
    with open(yol, 'w', encoding='utf-8') as f:
        f.write('\n'.join(satirlar) + '\n')
    print(yol)


if __name__ == '__main__':
    main()
