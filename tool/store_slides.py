#!/usr/bin/env python3
"""App Store slaytlarini kurar — GOKKUSAGI tarzi.

    python3 tool/store_slides.py

Girdi : outputs/appstore/ekranlar{,_tr,_de,_es}/*.png
        (test/appstore_shots_test.dart uretiyor — gercek Flutter
        motoruyla cizilmis GERCEK ekranlar, elde yapilmis taklit degil)
Cikti : outputs/appstore/slaytlar_<dil>/NN_*.png  — 1290x2796

Ayni motor Google Play setini de ciziyor (tool/play_slides.py,
1080x1920): `slayt_ciz(W, H, ...)` olcuden bagimsiz.

TASARIM
-------
Sekiz slayt, birbirine bagli: *kodlama ogrenir -> adim adim ->
oyunla pekistirir -> dersin ici -> bloklari surukler -> gercek kodu
yazar -> satrancla dusunur -> ogrendigini sinar.*

Her slaytta:

  - Doygun, cok duraklı bir GOKKUSAGI gecisi. Renkler uygulamanin
    kendi vurgu renkleri (mor baslik, mavi, robotik yesili, turuncu
    kart, pembe). Her slaytin kendi paleti var; yan yana dizilince
    bir renk akisi oluyor.
  - Zeminde uygulamanin oyun alanindaki gibi soluk semboller: blok,
    { }, </>, ok, halka.
  - Beyaz, ortalanmis baslik. [kelime] beyaz hap icinde renkli yazi,
    *kelime* sari yazi. Goz once o kelimeye takiliyor.
  - Telefon DUZ duruyor ve alt kenardan TASIYOR. (Egik telefonda
    ekrandaki yazi okunmuyordu; tam sigan telefon kartvizit gibi
    duruyordu.)
  - Maskot (Devi, uygulamadaki tek karakter) telefonun ust
    kosesinden bakiyor, kisa bir balonla. EKRANIN ICERIGINI
    KAPATMIYOR: ilk denemede telefonun ortasina binip listeyi
    ortuyordu; artik yalnizca durum cubugu seridinin ustunde.

DURUM CUBUGU SERIDI
-------------------
Ekran goruntuleri test motorunda durum cubugu OLMADAN cizildi
(guvenli alan yok). Dinamik ada dogrudan icerigin ustune biniyor ve
basligi kesiyordu. Ekranin ustune kendi ust renginde bir serit
ekleniyor; ada o seridin icinde duruyor.

ROZET VE PUAN YOK — BILEREK
---------------------------
Ornek alinan tasarimlarda "1M+ Learner", "JOIN 150,000+ PEOPLES",
"#1 THERAPY EXPERIENCE" ve yildizlar var. Bizde YOK ve konulmayacak:
hicbiri dogrulanabilir degil. Puanlar gercek deneyimden birikir;
slaytta uydurulmaz (App Store Kural 2.3.1). Gercek bir sayi ya da
odul olunca eklenir. Maskotun balonlari da iddia degil, cagri.

Basliklari degistirmek icin tek yer: asagidaki SLIDES listesi.
"""

import math
import os
import random

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

W, H = 1290, 2796

FONT_DIR = 'assets/fonts'
MASKOT = 'assets/maskot/devi.png'
SRC = 'outputs/appstore'

# Ilk slayttaki kurs rozetleri. Hepsi uygulamada gercekten VAR OLAN
# kurslar — katalogda karsiligi olmayan bir dil buraya yazilmaz
# (test/appstore_slides_test.dart kontrol ediyor). Gokkusagi tarzinda
# rozet cizilmiyor (alt satir kurslari zaten sayiyor); liste tablet
# seti ve one cikan grafik icin duruyor.
PILLS = [
    ('Scratch', (255, 140, 26)),
    ('Python', (55, 118, 171)),
    ('mBlock', (124, 77, 255)),
    ('Arduino', (0, 151, 157)),
    ('HTML', (227, 79, 38)),
    ('C#', (149, 66, 244)),
]

