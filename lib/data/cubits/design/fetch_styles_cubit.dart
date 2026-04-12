import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homiq/data/repositories/design_repository.dart';

abstract class FetchStylesState {}

class FetchStylesInitial extends FetchStylesState {}

class FetchStylesInProgress extends FetchStylesState {}

class FetchStylesSuccess extends FetchStylesState {
  FetchStylesSuccess(this.styles);
  final List<dynamic> styles;
}

class FetchStylesFailure extends FetchStylesState {
  FetchStylesFailure(this.errorMessage);
  final String errorMessage;
}

class FetchStylesCubit extends Cubit<FetchStylesState> {
  FetchStylesCubit(this._designRepository) : super(FetchStylesInitial());
  final DesignRepository _designRepository;

  Future<void> fetchStyles() async {
    try {
      emit(FetchStylesInProgress());
      final result = await _designRepository.getStyles();
      emit(FetchStylesSuccess(result['data'] as List<dynamic>));
    } catch (e) {
      emit(FetchStylesFailure(e.toString()));
    }
  }
}
