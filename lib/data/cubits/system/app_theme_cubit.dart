import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:homiq/utils/hive_keys.dart';
import 'package:homiq/utils/hive_utils.dart';

class AppThemeState {
  final ThemeMode appTheme;
  AppThemeState(this.appTheme);
}

class AppThemeCubit extends Cubit<AppThemeState> {
  AppThemeCubit() : super(AppThemeState(_getInitialThemeMode()));

  static ThemeMode _getInitialThemeMode() {
    final savedTheme = HiveUtils.getCurrentTheme();
    if (savedTheme == 'system') {
      return ThemeMode.system;
    } else if (savedTheme == 'dark') {
      return ThemeMode.dark;
    } else {
      return ThemeMode.light;
    }
  }

  void changeTheme(ThemeMode themeMode) {
    String themeValue;
    switch (themeMode) {
      case ThemeMode.system:
        themeValue = 'system';
      case ThemeMode.dark:
        themeValue = 'dark';
      case ThemeMode.light:
        themeValue = 'light';
    }

    try {
      Hive.box<dynamic>(HiveKeys.themeBox).put(HiveKeys.currentTheme, themeValue);
    } catch (e) {
      log('Failed to save theme: $e');
    }
    emit(AppThemeState(themeMode));
  }

  bool get isDarkMode {
    if (state.appTheme == ThemeMode.system) {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return state.appTheme == ThemeMode.dark;
  }
}
