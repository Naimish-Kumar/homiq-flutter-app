import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homiq/features/profile/data/models/subscription_package_model.dart';

abstract class FetchSubscriptionPackagesState {}

class FetchSubscriptionPackagesInitial extends FetchSubscriptionPackagesState {}

class FetchSubscriptionPackagesInProgress
    extends FetchSubscriptionPackagesState {}

class FetchSubscriptionPackagesSuccess extends FetchSubscriptionPackagesState {
  FetchSubscriptionPackagesSuccess({
    required this.packageResponseModel,
    required this.isLoadingMore,
    required this.hasError,
    required this.offset,
    required this.total,
  });
  final PackageResponseModel packageResponseModel;
  final bool isLoadingMore;
  final bool hasError;
  final int offset;
  final int total;

  FetchSubscriptionPackagesSuccess copyWith({
    PackageResponseModel? packageResponseModel,
    bool? isLoadingMore,
    bool? hasError,
    int? offset,
    int? total,
  }) {
    return FetchSubscriptionPackagesSuccess(
      packageResponseModel: packageResponseModel ?? this.packageResponseModel,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }
}

class FetchSubscriptionPackagesFailure extends FetchSubscriptionPackagesState {
  FetchSubscriptionPackagesFailure(this.errorMessage);
  final dynamic errorMessage;
}

class FetchSubscriptionPackagesCubit
    extends Cubit<FetchSubscriptionPackagesState> {
  FetchSubscriptionPackagesCubit() : super(FetchSubscriptionPackagesInitial());
 

  bool hasMore() {
    if (state is FetchSubscriptionPackagesSuccess) {
      return (state as FetchSubscriptionPackagesSuccess)
              .packageResponseModel
              .subscriptionPackage
              .length <
          (state as FetchSubscriptionPackagesSuccess).total;
    }
    return false;
  }

  }
