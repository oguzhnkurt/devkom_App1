#!/usr/bin/env python3
"""App Store slaytlarini kurar.

    python3 tool/store_slides.py

Girdi : outputs/appstore/ekranlar{,_tr,_de,_es}/*.png
        (test/appstore_shots_test.dart uretiyor — gercek Flutter
        motoruyla cizilmis GERCEK ekranlar, elde yapilmis taklit degil)
Cikti : outputs/appstore/slaytlar_<dil>/NN_*.png  — 1290x2796

TASARIM
-------
Bes slayt, birbirine bagli: *bloklarla baslar -> gercek Arduino'yu
programlar -> oyunla pekistirir -> gercek kodu okur -> devam etmek
ister.*

Her slaytta:

  - Yumusak renkli zemin + arkada buyuk bulanik bir isik lekesi.
    Duz gri zemin uzerine acik temali ekran koyunca slayt magazada
    silinip gidiyordu.
  - Basligin BIR KELIMESI vurgulu: ya renkli kutu icinde beyaz yazi
    ya renkli yazi. Goz once o kelimeye takiliyor.
  - Telefon DUZ duruyor ve alt kenardan tasiyor. (Bir denemede egik
    ve perspektifliydi; ekrandaki yazi da egilince okunmuyordu.)
  - Ekranin bir parcasi telefonun DISINA buyutulmus kart olarak
    tasiniyor. Kucuk ekranda gozden kacan detay — bir blok, bir
    aciklama kutusu — slaytta okunur boyutta oluyor.
  - Baslik kimi slaytta ustte kimi altta; bes slayt yan yana
    duracak, hepsi ayni kaliba oturursa liste tekduze goruntu
    veriyor.

ROZET VE PUAN YOK — BILEREK
---------------------------
Ornek alinan tasarimlarda "1M+ Learner", "JOIN 150,000+ PEOPLES",
"#1 THERAPY EXPERIENCE" ve yildizlar var. Bizde YOK ve konulmayacak:
hicbiri dogrulanabilir degil. Puanlar gercek deneyimden birikir;
slaytta uydurulmaz (App Store Kural 2.3.1). Gercek bir sayi ya da
odul olunca eklenir.

Basliklari degistirmek icin tek yer: asagidaki SLIDES listesi.
"""

import os
from PIL import Image, ImageDraw, ImageFilter, ImageFont

W, H = 1290, 2796
INK = (20, 33, 61)
INK_SOFT = (104, 118, 145)

FONT_DIR = 'assets/fonts'
SRC = 'outputs/appstore'

# Ilk slayttaki kurs rozetleri. Hepsi uygulamada gercekten VAR OLAN
# kurslar — katalogda karsiligi olmayan bir dil buraya yazilmaz
# (test/appstore_slides_test.dart kontrol ediyor).
PILLS = [
    ('Scratch', (255, 140, 26)),
    ('Python', (55, 118, 171)),
    ('mBlock', (124, 77, 255)),
    ('Arduino', (0, 151, 157)),
    ('HTML', (227, 79, 38)),
    ('C#', (149, 66, 244)),
]

# Slayt basina renk: (zemin, isik lekesi, vurgu)
THEME = {
    '09_home': ((238, 242, 255), (188, 205, 255), (37, 84, 214)),
    '10_splash': ((243, 238, 255), (211, 196, 255), (108, 60, 224)),
    '11_word_match': ((235, 247, 241), (177, 232, 208), (13, 145, 106)),
    '02_lesson': ((255, 247, 234), (255, 220, 178), (214, 122, 20)),
    '08_path': ((232, 246, 252), (176, 225, 243), (11, 124, 166)),
    '04_blocks': ((247, 238, 255), (219, 197, 255), (122, 63, 214)),
    '07_matching': ((235, 247, 241), (177, 232, 208), (13, 145, 106)),
    '06_hint': ((233, 244, 255), (176, 216, 255), (18, 104, 196)),
    '03_character': ((247, 238, 255), (219, 197, 255), (122, 63, 214)),
    # Satranc tahtasinin kendi krem/kahve rengi; slaytin zemini de
    # ona uyuyor.
    '12_chess': ((248, 241, 231), (228, 203, 171), (140, 90, 48)),
    '13_slide_to_start': ((246, 243, 255), (214, 199, 255), (108, 60, 224)),
}

# TELEFONUN DISINA TASAN BUYUTULMUS KART YOK.
#
# Bir surumde ekranin bir parcasi buyutulup slaytin kenarindan
# sarkitiliyordu. Iki sorunu vardi: ekranda zaten gorunen seyi
# tekrar gosteriyordu ve telefonun icerigini kapatiyordu. Kaldirildi;
# slayt artik baslik + tek telefon.

