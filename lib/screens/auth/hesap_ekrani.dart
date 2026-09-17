import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/learner_profile.dart';
import '../../models/user_progress_model.dart';
import '../../providers/auth_provider.dart';
import '../../theme.dart';
import '../../utils/lang.dart';
import '../parent/takip_kodu_screen.dart';
import 'ad_duzenleyici.dart';
import 'login_screen.dart';

/// HESAP — kimlik bilgileri ve hesabın kendisiyle ilgili işlemler.
///
/// NEDEN AYRI BİR EKRAN
///
/// Bunların hepsi profil ekranının içinde, alt alta duruyordu: takma ad,
/// onboarding cevapları, üyelik tarihi ve en altta kırmızı çerçeveli bir
/// "Tehlikeli Bölge" kutusu. İki sorun vardı:
///
///  * **Tehlikeli Bölge her ziyarette görünüyordu.** Profilini açan çocuk
///    her seferinde "hesabını silmek kalıcıdır" cümlesini okuyordu. Yılda
///    belki bir kez kullanılan bir işlemi her gün göstermek, hem gereksiz
///    bir korku hem de yanlışlıkla dokunma riski.
///  * Kimlikle ilgili satırlar ilerleme kartlarının arasına dağılmıştı;
///    "adımı nereden değiştiriyordum" sorusunun tek bir cevabı yoktu.
///
/// Artık profilde tek bir **Hesap** satırı var, hepsi burada.
///
/// BİLEREK BURADA OLMAYAN ŞEY: DOĞUM TARİHİ
///
/// Uygulama doğum tarihi sormuyor ve saklamıyor (bkz. learner_profile.dart
/// ve kurulum akışı). Yaş, yalnızca içeriği ayarlamak için ARALIK olarak
/// soruluyor; ebeveyn kapısındaki doğum yılı ise hiçbir yere yazılmıyor.
/// Buraya bir "doğum tarihi" alanı koymak, ihtiyaç duymadığımız bir
/// kişisel veriyi çocuktan toplamak olurdu — ICO Çocuklara Uygun Tasarım
/// Kuralları'nın 8. maddesi (veri minimizasyonu) tam olarak bunu
/// sınırlıyor. Bu yüzden ekranda yaş ARALIĞI var, doğum tarihi yok.
class HesapEkrani extends StatefulWidget {
  const HesapEkrani({super.key});

  @override
  State<HesapEkrani> createState() => _HesapEkraniState();
}

class _HesapEkraniState extends State<HesapEkrani> {
  bool _siliniyor = false;

  String get _lang => Localizations.localeOf(context).languageCode;

  String _t(String tr, String en, String de, String es) =>
      AppLang.pick(_lang, tr: tr, en: en, de: de, es: es);

