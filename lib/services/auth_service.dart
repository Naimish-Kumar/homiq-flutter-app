import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'auth_token';

  AuthService(this._dio);

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<UserModel?> getCurrentUser() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      final response = await _dio.get(
        '/api/profile',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      
      if (response.data['success'] == true) {
        final user = UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
        await _saveUser(user);
        return user;
      }
    } catch (e) {
      // If token expired, logout
      await logout();
    }
    return null;
  }

  Future<String?> sendOtp({
    required String identifier,
    required String type, // 'email' or 'mobile'
  }) async {
    // For email, keep the existing backend OTP flow
    if (type == 'email') {
      final response = await _dio.post('/api/auth/otp/send', data: {
        'identifier': identifier,
        'type': type,
      });
      return response.data['debug_otp']?.toString();
    }
    return null;
  }

  // Firebase Phone Auth verification
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException e) onVerificationFailed,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: onVerificationFailed,
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<UserModel> verifyFirebaseOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final UserCredential userCredential = await _auth.signInWithCredential(credential);
    final String? idToken = await userCredential.user?.getIdToken();

    if (idToken == null) throw Exception('Failed to get Firebase ID Token');

    return await loginWithFirebaseToken(idToken, 'phone');
  }

  Future<UserModel> loginWithFirebaseToken(String idToken, String provider) async {
    final response = await _dio.post('/api/auth/firebase/login', data: {
      'id_token': idToken,
      'provider': provider,
    });

    if (response.data['success'] == true) {
      final token = response.data['token'] as String;
      final user = UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
      
      await _saveToken(token);
      await _saveUser(user);
      return user;
    } else {
      throw Exception(response.data['message'] ?? 'Login failed');
    }
  }

  Future<UserModel> verifyOtp({
    required String identifier,
    required String type,
    required String otp,
  }) async {
    final response = await _dio.post('/api/auth/otp/verify', data: {
      'identifier': identifier,
      'type': type,
      'otp': otp,
    });

    if (response.data['success'] == true) {
      final token = response.data['token'] as String;
      final user = UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
      
      await _saveToken(token);
      await _saveUser(user);
      return user;
    } else {
      throw Exception(response.data['message'] ?? 'Verification failed');
    }
  }

  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign in cancelled');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) throw Exception('Firebase user is null');

      // Now call your backend with the social details
      return await loginWithGoogle(
        firebaseUser.uid,
        firebaseUser.email ?? '',
        firebaseUser.displayName ?? '',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> loginWithGoogle(String socialId, String email, String name) async {
    final response = await _dio.post('/api/auth/social/login', data: {
      'provider': 'google',
      'social_id': socialId,
      'email': email,
      'name': name,
    });

    if (response.data['success'] == true) {
      final token = response.data['token'] as String;
      final user = UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
      
      await _saveToken(token);
      await _saveUser(user);
      return user;
    } else {
      throw Exception('Google login failed');
    }
  }

  Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      try {
        await _dio.post(
          '/api/logout',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      } catch (_) {}
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? phoneNumber,
    dynamic profileImage, // File or path
  }) async {
    final token = await getToken();
    
    final formData = FormData.fromMap({
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (profileImage != null) 
        'profile': await MultipartFile.fromFile(profileImage.path),
    });

    final response = await _dio.post(
      '/api/profile/update',
      data: formData,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.data['success'] == true) {
      final user = UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
      await _saveUser(user);
      return user;
    } else {
      throw Exception('Profile update failed');
    }
  }

  Future<void> updateFcmToken(String fcmToken) async {
    final token = await getToken();
    if (token == null) return;

    try {
      await _dio.post(
        '/api/update-fcm-token',
        data: {'fcm_id': fcmToken},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      if (kDebugMode) print('Error updating FCM token: $e');
    }
  }

  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }
}
