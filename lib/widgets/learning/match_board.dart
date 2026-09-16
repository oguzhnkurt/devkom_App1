import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../ui/motion.dart';

/// Eslesen ciftlerin renkleri.
///
/// Once eslesen kutular arasina cizgi cekiyorduk. Ekranda dort bes
/// cizgi birden olunca tahtanin ustunden gecen bir tel yumagina
/// donusuyor, kutulari ve yazilari kesiyordu — hangi kutunun hangisine
/// bagli oldugu cizgiyi gozle takip etmeyi gerektiriyordu.
///
/// Renk bunu tek bakista anlatiyor: bir cift eslesince iki kutu da AYNI
/// rengi aliyor, komsu ciftler farkli renkte. Cizgiye gerek kalmiyor.
///
/// Renk TEK BASINA isaret degil: her ciftin iki kutusunda ayni sira
/// numarasi da var. Renk korlugu olan ya da dusuk kontrastli bir
/// ekranda bakan cocuk eslesmeyi numaradan da okuyabiliyor.
const List<Color> kMatchColors = [
  Color(0xFF2E7D32), // yesil
  Color(0xFF1E88E5), // mavi
  Color(0xFFF57C00), // turuncu
  Color(0xFF7E57C2), // mor
  Color(0xFFD81B60), // pembe
  Color(0xFF00897B), // turkuaz
];

/// Eslestirilecek tek bir cift.
class MatchPair {
  const MatchPair({required this.id, required this.left, required this.right});

  final String id;

  /// Sol sutundaki metin (ornek: Ingilizce kelime).
  final String left;

  /// Sag sutundaki karsiligi.
  final String right;
}

/// Iki sutunlu eslestirme tahtasi.
///
/// ARASTIRMA NOTU — neden hem dokunma hem surukleme var:
///
/// 8-9 yas cocuklarla yapilan bir olcumde (FittsFarm, INTERACT 2019)
/// parmakla surukle-birakta hata orani %12.6, kucuk hedeflerde %20.6
/// cikmis; arastirmacilarin onerisi "sec-ve-dokun" secenegi sunmak.
/// Nielsen Norman da kucuk cocuklarda "bir hedefi belirli bir noktaya
/// hassas sekilde surukleme"yi zor buluyor. Duolingo ve Quizlet'in
/// mobil eslestirme ekranlari da dokun-dokun ile calisiyor.
///
/// Ama cocuklar surukle-birak BEKLIYOR da (Donker & Reitsma). Bu yuzden
/// ikisi de acik. Suruklemeyi guvenli hale getiren sey su iki karar:
///
///  * Suruklemek icin kucuk bir tutamaga isabet etmek gerekmiyor —
///    KUTUNUN TAMAMI suruklenebiliyor.
///  * Birakma hedefi de kutunun tamami; 32 piksellik bir yuvarlaga
///    isabet ettirmek gerekmiyor.
///
/// Yani hassasiyet gerektiren iki uc nokta da ortadan kalkiyor.
class MatchBoard extends StatefulWidget {
  const MatchBoard({
    super.key,
    required this.pairs,
    required this.rightOrder,
    this.onCorrect,
    this.onWrong,
    this.onCompleted,
    this.leftColor = const Color(0xFF7E57C2),
    this.rightColor = const Color(0xFFF57C00),
    this.enableDrag = true,
  });

  /// Tahtadaki ciftler. Sol sutun bu sirayla cizilir.
  final List<MatchPair> pairs;

  /// Sag sutunun sirasi — [pairs] icindeki id'ler. Disaridan veriliyor ki
  /// testte sira belirli olsun.
  final List<String> rightOrder;

  final void Function(MatchPair pair)? onCorrect;

  /// Yanlis eslestirme. CEZA ICIN DEGIL, sadece haber vermek icin:
  /// bu tahtada yanlisin puan bedeli yok.
  final void Function(MatchPair leftPair, MatchPair wrongRightPair)? onWrong;

  final VoidCallback? onCompleted;

  final Color leftColor;
  final Color rightColor;

  /// Surukleme kapatilabilir (cok kucuk yaslar icin).
  final bool enableDrag;

  @override
  State<MatchBoard> createState() => MatchBoardState();
}

