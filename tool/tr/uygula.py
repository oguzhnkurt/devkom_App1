# -*- coding: utf-8 -*-
"""Aksani soyulmus Turkce kelimeleri duz yazi alanlarinda geri getirir.

Kullanim (proje kokunden):
    python3 tool/tr/uygula.py            # kuru calisma: ne degisecegini yazar
    python3 tool/tr/uygula.py --yaz      # dosyalara yazar

Harita `tool/tr/harita.json` dosyasindan geliyor: {"tr": {"duz": "dogru"}}.

Neden bu kadar dar kapsamli:
  - Yalnizca DUZ YAZI alanlarina dokunuluyor (title, content, tip, ...).
    Kod alanlari (starterCode, code, id, slug, ...) hic acilmiyor.
  - Icinde kod isareti gecen dizeler ( ; { } < > = # \n ) atlaniyor.
  - Bir kelime '(' ile bitiyorsa ya da '.'/'_' ile komsuysa atlaniyor:
    fonksiyon cagrisi veya tanimlayici olabilir.
  - Ingilizce alanlara (xxxEn) hic dokunulmuyor.
Cunku Python/Dart degisken adi ASCII olmak zorunda: ders icindeki
`ogrenci = 5` ornegi `ogrenci` kalmali, anlatim metnindeki ise
`ogrenci` degil `ogrenci`nin dogrusu olan kelime olmali.
"""
import os
import re
import sys
import json
import collections

ALAN = re.compile(r"(?<![A-Za-z0-9_])([A-Za-z0-9_]+)\s*:\s*('(?:[^'\\]|\\.)*')")
KELIME = re.compile(r"[A-Za-zÀ-ÿçğıöşüÇĞİÖŞÜ]+")
AKSAN = set('çğıöşüÇĞİÖŞÜáéíóúñÁÉÍÓÚÑäöüßÄÖÜ')
KOD_ISARETI = ('\\n', ';', '{', '}', '<', '>', '=', '#')

PROSE = {
    'title', 'content', 'question', 'tip', 'description', 'label',
    'explanation', 'name', 'subtitle', 'mascotMessage', 'badge',
    'instruction', 'hint', 'goal', 'successMessage', 'tooltip', 'tagline',
    'helpText', 'cancelText', 'confirmText', 'text', 'hintText', 'labelText',
    'message', 'left', 'right', 'counterText',
}
KOD = {
    'id', 'courseId', 'lessonId', 'prerequisiteId', 'starterCode',
    'targetCode', 'code', 'codeExample', 'codeContext', 'language',
    'fontFamily', 'slug', 'tag', 'thumbnailUrl', 'source', 'type', 'category',
    'theme', 'icon', 'onConflict', 'payload', 'channel', 'gameKey',
    'expectedOutput', 'solution',
}


def tr_upper(s):
    """Turkce buyuk harf: i -> İ, ı -> I."""
    return s.replace('i', 'İ').replace('ı', 'I').upper()


def bicim(orijinal, dogru):
    """Orijinalin buyuk/kucuk desenini dogru kelimeye tasir.

    'yurUtmek' gibi bozuk ic buyuk harfler KORUNMAZ; o desen zaten hatanin
    kendisi. Yalnizca TUMU BUYUK ve Baslik desenleri taniniyor.
    """
    if orijinal.isupper() and len(orijinal) > 1:
        return tr_upper(dogru)
    kucuk = dogru.lower()
    if orijinal[0].isupper():
        return tr_upper(kucuk[0]) + kucuk[1:]
    return kucuk


def dil_of(ad):
    if ad.endswith('En'):
        return 'en'
    if ad.endswith('De'):
        return 'de'
    if ad.endswith('Es'):
        return 'es'
    return 'tr'


def kok(ad):
    return re.sub(r'(En|De|Es)$', '', ad)


def main(yaz=False):
    harita = json.load(open('tool/tr/harita.json', encoding='utf-8'))
    degisim = collections.Counter()
    dosyalar = 0

    for r, _d, ff in os.walk('lib'):
        for x in ff:
            if not x.endswith('.dart'):
                continue
            p = os.path.join(r, x)
            satirlar = open(p, encoding='utf-8').readlines()
            degisti = False

            for i, line in enumerate(satirlar):
                if line.strip().startswith('//'):
                    continue
                yeni_line = line
                for m in ALAN.finditer(line):
                    ad, lit = m.group(1), m.group(2)
                    k, dil = kok(ad), dil_of(ad)
                    if dil == 'en' or dil not in harita:
                        continue
                    if k not in PROSE or k in KOD:
                        continue
                    metin = lit[1:-1]
                    if any(c in metin for c in KOD_ISARETI):
                        continue

                    h = harita[dil]
                    parca = []
                    for wm in KELIME.finditer(metin):
                        w = wm.group(0)
                        if set(w) & AKSAN:
                            continue
                        anahtar = w.lower()
                        if anahtar not in h:
                            continue
                        onc = metin[wm.start() - 1] if wm.start() else ' '
                        snk = metin[wm.end()] if wm.end() < len(metin) else ' '
                        if onc in '._' or snk in '._(':
                            continue
                        parca.append((wm.start(), wm.end(), bicim(w, h[anahtar])))
                        degisim[(dil, anahtar, h[anahtar])] += 1

                    if not parca:
                        continue
                    yeni = metin
                    for a, b, rep in reversed(parca):
                        yeni = yeni[:a] + rep + yeni[b:]
                    yeni_line = yeni_line.replace(lit, "'" + yeni + "'", 1)

                if yeni_line != line:
                    satirlar[i] = yeni_line
                    degisti = True

            if degisti:
                dosyalar += 1
                if yaz:
                    open(p, 'w', encoding='utf-8').writelines(satirlar)

    print('dosya:', dosyalar,
          '| toplam duzeltme:', sum(degisim.values()),
          '| farkli kelime:', len(degisim))
    for (dil, a, b), c in sorted(degisim.items(), key=lambda x: -x[1])[:30]:
        print(f'  {c:4d} [{dil}] {a} -> {b}')
    if not yaz:
        print('\n(kuru calisma — yazmak icin: python3 tool/tr/uygula.py --yaz)')


if __name__ == '__main__':
    main(yaz='--yaz' in sys.argv)
