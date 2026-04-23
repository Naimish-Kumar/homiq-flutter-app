import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../services/iap_service.dart';

// Events
abstract class SubscriptionEvent {}
class SubscriptionInitialize extends SubscriptionEvent {}
class SubscriptionPurchaseRequested extends SubscriptionEvent {
  final ProductDetails product;
  SubscriptionPurchaseRequested(this.product);
}
class SubscriptionRestoreRequested extends SubscriptionEvent {}
class SubscriptionLoadActive extends SubscriptionEvent {}
class _SubscriptionPurchaseUpdated extends SubscriptionEvent {
  final PurchaseDetails purchase;
  _SubscriptionPurchaseUpdated(this.purchase);
}

// State
class SubscriptionState {
  final List<ProductDetails> products;
  final bool isLoading;
  final String? error;
  final bool isPremium;
  final Map<String, dynamic>? activeSubscription;

  SubscriptionState({
    this.products = const [],
    this.isLoading = false,
    this.error,
    this.isPremium = false,
    this.activeSubscription,
  });

  SubscriptionState copyWith({
    List<ProductDetails>? products,
    bool? isLoading,
    String? error,
    bool? isPremium,
    Map<String, dynamic>? activeSubscription,
  }) {
    return SubscriptionState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isPremium: isPremium ?? this.isPremium,
      activeSubscription: activeSubscription ?? this.activeSubscription,
    );
  }
}

// Bloc
class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final IapService _iapService;
  late StreamSubscription _purchaseSubscription;

  SubscriptionBloc({required IapService iapService})
      : _iapService = iapService,
        super(SubscriptionState()) {
    on<SubscriptionInitialize>(_onInitialize);
    on<SubscriptionPurchaseRequested>(_onPurchase);
    on<SubscriptionRestoreRequested>(_onRestore);
    on<SubscriptionLoadActive>(_onLoadActive);
    on<_SubscriptionPurchaseUpdated>(_onPurchaseUpdated);

    _purchaseSubscription = _iapService.purchaseStream.listen(
      (purchase) => add(_SubscriptionPurchaseUpdated(purchase)),
    );
  }

  Future<void> _onInitialize(SubscriptionInitialize event, Emitter<SubscriptionState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final products = await _iapService.getProducts();
      emit(state.copyWith(products: products, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> _onPurchase(SubscriptionPurchaseRequested event, Emitter<SubscriptionState> emit) async {
    await _iapService.buyProduct(event.product);
  }

  Future<void> _onRestore(SubscriptionRestoreRequested event, Emitter<SubscriptionState> emit) async {
    await _iapService.restorePurchases();
  }

  void _onPurchaseUpdated(_SubscriptionPurchaseUpdated event, Emitter<SubscriptionState> emit) {
    if (event.purchase.status == PurchaseStatus.purchased || 
        event.purchase.status == PurchaseStatus.restored) {
      emit(state.copyWith(isPremium: true));
    } else if (event.purchase.status == PurchaseStatus.error) {
      emit(state.copyWith(error: 'Purchase failed'));
    }
  }

  Future<void> _onLoadActive(SubscriptionLoadActive event, Emitter<SubscriptionState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final activeSub = await _iapService.getActiveSubscription();
      emit(state.copyWith(
        activeSubscription: activeSub,
        isPremium: activeSub != null,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  @override
  Future<void> close() {
    _purchaseSubscription.cancel();
    return super.close();
  }
}
