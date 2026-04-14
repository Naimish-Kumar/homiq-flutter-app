import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homiq/features/home/data/models/home_page_data_model.dart';
import 'package:homiq/features/home/data/repositories_impl/home_screen_data_repository_impl.dart';

abstract class FetchHomePageDataState {}

class FetchHomePageDataInitial extends FetchHomePageDataState {}

class FetchHomePageDataInProgress extends FetchHomePageDataState {}

class FetchHomePageDataSuccess extends FetchHomePageDataState {
  FetchHomePageDataSuccess(this.homePageData);
  final HomePageDataModel homePageData;
}

class FetchHomePageDataFailure extends FetchHomePageDataState {
  FetchHomePageDataFailure(this.errorMessage);
  final String errorMessage;
}

class FetchHomePageDataCubit extends Cubit<FetchHomePageDataState> {
  FetchHomePageDataCubit() : super(FetchHomePageDataInitial());
  final HomeScreenDataRepository _repository = HomeScreenDataRepository();
  Future<void> fetch() async {
    emit(FetchHomePageDataInProgress());
    try {
      final result = await _repository.fetchHomePageData();
      emit(FetchHomePageDataSuccess(result));
    } catch (e) {
      emit(FetchHomePageDataFailure(e.toString()));
    }
  }
}
