# -*- coding: utf-8 -*-
"""ASCII'ye donmus Turkce kelimeleri bulur.

Yontem: projenin KENDI dogru yazilmis Turkce metinlerinden bir sozluk
kuruyoruz (aksanlari soyulmus hali -> dogru hali). Bir duz-ASCII kelime
bu sozlukte TEK bir karsiliga gidiyorsa duzeltme adayidir. Boylece
uydurma bir duzeltme yapilmiyor; yalnizca uygulamanin baska bir yerinde
zaten dogru yazilmis kelimeler geri getiriliyor.

Kod alanlarindaki tanimlayicilar (ogrenci, hesapMakinesi, selamVer...)
korunuyor: Python/Dart degisken adi ASCII olmak zorunda.
"""
import os, re, sys, json, collections

ALAN = re.compile(r"(?<![A-Za-z0-9_])([A-Za-z0-9_]+)\s*:\s*('(?:[^'\\]|\\.)*')")
KELIME = re.compile(r"[A-Za-zçğıöşüÇĞİÖŞÜ]+")
TRCH = set("çğıöşüÇĞİÖŞÜ")

# Duzeltilecek alanlar (duz yazi). Kod, kimlik, emoji alanlari disarida.
PROSE = {
    'title','content','question','tip','description','label','explanation',
    'name','subtitle','mascotMessage','badge','instruction','hint','goal',
    'successMessage','tooltip','tagline','helpText','cancelText','confirmText',
    'text','hintText','labelText','message','left','right','counterText',
}
# Kod/kimlik alanlari: dokunulmaz, ayrica icindeki kelimeler KORUNUR.
KOD = {
    'id','courseId','lessonId','prerequisiteId','starterCode','targetCode',
    'code','codeExample','codeContext','language','fontFamily','slug','tag',
    'thumbnailUrl','source','type','category','theme','icon','onConflict',
    'payload','channel','gameKey','expectedOutput','solution',
}

def soy(s):
    return (s.replace('ç','c').replace('Ç','C').replace('ğ','g').replace('Ğ','G')
             .replace('ı','i').replace('İ','I').replace('ö','o').replace('Ö','O')
             .replace('ş','s').replace('Ş','S').replace('ü','u').replace('Ü','U'))

def dosyalar(kok='lib'):
    for r,d,f in os.walk(kok):
        for x in f:
            if x.endswith('.dart'): yield os.path.join(r,x)

def topla():
    sozluk = collections.defaultdict(collections.Counter)
    korunan = set()
    for p in dosyalar():
        for line in open(p, encoding='utf-8'):
            if line.strip().startswith('//'): continue
            for m in ALAN.finditer(line):
                ad, lit = m.group(1), m.group(2)
                metin = lit[1:-1]
                if re.search(r'(En|De|Es)$', ad):
                    continue
                if ad in KOD or '\\n' in metin or ';' in metin or '{' in metin:
                    for w in KELIME.findall(metin):
                        if not (set(w) & TRCH):
                            korunan.add(w.lower())
                    continue
                for w in KELIME.findall(metin):
                    if set(w) & TRCH:
                        sozluk[soy(w).lower()][w] += 1
    return sozluk, korunan

def adaylar(sozluk, korunan):
    bulunan = []
    belirsiz = collections.Counter()
    eslesmeyen = collections.Counter()
    for p in dosyalar():
        for ln, line in enumerate(open(p, encoding='utf-8'), 1):
            if line.strip().startswith('//'): continue
            for m in ALAN.finditer(line):
                ad, lit = m.group(1), m.group(2)
                if ad not in PROSE: continue
                if re.search(r'(En|De|Es)$', ad): continue
                metin = lit[1:-1]
                if '\\n' in metin or ';' in metin or '{' in metin: continue
                for wm in KELIME.finditer(metin):
                    w = wm.group(0)
                    if set(w) & TRCH: continue
                    if len(w) < 3: continue
                    k = w.lower()
                    if k in korunan: continue
                    onc = metin[wm.start()-1] if wm.start() else ' '
                    son = metin[wm.end()] if wm.end() < len(metin) else ' '
                    if onc in '._' or son in '._(': continue
                    if k not in sozluk:
                        eslesmeyen[k]+=1; continue
                    secenek = sozluk[k]
                    if len(secenek) > 1:
                        belirsiz[k]+=1; continue
                    dogru = next(iter(secenek))
                    if soy(dogru).lower() == dogru.lower(): continue  # aksan yok
                    bulunan.append((p, ln, w, dogru, metin))
    return bulunan, belirsiz, eslesmeyen

if __name__ == '__main__':
    sozluk, korunan = topla()
    bulunan, belirsiz, eslesmeyen = adaylar(sozluk, korunan)
    print('sozluk boyutu:', len(sozluk), '| korunan kimlik:', len(korunan))
    print('duzeltme adayi:', len(bulunan))
    ozet = collections.Counter((w.lower(), d) for _,_,w,d,_ in bulunan)
    print('farkli kelime:', len(ozet))
    for (w,d),c in sorted(ozet.items(), key=lambda x:-x[1]):
        print(f'{c:4d}  {w}  ->  {d}')
    print('--- belirsiz (birden fazla karsilik):', len(belirsiz))
    for k,c in belirsiz.most_common(40): print(f'{c:4d}  {k} -> {dict(sozluk[k])}')
