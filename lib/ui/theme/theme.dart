import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

///Light Theme Colors
const Color primaryColor_ = Color(0xFFFBFBF9); // Warm Parchment/Ivory
const Color secondaryColor_ = Color(0xFFFFFFFF); // Pure White
const Color tertiaryColor_ = Color(0xFFB8860B); // Metallic Bronze/Gold (Luxury Accent)
const Color accentColor_ = Color(0xFFE5E7EB); // Soft Metallic Silver
const Color textColor = Color(0xFF1C1917); // Stone 900 (Soft Black)
Color lightTextColor = const Color(0xFF78716C); // Stone 500
Color widgetsBorderColorLight = const Color(0xFFE7E5E4); // Stone 200
Color senderChatColor = const Color(0xFFF5F5F4); // Stone 100

///Dark Theme Colors
Color primaryColorDark = const Color(0xFF0C0A09); // Deep Ebony
Color secondaryColorDark = const Color(0xFF1C1917); // Stone 900
const Color tertiaryColorDark = Color(0xFFD4AF37); // Classic Gold
const Color textColorDarkTheme = Color(0xFFFAFAF9); // Stone 50
Color lightTextColorDarkTheme = const Color(0xFFA8A29E).withValues(alpha: 0.8); // Stone 400
Color widgetsBorderColorDark = const Color(0xFF292524); // Stone 800
Color darkSenderChatColor = const Color(0xFF1C1917); // Stone 900/Deep Chat

// Message Colors (Luxury Muted Palette)
const Color successMessageColor = Color(0xFF15803D); // Muted Emerald
const Color warningMessageColor = Color(0xFFB45309); // Muted Amber
const Color errorMessageColor = Color(0xFFB91C1C); // Muted Crimson

//Button text color
const Color buttonTextColor = Colors.white;

///Advance
//Theme settings
extension ColorPrefs on ColorScheme {
  Color get primaryColor =>
      _getColor(brightness, lightColor: primaryColor_, darkColor: primaryColorDark);

  Color get backgroundColor => primaryColor;

  Color get secondaryColor => _getColor(brightness,
      lightColor: secondaryColor_, darkColor: secondaryColorDark);

  Color get tertiaryColor => _getColor(brightness,
      lightColor: tertiaryColor_, darkColor: tertiaryColorDark);

  Color get accentColor =>
      _getColor(brightness, lightColor: accentColor_, darkColor: accentColor_);

  Color get buttonColor =>
      _getColor(brightness, lightColor: Colors.white, darkColor: Colors.black);

  Color get textColorDark => _getColor(
    brightness,
    lightColor: textColor,
    darkColor: textColorDarkTheme,
  );

  Color get textLightColor => _getColor(
    brightness,
    lightColor: lightTextColor,
    darkColor: lightTextColorDarkTheme,
  );

  Color get borderColor => _getColor(
    brightness,
    lightColor: widgetsBorderColorLight,
    darkColor: widgetsBorderColorDark,
  );

  Color get chatSenderColor => _getColor(
    brightness,
    lightColor: senderChatColor,
    darkColor: darkSenderChatColor,
  );

  Color get inverseThemeColor =>
      _getColor(brightness, lightColor: Colors.black, darkColor: Colors.white);

  Color get blackColor => Colors.black;

  /// Standard ColorScheme mappings for extension compatibility
  Color get error => this.error;
  Color get onPrimary => this.onPrimary;
  Color get onSurface => this.onSurface;
  Color get inverseSurface => this.inverseSurface;
  Color get onInverseSurface => this.onInverseSurface;

  Color get shimmerBaseColor => brightness == Brightness.light
      ? const Color(0xFFF1F5F9)
      : const Color(0xFF1E293B);

  Color get shimmerHighlightColor =>
      brightness == Brightness.light ? Colors.white : const Color(0xFF334155);

  Color get shimmerContentColor => brightness == Brightness.light
      ? Colors.white.withValues(alpha: 0.8)
      : Colors.white.withValues(alpha: 0.2);

  Color get cardGlassColor => _getColor(
    brightness,
    lightColor: Colors.white.withValues(alpha: 0.85),
    darkColor: const Color(0xFF1E293B).withValues(alpha: 0.85),
  );

  LinearGradient get primaryGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accentColor],
  );

  LinearGradient get glassGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.05)],
  );
}

// 11pt: Smaller
// 12pt: Small
// 16pt: Large
// 18pt: Larger
// 24pt: Extra large
extension TextThemeForFont on TextTheme {
  Font get font => Font();

  TextTheme get luxuryTheme {
    return copyWith(
      displayLarge: GoogleFonts.prata(
        letterSpacing: -1,
        fontWeight: FontWeight.w400,
      ),
      displayMedium: GoogleFonts.prata(
        letterSpacing: -0.5,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: GoogleFonts.prata(
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: GoogleFonts.prata(
        fontWeight: FontWeight.w500,
      ),
      headlineMedium: GoogleFonts.prata(
        fontWeight: FontWeight.w500,
      ),
      headlineSmall: GoogleFonts.prata(
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
      titleMedium: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
      ),
      titleSmall: GoogleFonts.inter(
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.inter(
        fontWeight: FontWeight.w400,
      ),
      bodySmall: GoogleFonts.inter(
        fontWeight: FontWeight.w300,
      ),
      labelLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }
}

class Font {
  ///11
  double get xxs => 11; // smaller

  ///12
  double get xs => 12; // small

  ///14
  double get sm => 14; // normal

  ///16
  double get md => 16; // large

  ///18
  double get lg => 18; // larger

  ///24
  double get xl => 24; // extraLarge

  ///28
  double get xxl => 28; // xxLarge
}

//This one is for check current theme and return data accordingly
Color _getColor(
  Brightness brightness, {
  required Color lightColor,
  required Color darkColor,
}) {
  if (Brightness.light == brightness) {
    return lightColor;
  } else {
    return darkColor;
  }
}
