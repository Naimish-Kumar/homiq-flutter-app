import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/moodboard_model.dart';
import '../../services/moodboard_service.dart';

// Events
abstract class MoodboardEvent {}

class LoadMoodboards extends MoodboardEvent {}

class CreateMoodboard extends MoodboardEvent {
  final String title;
  final String? description;
  final int? styleId;
  final List<String>? colorPalette;
  final List<String>? items;
  CreateMoodboard({
    required this.title,
    this.description,
    this.styleId,
    this.colorPalette,
    this.items,
  });
}

class UpdateMoodboard extends MoodboardEvent {
  final int id;
  final String? title;
  final String? description;
  final int? styleId;
  final List<String>? colorPalette;
  final List<String>? items;
  UpdateMoodboard(this.id, {
    this.title,
    this.description,
    this.styleId,
    this.colorPalette,
    this.items,
  });
}

class DeleteMoodboard extends MoodboardEvent {
  final int id;
  DeleteMoodboard(this.id);
}

// States
abstract class MoodboardState {}

class MoodboardInitial extends MoodboardState {}

class MoodboardLoading extends MoodboardState {}

class MoodboardLoaded extends MoodboardState {
  final List<MoodboardModel> moodboards;
  MoodboardLoaded(this.moodboards);
}

class MoodboardOperationSuccess extends MoodboardState {
  final String message;
  MoodboardOperationSuccess(this.message);
}

class MoodboardError extends MoodboardState {
  final String message;
  MoodboardError(this.message);
}

// Bloc
class MoodboardBloc extends Bloc<MoodboardEvent, MoodboardState> {
  final MoodboardService _service;

  MoodboardBloc(this._service) : super(MoodboardInitial()) {
    on<LoadMoodboards>(_onLoadMoodboards);
    on<CreateMoodboard>(_onCreateMoodboard);
    on<UpdateMoodboard>(_onUpdateMoodboard);
    on<DeleteMoodboard>(_onDeleteMoodboard);
  }

  Future<void> _onLoadMoodboards(LoadMoodboards event, Emitter<MoodboardState> emit) async {
    emit(MoodboardLoading());
    try {
      final moodboards = await _service.getMoodboards();
      emit(MoodboardLoaded(moodboards));
    } catch (e) {
      emit(MoodboardError(e.toString()));
    }
  }

  Future<void> _onCreateMoodboard(CreateMoodboard event, Emitter<MoodboardState> emit) async {
    emit(MoodboardLoading());
    try {
      await _service.createMoodboard(
        title: event.title,
        description: event.description,
        styleId: event.styleId,
        colorPalette: event.colorPalette,
        items: event.items,
      );
      emit(MoodboardOperationSuccess('Moodboard created successfully'));
      add(LoadMoodboards());
    } catch (e) {
      emit(MoodboardError(e.toString()));
    }
  }

  Future<void> _onUpdateMoodboard(UpdateMoodboard event, Emitter<MoodboardState> emit) async {
    emit(MoodboardLoading());
    try {
      await _service.updateMoodboard(
        event.id,
        title: event.title,
        description: event.description,
        styleId: event.styleId,
        colorPalette: event.colorPalette,
        items: event.items,
      );
      emit(MoodboardOperationSuccess('Moodboard updated successfully'));
      add(LoadMoodboards());
    } catch (e) {
      emit(MoodboardError(e.toString()));
    }
  }

  Future<void> _onDeleteMoodboard(DeleteMoodboard event, Emitter<MoodboardState> emit) async {
    emit(MoodboardLoading());
    try {
      await _service.deleteMoodboard(event.id);
      emit(MoodboardOperationSuccess('Moodboard deleted successfully'));
      add(LoadMoodboards());
    } catch (e) {
      emit(MoodboardError(e.toString()));
    }
  }
}
