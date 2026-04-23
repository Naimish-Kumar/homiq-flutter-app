// lib/bloc/design/design_bloc.dart
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/design_model.dart';
import '../../services/design_service.dart';
import '../../services/design_cache_service.dart';

part 'design_event.dart';
part 'design_state.dart';

class DesignBloc extends Bloc<DesignEvent, DesignState> {
  final DesignService _designService;

  DesignBloc({required DesignService designService})
      : _designService = designService,
        super(DesignInitial()) {
    on<DesignUploadImage>(_onUploadImage);
    on<DesignSelectStyle>(_onSelectStyle);
    on<DesignSelectBudget>(_onSelectBudget);
    on<DesignGenerate>(_onGenerate);
    on<DesignSave>(_onSave);
    on<DesignLoadHistory>(_onLoadHistory);
    on<DesignReset>(_onReset);
    on<DesignToggleFavorite>(_onToggleFavorite);
    on<DesignDelete>(_onDelete);
    on<DesignLoadFavorites>(_onLoadFavorites);
    on<DesignLoadStyles>(_onLoadStyles);
  }

  File? _selectedImage;
  dynamic _selectedStyle;

  Future<void> _onUploadImage(
      DesignUploadImage event, Emitter<DesignState> emit) async {
    _selectedImage = event.image;
    emit(DesignImageSelected(image: event.image));
  }

  Future<void> _onSelectStyle(
      DesignSelectStyle event, Emitter<DesignState> emit) async {
    _selectedStyle = event.style;
    if (state is DesignImageSelected) {
      emit(DesignStyleSelected(
        image: (state as DesignImageSelected).image,
        style: event.style,
      ));
    } else if (state is DesignStyleSelected) {
      emit(DesignStyleSelected(
        image: (state as DesignStyleSelected).image,
        style: event.style,
      ));
    } else if (state is DesignBudgetSelected) {
      emit(DesignBudgetSelected(
        image: (state as DesignBudgetSelected).image,
        style: event.style,
        budget: (state as DesignBudgetSelected).budget,
      ));
    }
  }

  Future<void> _onSelectBudget(
      DesignSelectBudget event, Emitter<DesignState> emit) async {
    if (_selectedImage != null && _selectedStyle != null) {
      emit(DesignBudgetSelected(
        image: _selectedImage!,
        style: _selectedStyle!,
        budget: event.budget,
      ));
    }
  }

  Future<void> _onGenerate(
      DesignGenerate event, Emitter<DesignState> emit) async {
    emit(DesignGenerating());
    try {
      final design = await _designService.generateDesign(
        image: event.image,
        style: event.style,
        budget: event.budget,
        roomType: event.roomType,
        userId: event.userId,
      );
      emit(DesignCompleted(design: design));
      // Cache newly generated design
      await DesignCacheService.addDesignToCache(design);
    } catch (e) {
      emit(DesignError(message: e.toString()));
    }
  }

  Future<void> _onSave(DesignSave event, Emitter<DesignState> emit) async {
    try {
      final isFavorite = await _designService.toggleFavorite(event.designId);
      if (state is DesignCompleted) {
        final design = (state as DesignCompleted).design;
        emit(DesignCompleted(design: design.copyWith(isFavorite: isFavorite)));
      }
    } catch (e) {
      // silently fail save
    }
  }

  Future<void> _onToggleFavorite(
      DesignToggleFavorite event, Emitter<DesignState> emit) async {
    try {
      final isFavorite = await _designService.toggleFavorite(event.designId);

      if (state is DesignHistoryLoaded) {
        final designs = (state as DesignHistoryLoaded).designs.map((d) {
          if (d.id == event.designId) {
            return d.copyWith(isFavorite: isFavorite);
          }
          return d;
        }).toList();
        emit(DesignHistoryLoaded(designs: designs));
      } else if (state is DesignCompleted) {
        final design = (state as DesignCompleted).design;
        if (design.id == event.designId) {
          emit(DesignCompleted(design: design.copyWith(isFavorite: isFavorite)));
        }
      }
    } catch (e) {
      // silently fail
    }
  }

  Future<void> _onDelete(
      DesignDelete event, Emitter<DesignState> emit) async {
    try {
      await _designService.deleteDesign(event.designId);

      if (state is DesignHistoryLoaded) {
        final designs = (state as DesignHistoryLoaded)
            .designs
            .where((d) => d.id != event.designId)
            .toList();
        emit(DesignHistoryLoaded(designs: designs));
      }
    } catch (e) {
      emit(DesignError(message: 'Failed to delete design'));
    }
  }

  Future<void> _onLoadFavorites(
      DesignLoadFavorites event, Emitter<DesignState> emit) async {
    emit(DesignHistoryLoading());
    try {
      final designs = await _designService.getFavorites(event.userId);
      emit(DesignHistoryLoaded(designs: designs));
    } catch (e) {
      emit(DesignError(message: e.toString()));
    }
  }

  Future<void> _onLoadHistory(
      DesignLoadHistory event, Emitter<DesignState> emit) async {
    emit(DesignHistoryLoading());

    // Serve cached designs first for instant UI
    final cached = await DesignCacheService.getCachedDesigns();
    if (cached != null && cached.isNotEmpty) {
      emit(DesignHistoryLoaded(designs: cached));
    }

    try {
      final designs = await _designService.getDesignHistory(event.userId);
      await DesignCacheService.cacheDesigns(designs);
      emit(DesignHistoryLoaded(designs: designs));
    } catch (e) {
      // If we already emitted cached data, don't show error
      if (cached == null || cached.isEmpty) {
        emit(DesignError(message: e.toString()));
      }
    }
  }

  Future<void> _onReset(DesignReset event, Emitter<DesignState> emit) async {
    _selectedImage = null;
    _selectedStyle = null;
    emit(DesignInitial());
  }

  Future<void> _onLoadStyles(
      DesignLoadStyles event, Emitter<DesignState> emit) async {
    emit(DesignStylesLoading());
    try {
      final styles = await _designService.getStyles();
      emit(DesignStylesLoaded(styles: styles));
    } catch (e) {
      emit(DesignError(message: e.toString()));
    }
  }
}
