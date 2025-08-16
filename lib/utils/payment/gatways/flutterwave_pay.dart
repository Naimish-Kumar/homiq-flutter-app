import 'dart:developer';

import 'package:homiq/data/model/subscription_pacakage_model.dart';
import 'package:homiq/exports/main_export.dart';
import 'package:homiq/utils/payment/gatways/flutterwave.dart';
import 'package:homiq/utils/payment/lib/payment.dart';
import 'package:homiq/utils/payment/lib/purchase_package.dart';

class Flutterwave extends Payment {
  SubscriptionPackageModel? _modal;
  @override
  void pay(BuildContext context) {
    if (_modal == null) {
      log('Please set modal');
    }
    isPaymentGatewayOpen = true;
    Navigator.push<dynamic>(
      context,
      CupertinoPageRoute(
        builder: (context) {
          return FlutterwaveWidget(
            pacakge: _modal!,
            onSuccess: (msg) {
              isPaymentGatewayOpen = false;
              Navigator.pop(context, {
                'msg': msg,
                'type': 'success',
              });
            },
            onFail: (msg) {
              isPaymentGatewayOpen = false;
              Navigator.pop(context, {'msg': msg, 'type': 'fail'});
            },
          );
        },
      ),
    );
  }

  @override
  Flutterwave setPackage(SubscriptionPackageModel modal) {
    _modal = modal;
    return this;
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
