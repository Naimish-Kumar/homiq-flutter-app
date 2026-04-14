import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homiq/core/error/failures.dart';
import 'package:homiq/data/model/article_model.dart';
import 'package:homiq/data/repositories/articles_repository.dart';

abstract class FetchArticlesState {}

class FetchArticlesInitial extends FetchArticlesState {}

class FetchArticlesInProgress extends FetchArticlesState {}

class FetchArticlesSuccess extends FetchArticlesState {
  FetchArticlesSuccess({
    required this.isLoadingMore,
    required this.loadingMoreError,
    required this.articlemodel,
    required this.offset,
    required this.total,
  });
  final bool isLoadingMore;
  final bool loadingMoreError;
  final List<ArticleModel> articlemodel;
  final int offset;
  final int total;

  FetchArticlesSuccess copyWith({
    bool? isLoadingMore,
    bool? loadingMoreError,
    List<ArticleModel>? articlemodel,
    int? offset,
    int? total,
  }) {
    return FetchArticlesSuccess(
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      articlemodel: articlemodel ?? this.articlemodel,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }
}

class FetchArticlesFailure extends FetchArticlesState {
  FetchArticlesFailure(this.errorMessage);
  final dynamic errorMessage;
}

class FetchArticlesCubit extends Cubit<FetchArticlesState> {
  FetchArticlesCubit() : super(FetchArticlesInitial());

  final ArticlesRepository _articleRepository = ArticlesRepository();

  Future<void> fetchArticles() async {
    try {
      emit(FetchArticlesInProgress());

      final result = await _articleRepository.fetchArticles();

      emit(
        FetchArticlesSuccess(
          isLoadingMore: false,
          loadingMoreError: false,
          articlemodel: result.modelList,
          offset: 0,
          total: result.total,
        ),
      );
    } on ApiException catch (e) {
      emit(FetchArticlesFailure(e));
    }
  }

 
  bool hasMoreData() {
    if (state is FetchArticlesSuccess) {
      return (state as FetchArticlesSuccess).articlemodel.length <
          (state as FetchArticlesSuccess).total;
    }
    return false;
  }
}
