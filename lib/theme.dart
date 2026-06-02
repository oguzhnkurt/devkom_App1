import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modern, professional Material 3 theme for Devkom App
/// Corporate blue, white, and gray color scheme
class AppTheme {
  // Corporate Color Palette - Modern Blue, White, Gray
  static const Color primaryBlue = Color(0xFF1565C0); // Strong blue
  static const Color lightBlue = Color(0xFF42A5F5); // Lighter blue
  static const Color darkBlue = Color(0xFF0D47A1); // Dark blue for depth

  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF5F5F5); // Very light gray background
  static const Color mediumGray = Color(0xFF9E9E9E); // Medium gray for text
  static const Color darkGray = Color(0xFF424242); // Dark gray for primary text

  static const Color accentTeal = Color(0xFF26C6DA); // Teal accent
  static const Color accentYellow = Color(0xFFFFD700); // Gold/Yellow accent
  static const Color successGreen = Color(0xFF66BB6A); // Success states
  static const Color warningOrange = Color(0xFFFF9800); // Warnings
  static const Color errorRed = Color(0xFFEF5350); // Errors

  // Light theme
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color scheme
      colorScheme: ColorScheme.light(
        primary: primaryBlue,
        onPrimary: white,
        primaryContainer: lightBlue,
        onPrimaryContainer: darkBlue,

        secondary: accentTeal,
        onSecondary: white,
        secondaryContainer: Color(0xFFB2EBF2),
        onSecondaryContainer: Color(0xFF006064),

        tertiary: successGreen,
        onTertiary: white,

        error: errorRed,
        onError: white,

        surface: white,
        onSurface: darkGray,
        surfaceContainerLowest: white,
        surfaceContainerLow: lightGray,
        surfaceContainer: Color(0xFFEEEEEE),
        surfaceContainerHigh: Color(0xFFE0E0E0),
        surfaceContainerHighest: Color(0xFFBDBDBD),

        outline: mediumGray,
        outlineVariant: Color(0xFFE0E0E0),

        shadow: Colors.black.withOpacity(0.15),
      ),

      // Text theme with Nunito font (SF Pro Rounded alternative)
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        // Display styles - for large, prominent text
        displayLarge: GoogleFonts.nunito(
          fontSize: 57,
          fontWeight: FontWeight.w700,
          color: darkGray,
          letterSpacing: -0.25,
        ),
        displayMedium: GoogleFonts.nunito(
          fontSize: 45,
          fontWeight: FontWeight.w700,
          color: darkGray,
        ),
        displaySmall: GoogleFonts.nunito(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          color: darkGray,
        ),

        // Headline styles - for section headers
        headlineLarge: GoogleFonts.nunito(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: darkGray,
        ),
        headlineMedium: GoogleFonts.nunito(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: darkGray,
        ),
        headlineSmall: GoogleFonts.nunito(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: darkGray,
        ),

        // Title styles - for card titles and smaller headers
        titleLarge: GoogleFonts.nunito(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: darkGray,
          letterSpacing: 0,
        ),
        titleMedium: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: darkGray,
          letterSpacing: 0.15,
        ),
        titleSmall: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: darkGray,
          letterSpacing: 0.1,
        ),

        // Body styles - for main content
        bodyLarge: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: darkGray,
          letterSpacing: 0.5,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: darkGray,
          letterSpacing: 0.25,
        ),
        bodySmall: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: mediumGray,
          letterSpacing: 0.4,
        ),

        // Label styles - for buttons and labels
        labelLarge: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: darkGray,
          letterSpacing: 0.1,
        ),
        labelMedium: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: darkGray,
          letterSpacing: 0.5,
        ),
        labelSmall: GoogleFonts.nunito(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: mediumGray,
          letterSpacing: 0.5,
        ),
      ),

      // Scaffold background
      scaffoldBackgroundColor: lightGray,

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: white,
          letterSpacing: 1.2,
        ),
        iconTheme: const IconThemeData(
          color: white,
          size: 24,
        ),
      ),

      // Card theme
      cardTheme: CardTheme(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: white,
        margin: const EdgeInsets.all(8),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: white,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Filled button theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: const BorderSide(color: primaryBlue, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

        // Border styles
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: mediumGray.withOpacity(0.3), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: mediumGray.withOpacity(0.3), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),

        // Label and hint styles
        labelStyle: GoogleFonts.nunito(
          fontSize: 14,
          color: mediumGray,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: GoogleFonts.nunito(
          fontSize: 14,
          color: primaryBlue,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: GoogleFonts.nunito(
          fontSize: 14,
          color: mediumGray.withOpacity(0.6),
          fontWeight: FontWeight.w400,
        ),
        helperStyle: GoogleFonts.nunito(
          fontSize: 12,
          color: mediumGray,
        ),
        errorStyle: GoogleFonts.nunito(
          fontSize: 12,
          color: errorRed,
        ),
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentTeal,
        foregroundColor: white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Navigation bar theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: white,
        indicatorColor: primaryBlue.withOpacity(0.15),
        elevation: 3,
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: primaryBlue,
        unselectedItemColor: mediumGray,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Drawer theme
      drawerTheme: DrawerThemeData(
        backgroundColor: white,
        elevation: 16,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),

      // Dialog theme
      dialogTheme: DialogTheme(
        backgroundColor: white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkGray,
        ),
        contentTextStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: darkGray,
        ),
      ),

      // SnackBar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkGray,
        contentTextStyle: GoogleFonts.nunito(
          fontSize: 14,
          color: white,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 6,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: lightGray,
        deleteIconColor: mediumGray,
        selectedColor: primaryBlue.withOpacity(0.15),
        secondarySelectedColor: accentTeal.withOpacity(0.15),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: darkGray,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryBlue,
        linearTrackColor: lightGray,
        circularTrackColor: lightGray,
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryBlue;
          return mediumGray;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryBlue.withOpacity(0.5);
          return mediumGray.withOpacity(0.3);
        }),
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryBlue;
          return white;
        }),
        checkColor: WidgetStateProperty.all(white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryBlue;
          return mediumGray;
        }),
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: mediumGray.withOpacity(0.2),
        thickness: 1,
        space: 16,
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: darkGray,
        size: 24,
      ),

      // List tile theme
      listTileTheme: ListTileThemeData(
        tileColor: white,
        selectedTileColor: primaryBlue.withOpacity(0.1),
        iconColor: mediumGray,
        textColor: darkGray,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: darkGray,
        ),
        subtitleTextStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: mediumGray,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Tab bar theme
      tabBarTheme: TabBarTheme(
        labelColor: primaryBlue,
        unselectedLabelColor: mediumGray,
        indicatorColor: primaryBlue,
        labelStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Bottom sheet theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }

  // Dark theme (optional - keeping it for future use)
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: ColorScheme.dark(
        primary: lightBlue,
        onPrimary: darkGray,
        secondary: accentTeal,
        onSecondary: darkGray,
        surface: Color(0xFF1E1E1E),
        onSurface: white,
        error: errorRed,
        onError: white,
      ),

      textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme),
      scaffoldBackgroundColor: const Color(0xFF121212),
    );
  }
}
