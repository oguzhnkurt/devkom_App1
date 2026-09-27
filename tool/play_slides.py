#!/usr/bin/env python3
"""Google Play magaza gorsellerini kurar.

    python3 tool/play_slides.py

Girdi : outputs/appstore/ekranlar{,_tr,_de,_es}/*.png
        (test/appstore_shots_test.dart uretiyor — gercek Flutter
        motoruyla cizilmis GERCEK ekranlar)
        ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png
Cikti : outputs/play/<dil>/NN_*.png   1080x1920  (ekran goruntuleri)
        outputs/play/ikon_512.png                (uygulama simgesi)
        outputs/play/one_cikan_<dil>.png         1024x500

NEDEN AYRI BIR URETICI
----------------------
App Store seti (tool/store_slides.py) 1290x2796, acik pastel zeminli,
basligi kimi slaytta ustte kimi altta. Play'in olculeri (9:16) ve
listeleme baglami farkli:

  * Play kartlari BEYAZ bir listenin icinde, yan yana ve KUCUK
    gorunuyor. Acik pastel zeminler orada birbirine karisiyor.
  * Play'de en fazla 8 ekran goruntusu var ve kullanici genelde ilk
    ikisini goruyor; seri hissi vermek icin hepsi ayni kaliba
    oturuyor (baslik hep ustte) ve altta numara serisi var.

Bu yuzden Play seti KOYU ve DOYGUN: her slaytin kendi rengi var, yazi
beyaz, telefon alt kenardan tasiyor. Uygulamanin kendi ekranlari acik
temali oldugu icin koyu zeminde one cikiyor.

ROZET VE PUAN YOK — BILEREK
---------------------------
Puan, yildiz, yorum sayisi, odul, "1 numara" ya da kullanici sayisi
iddiasi YOK. Hicbiri dogrulanabilir degil. Ayni kural App Store
setinde de gecerli (bkz. tool/store_slides.py).

METINLER TEK KAYNAKTAN
----------------------
Baslik ve alt satirlar `tool/store_slides.py` icindeki SLIDES
listesinden okunuyor. Iki magaza icin iki ayri metin tutmak, birini
guncelleyip otekini unutmak demek.
"""

import os
import sys

from PIL import Image, ImageDraw, ImageFilter, ImageFont

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from store_slides import SLIDES, PILLS, CROP_ASPECT, parse  # noqa: E402

W, H = 1080, 1920
FONT_DIR = 'assets/fonts'
SRC = 'outputs/appstore'
OUT = 'outputs/play'
IKON_KAYNAK = ('ios/Runner/Assets.xcassets/AppIcon.appiconset/'
               'Icon-App-1024x1024@1x.png')

DILLER = {'tr': 'ekranlar_tr', 'en': 'ekranlar',
          'de': 'ekranlar_de', 'es': 'ekranlar_es'}

# Slayt basina (ust renk, alt renk). Ikisi arasinda dikey gecis var:
# duz tek renk koyu zemin kucuk kartta yassi duruyordu.
#
# Renkler uygulamanin kendi vurgu paletinden; slaytlar yan yana
# gorununce gokkusagi gibi degil, akan bir dizi gibi duruyor.
TEMA = {
    '09_home':          ((37, 64, 175), (18, 30, 96)),
    '08_path':          ((11, 110, 158), (8, 52, 82)),
    '07_matching':      ((13, 130, 98), (7, 62, 50)),
    '02_lesson':        ((186, 98, 14), (92, 44, 6)),
    '04_blocks':        ((104, 52, 190), (48, 22, 92)),
    '14_html_code':     ((176, 56, 26), (86, 24, 10)),
    '12_chess':         ((170, 98, 38), (72, 36, 12)),
    '13_slide_to_start': ((88, 48, 186), (40, 20, 92)),
}


def font(weight, size):
    return ImageFont.truetype(
        os.path.join(FONT_DIR, f'Nunito-{weight}.ttf'), size)


