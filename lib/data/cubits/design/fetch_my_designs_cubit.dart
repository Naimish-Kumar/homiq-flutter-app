import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homiq/data/repositories/design_repository.dart';

abstract class FetchMyDesignsState {}

class FetchMyDesignsInitial extends FetchMyDesignsState {}

class FetchMyDesignsInProgress extends FetchMyDesignsState {}

class FetchMyDesignsSuccess extends FetchMyDesignsState {
  FetchMyDesignsSuccess(this.designs);
  final List<dynamic> designs;
}

class FetchMyDesignsFailure extends FetchMyDesignsState {
  FetchMyDesignsFailure(this.errorMessage);
  final String errorMessage;
}

class FetchMyDesignsCubit extends Cubit<FetchMyDesignsState> {
  FetchMyDesignsCubit(this._designRepository) : super(FetchMyDesignsInitial());
  final DesignRepository _designRepository;

  Future<void> fetchMyDesigns() async {
    try {
      emit(FetchMyDesignsInProgress());
      final result = await _designRepository.getMyDesigns();
      emit(FetchMyDesignsSuccess(result['data'] as List<dynamic>));
    } catch (e) {
      emit(FetchMyDesignsFailure(e.toString()));
    }
  }
}
