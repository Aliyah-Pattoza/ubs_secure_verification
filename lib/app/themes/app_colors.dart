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
}