# Gokkusagi paletleri: gecisin duraklari. Uygulamanin kendi renkleri.
PALET = {
    'mor':   [(124, 77, 255), (41, 121, 255), (0, 191, 165)],
    'deniz': [(41, 121, 255), (0, 184, 212), (0, 200, 83)],
    'gun':   [(255, 109, 0), (255, 64, 129), (124, 77, 255)],
    # Sari ile BASLAMIYOR: sari zeminde beyaz baslik ve sari vurgu
    # okunmuyordu (ilk denemede 4. slayt).
    'sicak': [(255, 145, 0), (244, 81, 30), (216, 27, 96)],
    'mavi':  [(0, 145, 234), (41, 121, 255), (124, 77, 255)],
    'ates':  [(233, 30, 99), (255, 87, 34), (255, 152, 0)],
    'orman': [(0, 200, 83), (0, 184, 212), (41, 121, 255)],
    'gece':  [(124, 77, 255), (233, 30, 99), (255, 109, 0)],
}

# Slayt basina: (palet, hap icindeki yazinin rengi, maskot yani).
# Maskot slayttan slayta yer degistiriyor; hep ayni kosede durunca
# sekiz slayt ayni kaliptan cikmis gibi gorunuyordu.
THEME = {
    '09_home':           ('mor',   (108, 60, 224), 'sag'),
    '08_path':           ('deniz', (21, 101, 192), 'sol'),
    '07_matching':       ('gun',   (233, 30, 99),  'sag'),
    '02_lesson':         ('sicak', (230, 81, 0),   'sol'),
    '27_mblock_tezgah':  ('mavi',  (41, 98, 255),  'sag'),
    '14_html_code':      ('ates',  (216, 27, 96),  'sol'),
    '12_chess':          ('orman', (0, 137, 123),  'sag'),
    '06_hint':           ('gece',  (124, 77, 255), 'sol'),
}

# TELEFONUN DISINA TASAN BUYUTULMUS KART YOK.
#
# Bir surumde ekranin bir parcasi buyutulup slaytin kenarindan
# sarkitiliyordu. Iki sorunu vardi: ekranda zaten gorunen seyi
# tekrar gosteriyordu ve telefonun icerigini kapatiyordu. Kaldirildi;
# slayt baslik + tek telefon + maskot.

# Telefonun slayt genisligine orani. Tezgah ekrani biraz daha genis:
# bloklarin yazisi okunmali.
TELEFON = {
    '27_mblock_tezgah': 0.80,
}
TELEFON_VARSAYILAN = 0.74

# Kirpma penceresinin en-boy orani (play tablet seti hala kullaniyor).
# Gokkusagi slaytinda telefon alt kenardan tastigi icin pencere,
# telefonun gorunen boyuna gore ayrica hesaplaniyor.
CROP_ASPECT = {
    '09_home': 1.95,
    '10_splash': 1.55,
    '11_word_match': 1.55,
    '02_lesson': 1.55,
    '08_path': 1.95,
    '04_blocks': 1.52,
    '27_mblock_tezgah': 1.55,
    '07_matching': 1.9,
    '06_hint': 1.9,
    '03_character': 1.02,
    '12_chess': 1.16,
    '13_slide_to_start': 1.78,
    '14_html_code': 1.45,
    '01_first_task': 1.5,
}

# Maskotun balonu. Kisa bir cagri — iddia degil.
BALON = {
    '09_home': {'tr': 'Hadi başlayalım!', 'en': 'Let’s start!',
                'de': 'Los geht’s!', 'es': '¡Empecemos!'},
    '08_path': {'tr': 'Sıradaki ders!', 'en': 'Next lesson!',
                'de': 'Nächste Lektion!', 'es': '¡Siguiente lección!'},
    '07_matching': {'tr': 'Ben de oynarım!', 'en': 'Let me play!',
                    'de': 'Ich spiel mit!', 'es': '¡Yo también juego!'},
    '02_lesson': {'tr': 'Birlikte öğrenelim!', 'en': 'Let’s learn!',
                  'de': 'Lass uns lernen!', 'es': '¡Aprendamos!'},
    '27_mblock_tezgah': {'tr': 'Sürükle, bırak!', 'en': 'Drag and drop!',
                         'de': 'Ziehen, ablegen!',
                         'es': '¡Arrastra y suelta!'},
    '14_html_code': {'tr': 'Gerçek kod!', 'en': 'Real code!',
                     'de': 'Echter Code!', 'es': '¡Código real!'},
    '12_chess': {'tr': 'Hamle sende!', 'en': 'Your move!',
                 'de': 'Du bist dran!', 'es': '¡Te toca!'},
    '06_hint': {'tr': 'Bunu biliyorum!', 'en': 'I know this!',
                          'de': 'Das weiß ich!', 'es': '¡Me la sé!'},
}

