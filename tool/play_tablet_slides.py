#!/usr/bin/env python3
"""Google Play TABLET ekran goruntulerini kurar.

    python3 tool/play_tablet_slides.py

Girdi : outputs/appstore/ipad{,_tr}/*.png  (2064x2752 — gercek
        Flutter motoruyla, tablet olcusunde cizilmis GERCEK ekranlar)
Cikti : outputs/play/tablet/<dil>/NN_*.png   1440x2560 (9:16)

NEDEN AYRI BIR DOSYA
--------------------
Play tablet gorselini de 16:9 ya da 9:16 istiyor, ama tabletin kendi
ekrani 3:4. Telefon setindeki olculer (1080x1920, 76 punto kenar
bosluk, 76 punto baslik) buyuk tuvalde minicik kaliyor; hepsi
1440/1080 = 4/3 ile buyutuluyor.

Diller: iPad karelerinde yalnizca TR ve EN var (test/appstore_shots_test.dart
`_ipad.diller`). Almanca ve Ispanyolca magaza sayfalarina INGILIZCE
takim konuyor — Turkce varsayilandan miras almaktansa okunur oluyor.

ESKI GORSELLER NEDEN ATILDI
---------------------------
Konsolda duran uc tablet karesi Agustos'tan kalmaydi ve uygulamayi
artik temsil etmiyordu: uzerlerinde eski **DevKom** adi, artik
olmayan bir **giris (login) ekrani** ve cocuk uygulamasiyla
ortusmeyen "Profesyonel Egitim" cercevesi vardi. Magaza gorselinin
uygulamayi dogru anlatmasi Play politikasi.
"""

import os
import sys

from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import play_slides as ps                                    # noqa: E402
from store_slides import SLIDES, CROP_ASPECT                 # noqa: E402

OLCEK = 4 / 3                       # 1080 -> 1440
W, H = 1440, 2560                   # tam 9:16
SRC = 'outputs/appstore'
OUT = 'outputs/play/tablet'
DILLER = {'tr': 'ipad_tr', 'en': 'ipad'}

KENAR = round(76 * OLCEK)

# TABLET SETINE HANGI EKRANLAR GIRIYOR
# ------------------------------------
# Ekranlarin cogu telefon sutunu icin yazilmis; tablet genisliginde
# icerik ustte bitiyor, gerisi bos kaliyor. Her karede EN UZUN
# kesintisiz bos serit olculdu (outputs/appstore/ipad_tr):
#
#   03_character %75  01_first_task %76  02_lesson %69  14_html_code %61
#   04_blocks    %62  13_slide_to_start %35  07_matching %30
#   05_predict_code %28  06_hint %24  12_chess %10  11_word_match %6
#   08_path %3  09_home %3  10_splash %0
#
# Magaza karesini daha dar kirpip bosluğu gizlemek yerine, yalnizca
# tabletin GERCEKTEN dolduğu ekranlar aliniyor (esik: %10). Play en
# az iki kare istiyor, elimizde uc tane var. Tablet duzeni
# duzeltildiginde esik gevser ve set genisler.
GECER = {'09_home', '08_path', '12_chess'}


def p(deger):
    """Telefon setindeki olcuyu tablet tuvaline tasir."""
    return round(deger * OLCEK)


def baslik(slayt, metin):
    """Telefon setindeki baslik, buyutulmus olculerle."""
    from PIL import ImageDraw
    d = ImageDraw.Draw(slayt)
    boyut = p(76)
    f = ps.font('800', boyut)
    koyu = ps.TEMA_AKTIF[1]
    y = p(126)
    for satir in metin.split('\n'):
        parcalar = ps.parse(satir)
        genislik = sum(d.textlength(t, font=f) + (p(34) if s == 'kutu' else 0)
                       for t, s in parcalar)
        if genislik > W - 2 * KENAR:
            raise SystemExit(f'baslik cok uzun: {satir!r}')
        x = KENAR
        for t, s in parcalar:
            tw = d.textlength(t, font=f)
            if s == 'kutu':
                d.rounded_rectangle(
                    [x, y - p(4), x + tw + p(34), y + boyut + p(12)],
                    p(18), fill=(255, 255, 255))
                d.text((x + p(17), y), t, font=f, fill=koyu)
                x += tw + p(34)
            elif s == 'vurgu':
                d.text((x, y), t, font=f, fill=(255, 226, 138))
                x += tw
            else:
                d.text((x, y), t, font=f, fill=(255, 255, 255))
                x += tw
        y += boyut + p(16)
    return y


