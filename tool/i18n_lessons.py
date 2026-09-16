#!/usr/bin/env python3
"""Ders içeriği çeviri hattı.

NEDEN BU ARAÇ VAR
-----------------
Ders içeriğinde 1773 Türkçe metin alanı var ve bunların yalnızca ~%23'ünün
İngilizcesi yazılmış. Geri kalanı elle bulup elle eklemek şu yüzden
çalışmıyor:

  * Alanlar 7 ayrı dosyaya, 95 dersin içine dağılmış durumda.
  * Her `content:` alanının hemen altına `contentEn:` eklemek gerekiyor;
    elle yapınca kaçırılan alan sessizce Türkçe kalıyor ve kimse fark
    etmiyor (Almanca seçen kullanıcı Türkçe ders okuyor).
  * Dart dosyalarında kaçış karakterleri (\\n, \\', $) var; elle
    kopyalarken bozuluyor.

Bu araç işi ikiye bölüyor:

    extract  →  eksik alanları TSV'ye döker (çevirmene/incelemeye gider)
    inject   →  doldurulmuş TSV'yi Dart dosyalarına geri yazar
    report   →  hangi dilde ne kadar kapsama var, tek bakışta

TSV'nin sütunları: dosya, ders, adım, alan, türkçe, çeviri
"Çeviri" sütunu boş bırakılan satırlar atlanıyor — yani iş parça parça
ilerletilebiliyor.

KULLANIM

    python3 tool/i18n_lessons.py report
    python3 tool/i18n_lessons.py extract --lang en > /tmp/eksik_en.tsv
    # ... çeviri sütunu doldurulur ...
    python3 tool/i18n_lessons.py inject --lang en --file /tmp/eksik_en.tsv

Sonra MUTLAKA:  flutter analyze && flutter test
"""
from __future__ import annotations

import argparse
import csv
import glob
import re
import sys
from pathlib import Path

# Ders veri dosyalarındaki çevrilebilir alanlar.
#
# `title` ve `subtitle` bilerek listede: ders başlıkları da çevriliyor
# (bkz. lesson_localization_test.dart, 95/95 kapsama şartı).
FIELDS = [
    "title",
    "subtitle",
    "content",
    "question",
    "explanation",
    "instruction",
    "mascotMessage",
    "tip",
    "goal",
    "description",
    "successMessage",
    "errorDescription",
    "context",
    "label",
    "text",
    "hint",
]

DATA_GLOB = "lib/courses/data/*_lessons_data.dart"

# Dart tek tırnaklı string: kaçışlı karakterlere izin veriyor, ardışık
# satırlara bölünmüş ('abc'\n  'def') hâlini de yakalıyor.
_STR = r"'(?:[^'\\\n]|\\.)*'(?:\s*\n\s*'(?:[^'\\\n]|\\.)*')*"


def _field_re(field: str) -> re.Pattern:
    """Bir alanın Türkçe değerini yakalar.

    İKİ YAZIM BİÇİMİ VAR — ikisi de yakalanmalı:

        content: 'metin',                      <- satır başında
        ChoiceOption(text: 'metin'),           <- yapıcı çağrısının içinde

    İlk sürüm yalnızca satır başındakileri arıyordu. Sonuç: ŞIK
    METİNLERİ (ChoiceOption.text) ve satır içi DropZone/DraggableItem
    etiketleri hiç sayılmadı — rapor "%100 kapsama" derken İngilizce
    seçen çocuk soruyu İngilizce, şıkları Türkçe görüyordu. 664 şıktan
    572'si bu yüzden çevrilmemişti.
    """
    return re.compile(
        r"(?P<pre>\n[ \t]*|\(|,[ \t]*)(?P<name>" + field
        + r"):[ \t]*(?P<val>" + _STR + r")"
    )


def _suffix(lang: str) -> str:
    """`contentEn`, `contentDe` ... alan adı eki."""
    return lang.capitalize()


def _iter_fields(text: str, field: str):
    for m in _field_re(field).finditer(text):
        yield m


