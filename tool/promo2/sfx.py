"""App Promo surumunun sesi — sifirdan sentez, telifsiz.

Bu sablonun hissi otekinden farkli: klavye tiki yok, daha sakin ve
"premium". Altta surekli bir pad, her sahne gecisinde yumusak bir
swish, oyun seridinde hafif tiklar, logoda sicak bir cinlama.

Zamanlamalar render.html'deki sabitlerle AYNI olmali.
"""
import sys
import numpy as np
from scipy.signal import butter, sosfilt

SR = 48000
INTRO, SCENE, GAMES, OUTRO = 3.0, 3.4, 5.4, 3.4
SCENE_COUNT, GAME_COUNT = 4, 8
GAMES_AT = INTRO + SCENE_COUNT * SCENE      # 16.6
OUTRO_AT = GAMES_AT + GAMES                 # 22.0
DURATION = OUTRO_AT + OUTRO                 # 25.4


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


def swish(rng, dur=0.9):
    """Sahne gecisi: karanliktan acilip tekrar kapanan suzulmus gurultu.
    Oteki videodaki 'whoosh'tan daha yavas ve daha koyu."""
    n = int(dur * SR)
    t = np.linspace(0, 1, n)
    env = np.sin(np.pi * t) ** 2.2
    noise = rng.standard_normal(n)
    dark = lowpass(noise, 520)
    lit = bandpass(noise, 700, 3200)
    return (dark * (1 - t) + lit * t) * env


def bloom(rng, dur=1.6):
    """Acilistaki yukselen doku — logo yerine otururken."""
    n = int(dur * SR)
    t = np.linspace(0, 1, n)
    noise = bandpass(rng.standard_normal(n), 300, 2600)
    env = t ** 2 * np.exp(-((t - 0.75) ** 2) / 0.10)
    tone = np.sin(2 * np.pi * 196.0 * np.arange(n) / SR) * 0.35
    return (noise * 0.8 + tone) * env


def tick(rng):
    """Oyun seridinde cok hafif bir tik."""
    n = int(0.10 * SR)
    t = np.arange(n) / SR
    f = rng.choice([1174.7, 1318.5, 1568.0, 1760.0])
    return (np.sin(2 * np.pi * f * t) * np.exp(-t * 42)
            + 0.25 * bandpass(rng.standard_normal(n), 2500, 8000) * np.exp(-t * 90))


def chime():
    """Kapanis: sicak, iki notali, uzun kuyruklu."""
    n = int(2.6 * SR)
    out = np.zeros(n)
    for f, g, d, off in ((392.00, 0.55, 1.5, 0.00),
                         (587.33, 0.42, 1.7, 0.12),
                         (783.99, 0.26, 2.1, 0.24),
                         (1174.66, 0.12, 2.6, 0.36)):
        k = int(off * SR)
        tt = np.arange(n - k) / SR
        out[k:] += np.sin(2 * np.pi * f * tt) * np.exp(-tt * d) * g
    return out


def pad():
    """Altta surekli duran koyu mavi doku. Sahne sayisina gore degil,
    yavas bir nefes olarak hareket ediyor."""
    n = int(DURATION * SR)
    t = np.arange(n) / SR
    out = np.zeros(n)
    for f, g in ((49.0, 1.0), (73.4, 0.5), (98.0, 0.34),
                 (146.8, 0.16), (196.0, 0.08)):
        out += np.sin(2 * np.pi * f * t
                      + np.sin(2 * np.pi * 0.045 * t) * 0.8) * g
    nefes = 1 + 0.16 * np.sin(2 * np.pi * t / (SCENE * 2) - np.pi / 2)
    ac = np.clip(t / 2.6, 0, 1)
    kapa = np.clip((DURATION - t) / 2.4, 0, 1)
    return lowpass(out * nefes * ac * kapa, 210)


def build(lang):
    rng = np.random.default_rng(11)
    out = buf()

    add(out, 0.15, bloom(rng), 0.30)

    for i in range(SCENE_COUNT):
        at = INTRO + i * SCENE
        add(out, at - 0.35, swish(rng, 0.9 - 0.05 * i), 0.24)

    add(out, GAMES_AT - 0.40, swish(rng, 1.0), 0.28)
    for k in range(GAME_COUNT):
        add(out, GAMES_AT + 0.25 + k * (GAMES - 0.5) / GAME_COUNT,
            tick(rng), 0.13)

    add(out, OUTRO_AT - 0.35, swish(rng, 0.8), 0.24)
    add(out, OUTRO_AT + 0.35, chime(), 0.30)

    p = pad()
    out[:len(p)] += p * 0.042

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
