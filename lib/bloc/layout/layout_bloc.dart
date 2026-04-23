import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/layout_model.dart';
import '../../services/layout_service.dart';

// Events
abstract class LayoutEvent {}

class LoadLayouts extends LayoutEvent {}

class CreateLayout extends LayoutEvent {
  final String name;
  final File floorPlan;
  CreateLayout(this.name, this.floorPlan);
}

class DeleteLayout extends LayoutEvent {
  final int id;
  DeleteLayout(this.id);
}

// States
abstract class LayoutState {}

class LayoutInitial extends LayoutState {}

class LayoutLoading extends LayoutState {}

class LayoutLoaded extends LayoutState {
  final List<LayoutModel> layouts;
  LayoutLoaded(this.layouts);
}

class LayoutSuccess extends LayoutState {
  final LayoutModel layout;
  LayoutSuccess(this.layout);
}

class LayoutError extends LayoutState {
  final String message;
  LayoutError(this.message);
}

// BLoC
class LayoutBloc extends Bloc<LayoutEvent, LayoutState> {
  final LayoutService _layoutService;

  LayoutBloc(this._layoutService) : super(LayoutInitial()) {
    on<LoadLayouts>(_onLoadLayouts);
    on<CreateLayout>(_onCreateLayout);
    on<DeleteLayout>(_onDeleteLayout);
  }

  Future<void> _onLoadLayouts(LoadLayouts event, Emitter<LayoutState> emit) async {
    try {
      emit(LayoutLoading());
      final layouts = await _layoutService.getLayouts();
      emit(LayoutLoaded(layouts));
    } catch (e) {
      emit(LayoutError(e.toString()));
    }
  }

  Future<void> _onCreateLayout(CreateLayout event, Emitter<LayoutState> emit) async {
    try {
      emit(LayoutLoading());
      final layout = await _layoutService.createLayout(event.name, event.floorPlan);
      emit(LayoutSuccess(layout));
      add(LoadLayouts()); // Refresh list
    } catch (e) {
      emit(LayoutError(e.toString()));
    }
  }

  Future<void> _onDeleteLayout(DeleteLayout event, Emitter<LayoutState> emit) async {
    try {
      await _layoutService.deleteLayout(event.id);
      add(LoadLayouts());
    } catch (e) {
      emit(LayoutError(e.toString()));
    }
  }
}