def _has_translation(text: str, field: str, lang: str, at: int) -> bool:
    """Bu alanın KENDİ çevirisi var mı?

    DİKKAT — burada bir hata yapıldı ve 10 alan sessizce atlandı:
    ilk sürüm sabit 4000 karakterlik bir pencereye bakıyordu. Aynı
    ada sahip alanlar (`content:` gibi) birbirine yakın duruyorsa,
    A alanının penceresi B alanının `contentEn`'ini görüyor ve
    "A zaten çevrilmiş" diye karar veriyordu. Sonuç: aynı Türkçe
    metnin ikinci kopyası hiçbir zaman çevrilemiyordu.

    Pencere artık AYNI ADI TAŞIYAN BİR SONRAKİ ALANDA bitiyor.
    """
    nxt = _field_re(field).search(text, at)
    end = nxt.start() if nxt else len(text)
    # Aynı adı taşıyan alan çok uzaktaysa da sınır koyuyoruz: bir
    # yapıcı çağrısı bu kadar uzun olmuyor.
    end = min(end, at + 2500)
    tail = text[at:end]
    # Çeviri alanı da iki biçimde yazılabiliyor: satır başında ya da
    # aynı yapıcı çağrısının içinde (`, textEn: '...'`).
    return re.search(r"[\n(,]\s*" + field + _suffix(lang) + r":\s*'", tail) is not None


def _nearest_id(text: str, pos: int) -> tuple[str, str]:
    """Bu konumdan geriye doğru en yakın ders ve adım kimliği."""
    head = text[:pos]
    lesson = ""
    step = ""
    lm = None
    for lm in re.finditer(r"InteractiveLesson\(\s*id: '([^']+)'", head):
        pass
    if lm:
        lesson = lm.group(1)
    sm = None
    for sm in re.finditer(r"\n\s+id: '([^']+)'", head):
        pass
    if sm:
        step = sm.group(1)
    return lesson, step


def _unescape(dart: str) -> str:
    """Dart string literalini okunur metne çevirir."""
    parts = re.findall(r"'((?:[^'\\]|\\.)*)'", dart, re.S)
    raw = "".join(parts)
    return (
        raw.replace("\\n", "\n")
        .replace("\\'", "'")
        .replace('\\"', '"')
        .replace("\\$", "$")
        .replace("\\\\", "\\")
    )


def _escape(text: str) -> str:
    """Okunur metni Dart tek tırnaklı literale çevirir."""
    out = (
        text.replace("\\", "\\\\")
        .replace("'", "\\'")
        .replace("$", "\\$")
        .replace("\n", "\\n")
    )
    return "'" + out + "'"


def cmd_report(_args) -> int:
    langs = ["En", "De", "Es", "Ja"]
    total = 0
    have = {l: 0 for l in langs}
    per_file = {}
    for path in sorted(glob.glob(DATA_GLOB)):
        text = Path(path).read_text(encoding="utf-8")
        f_total = 0
        f_have = {l: 0 for l in langs}
        for field in FIELDS:
            for m in _iter_fields(text, field):
                # Zaten bir çeviri alanının kendisiyse sayma.
                pass
                f_total += 1
                for l in langs:
                    if _has_translation(text, field, l.lower(), m.end()):
                        f_have[l] += 1
        total += f_total
        for l in langs:
            have[l] += f_have[l]
        per_file[Path(path).name] = (f_total, dict(f_have))

    print(f"{'dosya':34} {'alan':>6}  " + "  ".join(f"{l:>6}" for l in langs))
    print("-" * 74)
    for name, (t, h) in per_file.items():
        cells = "  ".join(f"{h[l]:>6}" for l in langs)
        print(f"{name:34} {t:>6}  {cells}")
    print("-" * 74)
    cells = "  ".join(f"{have[l]:>6}" for l in langs)
    print(f"{'TOPLAM':34} {total:>6}  {cells}")
    print()
    for l in langs:
        pct = 100 * have[l] // max(total, 1)
        missing = total - have[l]
        print(f"  {l}: %{pct:<3} kapsama, {missing} alan eksik")
    return 0


