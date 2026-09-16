import 'package:flutter/material.dart';

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


  /// Uygulamanin tek yazi ailesi. Fontlar `assets/fonts/` altinda paketli.
  ///
  /// ONCEDEN: tum stiller `google_fonts` uzerinden geliyordu ve bu paket
  /// dosyalari CALISMA ANINDA internetten cekiyor. Ilk acilista (ya da
  /// internet yokken) indirme bitene kadar Flutter varsayilan Roboto'ya
  /// dusuyordu: basliklar ince, yuvarlak hatlar duz, "kalin olmasi gereken
  /// yerler kalin degil" goruntusu tam olarak buydu. Artik dort agirlik
  /// (400/600/700/800) uygulamayla birlikte geliyor, ilk kareden itibaren
  /// dogru font ciziliyor.
  static const String fontFamily = 'Nunito';

  static TextStyle _f({
    required double fontSize,
    required FontWeight fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Sayilar icin: XP, skor, seri, seviye, fiyat.
  ///
  /// `tabularFigures` olmadan animasyonlu sayaclarda rakam genislikleri
  /// degistigi icin metin titriyor. Sayilarda agirlik 800, harflerde degil —
  /// Duolingo/Mimo tipi "kalin rakam, sakin metin" kontrasti buradan geliyor.
  static TextStyle number({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w800,
    Color? color,
    double letterSpacing = -0.5,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: 1.1,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  /// Turkce metinlerde `ğ ş ç` alt uzantilari ile `İ` noktasi 1.2 satir
  /// yuksekliginde carpisiyor; taban satir yuksekligi bu yuzden Ingilizce
  /// olceklerden bir tik yuksek.
  static TextTheme _baseTextTheme() {
    return TextTheme(
      displayLarge: _f(fontSize: 40, fontWeight: FontWeight.w800, color: darkGray, letterSpacing: -0.5, height: 1.10),
      displayMedium: _f(fontSize: 32, fontWeight: FontWeight.w800, color: darkGray, letterSpacing: -0.25, height: 1.15),
      displaySmall: _f(fontSize: 28, fontWeight: FontWeight.w800, color: darkGray, letterSpacing: -0.25, height: 1.18),
      headlineLarge: _f(fontSize: 28, fontWeight: FontWeight.w700, color: darkGray, letterSpacing: -0.25, height: 1.20),
      headlineMedium: _f(fontSize: 24, fontWeight: FontWeight.w700, color: darkGray, height: 1.25),
      headlineSmall: _f(fontSize: 21, fontWeight: FontWeight.w700, color: darkGray, height: 1.28),
      titleLarge: _f(fontSize: 20, fontWeight: FontWeight.w700, color: darkGray, height: 1.30),
      titleMedium: _f(fontSize: 17, fontWeight: FontWeight.w600, color: darkGray, letterSpacing: 0.1, height: 1.35),
      titleSmall: _f(fontSize: 15, fontWeight: FontWeight.w600, color: darkGray, letterSpacing: 0.1, height: 1.35),
      bodyLarge: _f(fontSize: 16, fontWeight: FontWeight.w400, color: darkGray, letterSpacing: 0.15, height: 1.50),
      bodyMedium: _f(fontSize: 14, fontWeight: FontWeight.w400, color: darkGray, letterSpacing: 0.15, height: 1.45),
      bodySmall: _f(fontSize: 12.5, fontWeight: FontWeight.w400, color: mediumGray, letterSpacing: 0.2, height: 1.45),
      labelLarge: _f(fontSize: 15, fontWeight: FontWeight.w700, color: darkGray, letterSpacing: 0.5, height: 1.20),
      labelMedium: _f(fontSize: 13, fontWeight: FontWeight.w600, color: darkGray, letterSpacing: 0.4, height: 1.30),
      labelSmall: _f(fontSize: 11, fontWeight: FontWeight.w500, color: mediumGray, letterSpacing: 0.4, height: 1.40),
    );
  }

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

        shadow: Colors.black.withValues(alpha: 0.15),
      ),

      // Text theme with Nunito font (SF Pro Rounded alternative)
      textTheme: _baseTextTheme(),

      // Scaffold background
      scaffoldBackgroundColor: lightGray,

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        // 1.2 harf araligi Turkce basliklarda kelimeleri dagitiyordu; ayrica
        // baslik agirligi govde metninden net ayrilsin diye 800'e cikti.
        titleTextStyle: _f(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: white,
          letterSpacing: 0,
        ),
        iconTheme: const IconThemeData(
          color: white,
          size: 24,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
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
          shadowColor: Colors.black.withValues(alpha: 0.2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: _f(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
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
          textStyle: _f(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
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
          textStyle: _f(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
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
          textStyle: _f(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
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
          borderSide: BorderSide(color: mediumGray.withValues(alpha: 0.3), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: mediumGray.withValues(alpha: 0.3), width: 1),
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
        labelStyle: _f(
          fontSize: 14,
          color: mediumGray,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: _f(
          fontSize: 14,
          color: primaryBlue,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: _f(
          fontSize: 14,
          color: mediumGray.withValues(alpha: 0.6),
          fontWeight: FontWeight.w400,
        ),
        helperStyle: _f(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: mediumGray,
        ),
        errorStyle: _f(
          fontSize: 12,
          fontWeight: FontWeight.w500,
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
        indicatorColor: primaryBlue.withValues(alpha: 0.15),
        elevation: 3,
        labelTextStyle: WidgetStateProperty.all(
          _f(
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
        selectedLabelStyle: _f(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: _f(
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
      dialogTheme: DialogThemeData(
        backgroundColor: white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: _f(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkGray,
        ),
        contentTextStyle: _f(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: darkGray,
        ),
      ),

      // SnackBar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkGray,
        contentTextStyle: _f(
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
        selectedColor: primaryBlue.withValues(alpha: 0.15),
        secondarySelectedColor: accentTeal.withValues(alpha: 0.15),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: _f(
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
          if (states.contains(WidgetState.selected)) return primaryBlue.withValues(alpha: 0.5);
          return mediumGray.withValues(alpha: 0.3);
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
        color: mediumGray.withValues(alpha: 0.2),
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
        selectedTileColor: primaryBlue.withValues(alpha: 0.1),
        iconColor: mediumGray,
        textColor: darkGray,
        titleTextStyle: _f(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: darkGray,
        ),
        subtitleTextStyle: _f(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: mediumGray,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Tab bar theme
      tabBarTheme: TabBarThemeData(
        labelColor: primaryBlue,
        unselectedLabelColor: mediumGray,
        indicatorColor: primaryBlue,
        labelStyle: _f(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: _f(
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

      textTheme: _baseTextTheme().apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
    );
  }
}
