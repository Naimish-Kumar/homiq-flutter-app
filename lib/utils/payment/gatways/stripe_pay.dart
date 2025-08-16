import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:homiq/data/model/subscription_pacakage_model.dart';
import 'package:homiq/settings.dart';
import 'package:homiq/utils/hive_utils.dart';
import 'package:homiq/utils/payment/gatways/stripe_service.dart';
import 'package:homiq/utils/payment/lib/payment.dart';
import 'package:homiq/utils/payment/lib/purchase_package.dart';

class Stripe extends Payment {
  late SubscriptionPackageModel? _modal;

  @override
  Stripe setPackage(SubscriptionPackageModel modal) {
    _modal = modal;
    return this;
  }

  @override
  Future<void> pay(BuildContext context) async {
    try {
      StripeService.init(
        stripePublishable: AppSettings.stripePublishableKey,
        stripeSecrate: AppSettings.stripeSecrateKey,
      );

      final response = await StripeService.payWithPaymentSheet(
        amount: _modal!.price * 100, // Make sure to convert to int
        currency: AppSettings.stripeCurrency,
        isTestEnvironment: true,
        awaitedOrderId: _modal!.id.toString(),
        metadata: {
          'packageName': _modal!.name,
          'packageId': _modal!.id,
          'userId': HiveUtils.getUserId(),
        },
      );

      if (response.status == 'succeeded') {
        emit(Success(message: 'Success'));
      } else {
        await StripeService.paymentTransactionFail(
          paymentTransactionID: StripeService.paymentTransactionID ?? '',
        );
        emit(Failure(message: 'Fail'));
      }
    } on Exception catch (e) {
      log('ERROR IS $e');
    }
  }

  @override
  Future<void> onEvent(
    BuildContext context,
    covariant PaymentStatus currentStatus,
  ) async {
    if (currentStatus is Success) {
      await PurchasePackage().purchase(context);
    }
  }
}
