#!/usr/bin/env python3
"""assets/l10n/<dil>.json dosyalarini _kaynak.json'a gore denetler.
Eksik/fazla anahtar, yer tutucu uyumsuzlugu, bos ceviri. Kullanim:
  python3 tool/ceviri_dogrula.py [dil ...]"""
import json, os, re, sys
KOK = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
D = os.path.join(KOK, 'assets', 'l10n')
kaynak = json.load(open(os.path.join(D, '_kaynak.json'), encoding='utf-8'))
diller = sys.argv[1:] or sorted(f[:-5] for f in os.listdir(D) if f.endswith('.json') and not f.startswith('_'))
hata_var = False
for dil in diller:
    p = os.path.join(D, dil + '.json')
    if not os.path.exists(p):
        print(f'{dil}: DOSYA YOK'); hata_var = True; continue
    try:
        t = json.load(open(p, encoding='utf-8'))
    except Exception as e:
        print(f'{dil}: JSON HATASI {e}'); hata_var = True; continue
    eksik = [k for k in kaynak if k not in t]
    bos = [k for k in kaynak if k in t and not str(t[k]).strip()]
    yt = [k for k in kaynak if k in t and sorted(re.findall(r'\{\d+\}', k)) != sorted(re.findall(r'\{\d+\}', t[k]))]
    fazla = [k for k in t if k not in set(kaynak)]
    ayni = sum(1 for k in kaynak if t.get(k) == k)
    durum = 'OK' if not (eksik or bos or yt) else 'HATA'
    if durum == 'HATA': hata_var = True
    print(f'{dil}: {durum} eksik={len(eksik)} bos={len(bos)} yer_tutucu={len(yt)} fazla={len(fazla)} ayni={ayni}/{len(kaynak)}')
    for k in (eksik[:3] + yt[:3]):
        print('   ', repr(k)[:100])
sys.exit(1 if hata_var else 0)