# Baslik: [koseli parantez] = beyaz hap icinde renkli yazi,
#         *yildiz*        = sari yazi.
SLIDES = [
    # (dosya, kirpmanin BASLADIGI oran, (eski) baslik yeri, hap etiket
    #  var mi, {dil: (baslik, alt satir)})
    #
    # HER SLAYT DOLU BIR EKRAN. Bir surumde 2. slayt acilis ekrani
    # (kocaman bos mor zemin, ortada simge) ve 3. slayt kelime
    # eslestirme (ustte bos oyun tahtasi) idi; ikisi de slaytta bos
    # duruyordu. Yerlerine katalogdaki ogrenme yolu ve renkli
    # eslestirme oyunu kondu.
    ('09_home', 0.0, 'ust', False, {
        'tr': ('[Kodlama] ve\nrobotik öğren',
               'Sıfırdan başla · 9 kurs · Scratch, mBlock, Arduino, Python'),
        'en': ('Learn [coding]\nand robotics',
               'Start from zero · 9 courses · Scratch, mBlock, Arduino, Python'),
        'de': ('[Programmieren]\nund Robotik lernen',
               'Bei null anfangen · 9 Kurse · Scratch, mBlock, Arduino, Python'),
        'es': ('Aprende a [programar]\ny robótica',
               'Empieza de cero · 9 cursos · Scratch, mBlock, Arduino, Python'),
    }),
    ('08_path', 0.0, 'alt', False, {
        'tr': ('[Bloklardan]\ngerçek koda',
               '9 kurs, adım adım — her kurs bir öncekinin üstüne biner'),
        'en': ('From [blocks]\nto real code',
               '9 courses, step by step — each one builds on the last'),
        'de': ('Von [Blöcken]\nzu echtem Code',
               '9 Kurse, Schritt für Schritt — jeder baut auf dem letzten auf'),
        'es': ('De los [bloques]\nal código',
               '9 cursos, paso a paso — cada uno se apoya en el anterior'),
    }),
    ('07_matching', 0.0, 'ust', False, {
        'tr': ('[Oyunla] pekiştirir',
               '16 mini oyun · terimleri eşleştir, komutları sırala, '
               'labirenti geç'),
        'en': ('Practises by [playing]',
               '16 mini games · match terms, order commands, '
               'get through the maze'),
        'de': ('Übt beim [Spielen]',
               '16 Minispiele · Begriffe zuordnen, Befehle ordnen, '
               'durchs Labyrinth'),
        'es': ('Practica [jugando]',
               '16 minijuegos · empareja términos, ordena instrucciones, '
               'cruza el laberinto'),
    }),
    ('02_lesson', 0.0, 'alt', False, {
        'tr': ('Scratch’i *adım adım*\nöğrenir',
               'Blok nedir, ne işe yarar — kısa adımlarla, maskotuyla'),
        'en': ('Learns Scratch\n*step by step*',
               'What a block is and what it does — in short steps'),
        'de': ('Lernt Scratch\n*Schritt für Schritt*',
               'Was ein Block ist und was er tut — in kurzen Schritten'),
        'es': ('Aprende Scratch\n*paso a paso*',
               'Qué es un bloque y para qué sirve — en pasos cortos'),
    }),
    # GERCEK BLOK EDITORU (mBlock tezgahi, scratch-blocks).
    #
    # Onceki 5. slayt Scratch dersinin kart dizme ekraniydi
    # (04_blocks). Ayni hikayeyi — "bloklari surukleyip kodu kurar" —
    # artik gercek blok editoru anlatiyor. Ekran WebView oldugu icin
    # iki motorla ciziliyor: ders Flutter'dan, tezgah kendi sayfasindan
    # (bkz. tool/mblock_tezgah_slayt.py). Elle cizilmis bir sey yok.
    #
    # "mBlock'taki bloklar" iddiasi dogru: etiketler mBlock/Scratch'in
    # kendi dil dosyasindan, renkler mblock_palette.dart ile ayni
    # (test/mblock_tezgahi_test.dart ikisini de denetliyor).
    ('27_mblock_tezgah', 0.0, 'alt', False, {
        'tr': ('Blokları *sürükleyip*\nkodu kurar',
               'Gerçek blok editörü — mBlock’taki bloklar, aynı yazı ve renkle'),
        'en': ('*Drags* blocks\ninto working code',
               'A real block editor — the same blocks, words and colours as mBlock'),
        'de': ('*Zieht* Blöcke zu\nfertigem Code',
               'Ein echter Block-Editor — dieselben Blöcke, Wörter und Farben wie mBlock'),
        'es': ('*Arrastra* bloques\ny arma el código',
               'Un editor de bloques real — los mismos bloques, textos y colores que mBlock'),
    }),
    # Bloklarin yaninda gercek kod: uygulama blokta kalmiyor.
    ('14_html_code', 0.0, 'alt', False, {
        'tr': ('Sonra *gerçek kodu*\nkendi yazar',
               'HTML, CSS, Python, C# — harf harf, ipuçlarıyla'),
        'en': ('Then writes the\n*real code*',
               'HTML, CSS, Python, C# — line by line, with hints'),
        'de': ('Dann schreibt es\n*echten Code*',
               'HTML, CSS, Python, C# — Zeile für Zeile, mit Tipps'),
        'es': ('Después escribe\n*código real*',
               'HTML, CSS, Python, C# — línea a línea, con pistas'),
    }),
    # Satranc: kodlama disindaki tek "dusunme" oyunu. Uc zorluk
    # seviyesi gercek (Baslangic / Orta / Ileri); ELO sayisi slayta
    # YAZILMIYOR, iddia gibi durur.
    ('12_chess', 0.235, 'alt', False, {
        'tr': ('[Satranç] ile\nstratejik düşünür',
               'Üç zorluk seviyesi — acele etmeden, hamlesini planlayarak'),
        'en': ('Thinks ahead\nwith [chess]',
               'Three difficulty levels — plans the move instead of rushing'),
        'de': ('Denkt voraus\nbeim [Schach]',
               'Drei Schwierigkeitsgrade — plant den Zug, statt zu hetzen'),
        'es': ('Piensa antes\ncon el [ajedrez]',
               'Tres niveles de dificultad — planea la jugada sin prisa'),
    }),
    # QUIZ SORUSU. Onceki 8. slayt quiz giris ekraniydi ("Basla" icin
    # kaydir): basligi soz veriyor, ekrani hic soru gostermiyordu. Artik
    # gercek quiz ekrani — soru, secilmis cevap ve aciklama.
    ('06_hint', 0.0, 'ust', False, {
        'tr': ('Öğrendiğini [sınar]',
               'Derslerden gelen sorular · doğru cevapla, jeton ve XP kazan'),
        'en': ('[Tests] what it learned',
               'Questions from the lessons · answer right, earn coins and XP'),
        'de': ('[Prüft] das Gelernte',
               'Fragen aus den Lektionen · richtig antworten, Münzen und XP'),
        'es': ('[Pone a prueba]\nlo aprendido',
               'Preguntas de las lecciones · acierta y gana monedas y XP'),
    }),
]


