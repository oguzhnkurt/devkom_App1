# DevEducation arayüz çevirisi — talimat

Uygulama: 7–14 yaş çocuklara kodlama öğreten mobil uygulama (Scratch, mBlock,
Arduino, Python, HTML/CSS, Java, C#). Velilere hitap eden ekranlar da var
(abonelik, ebeveyn kapısı, ilerleme raporu).

Kaynak: `/home/claude/repo/assets/l10n/_kaynak.json` — İngilizce metinlerin
JSON dizisi (~1200 metin).

Çıktı: `/home/claude/repo/assets/l10n/<kod>.json` — TEK bir JSON nesnesi:
`{"<İngilizce kaynak, birebir>": "<çeviri>", ...}`. Kaynaktaki HER metin
anahtar olarak bulunmalı; anahtarlar kaynakla karakteri karakterine aynı
(boşluk, noktalama, emoji, satır sonu dahil). Anahtarları elle yeniden
yazma: betikte kaynak listesini okuyup sırayla çevirileri eşle.

Kurallar:
1. Yer tutucuları `{0}`, `{1}`, … aynen koru (adet aynı); dilin doğal
   sırasına göre yerlerini değiştirebilirsin.
2. Çevirme (aynen bırak): DevEducation, Devi, Devkom, Pro, Scratch, mBlock,
   Arduino, Uno, Python, HTML, CSS, Java, C#, JavaScript, LED, USB, RGB,
   kod/fonksiyon adları (`digitalWrite`, `pinMode`, `print`, `if`, `for`,
   `setup`, `loop`, HTML etiketleri), dosya uzantıları, ₺/$/€ işaretleri.
3. Kısa, doğal arayüz dili; çocuğa samimi ("sen"/informal) hitap, sıcak ve
   sade. Düğme metinleri kısa kalsın.
4. Satın alma/abonelik/yasal metinlerde anlamı birebir koru (süre, fiyat
   yer tutucusu, otomatik yenileme, iptal); abartı ekleme.
5. Emoji ve satır sonlarını koru.
6. Tek kelimelik belirsiz metinler uygulama bağlamında: "Run" = kodu
   çalıştır, "Level" = seviye, "Coins" = oyun içi jeton.
7. Çeviremeyeceğin teknik bir terim varsa İngilizcesini bırak.

Yöntem: Python ile yaz. Kaynağı oku (`json.load`), çevirileri kaynakla
AYNI SIRADA bir Python listesine yaz (parça parça, ör. 150'şer), sonunda
`dict(zip(kaynak, ceviriler))` ile eşleyip `json.dump(..., ensure_ascii=False,
indent=0)` ile kaydet. Liste uzunluğu kaynakla eşit olmalı (assert).
Bitince doğrula:
`python3 /home/claude/repo/tool/ceviri_dogrula.py <kod>` → "OK" görmelisin
(eksik=0 bos=0 yer_tutucu=0). Hata varsa düzelt.
