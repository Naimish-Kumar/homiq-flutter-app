import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homiq/ui/theme/theme.dart';

final commonThemeData = ThemeData(
  useMaterial3: true,
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  splashFactory: NoSplash.splashFactory,
  textSelectionTheme: TextSelectionThemeData(
    selectionColor: tertiaryColor_.withValues(alpha: 0.3),
    cursorColor: tertiaryColor_,
    selectionHandleColor: tertiaryColor_,
  ),
  dividerTheme:  DividerThemeData(
    color: widgetsBorderColorLight,
    thickness: 1,
    space: 0,
  ),
);

final Map<Brightness, ThemeData> appThemeData = {
  Brightness.light: commonThemeData.copyWith(
    brightness: Brightness.light,
    textTheme: commonThemeData.textTheme.luxuryTheme,
    scaffoldBackgroundColor: primaryColor_,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: textColor),
      titleTextStyle: GoogleFonts.prata(
        color: textColor,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: secondaryColor_,
      elevation: 5,
      height: 70,
    ),
    cardTheme: CardThemeData(
      color: secondaryColor_,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side:  BorderSide(color: widgetsBorderColorLight),
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: tertiaryColor_,
      primary: tertiaryColor_,
      secondary: accentColor_,
      surface: secondaryColor_,
      onSurface: textColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: tertiaryColor_,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
  ),
  Brightness.dark: commonThemeData.copyWith(
    brightness: Brightness.dark,
    textTheme: commonThemeData.textTheme.luxuryTheme,
    scaffoldBackgroundColor: primaryColorDark,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: textColorDarkTheme),
      titleTextStyle: GoogleFonts.prata(
        color: textColorDarkTheme,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: secondaryColorDark,
      elevation: 0,
      height: 70,
    ),
    cardTheme: CardThemeData(
      color: secondaryColorDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: widgetsBorderColorDark),
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: tertiaryColorDark,
      primary: tertiaryColorDark,
      secondary: tertiaryColorDark.withValues(alpha: 0.2),
      surface: secondaryColorDark,
      onSurface: textColorDarkTheme,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: tertiaryColorDark,
        foregroundColor: Colors.black,
        elevation: 0,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
  ),
};
