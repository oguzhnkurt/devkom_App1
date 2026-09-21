"""Sahnedeki her telefon karesini ONCEDEN uretir.

AE sablonunda telefon duz bir katman; biz de oyle yapiyoruz. Maket +
ekran goruntusu burada birlesip hazir PNG oluyor, tarayicidaki sahne
sadece o PNG'yi hareket ettiriyor.
"""
import os, sys
import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(__file__))
from mockup import Maket, hazirla

# Yollar run.sh'tan geliyor; tek basina calistirmak icin de
# makul varsayilanlar var.
ROOT = os.environ.get('ROOT', os.path.abspath(
    os.path.join(os.path.dirname(__file__), '..', '..')))
STAGE = os.environ.get('STAGE', f'{ROOT}/outputs/promo2/stage')
BASE = os.environ.get('MAKET', f'{ROOT}/outputs/promo2/maket')
SHOTS = f'{STAGE}/shots'      # 09_home, 02_lesson, ...
GAMES = f'{STAGE}/games'      # g1_chess, ...
OUT = f'{STAGE}/phones'
TMP = os.environ.get('TMPDIR', '/tmp')

# sahne -> (maket no, kaynak klasor, dosya adi)
SAHNE = [
    ('s1_home',   1, SHOTS, '09_home'),
    ('s2_lesson', 5, SHOTS, '02_lesson'),
    ('s3_blocks', 2, SHOTS, '04_blocks'),
    ('s4_html',   3, SHOTS, '14_html_code'),
    ('s5_path',   1, SHOTS, '08_path'),
]
OYUN = ['g1_chess', 'g2_millionaire', 'g3_word_match', 'g4_matching',
        'g5_bug_hunter', 'g6_coordinates', 'g7_robot', 'g8_arduino']
OYUN_MAKET = 4

_cache = {}


def maket(n):
    if n not in _cache:
        _cache[n] = Maket(f'{BASE}/Phone Mockup {n}.png',
                          f'{BASE}/Phone Mockup Placeholder {n}.png')
    return _cache[n]


def oran(m):
    q = m.quad
    en = (np.linalg.norm(q[1] - q[0]) + np.linalg.norm(q[2] - q[3])) / 2
    boy = (np.linalg.norm(q[3] - q[0]) + np.linalg.norm(q[2] - q[1])) / 2
    return en / boy


def kirp(im):
    """Saydam kenarlari atiyor — tarayicida konumlamak kolaylassin."""
    bb = im.getbbox()
    return im.crop(bb) if bb else im


def uret(ad, mno, kok, dosya, lang, hedef_yukseklik=1500):
    m = maket(mno)
    kaynak = f'{kok}/{lang}/{dosya}.png'
    tmp = f'{TMP}/_prep_{lang}_{ad}.png'
    hazirla(kaynak, oran(m)).save(tmp)
    im = kirp(m.uygula(tmp))
    if im.height > hedef_yukseklik:
        w = round(im.width * hedef_yukseklik / im.height)
        im = im.resize((w, hedef_yukseklik), Image.LANCZOS)
    p = f'{OUT}/{lang}/{ad}.png'
    im.save(p)
    os.remove(tmp)
    return p, im.size


if __name__ == '__main__':
    for lang in ('tr', 'en'):
        os.makedirs(f'{OUT}/{lang}', exist_ok=True)
        for ad, mno, kok, dosya in SAHNE:
            print(*uret(ad, mno, kok, dosya, lang))
        for g in OYUN:
            print(*uret(g, OYUN_MAKET, GAMES, g, lang, hedef_yukseklik=1200))
