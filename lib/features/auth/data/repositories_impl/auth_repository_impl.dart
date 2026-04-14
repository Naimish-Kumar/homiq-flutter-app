import 'package:homiq/core/network/api_client.dart';
import 'package:homiq/core/network/api_endpoints.dart';
import 'package:homiq/features/auth/data/models/user_model.dart';
import 'package:homiq/utils/hive_utils.dart';

class AuthRepository {
  final ApiClient _apiClient;
  
  AuthRepository([ApiClient? apiClient]) : _apiClient = apiClient ?? ApiClient();
  
  Future<dynamic> sendOtp({required String identifier, required String type}) async {
    try {
      final response = await _apiClient.post(
        Api.apiSendOtp,
        params: {
          'identifier': identifier,
          'type': type,
        },
      );
      response['success'] = !(response['error'] ?? false);
      return response;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<dynamic> verifyOtp({
    required String identifier, 
    required String otp, 
    required String type,
  }) async {
    try {
      final response = await _apiClient.post(
        Api.apiVerifyOtp,
        params: {
          'identifier': identifier,
          'otp': otp,
          'type': type,
        },
      );
      response['success'] = !(response['error'] ?? false);
      return response;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<UserModel?> getProfile() async {
    try {
      final response = await _apiClient.get(Api.apiGetProfile);
      if (response['success'] == true || response['error'] == false) {
        final userData = response['user'] as Map<String, dynamic>;
        final user = UserModel.fromJson(userData);
        await HiveUtils.setUserData(user.toJson());
        return user;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> socialLogin({required Map<String, dynamic> data}) async {
    try {
      final response = await _apiClient.post(
        Api.apiSocialLogin,
        params: data,
      );
      response['success'] = !(response['error'] ?? false);
      return response;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<dynamic> loginWithGoogle({required String email, required String name, required String uid}) async {
    return socialLogin(data: {
      'provider': 'google',
      'social_id': uid,
      'email': email,
      'name': name,
    });
  }

  Future<dynamic> registerUser({required Map<String, dynamic> data}) async {
    return {'success': true, 'message': 'User Registered'};
  }

  Future<void> beforeLogout() async {
    try {
      await _apiClient.post(Api.apiLogout);
    } catch (_) {}
  }
}

typedef AuthRepositoryImpl = AuthRepository;
