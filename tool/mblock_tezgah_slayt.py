#!/usr/bin/env python3
"""mBlock tezgahi ekran goruntusunu tamamlar.

    python3 tool/mblock_tezgah_slayt.py

NEDEN AYRI BIR ARAC
-------------------
Tezgah bir WebView (scratch-blocks). `test/appstore_shots_test.dart`
dersin geri kalanini gercek Flutter motoruyla ciziyor ama Flutter'in
test motoru WebView cizemiyor: tezgahin yeri BOS kaliyor. Test o bos
alanin ekrandaki dikdortgenini yanina yaziyor:

    outputs/appstore/<ekranlar...>/27_mblock_tezgah.json

Bu arac ayni sayfayi (assets/mblock/index.html) gercek bir Chromium'da,
ayni olcu, ayni olcek ve ayni dilde aciyor; tahtaya ayni yarim
programi koyuyor (test "Kontrol et" dugmesini bu programa gore
acik ciziyor) ve cikan goruntuyu o dikdortgene yerlestiriyor.

Yani slayttaki her piksel uygulamanin kendi kodundan geliyor: Flutter
kismi Flutter'dan, tezgah kismi tezgahin kendi sayfasindan.

GEREKEN: pip install playwright  +  playwright install chromium
(ya da PLAYWRIGHT_BROWSERS_PATH ile hazir bir Chromium).
"""

import asyncio
import json
import os
import sys

from PIL import Image

KOK = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SAYFA = os.path.join(KOK, 'assets', 'mblock', 'index.html')
KLASORLER = ['ekranlar', 'ekranlar_tr', 'ekranlar_de', 'ekranlar_es',
             'ipad', 'ipad_tr']
AD = '27_mblock_tezgah'

# Dersin tezgah ayari (lib/courses/data/mblock_proje_lessons_data.dart,
# p1_build_balik). Arac kutusu o adimdakiyle birebir ayni.
BLOKLAR = ['dev_bayrak', 'dev_yonune_don', 'dev_surekli', 'dev_git',
           'dev_sek']

# Tahtadaki YARIM program — testte "Kontrol et"i acan yiginla ayni:
# bayrak, 55 yonune don, surekli { 2 adim git }. "kenara geldiyse sek"
# henuz palette: slayt cocugun kurdugu ani gosteriyor.
YIGIN = (
    '<xml>'
    '<block type="dev_bayrak" x="0" y="10"><next>'
    '<block type="dev_yonune_don">'
    '<value name="YON"><shadow type="math_number">'
    '<field name="NUM">55</field></shadow></value>'
    '<next><block type="dev_surekli"><statement name="ICERIK">'
    '<block type="dev_git"><value name="ADIM"><shadow type="math_number">'
    '<field name="NUM">2</field></shadow></value></block>'
    '</statement></block></next></block>'
    '</next></block></xml>'
)


async def tezgahi_ciz(olcu, cikti):
    from playwright.async_api import async_playwright
    async with async_playwright() as p:
        tarayici = await p.chromium.launch()
        sayfa = await tarayici.new_page(
            viewport={'width': round(olcu['genislik']),
                      'height': round(olcu['yukseklik'])},
            device_scale_factor=olcu['oran'],
            has_touch=True,
        )
        await sayfa.goto('file://' + SAYFA)
        ayar = {'dil': olcu['dil'], 'bloklar': BLOKLAR,
                'olcek': olcu['olcek'], 'baslangic': YIGIN}
        await sayfa.evaluate('a => MBlockTezgah.kur(JSON.stringify(a))', ayar)
        await sayfa.wait_for_timeout(700)
        # Bu kisa programda palet ACIK kalmali; kapanmissa slayt
        # uygulamadaki ani gostermiyor demektir.
        if not await sayfa.evaluate('() => MBlockTezgah.paletAcikMi()'):
            raise SystemExit('palet kapali cikti: slayt yaniltici olurdu')
        await sayfa.screenshot(path=cikti)
        await tarayici.close()


def yuvarlak_maske(boyut, yaricap):
    from PIL import ImageDraw
    maske = Image.new('L', boyut, 0)
    ImageDraw.Draw(maske).rounded_rectangle(
        [0, 0, boyut[0] - 1, boyut[1] - 1], radius=yaricap, fill=255)
    return maske


def main():
    yapildi = 0
    for klasor in KLASORLER:
        dizin = os.path.join(KOK, 'outputs', 'appstore', klasor)
        olcu_yolu = os.path.join(dizin, AD + '.json')
        cerceve_yolu = os.path.join(dizin, AD + '.png')
        if not (os.path.exists(olcu_yolu) and os.path.exists(cerceve_yolu)):
            continue
        olcu = json.load(open(olcu_yolu))
        gecici = os.path.join(dizin, AD + '_tezgah.png')
        asyncio.run(tezgahi_ciz(olcu, gecici))

        cerceve = Image.open(cerceve_yolu).convert('RGBA')
        tezgah = Image.open(gecici).convert('RGBA')
        k = olcu['oran']
        x, y = round(olcu['x'] * k), round(olcu['y'] * k)
        # Uygulamadaki tezgah kutusu yuvarlak koseli; kose olmadan
        # yapistirilirsa slaytta kare bir yama gibi duruyordu.
        maske = yuvarlak_maske(tezgah.size, round(14 * k))
        cerceve.paste(tezgah, (x, y), maske)
        cerceve.convert('RGB').save(cerceve_yolu)
        os.remove(gecici)
        print(f'{klasor}: tezgah yerlestirildi ({olcu["dil"]}, '
              f'{tezgah.size[0]}x{tezgah.size[1]})')
        yapildi += 1
    if not yapildi:
        sys.exit('27_mblock_tezgah.json bulunamadi — once ekran '
                 'goruntusu testini calistir.')


if __name__ == '__main__':
    main()
