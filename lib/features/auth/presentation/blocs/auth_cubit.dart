import 'package:homiq/exports/main_export.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthProgress extends AuthState {}

class Unauthenticated extends AuthState {}

class Authenticated extends AuthState {
  Authenticated({required this.isAuthenticated});
  bool isAuthenticated = false;
}

class AuthFailure extends AuthState {
  AuthFailure(this.errorMessage);
  final String errorMessage;
}

class AuthCubit extends Cubit<AuthState> {
  //late String name, email, profile, address;
  AuthCubit() : super(AuthInitial()) {
    // checkIsAuthenticated();
  }
  void checkIsAuthenticated() {
    if (HiveUtils.isUserAuthenticated()) {
      //setUserData();
      emit(Authenticated(isAuthenticated: true));
    } else {
      emit(Unauthenticated());
    }
  }

 }
