import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:homiq/exports/main_export.dart';
import 'package:homiq/utils/login/lib/login_status.dart';
import 'package:homiq/utils/login/lib/login_system.dart';

class GoogleLogin extends LoginSystem {
  GoogleSignIn? _googleSignIn;
  static const Duration _timeoutDuration = Duration(seconds: 30);

  @override
  Future<void> init() async {
    _googleSignIn = GoogleSignIn(
      scopes: ['profile', 'email'],
    );
  }

  @override
  Future<UserCredential?> login() async {
    try {
      emit(MProgress());
      
      // Add timeout to prevent hanging
      final googleSignIn = await _googleSignIn?.signIn()
          .timeout(_timeoutDuration, onTimeout: () => null);

      if (googleSignIn == null) {
        emit(MFail('google-terminated'));
        return null;
      }
      
      // Get authentication with timeout
      final googleAuth = await googleSignIn.authentication
          .timeout(_timeoutDuration);

      final AuthCredential authCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase sign-in with timeout
      final userCredential = await firebaseAuth
          .signInWithCredential(authCredential)
          .timeout(_timeoutDuration);
          
      emit(MSuccess(userCredential, type: 'google'));
      return userCredential;
      
    } on TimeoutException catch (_) {
      emit(MFail('connectionTimeout'.translate(context!)));
    } on PlatformException catch (e) {
      if (e.code == 'network_error') {
        emit(MFail('noInternet'.translate(context!)));
      } else if (e.code == 'sign_in_canceled') {
        emit(MFail('google-terminated'));
      } else {
        emit(MFail('googleLoginFailed'.translate(context!)));
      }
    } on FirebaseAuthException catch (e) {
      emit(MFail(ErrorFilter.check(e.code)));
    } on Exception catch (_) {
      emit(MFail('googleLoginFailed'.translate(context!)));
    }
    return null;
  }

  @override
  void onEvent(MLoginState state) {
    if (kDebugMode) print('MLoginState is: $state');
  }
  
  // Add method to clear cached sign-in for faster subsequent logins
  Future<void> signOut() async {
    await _googleSignIn?.signOut();
  }
}