def font(weight, size):
    return ImageFont.truetype(
        os.path.join(FONT_DIR, f'Nunito-{weight}.ttf'), int(size))


def parse(text):
    """'[a] b *c*' -> [('a','kutu'), (' b ','duz'), ('c','vurgu')]"""
    out = []
    buf = ''
    i = 0
    while i < len(text):
        ch = text[i]
        if ch in '[*':
            close = ']' if ch == '[' else '*'
            j = text.index(close, i + 1)
            if buf:
                out.append((buf, 'duz'))
                buf = ''
            out.append((text[i + 1:j], 'kutu' if ch == '[' else 'vurgu'))
            i = j + 1
        else:
            buf += ch
            i += 1
    if buf:
        out.append((buf, 'duz'))
    return out


# ------------------------------------------------------------- zemin

_ZEMIN = {}


def gradyan(w, h, renkler, aci=35):
    """Cok duraklı capraz gecis + buyuk yumusak isik lekeleri."""
    anahtar = (w, h, tuple(renkler), aci)
    if anahtar in _ZEMIN:
        return _ZEMIN[anahtar].copy()
    ca, sa = math.cos(math.radians(aci)), math.sin(math.radians(aci))
    boy = abs(w * ca) + abs(h * sa)
    ys, xs = np.mgrid[0:h, 0:w].astype(np.float32)
    t = np.clip((xs * ca + ys * sa) / boy, 0, 1)
    n = len(renkler) - 1
    i = np.minimum((t * n).astype(int), n - 1)
    f = (t * n - i)[..., None]
    r = np.array(renkler, dtype=np.float32)
    rgb = r[i] + (r[i + 1] - r[i]) * f
    g = Image.fromarray(rgb.astype(np.uint8), 'RGB').convert('RGBA')

    leke = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(leke)
    for cx, cy, rr, al in [(0.15, 0.12, 0.55, 70), (0.9, 0.55, 0.5, 55),
                           (0.3, 0.95, 0.45, 45)]:
        R = int(rr * w)
        d.ellipse([cx * w - R, cy * h - R, cx * w + R, cy * h + R],
                  fill=(255, 255, 255, al))
    g.alpha_composite(leke.filter(ImageFilter.GaussianBlur(w * 0.12)))
    _ZEMIN[anahtar] = g
    return g.copy()