def alt_satir(slayt, metin, y):
    from PIL import ImageDraw
    d = ImageDraw.Draw(slayt)
    f = ps.font('600', p(33))
    satirlar, buf = [], ''
    for k in metin.split(' '):
        deneme = (buf + ' ' + k).strip()
        if d.textlength(deneme, font=f) > W - 2 * KENAR - p(8) and buf:
            satirlar.append(buf)
            buf = k
        else:
            buf = deneme
    if buf:
        satirlar.append(buf)
    if len(satirlar) > 2:
        raise SystemExit(f'alt satir 2 satiri asiyor: {metin!r}')
    for s in satirlar:
        d.text((KENAR, y), s, font=f, fill=(226, 232, 245))
        y += p(46)
    return y


def sayac(slayt, i, toplam):
    from PIL import ImageDraw
    d = ImageDraw.Draw(slayt)
    d.rounded_rectangle([KENAR, H - p(92), KENAR + p(58), H - p(86)], p(3),
                        fill=(255, 255, 255, 210))
    d.text((KENAR, H - p(68)), f'{i:02d} / {toplam:02d}',
           font=ps.font('700', p(26)), fill=(255, 255, 255, 190))


def golge(slayt, tab, konum):
    """Cihazin arkasinda yumusak isik.

    play_slides.golge() isigi tuvalin ALT kenarina kadar uzatiyor
    (telefon oradan tasiyor). Tablet tasmadigi icin burada isik
    cihazin kendi kutusunu sariyor.
    """
    from PIL import Image as _I, ImageDraw, ImageFilter
    g = _I.new('RGBA', (W, H), (0, 0, 0, 0))
    x, yy = konum
    pad = p(90)
    ImageDraw.Draw(g).rounded_rectangle(
        [x - pad // 2, yy - pad // 2,
         x + tab.width + pad // 2, yy + tab.height + pad // 2],
        p(120), fill=(255, 255, 255, 46))
    slayt.alpha_composite(g.filter(ImageFilter.GaussianBlur(p(70))))


def uret(dil):
    klasor = os.path.join(OUT, dil)
    os.makedirs(klasor, exist_ok=True)
    kaynak = os.path.join(SRC, DILLER[dil])
    secim = [s for s in SLIDES if dil in s[4] and s[0] in GECER]
    sayi = len(secim)
    for i, (dosya, kirp, _yer, _hap, metinler) in enumerate(secim, 1):
        ps.TEMA_AKTIF = ps.TEMA[dosya]
        bas, alt = metinler[dil]

        # zemin()/telefon()/golge() modul genellerini okuyor; tuvali
        # buyuturken onlari da degistirmek gerekiyor.
        ps.W, ps.H = W, H
        slayt = ps.zemin(*ps.TEMA_AKTIF).convert('RGBA')

        y = baslik(slayt, bas)
        y = alt_satir(slayt, alt, y + p(14))

        shot = Image.open(os.path.join(kaynak, dosya + '.png')).convert('RGB')
        oran = CROP_ASPECT.get(dosya)
        bas_y = round(shot.height * kirp)
        if oran:
            # Oran, cihazin GENISLIGINE gore uygulaniyor (telefon
            # setindeki gibi): pencere cihazla birlikte buyuyor.
            # Bir ara tabletin en/boy orani ile olceklemeyi denedim,
            # pencere asiri uzadi ve 06/14_html_code'da ekranin bos
            # alt yarisi da kareye girdi.
            yukseklik = min(round(shot.width * oran), shot.height - bas_y)
            shot = shot.crop((0, bas_y, shot.width, bas_y + yukseklik))
        elif kirp:
            shot = shot.crop((0, bas_y, shot.width, shot.height))

        # YERLESIM TELEFON SETINDEN FARKLI.
        #
        # Telefon slaytinda cihaz alt kenardan TASIYOR. Tablet 3:4
        # oldugu icin 9:16 tuvalde tasacak kadar buyutulurse tuvalin
        # disina cikiyor; sigacak kadar kucultulurse de ustte ve
        # altta genis bos bantlar kaliyor (ilk denemede sayac cihazin
        # uzerine biniyordu). Bu yuzden cihaz, metnin bittigi yer ile
        # alt kenar payi arasindaki BANDA sigdirilip ortalaniyor.
        ust = y + p(40)
        alt_pay = H - p(150)              # sayaca yer
        bant = alt_pay - ust
        en_boy = shot.height / shot.width
        genislik = min(W - 2 * p(50), int(bant / en_boy))
        tab = ps.telefon(shot, genislik)
        tx = (W - tab.width) // 2
        ty = ust + (bant - tab.height) // 2
        golge(slayt, tab, (tx, ty))
        slayt.alpha_composite(tab, (tx, ty))

        sayac(slayt, i, sayi)
        yol = os.path.join(klasor, f'{i:02d}_{dosya}.png')
        slayt.convert('RGB').save(yol, 'PNG')
        print('  ', yol, slayt.size)


if __name__ == '__main__':
    for dil in DILLER:
        print(dil)
        uret(dil)
    print('bitti ->', OUT)
