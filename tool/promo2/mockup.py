"""Sablonun 2B telefon maketlerine ekran goruntusu oturtur.

Sablon (App Promo) AE'de sunu yapiyor: yesil "Placeholder" katmani
ekranin tam dortgeni, "Phone Mockup" katmani ise cerceve + camin
uzerindeki parilti. Biz ayni isi burada yapip HAZIR PNG uretiyoruz;
tarayicidaki sahne sadece bu duz katmani hareket ettiriyor — AE'nin
yaptigi da bu.

Adimlar:
  1. Placeholder'daki yesil bolgeden ekranin dort kosesi bulunuyor
     (perspektifli; approxPolyDP).
  2. Ekran goruntusu o dortgene perspektif donusumle seriliyor.
  3. Placeholder'in kendi maskesi uygulaniyor — kosler YUVARLAK,
     duz dortgen degil.
  4. Maket PNG'sindeki yesil bolge saydamlastirilip cerceve ustte
     birlesiyor; yesilin parlaklik degisimi cam pariltisi olarak
     toplamali (additive) ekleniyor.
"""
import numpy as np, cv2
from PIL import Image


def _yesil(im):
    a = im[..., 3]
    r, g, b = im[..., 0].astype(int), im[..., 1].astype(int), im[..., 2].astype(int)
    return (a > 128) & (g > 90) & (g - r > 40) & (g - b > 40)