def cmd_extract(args) -> int:
    lang = args.lang.lower()
    w = csv.writer(sys.stdout, delimiter="\t", lineterminator="\n")
    w.writerow(["dosya", "ders", "adim", "alan", "turkce", "ceviri"])
    n = 0
    for path in sorted(glob.glob(DATA_GLOB)):
        if args.course and args.course not in path:
            continue
        text = Path(path).read_text(encoding="utf-8")
        for field in FIELDS:
            for m in _iter_fields(text, field):
                if _has_translation(text, field, lang, m.end()):
                    continue
                lesson, step = _nearest_id(text, m.start())
                w.writerow([
                    Path(path).name,
                    lesson,
                    step,
                    field,
                    _unescape(m.group('val')),
                    "",
                ])
                n += 1
    print(f"# {n} eksik alan", file=sys.stderr)
    return 0


def cmd_inject(args) -> int:
    lang = args.lang.lower()
    suffix = _suffix(lang)
    # DİKKAT: `read_text().splitlines()` KULLANMAYIN.
    #
    # Ders metinlerinin çoğu çok satırlı (`\n` içeriyor) ve TSV bunları
    # tırnak içine alıyor. `splitlines()` o tırnaklı alanı satırlardan
    # bölüyor, DictReader de bozuk satırlar görüyor — sonuç: uzun
    # `content` alanları HİÇ yazılamıyordu, kısa olanlar yazılıyordu.
    # Hata sessizdi: araç "eşleşmedi" diyordu ama sebebi dosyanın
    # kendisiydi, Dart tarafı değil.
    with open(args.file, encoding="utf-8", newline="") as fh:
        rows = list(csv.DictReader(fh, delimiter="\t"))
    filled = [r for r in rows if (r.get("ceviri") or "").strip()]
    print(f"{len(filled)}/{len(rows)} satır dolu", file=sys.stderr)

    by_file: dict[str, list[dict]] = {}
    for r in filled:
        by_file.setdefault(r["dosya"], []).append(r)

    written = 0
    for name, items in by_file.items():
        matches = glob.glob(f"lib/courses/data/{name}")
        if not matches:
            print(f"  ! dosya yok: {name}", file=sys.stderr)
            continue
        path = Path(matches[0])
        text = path.read_text(encoding="utf-8")

        # Aynı Türkçe metin birden çok yerde geçebiliyor; her satırı
        # SIRAYLA ve yalnızca ÇEVİRİSİ OLMAYAN ilk eşleşmeye yazıyoruz.
        for r in items:
            field = r["alan"]
            target = r["turkce"]
            done = False
            for m in _iter_fields(text, field):
                if _has_translation(text, field, lang, m.end()):
                    continue
                if _unescape(m.group("val")) != target:
                    continue
                pre = m.group("pre")
                if pre.startswith("\n"):
                    # Satır başı biçimi: değerin hemen ardına virgül +
                    # yeni satır ekliyoruz, mevcut virgül peşimizden
                    # geliyor.
                    indent = pre[1:]
                    ins = f",\n{indent}{field}{suffix}: {_escape(r['ceviri'])}"
                else:
                    # Yapıcı çağrısının içi: aynı satırda kalıyoruz.
                    ins = f", {field}{suffix}: {_escape(r['ceviri'])}"
                text = text[: m.end("val")] + ins + text[m.end("val"):]
                written += 1
                done = True
                break
            if not done:
                print(f"  ! eşleşmedi: {name} {r['ders']} {field}", file=sys.stderr)

        path.write_text(text, encoding="utf-8")

    print(f"{written} alan yazıldı. Şimdi: flutter analyze && flutter test",
          file=sys.stderr)
    return 0


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)

    sub.add_parser("report", help="dil bazında kapsama tablosu")

    e = sub.add_parser("extract", help="eksik alanları TSV olarak dök")
    e.add_argument("--lang", default="en")
    e.add_argument("--course", help="yalnızca bu kursu (örn. scratch)")

    i = sub.add_parser("inject", help="doldurulmuş TSV'yi geri yaz")
    i.add_argument("--lang", default="en")
    i.add_argument("--file", required=True)

    args = p.parse_args()
    return {"report": cmd_report, "extract": cmd_extract,
            "inject": cmd_inject}[args.cmd](args)


if __name__ == "__main__":
    raise SystemExit(main())
