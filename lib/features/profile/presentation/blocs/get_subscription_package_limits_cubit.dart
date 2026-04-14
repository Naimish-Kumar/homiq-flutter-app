import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homiq/core/enums/package_type.dart';

abstract class GetSubscriptionPackageLimitsState {}

class GetSubscriptionPackageLimitsInitial extends GetSubscriptionPackageLimitsState {}

class GetSubscriptionPackageLimitsInProgress extends GetSubscriptionPackageLimitsState {}

class GetSubscriptionPackageLimitsSuccess extends GetSubscriptionPackageLimitsState {
  final Map<PackageType, int> limits;
  final Map<PackageType, int> used;

  GetSubscriptionPackageLimitsSuccess({
    required this.limits,
    required this.used,
  });

  bool hasReachedLimit(PackageType type) {
    if (!limits.containsKey(type)) return false;
    return (used[type] ?? 0) >= (limits[type] ?? 0);
  }
}

class GetSubscriptionPackageLimitsFailure extends GetSubscriptionPackageLimitsState {
  final String errorMessage;
  GetSubscriptionPackageLimitsFailure(this.errorMessage);
}

class GetSubscriptionPackageLimitsCubit extends Cubit<GetSubscriptionPackageLimitsState> {
  GetSubscriptionPackageLimitsCubit() : super(GetSubscriptionPackageLimitsInitial());

  Future<void> fetchLimits() async {
    emit(GetSubscriptionPackageLimitsInProgress());
    try {
      // Mocking limits based on requirements: 3 free designs
      // In a real app, this would fetch from backend API
      final Map<PackageType, int> mockLimits = {
        PackageType.designGeneration: 3,
      };
      final Map<PackageType, int> mockUsed = {
        PackageType.designGeneration: 0,
      };

      emit(GetSubscriptionPackageLimitsSuccess(
        limits: mockLimits,
        used: mockUsed,
      ));
    } catch (e) {
      emit(GetSubscriptionPackageLimitsFailure(e.toString()));
    }
  }
}
