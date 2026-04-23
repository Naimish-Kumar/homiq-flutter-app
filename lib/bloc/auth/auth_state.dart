// lib/bloc/auth/auth_state.dart
part of 'auth_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthOtpSent extends AuthState {
  final String identifier;
  final String type;
  AuthOtpSent({required this.identifier, required this.type});
}

class AuthFirebaseCodeSent extends AuthState {
  final String verificationId;
  final String phoneNumber;
  AuthFirebaseCodeSent({required this.verificationId, required this.phoneNumber});
}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  AuthAuthenticated(this.user);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