def _dortgen(mask):
    cnts, _ = cv2.findContours(mask.astype(np.uint8) * 255,
                               cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    c = max(cnts, key=cv2.contourArea)
    for eps in np.arange(0.005, 0.15, 0.002):
        ap = cv2.approxPolyDP(c, eps * cv2.arcLength(c, True), True)
        if len(ap) == 4:
            return ap.reshape(4, 2).astype(np.float32)
    raise RuntimeError('ekran dortgeni bulunamadi')


def _sirala(q):
    """Kosleri saat yonunde: sol-ust, sag-ust, sag-alt, sol-alt."""
    m = q.mean(axis=0)
    ang = np.arctan2(q[:, 1] - m[1], q[:, 0] - m[0])
    q = q[np.argsort(ang)]
    # en ustteki iki noktadan soldaki sol-ust olsun
    top = np.argsort(q[:, 1])[:2]
    su = top[np.argmin(q[top, 0])]
    return np.roll(q, -su, axis=0).astype(np.float32)


class Maket:
    def __init__(self, maket_png, placeholder_png, tasma=0.015):
        mk = np.array(Image.open(maket_png).convert('RGBA'))
        ph = np.array(Image.open(placeholder_png).convert('RGBA'))
        assert mk.shape[:2] == ph.shape[:2], 'maket ve placeholder ayni boyutta olmali'
        self.h, self.w = mk.shape[:2]

        ekran = _yesil(ph)
        q = _sirala(_dortgen(ekran))
        # Yuvarlak koseler yuzunden approxPolyDP kosleri iceri aliyor;
        # biraz disari tasirip maskeyle kesiyoruz.
        q = q + (q - q.mean(axis=0)) * tasma
        self.quad = q
        self.ekran_maske = (ekran.astype(np.float32))

        # Cerceve: maketin yesil bolgesi saydam.
        mg = _yesil(mk)
        cerceve = mk.astype(np.float32).copy()
        cerceve[..., 3] = np.where(mg, 0.0, cerceve[..., 3])
        self.cerceve = cerceve

        # Cam pariltisi: yesil bolgenin saf yesilden sapmasi.
        # Sablon orada duz yesil degil, hafif degradeli bir yesil
        # kullaniyor — o degrade camin uzerindeki isik.
        g = mk[..., 1].astype(np.float32)
        p = np.zeros((self.h, self.w), np.float32)
        if mg.any():
            v = g[mg]
            taban = np.percentile(v, 15)
            p[mg] = np.clip((g[mg] - taban) / max(1.0, 255.0 - taban), 0, 1)
        self.parilti = p * ekran  # sadece ekran icinde

    def uygula(self, ekran_png, parilti_gucu=0.22):
        src = np.array(Image.open(ekran_png).convert('RGB')).astype(np.float32)
        sh, sw = src.shape[:2]
        M = cv2.getPerspectiveTransform(
            np.float32([[0, 0], [sw, 0], [sw, sh], [0, sh]]), self.quad)
        warp = cv2.warpPerspective(src, M, (self.w, self.h),
                                   flags=cv2.INTER_LANCZOS4,
                                   borderMode=cv2.BORDER_REPLICATE)
        a = self.ekran_maske[..., None]
        out = warp * a
        out += self.parilti[..., None] * 255.0 * parilti_gucu * a
        alpha = self.ekran_maske * 255.0

        # Cerceveyi ustte birlestir.
        ca = self.cerceve[..., 3:4] / 255.0
        rgb = self.cerceve[..., :3] * ca + out * (1 - ca)
        al = np.clip(self.cerceve[..., 3] + alpha * (1 - ca[..., 0]), 0, 255)
        res = np.dstack([np.clip(rgb, 0, 255), al]).astype(np.uint8)
        return Image.fromarray(res, 'RGBA')


def hazirla(yol, oran, ust_bant=150, alt_kirp=100):
    """Ekran goruntusunu makete girmeden once duzeltir.

    UST BANT: widget testinden gelen goruntude guvenli alan boslugu
    yok, icerik y=0'dan basliyor; maketin Dynamic Island'i ise ustu
    ortuyor. Goruntunun kendi ilk satirinin rengiyle bir bant
    ekleniyor — uygulamanin arka planinin devami gibi duruyor.

    ALT KIRPMA: yuzen sekmeli cubugun ALTINDA yarim kalmis metin
    kaliyor ("Bu derste ne ogreneceksin?" gibi). Kucultulunce cizgi
    cizgi bir seride donusuyor. O serit kirpilip arka plan rengiyle
    dolduruluyor.

    ORAN: kalan goruntu, maketin ekran dortgeninin en/boy oranina
    YANLARDAN dolguyla getiriliyor; boylece hicbir yer kirpilmiyor ve
    yazilar ezilmiyor.
    """
    import numpy as np
    from PIL import Image
    im = Image.open(yol).convert('RGB')
    a = np.array(im)
    h, w = a.shape[:2]

    if alt_kirp > 0:
        zemin = np.median(a[h - alt_kirp - 6:h - alt_kirp - 1, :40]
                          .reshape(-1, 3), axis=0).astype(np.uint8)
        a = a[:h - alt_kirp]
        a = np.vstack([a, np.tile(zemin, (alt_kirp, w, 1)).astype(np.uint8)])

    if ust_bant > 0:
        ust = np.median(a[0:3], axis=(0, 1)).astype(np.uint8)
        a = np.vstack([np.tile(ust, (ust_bant, w, 1)).astype(np.uint8), a])

    h, w = a.shape[:2]
    hedef_w = int(round(h * oran))
    if hedef_w > w:
        pad = hedef_w - w
        sol, sag = pad // 2, pad - pad // 2
        kl = np.median(a[:, :3], axis=1).astype(np.uint8)[:, None, :]
        kr = np.median(a[:, -3:], axis=1).astype(np.uint8)[:, None, :]
        a = np.hstack([np.repeat(kl, sol, axis=1), a, np.repeat(kr, sag, axis=1)])
    elif hedef_w < w:
        hedef_h = int(round(w / oran))
        pad = hedef_h - h
        zemin = np.median(a[-3:], axis=(0, 1)).astype(np.uint8)
        a = np.vstack([a, np.tile(zemin, (pad, w, 1)).astype(np.uint8)])
    return Image.fromarray(a)
