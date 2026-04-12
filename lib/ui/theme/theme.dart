import 'package:flutter/material.dart';
import 'package:homiq/app/app.dart';

///Light Theme Colors
const Color primaryColor_ = Color(0xFFF8FAFC); // Soft Mist White
const Color secondaryColor_ = Color(0xFFFFFFFF); // White
const Color tertiaryColor_ = Color(0xFF49A9B4); // Brand Teal
const Color accentColor_ = Color(0xFFFF7F64); // Brand Coral
const Color textColor = Color(0xFF0F172A); // Dark Slate
Color lightTextColor = const Color(0xFF64748B); // Muted Slate
Color widgetsBorderColorLight = const Color(0xFFE2E8F0);
Color senderChatColor = const Color(0xFFEDF8F9); // Very Light Teal Tint

///Dark Theme Colors
Color primaryColorDark = const Color(0xFF0F172A); // Deep Navy Slate
Color secondaryColorDark = const Color(0xFF1E293B); // Muted Dark Navy
const Color tertiaryColorDark = Color(0xFF49A9B4); // Brand Teal
const Color textColorDarkTheme = Color(0xFFF8FAFC);
Color lightTextColorDarkTheme = const Color(0xFF94A3B8).withValues(alpha: 0.8);
Color widgetsBorderColorDark = const Color(0xFF334155);
Color darkSenderChatColor = const Color(0xFF134E4A); // Deep Teal

///Messages Color
const Color errorMessageColor = Color(0xFFD32F2F);
const Color successMessageColor = Color(0xFF388E3C);
const Color warningMessageColor = Color(0xFFFBC02D);

//Button text color
const Color buttonTextColor = Colors.white;

///Advance
//Theme settings
extension ColorPrefs on ColorScheme {
  Color get primaryColor => _getColor(
        brightness,
        lightColor: appSettings.lightPrimary,
        darkColor: appSettings.darkPrimary,
      );

  Color get secondaryColor => _getColor(
        brightness,
        lightColor: appSettings.lightSecondary,
        darkColor: appSettings.darkSecondary,
      );

  Color get tertiaryColor => _getColor(
        brightness,
        lightColor: appSettings.lightTertiary,
        darkColor: appSettings.darkTertiary,
      );
 
  Color get accentColor => _getColor(
        brightness,
        lightColor: accentColor_,
        darkColor: accentColor_,
      );

  Color get backgroundColor => _getColor(
        brightness,
        lightColor: appSettings.lightPrimary,
        darkColor: appSettings.darkPrimary,
      );

  Color get buttonColor => _getColor(
        brightness,
        lightColor: Colors.white,
        darkColor: Colors.black,
      );

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

  Color get inverseThemeColor => _getColor(
        brightness,
        lightColor: Colors.black,
        darkColor: Colors.white,
      );

  Color get blackColor => Colors.black;

  Color get shimmerBaseColor => brightness == Brightness.light
      ? const Color.fromARGB(255, 225, 225, 225)
      : const Color.fromARGB(255, 150, 150, 150);

  Color get shimmerHighlightColor => brightness == Brightness.light
      ? Colors.grey.shade100
      : Colors.grey.shade300;

  Color get shimmerContentColor => brightness == Brightness.light
      ? Colors.white.withOpacity(0.85)
      : Colors.white.withOpacity(0.7);
}

// 11pt: Smaller
// 12pt: Small
// 16pt: Large
// 18pt: Larger
// 24pt: Extra large
extension TextThemeForFont on TextTheme {
  Font get font => Font();
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
