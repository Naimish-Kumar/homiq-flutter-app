import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageCubit extends Cubit<Locale> {
  static const String _langKey = 'selected_language';

  LanguageCubit() : super(const Locale('en')) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString(_langKey) ?? 'en';
    emit(Locale(langCode));
  }

  Future<void> changeLanguage(String langCode) async {
    emit(Locale(langCode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, langCode);
  }
}
