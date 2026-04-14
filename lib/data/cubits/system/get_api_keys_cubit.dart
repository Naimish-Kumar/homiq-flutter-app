import 'dart:developer';

import 'package:homiq/exports/main_export.dart';
import 'package:homiq/settings.dart';

class GetApiKeysCubit extends Cubit<GetApiKeysState> {
  GetApiKeysCubit() : super(GetApiKeysInitial());

 
  void setAPIKeys() {
    //setKeys
    if (state is GetApiKeysSuccess) {
      final st = state as GetApiKeysSuccess;

      AppSettings.paystackKey = st.paystackPublicKey;
      AppSettings.razorpayKey = st.razorPayKey;
      AppSettings.enabledPaymentGatway = st.enabledPaymentGatway;
      AppSettings.paystackCurrency = st.paystackCurrency;
      AppSettings.stripeCurrency = st.stripeCurrency;
      AppSettings.stripePublishableKey = st.stripePublishableKey;
    }
    if (state is GetApiKeysFail) {
      log((state as GetApiKeysFail).error.toString(), name: 'API KEY FAIL');
    }
  }

  Future<void> fetch() async {
    // Stub implementation
    emit(GetApiKeysInProgress());
    emit(GetApiKeysSuccess(
      bankTransferStatus: '0',
      razorPayKey: '',
      paystackPublicKey: '',
      paystackCurrency: '',
      enabledPaymentGatway: '',
      stripeCurrency: '',
      stripePublishableKey: '',
      stripeSecretKey: '',
      flutterwaveStatus: '0',
    ));
  }

}

abstract class GetApiKeysState {}

class GetApiKeysInitial extends GetApiKeysState {}

class GetApiKeysInProgress extends GetApiKeysState {}

class GetApiKeysSuccess extends GetApiKeysState {
  GetApiKeysSuccess({
    required this.bankTransferStatus,
    required this.razorPayKey,
    required this.paystackPublicKey,
    required this.paystackCurrency,
    required this.enabledPaymentGatway,
    required this.stripeCurrency,
    required this.stripePublishableKey,
    required this.stripeSecretKey,
    required this.flutterwaveStatus,
  });
  final String bankTransferStatus;
  final String razorPayKey;
  final String paystackPublicKey;
  final String paystackCurrency;
  final String enabledPaymentGatway;
  final String stripeCurrency;
  final String stripePublishableKey;
  final String stripeSecretKey;
  final String flutterwaveStatus;

  @override
  String toString() {
    return '''GetApiKeysSuccess(razorPayKey: $razorPayKey, paystackPublicKey: $paystackPublicKey, paystackCurrency: $paystackCurrency, enabledPaymentGatway: $enabledPaymentGatway, stripeCurrency: $stripeCurrency, stripePublishableKey: $stripePublishableKey, stripeSecretKey: $stripeSecretKey, flutterwaveStatus: $flutterwaveStatus)''';
  }
}

class GetApiKeysFail extends GetApiKeysState {
  GetApiKeysFail(this.error);
  final dynamic error;
}