def semboller(w, h, tohum=7, adet=22):
    """Uygulamanin oyun alani zemini gibi: blok, { }, </>, ok, halka."""
    k = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(k)
    rnd = random.Random(tohum)
    for _ in range(adet):
        x, y = rnd.random() * w, rnd.random() * h
        s = w * (0.05 + rnd.random() * 0.06)
        c = (255, 255, 255, int(28 + rnd.random() * 30))
        tur = rnd.choice(['blok', 'parantez', 'ok', 'daire', 'kod'])
        if tur == 'blok':
            d.rounded_rectangle([x, y, x + s * 1.8, y + s * 0.8],
                                radius=s * 0.2, outline=c,
                                width=max(4, int(s * 0.09)))
            d.rectangle([x + s * 0.3, y + s * 0.8 - 2, x + s * 0.7,
                         y + s * 0.95], fill=c)
        elif tur == 'parantez':
            d.text((x, y), '{ }', font=font('800', s * 1.3), fill=c)
        elif tur == 'kod':
            d.text((x, y), '</>', font=font('800', s * 1.1), fill=c)
        elif tur == 'ok':
            d.line([x, y + s / 2, x + s * 1.4, y + s / 2], fill=c,
                   width=max(5, int(s * 0.12)))
            d.polygon([(x + s * 1.4, y + s * 0.2), (x + s * 1.8, y + s / 2),
                       (x + s * 1.4, y + s * 0.8)], fill=c)
        else:
            d.ellipse([x, y, x + s, y + s], outline=c,
                      width=max(4, int(s * 0.1)))
    return k


# ------------------------------------------------------------ telefon

