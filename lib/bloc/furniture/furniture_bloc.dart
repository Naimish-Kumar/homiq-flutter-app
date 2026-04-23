import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/furniture_model.dart';
import '../../services/furniture_service.dart';

// Events
abstract class FurnitureEvent {}

class LoadFurniture extends FurnitureEvent {
  final String? category;
  final int? styleId;
  final String? search;
  final bool refresh;

  LoadFurniture({this.category, this.styleId, this.search, this.refresh = false});
}

class LoadMoreFurniture extends FurnitureEvent {}

class LoadCategories extends FurnitureEvent {}

// States
abstract class FurnitureState {}

class FurnitureInitial extends FurnitureState {}

class FurnitureLoading extends FurnitureState {}

class FurnitureLoaded extends FurnitureState {
  final List<FurnitureModel> products;
  final List<String> categories;
  final int currentPage;
  final int lastPage;
  final String? currentCategory;
  final int? currentStyleId;
  final String? currentSearch;

  FurnitureLoaded({
    required this.products,
    required this.categories,
    required this.currentPage,
    required this.lastPage,
    this.currentCategory,
    this.currentStyleId,
    this.currentSearch,
  });

  FurnitureLoaded copyWith({
    List<FurnitureModel>? products,
    List<String>? categories,
    int? currentPage,
    int? lastPage,
    String? currentCategory,
    int? currentStyleId,
    String? currentSearch,
  }) {
    return FurnitureLoaded(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      currentCategory: currentCategory ?? this.currentCategory,
      currentStyleId: currentStyleId ?? this.currentStyleId,
      currentSearch: currentSearch ?? this.currentSearch,
    );
  }
}

class FurnitureError extends FurnitureState {
  final String message;
  FurnitureError(this.message);
}

// BLoC
class FurnitureBloc extends Bloc<FurnitureEvent, FurnitureState> {
  final FurnitureService _furnitureService;

  FurnitureBloc(this._furnitureService) : super(FurnitureInitial()) {
    on<LoadFurniture>(_onLoadFurniture);
    on<LoadMoreFurniture>(_onLoadMoreFurniture);
    on<LoadCategories>(_onLoadCategories);
  }

  Future<void> _onLoadFurniture(LoadFurniture event, Emitter<FurnitureState> emit) async {
    try {
      emit(FurnitureLoading());
      
      final categories = await _furnitureService.getCategories();
      final result = await _furnitureService.getProducts(
        category: event.category,
        styleId: event.styleId,
        search: event.search,
      );

      emit(FurnitureLoaded(
        products: result['products'],
        categories: categories,
        currentPage: result['currentPage'],
        lastPage: result['lastPage'],
        currentCategory: event.category,
        currentStyleId: event.styleId,
        currentSearch: event.search,
      ));
    } catch (e) {
      emit(FurnitureError(e.toString()));
    }
  }

  Future<void> _onLoadMoreFurniture(LoadMoreFurniture event, Emitter<FurnitureState> emit) async {
    final currentState = state;
    if (currentState is FurnitureLoaded && currentState.currentPage < currentState.lastPage) {
      try {
        final nextPage = currentState.currentPage + 1;
        final result = await _furnitureService.getProducts(
          page: nextPage,
          category: currentState.currentCategory,
          styleId: currentState.currentStyleId,
          search: currentState.currentSearch,
        );

        emit(currentState.copyWith(
          products: [...currentState.products, ...result['products']],
          currentPage: result['currentPage'],
        ));
      } catch (e) {
        // Silently fail for "load more" or emit a specific error state
      }
    }
  }

  Future<void> _onLoadCategories(LoadCategories event, Emitter<FurnitureState> emit) async {
    // This is usually handled within LoadFurniture, but can be separate if needed
  }
}
