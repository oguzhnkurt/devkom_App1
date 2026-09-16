import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme.dart';
import '../../ui/motion.dart';

/// Sirala/kur tipi etkinliklerde tasinan tek parca.
///
/// `id` sart: ayni etiketli iki parca olabiliyor ("dön", "dön") ve bunlari
/// metinle ayirt etmeye calismak surukle-birakta en sik yapilan hata —
/// parcalardan biri kayboluyor ya da ikiye cikiyor.
class SequenceToken {
  const SequenceToken({
    required this.id,
    required this.label,
    this.icon,
    this.color,
  });

  final String id;
  final String label;
  final IconData? icon;
  final Color? color;

  @override
  bool operator ==(Object other) =>
      other is SequenceToken && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Komut/kelime siralama etkinligi.
///
/// Iki etkilesim birden destekleniyor ve bu bilincli bir tercih:
///
/// * **Dokunma birincil.** Havuzdaki parcaya dokunmak onu cevap satirinin
///   sonuna ekler, cevaptaki parcaya dokunmak geri gonderir. Duolingo'nun
///   kelime bankasi da surukleme degil dokunma ile calisiyor: daha hizli ve
///   ekran okuyucuyla kullanilabilir. Yalnizca surukleme ile calisan bir
///   etkinlik TalkBack/VoiceOver kullanan bir cocuk icin tamamen kapali
///   demek.
/// * **Surukleme ek olarak.** Cevaptaki bir parcayi basili tutup baska bir
///   parcanin uzerine birakmak sirayi degistirir; havuzdaki parcayi cevaba
///   surukleyip birakmak da eklenir.
///
/// Surukleme `LongPressDraggable` ile: duz `Draggable` kaydirilabilir bir
/// listenin icinde dikey kaydirma jestini yutuyor (flutter#49770) ve cocuk
/// sayfayi kaydiramiyor.
class TokenSequenceBuilder extends StatefulWidget {
  const TokenSequenceBuilder({
    super.key,
    required this.bank,
    required this.answer,
    required this.onChanged,
    this.locked = false,
    this.emptyHint = 'Parçalara dokun ya da sürükle',
    this.correctness,
  });

  /// Henuz kullanilmamis parcalar.
  final List<SequenceToken> bank;

  /// Kullanicinin kurdugu sira.
  final List<SequenceToken> answer;

  final ValueChanged<List<SequenceToken>> onChanged;

  /// Cevap kontrol edildikten sonra true; etkilesim durur.
  final bool locked;

  final String emptyHint;

  /// Kontrol sonrasi her pozisyonun dogru olup olmadigi. Uzunlugu [answer]
  /// ile ayni olmali; null ise renklendirme yapilmaz.
  final List<bool>? correctness;

  @override
  State<TokenSequenceBuilder> createState() => _TokenSequenceBuilderState();
}

class _TokenSequenceBuilderState extends State<TokenSequenceBuilder> {
  static const Color _hairline = Color(0xFFDDE1E7);

  void _emit(List<SequenceToken> next) => widget.onChanged(next);

  void _place(SequenceToken token) {
    if (widget.locked) return;
    HapticFeedback.lightImpact();
    _emit([...widget.answer, token]);
  }

  void _remove(SequenceToken token) {
    if (widget.locked) return;
    HapticFeedback.lightImpact();
    _emit(widget.answer.where((t) => t.id != token.id).toList());
  }

  /// [token]'i cevapta [index] konumuna tasir. Parca zaten cevaptaysa once
  /// cikarilir; cikarilan konum hedefin solundaysa hedef bir kayar.
  void _moveTo(SequenceToken token, int index) {
    if (widget.locked) return;
    final next = [...widget.answer];
    final from = next.indexWhere((t) => t.id == token.id);
    if (from >= 0) {
      next.removeAt(from);
      if (from < index) index -= 1;
    }
    index = index.clamp(0, next.length);
    next.insert(index, token);
    HapticFeedback.selectionClick();
    _emit(next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAnswerArea(),
        const SizedBox(height: 20),
        _buildBank(),
      ],
    );
  }

  // ------------------------------------------------------------ cevap alani

