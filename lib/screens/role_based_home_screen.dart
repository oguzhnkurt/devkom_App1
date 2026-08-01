import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
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
class RoleBasedHomeScreen extends StatelessWidget {
  const RoleBasedHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;

        // Loading state
        if (authProvider.isLoading || user == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
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
}
