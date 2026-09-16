import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../utils/lang.dart';
import '../../providers/settings_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../courses/models/course_model.dart';
import '../../providers/auth_provider.dart';

/// Kurs bitirme sertifikası (Pro).
///
/// PDF yerine PNG üretiyoruz: telefonda paylaşması kolay, ayrıca ek bir
/// PDF paketi (ve onun platform kodu) gerekmiyor. Sertifika bir widget
/// olarak çiziliyor, [RepaintBoundary] ile görüntüye alınıyor.
class CertificateScreen extends StatefulWidget {
  final Course course;
  final DateTime completedAt;

  const CertificateScreen({
    super.key,
    required this.course,
    required this.completedAt,
  });

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  final GlobalKey _boundaryKey = GlobalKey();
  bool _busy = false;

  Future<Uint8List?> _capture() async {
    try {
      final boundary = _boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;
      // 3x: paylaşıldığında ve yazdırıldığında bulanık görünmesin.
      final image = await boundary.toImage(pixelRatio: 3.0);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Sertifika görüntüsü alınamadı: $e');
      return null;
    }
  }

  Future<void> _share() async {
    if (_busy) return;
    setState(() => _busy = true);

    final bytes = await _capture();
    if (!mounted) return;

    if (bytes == null) {
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t4(context, 'Sertifika oluşturulamadı, tekrar dene.',
            'The certificate could not be created. Please try again.',
            'Das Zertifikat konnte nicht erstellt werden. Bitte versuch es erneut.',
            'No se pudo crear el certificado. Inténtalo de nuevo.'))),
      );
      return;
    }

    try {
      final dir = await getTemporaryDirectory();
      final safeName = widget.course.slug.replaceAll(RegExp(r'[^a-z0-9-]'), '');
      final file = File('${dir.path}/deveducation-sertifika-$safeName.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: '${widget.course.name} kursunu tamamladım! 🎓 · DevEducation',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_t4(context, 'Paylaşılamadı: $e',
                  'Could not share: $e', 'Teilen nicht möglich: $e',
                  'No se pudo compartir: $e'))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _formatDate(DateTime d) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final name = (user?.displayName.trim().isNotEmpty ?? false)
        ? user!.displayName
        : 'Öğrenci';

    return Scaffold(
      backgroundColor: const Color(0xFF1A1030),
      appBar: AppBar(
        title: const Text('Sertifikan'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1 / 1.414, // A4 oranı
                  child: RepaintBoundary(
                    key: _boundaryKey,
                    child: _buildCertificate(name),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _busy ? null : _share,
                icon: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.ios_share_rounded),
                label: Text(_busy ? 'Hazırlanıyor...' : 'Paylaş veya kaydet'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6C3CE0),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificate(String name) {
    final accent = widget.course.primaryColor;

    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: Stack(
        children: [
          // Üst ve alt renk şeridi
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent, widget.course.secondaryColor],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [widget.course.secondaryColor, accent],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 40, 26, 34),
            child: Column(
              children: [
                Text(
                  'DEVEDUCATION',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3.5,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Yazılım ve Robotik',
                  style: TextStyle(fontSize: 9.5, color: Colors.grey[600], letterSpacing: 1.4),
                ),
                const Spacer(flex: 2),
                Text(
                  'BAŞARI SERTİFİKASI',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.6,
                    color: Colors.grey[850],
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Bu belge',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 10),
                Container(width: 90, height: 2, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    'adlı öğrencinin aşağıdaki kursu baştan sona tamamladığını '
                    'belgelemek için düzenlenmiştir.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, height: 1.5, color: Colors.grey[700]),
                  ),
                ),
                const SizedBox(height: 20),
                Text(widget.course.icon, style: const TextStyle(fontSize: 34)),
                const SizedBox(height: 8),
                Text(
                  widget.course.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.course.totalLessons} ders · ${widget.course.difficultyText}',
                  style: TextStyle(fontSize: 10.5, color: Colors.grey[600]),
                ),
                const Spacer(flex: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 74, height: 1, color: Colors.grey.shade400),
                        const SizedBox(height: 5),
                        Text('Tarih',
                            style: TextStyle(fontSize: 8.5, color: Colors.grey[500])),
                        Text(_formatDate(widget.completedAt),
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    Icon(Icons.workspace_premium_rounded, size: 34, color: accent),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(width: 74, height: 1, color: Colors.grey.shade400),
                        const SizedBox(height: 5),
                        Text('Kurs kodu',
                            style: TextStyle(fontSize: 8.5, color: Colors.grey[500])),
                        Text(widget.course.slug.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bu ekrandaki kısa arayüz yazıları için dört dilli yardımcı.
String _t4(BuildContext context, String tr, String en, String de, String es) =>
    AppLang.pick(
      Provider.of<SettingsProvider>(context, listen: false)
          .locale
          .languageCode,
      tr: tr,
      en: en,
      de: de,
      es: es,
    );