# Kirpma penceresinin en-boy orani.
CROP_ASPECT = {
    '09_home': 1.95,
    '10_splash': 1.55,
    '11_word_match': 1.55,
    '02_lesson': 1.55,
    '08_path': 1.95,
    # Blok ekrani bilerek daha dar kirpiliyor: genis kirpinca
    # bloklarin yazisi slaytta okunmuyordu.
    '04_blocks': 1.52,
    '07_matching': 1.9,
    '06_hint': 1.9,
    '03_character': 1.02,
    # Tahtanin cevresine sikica kirpiliyor: genis kirpinca tahtanin
    # altinda kocaman bos bir alan kaliyordu.
    '12_chess': 1.16,
    '13_slide_to_start': 1.78,
}

# Baslik: [koseli parantez] = renkli kutu icinde beyaz yazi,
#         *yildiz*        = vurgu renginde yazi.
SLIDES = [
    # (dosya, kirpmanin BASLADIGI oran, baslik yeri, hap etiket var mi,
    #  {dil: (baslik, alt satir)})
    #
    # SIMDILIK IKI DIL: Turkiye'ye Turkce, disariya Ingilizce.
    # Almanca ve Ispanyolca metinler `docs/MAGAZA_METNI.md` icinde
    # duruyor; o iki ulke acildiginda buraya geri eklenir.
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
    ('04_blocks', 0.015, 'alt', False, {
        'tr': ('Gerçek *Arduino*’yu\nprogramlar',
               'mBlock blokları — uydurma değil, gerçek bloklar'),
        'en': ('Programs a real\n*Arduino*',
               'mBlock blocks — the real ones, not look-alikes'),
        'de': ('Programmiert einen\nechten *Arduino*',
               'mBlock-Blöcke — echte, keine Nachbauten'),
        'es': ('Programa un *Arduino*\nde verdad',
               'Bloques de mBlock — los de verdad, no imitaciones'),
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
    ('13_slide_to_start', 0.20, 'ust', False, {
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
        os.path.join(FONT_DIR, f'Nunito-{weight}.ttf'), size)


def background(base, orb, orb_at):
    bg = Image.new('RGB', (W, H), base)
    halo = Image.new('RGB', (W, H), base)
    d = ImageDraw.Draw(halo)
    cx, cy = orb_at
    r = 720
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=orb)
    halo = halo.filter(ImageFilter.GaussianBlur(200))
    return Image.blend(bg, halo, 0.75)


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


def headline(slide, text, accent, top, max_w, size=104):
    """Vurgulu baslik. Satir sonlari elle konuyor (\\n)."""
    d = ImageDraw.Draw(slide)
    f = font('800', size)
    y = top
    for satir in text.split('\n'):
        parcalar = parse(satir)
        genislik = sum(
            d.textlength(t, font=f) + (40 if s == 'kutu' else 0)
            for t, s in parcalar)
        if genislik > max_w:
            raise SystemExit(
                f'baslik satiri cok uzun ({round(genislik)} > {max_w}): '
                f'{satir!r}')
        x = 88
        for t, s in parcalar:
            tw = d.textlength(t, font=f)
            if s == 'kutu':
                d.rounded_rectangle(
                    [x, y - 6, x + tw + 40, y + size + 14], 22, fill=accent)
                d.text((x + 20, y), t, font=f, fill=(255, 255, 255))
                x += tw + 40
            elif s == 'vurgu':
                d.text((x, y), t, font=f, fill=accent)
                x += tw
            else:
                d.text((x, y), t, font=f, fill=INK)
                x += tw
        y += size + 26
    return y


def card(img, radius=34, blur=26, alpha=60, border=None):
    """Yuvarlak koseli, golgeli kart."""
    w, h = img.size
    mask = Image.new('L', (w, h), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, w - 1, h - 1], radius,
                                           fill=255)
    body = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    body.paste(img, (0, 0), mask)
    if border:
        ImageDraw.Draw(body).rounded_rectangle(
            [0, 0, w - 1, h - 1], radius, outline=border + (255,), width=6)

    pad = blur * 3
    out = Image.new('RGBA', (w + pad * 2, h + pad * 2), (0, 0, 0, 0))
    sil = Image.new('RGBA', (w, h), (20, 33, 61, alpha))
    out.paste(sil, (pad, pad + 18), body)
    out = out.filter(ImageFilter.GaussianBlur(blur))
    out.paste(body, (pad, pad), body)
    return out


def device(shot, screen_w):
    scale = screen_w / shot.width
    shot = shot.resize((screen_w, round(shot.height * scale)), Image.LANCZOS)
    bezel = max(12, round(screen_w * 0.022))
    radius_out = round(screen_w * 0.105)
    dw, dh = shot.width + bezel * 2, shot.height + bezel * 2
    dev = Image.new('RGBA', (dw, dh), (0, 0, 0, 0))
    ImageDraw.Draw(dev).rounded_rectangle(
        [0, 0, dw - 1, dh - 1], radius_out, fill=(24, 32, 46, 255))
    mask = Image.new('L', shot.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, shot.width - 1, shot.height - 1], radius_out - bezel, fill=255)
    dev.paste(shot, (bezel, bezel), mask)
    return card(dev, radius=radius_out, blur=32, alpha=74)


def chips(slide, y, accent):
    """Kurs rozetleri — hafif dagilmis, duz sutun degil."""
    d = ImageDraw.Draw(slide)
    f = font('800', 40)
    x = 88
    row = y
    for i, (label, color) in enumerate(PILLS):
        tw = d.textlength(label, font=f)
        pw, ph = round(tw) + 134, 86
        if x + pw > W - 88:
            x = 88 + (46 if (i // 3) % 2 else 0)
            row += 106
        chip = Image.new('RGBA', (pw + 90, ph + 90), (0, 0, 0, 0))
        cd = ImageDraw.Draw(chip)
        cd.rounded_rectangle([45, 45, 45 + pw, 45 + ph], ph // 2,
                             fill=(255, 255, 255, 255))
        cd.ellipse([45 + 22, 45 + 23, 45 + 62, 45 + 63], fill=color)
        cd.text((45 + 80, 45 + 20), label, font=f, fill=INK)
        chip = card(chip.crop((45, 45, 45 + pw, 45 + ph)), radius=ph // 2,
                    blur=18, alpha=42)
        slide.paste(chip, (x - 54, row - 54), chip)
        x += pw + 26
    return row + 118


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
    for i, (name, crop_top, yer, pills, texts) in enumerate(SLIDES, start=1):
        path = os.path.join(src_dir, f'{name}.png')
        if not os.path.exists(path):
            raise SystemExit(
                f'{path} yok. Once ekranlari uret:\n'
                '  flutter test --run-skipped --tags shots '
                'test/appstore_shots_test.dart')

        head, sub = texts[lang]
        base, orb, accent = THEME[name]
        slide = background(base, orb,
                           (W // 2, 380 if yer == 'ust' else H - 520))
        d = ImageDraw.Draw(slide)
        max_w = W - 176
        f_sub = font('600', 38)

        ham = Image.open(path).convert('RGB')

        if yer == 'ust':
            y = headline(slide, head, accent, 150, max_w)
            y += 12
            for line in _wrap(d, sub, f_sub, max_w):
                d.text((88, y), line, font=f_sub, fill=INK_SOFT)
                y += 52
            if pills:
                y = chips(slide, y + 40, accent)
            top = y + 40
            alt_sinir = H
        else:
            # Baslik altta: once yerini olcuyoruz.
            satir = len(head.split('\n'))
            alt_yuk = satir * 130 + len(_wrap(d, sub, f_sub, max_w)) * 52 + 80
            alt_sinir = H - alt_yuk
            top = 150

        # --- telefon ---
        aspect = CROP_ASPECT[name]
        want_h = min(ham.height, round(ham.width * aspect))
        cy = min(round(ham.height * crop_top), ham.height - want_h)
        shot = ham.crop((0, cy, ham.width, cy + want_h))
        dev = device(shot, 1000)

        # 'ust' slaytta telefon ALT kenardan, 'alt' slaytta UST
        # kenardan tasiyor. Tamamini sigdirmaya calisinca kucuk
        # kaliyor ve etrafinda olu bosluk olusuyor.
        # Telefon bosluga gore buyutuluyor ama GENISLIK SINIRI var:
        # kisa ekranlarda (karakter, ilk gorev) yukseklige gore
        # buyutunce telefon slayti tasip cercevesi kayboluyordu.
        alan = alt_sinir - top
        k = min((alan + 320) / dev.height, 1250 / dev.width)
        dev = dev.resize((round(dev.width * k), round(dev.height * k)),
                         Image.LANCZOS)
        if dev.height >= alan:
            oy = top - 60 if yer == 'ust' else alt_sinir - dev.height + 60
        else:
            oy = top + (alan - dev.height) // 2
        slide.paste(dev, ((W - dev.width) // 2, oy), dev)

        # --- telefonun disina tasan detay ---
        if yer == 'alt':
            y = headline(slide, head, accent, alt_sinir + 20, max_w)
            y += 8
            for line in _wrap(d, sub, f_sub, max_w):
                d.text((88, y), line, font=f_sub, fill=INK_SOFT)
                y += 52

        out = os.path.join(out_dir, f'{i:02d}_{name}.png')
        slide.convert('RGB').save(out)
        made.append(out)
    return made


def _wrap(draw, text, fnt, max_w):
    out = []
    line = ''
    for word in text.split(' '):
        trial = word if not line else line + ' ' + word
        if draw.textlength(trial, font=fnt) <= max_w:
            line = trial
        else:
            out.append(line)
            line = word
    out.append(line)
    return out


if __name__ == '__main__':
    for lang in ['tr', 'en', 'de', 'es']:
        files = build(lang)
        print(f'{lang}: {len(files)} slayt -> {os.path.dirname(files[0])}')
