import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

import '../../app_version.dart';
import '../dev/ad_test_screen.dart';
import '../../utils/pro_gate.dart';
import '../../providers/settings_provider.dart';
import '../../theme.dart';
import '../../utils/app_localizations.dart';
import '../../utils/lang.dart';
import '../../services/subscription_service.dart';
import '../../widgets/parent_gate.dart';
import '../parent/parent_area_screen.dart';
import '../parent/takip_kodu_screen.dart';
import '../subscription_screen.dart';

/// Ayarlar.
///
/// TASARIM NOTU
/// ------------
/// Bu ekran uzun süre uygulamanın geri kalanına benzemiyordu: koyu
/// mavi bir AppBar, gri zemin, uç uca dizilmiş düz `ListTile`'lar ve
/// aralarında ince gri çizgiler. Uygulamanın geri kalanı — özellikle
/// Pro ekranı — bulutlu, yumuşak, yuvarlak köşeli. Ayarlar bir
/// yönetim panosu gibi duruyordu.
///
/// Artık satırlar tek tek değil, konusuna göre BEYAZ KARTLAR halinde
/// gruplanıyor. `Divider` yok: kartın kendisi zaten sınır çiziyor.
///
/// ARKA PLAN NEDEN SADE
/// --------------------
/// İlk denemede Pro ekranının bulutlu, gökkuşaklı gökyüzü ([PaywallSky])
/// buraya da konmuştu. Fazla geldi: Pro ekranı tek seferlik ve ikna
/// edici olmalı, ayarlar ise okunacak bir liste — arkadaki gökkuşağı
/// kartların altından geçince metin yorucu oluyordu. Onun yerine aynı
/// paletin çok soluk hâli: üstte hafif krem, altta hafif yeşil-mavi,
/// desen yok. Sıcaklık kalıyor, gürültü gidiyor.
///
/// Dört dilde de test ediliyor (`test/settings_screen_test.dart`);
/// Almanca ve İspanyolca etiketler Türkçe/İngilizce'den uzun olduğu
/// için taşma kontrolü ekranın bir parçası, sonradan yapılan bir
/// kontrol değil.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          loc.settings.toUpperCase(),
          style: const TextStyle(
            color: AppTheme.darkBlue,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.darkBlue,
        iconTheme: const IconThemeData(color: AppTheme.darkBlue),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF8EF),
              Color(0xFFF7FAFD),
              Color(0xFFF2F8F3),
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: Consumer<SettingsProvider>(
          builder: (context, settings, _) {
            return SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  // ---- Pro -------------------------------------------
                  _group(
                    icon: Icons.star_rounded,
                    color: AppTheme.warningOrange,
                    title: 'DevEducation Pro',
                    children: [
                      FutureBuilder<Map<String, dynamic>?>(
                        future: SubscriptionService().getSubscriptionInfo(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return ListTile(
                              leading: _chip(
                                  Icons.hourglass_empty, AppTheme.mediumGray),
                              title: Text(_t(context, 'Yükleniyor...',
                                  'Loading…', 'Wird geladen…', 'Cargando…')),
                            );
                          }

                          final subscriptionInfo = snapshot.data;
                          final bool isPro =
                              subscriptionInfo?['isActive'] ?? false;

                          if (isPro) {
                            final expiryDate =
                                subscriptionInfo!['expiryDate'] as DateTime?;
                            final expiryText = expiryDate != null
                                ? '${_t(context, 'Bitiş', 'Ends', 'Endet', 'Termina')}: '
                                    '${expiryDate.day}/${expiryDate.month}/${expiryDate.year}'
                                : _t(context, 'Aktif', 'Active', 'Aktiv',
                                    'Activa');

                            return Column(
                              children: [
                                ListTile(
                                  leading: _chip(Icons.star_rounded,
                                      AppTheme.warningOrange),
                                  title: Text(
                                    _t(
                                        context,
                                        'DevEducation Pro aktif',
                                        'DevEducation Pro is active',
                                        'DevEducation Pro ist aktiv',
                                        'DevEducation Pro está activo'),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(expiryText),
                                  trailing: const Icon(Icons.check_circle,
                                      color: AppTheme.successGreen),
                                ),
                                _rowDivider(),
                                ListTile(
                                  leading: _chip(
                                      Icons.restore, AppTheme.primaryBlue),
                                  title: Text(_t(
                                      context,
                                      'Satın Almaları Geri Yükle',
                                      'Restore purchases',
                                      'Käufe wiederherstellen',
                                      'Restaurar compras')),
                                  subtitle: Text(_t(
                                      context,
                                      'Önceki satın almalarınızı geri yükleyin',
                                      'Restore your earlier purchases',
                                      'Stelle deine früheren Käufe wieder her',
                                      'Restaura tus compras anteriores')),
                                  onTap: () async {
                                    try {
                                      await SubscriptionService()
                                          .restorePurchases();
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(_t(
                                                context,
                                                'Satın almalar geri yüklendi',
                                                'Purchases restored',
                                                'Käufe wiederhergestellt',
                                                'Compras restauradas')),
                                            backgroundColor:
                                                AppTheme.successGreen,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                '${_t(context, 'Hata', 'Error', 'Fehler', 'Error')}: $e'),
                                            backgroundColor: AppTheme.errorRed,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            );
                          }

                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppTheme.accentYellow,
                                    AppTheme.warningOrange,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.auto_awesome_rounded,
                                  color: Colors.white),
                            ),
                            title: Text(
                              _t(
                                  context,
                                  'DevEducation Pro\'ya Yükselt',
                                  'Upgrade to DevEducation Pro',
                                  'Auf DevEducation Pro upgraden',
                                  'Cambia a DevEducation Pro'),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(_t(
                                context,
                                'Tüm özelliklere sınırsız erişim',
                                'Unlimited access to everything',
                                'Unbegrenzter Zugriff auf alles',
                                'Acceso ilimitado a todo')),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SubscriptionScreen(),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),

                  // ---- Ebeveyn ---------------------------------------
                  //
                  // Ebeveyn kapisinin arkasinda. Apple'in Cocuklar
                  // kategorisi kurali (1.3) satin alma, dis baglanti ve
                  // benzeri "dikkat dagitici" seylerin yetiskin
                  // seviyesinde bir gorevin arkasinda olmasini istiyor;
                  // ayni kapiyi ilerleme raporu icin de kullaniyoruz
                  // cunku bu ekran cocuga degil odemeyi yapan kisiye
                  // yazilmis.
                  _group(
                    icon: Icons.family_restroom,
                    color: AppTheme.primaryBlue,
                    title: AppLang.pick(lang,
                        tr: 'Ebeveyn',
                        en: 'Parents',
                        de: 'Eltern',
                        es: 'Familias'),
                    children: [
                      ListTile(
                        leading:
                            _chip(Icons.insights_rounded, AppTheme.primaryBlue),
                        title: Text(AppLang.pick(lang,
                            tr: 'Ebeveyn Alanı',
                            en: 'Parent Area',
                            de: 'Elternbereich',
                            es: 'Área para familias')),
                        // Takip kodundan burada soz ediyoruz: kodun
                        // kendisi kapinin arkasinda duruyor ama ozelligin
                        // VARLIGINI bilmeyen bir ebeveyn o kapiyi hic
                        // acmiyor.
                        subtitle: Text(AppLang.pick(lang,
                            tr: 'İlerleme, haftalık hedef, sertifikalar — '
                                'kendi telefonunuzdan da takip edin',
                            en: 'Progress, weekly goal, certificates — '
                                'follow from your own phone too',
                            de: 'Fortschritt, Wochenziel, Zertifikate — '
                                'auch vom eigenen Telefon aus',
                            es: 'Progreso, meta semanal, certificados — '
                                'también desde tu propio móvil')),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () async {
                          final ok = await ParentGate.verify(
                            context,
                            lang: lang,
                            reason: AppLang.pick(lang,
                                tr: 'Bu bölümde çocuğunuzun ilerlemesi ve '
                                    'haftalık hedefi var. Devam etmek için '
                                    'doğum yılınızı girin.',
                                en: "This section shows your child's "
                                    'progress and weekly goal. Enter your '
                                    'year of birth to continue.',
                                de: 'Hier siehst du Fortschritt und '
                                    'Wochenziel deines Kindes. Gib dein '
                                    'Geburtsjahr ein, um fortzufahren.',
                                es: 'Aquí verás el progreso y la meta '
                                    'semanal de tu hijo o hija. Escribe tu '
                                    'año de nacimiento para continuar.'),
                          );
                          if (!ok || !context.mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ParentAreaScreen(),
                            ),
                          );
                        },
                      ),
                      // Cocuga yazilmis satir, KAPI YOK.
                      //
                      // Ayni kod Ebeveyn Alani'nda da var; orasi kapinin
                      // arkasinda. Burasi onunde, cunku kodu cocugun
                      // kendisi de velisine verebilmeli. Bedeli var:
                      // kodu alan kisi cocugun adini ve etkinligini
                      // goruyor. O yuzden acilan ekranda hem uyari var
                      // hem de "hepsini kaldir" dugmesi — ozelligi
                      // cocugun eline veriyorsak kapatmayi da vermeliyiz.
                      ListTile(
                        leading: _chip(
                            Icons.qr_code_2_rounded, AppTheme.accentTeal),
                        // Baslik KODU degil, PAYLASILAN SEYI anlatiyor.
                        // "Kodunu paylas" cocuga ne verdigini soylemiyor;
                        // "etkinliklerimi paylas" soyluyor.
                        title: Text(AppLang.pick(lang,
                            tr: 'Etkinliklerimi velimle paylaş',
                            en: 'Share my activity with a parent',
                            de: 'Meine Aktivität mit meinen Eltern teilen',
                            es: 'Compartir mi actividad con mi familia')),
                        subtitle: Text(AppLang.pick(lang,
                            tr: 'Neler öğrendiğini kendi telefonundan '
                                'görebilsinler',
                            en: 'So they can see what you are learning from '
                                'their own phone',
                            de: 'Damit sie auf ihrem Telefon sehen, was du '
                                'lernst',
                            es: 'Para que vean lo que aprendes desde su '
                                'móvil')),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TakipKoduScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ---- Dil -------------------------------------------
                  _group(
                    icon: Icons.language,
                    color: AppTheme.accentTeal,
                    title: loc.languageAndRegion,
                    children: [_buildLanguageTile(context, settings)],
                  ),

                  // ---- Bildirimler -----------------------------------
                  _group(
                    icon: Icons.notifications_rounded,
                    color: AppTheme.warningOrange,
                    title: loc.notifications,
                    children: [
                      _buildSwitchTile(
                        context,
                        title: loc.enableNotifications,
                        subtitle: loc.appNotifications,
                        icon: Icons.notifications_active,
                        value: settings.notificationsEnabled,
                        onChanged: (value) =>
                            settings.setNotificationsEnabled(value),
                      ),
                      if (settings.notificationsEnabled) ...[
                        _rowDivider(),
                        _buildSwitchTile(
                          context,
                          title: loc.sound,
                          subtitle: loc.notificationSounds,
                          icon: Icons.volume_up,
                          value: settings.soundEnabled,
                          onChanged: (value) => settings.setSoundEnabled(value),
                        ),
                        _rowDivider(),
                        _buildSwitchTile(
                          context,
                          title: loc.vibration,
                          subtitle: loc.notificationVibration,
                          icon: Icons.vibration,
                          value: settings.vibrationEnabled,
                          onChanged: (value) =>
                              settings.setVibrationEnabled(value),
                        ),
                      ],
                    ],
                  ),

                  // ---- Erişilebilirlik -------------------------------
                  _group(
                    icon: Icons.accessibility_new_rounded,
                    color: AppTheme.successGreen,
                    title: loc.accessibility,
                    children: [
                      _buildTextScaleTile(context, settings),
                      _rowDivider(),
                      _buildSwitchTile(
                        context,
                        title: loc.highContrast,
                        subtitle: loc.makeColorsBolder,
                        icon: Icons.contrast,
                        value: settings.highContrastMode,
                        onChanged: (value) =>
                            settings.setHighContrastMode(value),
                      ),
                    ],
                  ),

                  // ---- Gizlilik --------------------------------------
                  _group(
                    icon: Icons.privacy_tip_rounded,
                    color: AppTheme.primaryBlue,
                    title: loc.privacy,
                    children: [
                      _buildSwitchTile(
                        context,
                        title: loc.dataSharing,
                        subtitle: loc.shareAnonymousData,
                        icon: Icons.analytics,
                        value: settings.shareDataForImprovement,
                        onChanged: (value) =>
                            settings.setShareDataForImprovement(value),
                      ),
                      _rowDivider(),
                      ListTile(
                        leading: _chip(
                            Icons.description_outlined, AppTheme.primaryBlue),
                        title: Text(_t(
                            context,
                            'Gizlilik Politikası',
                            'Privacy Policy',
                            'Datenschutz',
                            'Política de privacidad')),
                        subtitle: Text(_t(
                            context,
                            'Gizlilik politikamızı ve hesap silmeyi görüntüle',
                            'View our privacy policy and account deletion',
                            'Datenschutzerklärung und Kontolöschung ansehen',
                            'Consulta nuestra política de privacidad y la eliminación de cuenta')),
                        trailing: const Icon(Icons.open_in_new, size: 18),
                        onTap: () async {
                          final uri = Uri.parse(
                            'https://oguzhnkurt.github.io/devkom_App1/privacy-policy.html',
                          );
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        },
                      ),
                    ],
                  ),

                  // ---- Uygulama deneyimi -----------------------------
                  _group(
                    icon: Icons.touch_app_rounded,
                    color: AppTheme.accentTeal,
                    title: loc.appExperience,
                    children: [
                      ListTile(
                        leading:
                            _chip(Icons.replay_rounded, AppTheme.accentTeal),
                        title: Text(loc.showOnboardingAgain),
                        subtitle: Text(loc.onboardingWillShow),
                        trailing: TextButton.icon(
                          onPressed: () async {
                            await settings.resetOnboarding();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(loc.onboardingResetMessage),
                                  backgroundColor: AppTheme.successGreen,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.refresh, size: 18),
                          label: Text(loc.reset),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primaryBlue,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            minimumSize: const Size(0, 36),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ---- Hakkında --------------------------------------
                  _group(
                    icon: Icons.info_rounded,
                    color: Colors.purple,
                    title: loc.about,
                    children: [
                      _buildAboutTile(context),
                      // Yalnizca hata ayiklama derlemesinde gorunur.
                      // Yayin derlemesinde `kDebugMode` false oldugu icin
                      // bu satir hic olusmuyor.
                      if (kDebugMode) _buildAdTestTile(context),
                      if (kDebugMode) const _ProSimTile(),
                    ],
                  ),

                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _showResetDialog(context, settings),
                    icon: const Icon(Icons.restore, color: AppTheme.errorRed),
                    label: Text(
                      loc.resetSettings,
                      style: const TextStyle(color: AppTheme.errorRed),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                          color: AppTheme.errorRed, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Başlık + beyaz kart.
  ///
  /// Gökyüzünün üstünde okunabilirlik için kart yarı saydam değil
  /// neredeyse tam beyaz; başlık ise kartın DIŞINDA, gökyüzünün
  /// üstünde duruyor, böylece bölümler görsel olarak ayrılıyor ve
  /// `Divider` gerekmiyor.
  Widget _group({
    required IconData icon,
    required Color color,
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
            child: Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.darkBlue,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Kart MATERIAL olmali, sadece renkli bir kutu degil:
          // ListTile arka planini ve dokunma dalgasini en yakin
          // Material'a cizer. Renkli bir DecoratedBox araya girerse
          // dokunma geri bildirimi gorunmez olur (Flutter bunu
          // calisma aninda uyari olarak da soyluyor).
          Material(
            color: Colors.white,
            elevation: 2,
            shadowColor: AppTheme.darkBlue.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(22),
            clipBehavior: Clip.antiAlias,
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  /// Kart içindeki satırları ayıran çok ince çizgi.
  Widget _rowDivider() => Divider(
        height: 1,
        thickness: 1,
        indent: 68,
        color: AppTheme.mediumGray.withValues(alpha: 0.18),
      );

  /// Satır başındaki renkli ikon karesi.
  Widget _chip(IconData icon, Color color) => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      );

  Widget _buildLanguageTile(BuildContext context, SettingsProvider settings) {
    final loc = AppLocalizations.of(context);

    return ListTile(
      leading: _chip(Icons.translate, AppTheme.accentTeal),
      title: Text(loc.language, style: const TextStyle(inherit: true)),
      subtitle: Row(
        children: [
          Text(AppLang.flag[settings.locale.languageCode] ?? '',
              style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(settings.currentLanguageName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(inherit: true)),
          ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => _showLanguageDialog(context, settings),
    );
  }

  Widget _buildTextScaleTile(BuildContext context, SettingsProvider settings) {
    final loc = AppLocalizations.of(context);

    return ListTile(
      leading: _chip(Icons.text_fields, AppTheme.warningOrange),
      title: Text(loc.textSize, style: const TextStyle(inherit: true)),
      // Kaydiracin varsayilan mor rengi ekranin geri kalanina hic
      // uymuyordu; turkuaza cekiyoruz.
      subtitle: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: AppTheme.accentTeal,
          inactiveTrackColor: AppTheme.accentTeal.withValues(alpha: 0.22),
          thumbColor: AppTheme.accentTeal,
          overlayColor: AppTheme.accentTeal.withValues(alpha: 0.15),
          valueIndicatorColor: AppTheme.primaryBlue,
        ),
        child: Slider(
          value: settings.textScaleFactor,
          min: 0.8,
          max: 1.4,
          divisions: 6,
          label: '${(settings.textScaleFactor * 100).round()}%',
          onChanged: (value) => settings.setTextScaleFactor(value),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: _chip(icon, AppTheme.accentTeal),
      title: Text(title, style: const TextStyle(inherit: true)),
      subtitle:
          Text(subtitle, style: const TextStyle(fontSize: 12, inherit: true)),
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppTheme.accentTeal,
    );
  }

  /// Reklam tani ekranina giden yol — yalnizca hata ayiklama.
  ///
  /// Reklami denerken "hicbir sey cikmadi" demenin on tane sessiz sebebi
  /// var (Pro uyelik, isinma payi, gunluk tavan, dort dakikalik ara...).
  /// Bu ekran hangisinin gecerli oldugunu tek bakista soyluyor.
  Widget _buildAdTestTile(BuildContext context) {
    return ListTile(
      leading: _chip(Icons.ads_click_rounded, Colors.teal),
      title: const Text('Reklam testi (debug)',
          style: TextStyle(inherit: true)),
      subtitle: const Text('Yalnizca hata ayiklama derlemesinde gorunur',
          style: TextStyle(inherit: true)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdTestScreen()),
      ),
    );
  }

  Widget _buildAboutTile(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return ListTile(
      leading: _chip(Icons.info_outline, Colors.purple),
      title: Text(loc.aboutApp, style: const TextStyle(inherit: true)),
      // Sürüm artık elle yazılmıyor; pubspec ile teste bağlı.
      subtitle: Text('${loc.version} ${AppVersion.full}',
          style: const TextStyle(inherit: true)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => _showAboutDialog(context),
    );
  }

  /// Dil secimi.
  ///
  /// Once iki dil elle yazilmisti (iki tam RadioListTile blogu, her
  /// birinde ayni 15 satirlik akis kopyalanmis). Dort dile cikarken
  /// kopyalamak yerine listeyi [AppLang.supported] uzerinden kuruyoruz:
  /// yeni bir dil eklemek artik bu ekranda hicbir degisiklik
  /// gerektirmiyor.
  ///
  /// Her dil KENDI adiyla yaziliyor — "Almanca" degil "Deutsch". Dil
  /// secen kullanici, secmek uzere oldugu dili henuz okumuyor olabilir
  /// ama kendi dilinin adini tanir.
  void _showLanguageDialog(BuildContext context, SettingsProvider settings) {
    final loc = AppLocalizations.of(context);
    final current = settings.locale.languageCode;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(loc.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final code in AppLang.supported)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: Text(
                  AppLang.flag[code] ?? '',
                  style: const TextStyle(fontSize: 26),
                ),
                title: Text(
                  AppLang.nativeName[code] ?? code,
                  style: TextStyle(
                    inherit: true,
                    fontWeight:
                        code == current ? FontWeight.w800 : FontWeight.w500,
                    color: code == current ? AppTheme.primaryBlue : null,
                  ),
                ),
                trailing: code == current
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppTheme.primaryBlue)
                    : null,
                onTap: () async {
                  Navigator.pop(dialogContext);
                  if (code == current) return;
                  _showLanguageChangingOverlay(context, code);
                  await Future.delayed(const Duration(milliseconds: 100));
                  await settings.setLocale(Locale(code));
                  await Future.delayed(const Duration(milliseconds: 1200));
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(loc.cancel),
          ),
        ],
      ),
    );
  }

  void _showLanguageChangingOverlay(BuildContext context, String languageCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: _LanguageChangingOverlay(languageCode: languageCode),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final loc = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.appName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${loc.version}: ${AppVersion.full}'),
            const SizedBox(height: 8),
            Text(loc.appDescription),
            const SizedBox(height: 16),
            const Text('© 2025 DevEducation', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.ok),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, SettingsProvider settings) {
    final loc = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.resetSettings),
        content: Text(loc.resetConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              settings.resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(loc.settingsResetSuccess),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(loc.reset),
          ),
        ],
      ),
    );
  }
}

/// Modern language changing overlay with animation
class _LanguageChangingOverlay extends StatefulWidget {
  final String languageCode;

  const _LanguageChangingOverlay({required this.languageCode});

  @override
  State<_LanguageChangingOverlay> createState() =>
      _LanguageChangingOverlayState();
}

class _LanguageChangingOverlayState extends State<_LanguageChangingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Onay mesaji YENI dilde yaziliyor: kullanici Almanca'yi sectiyse
    // dogru sey olup olmadigini Almanca bir cumleden anlar.
    const messages = {
      AppLang.tr: 'Dil Türkçe olarak değiştirildi',
      AppLang.en: 'The language has been changed to English',
      AppLang.de: 'Die Sprache wurde auf Deutsch umgestellt',
      AppLang.es: 'El idioma se ha cambiado a español',
    };
    final message = messages[widget.languageCode] ?? messages[AppLang.en]!;

    return Material(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryBlue.withValues(alpha: 0.95),
                    AppTheme.accentTeal.withValues(alpha: 0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated check icon
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.check_circle,
                            size: 50,
                            color: AppTheme.successGreen,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Success message
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Loading indicator
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ekrandaki kısa arayüz yazıları için dört dilli yardımcı.
///
/// Bu ekran tamamen Türkçe sabit yazılarla yazılmıştı; İngilizce,
/// Almanca ya da İspanyolca seçen çocuk uygulamanın geri kalanı
/// çevrilmişken burada Türkçe görüyordu.
String _t(BuildContext context, String tr, String en, String de, String es) =>
    AppLang.pick(
      Provider.of<SettingsProvider>(context).locale.languageCode,
      tr: tr,
      en: en,
      de: de,
      es: es,
    );

/// Pro simulasyonu anahtari — YALNIZCA hata ayiklama derlemesi.
///
/// Acikken butun Pro kurslar, Pro oyunlar, Pro gorevler, sertifika ve
/// rapor aciliyor; kilitli her seyi satin almadan deneyebilirsin.
///
/// Reklamlarla ilgisi yok: bu anahtar reklamlari KAPATMIYOR. Kilit
/// sayfasindaki "Reklam izle" dugmesini gormek istiyorsan anahtari
/// KAPAT — Pro uyeye o dugme hic cikmiyor.
///
/// Ayri bir bilesen olmasinin sebebi: SettingsScreen stateless, anahtarin
/// kendi durumunu cizebilmesi icin kucuk bir stateful kutu gerekiyor.
class _ProSimTile extends StatefulWidget {
  const _ProSimTile();

  @override
  State<_ProSimTile> createState() => _ProSimTileState();
}

class _ProSimTileState extends State<_ProSimTile> {
  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.lock_open_rounded, color: Colors.amber),
      ),
      title: const Text('Her şeyi aç (debug)',
          style: TextStyle(inherit: true)),
      subtitle: const Text(
          'Pro simülasyonu. Yalnızca hata ayıklama derlemesinde çalışır.',
          style: TextStyle(inherit: true)),
      value: ProGate.debugHerSeyAcik,
      onChanged: (v) => setState(() => ProGate.debugHerSeyAcik = v),
    );
  }
}
