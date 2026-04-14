import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homiq/features/studio/domain/repositories/design_repository.dart';

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
  final DesignRepository _designRepository;
  FetchStylesCubit(this._designRepository) : super(FetchStylesInitial());

  Future<void> fetchStyles() async {
    try {
      final styles = await _designRepository.fetchStyles();
      emit(FetchStylesSuccess(styles));
    } catch (e) {
      emit(FetchStylesFailure(e.toString()));
    }
  }

  Future<void> fetch() => fetchStyles();
}
