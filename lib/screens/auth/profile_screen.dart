import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/lang.dart';
import '../../providers/settings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/learner_profile.dart';
import '../../models/user_model.dart';
import '../../models/user_progress_model.dart';
import '../../theme.dart';
import '../../models/store_item_model.dart';
import '../../services/store_service.dart';
import '../../widgets/avatar_cercevesi.dart';
import 'ad_duzenleyici.dart';
import 'hesap_ekrani.dart';
import 'login_screen.dart';
import '../settings/settings_screen.dart';
import '../../utils/app_localizations.dart';
import '../../utils/pro_gate.dart';
import '../report/progress_report_screen.dart';
import '../../widgets/mascot.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggingOut = false;

  // Profilin en ustunde kullanicinin kusandigi karakter gorunuyor.

  /// Takma ad alani. NOT: Bu controller bilerek State'e bagli.
  /// Daha once modal icinde olusturulup showModalBottomSheet doner donmez
  /// dispose ediliyordu; sayfanin kapanma animasyonu bitmeden atildigi icin
  /// '_dependents.isEmpty' assertion'i ile kirmizi ekran veriyordu.
  final TextEditingController _nameController = TextEditingController();

  /// Hesap baglama sayfasindaki alanlar. Ayni sebeple State'e bagli:
  /// showModalBottomSheet'in future'i route pop edilir edilmez tamamlaniyor,
  /// kapanma animasyonu ise hala suruyor. Modal icinde olusturulup metodun
  /// sonunda dispose edilirse TextField hala o controller'i dinledigi icin
  /// "used after being disposed" hatasi ile kirmizi ekran geliyor.
  final TextEditingController _linkEmailController = TextEditingController();
  final TextEditingController _linkPasswordController = TextEditingController();

  /// Kusanilmis avatar cercevesi. Market bunu satiyor; profil avatari
  /// onu GOSTERIYOR. Once gostermiyordu: cocuk jetonunu veriyor,
  /// ekranda hicbir sey degismiyordu.
  StoreItem? _cerceve;

  @override
  void initState() {
    super.initState();
    _cerceveyiYukle();
  }

  /// Kusanilmis profil afisi: baslik alaninin rengi.
  StoreItem? _afis;

  Future<void> _cerceveyiYukle() async {
    try {
      final servis = StoreService();
      final c = await servis.getEquippedItem(StoreItemCategory.avatarFrame);
      final a = await servis.getEquippedItem(StoreItemCategory.profileBanner);
      if (!mounted) return;
      setState(() {
        _cerceve = c;
        _afis = a;
      });
    } catch (_) {
      // Okunamazsa varsayilan gorunum: sade halka, kurumsal mavi baslik.
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _linkEmailController.dispose();
    _linkPasswordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FA),
      appBar: AppBar(
        title: Text(loc.profile.toUpperCase()),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final user = authProvider.currentUser;

          // NOT: Uygulama artik acilista anonim oturum aciyor, bu yuzden
          // user normalde hicbir zaman null olmuyor. Anonim oturum bir
          // sebeple acilamazsa (ag yok) kullaniciyi bos ekranda birakmamak
          // icin kisa bir bilgilendirme gosteriyoruz.
          if (user == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_off_rounded,
                        size: 56, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      _t4(context, 'Profilin yüklenemedi',
                          'Profile could not load', 'Profil konnte nicht geladen werden',
                          'No se pudo cargar el perfil'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      // ESKI METIN YANLIS SEYI SOYLUYORDU.
                      //
                      // "Internet baglantini kontrol et" diyordu ama en
                      // sik sebep ag degildi: cikis yaptiktan sonra
                      // uygulama kullanicisiz kaliyordu. Cocuk internete
                      // bakip bir sey bulamiyor, uygulamayi yeniden
                      // aciyor ve ayni ekrani goruyordu.
                      _t4(
                          context,
                          'Oturum açılamadı. Tekrar deneyelim.',
                          'We could not start your session. Let us try again.',
                          'Die Sitzung konnte nicht gestartet werden. '
                              'Versuchen wir es erneut.',
                          'No se pudo iniciar la sesión. Vamos a intentarlo '
                              'de nuevo.'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13.5),
                    ),
                    const SizedBox(height: 18),
                    // CIKIS YOLU YOKTU: ekranda tek bir dugme bile
                    // olmadigi icin kullanicinin yapabilecegi tek sey
                    // uygulamayi kapatmakti.
                    FilledButton.icon(
                      onPressed: () => authProvider.refreshUser(),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: Text(_t4(context, 'Tekrar dene', 'Try again',
                          'Erneut versuchen', 'Reintentar')),
                    ),
                  ],
                ),
              ),
            );
          }

          final progress = authProvider.userProgress;

          return SingleChildScrollView(
            // Alt cam gezinme cubugu icerigin uzerinde duruyor; son kart
            // onun altinda kalmasin diye cubugun yuksegi kadar bosluk.
            padding: EdgeInsets.only(
                bottom: MediaQuery.paddingOf(context).bottom),
            child: Column(
              children: [
                _buildHeader(context, user, theme),
                // NOT: Burada daha once `margin: EdgeInsets.only(top: -28)`
                // kullaniliyordu; Flutter'da Container margin'i negatif
                // olamaz ('margin.isNonNegative' assertion) ve bu ekrani
                // tamamen cokertiyordu. Ayni "basligin uzerine binme"
                // gorunumu icin Transform kullaniyoruz.
                Transform.translate(
                  offset: const Offset(0, -28),
                  child: _buildStatsGrid(progress),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Column(
                    children: [
                      if (authProvider.isAnonymous) ...[
                        _buildSaveProgressCard(context),
                        const SizedBox(height: 20),
                      ],
                      _buildReportCard(context),
                      const SizedBox(height: 20),
                      _buildActionsGroup(context, loc),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // HEADER - kurumsal gradyan + avatar + rozet
  // ==========================================
  Widget _buildHeader(BuildContext context, UserModel user, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 56),
      decoration: BoxDecoration(
        // AFIS: marketten alinan profil afisi basligin rengini
        // degistiriyor. Alinmadiysa kurumsal mavi duruyor — "eksik" bir
        // gorunum degil, varsayilan gorunum.
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _afis == null
              ? [AppTheme.darkBlue, AppTheme.primaryBlue]
              : [
                  Color.lerp(AvatarCercevesi.renk(_afis!.colorHex),
                      Colors.black, 0.35)!,
                  AvatarCercevesi.renk(_afis!.colorHex),
                ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ince dekoratif parıltılar - abartısız, kurumsal his bozulmadan
          const Positioned(
              top: 16,
              left: 32,
              child: Opacity(
                  opacity: 0.35,
                  child: Text('✨', style: TextStyle(fontSize: 14)))),
          const Positioned(
              top: 40,
              right: 40,
              child: Opacity(
                  opacity: 0.3,
                  child: Text('✨', style: TextStyle(fontSize: 12)))),
          const Positioned(
              top: 10,
              right: 90,
              child: Opacity(
                  opacity: 0.25,
                  child: Text('✨', style: TextStyle(fontSize: 10)))),
          if (_afis != null)
            Positioned(
              top: 14,
              left: 18,
              child: Opacity(
                opacity: 0.55,
                child: Text(_afis!.iconEmoji,
                    style: const TextStyle(fontSize: 22)),
              ),
            ),
          Column(
            children: [
              const SizedBox(height: 28),
              _buildCharacterAvatar(theme, user),
              const SizedBox(height: 10),
              // Takma ad — dokununca duzenlenebiliyor.
              GestureDetector(
                onTap: () => _showNameEditor(context, user.displayName),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        user.displayName,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.edit_rounded,
                        size: 17, color: Colors.white.withValues(alpha: 0.8)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              // NOT: Burada e-posta gosteriliyordu; kisisel veriyi ekranda
              // tutmamak icin kaldirildi.
              Text(
                _t4(context, 'Takma adını değiştirmek için dokun',
                    'Tap to change your nickname',
                    'Tippe, um deinen Spitznamen zu ändern',
                    'Toca para cambiar tu apodo'),
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65), fontSize: 12),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (user.learningGoal != null) ...[
                    _buildGoalBadge(user.learningGoal!),
                    const SizedBox(width: 8),
                  ],
                  if (user.isPro) _buildProBadge(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Profil basligindaki avatar: MASKOT.
  ///
  /// Once burada kusanilmis karakter + sapka/gozluk/kolye/ayakkabi
  /// ciziliyordu. Giydirme kalkti (tek maskot, 3B render), o yuzden
  /// burada da Devi duruyor. Cocuk hicbir sey kusanmamissa eskiden
  /// bas harfleri goruyordu; simdi herkes ayni arkadasi goruyor.
  Widget _buildCharacterAvatar(ThemeData theme, UserModel user) {
    return AvatarCercevesi(
      boyut: 150,
      cerceve: _cerceve,
      child: const Mascot(size: 112, showShadow: false),
    );
  }

  /// Takma ad duzenleme sayfasi. Rastgele yeni ad uretme secenegi de var.
  /// Takma ad duzenleyici ortak dosyaya tasindi: ayni duzenleyici
  /// Hesap ekranindan da aciliyor (bkz. ad_duzenleyici.dart).
  Future<void> _showNameEditor(BuildContext context, String currentName) =>
      adDuzenleyiciyiAc(context, currentName);

  Widget _buildProBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA000)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 4)),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium, color: Colors.white, size: 16),
          SizedBox(width: 6),
          Text('PRO',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }

  // ==========================================
  // STAT GRID - gercek kullanici verisiyle (XP, Seviye, Jeton, Seri)
  // ==========================================
  Widget _buildStatsGrid(UserProgress? progress) {
    final level = progress?.level ?? 1;
    final totalXP = progress?.totalXP ?? 0;
    final jeton = progress?.jetonBalance ?? 0;
    final streak = progress?.streakDays ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          children: [
            _buildStatItem(
                Icons.military_tech, 'Seviye', '$level', AppTheme.primaryBlue),
            _buildStatDivider(),
            _buildStatItem(
                Icons.bolt, 'XP', '$totalXP', AppTheme.warningOrange),
            _buildStatDivider(),
            _buildStatItem(Icons.monetization_on, 'Jeton', '$jeton',
                const Color(0xFFFFA000)),
            _buildStatDivider(),
            _buildStatItem(Icons.local_fire_department, 'Seri', '$streak',
                Colors.redAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildStatDivider() =>
      Container(width: 1, height: 36, color: Colors.grey.shade200);

  Widget _buildStatItem(
      IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  // ==========================================
  // BILGI GRUBU - tek kart icinde bolunmus satirlar (kurumsal liste hissi)
  // ==========================================
  Widget _buildSaveProgressCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5A34E8), Color(0xFF00C4E0)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5A34E8).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/app_icon.png',
                  width: 46,
                  height: 46,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t4(context, 'İlerlemeni kaydet', 'Save your progress',
                          'Sichere deinen Fortschritt', 'Guarda tu progreso'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _t4(
                          context,
                          'Şu an ilerlemen sadece bu telefonda duruyor',
                          'Right now your progress lives only on this phone',
                          'Dein Fortschritt liegt derzeit nur auf diesem Handy',
                          'Ahora mismo tu progreso solo está en este teléfono'),
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _t4(
                context,
                'Bir e-posta ekleyerek XP, jeton ve karakterlerini hesabına bağla. '
                    'Telefonunu değiştirsen de kaldığın yerden devam edersin.',
                'Add an email to tie your XP, coins and characters to an account. '
                    'Change phones and you carry on right where you left off.',
                'Verknüpfe XP, Münzen und Figuren über eine E-Mail mit deinem Konto. '
                    'Auch nach einem Handywechsel machst du genau dort weiter.',
                'Añade un correo para vincular tu XP, monedas y personajes a tu cuenta. '
                    'Si cambias de teléfono, sigues justo donde lo dejaste.'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _showLinkAccountSheet(context),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF5A34E8),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _t4(context, 'Hesabımı oluştur', 'Create my account',
                    'Konto erstellen', 'Crear mi cuenta'),
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// E-posta + sifre alip anonim hesabi kalici hale getirir.
  Future<void> _showLinkAccountSheet(BuildContext context) async {
    final emailController = _linkEmailController..clear();
    final passwordController = _linkPasswordController..clear();
    String? error;
    bool busy = false;
    bool obscure = true;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          Future<void> submit() async {
            final mail = emailController.text.trim();
            final pass = passwordController.text;

            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(mail)) {
              setSheetState(() => error = _t4(
                  context,
                  'Geçerli bir e-posta yaz.',
                  'Enter a valid email address.',
                  'Gib eine gültige E-Mail-Adresse ein.',
                  'Escribe un correo electrónico válido.'));
              return;
            }
            if (pass.length < 6) {
              setSheetState(() => error = _t4(
                  context,
                  'Şifre en az 6 karakter olmalı.',
                  'Password must be at least 6 characters.',
                  'Das Passwort muss mindestens 6 Zeichen haben.',
                  'La contraseña debe tener al menos 6 caracteres.'));
              return;
            }

            setSheetState(() {
              busy = true;
              error = null;
            });
            final auth = context.read<AuthProvider>();
            final ok = await auth.linkAccount(email: mail, password: pass);
            if (!sheetContext.mounted) return;

            if (ok) {
              Navigator.pop(sheetContext);
              // BILDIRIM SAYFANIN KENDI DURUMUNA BAGLI.
              //
              // Once yalnizca `context.mounted` bakiliyordu; sayfa
              // bu sirada agactan kalkmis olabiliyor ve
              // `ScaffoldMessenger.of(context)` "No ScaffoldMessenger
              // widget found" hatasiyla kirmizi ekran veriyordu.
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_t4(
                        context,
                        'Hesabın oluşturuldu, ilerlemen kayıtlı.',
                        'Your account is ready and your progress is saved.',
                        'Dein Konto ist fertig, dein Fortschritt ist gespeichert.',
                        'Tu cuenta está lista y tu progreso está guardado.')),
                  ),
                );
              }
            } else {
              setSheetState(() {
                busy = false;
                error = auth.errorMessage ??
                    _t4(context, 'Kaydedilemedi, tekrar dene.',
                        'Could not save, please try again.',
                        'Speichern fehlgeschlagen, versuch es erneut.',
                        'No se pudo guardar, inténtalo de nuevo.');
              });
            }
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              22,
              20,
              MediaQuery.of(sheetContext).viewInsets.bottom + 26,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t4(context, 'Hesabını oluştur', 'Create your account',
                      'Erstelle dein Konto', 'Crea tu cuenta'),
                  style:
                      const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  _t4(
                      context,
                      'Mevcut ilerlemen aynen korunur — yeni bir hesap açmıyoruz, '
                          'bu hesabı e-postana bağlıyoruz.',
                      'Your current progress stays exactly as it is — we are not '
                          'starting a new account, we are linking this one to your email.',
                      'Dein bisheriger Fortschritt bleibt genau erhalten — wir legen '
                          'kein neues Konto an, sondern verknüpfen dieses mit deiner E-Mail.',
                      'Tu progreso actual se mantiene igual: no creamos una cuenta '
                          'nueva, vinculamos esta a tu correo.'),
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey[600],
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: _t4(context, 'E-posta', 'Email', 'E-Mail',
                        'Correo electrónico'),
                    prefixIcon: const Icon(Icons.mail_outline_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    labelText: _t4(context, 'Şifre', 'Password', 'Passwort',
                        'Contraseña'),
                    helperText: _t4(context, 'En az 6 karakter',
                        'At least 6 characters', 'Mindestens 6 Zeichen',
                        'Al menos 6 caracteres'),
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setSheetState(() => obscure = !obscure),
                    ),
                    errorText: error,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: busy ? null : submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF5A34E8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(_t4(context, 'Kaydet', 'Save', 'Speichern',
                            'Guardar')),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Pro'ya ozel ilerleme raporu girisi. Pro degilse tanitim sayfasi aciliyor.
  Widget _buildReportCard(BuildContext context) {
    final isPro = ProGate.watchIsPro(context);

    return GestureDetector(
      onTap: () async {
        if (!isPro) {
          final ok = await ProGate.ensure(
            context,
            featureName: _t4(context, 'İlerleme Raporu', 'Progress Report',
                'Fortschrittsbericht', 'Informe de progreso'),
            explanation: _t4(
                context,
                'Hangi kursta nerede olduğunu, hangi gün çalıştığını '
                    've neyin yarım kaldığını gösterir. Biten kursların '
                    'sertifikasına da buradan ulaşılıyor.',
                'Shows where you are in each course, which days you studied and '
                    'what is left half finished. Certificates for completed '
                    'courses are here too.',
                'Zeigt, wo du in jedem Kurs stehst, an welchen Tagen du geübt hast '
                    'und was halb fertig liegen geblieben ist. Zertifikate für '
                    'abgeschlossene Kurse findest du ebenfalls hier.',
                'Muestra dónde estás en cada curso, qué días estudiaste y qué '
                    'quedó a medias. Los certificados de los cursos terminados '
                    'también están aquí.'),
          );
          if (!ok || !context.mounted) return;
        }
        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProgressReportScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C3CE0), Color(0xFF9B6BFF)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.insights_rounded, color: Colors.white, size: 26),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t4(context, 'İlerleme Raporu', 'Progress Report',
                        'Fortschrittsbericht', 'Informe de progreso'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _t4(
                        context,
                        'Kurs kırılımı, haftalık çalışma ve sertifikalar',
                        'Course breakdown, weekly practice and certificates',
                        'Kursübersicht, wöchentliches Üben und Zertifikate',
                        'Desglose por curso, práctica semanal y certificados'),
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (!isPro)
              ProGate.badge(size: 9)
            else
              const Icon(Icons.chevron_right_rounded, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsGroup(BuildContext context, AppLocalizations loc) {
    return _buildGroupCard(
      title: _t4(context, 'Hesap İşlemleri', 'Account', 'Konto', 'Cuenta'),
      children: [
        // HESAP: takma ad, kurulum cevaplari, veli paylasim kodu ve
        // hesabi silme artik tek bir ekranda. Eskiden hepsi profilin
        // icine dagilmisti ve "Tehlikeli Bolge" kutusu her ziyarette
        // gorunuyordu.
        _buildActionRow(
          icon: Icons.manage_accounts_outlined,
          label: _t4(context, 'Hesap', 'Account', 'Konto', 'Cuenta'),
          color: AppTheme.accentTeal,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HesapEkrani()),
          ),
        ),
        Divider(height: 1, color: Colors.grey.shade100, indent: 56),
        _buildActionRow(
          icon: Icons.settings_outlined,
          label: loc.settings,
          color: AppTheme.primaryBlue,
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SettingsScreen()));
          },
        ),
        Divider(height: 1, color: Colors.grey.shade100, indent: 56),
        _buildActionRow(
          icon: Icons.logout,
          label: _isLoggingOut ? loc.loggingOut : loc.logout,
          color: AppTheme.darkGray,
          loading: _isLoggingOut,
          onTap: _isLoggingOut ? null : () => _confirmLogout(context),
        ),
      ],
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
    bool loading = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: loading
                  ? Padding(
                      padding: const EdgeInsets.all(9),
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: color),
                    )
                  : Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500))),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TEHLIKELI BOLGE - Hesap silme, acikca ayristirilmis
  // ==========================================
  Widget _buildGroupCard(
      {required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
                letterSpacing: 0.4),
          ),
          const SizedBox(height: 4),
          ...children,
        ],
      ),
    );
  }

  /// Profilin ustundeki rozet.
  ///
  /// Burada eskiden "Ogrenci" rol rozeti vardi. Uygulama tek kullanici tipine
  /// gectikten sonra herkes ogrenci oldugu icin rozet hicbir bilgi tasimiyordu;
  /// yerine cocugun onboarding'de sectigi hedef gosteriliyor.
  Widget _buildGoalBadge(LearningGoal goal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(goal.emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 6),
          Text(
            goal.labelFor(Localizations.localeOf(context).languageCode),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }



  // ==========================================
  // SLIDE-UP ONAY PANELLERI (showModalBottomSheet)
  // ==========================================

  void _confirmLogout(BuildContext context) {
    final loc = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _ConfirmSheet(
        dragHandleColor: Colors.grey.shade300,
        iconBackgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
        icon: Icons.logout,
        iconColor: AppTheme.primaryBlue,
        title: loc.logout,
        message: loc.logoutConfirmation,
        cancelLabel: loc.cancel,
        confirmLabel: loc.logout,
        confirmColor: AppTheme.primaryBlue,
        onConfirm: () {
          Navigator.pop(sheetContext);
          _handleLogout(
              context, Provider.of<AuthProvider>(context, listen: false));
        },
      ),
    );
  }

  Future<void> _handleLogout(
      BuildContext context, AuthProvider authProvider) async {
    final loc = AppLocalizations.of(context);
    setState(() {
      _isLoggingOut = true;
    });

    try {
      await authProvider.signOut();
      await Future.delayed(const Duration(milliseconds: 100));

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${loc.logoutErrorMessage}: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}


/// Ortak "slide up" onay paneli - Quizo tasarımındaki yuvarlatılmış üst
/// köşeli, tutamaçlı (drag handle) alt sayfa hissini örnek alır; kurumsal
/// mavi/kırmızı temamızla (logout/silme) uyarlanmıştır. Bkz. ProPaywall
/// (lib/widgets/pro_paywall.dart) - aynı showModalBottomSheet deseni.
class _ConfirmSheet extends StatelessWidget {
  final Color dragHandleColor;
  final Color iconBackgroundColor;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String cancelLabel;
  final String confirmLabel;
  final Color confirmColor;
  final VoidCallback onConfirm;

  const _ConfirmSheet({
    required this.dragHandleColor,
    required this.iconBackgroundColor,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.confirmColor,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28), topRight: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 12, 24, 24 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: dragHandleColor, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
                color: iconBackgroundColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 30),
          ),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13.5, color: Colors.grey.shade600, height: 1.4),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(confirmLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                foregroundColor: Colors.grey.shade700,
              ),
              child: Text(cancelLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
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