def zemin(ust, alt):
    """Dikey gecis + sag ustte yumusak isik."""
    bg = Image.new('RGB', (W, H))
    d = ImageDraw.Draw(bg)
    for y in range(H):
        t = y / (H - 1)
        d.line([(0, y), (W, y)],
               fill=tuple(round(ust[i] + (alt[i] - ust[i]) * t)
                          for i in range(3)))
    isik = Image.new('RGB', (W, H), (0, 0, 0))
    r = 560
    ImageDraw.Draw(isik).ellipse(
        [W - r, -r // 2, W + r, r + r // 2],
        fill=tuple(min(255, c + 70) for c in ust))
    isik = isik.filter(ImageFilter.GaussianBlur(190))
    return Image.blend(bg, Image.blend(bg, isik, 0.55), 0.9)


def baslik(slayt, metin, boyut=76, ust=126):
    """Vurgulu baslik.

    Koyu zeminde vurgu TERSINE calisiyor: `[kelime]` BEYAZ kutunun
    icinde koyu yazi oluyor. App Store setinde bunun tersi (renkli
    kutu, beyaz yazi) — orada zemin acikti.
    """
    d = ImageDraw.Draw(slayt)
    f = font('800', boyut)
    koyu = TEMA_AKTIF[1]
    y = ust
    for satir in metin.split('\n'):
        parcalar = parse(satir)
        genislik = sum(d.textlength(t, font=f) + (34 if s == 'kutu' else 0)
                       for t, s in parcalar)
        if genislik > W - 150:
            raise SystemExit(
                f'baslik satiri cok uzun ({round(genislik)} > {W - 150}): '
                f'{satir!r}')
        x = 76
        for t, s in parcalar:
            tw = d.textlength(t, font=f)
            if s == 'kutu':
                d.rounded_rectangle([x, y - 4, x + tw + 34, y + boyut + 12],
                                    18, fill=(255, 255, 255))
                d.text((x + 17, y), t, font=f, fill=koyu)
                x += tw + 34
            elif s == 'vurgu':
                d.text((x, y), t, font=f, fill=(255, 226, 138))
                x += tw
            else:
                d.text((x, y), t, font=f, fill=(255, 255, 255))
                x += tw
        y += boyut + 16
    return y


def alt_satir(slayt, metin, y):
    """Alt aciklama — iki satira kadar sariliyor."""
    d = ImageDraw.Draw(slayt)
    f = font('600', 33)
    kelimeler = metin.split(' ')
    satirlar, buf = [], ''
    for k in kelimeler:
        deneme = (buf + ' ' + k).strip()
        if d.textlength(deneme, font=f) > W - 160 and buf:
            satirlar.append(buf)
            buf = k
        else:
            buf = deneme
    if buf:
        satirlar.append(buf)
    if len(satirlar) > 2:
        raise SystemExit(f'alt satir 2 satiri asiyor: {metin!r}')
    for s in satirlar:
        d.text((76, y), s, font=f, fill=(226, 232, 245))
        y += 46
    return y


def telefon(shot, genislik):
    """Cerceveli telefon. Alt kenardan TASIYOR: tam sigan telefon
    kartvizit gibi duruyordu, tasan telefon 'devami var' hissi
    veriyor."""
    olcek = genislik / shot.width
    shot = shot.resize((genislik, round(shot.height * olcek)), Image.LANCZOS)
    kenar = max(10, round(genislik * 0.021))
    yaricap = round(genislik * 0.10)
    dw, dh = shot.width + kenar * 2, shot.height + kenar * 2
    dev = Image.new('RGBA', (dw, dh), (0, 0, 0, 0))
    ImageDraw.Draw(dev).rounded_rectangle(
        [0, 0, dw - 1, dh - 1], yaricap, fill=(16, 22, 34, 255))
    maske = Image.new('L', shot.size, 0)
    ImageDraw.Draw(maske).rounded_rectangle(
        [0, 0, shot.width - 1, shot.height - 1], yaricap - kenar, fill=255)
    dev.paste(shot, (kenar, kenar), maske)
    return dev


def golge(kat, telefon_img, konum):
    """Telefonun arkasina genis, yumusak bir isik."""
    g = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    x, y = konum
    pad = 90
    ImageDraw.Draw(g).rounded_rectangle(
        [x - pad // 2, y - pad // 2,
         x + telefon_img.width + pad // 2, H + pad],
        120, fill=(255, 255, 255, 46))
    g = g.filter(ImageFilter.GaussianBlur(70))
    kat.alpha_composite(g)


def haplar(slayt, y):
    """Kurs rozetleri — yalnizca ilk slaytta.

    Hepsi uygulamada GERCEKTEN var olan kurslar; katalogda karsiligi
    olmayan bir dil buraya yazilmaz.
    """
    # DOLGU AYRI KATMANDA.
    #
    # Ilk surumde yarı saydam beyaz dolgu dogrudan RGBA slayta
    # ciziliyordu. PIL bunu HARMANLAMIYOR, pikseli oldugu gibi
    # DEGISTIRIYOR: rozetler alfa 38'lik beyaza donuyor, ustune
    # yazilan beyaz yazi da kayboluyordu — magazada ici bos beyaz
    # baloncuklar. Dolgu ayri bir katmana cizilip alpha_composite
    # ile bindiriliyor; cerceve ve yazi sonra, opak olarak.
    f = font('800', 30)
    olcu = ImageDraw.Draw(slayt)
    kat = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    kd = ImageDraw.Draw(kat)
    kutular = []
    x, satir = 76, y
    for etiket, _ in PILLS:
        tw = olcu.textlength(etiket, font=f)
        pw, ph = round(tw) + 52, 60
        if x + pw > W - 76:
            x = 76
            satir += ph + 14
        kutular.append((x, satir, pw, ph, etiket))
        kd.rounded_rectangle([x, satir, x + pw, satir + ph], ph // 2,
                             fill=(255, 255, 255, 46))
        x += pw + 14
    slayt.alpha_composite(kat)
    d = ImageDraw.Draw(slayt)
    for x, satir_y, pw, ph, etiket in kutular:
        d.rounded_rectangle([x, satir_y, x + pw, satir_y + ph], ph // 2,
                            outline=(255, 255, 255), width=3)
        d.text((x + 26, satir_y + 13), etiket, font=f,
               fill=(255, 255, 255))
    return satir + 60


def sayac(slayt, i, toplam):
    """Sol altta '01 / 08'. Sekiz kart yan yana gorununce seri
    oldugu anlasiliyor."""
    d = ImageDraw.Draw(slayt)
    d.rounded_rectangle([76, H - 92, 76 + 58, H - 86], 3,
                        fill=(255, 255, 255, 210))
    d.text((76, H - 68), f'{i:02d} / {toplam:02d}',
           font=font('700', 26), fill=(255, 255, 255, 190))


def ekran_goruntuleri(dil):
    klasor = os.path.join(OUT, dil)
    os.makedirs(klasor, exist_ok=True)
    global TEMA_AKTIF
    for i, (dosya, kirp, _yer, _hap, metinler) in enumerate(SLIDES, 1):
        if dil not in metinler:
            continue
        TEMA_AKTIF = TEMA[dosya]
        bas, alt = metinler[dil]
        slayt = zemin(*TEMA_AKTIF).convert('RGBA')

        y = baslik(slayt, bas)
        y = alt_satir(slayt, alt, y + 14)
        if i == 1:
            y = haplar(slayt, y + 26)

        shot = Image.open(
            os.path.join(SRC, DILLER[dil], dosya + '.png')).convert('RGB')

        # EKRAN PENCERESI: store_slides'taki elle ayarlanmis oranlar.
        # Ham ekranin tamami (1290x2796) konunca altta kocaman bos
        # beyaz bir alan kaliyordu — telefonun yarisi bos duruyordu.
        oran = CROP_ASPECT.get(dosya)
        bas_y = round(shot.height * kirp)
        if oran:
            yukseklik = min(round(shot.width * oran), shot.height - bas_y)
            shot = shot.crop((0, bas_y, shot.width, bas_y + yukseklik))
        elif kirp:
            shot = shot.crop((0, bas_y, shot.width, shot.height))

        # TELEFONUN BOYU GEOMETRIDEN CIKIYOR.
        #
        # Sabit genislik verince kisa kirpilan ekranlarda (satranc
        # 1.16) telefon slaytin ortasinda kucucuk kaliyor, uzun
        # olanlarda tasma cok oluyordu. Burada once telefonun
        # OTURACAGI yer belirleniyor, genislik ondan hesaplaniyor.
        ty = min(max(y + 80, 600), 760)
        en_boy = shot.height / shot.width
        genislik = int(min(max((H + 70 - ty) / en_boy, 560), 880))
        tel = telefon(shot, genislik)
        tx = (W - tel.width) // 2
        golge(slayt, tel, (tx, ty))
        slayt.alpha_composite(tel, (tx, ty))

        sayac(slayt, i, len([s for s in SLIDES if dil in s[4]]))
        yol = os.path.join(klasor, f'{i:02d}_{dosya}.png')
        slayt.convert('RGB').save(yol, 'PNG')
        print('  ', yol)


def ikon():
    """Play simgesi = uygulamanin GERCEK simgesi.

    Play'deki simge cihazdaki simgeden farkli olamaz; kullanici
    magazada gordugu seyi ana ekranda ariyor. Bu yuzden yeni bir
    tasarim degil, iOS 1024'un birebir kucultulmusu."""
    os.makedirs(OUT, exist_ok=True)
    im = Image.open(IKON_KAYNAK).convert('RGBA')
    im = im.resize((512, 512), Image.LANCZOS)
    yol = os.path.join(OUT, 'ikon_512.png')
    im.save(yol, 'PNG')
    print('  ', yol, im.size, im.mode)


ONE_CIKAN = {
    'tr': ('Renkli bloklarla başla,', 'gerçek kod yaz'),
    'en': ('Start with coloured blocks,', 'end with real code'),
    'de': ('Beginne mit bunten Blöcken,', 'schreibe echten Code'),
    'es': ('Empieza con bloques,', 'acaba con código real'),
}


def one_cikan(dil):
    """1024x500 one cikan grafik.

    Play bunu bazi yuzeylerde kenarlarindan kirpiyor; bu yuzden
    yazi ve maskot ORTAYA yakin duruyor, kenarlarda 90 piksel
    bos pay var. Alfa YOK — Play seffaflik kabul etmiyor.
    """
    w, h = 1024, 500
    ust, alt = (37, 64, 175), (18, 30, 96)
    g = Image.new('RGB', (w, h))
    d = ImageDraw.Draw(g)
    for y in range(h):
        t = y / (h - 1)
        d.line([(0, y), (w, y)],
               fill=tuple(round(ust[i] + (alt[i] - ust[i]) * t)
                          for i in range(3)))
    isik = Image.new('RGB', (w, h), (0, 0, 0))
    ImageDraw.Draw(isik).ellipse([w - 420, -180, w + 160, 380],
                                 fill=(96, 132, 255))
    isik = isik.filter(ImageFilter.GaussianBlur(140))
    g = Image.blend(g, Image.blend(g, isik, 0.6), 0.9)
    d = ImageDraw.Draw(g)

    # MASKOT METNE BINMEMELI.
    #
    # Ilk surumde maskot 330 piksel yuksekti ve elindeki kalp sola
    # tasip "Arduino" rozetinin ustune biniyordu. Boyu kuculdu,
    # saga dayandi; metin sutunu da 560 pikselle sinirli.
    maskot = Image.open('assets/maskot/devi.png').convert('RGBA')
    mh = 286
    maskot = maskot.resize(
        (round(maskot.width * mh / maskot.height), mh), Image.LANCZOS)
    g.paste(maskot, (w - maskot.width - 46, h - mh - 62), maskot)

    # KENARLARDAN PAY. Play one cikan grafigi bazi yuzeylerde
    # kenarlarindan kirpiyor; yazi 140 pikselden once baslamiyor.
    d.text((140, 128), 'DevEducation', font=font('800', 62),
           fill=(255, 255, 255))
    s1, s2 = ONE_CIKAN[dil]
    d.text((140, 216), s1, font=font('700', 32), fill=(206, 219, 255))
    d.text((140, 260), s2, font=font('700', 32), fill=(255, 226, 138))

    x = 140
    f = font('800', 24)
    for etiket, _ in PILLS[:3]:
        tw = d.textlength(etiket, font=f)
        pw = round(tw) + 40
        d.rounded_rectangle([x, 342, x + pw, 390], 24,
                            outline=(255, 255, 255), width=3)
        d.text((x + 20, 352), etiket, font=f, fill=(255, 255, 255))
        x += pw + 12

    yol = os.path.join(OUT, f'one_cikan_{dil}.png')
    g.save(yol, 'PNG')          # 24-bit, alfa yok
    print('  ', yol, g.size, g.mode)


if __name__ == '__main__':
    print('simge')
    ikon()
    for dil in DILLER:
        print(dil)
        ekran_goruntuleri(dil)
        one_cikan(dil)
    print('bitti ->', OUT)
