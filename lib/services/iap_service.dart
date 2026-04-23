import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage In-App Purchases with server-side receipt verification.
class IapService {
  final InAppPurchase _iap = InAppPurchase.instance;
  final Dio _dio;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // Product IDs — must match App Store Connect & Google Play Console
  static const String proMonthlyId = 'homiq_pro_monthly';
  static const String platinumMonthlyId = 'homiq_platinum_monthly';
  static const String _tokenKey = 'auth_token';

  final _purchaseController = StreamController<PurchaseDetails>.broadcast();
  Stream<PurchaseDetails> get purchaseStream => _purchaseController.stream;

  /// Whether the last verification succeeded.
  bool _lastVerificationSucceeded = false;
  bool get lastVerificationSucceeded => _lastVerificationSucceeded;

  IapService(this._dio) {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      (purchaseDetailsList) {
        _handlePurchaseUpdates(purchaseDetailsList);
      },
      onDone: () => _subscription.cancel(),
      onError: (error) {
        if (kDebugMode) print('IAP Error: $error');
      },
    );
  }

  Future<bool> isAvailable() async {
    return await _iap.isAvailable();
  }

  Future<List<ProductDetails>> getProducts() async {
    final Set<String> ids = {proMonthlyId, platinumMonthlyId};
    final ProductDetailsResponse response = await _iap.queryProductDetails(ids);

    if (response.error != null) {
      if (kDebugMode) print('Product query error: ${response.error}');
      return [];
    }

    return response.productDetails;
  }

  Future<void> buyProduct(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  Future<Map<String, dynamic>?> getActiveSubscription() async {
    try {
      final token = await _getAuthToken();
      if (token == null) return null;

      final response = await _dio.get(
        '/api/subscription/status',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data['success'] == true) {
        return response.data['subscription'];
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching active sub: $e');
    }
    return null;
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.pending) {
        // Purchase is pending — UI should show a loading state
        if (kDebugMode) print('IAP: Purchase pending...');
      } else if (purchase.status == PurchaseStatus.error) {
        if (kDebugMode) print('IAP: Purchase error — ${purchase.error}');
      } else if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // Verify the purchase receipt with our backend
        _verifyPurchase(purchase);
      }

      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }

      _purchaseController.add(purchase);
    }
  }

  /// Verify the purchase receipt with the backend server.
  ///
  /// Sends the store receipt/token to `/api/subscription/purchase` which
  /// records the subscription and returns success. This ensures that
  /// purchases are validated server-side and not spoofed.
  Future<void> _verifyPurchase(PurchaseDetails purchase) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        if (kDebugMode) print('IAP: No auth token — cannot verify purchase');
        _lastVerificationSucceeded = false;
        return;
      }

      // Determine platform
      final platform = Platform.isIOS ? 'ios' : 'android';

      // Extract the receipt / purchase token
      final String receiptData;
      if (Platform.isIOS) {
        // iOS: the verification data is the App Store receipt
        receiptData = purchase.verificationData.serverVerificationData;
      } else {
        // Android: the verification data is the purchase token
        receiptData = purchase.verificationData.serverVerificationData;
      }

      // Map product ID to package info
      final packageInfo = _getPackageInfo(purchase.productID);

      final response = await _dio.post(
        '/api/subscription/purchase',
        data: {
          'package_id': packageInfo['id'],
          'package_name': packageInfo['name'],
          'transaction_id': purchase.purchaseID ?? '',
          'platform': platform,
          'amount': packageInfo['amount'],
          'receipt_data': receiptData,
          'product_id': purchase.productID,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data['success'] == true) {
        _lastVerificationSucceeded = true;
        if (kDebugMode) {
          print('IAP: Purchase verified successfully on server');
        }
      } else {
        _lastVerificationSucceeded = false;
        if (kDebugMode) {
          print('IAP: Server rejected purchase — ${response.data['message']}');
        }
      }
    } catch (e) {
      _lastVerificationSucceeded = false;
      if (kDebugMode) {
        print('IAP: Verification failed — $e');
      }
    }
  }

  /// Map product IDs to package metadata for the backend.
  Map<String, dynamic> _getPackageInfo(String productId) {
    switch (productId) {
      case proMonthlyId:
        return {'id': 2, 'name': 'Pro', 'amount': 499};
      case platinumMonthlyId:
        return {'id': 3, 'name': 'Platinum', 'amount': 999};
      default:
        return {'id': 1, 'name': 'Basic', 'amount': 0};
    }
  }

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  void dispose() {
    _subscription.cancel();
    _purchaseController.close();
  }
}
