// lib/bloc/design/design_event.dart
part of 'design_bloc.dart';

abstract class DesignEvent {}

class DesignUploadImage extends DesignEvent {
  final File image;
  final String roomType;
  DesignUploadImage({required this.image, required this.roomType});
}

class DesignSelectStyle extends DesignEvent {
  final dynamic style; // DesignStyle or StyleModel
  DesignSelectStyle({required this.style});
}

class DesignLoadStyles extends DesignEvent {}

class DesignSelectBudget extends DesignEvent {
  final BudgetLevel budget;
  DesignSelectBudget({required this.budget});
}

class DesignGenerate extends DesignEvent {
  final File image;
  final dynamic style; // DesignStyle or StyleModel
  final BudgetLevel budget;
  final String roomType;
  final String userId;
  DesignGenerate({
    required this.image,
    required this.style,
    required this.budget,
    required this.roomType,
    required this.userId,
  });
}

class DesignSave extends DesignEvent {
  final String designId;
  DesignSave({required this.designId});
}

class DesignLoadHistory extends DesignEvent {
  final String userId;
  DesignLoadHistory({required this.userId});
}

class DesignReset extends DesignEvent {}

class DesignToggleFavorite extends DesignEvent {
  final String designId;
  DesignToggleFavorite({required this.designId});
}

class DesignDelete extends DesignEvent {
  final String designId;
  DesignDelete({required this.designId});
}

class DesignLoadFavorites extends DesignEvent {
  final String userId;
  DesignLoadFavorites({required this.userId});
}
