"""'Bloklardan gercek koda' videosunun sesi — sifirdan sentez, telifsiz.

Bu surumun kurgusu ritmik: acilista uc blok yerine oturuyor, sonra koda
donusuyor, sonda sekiz oyun karti esit araliklarla geciyor. Ses de ayni
izgaraya oturuyor.

Ne var:
  * her blok otururken tahta bir "snap"
  * donusumde yukari suzulen tonal bir glide ve her kod satirinda
    yumusak bir tus sesi
  * telefon sahnelerinde sahne basina tek bir malet notasi
  * oyun montajinda 80 BPM'lik hafif bir vurus izgarasi (kart basina
    bir vurus) — goruntudeki kesmelerle AYNI anda
  * kapanista sicak cinlama ve uc parilti
  * altta surekli, cok kisik bir akor

GURULTU: acilista genis bantli hicbir sey yok. Onceki surumde
suzulmus gurultuden bir "bloom" vardi ve "ruzgar sesi gibi, itici"
bulundu. Buradaki tek gurultu, oyun izgarasindaki cok kisa ve kisik
hi-hat.

Zamanlamalar render.html'deki sabitlerle AYNI olmali.
"""
import sys
import numpy as np
from scipy.signal import butter, sosfilt

SR = 48000
BLOK, MORPH, PHONE, GAMES, OUTRO = 2.4, 2.2, 3.0, 6.0, 4.0
PHONE_N, GAME_N = 3, 8
T_BLOK = 0.0
T_MORPH = BLOK                                  # 2.4
T_PHONE = T_MORPH + MORPH                       # 4.6
T_GAMES = T_PHONE + PHONE_N * PHONE             # 13.6
T_OUT = T_GAMES + GAMES                         # 19.6
DURATION = T_OUT + OUTRO                        # 23.6


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


def highpass(x, hz, order=4):
    return sosfilt(butter(order, hz / (SR / 2), btype='high', output='sos'), x)


def bandpass(x, lo, hi, order=4):
    return sosfilt(butter(order, [lo / (SR / 2), hi / (SR / 2)],
                          btype='band', output='sos'), x)


def snap(rng, f=210.0):
    """Blok yerine otururken: tahta bir vurus. Kisa, odun tinili."""
    n = int(0.26 * SR)
    t = np.arange(n) / SR
    gov = np.sin(2 * np.pi * f * t) * np.exp(-t * 26)
    gov += 0.45 * np.sin(2 * np.pi * f * 2.76 * t) * np.exp(-t * 46)
    gov += 0.22 * np.sin(2 * np.pi * f * 5.4 * t) * np.exp(-t * 70)
    tik = bandpass(rng.standard_normal(n), 2200, 7000) * np.exp(-t * 260)
    return gov * 0.9 + tik * 0.30


def tus(rng):
    """Kod satiri belirirken yumusak bir tus — eski daktilo tikindan
    daha yuvarlak, daha kisik."""
    n = int(0.09 * SR)
    t = np.arange(n) / SR
    g = np.sin(2 * np.pi * 330.0 * t) * np.exp(-t * 90)
    h = bandpass(rng.standard_normal(n), 1400, 4200) * np.exp(-t * 200)
    return g * 0.7 + h * 0.35


def glide(f0=180.0, f1=720.0, dur=1.0):
    """Donusum: asagidan yukari kayan tonal bir suzulme. Gurultu yok."""
    n = int(dur * SR)
    t = np.arange(n) / SR
    f = f0 * (f1 / f0) ** (t / dur)
    faz = 2 * np.pi * np.cumsum(f) / SR
    zarf = np.sin(np.pi * (t / dur)) ** 1.4
    return (np.sin(faz) + 0.3 * np.sin(2 * faz)) * zarf


def malet(f, dur=1.4):
    """Sahne gecisi: tek, yumusak bir malet notasi."""
    n = int(dur * SR)
    t = np.arange(n) / SR
    out = np.zeros(n)
    for c, g, d in ((1.0, 1.0, 3.0), (2.0, 0.28, 4.6), (3.01, 0.12, 6.4)):
        out += np.sin(2 * np.pi * f * c * t) * np.exp(-t * d) * g
    return out


