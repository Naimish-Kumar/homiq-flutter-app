import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homiq/features/auth/data/models/user_model.dart';
import 'package:homiq/features/auth/data/repositories_impl/auth_repository_impl.dart';

abstract class GetUserDataState {}

class GetUserDataInitial extends GetUserDataState {}

class GetUserDataInProgress extends GetUserDataState {}

class GetUserDataSuccess extends GetUserDataState {
  GetUserDataSuccess(this.user);
  final UserModel user;
}

class GetUserDataFailure extends GetUserDataState {
  GetUserDataFailure(this.errorMessage);
  final String errorMessage;
}

class GetUserDataCubit extends Cubit<GetUserDataState> {
  GetUserDataCubit() : super(GetUserDataInitial());
  final AuthRepository _authRepository = AuthRepository();

  Future<void> getUserData() async {
    emit(GetUserDataInProgress());
    try {
      final user = await _authRepository.getProfile();
      if (user != null) {
        emit(GetUserDataSuccess(user));
      } else {
        emit(GetUserDataFailure('Failed to fetch user data'));
      }
    } catch (e) {
      emit(GetUserDataFailure(e.toString()));
    }
  }
}
