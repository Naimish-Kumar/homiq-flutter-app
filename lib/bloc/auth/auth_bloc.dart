// lib/bloc/auth/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/push_notification_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthSendOtp>(_onSendOtp);
    on<AuthVerifyOtp>(_onVerifyOtp);
    on<AuthLoginWithGoogle>(_onLoginWithGoogle);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthUpdateProfile>(_onUpdateProfile);
    on<AuthRefreshRequested>(_onRefreshRequested);
    on<AuthVerifyFirebaseOtp>(_onVerifyFirebaseOtp);
    on<_InternalAuthFirebaseCodeSent>(_onInternalFirebaseCodeSent);
    on<_InternalAuthError>((event, emit) => emit(AuthError(event.message)));
  }

  Future<void> _onCheckRequested(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
        // Sync FCM token on success
        PushNotificationService.syncToken(_authService);
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSendOtp(
      AuthSendOtp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      if (event.type == 'mobile') {
        // Use Firebase Phone Auth for mobile
        await _authService.verifyPhoneNumber(
          phoneNumber: event.identifier,
          onCodeSent: (verificationId) {
            add(_InternalAuthFirebaseCodeSent(verificationId, event.identifier));
          },
          onVerificationFailed: (e) {
            add(_InternalAuthError(e.message ?? 'Verification failed'));
          },
        );
        // We don't emit yet, we wait for callbacks
      } else {
        // Standard email OTP
        await _authService.sendOtp(
          identifier: event.identifier,
          type: event.type,
        );
        emit(AuthOtpSent(
          identifier: event.identifier, 
          type: event.type, 
        ));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Internal events to bridge Firebase callbacks
  void _onInternalFirebaseCodeSent(_InternalAuthFirebaseCodeSent event, Emitter<AuthState> emit) {
    emit(AuthFirebaseCodeSent(verificationId: event.verificationId, phoneNumber: event.phoneNumber));
  }

  Future<void> _onVerifyFirebaseOtp(
      AuthVerifyFirebaseOtp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authService.verifyFirebaseOtp(
        verificationId: event.verificationId,
        smsCode: event.smsCode,
      );
      emit(AuthAuthenticated(user));
      PushNotificationService.syncToken(_authService);
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyOtp(
      AuthVerifyOtp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authService.verifyOtp(
        identifier: event.identifier,
        type: event.type,
        otp: event.otp,
      );
      emit(AuthAuthenticated(user));
      // Sync FCM token on success
      PushNotificationService.syncToken(_authService);
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLoginWithGoogle(
      AuthLoginWithGoogle event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authService.signInWithGoogle();
      emit(AuthAuthenticated(user));
      // Sync FCM token on success
      PushNotificationService.syncToken(_authService);
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _authService.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onUpdateProfile(
      AuthUpdateProfile event, Emitter<AuthState> emit) async {
    try {
      final user = await _authService.updateProfile(
        name: event.name,
        email: event.email,
        phoneNumber: event.phoneNumber,
        profileImage: event.profileImage,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  Future<void> _onRefreshRequested(
      AuthRefreshRequested event, Emitter<AuthState> emit) async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      }
    } catch (e) {
      // silently fail refresh
    }
  }
}
