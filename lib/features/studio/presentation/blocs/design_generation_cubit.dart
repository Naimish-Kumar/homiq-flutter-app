import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homiq/features/studio/domain/repositories/design_repository.dart';

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
  final DesignRepository _designRepository;
  DesignGenerationCubit(this._designRepository) : super(DesignGenerationInitial());

  Future<void> generate({required Map<String, dynamic> data}) async {
    emit(DesignGenerationInProgress());
    try {
      final result = await _designRepository.generateDesign(data: data);
      emit(DesignGenerationSuccess(result));
    } catch (e) {
      emit(DesignGenerationFailure(e.toString()));
    }
  }
}
