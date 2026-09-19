"""Tanitim videosu icin ses tasarimi — sifirdan sentezleniyor.

NEDEN SIFIRDAN: sablonun onizleme muzigi AudioJungle'dan ayri lisansli.
Lisansi olmayan bir parcayi videoya gommek telif ihlali olurdu. Buradaki
her ses numpy ile uretiliyor; telif sorunu yok.

Ne var:
  * acilistaki yazinin her harfinde bir klavye tiki
  * her ekran gecisinde bir "whoosh"
  * oyun duvarinda seyrek blipler
  * logo belirirken yumusak bir cinlama
  * altta cok kisik, yavas nefes alan bir bas dokusu

Zamanlamalar render.html'deki sabitlerle AYNI olmali.
"""
import sys
import numpy as np
from scipy.signal import butter, sosfilt

SR = 48000
# Zamanlar render.html ile AYNI olmali.
INTRO, DUR, GAMES_DUR, END_DUR = 2.8, 3.2, 4.8, 3.2
GAME_COUNT = 4                       # oyun bolumunde kac ekran donuyor
CUTS = [INTRO + i * DUR for i in range(4)]   # telefonun geldigi/dondugu anlar
GAMES_AT = INTRO + 4 * DUR                   # oyun bolumu baslangici
END_AT = GAMES_AT + GAMES_DUR                # telefon geri geliyor
DURATION = END_AT + END_DUR                  # 23.6 s
TYPE_START, TYPE_LEN = 0.25, 1.45

TEXT = {'tr': 'Bloklardan gerçek koda.', 'en': 'From blocks to real code.'}


def buf():
    return np.zeros(int(DURATION * SR) + SR, dtype=np.float64)


def add(dst, at, sig, gain=1.0):
    i = int(at * SR)
    if i < 0:
        sig, i = sig[-i:], 0
    n = min(len(sig), len(dst) - i)
    if n > 0:
        dst[i:i + n] += sig[:n] * gain


def lowpass(x, hz, order=4):
    return sosfilt(butter(order, hz / (SR / 2), btype='low', output='sos'), x)


def bandpass(x, lo, hi, order=4):
    return sosfilt(butter(order, [lo / (SR / 2), hi / (SR / 2)],
                          btype='band', output='sos'), x)


def click(rng):
    """Klavye tiki: kisa gurultu patlamasi + govde icin alcak sinus."""
    n = int(0.045 * SR)
    t = np.arange(n) / SR
    noise = bandpass(rng.standard_normal(n), 1800, 6500)
    noise *= np.exp(-t * 190)
    body = np.sin(2 * np.pi * rng.uniform(150, 210) * t) * np.exp(-t * 120)
    return (noise * 0.9 + body * 0.35) * rng.uniform(0.75, 1.0)


def whoosh(rng, dur=0.55, bright=1.0):
    """Donme sesi: suzulmus gurultu, once acilip sonra kapanan zarf."""
    n = int(dur * SR)
    t = np.linspace(0, 1, n)
    env = np.sin(np.pi * t) ** 1.6
    noise = rng.standard_normal(n)
    dark = lowpass(noise, 700)
    lit = bandpass(noise, 900, 5200 * bright)
    mix = dark * (1 - t) + lit * t          # kararandan parlaga
    return mix * env


def chime():
    """Logo cinlamasi: iki notali, yumusak."""
    n = int(1.6 * SR)
    t = np.arange(n) / SR
    out = np.zeros(n)
    for f, g, d, off in ((523.25, 0.55, 2.6, 0.00),
                         (783.99, 0.40, 3.0, 0.09),
                         (1046.50, 0.22, 3.6, 0.18)):
        k = int(off * SR)
        tt = np.arange(n - k) / SR
        out[k:] += np.sin(2 * np.pi * f * tt) * np.exp(-tt * d) * g
    return out


def blip(rng):
    """Oyun duvarinda seyrek, kisa bir ton — kart degistikce."""
    n = int(0.22 * SR)
    t = np.arange(n) / SR
    f = rng.choice([523.25, 659.25, 783.99, 880.0, 1046.5])
    tone = np.sin(2 * np.pi * f * t) * np.exp(-t * 14)
    tone += 0.3 * np.sin(2 * np.pi * f * 2 * t) * np.exp(-t * 22)
    return tone


def drone():
    """Cok kisik bas dokusu: sahne degisimlerinde hafifce nefes aliyor."""
    n = int(DURATION * SR)
    t = np.arange(n) / SR
    out = np.zeros(n)
    for f, g in ((55.0, 1.0), (82.5, 0.45), (110.0, 0.3), (164.8, 0.12)):
        out += np.sin(2 * np.pi * f * t + np.sin(2 * np.pi * 0.07 * t) * 0.6) * g
    breathe = 1 + 0.18 * np.sin(2 * np.pi * t / DUR - np.pi / 2)
    fade_in = np.clip(t / 2.2, 0, 1)
    fade_out = np.clip((DURATION - t) / 1.6, 0, 1)
    return lowpass(out * breathe * fade_in * fade_out, 240)


def build(lang):
    rng = np.random.default_rng(7)
    out = buf()
    text = TEXT[lang]

    # yazim tiklari — harf sayisi dile gore degisiyor
    letters = len(text)
    for k in range(1, letters + 1):
        if text[k - 1] == ' ':
            continue
        at = TYPE_START + TYPE_LEN * (k - 0.5) / letters
        add(out, at, click(rng), 0.30)

    # ilk ekranin gelisi ve her ekran gecisi
    for i, at in enumerate(CUTS):
        add(out, at - 0.25, whoosh(rng, 0.70 if i == 0 else 0.5, 0.9 + 0.1 * i),
            0.30 if i == 0 else 0.22)

    # oyun bolumu: telefon cekilirken bir gecis, her oyun degisiminde blip
    add(out, GAMES_AT - 0.30, whoosh(rng, 0.75, 1.1), 0.26)
    for k in range(GAME_COUNT):
        add(out, GAMES_AT + k * (GAMES_DUR / GAME_COUNT), blip(rng), 0.20)

    # kapanis + logo
    add(out, END_AT - 0.25, whoosh(rng, 0.6, 0.8), 0.22)
    add(out, END_AT + 1.05, chime(), 0.26)

    d = drone()
    out[:len(d)] += d * 0.035

    out = out[:int(DURATION * SR)]
    peak = np.max(np.abs(out))
    if peak > 0:
        out *= 0.89 / peak
    # kuyrukta tikirti olmasin
    tail = int(0.12 * SR)
    out[-tail:] *= np.linspace(1, 0, tail)
    return out


if __name__ == '__main__':
    lang = sys.argv[1] if len(sys.argv) > 1 else 'tr'
    path = sys.argv[2] if len(sys.argv) > 2 else f'sfx_{lang}.wav'
    mono = build(lang)
    stereo = np.stack([mono, mono], axis=1)
    pcm = (np.clip(stereo, -1, 1) * 32767).astype('<i2')
    import wave
    with wave.open(path, 'wb') as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm.tobytes())
    print(path, f'{len(mono)/SR:.2f} s')
