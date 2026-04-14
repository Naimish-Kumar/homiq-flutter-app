import 'package:homiq/features/studio/domain/entities/design_style.dart';

class RoomDesignModel {
  final int id;
  final int userId;
  final int styleId;
  final String budget;
  final String originalImagePath;
  final String? generatedImagePath;
  final String status;
  final DateTime createdAt;
  final DesignStyle? style;

  RoomDesignModel({
    required this.id,
    required this.userId,
    required this.styleId,
    required this.budget,
    required this.originalImagePath,
    this.generatedImagePath,
    required this.status,
    required this.createdAt,
    this.style,
  });

  factory RoomDesignModel.fromJson(Map<String, dynamic> json) {
    return RoomDesignModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      styleId: json['style_id'] as int,
      budget: json['budget']?.toString() ?? 'medium',
      originalImagePath: json['original_image_path']?.toString() ?? '',
      generatedImagePath: json['generated_image_path']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      createdAt: DateTime.parse(json['created_at'].toString()),
      style: json['style'] != null 
          ? DesignStyle.fromJson(Map<String, dynamic>.from(json['style'])) 
          : null,
    );
  }

  // Helpers to get full URLs
  String get originalImageUrl => 'https://homiq.acrocoder.com/storage/$originalImagePath';
  String get generatedImageUrl => generatedImagePath != null 
      ? 'https://homiq.acrocoder.com/storage/$generatedImagePath' 
      : '';
}
