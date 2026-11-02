#!/usr/bin/env python3
"""51 dil: cevrilecek Ingilizce metinleri toplar -> assets/l10n/_kaynak.json

Kaynaklar:
  * AppLang.pick(..., en: '...') ve pickOf degil (yalniz metin)
  * _t / devreT / tanitimMetni sarmalayicilarinin Ingilizce argumani
    (ilk argumani dil olanlarda 3., olmayanlarda 2. arguman)
  * lib/utils/app_localizations.dart icindeki 'en' tablosu

Degiskenli metinler ($x, ${...}) {0},{1}... yer tutuculu sablona cevrilir.
Calistir: python3 tool/ceviri_kaynagi.py
"""
import json, os, re, sys

KOK = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(KOK, 'lib')

def literal_oku(s, i):
    """s[i]'de baslayan bir Dart dize ifadesini (bitisik literaller dahil)
    okur. Donus: (parcalar listesi [(metin, ham)], bitis) ya da None."""
    parcalar = []
    n = len(s)
    while True:
        # bosluk / yorum atla
        while i < n:
            if s[i].isspace():
                i += 1
            elif s.startswith('//', i):
                j = s.find('\n', i); i = n if j < 0 else j
            elif s.startswith('/*', i):
                j = s.find('*/', i); i = n if j < 0 else j + 2
            else:
                break
        ham = False
        j = i
        if j < n and s[j] == 'r' and j + 1 < n and s[j+1] in '\'"':
            ham = True; j += 1
        if j >= n or s[j] not in '\'"':
            break
        q = s[j]
        uclu = s.startswith(q*3, j)
        bit = q*3 if uclu else q
        k = j + len(bit)
        buf = []
        while k < n:
            if not ham and s[k] == '\\':
                buf.append(s[k:k+2]); k += 2; continue
            if not ham and s.startswith('${', k):
                # ic ifade: icindeki tirnaklar dizeyi bitirmez
                derinlik = 0; j = k + 1
                while j < n:
                    if s[j] == '{': derinlik += 1
                    elif s[j] == '}':
                        derinlik -= 1
                        if derinlik == 0: break
                    j += 1
                buf.append(s[k:j+1]); k = j + 1; continue
            if s.startswith(bit, k):
                break
            if not uclu and s[k] == '\n':
                return None
            buf.append(s[k]); k += 1
        parcalar.append((''.join(buf), ham))
        i = k + len(bit)
    if not parcalar:
        return None
    return parcalar, i

KACIS = {'n': '\n', 't': '\t', "'": "'", '"': '"', '\\': '\\', '$': '\x00DOLAR\x00', 'r': '\r'}

def coz(parcalar):
    """Dart literal(ler)ini calisma anindaki metne/sablona cevirir."""
    out = []
    say = 0
    for metin, ham in parcalar:
        i = 0
        while i < len(metin):
            c = metin[i]
            if not ham and c == '\\' and i + 1 < len(metin):
                d = metin[i+1]
                if d == 'u' and i + 5 < len(metin) and metin[i+2] != '{':
                    out.append(chr(int(metin[i+2:i+6], 16))); i += 6; continue
                out.append(KACIS.get(d, d)); i += 2; continue
            if not ham and c == '$':
                if i + 1 < len(metin) and metin[i+1] == '{':
                    derinlik = 0; j = i + 1
                    while j < len(metin):
                        if metin[j] == '{': derinlik += 1
                        elif metin[j] == '}':
                            derinlik -= 1
                            if derinlik == 0: break
                        j += 1
                    out.append('{%d}' % say); say += 1; i = j + 1; continue
                m = re.match(r'\$[A-Za-z_]\w*', metin[i:])
                if m:
                    out.append('{%d}' % say); say += 1; i += m.end(); continue
            out.append(c); i += 1
    return ''.join(out).replace('\x00DOLAR\x00', '$')

def topla():
    metinler = {}
    def ekle(t, yer):
        t = t.strip('\n') if t.strip() else t
        if not t.strip() or not re.search(r'[A-Za-z]', t):
            return
        # Sablonlarda yer tutucular disinda en az 4 harf olmali; yoksa
        # ("{0}s" gibi) calisma aninda alakasiz metinlerle eslesir.
        if '{0}' in t and len(re.findall(r'[A-Za-z]', re.sub(r'\{\d+\}', '', t))) < 4:
            return
        metinler.setdefault(t, yer)
    for d, _, fs in os.walk(LIB):
        for f in fs:
            if not f.endswith('.dart'):
                continue
            p = os.path.join(d, f)
            s = open(p, encoding='utf-8').read()
            rel = os.path.relpath(p, KOK)
            for m in re.finditer(r'\ben:\s*', s):
                r = literal_oku(s, m.end())
                if r: ekle(coz(r[0]), rel)
            for m in re.finditer(r'\b(_t|devreT|tanitimMetni)\(', s):
                i = m.end()
                args = []
                for _ in range(3):
                    r = literal_oku(s, i)
                    if r is None:
                        # ilk arguman dil degiskeni olabilir
                        mm = re.match(r'\s*[\w.]+\s*,', s[i:])
                        if mm and not args:
                            i += mm.end(); r2 = literal_oku(s, i)
                            if r2 is None: break
                            args.append(r2[0]); i = r2[1]
                            mm2 = re.match(r'\s*,', s[i:]);
                            if not mm2: break
                            i += mm2.end(); continue
                        break
                    args.append(r[0]); i = r[1]
                    mm = re.match(r'\s*,', s[i:])
                    if not mm: break
                    i += mm.end()
                if len(args) >= 2:
                    ekle(coz(args[1]), rel)
    # app_localizations 'en' tablosu
    p = os.path.join(LIB, 'utils', 'app_localizations.dart')
    s = open(p, encoding='utf-8').read()
    m = re.search(r"\n\s*'en':\s*\{", s)
    if m:
        i = m.end(); derinlik = 1; j = i
        while j < len(s) and derinlik:
            if s[j] == '{': derinlik += 1
            elif s[j] == '}': derinlik -= 1
            j += 1
        blok = s[i:j]
        for mm in re.finditer(r"'[^']+'\s*:\s*", blok):
            r = literal_oku(blok, mm.end())
            if r: ekle(coz(r[0]), 'lib/utils/app_localizations.dart')
    return metinler

if __name__ == '__main__':
    m = topla()
    hedef = os.path.join(KOK, 'assets', 'l10n', '_kaynak.json')
    os.makedirs(os.path.dirname(hedef), exist_ok=True)
    with open(hedef, 'w', encoding='utf-8') as f:
        json.dump(sorted(m.keys()), f, ensure_ascii=False, indent=0)
    sablon = sum(1 for k in m if '{0}' in k)
    print(f'{len(m)} metin ({sablon} sablon), {sum(len(k.split()) for k in m)} kelime -> {hedef}')
