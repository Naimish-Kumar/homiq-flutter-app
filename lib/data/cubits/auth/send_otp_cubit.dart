import 'dart:async';
import 'package:homiq/data/repositories/auth_repository.dart';
import 'package:homiq/exports/main_export.dart';

String verificationID = '';

abstract class SendOtpState {}

class SendOtpInitial extends SendOtpState {}

class SendOtpInProgress extends SendOtpState {}

class SendOtpSuccess extends SendOtpState {
  SendOtpSuccess({
    this.verificationId,
    this.message,
  });
  String? verificationId;
  String? message;
}

class SendOtpFailure extends SendOtpState {
  SendOtpFailure(this.errorMessage);
  final String errorMessage;
}

class SendOtpCubit extends Cubit<SendOtpState> {
  SendOtpCubit() : super(SendOtpInitial());

  final AuthRepository _authRepository = AuthRepository();
  static const Duration _otpTimeout = Duration(seconds: 30);
  
  // Unified OTP sending method to reduce code duplication
  Future<void> sendOTP({
    required String phoneNumber, 
    required String countryCode,
    String? provider,
  }) async {
    if (state is SendOtpInProgress) return; // Prevent multiple calls
    
    emit(SendOtpInProgress());
    
    try {
      await _authRepository.sendOTP(
        phoneNumber: phoneNumber,
        countryCode: countryCode,
        onCodeSent: (verificationId) {
          verificationID = verificationId;
          emit(SendOtpSuccess(verificationId: verificationId));
        },
        onError: (e) {
          emit(SendOtpFailure(e.toString()));
        },
      ).timeout(_otpTimeout);
    } on TimeoutException catch (_) {
      emit(SendOtpFailure('OTP request timed out. Please try again.'));
    } catch (e) {
      emit(SendOtpFailure(e.toString()));
    }
  }

  Future<void> sendFirebaseOTP(
      {required String phoneNumber, required String countryCode}) async {
    await sendOTP(phoneNumber: phoneNumber, countryCode: countryCode, provider: 'firebase');
  }

  Future<void> sendTwilioOTP(
      {required String phoneNumber, required String countryCode}) async {
    await sendOTP(phoneNumber: phoneNumber, countryCode: countryCode, provider: 'twilio');
  }

  Future<void> sendForgotPasswordEmail({
    required String email,
  }) async {
    emit(SendOtpInProgress());
    try {
      final result = await _authRepository.sendForgotPasswordEmail(
        email: email,
      );
      if (result['error'] == true) {
        emit(SendOtpFailure(result['message']?.toString() ?? ''));
      } else {
        emit(SendOtpSuccess(message: result['message']?.toString() ?? ''));
      }
    } on ApiException catch (e) {
      emit(SendOtpFailure(e.toString()));
    }
  }

  Future<void> sendEmailOTP({
    required String email,
    required String name,
    required String phoneNumber,
    required String countryCode,
    required String password,
    required String confirmPassword,
  }) async {
    emit(SendOtpInProgress());
    try {
      final result = await _authRepository.sendEmailOTP(
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        countryCode: countryCode,
        password: password,
        confirmPassword: confirmPassword,
      );
      if (result['error'] == true) {
        emit(SendOtpFailure(result['message']?.toString() ?? ''));
      } else {
        emit(SendOtpSuccess());
      }
    } on ApiException catch (e) {
      emit(SendOtpFailure(e.toString()));
    }
  }

  Future<void> resendEmailOTP({
    required String email,
    required String password,
  }) async {
    try {
      emit(SendOtpInProgress());
      final result = await _authRepository.resendEmailOTP(
        email: email,
        password: password,
      );
      if (result['error'] == true) {
        emit(SendOtpFailure(result['message']?.toString() ?? ''));
      } else {
        emit(SendOtpSuccess());
      }
    } on ApiException catch (e) {
      emit(SendOtpFailure(e.toString()));
    }
  }
}
