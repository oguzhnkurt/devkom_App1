import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../theme.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import '../settings/settings_screen.dart';
import '../../utils/app_localizations.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggingOut = false;
  bool _isDeletingAccount = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
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

          if (user == null) {
            // Visitor view - show login/register options
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Welcome icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppTheme.primaryBlue, AppTheme.accentTeal],
                        ),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Welcome text
                    Text(
                      loc.welcome,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      loc.loginToAccessFeatures,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Login button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.login, color: Colors.white),
                            const SizedBox(width: 12),
                            Text(
                              loc.login,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Register button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppTheme.primaryBlue, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_add, color: AppTheme.primaryBlue),
                            const SizedBox(width: 12),
                            Text(
                              loc.register,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header Section with Gradient
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.darkBlue,
                        AppTheme.darkBlue.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      // Profile Avatar
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.accentTeal,
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: AppTheme.accentTeal.withValues(alpha: 0.2),
                          child: Text(
                            _getInitials(user.displayName),
                            style: theme.textTheme.headlineLarge?.copyWith(
                              color: AppTheme.accentTeal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // User Name
                      Text(
                        user.displayName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Role Badge
                      _buildRoleBadge(user.role, theme),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),

                // Profile Information Cards
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Email Card
                      _buildInfoCard(
                        context: context,
                        icon: Icons.email_outlined,
                        title: loc.email,
                        value: user.email,
                        iconColor: AppTheme.accentTeal,
                      ),
                      const SizedBox(height: 12),

                      // Role Card
                      _buildInfoCard(
                        context: context,
                        icon: Icons.badge_outlined,
                        title: loc.role,
                        value: user.roleDisplayName,
                        iconColor: _getRoleColor(user.role),
                      ),
                      const SizedBox(height: 12),

                      // Member Since Card
                      _buildInfoCard(
                        context: context,
                        icon: Icons.calendar_today_outlined,
                        title: loc.memberSince,
                        value: _formatDate(user.createdAt),
                        iconColor: AppTheme.lightGray,
                      ),
                      const SizedBox(height: 12),

                      // Last Login Card
                      if (user.lastLoginAt != null)
                        _buildInfoCard(
                          context: context,
                          icon: Icons.access_time_outlined,
                          title: loc.lastLogin,
                          value: _formatDate(user.lastLoginAt!),
                          iconColor: AppTheme.lightGray,
                        ),
                      const SizedBox(height: 12),

                      const SizedBox(height: 32),

                      // Settings Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.settings),
                          label: Text(loc.settings),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Logout Button for authenticated users
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoggingOut
                              ? null
                              : () => _handleLogout(context, authProvider),
                          icon: _isLoggingOut
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.logout),
                          label: Text(
                            _isLoggingOut ? loc.loggingOut : loc.logout,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Delete Account Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isDeletingAccount
                              ? null
                              : () => _handleDeleteAccount(context, authProvider),
                          icon: _isDeletingAccount
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.delete_forever, color: Colors.red),
                          label: Text(
                            _isDeletingAccount ? 'Siliniyor...' : 'Hesabı Sil',
                            style: const TextStyle(color: Colors.red),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
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

  Widget _buildRoleBadge(UserRole role, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: _getRoleColor(role),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getRoleColor(role).withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getRoleIcon(role),
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            _getRoleDisplayName(role, context),
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightGray,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  String _getInitials(String name) {
    List<String> nameParts = name.trim().split(' ');
    if (nameParts.isEmpty) return '?';

    if (nameParts.length == 1) {
      return nameParts[0][0].toUpperCase();
    }

    return (nameParts[0][0] + nameParts[nameParts.length - 1][0]).toUpperCase();
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.student:
        return Colors.green;
      case UserRole.admin:
        return Colors.purple;
      case UserRole.parent:
        return Colors.blue;
      case UserRole.teacher:
        return const Color(0xFF4CAF50);
      case UserRole.visitor:
        return const Color(0xFFFF6B6B); // Orange/red to match purpose selection
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.student:
        return Icons.school;
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.parent:
        return Icons.family_restroom;
      case UserRole.teacher:
        return Icons.person_outline;
      case UserRole.visitor:
        return Icons.explore_rounded; // Match purpose selection screen
    }
  }

  String _getRoleDisplayName(UserRole role, BuildContext context) {
    final loc = AppLocalizations.of(context);
    switch (role) {
      case UserRole.student:
        return loc.student;
      case UserRole.admin:
        return loc.admin;
      case UserRole.parent:
        return loc.parent;
      case UserRole.teacher:
        return loc.teacher;
      case UserRole.visitor:
        return 'Ziyaretçi'; // Visitor role display name
    }
  }

  String _formatDate(DateTime date) {
    final loc = AppLocalizations.of(context);
    final locale = loc.locale.languageCode;

    // Use DateFormat with the appropriate locale
    if (locale == 'en') {
      // English: "November 19, 2025"
      return DateFormat('MMMM d, y', 'en').format(date);
    } else {
      // Turkish: "19 Kasım 2025"
      return DateFormat('d MMMM y', 'tr').format(date);
    }
  }


  Future<void> _handleDeleteAccount(BuildContext context, AuthProvider authProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Hesabı Sil'),
        content: const Text(
          'Hesabınız kalıcı olarak silinecek ve bu işlem geri alınamaz. Emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hesabı Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isDeletingAccount = true);
      try {
        await authProvider.deleteAccount();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isDeletingAccount = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hesap silinemedi: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleLogout(BuildContext context, AuthProvider authProvider) async {
    // Show confirmation dialog
    final loc = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(loc.logout),
        content: Text(loc.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(loc.logout),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _isLoggingOut = true;
      });

      try {
        // Call signOut
        await authProvider.signOut();

        // Wait a tiny bit for notifyListeners to propagate
        await Future.delayed(const Duration(milliseconds: 100));

        // Navigate directly to LoginScreen and clear all routes
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false, // Remove all previous routes
          );
        }
      } catch (e) {
        // Reset loading state on error
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
}
