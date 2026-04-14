import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

///Light Theme Colors
const Color primaryColor_ = Color(0xFFFDF8F7); // Soft Rose White
const Color secondaryColor_ = Color(0xFFFFFFFF); // Pure White
const Color tertiaryColor_ = Color(0xFFBC8E92); // Premium Metallic Rose Gold 
const Color accentColor_ = Color(0xFFF3CFC6); // Soft Rose Highlight
const Color textColor = Color(0xFF1C1917); // Stone 900 (Soft Black)
Color lightTextColor = const Color(0xFF78716C); // Stone 500
Color widgetsBorderColorLight = const Color(0xFFE7ADAC).withValues(alpha: 0.2); // Rose Tinted Border
Color senderChatColor = const Color(0xFFFDF8F7); 

///Dark Theme Colors
Color primaryColorDark = const Color(0xFF0C0A09); // Deep Ebony
Color secondaryColorDark = const Color(0xFF1C1917); // Stone 900
const Color tertiaryColorDark = Color(0xFFE29587); // Vibrant Rose Gold
const Color textColorDarkTheme = Color(0xFFFAFAF9); // Stone 50
Color lightTextColorDarkTheme = const Color(0xFFA8A29E).withValues(alpha: 0.8); // Stone 400
Color widgetsBorderColorDark = const Color(0xFFE29587).withValues(alpha: 0.15); // Rose Gold Tinted Border
Color darkSenderChatColor = const Color(0xFF1C1917); 

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
      _getColor(brightness, lightColor: accentColor_, darkColor: Color(0xFFBC8E92).withValues(alpha: 0.2));

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
      ? const Color(0xFFF9F5F5)
      : const Color(0xFF1C1917);

  Color get shimmerHighlightColor =>
      brightness == Brightness.light ? Colors.white : const Color(0xFF292524);

  Color get shimmerContentColor => brightness == Brightness.light
      ? tertiaryColor.withValues(alpha: 0.05)
      : tertiaryColor.withValues(alpha: 0.1);

  Color get cardGlassColor => _getColor(
    brightness,
    lightColor: Colors.white.withValues(alpha: 0.75),
    darkColor: const Color(0xFF1C1917).withValues(alpha: 0.75),
  );

  LinearGradient get primaryGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [tertiaryColor, accentColor],
  );

  LinearGradient get glassGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withValues(alpha: 0.12), 
      tertiaryColor.withValues(alpha: 0.04)
    ],
  );

  // Modern Mesh Gradient Blend
  LinearGradient get meshGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: brightness == Brightness.light
        ? [
            const Color(0xFFFDF8F7),
            const Color(0xFFF3CFC6).withValues(alpha: 0.15),
            const Color(0xFFFDF8F7),
          ]
        : [
            const Color(0xFF0C0A09),
            const Color(0xFFBC8E92).withValues(alpha: 0.1),
            const Color(0xFF0C0A09),
          ],
    stops: const [0.0, 0.5, 1.0],
  );
}

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
  double get xxs => 11; 
  double get xs => 12; 
  double get sm => 14; 
  double get md => 16; 
  double get lg => 18; 
  double get xl => 24; 
  double get xxl => 28; 
}

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

final Map<ThemeMode, ThemeData> appThemeData = {
  ThemeMode.light: ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor_,
    colorScheme: const ColorScheme.light(
      primary: primaryColor_,
      secondary: secondaryColor_,
      tertiary: tertiaryColor_,
    ),
    useMaterial3: true,
  ),
  ThemeMode.dark: ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColorDark,
    colorScheme: ColorScheme.dark(
      primary: primaryColorDark,
      secondary: secondaryColorDark,
      tertiary: tertiaryColorDark,
    ),
    useMaterial3: true,
  ),
};
