# -*- coding: utf-8 -*-
"""Tek satira sigdirilmis yapilardaki `xEn:` alanlarini cevirir.

NEDEN AYRI BIR ARAC VAR
-----------------------
`lesson_i18n.py` alanlari `\\n\\s*xEn:` kalibiyla buluyor, yani YALNIZCA
satir basindakileri. Icerikte ise tek satira sigdirilmis yapilar var:

    ChoiceOption(text: 'Hata verir', textEn: 'It gives an error')
    DraggableItem(id: 'c', content: 'Content', contentEn: 'Content', color: x)

Buradaki `textEn:` satirin ortasinda kaldigi icin hem arac atladi hem de
kapsam testi yakalamadi: sekiz kursun ders ANLATIMI dort dildeydi ama
SIKLARI Ingilizce kalmisti (874 alan).

Bu arac yalnizca tek satirlik literal degerleri isler; cok satirli ya da
liste degerler zaten obur aracin isi.

Sozluk bicimi (JSON):
    {"metinler": {"<ingilizce>": ["<almanca>", "<ispanyolca>"]}}
"""
import json
import re
import sys

# xEn: 'deger'  — deger tek satirlik, kacisli tirnak icerebilir.
ALAN = re.compile(r"(?<![A-Za-z0-9_])([A-Za-z0-9_]+)En:\s*('(?:[^'\\]|\\.)*')")


def _lit(s):
    return "'" + s.replace("'", "\\'") + "'"


def satir_ici_mi(satir, m):
    """Alan satirin BASINDA mi? Oyleyse obur aracin isi, dokunma."""
    bas = len(satir) - len(satir.lstrip())
    return m.start() != bas


def uygula(dosya, sozluk):
    metinler = sozluk.get('metinler', {})
    satirlar = open(dosya, encoding='utf-8').read().split('\n')
    eklendi = 0
    atlanan = []

    for i, satir in enumerate(satirlar):
        if 'En:' not in satir:
            continue
        yeni = satir
        # Sagdan sola gidiyoruz ki eklemeler indeksleri kaydirmasin.
        for m in reversed(list(ALAN.finditer(satir))):
            if not satir_ici_mi(satir, m):
                continue
            ad, ham = m.group(1), m.group(2)
            # Zaten cevrilmisse dokunma.
            if re.search(r'(?<![A-Za-z0-9_])' + ad + r'De:', satir):
                continue
            cev = metinler.get(ham)
            if cev is None:
                atlanan.append(ham)
                continue
            de, es = cev
            ek = f', {ad}De: {_lit(de)}, {ad}Es: {_lit(es)}'
            son = m.end()
            yeni = yeni[:son] + ek + yeni[son:]
            eklendi += 1
        satirlar[i] = yeni

    open(dosya, 'w', encoding='utf-8').write('\n'.join(satirlar))
    return eklendi, atlanan


if __name__ == '__main__':
    dosya, sozluk_yolu = sys.argv[1], sys.argv[2]
    n, atlanan = uygula(dosya, json.load(open(sozluk_yolu, encoding='utf-8')))
    print(f'eklendi: {n}')
    if '-v' in sys.argv:
        for a in dict.fromkeys(atlanan):
            print('  atlandi:', a)
