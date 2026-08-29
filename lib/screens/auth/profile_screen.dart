import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../models/user_progress_model.dart';
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

          final progress = authProvider.userProgress;

          return SingleChildScrollView(
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
                      _buildInfoGroup(context, user, loc),
                      const SizedBox(height: 20),
                      _buildActionsGroup(context, loc),
                      const SizedBox(height: 20),
                      _buildDangerZone(context, authProvider, progress),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.darkBlue, AppTheme.primaryBlue],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ince dekoratif parıltılar - abartısız, kurumsal his bozulmadan
          const Positioned(top: 16, left: 32, child: Opacity(opacity: 0.35, child: Text('✨', style: TextStyle(fontSize: 14)))),
          const Positioned(top: 40, right: 40, child: Opacity(opacity: 0.3, child: Text('✨', style: TextStyle(fontSize: 12)))),
          const Positioned(top: 10, right: 90, child: Opacity(opacity: 0.25, child: Text('✨', style: TextStyle(fontSize: 10)))),
          Column(
            children: [
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 3),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 6)),
                  ],
                ),
                child: CircleAvatar(
                  radius: 52,
                  backgroundColor: AppTheme.accentTeal.withValues(alpha: 0.25),
                  child: Text(
                    _getInitials(user.displayName),
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                user.displayName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildRoleBadge(user.role, theme),
                  if (user.isPro) ...[
                    const SizedBox(width: 8),
                    _buildProBadge(),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA000)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium, color: Colors.white, size: 16),
          SizedBox(width: 6),
          Text('PRO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5)),
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
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          children: [
            _buildStatItem(Icons.military_tech, 'Seviye', '$level', AppTheme.primaryBlue),
            _buildStatDivider(),
            _buildStatItem(Icons.bolt, 'XP', '$totalXP', AppTheme.warningOrange),
            _buildStatDivider(),
            _buildStatItem(Icons.monetization_on, 'Jeton', '$jeton', const Color(0xFFFFA000)),
            _buildStatDivider(),
            _buildStatItem(Icons.local_fire_department, 'Seri', '$streak', Colors.redAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildStatDivider() => Container(width: 1, height: 36, color: Colors.grey.shade200);

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  // ==========================================
  // BILGI GRUBU - tek kart icinde bolunmus satirlar (kurumsal liste hissi)
  // ==========================================
  Widget _buildInfoGroup(BuildContext context, UserModel user, AppLocalizations loc) {
    final rows = <_InfoRowData>[
      _InfoRowData(Icons.badge_outlined, loc.role, user.roleDisplayName, _getRoleColor(user.role)),
      _InfoRowData(Icons.calendar_today_outlined, loc.memberSince, _formatDate(user.createdAt), AppTheme.mediumGray),
      if (user.lastLoginAt != null)
        _InfoRowData(Icons.access_time_outlined, loc.lastLogin, _formatDate(user.lastLoginAt!), AppTheme.mediumGray),
    ];

    return _buildGroupCard(
      title: 'Hesap Bilgileri',
      children: List.generate(rows.length, (i) {
        final row = rows[i];
        return Column(
          children: [
            _buildInfoRow(row.icon, row.title, row.value, row.color),
            if (i != rows.length - 1) Divider(height: 1, color: Colors.grey.shade100, indent: 56),
          ],
        );
      }),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title, style: TextStyle(fontSize: 13.5, color: Colors.grey.shade700)),
          ),
          Text(value, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ==========================================
  // EYLEMLER GRUBU - Ayarlar + Cikis (notr, kurumsal)
  // ==========================================
  Widget _buildActionsGroup(BuildContext context, AppLocalizations loc) {
    return _buildGroupCard(
      title: 'Hesap İşlemleri',
      children: [
        _buildActionRow(
          icon: Icons.settings_outlined,
          label: loc.settings,
          color: AppTheme.primaryBlue,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
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
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: loading
                  ? Padding(
                      padding: const EdgeInsets.all(9),
                      child: CircularProgressIndicator(strokeWidth: 2, color: color),
                    )
                  : Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TEHLIKELI BOLGE - Hesap silme, acikca ayristirilmis
  // ==========================================
  Widget _buildDangerZone(BuildContext context, AuthProvider authProvider, UserProgress? progress) {
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
              Icon(Icons.warning_amber_rounded, color: Colors.red.shade400, size: 18),
              const SizedBox(width: 8),
              Text(
                'Tehlikeli Bölge',
                style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Hesabını silmek kalıcıdır. İlerlemen, jetonların ve rozetlerin geri getirilemez şekilde silinir.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isDeletingAccount ? null : () => _confirmDeleteAccount(context, authProvider, progress),
              icon: _isDeletingAccount
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
                  : const Icon(Icons.delete_forever, color: Colors.red, size: 18),
              label: Text(
                _isDeletingAccount ? 'Siliniyor...' : 'Hesabımı Sil',
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 0.4),
          ),
          const SizedBox(height: 4),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRoleBadge(UserRole role, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getRoleIcon(role), color: Colors.white, size: 15),
          const SizedBox(width: 6),
          Text(
            _getRoleDisplayName(role, context),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
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
          _handleLogout(context, Provider.of<AuthProvider>(context, listen: false));
        },
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, AuthProvider authProvider, UserProgress? progress) {
    final xp = progress?.totalXP ?? 0;
    final jeton = progress?.jetonBalance ?? 0;
    final badges = progress?.earnedBadgeIds.length ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _ConfirmSheet(
        dragHandleColor: Colors.grey.shade300,
        iconBackgroundColor: Colors.red.withValues(alpha: 0.1),
        icon: Icons.warning_amber_rounded,
        iconColor: Colors.red,
        title: 'Hesabını silmek üzeresin',
        message:
            '$xp XP, $jeton jeton ve $badges rozet dahil tüm ilerlemen kalıcı olarak silinecek. Bu işlem geri alınamaz.',
        cancelLabel: 'Vazgeç',
        confirmLabel: 'Evet, Hesabımı Sil',
        confirmColor: Colors.red,
        onConfirm: () {
          Navigator.pop(sheetContext);
          _handleDeleteAccount(context, authProvider);
        },
      ),
    );
  }

  Future<void> _handleDeleteAccount(BuildContext context, AuthProvider authProvider) async {
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

  Future<void> _handleLogout(BuildContext context, AuthProvider authProvider) async {
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

class _InfoRowData {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  const _InfoRowData(this.icon, this.title, this.value, this.color);
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
        borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: dragHandleColor, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: iconBackgroundColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 30),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, color: Colors.grey.shade600, height: 1.4),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(confirmLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
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
              child: Text(cancelLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
