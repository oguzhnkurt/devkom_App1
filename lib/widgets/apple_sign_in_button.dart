import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../services/auth_service.dart';

/// Apple Sign In Button Widget
/// Platform-aware button that shows only on iOS/macOS
class AppleSignInButton extends StatelessWidget {
  final VoidCallback? onSuccess;
  final Function(String)? onError;

  const AppleSignInButton({
    Key? key,
    this.onSuccess,
    this.onError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService().isAppleSignInAvailable(),
      builder: (context, snapshot) {
        // Apple Sign In mevcut değilse hiçbir şey gösterme
        if (snapshot.data != true) {
          return const SizedBox.shrink();
        }

        return SignInWithAppleButton(
          onPressed: () => _handleSignIn(context),
          text: 'Apple ile Giriş Yap',
          height: 50,
          style: SignInWithAppleButtonStyle.black,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        );
      },
    );
  }

  Future<void> _handleSignIn(BuildContext context) async {
    try {
      // Loading indicator göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Apple ile giriş yap
      final authService = AuthService();
      final user = await authService.signInWithApple();

      // Loading kapat
      Navigator.of(context).pop();

      debugPrint('✅ Apple Sign In başarılı: ${user.displayName}');

      // Başarı callback'i çağır
      if (onSuccess != null) {
        onSuccess!();
      }
    } catch (e) {
      // Loading kapat
      Navigator.of(context).pop();

      final errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('❌ Apple Sign In hatası: $errorMessage');

      // Hata callback'i çağır
      if (onError != null) {
        onError!(errorMessage);
      } else {
        // Varsayılan hata gösterimi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

/// Custom Apple Sign In Button (Manuel stil için)
class CustomAppleSignInButton extends StatelessWidget {
  final VoidCallback? onSuccess;
  final Function(String)? onError;
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const CustomAppleSignInButton({
    Key? key,
    this.onSuccess,
    this.onError,
    this.text = 'Apple ile Devam Et',
    this.backgroundColor = Colors.black,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService().isAppleSignInAvailable(),
      builder: (context, snapshot) {
        if (snapshot.data != true) {
          return const SizedBox.shrink();
        }

        return ElevatedButton.icon(
          onPressed: () => _handleSignIn(context),
          icon: const Icon(Icons.apple, size: 24),
          label: Text(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: textColor,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSignIn(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final authService = AuthService();
      final user = await authService.signInWithApple();

      Navigator.of(context).pop();

      if (onSuccess != null) {
        onSuccess!();
      }
    } catch (e) {
      Navigator.of(context).pop();

      final errorMessage = e.toString().replaceAll('Exception: ', '');

      if (onError != null) {
        onError!(errorMessage);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
