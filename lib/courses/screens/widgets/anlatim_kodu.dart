/// Anlatim metnindeki KOD satirlarini duz yazidan ayirir.
///
/// NEDEN
/// -----
/// Python, Java, C#, HTML, CSS ve Arduino derslerinin anlatim metinleri
/// ornek kodu dogrudan paragrafin icinde tasiyor:
///
///     Example:
///     print("Hello")
///     print('Hi')
///
/// Ekranda bunlar govde yazisiyla ayni yazi tipinde, ayni boyutta
/// duruyordu; cocuk hangi satirin KOD, hangisinin ACIKLAMA oldugunu
/// ayirt edemiyordu ve girintiler (Python'da anlamli!) orantili yazi
/// tipinde kayboluyordu. Ders verisine dokunmadan, kod satirlari burada
/// taniniyor ve ayri bir kod panelinde, sabit genislikli yazi tipiyle
/// ciziliyor.
///
/// KURAL PARAGRAF DUZEYINDE
/// ------------------------
/// Tek tek satirlara bakmak "elif (else if) checks other conditions:"
/// gibi aciklamalari koda cevirirdi. Bir paragraf ancak satirlarinin
/// cogu (>= %60) kod gibi gorunuyorsa kod sayiliyor; o zaman aradaki
/// `except ValueError:` ya da `greet()  # Hello!` gibi satirlar da
/// panelde kaliyor. Paragrafin basindaki "Example:" / "Örnek:" gibi
/// iki noktayla biten bir aciklama satiri panelin USTUNDE yazi olarak
/// kaliyor.
class AnlatimParcasi {
  const AnlatimParcasi(this.metin, {this.kod = false});

  final String metin;
  final bool kod;
}

class AnlatimKodu {
  AnlatimKodu._();

  static const _kw = r'(def|for|while|if|elif|else|with|try|except|finally|'
      r'import|from|return|class|public|private|protected|static|void|int|'
      r'float|double|bool|boolean|char|String|string|var|let|const|function|'
      r'#include|#define|using|namespace|catch|switch|case|break|continue|'
      r'foreach|do|struct|enum|interface|async|await|yield|print|lambda)\b';

  static final _guclu = <RegExp>[
    // cagri: print("Hi"), Console.WriteLine("x");
    RegExp(r'''^\s*[A-Za-z_][\w.\[\]"']*\s*\(.*\)\s*[;:{]?\s*$'''),
    RegExp('^\\s*$_kw[^.!?]*[:;{})\\]]\\s*\$'),
    RegExp(r'''^\s*(import|from|using|#include)\s+[\w.<>"]+.*$'''),
    RegExp(r'^\s*</?[a-zA-Z!][^>]*>.*$'), // html
    RegExp(r'^\s*[\w\-.#:,\[\]="* >()]+\{\s*\}?\s*$'), // blok acilisi
    RegExp(r'^\s*[}\])]+\s*[;,)]?\s*$'), // kapanislar
    RegExp(r'^\s*[\w-]+\s*:\s*[^;]+;\s*$'), // css ozelligi
    RegExp(r'''^\s*[A-Za-z_][\w.\[\]"']*(\s*,\s*[A-Za-z_]\w*)*\s*(=|\+=|-=|\*=|/=)\s*[^=].*$'''),
    RegExp(r'^\s*"[^"]*"\s*:\s*.+,?\s*$'), // sozluk girdisi
    RegExp(r'^\s*(def|class|return|if|elif|else|for|while|try|except|finally|'
        r'with|import|from|break|continue|pass)\b'
        r'(?!\s+(you|we|it|the|this|is|are|runs|means)\b).*$'),
    RegExp(r'^.*[{}].*$'),
    RegExp(r'^[^.!?]*[(=:\]][^.!?]*;\s*$'),
    RegExp(r'^\s*@?[\w%-]+(\s+[\w%-]+)*\s*\{.*$'),
    RegExp(r'^\s*[\w<>\[\].]+\s+[A-Za-z_]\w*\s*=\s*.+$'),
    RegExp(r'^\s*(int|float|double|bool|boolean|char|String|string|var|let|'
        r'const|long|byte)\s+\w+.*$'),
  ];

