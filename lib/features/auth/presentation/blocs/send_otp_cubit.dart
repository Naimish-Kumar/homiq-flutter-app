
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homiq/features/auth/data/repositories_impl/auth_repository_impl.dart';

abstract class SendOtpState {}
class SendOtpInitial extends SendOtpState {}
class SendOtpInProgress extends SendOtpState {}
class SendOtpSuccess extends SendOtpState {
  SendOtpSuccess({this.verificationId, this.message});
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
  Future<void> sendOtp({required String identifier, required String type}) async {
    emit(SendOtpInProgress());
    try {
      final result = await _authRepository.sendOtp(identifier: identifier, type: type);
      if (result['success'] == true) {
        emit(SendOtpSuccess(message: result['message']?.toString()));
      } else {
        emit(SendOtpFailure(result['message']?.toString() ?? 'Failed'));
      }
    } catch (e) {
      emit(SendOtpFailure(e.toString()));
    }
  }
}
