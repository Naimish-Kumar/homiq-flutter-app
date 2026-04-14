import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageState {}

class LanguageInitial extends LanguageState {}

class LanguageLoader extends LanguageState {
  LanguageLoader(this.languageCode, {required this.isRTL});
  final bool isRTL;
  final dynamic languageCode;
}

class LanguageLoadFail extends LanguageState {
  LanguageLoadFail({required this.error});
  final dynamic error;
}

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit() : super(LanguageInitial());

  void emitLanguageLoader({required String code, required bool isRtl}) {
    // Force English even if called
    emit(LanguageLoader('en', isRTL: false));
  }

  void loadCurrentLanguage() {
    // Always load English
    emit(LanguageLoader('en', isRTL: false));
  }

  bool get isRTL {
    if (state is LanguageLoader) {
      return (state as LanguageLoader).isRTL;
    }
    return false;
  }
}

