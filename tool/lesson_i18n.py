# -*- coding: utf-8 -*-
"""Ders verisine Almanca/Ispanyolca alanlari ekler.

NEDEN BU ARAC VAR
-----------------
Ders icerigi 3.127 alanda Ingilizce, Almanca ve Ispanyolca'da SIFIRDI.
Elle duzenlemek 6.254 metin demek; her biri Dart kaynagina dogru kacisla
yazilmali. Bu arac ceviriyi ayri bir sozlukten okuyup `xEn:` satirinin
hemen ardina `xDe:` ve `xEs:` ekliyor.

KURAL: yalnizca EKLER. Var olan bir alani degistirmez, silmez. Ayni
metin baska derste de geciyorsa orasi da cevrilir - istenen budur.

Sozluk bicimi (JSON):
    {"metinler": {"<ingilizce>": ["<almanca>", "<ispanyolca>"]},
     "listeler": [{"en": [...], "de": [...], "es": [...]}]}
"""
import json
import re
import sys


def _literal_bitisi(src, i):
    """i, acilis tirnaginin indeksi. Kapanis tirnagindan SONRAKI indeksi doner."""
    q = i + 1
    while q < len(src):
        if src[q] == '\\':
            q += 2
            continue
        if src[q] == "'":
            return q + 1
        q += 1
    raise ValueError('kapanmamis literal')


def _deger_bitisi(src, i):
    """`xEn:` sonrasi degerin bittigi indeks (liste ya da bitisik literaller)."""
    while src[i] in ' \t\r\n':
        i += 1
    if src[i] == '[':
        derin = 0
        while i < len(src):
            if src[i] == "'":
                i = _literal_bitisi(src, i)
                continue
            if src[i] == '[':
                derin += 1
            elif src[i] == ']':
                derin -= 1
                if derin == 0:
                    return i + 1
            i += 1
        raise ValueError('kapanmamis liste')
    if src[i] != "'":
        return None  # degisken referansi vb. - dokunma
    while True:
        i = _literal_bitisi(src, i)
        j = i
        while j < len(src) and src[j] in ' \t\r\n':
            j += 1
        if j < len(src) and src[j] == "'":
            i = j
            continue
        return i


def _icerik(ham):
    """Kaynak metindeki literal iceriklerini (kacislar korunarak) birlestirir."""
    return ''.join(re.findall(r"'((?:[^'\\]|\\.)*)'", ham, re.S))


def _liste_icerik(ham):
    return tuple(re.findall(r"'((?:[^'\\]|\\.)*)'", ham, re.S))


def _lit(s):
    return "'" + s.replace("'", "\\'") + "'"


def uygula(dosya, sozluk):
    metinler = sozluk.get('metinler', {})
    listeler = {tuple(x['en']): (x['de'], x['es']) for x in sozluk.get('listeler', [])}

    src = open(dosya, encoding='utf-8').read()
    eklemeler = []
    atlanan = []

    for m in re.finditer(r'\n(\s*)([a-zA-Z]+)En:', src):
        girinti, ad = m.group(1), m.group(2)
        # Zaten De/Es verilmisse tekrar ekleme
        son = _deger_bitisi(src, m.end())
        if son is None:
            continue
        kuyruk = src[son:son + 200]
        if re.match(r'\s*,\s*' + ad + r'De:', kuyruk):
            continue

        ham = src[m.end():son]
        if ham.lstrip().startswith('['):
            anahtar = _liste_icerik(ham)
            cev = listeler.get(anahtar)
            liste = True
        else:
            anahtar = _icerik(ham)
            cev = metinler.get(anahtar)
            liste = False

        if cev is None:
            if anahtar:
                atlanan.append(list(anahtar) if liste else anahtar)
            continue

        de, es = cev
        if liste:
            de_s = '[\n' + ''.join(f'{girinti}  {_lit(x)},\n' for x in de) + girinti + ']'
            es_s = '[\n' + ''.join(f'{girinti}  {_lit(x)},\n' for x in es) + girinti + ']'
        else:
            de_s, es_s = _lit(de), _lit(es)

        # Sondaki virgul BILEREK var: orijinal virgulu yutup yerine
        # bunu yaziyoruz, yoksa sonraki alanla birlesip derlenmiyor.
        eklemeler.append(
            (son, f',\n{girinti}{ad}De: {de_s},\n{girinti}{ad}Es: {es_s},'))

    for son, metin in reversed(eklemeler):
        # Orijinal degerin ardindaki virgul varsa onu yut, sonra yeniden yaz.
        kalan = src[son:]
        k = re.match(r'\s*,', kalan)
        if k:
            src = src[:son] + metin + kalan[k.end():]
        else:
            src = src[:son] + metin + kalan

    open(dosya, 'w', encoding='utf-8').write(src)
    return len(eklemeler), atlanan


if __name__ == '__main__':
    dosya, sozluk_yolu = sys.argv[1], sys.argv[2]
    sozluk = json.load(open(sozluk_yolu, encoding='utf-8'))
    n, atlanan = uygula(dosya, sozluk)
    print(f'eklendi: {n}')
    if '-v' in sys.argv:
        for a in atlanan[:40]:
            print('  atlandi:', a)
