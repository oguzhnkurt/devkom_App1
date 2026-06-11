import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/animated_tech_background.dart';
import '../../widgets/permission_sheet.dart';
import '../../services/permission_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import '../role_based_home_screen.dart';
import 'register_screen.dart';
import 'dart:math' as math;
import '../../utils/app_localizations.dart';
import '../../widgets/apple_sign_in_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _glowController;
  late AnimationController _logoController;
  late AnimationController _borderController;
  late Animation<double> _glowAnimation;
  late Animation<double> _logoRotation;
  late Animation<Color?> _borderColorAnimation1;
  late Animation<Color?> _borderColorAnimation2;

  @override
  void initState() {
    super.initState();

    // Glow animation
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Logo rotation
    _logoController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _logoRotation = Tween<double>(begin: 0, end: 2 * math.pi).animate(_logoController);

    // Border color animation (turquoise to purple)
    _borderController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _borderColorAnimation1 = ColorTween(
      begin: const Color(0xFF00D9FF), // Turquoise
      end: const Color(0xFF9D4EDD),   // Purple
    ).animate(CurvedAnimation(
      parent: _borderController,
      curve: Curves.easeInOut,
    ));

    _borderColorAnimation2 = ColorTween(
      begin: const Color(0xFF9D4EDD), // Purple
      end: const Color(0xFF00D9FF),   // Turquoise
    ).animate(CurvedAnimation(
      parent: _borderController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _glowController.dispose();
    _logoController.dispose();
    _borderController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      print('❌ _login: Form validation failed');
      return;
    }

    print('🔐 _login: Starting login process...');
    print('📧 Email: ${_emailController.text.trim()}');

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    print('🔐 _login: Login result = $success');

    if (!mounted) return;

    if (success && authProvider.currentUser != null) {
      print('✅ _login: Login successful! User: ${authProvider.currentUser!.displayName}');
      // Show permission sheet based on user role (only if not granted yet)
      await _showPermissionSheetIfNeeded(authProvider.currentUser!.role);

      // Navigate directly to home screen
      if (mounted) {
        // Remove all previous routes and push home screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const RoleBasedHomeScreen(),
          ),
          (route) => false, // Remove all routes
        );
      }
    } else if (authProvider.errorMessage != null) {
      print('❌ _login: Error - ${authProvider.errorMessage}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Show permission sheet with role-specific permissions (only if needed)
  Future<void> _showPermissionSheetIfNeeded(UserRole role) async {
    List<AppPermission> permissions = [];

    // Define permissions based on role
    switch (role) {
      case UserRole.student:
        permissions = [AppPermission.notification];
        break;
      case UserRole.parent:
        permissions = [AppPermission.notification, AppPermission.camera];
        break;
      case UserRole.teacher:
        permissions = [AppPermission.notification, AppPermission.photos];
        break;
      case UserRole.visitor:
        permissions = [AppPermission.notification];
        break;
      case UserRole.admin:
        permissions = [AppPermission.notification, AppPermission.photos];
        break;
    }

    if (permissions.isEmpty) return;

    // Check if permission sheet was already shown
    final prefs = await SharedPreferences.getInstance();
    final alreadyShown = prefs.getBool('permission_sheet_shown') ?? false;
    if (alreadyShown) return;
    await prefs.setBool('permission_sheet_shown', true);

    // Show permission sheet
    await PermissionSheet.show(
      context,
      permissions: permissions,
      onComplete: () async {},
      canSkip: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: AnimatedTechBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: AnimatedBuilder(
                animation: Listenable.merge([_glowAnimation, _borderController]),
                builder: (context, child) {
                  return Container(
                    constraints: const BoxConstraints(maxWidth: 450),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        // Çok parlak turkuaz glow
                        BoxShadow(
                          color: _borderColorAnimation1.value!.withOpacity(0.8 + _glowAnimation.value * 0.2),
                          blurRadius: 60 + _glowAnimation.value * 40,
                          spreadRadius: 10 + _glowAnimation.value * 15,
                        ),
                        // Çok parlak mor glow
                        BoxShadow(
                          color: _borderColorAnimation2.value!.withOpacity(0.7 + _glowAnimation.value * 0.3),
                          blurRadius: 50 + _glowAnimation.value * 30,
                          spreadRadius: 8 + _glowAnimation.value * 12,
                        ),
                        // Ekstra parlak iç glow
                        BoxShadow(
                          color: _borderColorAnimation1.value!.withOpacity(0.9),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        // Parlak gradient border
                        border: Border.all(
                          width: 4,
                          color: Colors.transparent,
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _borderColorAnimation1.value!.withOpacity(0.9),
                            _borderColorAnimation2.value!.withOpacity(0.9),
                            _borderColorAnimation1.value!.withOpacity(0.9),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: _borderColorAnimation1.value!.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: -5,
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Animated Logo with rotating glow
                                    AnimatedBuilder(
                                      animation: _logoController,
                                      builder: (context, child) {
                                        return Transform.scale(
                                          scale: 1.0 + math.sin(_glowAnimation.value * math.pi) * 0.05,
                                          child: Container(
                                            height: 150,
                                            padding: const EdgeInsets.all(20),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                // Rotating gradient glow
                                                Transform.rotate(
                                                  angle: _logoRotation.value,
                                                  child: Container(
                                                    width: 140,
                                                    height: 140,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      gradient: SweepGradient(
                                                        colors: [
                                                          Colors.transparent,
                                                          _borderColorAnimation1.value!.withOpacity(0.6),
                                                          _borderColorAnimation2.value!.withOpacity(0.6),
                                                          Colors.transparent,
                                                        ],
                                                        stops: const [0.0, 0.25, 0.75, 1.0],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                // Static glow ring
                                                Container(
                                                  width: 130,
                                                  height: 130,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: _borderColorAnimation1.value!.withOpacity(0.3),
                                                        blurRadius: 30,
                                                        spreadRadius: 10,
                                                      ),
                                                      BoxShadow(
                                                        color: _borderColorAnimation2.value!.withOpacity(0.3),
                                                        blurRadius: 20,
                                                        spreadRadius: 5,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Logo container
                                                Container(
                                                  width: 100,
                                                  height: 100,
                                                  padding: const EdgeInsets.all(15),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: _borderColorAnimation1.value!.withOpacity(0.4),
                                                        blurRadius: 20,
                                                        spreadRadius: 2,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Image.asset(
                                                    'assets/images/logo.png',
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 24),

                                    // Title with gradient
                                    ShaderMask(
                                      shaderCallback: (bounds) => LinearGradient(
                                        colors: [
                                          _borderColorAnimation1.value!,
                                          _borderColorAnimation2.value!,
                                        ],
                                      ).createShader(bounds),
                                      child: Text(
                                        loc.login,
                                        style: theme.textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      loc.softwareRoboticsEducation,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 32),

                                    // Email Field with animated border
                                    _buildGlowingTextField(
                                      controller: _emailController,
                                      labelText: loc.email,
                                      prefixIcon: Icons.email_outlined,
                                      hintText: loc.emailHint,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return loc.pleaseEnterEmail;
                                        }
                                        if (!value.contains('@')) {
                                          return loc.enterValidEmail;
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),

                                    // Password Field with animated border
                                    _buildGlowingTextField(
                                      controller: _passwordController,
                                      labelText: loc.password,
                                      prefixIcon: Icons.lock_outlined,
                                      obscureText: _obscurePassword,
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (_) => _login(),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return loc.pleaseEnterPassword;
                                        }
                                        if (value.length < 6) {
                                          return loc.passwordMinLength;
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 24),

                                    // Login Button with gradient
                                    Consumer<AuthProvider>(
                                      builder: (context, authProvider, _) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            gradient: LinearGradient(
                                              colors: [
                                                _borderColorAnimation1.value!,
                                                _borderColorAnimation2.value!,
                                              ],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: _borderColorAnimation1.value!.withOpacity(0.5),
                                                blurRadius: 20,
                                                spreadRadius: 2,
                                                offset: const Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: ElevatedButton(
                                            onPressed: authProvider.isLoading ? null : _login,
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                              backgroundColor: Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: authProvider.isLoading
                                                ? const SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : Text(
                                                    loc.login,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 16),

                                    // Register Link
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(loc.noAccount),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => const RegisterScreen(),
                                              ),
                                            );
                                          },
                                          child: ShaderMask(
                                            shaderCallback: (bounds) => LinearGradient(
                                              colors: [
                                                _borderColorAnimation1.value!,
                                                _borderColorAnimation2.value!,
                                              ],
                                            ).createShader(bounds),
                                            child: Text(
                                              loc.register,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlowingTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    String? hintText,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    Widget? suffixIcon,
    void Function(String)? onFieldSubmitted,
    String? Function(String?)? validator,
  }) {
    return AnimatedBuilder(
      animation: Listenable.merge([_glowAnimation, _borderController]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _borderColorAnimation1.value!.withOpacity(0.2 + _glowAnimation.value * 0.2),
                blurRadius: 15 + _glowAnimation.value * 10,
                spreadRadius: 1 + _glowAnimation.value * 3,
              ),
              BoxShadow(
                color: _borderColorAnimation2.value!.withOpacity(0.15 + _glowAnimation.value * 0.15),
                blurRadius: 10 + _glowAnimation.value * 8,
                spreadRadius: 1 + _glowAnimation.value * 2,
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: labelText,
              prefixIcon: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    _borderColorAnimation1.value!,
                    _borderColorAnimation2.value!,
                  ],
                ).createShader(bounds),
                child: Icon(prefixIcon, color: Colors.white),
              ),
              suffixIcon: suffixIcon,
              hintText: hintText,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _borderColorAnimation1.value!.withOpacity(0.3),
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _borderColorAnimation1.value!.withOpacity(0.4 + _glowAnimation.value * 0.3),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _borderColorAnimation1.value!,
                  width: 2.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2.5,
                ),
              ),
            ),
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            obscureText: obscureText,
            onFieldSubmitted: onFieldSubmitted,
            validator: validator,
          ),
        );
      },
    );
  }
}
