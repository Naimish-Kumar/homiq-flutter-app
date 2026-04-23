// lib/bloc/auth/auth_event.dart
part of 'auth_bloc.dart';

abstract class AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class AuthSendOtp extends AuthEvent {
  final String identifier;
  final String type; // 'email' or 'mobile'
  AuthSendOtp({required this.identifier, required this.type});
}

class AuthVerifyOtp extends AuthEvent {
  final String identifier;
  final String type;
  final String otp;
  AuthVerifyOtp({required this.identifier, required this.type, required this.otp});
}

class AuthVerifyFirebaseOtp extends AuthEvent {
  final String verificationId;
  final String smsCode;
  AuthVerifyFirebaseOtp({required this.verificationId, required this.smsCode});
}

class AuthLoginWithGoogle extends AuthEvent {}

class AuthLogoutRequested extends AuthEvent {}

class AuthUpdateProfile extends AuthEvent {
  final String? name;
  final String? email;
  final String? phoneNumber;
  final dynamic profileImage;
  AuthUpdateProfile({this.name, this.email, this.phoneNumber, this.profileImage});
}

class AuthRefreshRequested extends AuthEvent {}

// Internal events
class _InternalAuthFirebaseCodeSent extends AuthEvent {
  final String verificationId;
  final String phoneNumber;
  _InternalAuthFirebaseCodeSent(this.verificationId, this.phoneNumber);
}

class _InternalAuthError extends AuthEvent {
  final String message;
  _InternalAuthError(this.message);
}