class MatchBoardState extends State<MatchBoard>
    with SingleTickerProviderStateMixin {
  /// Eslesen ciftler, ESLESME SIRASIYLA. Sira onemli: renk ve numara
  /// buradan geliyor, yani ilk eslesen cift her zaman ilk rengi aliyor.
  final List<String> _matched = [];
  String? _selectedLeft;
  String? _wrongLeft;
  String? _wrongRight;

  String? _dragId;
  Offset? _dragPoint;
  String? _hoverId;

  final GlobalKey _boardKey = GlobalKey();
  final Map<String, GlobalKey> _leftKeys = {};
  final Map<String, GlobalKey> _rightKeys = {};

  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );

  /// Test ve ust ekran icin: kac cift eslesti.
  int get matchedCount => _matched.length;

  /// [id]'li ciftin SAG kutusunun ekran uzerindeki merkezi.
  ///
  /// Ust ekran basari efektini tam o noktada patlatiyor. Once efektin
  /// yeri, kutu yuksekligi elle 86 piksel varsayilarak hesaplaniyordu;
  /// kutu boyu degisince efekt yanlis yere cikacakti.
  Offset? rightTileCenter(String id) {
    final box =
        _rightKeys[id]?.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(box.size.center(Offset.zero));
  }

  /// [id]'li ciftin rengi — henuz eslesmediyse null.
  Color? _colorOf(String id) {
    final i = _matched.indexOf(id);
    return i < 0 ? null : kMatchColors[i % kMatchColors.length];
  }

  @override
  void initState() {
    super.initState();
    _ensureKeys();
  }

  @override
  void didUpdateWidget(MatchBoard old) {
    super.didUpdateWidget(old);
    if (old.pairs != widget.pairs) {
      _matched.clear();
      _selectedLeft = null;
      _wrongLeft = null;
      _wrongRight = null;
      _dragId = null;
      _dragPoint = null;
      _hoverId = null;
      _leftKeys.clear();
      _rightKeys.clear();
    }
    _ensureKeys();
  }

  void _ensureKeys() {
    for (final p in widget.pairs) {
      _leftKeys.putIfAbsent(p.id, GlobalKey.new);
      _rightKeys.putIfAbsent(p.id, GlobalKey.new);
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  MatchPair _pairOf(String id) => widget.pairs.firstWhere((p) => p.id == id);

  RenderBox? get _boardBox {
    final ctx = _boardKey.currentContext;
    final box = ctx?.findRenderObject() as RenderBox?;
    return (box != null && box.hasSize) ? box : null;
  }

  // --------------------------------------------------------------
  // Etkilesim
  // --------------------------------------------------------------

  void _tapLeft(String id) {
    if (_matched.contains(id)) return;
    setState(() => _selectedLeft = _selectedLeft == id ? null : id);
  }

  void _tapRight(String id) {
    if (_matched.contains(id)) return;
    final left = _selectedLeft;
    if (left == null) return;
    _resolve(left, id);
  }

  /// Sol [leftId] ile sag [rightId] eslesmesini degerlendirir.
  void _resolve(String leftId, String rightId) {
    if (leftId == rightId) {
      setState(() {
        if (!_matched.contains(leftId)) _matched.add(leftId);
        _selectedLeft = null;
        _wrongLeft = null;
        _wrongRight = null;
      });
      widget.onCorrect?.call(_pairOf(leftId));
      if (_matched.length == widget.pairs.length) {
        widget.onCompleted?.call();
      }
      return;
    }

    // YANLIS: ceza yok.
    //
    // Duolingo'nun eslestirme oyununda yanlisin bedeli yok; Quizlet'te
    // var ama o yetiskin/liderlik tablosu oyunu. Bizim yas grubumuzda
    // yanlis eslestirmelerin buyuk kismi bilgi hatasi degil PARMAK
    // hatasi (yukaridaki %12-20 rakamlari) — parmak hatasini
    // cezalandirmak ogrenmeyi caydirir.
    setState(() {
      _wrongLeft = leftId;
      _wrongRight = rightId;
      _selectedLeft = null;
    });
    if (!Motion.reduced(context)) _shake.forward(from: 0);
    widget.onWrong?.call(_pairOf(leftId), _pairOf(rightId));

    Future.delayed(const Duration(milliseconds: 480), () {
      if (!mounted) return;
      setState(() {
        _wrongLeft = null;
        _wrongRight = null;
      });
    });
  }

  String? _rightUnder(Offset globalPosition) {
    final board = _boardBox;
    if (board == null) return null;
    final local = board.globalToLocal(globalPosition);
    for (final entry in _rightKeys.entries) {
      if (_matched.contains(entry.key)) continue;
      final box = entry.value.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) continue;
      final topLeft = box.localToGlobal(Offset.zero, ancestor: board);
      if ((topLeft & box.size).contains(local)) return entry.key;
    }
    return null;
  }

  void _dragStart(String id, Offset globalPosition) {
    if (_matched.contains(id)) return;
    final board = _boardBox;
    if (board == null) return;
    setState(() {
      _dragId = id;
      _selectedLeft = id;
      _dragPoint = board.globalToLocal(globalPosition);
      _hoverId = null;
    });
  }

  void _dragUpdate(Offset globalPosition) {
    if (_dragId == null) return;
    final board = _boardBox;
    if (board == null) return;
    setState(() {
      _dragPoint = board.globalToLocal(globalPosition);
      _hoverId = _rightUnder(globalPosition);
    });
  }

  void _dragEnd() {
    final id = _dragId;
    final target = _hoverId;
    setState(() {
      _dragId = null;
      _dragPoint = null;
      _hoverId = null;
    });
    if (id == null) return;
    if (target == null) {
      // Bosluga birakmak bir deneme degil, vazgecme. Secim duruyor ki
      // cocuk isterse dokunarak tamamlasin.
      return;
    }
    _resolve(id, target);
  }

  // --------------------------------------------------------------
  // Cizim
  // --------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final rightPairs = [
      for (final id in widget.rightOrder)
        widget.pairs.firstWhere((p) => p.id == id),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProgressPips(
          total: widget.pairs.length,
          done: _matched.length,
          color: widget.leftColor,
        ),
        const SizedBox(height: 18),
        Stack(
          key: _boardKey,
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _shake,
                builder: (context, _) => CustomPaint(
                  // Burada ARTIK SADECE surukleme cizgisi var. Eslesen
                  // ciftleri birlestiren kalici cizgiler kaldirildi;
                  // yerlerini ortak renk ve ortak numara aldi.
                  // Surukleme cizgisi kaliyor cunku o gecici: parmak
                  // hareket ederken nereye gittigini gostermenin baska
                  // yolu yok.
                  painter: _DragLinePainter(
                    leftKeys: _leftKeys,
                    boardKey: _boardKey,
                    dragId: _dragId,
                    dragPoint: _dragPoint,
                    dragOnTarget: _hoverId != null,
                    dragColor: widget.leftColor,
                  ),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      for (final p in widget.pairs) _tile(p, isLeft: true),
                    ],
                  ),
                ),
                const SizedBox(width: 26),
                Expanded(
                  child: Column(
                    children: [
                      for (final p in rightPairs) _tile(p, isLeft: false),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _tile(MatchPair pair, {required bool isLeft}) {
    final id = pair.id;
    final matched = _matched.contains(id);
    final selected = isLeft && _selectedLeft == id && !matched;
    final wrong = isLeft ? _wrongLeft == id : _wrongRight == id;
    final hovered = !isLeft && _hoverId == id && !matched;

    final base = isLeft ? widget.leftColor : widget.rightColor;

    final tile = _MatchTile(
      key: isLeft ? _leftKeys[id] : _rightKeys[id],
      label: isLeft ? pair.left : pair.right,
      color: base,
      matchColor: _colorOf(id),
      matchNumber: matched ? _matched.indexOf(id) + 1 : null,
      selected: selected || hovered,
      matched: matched,
      wrong: wrong,
      shake: _shake,
      onTap: () => isLeft ? _tapLeft(id) : _tapRight(id),
    );

    if (!isLeft || !widget.enableDrag || matched) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: tile,
      );
    }

    // Yatay surukleme kullaniyoruz, pan degil: sayfa dikey kayiyor,
    // pan olsaydi iki hareket yarisir ve kaydirma bozulurdu.
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (d) => _dragStart(id, d.globalPosition),
        onHorizontalDragUpdate: (d) => _dragUpdate(d.globalPosition),
        onHorizontalDragEnd: (_) => _dragEnd(),
        onHorizontalDragCancel: _dragEnd,
        child: tile,
      ),
    );
  }
}