  static final _yorum = RegExp(r'^\s*(#|//)');
  static final _sondakiYorum =
      RegExp(r'''(?<=[\w)\]"';}:])\s+(//|#)(\s.*)?$''');
  static final _madde = RegExp(r'^[✓•✗–*🎉💡👉➡✅❌🔹📌⭐]');
  static final _numara = RegExp(r'^\d+[.)]\s');
  static final _anahtarBas = RegExp('^\\s*$_kw');

  /// null: bos satir; 'y': yorum; true/false: kod mu.
  static Object? _satir(String l) {
    final s = l.trim();
    if (s.isEmpty) return null;
    if (_madde.hasMatch(s) || _numara.hasMatch(s)) return false;
    final t = l.replaceFirst(_sondakiYorum, '');
    if (_yorum.hasMatch(t)) return 'y';
    // Nokta ile biten, kod isareti tasimayan bir cumle: duz yazi
    // ("Semantic = meaningful.").
    if (t.trimRight().endsWith('.') && !RegExp(r'[;{}()]').hasMatch(t)) {
      return false;
    }
    final kelime = t.trim().split(RegExp(r'\s+')).length;
    for (final p in _guclu) {
      if (!p.hasMatch(t)) continue;
      if (t.trimRight().endsWith(':') && !_anahtarBas.hasMatch(t)) {
        return false;
      }
      // "elif (else if) checks other conditions:" — anahtar sozcukle
      // baslayan ama cumle olan bir aciklama.
      if (t.trimRight().endsWith(':') &&
          kelime > 5 &&
          !RegExp(r'''[=<>.\[\]"']''').hasMatch(t)) {
        return false;
      }
      if (kelime > 8 && !RegExp(r'[;{}=]|^\s*<').hasMatch(t)) return false;
      return true;
    }
    return false;
  }

  /// Bir paragrafi duz yazi / kod parcalarina ayirir. Kod yoksa tek
  /// parca (paragrafin kendisi) doner.
  static List<AnlatimParcasi> ayir(String paragraf) {
    final satirlar = paragraf.split('\n');
    final dolu = satirlar.where((l) => l.trim().isNotEmpty).toList();
    if (dolu.isEmpty) return [AnlatimParcasi(paragraf)];
    final bayrak = dolu.map(_satir).toList();

    var bas = 0;
    if (dolu.length > 1 &&
        bayrak[0] == false &&
        dolu[0].trimRight().endsWith(':')) {
      bas = 1;
    }
    final govde = bayrak.sublist(bas);
    if (govde.isEmpty) return [AnlatimParcasi(paragraf)];
    final kod = govde.where((f) => f == true).length;
    final yorum = govde.where((f) => f == 'y').length;
    final hepsiUzun = dolu
        .sublist(bas)
        .every((l) => l.trim().split(RegExp(r'\s+')).length > 9);
    if (kod < 1 || (kod + yorum) / govde.length < 0.6 || hepsiUzun) {
      return [AnlatimParcasi(paragraf)];
    }
    final kodMetni = dolu.sublist(bas).join('\n');
    return [
      if (bas == 1) AnlatimParcasi(dolu[0].trim()),
      AnlatimParcasi(kodMetni, kod: true),
    ];
  }

  /// Kod panelinin basligindaki dil etiketi.
  static String? dil(String courseId) {
    final id = courseId.toLowerCase();
    if (id.startsWith('python')) return 'python';
    if (id.startsWith('java')) return 'java';
    if (id.startsWith('csharp')) return 'c#';
    if (id.startsWith('html')) return 'html';
    if (id.startsWith('css')) return 'css';
    if (id.startsWith('arduino')) return 'arduino';
    return null;
  }
}
