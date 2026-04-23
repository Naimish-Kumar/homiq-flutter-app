import 'package:homiq_ai/models/design_model.dart';

class MoodboardModel {
  final int id;
  final int userId;
  final String title;
  final String? description;
  final int? styleId;
  final StyleModel? style;
  final List<String> colorPalette;
  final List<String> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  MoodboardModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.styleId,
    this.style,
    this.colorPalette = const [],
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory MoodboardModel.fromJson(Map<String, dynamic> json) {
    return MoodboardModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      styleId: json['style_id'],
      style: json['style'] != null ? StyleModel.fromJson(json['style']) : null,
      colorPalette: List<String>.from(json['color_palette'] ?? []),
      items: List<String>.from(json['items'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'style_id': styleId,
      'color_palette': colorPalette,
      'items': items,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
