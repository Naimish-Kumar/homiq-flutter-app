import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homiq/features/auth/data/repositories_impl/auth_repository_impl.dart';

abstract class VerifyOtpState {}
class VerifyOtpInitial extends VerifyOtpState {}
class VerifyOtpInProgress extends VerifyOtpState {}
class VerifyOtpSuccess extends VerifyOtpState {
  VerifyOtpSuccess({this.accessToken});
  final String? accessToken;
}
class VerifyOtpFailure extends VerifyOtpState {
  VerifyOtpFailure(this.errorMessage);
  final String errorMessage;
}

class VerifyOtpCubit extends Cubit<VerifyOtpState> {
  VerifyOtpCubit() : super(VerifyOtpInitial());
  final AuthRepository _authRepository = AuthRepository();
  Future<void> verifyOtp({
    required String identifier,
    required String otp,
    required String type,
  }) async {
    emit(VerifyOtpInProgress());
    try {
      final result = await _authRepository.verifyOtp(
        identifier: identifier,
        otp: otp,
        type: type,
      );
      if (result['success'] == true) {
        emit(VerifyOtpSuccess(accessToken: result['token'] ?? result['access_token']));
      } else {
        emit(VerifyOtpFailure(result['message']?.toString() ?? 'Failed'));
      }
    } catch (e) {
      emit(VerifyOtpFailure(e.toString()));
    }
  }
}
