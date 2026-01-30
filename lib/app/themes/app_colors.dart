import 'package:flutter/material.dart';

class AppColors {
  // ============================================
  // PRIMARY COLORS - Navy Blue (UBS Brand)
  // ============================================
  static const Color primary = Color(0xFF1E3A5F);
  static const Color primaryDark = Color(0xFF152A45);
  static const Color primaryLight = Color(0xFF2A4A6F);

  // ============================================
  // SECONDARY COLORS - Gold (UBS Brand)
  // ============================================
  static const Color secondary = Color(0xFFD4A574);
  static const Color secondaryLight = Color(0xFFE8C9A0);
  static const Color secondaryDark = Color(0xFFB8956A);

  // Alias untuk kemudahan
  static const Color gold = Color(0xFFD4A574);
  static const Color goldLight = Color(0xFFE8C9A0);
  static const Color goldDark = Color(0xFFB8956A);

  // ============================================
  // BACKGROUND COLORS
  // ============================================
  static const Color background = Color(0xFFF5EFE6);
  static const Color backgroundLight = Color(0xFFFAF7F2);
  static const Color backgroundCard = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF1E3A5F);

  // ============================================
  // TEXT COLORS
  // ============================================
  static const Color textPrimary = Color(0xFF1E3A5F);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1E3A5F);

  // ============================================
  // STATUS COLORS
  // ============================================
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ============================================
  // GRADIENTS
  // ============================================
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8C9A0), Color(0xFFD4A574), Color(0xFFB8956A)],
  );

  static const LinearGradient navyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1E3A5F), Color(0xFF152A45)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF5EFE6), Color(0xFFFFFFFF)],
  );

  // ============================================
  // SHADOWS
  // ============================================
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> goldShadow = [
    BoxShadow(
      color: const Color(0xFFD4A574).withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}

/// App Theme dengan font yang sudah Anda download
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.gold,
        surface: AppColors.backgroundCard,
        background: AppColors.background,
        error: AppColors.error,
        onPrimary: AppColors.textLight,
        onSecondary: AppColors.textDark,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: AppColors.textLight,
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.primary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),


      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.textDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.gold,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.textMuted.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.gold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: TextStyle(
          color: AppColors.textMuted.withOpacity(0.6),
          fontSize: 14,
          fontFamily: 'Inter',
        ),
        errorStyle: const TextStyle(
          color: AppColors.error,
          fontSize: 12,
          fontFamily: 'Inter',
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontFamily: 'Inter',
        ),
      ),

      // Text Theme (menggunakan font Anda)
      textTheme: const TextTheme(
        // Display - Menggunakan Marcellus untuk heading yang elegan
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          fontFamily: 'Marcellus',
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          fontFamily: 'Marcellus',
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          fontFamily: 'Marcellus',
        ),

        // Headline - Menggunakan Inter untuk heading utama
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          fontFamily: 'Inter',
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          fontFamily: 'Inter',
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          fontFamily: 'Inter',
        ),

        // Title
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          fontFamily: 'Inter',
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          fontFamily: 'Inter',
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          fontFamily: 'Inter',
        ),

        // Body
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.textSecondary,
          fontFamily: 'Inter',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
          fontFamily: 'Inter',
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
          fontFamily: 'Inter',
        ),

        // Label
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          fontFamily: 'Inter',
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          fontFamily: 'Inter',
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          fontFamily: 'Inter',
        ),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: AppColors.textMuted.withOpacity(0.2),
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.primary,
        size: 24,
      ),

      // Icon Button Theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.primary,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.textDark,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.textMuted,
        elevation: 8,
      ),

      // Navigation Bar Theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.gold.withOpacity(0.2),
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
            fontFamily: 'Inter',
          ),
        ),
      ),

      // Badge Theme
      badgeTheme: const BadgeThemeData(
        backgroundColor: AppColors.error,
        textColor: Colors.white,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        linearTrackColor: AppColors.backgroundLight,
        color: AppColors.gold,
      ),

      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primary,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontFamily: 'Inter',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),

      // Font Family default
      fontFamily: 'Inter',
    );
  }

  // Dark Theme (opsional)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.primaryDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        secondary: AppColors.goldLight,
        surface: AppColors.primaryLight,
        background: AppColors.primaryDark,
        error: AppColors.error,
        onPrimary: AppColors.textDark,
        onSecondary: AppColors.textDark,
      ),
      fontFamily: 'Inter',
      // Tambahkan konfigurasi lain untuk dark theme sesuai kebutuhan
    );
  }
}

/// Helper class untuk menggunakan font dengan mudah di seluruh aplikasi
class FontStyles {
  // Inter Font dengan berbagai weight
  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight = FontWeight.w400,
    Color? color = AppColors.textPrimary,
    double? height,
    TextDecoration? decoration,
    FontStyle? fontStyle,
  }) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      decoration: decoration,
      fontStyle: fontStyle,
    );
  }

  // Inter Italic
  static TextStyle interItalic({
    double? fontSize,
    FontWeight? fontWeight = FontWeight.w400,
    Color? color = AppColors.textPrimary,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      decoration: decoration,
      fontStyle: FontStyle.italic,
    );
  }

  // Marcellus Font (untuk heading elegan)
  static TextStyle marcellus({
    double? fontSize,
    FontWeight? fontWeight = FontWeight.w400,
    Color? color = AppColors.textPrimary,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: 'Marcellus',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      decoration: decoration,
    );
  }

  // Predefined styles untuk penggunaan umum
  static TextStyle get titleLarge => marcellus(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get titleMedium => inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get bodyLarge => inter(
    fontSize: 16,
    color: AppColors.textSecondary,
  );

  static TextStyle get bodyMedium => inter(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static TextStyle get caption => inter(
    fontSize: 12,
    color: AppColors.textMuted,
  );

  static TextStyle get button => inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );
}