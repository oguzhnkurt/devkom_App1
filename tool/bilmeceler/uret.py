#!/usr/bin/env python3
"""Devi'nin bilmeceleri ve "Biliyor muydun?" bilgilerini Dart'a cevirir.

    python3 tool/bilmeceler/uret.py   (repo kokunden)

Icerik bu klasordeki .py dosyalarinda (dort dil). Cikti:
lib/data/devi_bilmeceleri.dart — elle duzenlenmez.
"""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from scratch import SCRATCH
from mblock import MBLOCK
from donanim import ARDUINO, TINKERCAD, DONANIM
from bilgiler import BILGILER

DILLER = ['tr', 'en', 'de', 'es']
assert len(SCRATCH) == 30 and len(MBLOCK) == 24 and len(ARDUINO) == 14
assert len(TINKERCAD) == 10 and len(DONANIM) == 12 and len(BILGILER) == 30

hepsi = ([('scratch', x) for x in SCRATCH] + [('mblock', x) for x in MBLOCK] +
         [('arduino', x) for x in ARDUINO] + [('tinkercad', x) for x in TINKERCAD] +
         [('donanim', x) for x in DONANIM])
bas = {'scratch': 0, 'mblock': 30, 'arduino': 54, 'tinkercad': 68, 'donanim': 78}

for kat, (d, m) in hepsi:
    for dil in DILLER:
        s, sec, a = m[dil]
        assert len(sec) == 3 and 0 <= d < 3, (kat, dil, s)
        assert len(set(sec)) == 3, (kat, dil, sec)

gunler = []
mi = ti = ai = di = 0
ti3 = 6
for g in range(30):
    s1 = bas['scratch'] + g
    if g % 5 == 4:
        s2 = bas['tinkercad'] + ti; ti += 1
    else:
        s2 = bas['mblock'] + mi; mi += 1
    if g in (6, 13, 20, 27):
        s3 = bas['tinkercad'] + ti3; ti3 += 1
    elif (g % 2 == 0 and ai < 14) or di >= 12:
        s3 = bas['arduino'] + ai; ai += 1
    else:
        s3 = bas['donanim'] + di; di += 1
    gunler.append((s1, s2, s3))
assert mi == 24 and ti == 6 and ti3 == 10 and ai == 14 and di == 12, (mi, ti, ti3, ai, di)
assert len({i for g in gunler for i in g}) == 90

def q(t):
    return "'" + t.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$') + "'"

out = ["// URETILDI: tool/bilmeceler/uret.py — elle duzenleme, kaynagi duzenle.",
       "// ignore_for_file: lines_longer_than_80_chars",
       "",
       "part of 'devi_bilmeceleri_api.dart';",
       "",
       "const List<Bilmece> _hepsi = ["]
for kat, (d, m) in hepsi:
    out.append(f"  Bilmece('{kat}', {d}, {{")
    for dil in DILLER:
        s, sec, a = m[dil]
        out.append(f"    '{dil}': [{q(s)}, {q(sec[0])}, {q(sec[1])}, {q(sec[2])}, {q(a)}],")
    out.append("  }),")
out.append("];")
out.append("")
out.append("const List<List<int>> _gunler = [")
for g in gunler:
    out.append(f"  [{g[0]}, {g[1]}, {g[2]}],")
out.append("];")
out.append("")
out.append("const List<Map<String, String>> _bilgiler = [")
for b in BILGILER:
    out.append("  {" + ", ".join(f"'{dil}': {q(b[dil])}" for dil in DILLER) + "},")
out.append("];")
kok = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
open(os.path.join(kok, 'lib/bilmece/devi_bilmeceleri_veri.dart'), 'w').write("\n".join(out) + "\n")
print('90 bilmece, 30 gun, 30 bilgi yazildi')
