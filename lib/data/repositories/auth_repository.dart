
import 'package:homiq/exports/main_export.dart';

enum LoginType {
  google('google'),
  apple('apple'),
  email('email'),
  phone('mobile'),
  mobile('mobile');

  const LoginType(this.value);
  final String value;
}

class AuthRepository {
  /// Send OTP to identifier (email or mobile) via backend
  Future<Map<String, dynamic>> sendOtp({
    required String identifier,
    required String type,
  }) async {
    try {
      final response = await Api.post(
        url: Api.apiSendOtp,
        parameter: {
          'identifier': identifier,
          'type': type,
        },
        useAuthToken: false,
      );

      return response;
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Verify OTP and obtain Sanctum token
  Future<Map<String, dynamic>> verifyOtp({
    required String identifier,
    required String type,
    required String otp,
  }) async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
      
      final response = await Api.post(
        url: Api.apiVerifyOtp,
        parameter: {
          'identifier': identifier,
          'type': type,
          'otp': otp,
          'fcm_id': fcmToken,
        },
        useAuthToken: false,
      );

      return response;
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Unified Social Login verified by backend
  Future<Map<String, dynamic>> socialLogin({
    required String provider,
    required String socialId,
    required String email,
    String? name,
  }) async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken() ?? '';

      final response = await Api.post(
        url: Api.apiSocialLogin,
        parameter: {
          'provider': provider,
          'social_id': socialId,
          'email': email,
          if (name != null) 'name': name,
          'fcm_id': fcmToken,
        },
        useAuthToken: false,
      );

      return response;
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> beforeLogout() async {
    final token = await FirebaseMessaging.instance.getToken();
    await Api.post(
      url: Api.apiBeforeLogout,
      parameter: {
        'fcm_id': token,
      },
    );
  }
}

