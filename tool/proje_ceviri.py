# -*- coding: utf-8 -*-
"""ProjectStep'lerin requirements/hints listelerini dort dile cevirir.

Neden bir betik: 30 proje adiminin gereksinim ve ipucu listeleri
`requirements: [...]` seklinde ciplak dize listeleri. Elle duzenlemek
hem hata yapmaya acik hem de her seferinde ayni girintiyi ve Dart
kacislarini tutturmayi gerektiriyor.

VERI `tool/proje_metinleri.py` icinde. Bu dosya yalnizca uygular.
"""
import re
import sys

GIRINTI_ALAN = ' ' * 10
GIRINTI_OGE = ' ' * 12


def dart(s):
    """Dart tek tirnakli dize kacisi. `$` de kaciyor: enterpolasyon."""
    return s.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$')


def liste(ad, ogeler):
    ic = ''.join(f"{GIRINTI_OGE}'{dart(o)}',\n" for o in ogeler)
    return f"{GIRINTI_ALAN}{ad}: [\n{ic}{GIRINTI_ALAN}],\n"


def blok_araligi(s, bas, ad):
    """`ad: [` ile basliyan listenin (bas, son) karakter araligi."""
    m = re.search(rf"^{GIRINTI_ALAN}{ad}: \[\n", s[bas:], re.M)
    if not m:
        return None
    b = bas + m.start()
    m2 = re.search(rf"^{GIRINTI_ALAN}\],\n", s[b + m.end() - m.start():], re.M)
    if not m2:
        return None
    return b, b + (m.end() - m.start()) + m2.end()


def uygula(yol, veriler, yaz=False):
    s = open(yol, encoding='utf-8').read()
    degisen = 0
    for sid, alanlar in veriler.items():
        i = s.find(f"id: '{sid}'")
        if i < 0:
            print(f'  ATLANDI (id yok): {sid}')
            continue
        # Adim blogunun sonu
        son = s.find('\n        ),', i)
        for ad in ('requirements', 'hints'):
            if ad not in alanlar:
                continue
            ar = blok_araligi(s[:son], i, ad)
            if ar is None:
                print(f'  ATLANDI ({ad} yok): {sid}')
                continue
            b, e = ar
            # Varsa ESKI ceviri listelerini once siliyoruz; yoksa yeniden
            # calistirinca ayni alan iki kez yaziliyor.
            for ek in ('En', 'De', 'Es'):
                esk = blok_araligi(s[:son], i, ad + ek)
                if esk:
                    eb, ee = esk
                    s = s[:eb] + s[ee:]
                    son -= ee - eb
                    if eb < b:
                        b -= ee - eb
                        e -= ee - eb
            d = alanlar[ad]
            yeni = liste(ad, d['tr'])
            for ek, dil in (('En', 'en'), ('De', 'de'), ('Es', 'es')):
                yeni += liste(ad + ek, d[dil])
            # Varsa eski cevirileri de sil
            s = s[:b] + yeni + s[e:]
            son += len(yeni) - (e - b)
            degisen += 1
    print(f'{yol}: {degisen} liste')
    if yaz:
        open(yol, 'w', encoding='utf-8').write(s)
    return s


if __name__ == '__main__':
    import proje_metinleri as PM
    yaz = '--yaz' in sys.argv
    for yol, veriler in PM.VERI.items():
        uygula(yol, veriler, yaz)
    if not yaz:
        print('\n(kuru calisma — yazmak icin: --yaz)')
