#!/usr/bin/env python3
"""iPhone Duo magaza slaytlarini kurar (Ekim 2026).

    python3 tool/duo_slides.py

Girdi : outputs/appstore/duo_ic{,_tr,_de,_es}/*.png  (2007x2853)
        outputs/appstore/duo_dis{,_tr,_de,_es}/*.png (1398x2034)
        test/appstore_shots_test.dart uretiyor: GERCEK Flutter
        ekranlari, Duo'nun ic ve dis ekran olcusunde cizilmis.
Cikti : outputs/appstore/slaytlar_duo_ic_<dil>/NN_*.png  2007x2853
        outputs/appstore/slaytlar_duo_dis_<dil>/NN_*.png 1398x2034

App Store Connect'te iPhone Duo ekran goruntuleri gonderilince urun
sayfasinda "Made for iPhone Duo" rozeti cikiyor. Nisan 2027'den
itibaren iOS 27.1 SDK ile derlenen her uygulama icin zorunlu.

Basliklar, renkler ve maskot balonlari App Store setiyle ayni (tek
kaynak: tool/store_slides.py SLIDES). Fark yalnizca cerceve: Duo'da
dinamik ada USTTE degil; durum cubugu ve kamera SAG kenarda. Bu
yuzden ust serit ve ada cizilmiyor, sag kenarda kucuk bir kamera
noktasi var. Ekran goruntuleri gercek ekran; hicbir yerde rozet ya
da puan iddiasi yok (App Store Kural 2.3.1).
"""

import os
import sys

from PIL import Image, ImageDraw

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import store_slides as ss  # noqa: E402

CIHAZLAR = {
    'duo_ic': (2007, 2853),
    'duo_dis': (1398, 2034),
}


def duo_cerceve(ekran, genislik):
    """Duz Duo cercevesi: ince kenar, yuvarlak kose, sag kenarda kamera."""
    ek = ekran.convert('RGBA')
    k = genislik / ek.width
    ew, eh = int(ek.width * k), int(ek.height * k)
    e = ek.resize((ew, eh), Image.LANCZOS)
    cer = int(genislik * 0.03)
    r_dis = int(genislik * 0.08)
    r_ic = r_dis - cer
    tw, th = ew + 2 * cer, eh + 2 * cer
    t = Image.new('RGBA', (tw, th), (0, 0, 0, 0))
    d = ImageDraw.Draw(t)
    d.rounded_rectangle([0, 0, tw - 1, th - 1], radius=r_dis,
                        fill=(18, 20, 32, 255))
    d.rounded_rectangle([3, 3, tw - 4, th - 4], radius=r_dis - 3,
                        outline=(70, 74, 96, 255), width=3)
    m = Image.new('L', (ew, eh), 0)
    ImageDraw.Draw(m).rounded_rectangle([0, 0, ew - 1, eh - 1],
                                        radius=r_ic, fill=255)
    t.paste(e, (cer, cer), m)
    # Kamera: sag kenarda, ustten biraz asagida, cercevenin icinde.
    kr = max(4, int(cer * 0.32))
    kx, ky = tw - cer // 2, cer + int(eh * 0.06)
    d.ellipse([kx - kr, ky - kr, kx + kr, ky + kr], fill=(6, 6, 10, 255))
    return t


def build(cihaz, lang):
    w, h = CIHAZLAR[cihaz]
    src_dir = os.path.join(ss.SRC, cihaz if lang == 'en' else f'{cihaz}_{lang}')
    out_dir = os.path.join(ss.SRC, f'slaytlar_{cihaz}_{lang}')
    if os.path.isdir(out_dir):
        for old in os.listdir(out_dir):
            if old.endswith('.png'):
                os.remove(os.path.join(out_dir, old))
    os.makedirs(out_dir, exist_ok=True)
    made = []
    for i, (name, crop_top, _yer, _pills, texts) in enumerate(ss.SLIDES, 1):
        path = os.path.join(src_dir, f'{ss.EKRAN.get(name, name)}.png')
        if not os.path.exists(path):
            raise SystemExit(f'{path} yok. Once Duo ekranlarini uret.')
        head, sub = texts[lang]
        ham = Image.open(path).convert('RGB')
        slide = ss.slayt_ciz(w, h, ham, crop_top, name, head, sub,
                             ss.BALON[name][lang], tohum=i * 7,
                             yanlar=ss.yan_ekranlar(src_dir, name))
        assert slide.size == (w, h), slide.size
        out = os.path.join(out_dir, f'{i:02d}_{name}.png')
        slide.save(out)
        made.append(out)
    return made


if __name__ == '__main__':
    # Cerceveyi Duo'nunkiyle degistir (yan telefonlar da ayni cerceveyi
    # kullaniyor).
    ss.telefon = duo_cerceve
    for cihaz in CIHAZLAR:
        for lang in ['tr', 'en', 'de', 'es']:
            files = build(cihaz, lang)
            print(f'{cihaz} {lang}: {len(files)} slayt')
