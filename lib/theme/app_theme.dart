import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// ─── Animation Constants ─────────────────────────────────────────────────────
class AppDurations {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Duration shimmer = Duration(milliseconds: 1500);
  static const Duration staggerDelay = Duration(milliseconds: 80);
}
class AppCurves {
  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve bounce = Curves.elasticOut;
  static const Curve smooth = Curves.easeInOutCubic;
  static const Curve decelerate = Curves.decelerate;
}
// ─── Color Palette ───────────────────────────────────────────────────────────
class AppColors {
  // ─ Dark Mode Palette (Luxury Dark)
  static const Color background = Color(0xFF1E1E1E);      // Deep Black/Grey
  static const Color surface = Color(0xFF2A2A2A);          // Elevated surface
  static const Color surfaceLight = Color(0xFF333333);     // Elevated surface
  static const Color cardBg = Color(0xFF2A2A2A);
  
  // ─ Light Mode Palette (Warm Premium - Updated)
  static const Color backgroundLight = Color(0xFFFEFEFE);  // Pure White
  static const Color surfaceL = Color(0xFFFDFDFD);         // Off White
  static const Color surfaceVariantL = Color(0xFFF5F5F5);  
  static const Color cardBgL = Color(0xFFFDFDFD);
  
  // ─ Brand Colors (Updated)
  static const Color primary = Color(0xFF9E8770);          // Warm Tan/Brown
  static const Color primaryLight = Color(0xFFB5A18D);
  static const Color primaryDark = Color(0xFF86725E);
  static const Color accent = Color(0xFF707068);           // Muted Grey/Olive
  static const Color charcoal = Color(0xFF5A5E5E);         // Dark Slate Grey
  
  // ─ Accent Colors
  static const Color olive = Color(0xFF707068);            
  static const Color softBrown = Color(0xFF9E8770);        
  
  // ─ Feature Badge Colors
  static const Color badgeBlue = Color(0xFF8B9DC3);
  static const Color badgePurple = Color(0xFFA188A6);
  static const Color badgePink = Color(0xFFD4A5A5);
  static const Color badgeAmber = Color(0xFF9E8770);
  static const Color badgeGreen = Color(0xFF707068);
  
  // ─ Text Colors (Dark Mode)
  static const Color textPrimary = Color(0xFFFEFEFE);
  static const Color textSecondary = Color(0xFF9E8770);
  static const Color textMuted = Color(0xFF707068);
  
  // ─ Text Colors (Light Mode)
  static const Color textPrimaryL = Color(0xFF2F2F2F);      
  static const Color textSecondaryL = Color(0xFF5A5E5E);    // Dark Slate Grey
  static const Color textMutedL = Color(0xFF707068);
  
  // ─ Borders & Dividers
  static const Color divider = Color(0xFF333333);
  static const Color border = Color(0xFF333333);
  static const Color borderL = Color(0xFFE5E2D9);
  
  // ─ Status Colors
  static const Color success = Color(0xFF7A8A6B);
  static const Color error = Color(0xFFB45B5B);
  static const Color warning = Color(0xFFD4B483);
  
