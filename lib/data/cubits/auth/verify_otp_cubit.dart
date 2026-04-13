
import 'package:homiq/data/repositories/auth_repository.dart';
import 'package:homiq/exports/main_export.dart';

abstract class VerifyOtpState {}

class VerifyOtpInitial extends VerifyOtpState {}

class VerifyOtpInProgress extends VerifyOtpState {}

class VerifyOtpSuccess extends VerifyOtpState {
  VerifyOtpSuccess({
    this.authId,
    this.number,
    this.otp,
    this.credential,
  });
  final dynamic credential;
  final String? authId;
  final String? number;
  final String? otp;  
}

class VerifyOtpFailure extends VerifyOtpState {
  VerifyOtpFailure(this.errorMessage);
  final String errorMessage;
}

class VerifyOtpCubit extends Cubit<VerifyOtpState> {
  VerifyOtpCubit() : super(VerifyOtpInitial());
  final AuthRepository _authRepository = AuthRepository();

  /// Unified OTP verification (Email or Mobile)
  Future<void> verifyOtp({
    required String otp,
    required String identifier,
    required String type,
  }) async {
    try {
      emit(VerifyOtpInProgress());
      
      final result = await _authRepository.verifyOtp(
        identifier: identifier,
        type: type,
        otp: otp,
      );

      if (result['success'] == true) {
        await _persistLogin(result, loginType: type);
        emit(VerifyOtpSuccess(credential: result));
      } else {
        emit(VerifyOtpFailure(result['message']?.toString() ?? 'Verification failed'));
      }
    } on ApiException catch (e) {
      emit(VerifyOtpFailure(e.toString()));
    } catch (e) {
      emit(VerifyOtpFailure('An unexpected error occurred'));
    }
  }

  /// Unified Social Login verified by backend
  Future<void> socialLogin({
    required String provider,
    required String socialId,
    required String email,
    String? name,
  }) async {
    try {
      emit(VerifyOtpInProgress());
      
      final result = await _authRepository.socialLogin(
        provider: provider,
        socialId: socialId,
        email: email,
        name: name,
      );

      if (result['success'] == true) {
        await _persistLogin(result, loginType: provider);
        emit(VerifyOtpSuccess(credential: result));
      } else {
        emit(VerifyOtpFailure(result['message']?.toString() ?? 'Social Login failed'));
      }
    } on ApiException catch (e) {
      emit(VerifyOtpFailure(e.toString()));
    } catch (e) {
      emit(VerifyOtpFailure('An unexpected error occurred'));
    }
  }

  /// Helper to persist JWT and User data
  Future<void> _persistLogin(Map<String, dynamic> result, {required String loginType}) async {
    final token = result['token']?.toString() ?? result['access_token']?.toString() ?? '';
    final userData = result['user'] as Map<String, dynamic>? ?? {};
    
    if (token.isNotEmpty) {
      await HiveUtils.setJWT(token);
    }
    
    if (userData.isNotEmpty) {
      await HiveUtils.setUserData(userData);
    }

    // Store login type so EditProfileScreen and logout can determine the auth method
    await HiveUtils.setUserData({'type': loginType});

    // Mark user as authenticated
    HiveUtils.setUserIsAuthenticated();
    HiveUtils.setIsNotGuest();
  }
}