def vurus():
    """Oyun izgarasinin vurusu: kisa, alcak, yumusak bir kick."""
    n = int(0.22 * SR)
    t = np.arange(n) / SR
    f = 118 * np.exp(-t * 34) + 48
    faz = 2 * np.pi * np.cumsum(f) / SR
    return np.sin(faz) * np.exp(-t * 15)


def hat(rng):
    """Cok kisa, cok kisik bir hi-hat — izgaranin arasini doldurur."""
    n = int(0.05 * SR)
    t = np.arange(n) / SR
    return highpass(rng.standard_normal(n), 7000) * np.exp(-t * 300)


def cinlama():
    """Kapanis: sicak, dort notali, uzun kuyruklu."""
    n = int(2.8 * SR)
    out = np.zeros(n)
    for f, g, d, off in ((392.00, 0.55, 1.4, 0.00), (587.33, 0.42, 1.6, 0.11),
                         (783.99, 0.28, 2.0, 0.22), (1174.66, 0.13, 2.5, 0.33)):
        k = int(off * SR)
        tt = np.arange(n - k) / SR
        out[k:] += np.sin(2 * np.pi * f * tt) * np.exp(-tt * d) * g
    return out


def parilti(rng):
    n = int(0.3 * SR)
    t = np.arange(n) / SR
    f = rng.choice([1318.5, 1568.0, 1760.0, 2093.0])
    return np.sin(2 * np.pi * f * t) * np.exp(-t * 16)


def akor():
    """Altta surekli duran cok kisik doku."""
    n = int(DURATION * SR)
    t = np.arange(n) / SR
    out = np.zeros(n)
    for f, g in ((55.0, 1.0), (82.4, 0.5), (110.0, 0.34),
                 (164.8, 0.15), (220.0, 0.07)):
        out += np.sin(2 * np.pi * f * t + np.sin(2 * np.pi * 0.05 * t) * 0.7) * g
    nefes = 1 + 0.15 * np.sin(2 * np.pi * t / (PHONE * 2) - np.pi / 2)
    ac = np.clip(t / 1.4, 0, 1)
    kapa = np.clip((DURATION - t) / 2.2, 0, 1)
    return lowpass(out * nefes * ac * kapa, 220)


def build(lang):
    rng = np.random.default_rng(23)
    out = buf()

    # --- acilis: uc blok yerine oturuyor (render.html ile ayni anlar)
    for i, at in enumerate((0.12, 0.52, 0.92)):
        add(out, T_BLOK + at + 0.30, snap(rng, 232 - i * 26), 0.42 - i * 0.04)

    # --- donusum: yukari suzulme + her kod satirinda bir tus
    add(out, T_MORPH + 0.18, glide(170, 760, 1.05), 0.16)
    for i in range(3):
        add(out, T_MORPH + 0.62 + i * 0.29, tus(rng), 0.26)
    add(out, T_MORPH + 1.62, malet(880.0, 1.6), 0.18)

    # --- telefon sahneleri: sahne basina tek malet notasi
    for i, f in enumerate((523.25, 659.25, 783.99)[:PHONE_N]):
        add(out, T_PHONE + i * PHONE - 0.10, malet(f, 1.8), 0.20)

    # --- oyun montaji: kart basina bir vurus, arada hat
    adim = GAMES / GAME_N                 # 0.75 s -> 80 BPM
    for k in range(GAME_N):
        at = T_GAMES + k * adim
        add(out, at, vurus(), 0.34)
        add(out, at, parilti(rng), 0.07)
        add(out, at + adim / 2, hat(rng), 0.05)

    # --- kapanis
    add(out, T_OUT - 0.18, glide(520, 190, 0.5), 0.10)
    add(out, T_OUT + 0.70, cinlama(), 0.30)
    for k, off in enumerate((1.40, 1.58, 1.78)):
        add(out, T_OUT + off, parilti(rng), 0.10 - k * 0.02)

    d = akor()
    out[:len(d)] += d * 0.055

    out = out[:int(DURATION * SR)]
    peak = np.max(np.abs(out))
    if peak > 0:
        out *= 0.89 / peak
    tail = int(0.15 * SR)
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
        w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes(pcm.tobytes())
    print(path, f'{len(mono)/SR:.2f} s')