  Widget _buildAnswerArea() {
    return DragTarget<SequenceToken>(
      onWillAcceptWithDetails: (_) => !widget.locked,
      onAcceptWithDetails: (d) => _moveTo(d.data, widget.answer.length),
      builder: (context, candidate, __) {
        final hot = candidate.isNotEmpty;
        return AnimatedContainer(
          duration: Motion.short3,
          curve: Motion.emphasized,
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 96),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: hot
                ? AppTheme.primaryBlue.withValues(alpha: 0.06)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hot ? AppTheme.primaryBlue : _hairline,
              width: hot ? 2 : 1.5,
            ),
          ),
          child: widget.answer.isEmpty
              ? Center(
                  child: Text(
                    widget.emptyHint,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9AA1AD),
                    ),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (int i = 0; i < widget.answer.length; i++)
                      _buildAnswerSlot(i),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildAnswerSlot(int index) {
    final token = widget.answer[index];
    final ok = widget.correctness != null && index < widget.correctness!.length
        ? widget.correctness![index]
        : null;

    final chip = _TokenChip(
      token: token,
      index: index + 1,
      state: ok == null
          ? _ChipState.placed
          : (ok ? _ChipState.correct : _ChipState.wrong),
      onTap: widget.locked ? null : () => _remove(token),
    );

    // Her yerlesmis parca ayni zamanda bir birakma hedefi: uzerine birakilan
    // parca bu konuma giriyor.
    return DragTarget<SequenceToken>(
      // NOT: burada `setState` cagirmiyoruz. `onWillAccept` hit-test
      // sirasinda calisiyor ve icinden setState cagirmak "setState called
      // during build" istisnasina yol aciyor; bosluk gostergesini
      // builder'in kendi `candidate` listesinden suruyoruz.
      onWillAcceptWithDetails: (d) => !widget.locked && d.data.id != token.id,
      onAcceptWithDetails: (d) => _moveTo(d.data, index),
      builder: (context, candidate, __) {
        final showGap = candidate.isNotEmpty;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Birakma noktasi belirsiz kalmasin: hedefin soluna gercek bir
            // bosluk aciliyor, parca oraya girecegini onceden gosteriyor.
            AnimatedContainer(
              duration: Motion.short3,
              curve: Motion.emphasized,
              width: showGap ? 10 : 0,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (widget.locked)
              chip
            else
              LongPressDraggable<SequenceToken>(
                data: token,
                maxSimultaneousDrags: 1,
                // feedback'i Material'e sarmazsak metin sari altciziliyle
                // ciziliyor ve golge olusmuyor.
                feedback: Material(
                  type: MaterialType.transparency,
                  child: Transform.rotate(
                    angle: 0.02,
                    child: Transform.scale(
                      scale: 1.05,
                      child: _TokenChip(
                        token: token,
                        index: index + 1,
                        state: _ChipState.dragging,
                      ),
                    ),
                  ),
                ),
                // Ayni boyutta soluk kopya: parca kaybolunca satirin
                // yerlesimi ziplamasin.
                childWhenDragging: Opacity(opacity: 0.3, child: chip),
                child: chip,
              ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------------ havuz

  Widget _buildBank() {
    if (widget.bank.isEmpty) {
      return const SizedBox(height: 4);
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final token in widget.bank)
          widget.locked
              ? _TokenChip(token: token, state: _ChipState.bank)
              : LongPressDraggable<SequenceToken>(
                  data: token,
                  maxSimultaneousDrags: 1,
                  feedback: Material(
                    type: MaterialType.transparency,
                    child: Transform.scale(
                      scale: 1.05,
                      child: _TokenChip(
                          token: token, state: _ChipState.dragging),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: _TokenChip(token: token, state: _ChipState.bank),
                  ),
                  child: _TokenChip(
                    token: token,
                    state: _ChipState.bank,
                    onTap: () => _place(token),
                  ),
                ),
      ],
    );
  }
}

enum _ChipState { bank, placed, dragging, correct, wrong }

class _TokenChip extends StatelessWidget {
  const _TokenChip({
    required this.token,
    required this.state,
    this.index,
    this.onTap,
  });

  final SequenceToken token;
  final _ChipState state;

  /// Cevaptaki sira numarasi. Siralama etkinliginde "kacinci adim" bilgisi
  /// olmadan cocuk kendi cevabini okuyamiyor.
  final int? index;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = token.color ?? AppTheme.primaryBlue;

    late final Color bg;
    late final Color border;
    late final Color ink;
    switch (state) {
      case _ChipState.bank:
        bg = Colors.white;
        border = const Color(0xFFDDE1E7);
        ink = const Color(0xFF14161A);
        break;
      case _ChipState.placed:
      case _ChipState.dragging:
        bg = accent.withValues(alpha: 0.10);
        border = accent;
        ink = accent;
        break;
      case _ChipState.correct:
        bg = const Color(0xFFE8F6E9);
        border = const Color(0xFF2E7D32);
        ink = const Color(0xFF2E7D32);
        break;
      case _ChipState.wrong:
        bg = const Color(0xFFFDECEC);
        border = const Color(0xFFC62828);
        ink = const Color(0xFFC62828);
        break;
    }

    return GestureDetector(
      // Dokunma hedefi Draggable'in kendisinde degil burada; ic ice InkWell
      // koymak webde istisna firlatiyor (flutter#69774).
      onTap: onTap,
      child: AnimatedContainer(
        duration: Motion.short3,
        curve: Motion.emphasized,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 1.6),
          boxShadow: state == _ChipState.dragging
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (index != null) ...[
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ink.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$index',
                  style: AppTheme.number(
                      fontSize: 11, color: ink, letterSpacing: 0),
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (token.icon != null) ...[
              Icon(token.icon, size: 17, color: ink),
              const SizedBox(width: 6),
            ],
            Text(
              token.label,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: ink,
              ),
            ),
            if (state == _ChipState.correct) ...[
              const SizedBox(width: 6),
              Icon(Icons.check_rounded, size: 16, color: ink),
            ],
            if (state == _ChipState.wrong) ...[
              const SizedBox(width: 6),
              Icon(Icons.close_rounded, size: 16, color: ink),
            ],
          ],
        ),
      ),
    );
  }
}