/// Tek kutu.
///
/// Gorsel dil Duolingo'nun tus dilinden: buyuk kose yaricapi, altta
/// KATI bir "dudak" (bulanik golge degil) ve basinca cokme. Bulanik
/// golge kutunun basilabilir oldugunu soylemiyor; kati dudak soyluyor.
class _MatchTile extends StatefulWidget {
  const _MatchTile({
    super.key,
    required this.label,
    required this.color,
    required this.matchColor,
    required this.matchNumber,
    required this.selected,
    required this.matched,
    required this.wrong,
    required this.shake,
    required this.onTap,
  });

  final String label;
  final Color color;

  /// Eslestiginde bu ciftin rengi. Iki kutuda da ayni.
  final Color? matchColor;

  /// Eslesme sira numarasi — rengin yaninda ikinci bir isaret.
  final int? matchNumber;

  final bool selected;
  final bool matched;
  final bool wrong;
  final Animation<double> shake;
  final VoidCallback onTap;

  @override
  State<_MatchTile> createState() => _MatchTileState();
}

class _MatchTileState extends State<_MatchTile> {
  bool _down = false;

  static const _green = Color(0xFF2E7D32);
  static const _amber = Color(0xFFE65100);

  @override
  Widget build(BuildContext context) {
    final matched = widget.matched;
    final wrong = widget.wrong;

    final pairColor = widget.matchColor ?? _green;

    final Color border = matched
        ? pairColor
        : wrong
            ? _amber
            : widget.selected
                ? widget.color
                : const Color(0xFFDDE1E6);
    final Color fill = matched
        ? pairColor.withValues(alpha: 0.12)
        : wrong
            ? _amber.withValues(alpha: 0.10)
            : widget.selected
                ? widget.color.withValues(alpha: 0.10)
                : Colors.white;
    // Eslesen kutunun yazisi SOLMUYOR.
    //
    // Once kutuyu %55 saydamliga cekiyorduk; yazi soluyor ve cocuk
    // bitirdigi eslesmeyi okuyamiyordu. Bitmis is silik olmak zorunda
    // degil — zaten dokunulamiyor. Rengi ciftin rengi, yazisi tam
    // koyulukta.
    final Color text = matched
        ? pairColor
        : wrong
            ? _amber
            : widget.selected
                ? widget.color
                : AppTheme.darkGray;

    // Basinca kutu 4 piksel asagi iniyor ve dudak kayboluyor.
    final pressed = _down && !matched;
    final lip = pressed ? 0.0 : 4.0;

    Widget content = AnimatedContainer(
      duration: Motion.short2,
      curve: Motion.emphasized,
      transform: Matrix4.translationValues(0, pressed ? 4 : 0, 0),
      // Kucuk cocuklarda onerilen dokunma hedefi 2cm x 2cm; 72 piksel
      // bunun telefondaki karsiligi. Iki satir metin de sigiyor —
      // Turkce terimler uzun (ornek: "tekrarlama blogu") ve tek satirlik
      // kutuda kirpilirdi.
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: border,
            width: matched || widget.selected || wrong ? 2.5 : 2),
        boxShadow: lip == 0
            ? null
            : [
                BoxShadow(
                  color: border == const Color(0xFFDDE1E6)
                      ? const Color(0xFFCDD3DA)
                      : border.withValues(alpha: 0.55),
                  offset: Offset(0, lip),
                ),
              ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: widget.label.length > 14 ? 15 : 17,
                fontWeight: FontWeight.w800,
                height: 1.2,
                color: text,
              ),
            ),
          ),
          // Rengi TEK BASINA isaret olarak kullanmiyoruz: eslesen iki
          // kutuda ayni sira numarasi da var. Renk korlugu olan ya da
          // dusuk kontrastli bir ekranda bakan cocuk eslesmeyi
          // numaradan okuyabiliyor.
          if (matched && widget.matchNumber != null) ...[
            const SizedBox(width: 8),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: pairColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${widget.matchNumber}',
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (wrong) {
      content = AnimatedBuilder(
        animation: widget.shake,
        builder: (context, child) {
          final t = widget.shake.value;
          final dx = math.sin(t * math.pi * 6) * 7 * (1 - t);
          return Transform.translate(offset: Offset(dx, 0), child: child);
        },
        child: content,
      );
    }

    return Semantics(
      button: !matched,
      label: widget.label,
      value: matched
          ? 'eşleşti'
          : widget.selected
              ? 'seçili'
              : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // Geri bildirim parmak KALKARKEN degil INERKEN: cocuklar
        // dokunuslarinin islendigini hemen gormek istiyor.
        onTapDown: matched ? null : (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: matched ? null : widget.onTap,
        child: AnimatedScale(
          scale: matched ? 1.0 : (widget.selected ? 1.02 : 1.0),
          duration: Motion.short3,
          // Eslesen kutu yerinde KALIYOR. Kaldirmak listeyi yeniden
          // diziyor ve cocugun dokunmak uzere oldugu kutu yerinden
          // oynuyor — yanlis dokunuslarin klasik kaynagi.
          child: content,
        ),
      ),
    );
  }
}

