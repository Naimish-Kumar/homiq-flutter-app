import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homiq/data/repositories/design_repository.dart';

abstract class DesignGenerationState {}

class DesignGenerationInitial extends DesignGenerationState {}

class DesignGenerationInProgress extends DesignGenerationState {}

class DesignGenerationSuccess extends DesignGenerationState {
  DesignGenerationSuccess(this.result);
  final Map<String, dynamic> result;
}

class DesignGenerationFailure extends DesignGenerationState {
  DesignGenerationFailure(this.errorMessage);
  final String errorMessage;
}

class DesignGenerationCubit extends Cubit<DesignGenerationState> {
  DesignGenerationCubit(this._designRepository) : super(DesignGenerationInitial());
  final DesignRepository _designRepository;

  Future<void> generateDesign({
    required File image,
    required String styleId,
    String? budget,
  }) async {
    try {
      emit(DesignGenerationInProgress());
      final result = await _designRepository.generateDesign(
        image: image,
        styleId: styleId,
        budget: budget,
      );
      emit(DesignGenerationSuccess(result['data'] as Map<String, dynamic>));
    } catch (e) {
      emit(DesignGenerationFailure(e.toString()));
    }
  }
}
