import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homiq/data/repositories/system_repository.dart';

abstract class FetchSystemSettingsState {}

class FetchSystemSettingsInitial extends FetchSystemSettingsState {}

class FetchSystemSettingsInProgress extends FetchSystemSettingsState {}

class FetchSystemSettingsSuccess extends FetchSystemSettingsState {
  FetchSystemSettingsSuccess({required this.settings});
  final Map<dynamic, dynamic> settings;
}

class FetchSystemSettingsFailure extends FetchSystemSettingsState {
  FetchSystemSettingsFailure(this.errorMessage);
  final String errorMessage;
}

class FetchSystemSettingsCubit extends Cubit<FetchSystemSettingsState> {
  FetchSystemSettingsCubit() : super(FetchSystemSettingsInitial());
  final SystemRepository _systemRepository = SystemRepository();

  Future<void> fetchSettings({bool isAnonymous = false}) async {
    emit(FetchSystemSettingsInProgress());
    try {
      final settings = await _systemRepository.fetchSettings(isAnonymous: isAnonymous);
      emit(FetchSystemSettingsSuccess(settings: settings));
    } catch (e) {
      emit(FetchSystemSettingsFailure(e.toString()));
    }
  }

  dynamic getSetting(dynamic key) {
    if (state is FetchSystemSettingsSuccess) {
      return (state as FetchSystemSettingsSuccess).settings[key];
    }
    return null;
  }
}