  String _tarih(DateTime d) => DateFormat('d MMMM y', _lang).format(d);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FA),
      appBar: AppBar(
        title: Text(_t('Hesap', 'Account', 'Konto', 'Cuenta')),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.currentUser;
          if (user == null) {
            return Center(
              child: Text(_t('Hesap bilgisi yüklenemedi.',
                  'Account details could not load.',
                  'Kontodaten konnten nicht geladen werden.',
                  'No se pudieron cargar los datos de la cuenta.')),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              _kart(
                baslik: _t('Kimlik', 'Identity', 'Identität', 'Identidad'),
                cocuklar: [
                  _satir(
                    ikon: Icons.badge_outlined,
                    renk: AppTheme.primaryBlue,
                    baslik: _t('Takma adın', 'Your nickname', 'Dein Spitzname',
                        'Tu apodo'),
                    deger: user.displayName,
                    onTap: () => adDuzenleyiciyiAc(context, user.displayName),
                  ),
                  _ayirac(),
                  _satir(
                    ikon: auth.isAnonymous
                        ? Icons.phone_iphone_rounded
                        : Icons.mail_outline_rounded,
                    renk: AppTheme.accentTeal,
                    baslik: _t('Giriş', 'Sign-in', 'Anmeldung', 'Acceso'),
                    // ANONIM HESAP BIR EKSIKLIK DEGIL, BIR DURUM.
                    // "E-posta yok" demek yerine ilerlemenin nerede
                    // durdugunu soyluyoruz — cocugun anlayacagi sey bu.
                    deger: auth.isAnonymous
                        ? _t('Bu telefonda', 'On this phone',
                            'Auf diesem Handy', 'En este teléfono')
                        : (user.email.isEmpty ? '—' : user.email),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _kart(
                baslik: _t('Hakkımda', 'About me', 'Über mich', 'Sobre mí'),
                cocuklar: [
                  if (user.learningGoal != null) ...[
                    _satir(
                      ikon: Icons.flag_outlined,
                      renk: AppTheme.primaryBlue,
                      baslik: _t('Hedefim', 'My goal', 'Mein Ziel',
                          'Mi objetivo'),
                      deger: user.learningGoal!.labelFor(_lang),
                    ),
                    _ayirac(),
                  ],
                  if (user.skillLevel != null) ...[
                    _satir(
                      ikon: Icons.trending_up_rounded,
                      renk: AppTheme.accentTeal,
                      baslik: _t('Seviyem', 'My level', 'Mein Level',
                          'Mi nivel'),
                      deger: user.skillLevel!.labelFor(_lang),
                    ),
                    _ayirac(),
                  ],
                  if (user.ageBand != null) ...[
                    // Yas ARALIGI — dogum tarihi degil. Sinifin basindaki
                    // aciklamaya bakiniz.
                    _satir(
                      ikon: Icons.cake_outlined,
                      renk: AppTheme.warningOrange,
                      baslik: _t('Yaş aralığı', 'Age range', 'Altersgruppe',
                          'Rango de edad'),
                      deger: user.ageBand!.labelFor(_lang),
                    ),
                    _ayirac(),
                  ],
                  _satir(
                    ikon: Icons.calendar_today_outlined,
                    renk: AppTheme.mediumGray,
                    baslik: _t('Başlangıç', 'Member since', 'Dabei seit',
                        'Miembro desde'),
                    deger: _tarih(user.createdAt),
                  ),
                  if (user.lastLoginAt != null) ...[
                    _ayirac(),
                    _satir(
                      ikon: Icons.access_time_outlined,
                      renk: AppTheme.mediumGray,
                      baslik: _t('Son giriş', 'Last sign-in', 'Letzte Anmeldung',
                          'Último acceso'),
                      deger: _tarih(user.lastLoginAt!),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 18),
              _kart(
                baslik: _t('Paylaşım', 'Sharing', 'Teilen', 'Compartir'),
                cocuklar: [
                  // KOD BURADA YAZMIYOR, EKRANI ACIYOR.
                  //
                  // Kodun kendisini bu listede gostermek, omzunun
                  // uzerinden bakan herkese vermek demekti. Kendi
                  // ekraninda ise yanINDA "bu kodu sadece annene ya da
                  // babana ver" uyarisi ve takibi kaldirma dugmesi var.
                  _satir(
                    ikon: Icons.family_restroom_rounded,
                    renk: const Color(0xFF7E57C2),
                    baslik: _t(
                        'Etkinliklerimi velimle paylaş',
                        'Share my activity with a parent',
                        'Meine Aktivität mit einem Elternteil teilen',
                        'Compartir mi actividad con un familiar'),
                    deger: '',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const TakipKoduScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _tehlikeliBolge(context, auth),
            ],
          );
        },
      ),
    );
  }

  Widget _kart({required String baslik, required List<Widget> cocuklar}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            baslik.toUpperCase(),
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          ...cocuklar,
        ],
      ),
    );
  }

  Widget _ayirac() =>
      Divider(height: 1, color: Colors.grey.shade100, indent: 50);

  Widget _satir({
    required IconData ikon,
    required Color renk,
    required String baslik,
    required String deger,
    VoidCallback? onTap,
  }) {
    final govde = Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: renk.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(ikon, color: renk, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(baslik,
                style:
                    TextStyle(fontSize: 13.5, color: Colors.grey.shade700)),
          ),
          if (deger.isNotEmpty)
            Flexible(
              child: Text(
                deger,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w600),
              ),
            ),
          // OK ICIN YER HER SATIRDA AYRILIYOR.
          //
          // Once ok yalnizca dokunulabilir satirlarda ciziliyordu ve o
          // satirin degeri okun genisligi kadar SOLA kayiyordu: "Takma
          // adin" satirindaki ad, altindaki "Bu telefonda" ile ayni
          // hizada bitmiyordu. Bos bir kutu, hizayi tek basina duzeltiyor.
          SizedBox(
            width: 24,
            child: onTap == null
                ? null
                : Icon(Icons.chevron_right,
                    color: Colors.grey.shade400, size: 20),
          ),
        ],
      ),
    );

    if (onTap == null) return govde;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: govde,
    );
  }

  /// Hesabı silme. Profilden buraya taşındı: yılda bir kullanılan bir
  /// işlem, her profil ziyaretinde kırmızı bir uyarı olarak durmamalı.
  Widget _tehlikeliBolge(BuildContext context, AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Colors.red.shade400, size: 18),
              const SizedBox(width: 8),
              Text(
                _t('Tehlikeli Bölge', 'Danger Zone', 'Gefahrenzone',
                    'Zona de riesgo'),
                style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _t(
                'Hesabını silmek kalıcıdır. İlerlemen, jetonların ve '
                    'rozetlerin geri getirilemez şekilde silinir.',
                'Deleting your account is permanent. Your progress, coins and '
                    'badges are erased for good.',
                'Das Löschen deines Kontos ist endgültig. Fortschritt, Münzen '
                    'und Abzeichen werden unwiderruflich gelöscht.',
                'Eliminar tu cuenta es permanente. Tu progreso, monedas e '
                    'insignias se borran para siempre.'),
            style:
                TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _siliniyor ? null : () => _silmeyiOnayla(context, auth),
              icon: _siliniyor
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.red))
                  : const Icon(Icons.delete_forever, color: Colors.red, size: 18),
              label: Text(
                _siliniyor
                    ? _t('Siliniyor...', 'Deleting...', 'Wird gelöscht...',
                        'Eliminando...')
                    : _t('Hesabımı Sil', 'Delete My Account', 'Konto löschen',
                        'Eliminar mi cuenta'),
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _silmeyiOnayla(BuildContext context, AuthProvider auth) {
    final UserProgress? p = auth.userProgress;
    final xp = p?.totalXP ?? 0;
    final jeton = p?.jetonBalance ?? 0;
    final rozet = p?.earnedBadgeIds.length ?? 0;

    showDialog<void>(
      context: context,
      builder: (d) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(_t(
            'Hesabını silmek üzeresin',
            'You are about to delete your account',
            'Du bist dabei, dein Konto zu löschen',
            'Estás a punto de eliminar tu cuenta')),
        content: Text(_t(
            '$xp XP, $jeton jeton ve $rozet rozet dahil tüm ilerlemen kalıcı '
                'olarak silinecek. Bu işlem geri alınamaz.',
            'All your progress, including $xp XP, $jeton coins and $rozet '
                'badges, will be permanently deleted. This cannot be undone.',
            'Dein gesamter Fortschritt, einschließlich $xp XP, $jeton Münzen '
                'und $rozet Abzeichen, wird endgültig gelöscht. Das lässt '
                'sich nicht rückgängig machen.',
            'Todo tu progreso, incluidos $xp XP, $jeton monedas y $rozet '
                'insignias, se eliminará de forma permanente. Esto no se '
                'puede deshacer.')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d),
            child: Text(_t('Vazgeç', 'Cancel', 'Abbrechen', 'Cancelar')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(d);
              _sil(auth);
            },
            child: Text(
              _t('Evet, sil', 'Yes, delete', 'Ja, löschen', 'Sí, eliminar'),
              style: const TextStyle(
                  color: Colors.red, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sil(AuthProvider auth) async {
    setState(() => _siliniyor = true);
    try {
      await auth.deleteAccount();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _siliniyor = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_t('Hesap silinemedi.', 'Account could not be deleted.',
              'Konto konnte nicht gelöscht werden.',
              'No se pudo eliminar la cuenta.')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
