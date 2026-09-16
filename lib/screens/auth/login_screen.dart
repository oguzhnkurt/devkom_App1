import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/permission_manager.dart';
import '../../theme.dart';
import '../../widgets/code_hero_background.dart';
import '../../widgets/permission_sheet.dart';
import '../role_based_home_screen.dart';
import 'auth_wrapper.dart';
import 'register_screen.dart';
import '../../utils/lang.dart';

/// Giriş ekranı.
///
/// Eskiden yanıp sönen turkuaz/mor glow katmanları, dönen bir halka ve eski
/// "DEVKOM YAZILIM" logosu vardı; uygulamanın geri kalanıyla hiçbir ilgisi
/// yoktu ve marka bile yanlıştı. Artık karşılama ekranıyla aynı dili
/// konuşuyor: akan kod arka planı, üzerinde sade beyaz bir kart.
///
/// Önemli not: bu ekran artık zorunlu bir kapı değil. Uygulama açılışta
/// sessizce anonim oturum açıyor, ilerleme ilk saniyeden itibaren
/// kaydediliyor. Buraya yalnızca daha önce hesap açmış biri gelir.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Arayuz dili. Giris ekrani da bugune kadar tamamen Turkce sabitti.
  ///
  /// `listen: false`: bu getter form dogrulayicilarindan da cagriliyor ve
  /// onlar build disinda calisiyor; `watch` orada istisna firlatir.
  String get _lang =>
      Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;
  /// Metin secici.
  ///
  /// [de] ve [es] verilmemisse Ingilizcesi gosteriliyor. Boylece bir
  /// cumlenin Almancasi henuz yazilmamis olsa bile ekran dogru
  /// calisiyor ve ceviri sonradan tek bir arguman eklenerek
  /// tamamlanabiliyor — 500'den fazla cagri yerini bir anda cevirmek
  /// zorunda kalmadan.
  String _t(String tr, String en, [String? de, String? es]) =>
      AppLang.pick(_lang, tr: tr, en: en, de: de, es: es);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _busy = false;
  bool _appleAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkApple();
  }

  Future<void> _checkApple() async {
    final ok = await context.read<AuthProvider>().isAppleSignInAvailable();
    if (mounted) setState(() => _appleAvailable = ok);
  }

  /// Apple ile giris.
  ///
  /// Cocuk kullanicilar icin birincil yol: sifre yok, tek dokunus ve
  /// "E-postami Gizle" sayesinde gercek e-postayi hic saklamiyoruz.
  Future<void> _appleSignIn() async {
    if (_busy) return;
    setState(() => _busy = true);
    final authProvider = context.read<AuthProvider>();
    final ok = await authProvider.signInWithApple();
    if (!mounted) return;
    setState(() => _busy = false);

    if (ok) {
      await _showPermissionSheetIfNeeded();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RoleBasedHomeScreen()),
        (route) => false,
      );
    } else if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate() || _busy) return;

    setState(() => _busy = true);
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _busy = false);

    if (success && authProvider.currentUser != null) {
      await _showPermissionSheetIfNeeded();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RoleBasedHomeScreen()),
        (route) => false,
      );
    } else if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  /// "Hesapsız devam et".
  ///
  /// Burada eskiden `Navigator.pop` vardi ve siyah ekran veriyordu: bu ekrana
  /// onboarding'den `pushReplacement` ile gelindigi icin altta hicbir rota
  /// kalmiyor, pop da bos bir Navigator birakiyordu. Geri gitmek yerine ileri
  /// gidiyoruz: uygulama zaten anonim oturumla calisiyor, dogrudan ana ekrana
  /// devam etmek dogru davranis.
  Future<void> _continueWithoutAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthWrapper()),
      (route) => false,
    );
  }

  /// Bildirim izni sayfası — yalnızca bir kez.
  ///
  /// Eskiden role göre kamera/fotoğraf izni de isteniyordu; uygulama tek
  /// kullanıcı tipine geçtiği ve veli kamerası kaldırıldığı için geriye
  /// yalnızca bildirim kaldı.
  Future<void> _showPermissionSheetIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('permission_sheet_shown') ?? false) return;
    await prefs.setBool('permission_sheet_shown', true);

    if (!mounted) return;
    await PermissionSheet.show(
      context,
      permissions: [AppPermission.notification],
      onComplete: () {},
      canSkip: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B3A8C),
      body: CodeHeroBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCard(),
                    const SizedBox(height: 18),
                    TextButton.icon(
                      onPressed: _busy ? null : _continueWithoutAccount,
                      icon: const Icon(Icons.arrow_back_rounded,
                          size: 18, color: Colors.white),
                      label: Text(
                        _t('Hesapsız devam et', 'Continue without an account', 'Ohne Konto fortfahren', 'Continuar sin cuenta'),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppTheme.primaryBlue.withValues(alpha: 0.08),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/app_icon.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.school_rounded,
                    size: 38,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _t('Tekrar hoş geldin', 'Welcome back', 'Willkommen zurück', 'Bienvenido de nuevo'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGray,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _t('Hesabına giriş yap, ilerlemen seni bekliyor.',
                  'Sign in — your progress is waiting for you.', 'Melde dich an — dein Fortschritt wartet auf dich.', 'Inicia sesión: tu progreso te espera.'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppTheme.mediumGray),
            ),
            const SizedBox(height: 26),
            if (_appleAvailable) ...[
              SizedBox(
                width: double.infinity,
                child: SignInWithAppleButton(
                  onPressed: _busy ? () {} : _appleSignIn,
                  text: _t('Apple ile devam et', 'Continue with Apple', 'Mit Apple fortfahren', 'Continuar con Apple'),
                  height: 52,
                  borderRadius: const BorderRadius.all(Radius.circular(14)),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      _t('ya da e-posta ile', 'or with email', 'oder mit E-Mail', 'o con correo electrónico'),
                      style: TextStyle(
                        color: AppTheme.mediumGray,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                ],
              ),
              const SizedBox(height: 18),
            ],
            _field(
              controller: _emailController,
              hint: _t('E-posta', 'Email', 'E-Mail', 'Correo electrónico'),
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                final value = (v ?? '').trim();
                if (value.isEmpty) {
                  return _t('E-posta gerekli', 'Email is required', 'E-Mail ist erforderlich', 'El correo es obligatorio');
                }
                if (!value.contains('@') || !value.contains('.')) {
                  return _t(
                      'Geçerli bir e-posta yaz', 'Enter a valid email address', 'Gib eine gültige E-Mail-Adresse ein', 'Escribe un correo válido');
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _field(
              controller: _passwordController,
              hint: _t('Şifre', 'Password', 'Passwort', 'Contraseña'),
              icon: Icons.lock_outline_rounded,
              obscure: _obscurePassword,
              validator: (v) => (v ?? '').isEmpty
                  ? _t('Şifre gerekli', 'Password is required', 'Passwort ist erforderlich', 'La contraseña es obligatoria')
                  : null,
              suffix: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.mediumGray,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              onSubmitted: (_) => _login(),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _busy ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _t('Giriş Yap', 'Sign In', 'Anmelden', 'Iniciar sesión'),
                        style: const TextStyle(
                            fontSize: 16.5, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _t('Hesabın yok mu?', "Don't have an account?", 'Noch kein Konto?', '¿No tienes cuenta?'),
                  style:
                      const TextStyle(color: AppTheme.mediumGray, fontSize: 14),
                ),
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen()),
                          ),
                  child: Text(
                    _t('Kayıt ol', 'Sign up', 'Registrieren', 'Regístrate'),
                    style: const TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
    void Function(String)? onSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      style: const TextStyle(fontSize: 15.5, color: AppTheme.darkGray),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.mediumGray, size: 21),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppTheme.lightGray,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.6),
        ),
      ),
    );
  }
}
