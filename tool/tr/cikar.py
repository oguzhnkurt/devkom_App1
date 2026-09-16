# -*- coding: utf-8 -*-
"""Duz yazi alanlarindaki ASCII-only kelimeleri cikarir (tr/de/es)."""
import os, re, json, collections

ALAN = re.compile(r"(?<![A-Za-z0-9_])([A-Za-z0-9_]+)\s*:\s*('(?:[^'\\]|\\.)*')")
KELIME = re.compile(r"[A-Za-zÀ-ÿçğıöşüÇĞİÖŞÜ]+")

PROSE = {
    'title','content','question','tip','description','label','explanation',
    'name','subtitle','mascotMessage','badge','instruction','hint','goal',
    'successMessage','tooltip','tagline','helpText','cancelText','confirmText',
    'text','hintText','labelText','message','left','right','counterText',
}
KOD = {
    'id','courseId','lessonId','prerequisiteId','starterCode','targetCode',
    'code','codeExample','codeContext','language','fontFamily','slug','tag',
    'thumbnailUrl','source','type','category','theme','icon','onConflict',
    'payload','channel','gameKey','expectedOutput','solution',
}
AKSAN = set('çğıöşüÇĞİÖŞÜáéíóúñÁÉÍÓÚÑäöüßÄÖÜàâêîôûëïÀÂÊÎÔÛËÏ')

def dosyalar(kok='lib'):
    for r,d,f in os.walk(kok):
        for x in f:
            if x.endswith('.dart'): yield os.path.join(r,x)

def dil(ad):
    if ad.endswith('En'): return 'en'
    if ad.endswith('De'): return 'de'
    if ad.endswith('Es'): return 'es'
    return 'tr'

def kok(ad):
    return re.sub(r'(En|De|Es)$', '', ad)

korunan = set()
sayac = {'tr': collections.Counter(), 'de': collections.Counter(),
         'es': collections.Counter()}
ornek = {'tr': {}, 'de': {}, 'es': {}}

for p in dosyalar():
    for ln, line in enumerate(open(p, encoding='utf-8'), 1):
        if line.strip().startswith('//'): continue
        for m in ALAN.finditer(line):
            ad, lit = m.group(1), m.group(2)
            metin = lit[1:-1]
            k = kok(ad)
            kodsu = (k in KOD) or ('\\n' in metin) or (';' in metin) or ('{' in metin)
            if kodsu:
                for w in KELIME.findall(metin):
                    if not (set(w) & AKSAN): korunan.add(w.lower())
                continue
            if k not in PROSE: continue
            d = dil(ad)
            if d == 'en': continue
            for wm in KELIME.finditer(metin):
                w = wm.group(0)
                if set(w) & AKSAN: continue
                if len(w) < 3: continue
                onc = metin[wm.start()-1] if wm.start() else ' '
                son = metin[wm.end()] if wm.end() < len(metin) else ' '
                if onc in '._' or son in '._(': continue
                sayac[d][w.lower()] += 1
                ornek[d].setdefault(w.lower(), f'{p}:{ln}: {metin[:90]}')

cikti = {
    'korunan': sorted(korunan),
    'tr': sayac['tr'].most_common(),
    'de': sayac['de'].most_common(),
    'es': sayac['es'].most_common(),
    'ornek': {d: ornek[d] for d in ornek},
}
json.dump(cikti, open('tool/tr/kelimeler.json','w'), ensure_ascii=False)
for d in ('tr','de','es'):
    print(d, 'farkli kelime:', len(sayac[d]), 'toplam gecis:', sum(sayac[d].values()))
print('korunan kimlik:', len(korunan))
