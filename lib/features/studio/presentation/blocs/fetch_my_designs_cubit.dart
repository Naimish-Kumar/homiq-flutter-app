import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homiq/features/studio/domain/repositories/design_repository.dart';

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
  final DesignRepository _designRepository;
  FetchMyDesignsCubit(this._designRepository) : super(FetchMyDesignsInitial());

  Future<void> fetchMyDesigns() async {
    try {
      final designs = await _designRepository.fetchMyDesigns();
      emit(FetchMyDesignsSuccess(designs));
    } catch (e) {
      emit(FetchMyDesignsFailure(e.toString()));
    }
  }

  Future<void> fetch() => fetchMyDesigns();
}