def telefon(ekran, genislik):
    """DUZ telefon, ustte durum cubugu seridi ve dinamik ada."""
    ek = ekran.convert('RGBA')
    serit = int(ek.width * 0.10)
    ust = ek.getpixel((ek.width // 2, 2))
    tam = Image.new('RGBA', (ek.width, ek.height + serit), ust)
    tam.paste(ek, (0, serit))
    k = genislik / tam.width
    ew, eh = int(tam.width * k), int(tam.height * k)
    e = tam.resize((ew, eh), Image.LANCZOS)
    cer = int(genislik * 0.035)
    r_dis = int(genislik * 0.14)
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
    ada_w = int(ew * 0.28)
    ada_h = int(ada_w * 0.3)
    ay = cer + int(ew * 0.025)
    d.rounded_rectangle([tw // 2 - ada_w // 2, ay, tw // 2 + ada_w // 2,
                         ay + ada_h], radius=ada_h // 2,
                        fill=(8, 8, 12, 255))
    return t


def golge(img, bulan, alfa, kay=(0, 30)):
    a = img.split()[3].point(lambda v: int(v * alfa / 255))
    g = Image.new('RGBA', (img.width + bulan * 4, img.height + bulan * 4),
                  (0, 0, 0, 0))
    sh = Image.new('RGBA', img.size, (20, 10, 60, 255))
    sh.putalpha(a)
    g.paste(sh, (bulan * 2 + kay[0], bulan * 2 + kay[1]), sh)
    return g.filter(ImageFilter.GaussianBlur(bulan))


# -------------------------------------------------------------- metin

def baslik_olc(d, metin, boy):
    f = font('800', boy)
    pad = boy * 0.22
    en = 0
    for satir in metin.split('\n'):
        g = sum(d.textlength(t, font=f) + (pad * 1.2 if s == 'kutu' else 0)
                for t, s in parse(satir))
        en = max(en, g)
    return en


def baslik(tuval, metin, y, boy, hap_renk, sinir):
    """Ortalanmis beyaz baslik. Sigmazsa kuculur; en kucukte de
    sigmazsa DURUR — uzun bir ceviri sessizce tasmasin."""
    d = ImageDraw.Draw(tuval)
    en_kucuk = int(boy * 0.78)
    while baslik_olc(d, metin, boy) > sinir:
        boy -= 2
        if boy < en_kucuk:
            raise SystemExit(
                f'baslik satiri cok uzun ({round(baslik_olc(d, metin, boy))}'
                f' > {sinir}): {metin!r}')
    f = font('800', boy)
    pad = boy * 0.22
    for satir in metin.split('\n'):
        parcalar = parse(satir)
        gen = [d.textlength(t, font=f) + (pad * 1.2 if s == 'kutu' else 0)
               for t, s in parcalar]
        x = (tuval.width - sum(gen)) / 2
        for (t, s), gw in zip(parcalar, gen):
            if s == 'kutu':
                x0 = x + pad * 0.6
                tw = gw - pad * 1.2
                d.rounded_rectangle(
                    [x0 - pad * 0.6, y - pad * 0.25, x0 + tw + pad * 0.6,
                     y + boy * 1.08], radius=boy * 0.28,
                    fill=(255, 255, 255, 255))
                d.text((x0, y - boy * 0.08), t, font=f, fill=hap_renk)
            else:
                renk = (255, 226, 138) if s == 'vurgu' else (255, 255, 255)
                # Sari vurgu turuncu zeminde silikti; golgesi koyu.
                golge_a = 150 if s == 'vurgu' else 90
                d.text((x + 3, y - boy * 0.08 + 5), t, font=f,
                       fill=(30, 10, 70, golge_a))
                d.text((x, y - boy * 0.08), t, font=f, fill=renk)
            x += gw
        y += int(boy * 1.22)
    return y


def sar(d, metin, f, sinir):
    satirlar, buf = [], ''
    for k in metin.split(' '):
        deneme = (buf + ' ' + k).strip()
        if d.textlength(deneme, font=f) > sinir and buf:
            satirlar.append(buf)
            buf = k
        else:
            buf = deneme
    if buf:
        satirlar.append(buf)
    return satirlar


def alt_satir(tuval, metin, y, boy, sinir):
    """Ortalanmis alt aciklama, en fazla iki satir."""
    d = ImageDraw.Draw(tuval)
    f = font('700', boy)
    satirlar = sar(d, metin, f, sinir)
    if len(satirlar) > 2:
        raise SystemExit(f'alt satir 2 satiri asiyor: {metin!r}')
    for s in satirlar:
        w = d.textlength(s, font=f)
        # Golgesiz alt satir acik zemin bolgelerinde kayboluyordu.
        d.text(((tuval.width - w) / 2 + 2, y + 3), s, font=f,
               fill=(30, 10, 70, 110))
        d.text(((tuval.width - w) / 2, y), s, font=f,
               fill=(255, 255, 255, 255))
        y += int(boy * 1.3)
    return y


# ------------------------------------------------------------- maskot

def maskot(tuval, boy, x, y, balon, yon):
    """Devi + balon. `yon` maskotun baktigi taraf; balon o tarafta."""
    dv = Image.open(MASKOT).convert('RGBA').resize((boy, boy), Image.LANCZOS)
    if yon == 'sol':
        dv = dv.transpose(Image.FLIP_LEFT_RIGHT)
    g = golge(dv, int(boy * 0.04), 110, (0, int(boy * 0.05)))
    tuval.alpha_composite(g, (x - int(boy * 0.08), y - int(boy * 0.08)))
    tuval.alpha_composite(dv, (x, y))
    if not balon:
        return
    d = ImageDraw.Draw(tuval)
    fb = boy * 0.13
    kenar = tuval.width * 0.03
    while True:
        f = font('800', fb)
        tw = d.textlength(balon, font=f)
        pad = int(boy * 0.07)
        bx = x + boy * 0.92 if yon == 'sag' else x + boy * 0.08 - tw - pad * 2
        if kenar <= bx and bx + tw + pad * 2 <= tuval.width - kenar:
            break
        fb -= 2
        if fb < boy * 0.08:
            raise SystemExit(f'balon sigmiyor: {balon!r}')
    by = y + int(boy * 0.18)
    d.rounded_rectangle([bx, by, bx + tw + pad * 2, by + fb + pad * 2],
                        radius=boy * 0.1, fill=(255, 255, 255, 255))
    d.text((bx + pad, by + pad - fb * 0.15), balon, font=f,
           fill=(90, 50, 200, 255))


# -------------------------------------------------------------- slayt

def slayt_ciz(w, h, ham, crop_top, ad, bas, alt, balon, tohum=3):
    """Tek gokkusagi slayti. Olcuden bagimsiz: App Store 1290x2796,
    Play 1080x1920 ayni fonksiyondan cikiyor."""
    palet, hap_renk, maskot_yer = THEME[ad]
    t = gradyan(w, h, PALET[palet])
    t.alpha_composite(semboller(w, h, tohum))

    kenar = int(w * 0.07)
    y = baslik(t, bas, int(h * 0.05), int(w * 0.085), hap_renk,
               w - 2 * kenar)
    y = alt_satir(t, alt, y + int(w * 0.012), int(w * 0.036),
                  w - 2 * kenar)

    # Maskot telefonun ust kosesinden bakiyor; balonu alt satira
    # binmesin diye telefon gerekirse asagi iniyor.
    mb = int(w * (0.30 if h / w > 2 else 0.26))
    py = max(int(h * 0.30), y + int(h * 0.015) + int(mb * 0.44))

    # Telefon alt kenardan TASIYOR. Ekranin telefonda gorunecek kismi
    # kadar kirpiliyor (+ biraz tasma); fazlasini cizmenin anlami yok.
    tel_w = int(w * TELEFON.get(ad, TELEFON_VARSAYILAN))
    cer = tel_w * 0.035
    olcek = (tel_w - 2 * cer) / ham.width
    cy = round(ham.height * crop_top)
    gorunen = (h - py + int(h * 0.04)) / olcek
    kes = ham.crop((0, cy, ham.width,
                    min(ham.height, cy + int(gorunen))))
    ph = telefon(kes, tel_w)
    px = (w - ph.width) // 2
    t.alpha_composite(golge(ph, 40, 120, (0, 50)), (px - 80, py - 80))
    t.alpha_composite(ph, (px, py))

    my = py - int(mb * 0.62)
    if maskot_yer == 'sag':
        maskot(t, mb, px + ph.width - int(mb * 0.78), my, balon, 'sol')
    else:
        maskot(t, mb, px - int(mb * 0.22), my, balon, 'sag')
    return t.convert('RGB')


def build(lang):
    src_dir = os.path.join(SRC,
                           'ekranlar' if lang == 'en' else f'ekranlar_{lang}')
    out_dir = os.path.join(SRC, f'slaytlar_{lang}')
    # Klasoru temizliyoruz: slayt sirasi degisince eski dosyalar
    # kaliyor ve magazaya artik dogru olmayan bir slayt yuklenebiliyor.
    if os.path.isdir(out_dir):
        for old in os.listdir(out_dir):
            if old.endswith('.png'):
                os.remove(os.path.join(out_dir, old))
    os.makedirs(out_dir, exist_ok=True)

    made = []
    for i, (name, crop_top, _yer, _pills, texts) in enumerate(SLIDES, 1):
        path = os.path.join(src_dir, f'{name}.png')
        if not os.path.exists(path):
            raise SystemExit(
                f'{path} yok. Once ekranlari uret:\n'
                '  flutter test --run-skipped --tags shots '
                'test/appstore_shots_test.dart')
        head, sub = texts[lang]
        ham = Image.open(path).convert('RGB')
        slide = slayt_ciz(W, H, ham, crop_top, name, head, sub,
                          BALON[name][lang], tohum=i * 7)
        out = os.path.join(out_dir, f'{i:02d}_{name}.png')
        slide.save(out)
        made.append(out)
    return made


if __name__ == '__main__':
    for lang in ['tr', 'en', 'de', 'es']:
        files = build(lang)
        print(f'{lang}: {len(files)} slayt -> {os.path.dirname(files[0])}')
