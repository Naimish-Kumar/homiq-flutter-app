import 'dart:developer';

import 'package:homiq/data/repositories/auth_repository.dart';
import 'package:homiq/exports/main_export.dart';

String verificationID = '';

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
  static const Duration _cooldownPeriod = Duration(minutes: 1);
  static DateTime? _lastRequestTime;
  static String? _lastIdentifier;

  /// Simplified OTP sending for any identifier (Email or Mobile)
  Future<void> sendOtp({
    required String identifier,
    required String type,
  }) async {
    if (state is SendOtpInProgress) return;

    // Check cooldown period
    final now = DateTime.now();
    if (_lastRequestTime != null && _lastIdentifier == identifier) {
      final timeSinceLastRequest = now.difference(_lastRequestTime!);
      if (timeSinceLastRequest < _cooldownPeriod) {
        final remainingTime = _cooldownPeriod - timeSinceLastRequest;
        emit(
          SendOtpFailure(
            'Please wait ${remainingTime.inSeconds} seconds before requesting another OTP.',
          ),
        );
        return;
      }
    }

    emit(SendOtpInProgress());

    try {
      _lastRequestTime = now;
      _lastIdentifier = identifier;

      final result = await _authRepository.sendOtp(
        identifier: identifier,
        type: type,
      );
      log(result.toString());
      if (result['success'] == true) {
        emit(SendOtpSuccess(message: result['message']?.toString()));
      } else {
        emit(
          SendOtpFailure(result['message']?.toString() ?? 'Failed to send OTP'),
        );
      }
    } catch (e) {
      emit(SendOtpFailure(e.toString()));
    }
  }
}
