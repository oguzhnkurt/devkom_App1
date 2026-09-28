import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/lang.dart';
import '../models/user_model.dart';
import 'student/student_home_screen.dart';
import 'roboakademi/roboakademi_parent_screen.dart';
import 'roboakademi/roboakademi_teacher_screen.dart';
// TODO: Parent/Teacher/Admin screens disabled during Firebase migration
// import 'parent/parent_home_screen.dart';
// import 'teacher/teacher_home_screen.dart';
// import 'admin/admin_dashboard_screen.dart';

/// Role-based home screen router
/// Redirects users to appropriate home screen based on their role
/// NOTE: Currently only Student role is supported (other roles redirect to student screen)
class RoleBasedHomeScreen extends StatefulWidget {
  const RoleBasedHomeScreen({super.key});

  @override
  State<RoleBasedHomeScreen> createState() => _RoleBasedHomeScreenState();
}

class _RoleBasedHomeScreenState extends State<RoleBasedHomeScreen> {
  /// Profil bu sureden sonra hala gelmediyse halka yerine cikis yolu
  /// olan bir ekran gosteriliyor.
  ///
  /// NEDEN SURE
  /// ----------
  /// Kullanici kayit olduktan sonra donen bir halkada KALIYORDU. Halka
  /// dogru bir ara durum ama SONSUZ bir ara durum degil: ag koptuysa,
  /// profil satiri olusmadiysa ya da oturum acilmadiysa o halka hicbir
  /// zaman bitmiyor ve cocugun elinde geri donecek bir sey kalmiyor.
  static const Duration _sabir = Duration(seconds: 12);

  Timer? _sayac;
  bool _sabirBitti = false;
  bool _yeniliyor = false;

  @override
  void initState() {
    super.initState();
    _sayaciKur();
  }

  void _sayaciKur() {
    _sayac?.cancel();
    _sabirBitti = false;
    _sayac = Timer(_sabir, () {
      if (mounted) setState(() => _sabirBitti = true);
    });
  }

  @override
  void dispose() {
    _sayac?.cancel();
    super.dispose();
  }

  String _t(String tr, String en, String de, String es) => AppLang.pick(
        Provider.of<SettingsProvider>(context, listen: false)
            .locale
            .languageCode,
        tr: tr,
        en: en,
        de: de,
        es: es,
      );

  Future<void> _tekrarDene() async {
    if (_yeniliyor) return;
    setState(() => _yeniliyor = true);
    try {
      await context.read<AuthProvider>().kullaniciyiTazele();
    } catch (e) {
      debugPrint('⚠️ Profil tazelenemedi: $e');
    }
    if (!mounted) return;
    setState(() => _yeniliyor = false);
    _sayaciKur();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;

        // YUKLENIYOR DURUMU YALNIZCA KULLANICI YOKKEN.
        //
        // BU BIR KIRMIZI EKRAN SEBEBIYDI. Burasi eskiden
        // `authProvider.isLoading` olduğunda da tam ekran bir halka
        // gösteriyordu. `isLoading`, hesap bağlama gibi ARKA PLANDAKİ
        // işlerde de true oluyor; o an bütün ev ekranı (sekmeler,
        // profil, açık alt sayfalar) ağaçtan kalkıyordu.
        //
        // Sonuç: çocuk "İlerlemeni kaydet → hesap oluştur" diyip
        // kaydete bastığında profil yok oluyor, bağlama bitince
        // ölü bir context'e dokunulup "Looking up a deactivated
        // widget's ancestor is unsafe" hatası alınıyor ve uygulama
        // ana sayfaya düşüyordu.
        //
        // İlk açılışta kullanıcı zaten null olduğu için halka yine
        // görünüyor; sonraki her yükleme sessizce arkada oluyor.
        if (user == null) {
          return _profilYok(context);
        }

        // RoboAkademi workshop parents get their dedicated tracking panel
        // (attendance, curriculum progress, points, payment status).
        if (user.isRoboAkademi && user.role == UserRole.parent) {
          return const RoboAkademiParentScreen();
        }

        // Teachers/admins get the simple RoboAkademi data-entry screen
        // (attendance, points, payment status for the workshop students).
        if (user.role == UserRole.teacher || user.role == UserRole.admin) {
          return const RoboAkademiTeacherScreen();
        }

        // Route based on user role
        // TODO: Currently all other roles redirect to StudentHomeScreen
        // Parent/Teacher/Admin screens are disabled during Firebase migration
        switch (user.role) {
          case UserRole.student:
            return const StudentHomeScreen();

          // case UserRole.parent:
          //   return const ParentHomeScreen();

          default:
            // All users get student home screen during migration
            return const StudentHomeScreen();
        }
      },
    );
  }

  /// Profil henuz yok: once halka, sabir bitince cikis yolu.
  Widget _profilYok(BuildContext context) {
    if (!_sabirBitti) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🐢', style: TextStyle(fontSize: 52)),
                const SizedBox(height: 16),
                Text(
                  _t('Profilin yüklenemedi', 'We could not load your profile',
                      'Dein Profil konnte nicht geladen werden',
                      'No hemos podido cargar tu perfil'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  _t(
                      'Hesabın oluşmuş olabilir. İnternetini kontrol edip '
                          'tekrar dene ya da çıkış yapıp giriş yap.',
                      'Your account may already exist. Check your internet '
                          'and try again, or sign out and sign in.',
                      'Dein Konto gibt es vielleicht schon. Prüfe dein '
                          'Internet und versuch es erneut, oder melde dich '
                          'ab und wieder an.',
                      'Puede que tu cuenta ya exista. Comprueba tu internet '
                          'e inténtalo de nuevo, o cierra sesión y vuelve a '
                          'entrar.'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, height: 1.35),
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: _yeniliyor ? null : _tekrarDene,
                  icon: _yeniliyor
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded),
                  label: Text(_t('Tekrar dene', 'Try again',
                      'Erneut versuchen', 'Inténtalo de nuevo')),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () =>
                      context.read<AuthProvider>().signOut(),
                  child: Text(_t('Çıkış yap', 'Sign out', 'Abmelden',
                      'Cerrar sesión')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
