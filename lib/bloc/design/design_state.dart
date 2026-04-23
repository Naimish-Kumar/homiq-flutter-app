// lib/bloc/design/design_state.dart
part of 'design_bloc.dart';

abstract class DesignState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DesignInitial extends DesignState {}

class DesignImageSelected extends DesignState {
  final File image;
  DesignImageSelected({required this.image});
  @override
  List<Object?> get props => [image.path];
}

class DesignStyleSelected extends DesignState {
  final File image;
  final dynamic style; // DesignStyle or StyleModel
  DesignStyleSelected({required this.image, required this.style});
  @override
  List<Object?> get props => [image.path, style];
}

class DesignStylesLoading extends DesignState {}

class DesignStylesLoaded extends DesignState {
  final List<StyleModel> styles;
  DesignStylesLoaded({required this.styles});
  @override
  List<Object?> get props => [styles];
}

class DesignBudgetSelected extends DesignState {
  final File image;
  final dynamic style; // DesignStyle or StyleModel
  final BudgetLevel budget;
  DesignBudgetSelected({
    required this.image,
    required this.style,
    required this.budget,
  });
  @override
  List<Object?> get props => [image.path, style, budget];
}

class DesignGenerating extends DesignState {}

class DesignCompleted extends DesignState {
  final DesignModel design;
  DesignCompleted({required this.design});
  @override
  List<Object?> get props => [design.id];
}

class DesignHistoryLoading extends DesignState {}

class DesignHistoryLoaded extends DesignState {
  final List<DesignModel> designs;
  DesignHistoryLoaded({required this.designs});
  @override
  List<Object?> get props => [designs];
}

class DesignError extends DesignState {
  final String message;
  DesignError({required this.message});
  @override
  List<Object?> get props => [message];
}