  // ─ Gradients (Updated for luxury feel)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF9E8770), Color(0xFF86725E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF707068), Color(0xFF5A5E5E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF5A5E5E), Color(0xFF2F2F2F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFF2A2A2A), Color(0xFF1E1E1E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const LinearGradient meshGradient1 = LinearGradient(
    colors: [Color(0xFFCBBBA0), Color(0xFFA89078), Color(0xFF7A8A6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // ─ Glass Colors
  static Color glassWhite = Colors.white.withValues(alpha: 0.05);
  static Color glassBorder = Colors.white.withValues(alpha: 0.08);
  static Color glassWhiteL = Colors.white.withValues(alpha: 0.6);
  static Color glassBorderL = Colors.black.withValues(alpha: 0.04);
  
  // ─ Shadows (Softened as requested: 0.05-0.08)
  static final List<BoxShadow> cardShadows = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];
  static final List<BoxShadow> cardShadowsL = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
  ];
  static final List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: primary.withValues(alpha: 0.2),
      blurRadius: 15,
      offset: const Offset(0, 6),
    ),
  ];
  static final List<BoxShadow> glowShadow = [
    BoxShadow(
      color: primary.withValues(alpha: 0.1),
      blurRadius: 30,
      spreadRadius: 1,
    ),
  ];
}
// ─── Text Styles ─────────────────────────────────────────────────────────────
class AppTextStyles {
  static TextStyle get displayLarge => GoogleFonts.playfairDisplay(
    fontSize: 42,
    fontWeight: FontWeight.w800,
    height: 1.08,
    letterSpacing: -1.5,
  ).copyWith(inherit: true);
  static TextStyle get displayMedium => GoogleFonts.playfairDisplay(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.8,
  ).copyWith(inherit: true);
  static TextStyle get headlineLarge => GoogleFonts.playfairDisplay(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.3,
  ).copyWith(inherit: true);
  static TextStyle get headlineMedium => GoogleFonts.playfairDisplay(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  ).copyWith(inherit: true);
  static TextStyle get headlineSmall => GoogleFonts.playfairDisplay(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  ).copyWith(inherit: true);
  static TextStyle get titleLarge => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  ).copyWith(inherit: true);
  static TextStyle get titleMedium => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  ).copyWith(inherit: true);
  static TextStyle get bodyLarge => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
  ).copyWith(inherit: true);
  static TextStyle get bodyMedium => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  ).copyWith(inherit: true);
  static TextStyle get labelLarge => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  ).copyWith(inherit: true);
  static TextStyle get labelMedium => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  ).copyWith(inherit: true);
  static TextStyle get labelSmall => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w500,
  ).copyWith(inherit: true);
  static TextStyle get caption => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  ).copyWith(inherit: true);
  static TextStyle get overline => GoogleFonts.poppins(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
  ).copyWith(inherit: true);
}
// ─── Glassmorphism Helper ────────────────────────────────────────────────────
class GlassDecoration {
  static BoxDecoration card({
    required bool isDark,
    double borderRadius = 24,
    double opacity = 0.08,
  }) {
    return BoxDecoration(
      color: isDark
          ? Colors.white.withValues(alpha: opacity)
          : Colors.white.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.black.withValues(alpha: 0.06),
        width: 1,
      ),
      boxShadow: isDark ? null : AppColors.cardShadowsL,
    );
  }
  static BoxDecoration elevated({
    required bool isDark,
    double borderRadius = 20,
  }) {
    return BoxDecoration(
      color: isDark ? AppColors.surface : AppColors.surfaceL,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: isDark ? AppColors.border : AppColors.borderL,
        width: 1,
      ),
      boxShadow: isDark ? null : AppColors.cardShadowsL,
    );
  }
}
// ─── AppTheme (Compatibility + ThemeData) ─────────────────────────────────────
class AppTheme {
  static const Color background = AppColors.background;
  static const Color surface = AppColors.surface;
  static const Color primary = AppColors.primary;
  static const Color accent = AppColors.accent;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color error = AppColors.error;
  static const Color border = AppColors.border;
  static LinearGradient get primaryGradient => AppColors.primaryGradient;
  static LinearGradient get accentGradient => AppColors.accentGradient;
  static List<BoxShadow> get cardShadow => AppColors.cardShadows;
  // Compatibility aliases
  static const Color divider = AppColors.divider;
  static const Color surfaceVariant = AppColors.surfaceLight;
  static const Color textHint = AppColors.textMuted;
  static const Color success = AppColors.success;
  static const Color secondary = AppColors.accent;
  static const Color gold = AppColors.primary;
  static const Color shadowColor = Colors.black;
  static LinearGradient get goldGradient => AppColors.primaryGradient;
  static List<BoxShadow> get cardShadows => AppColors.cardShadows;
  static ThemeData get lightTheme {
    final textTheme = TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.textPrimaryL),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.textPrimaryL),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimaryL),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimaryL),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimaryL),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimaryL),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimaryL),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryL),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryL),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimaryL),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondaryL),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: textTheme,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surfaceL,
        error: AppColors.error,
        onSurface: AppColors.textPrimaryL,
        onSurfaceVariant: AppColors.textSecondaryL,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimaryL),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryL),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          side: const BorderSide(color: AppColors.accent, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceL,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.borderL, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderL,
        thickness: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.accent,
        titleTextStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryL),
        subtitleTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryL),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceL,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMutedL),
        labelStyle: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimaryL),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderL, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
      ),
    );
  }
  static ThemeData get darkTheme {
    final textTheme = TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.textPrimary),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.textPrimary),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimary),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.error,
        onSurface: AppColors.textPrimary,
        onSurfaceVariant: AppColors.textSecondary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimary),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.primary,
        titleTextStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
        subtitleTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
        labelStyle: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
      ),
    );
  }
}