/// Ust taraftaki ilerleme noktalari.
///
/// Yuzde ya da ham puan yerine cift basina bir nokta: bu yas grubunda
/// somut ve sayilabilir olan, soyut olana gore daha iyi okunuyor.
/// Hata sayaci BILEREK yok — "3 hata" gostermek adi konmamis bir ceza.
class _ProgressPips extends StatelessWidget {
  const _ProgressPips({
    required this.total,
    required this.done,
    required this.color,
  });

  final int total;
  final int done;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < total; i++)
          AnimatedContainer(
            duration: Motion.medium2,
            curve: Motion.emphasized,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i < done ? 26 : 20,
            height: 8,
            decoration: BoxDecoration(
              color:
                  i < done ? const Color(0xFF2E7D32) : const Color(0xFFE0E4E9),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}

/// Suruklerken parmagi takip eden gecici cizgi.
///
/// Eslesen ciftleri birlestiren KALICI cizgiler kaldirildi: dort bes
/// tanesi birden tahtanin ustunden gecen bir tel yumagina donusuyor,
/// kutulari ve yazilari kesiyordu. Eslesmeyi artik ortak renk ve ortak
/// numara anlatiyor.
///
/// Buradaki cizgi baska bir sey: parmak hareket ederken nereye
/// gittigini gostermenin baska yolu yok, ve parmak kalkinca kayboluyor.
class _DragLinePainter extends CustomPainter {
  _DragLinePainter({
    required this.leftKeys,
    required this.boardKey,
    required this.dragId,
    required this.dragPoint,
    required this.dragOnTarget,
    required this.dragColor,
  });

  final Map<String, GlobalKey> leftKeys;
  final GlobalKey boardKey;
  final String? dragId;
  final Offset? dragPoint;
  final bool dragOnTarget;
  final Color dragColor;

  static const _green = Color(0xFF2E7D32);

  @override
  void paint(Canvas canvas, Size size) {
    final id = dragId;
    final point = dragPoint;
    if (id == null || point == null) return;

    final board = boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (board == null || !board.hasSize) return;

    final box = leftKeys[id]?.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    // Cizgi kutunun ortasindan degil, ortaya bakan kenarindan cikiyor.
    final a = box.localToGlobal(
      Offset(box.size.width, box.size.height / 2),
      ancestor: board,
    );

    final color = dragOnTarget ? _green : dragColor;
    final paint = Paint()
      ..color = color.withValues(alpha: dragOnTarget ? 0.95 : 0.7)
      ..strokeWidth = dragOnTarget ? 4.5 : 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (dragOnTarget) {
      canvas.drawLine(a, point, paint);
    } else {
      // Hedefin uzerinde degilken kesikli: "henuz baglanmadi".
      const dash = 10.0, gap = 6.0;
      final total = (point - a).distance;
      if (total < 1) return;
      final dir = (point - a) / total;
      var d = 0.0;
      while (d < total) {
        final e = math.min(d + dash, total);
        canvas.drawLine(a + dir * d, a + dir * e, paint);
        d = e + gap;
      }
    }
    canvas.drawCircle(a, 5, Paint()..color = color);
    canvas.drawCircle(point, dragOnTarget ? 8 : 5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_DragLinePainter old) =>
      old.dragId != dragId ||
      old.dragPoint != dragPoint ||
      old.dragOnTarget != dragOnTarget;
}
