// lib/models/design_model.dart
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum DesignStyle {
  modern('Modern', FontAwesomeIcons.building),
  minimal('Minimal', FontAwesomeIcons.square),
  luxury('Luxury', FontAwesomeIcons.gem),
  traditionalIndian('Traditional Indian', FontAwesomeIcons.palette),
  scandinavian('Scandinavian', FontAwesomeIcons.tree);

  const DesignStyle(this.label, this.icon);
  final String label;
  final FaIconData icon;
}

enum BudgetLevel {
  low('Budget-Friendly', '₹50K – ₹1.5L', FontAwesomeIcons.wallet),
  medium('Mid-Range', '₹1.5L – ₹5L', FontAwesomeIcons.coins),
  high('Premium', '₹5L+', FontAwesomeIcons.diamond);

  const BudgetLevel(this.label, this.range, this.icon);
  final String label;
  final String range;
  final FaIconData icon;
}

class StyleModel {
  final String id;
  final String name;
  final String? thumbnailUrl;
  final String? promptPrefix;

  const StyleModel({
    required this.id,
    required this.name,
    this.thumbnailUrl,
    this.promptPrefix,
  });

  factory StyleModel.fromJson(Map<String, dynamic> json) {
    return StyleModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Style',
      thumbnailUrl: json['thumbnail_url']?.toString(),
      promptPrefix: json['prompt_prefix']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'thumbnail_url': thumbnailUrl,
    'prompt_prefix': promptPrefix,
  };

  DesignStyle get enumStyle {
    return DesignStyle.values.firstWhere(
      (s) => s.name.toLowerCase() == name.toLowerCase(),
      orElse: () => DesignStyle.modern,
    );
  }
}

enum DesignStatus { pending, processing, completed, failed }

class DesignModel {
  final String id;
  final String userId;
  final String roomName;
  final String roomType;
  final String originalImagePath;
  final String? generatedImagePath;
  final dynamic style; // Can be DesignStyle enum or StyleModel
  final BudgetLevel budget;
  final DesignStatus status;
  final DateTime createdAt;
  final bool isFavorite;
  final List<FurnitureItem> furnitureRecommendations;

  const DesignModel({
    required this.id,
    required this.userId,
    required this.roomName,
    required this.roomType,
    required this.originalImagePath,
    this.generatedImagePath,
    required this.style,
    required this.budget,
    this.status = DesignStatus.pending,
    required this.createdAt,
    this.isFavorite = false,
    this.furnitureRecommendations = const [],
  });

  String get styleLabel => style is DesignStyle
      ? (style as DesignStyle).label
      : (style as StyleModel).name;
  FaIconData get styleIcon => style is DesignStyle
      ? (style as DesignStyle).icon
      : (style as StyleModel).enumStyle.icon;
  String get budgetLabel => budget.label;
  FaIconData get budgetIcon => budget.icon;
  String get budgetRange => budget.range;

  DesignModel copyWith({
    String? id,
    String? userId,
    String? roomName,
    String? roomType,
    String? originalImagePath,
    String? generatedImagePath,
    dynamic style,
    BudgetLevel? budget,
    DesignStatus? status,
    DateTime? createdAt,
    bool? isFavorite,
    List<FurnitureItem>? furnitureRecommendations,
  }) {
    return DesignModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      roomName: roomName ?? this.roomName,
      roomType: roomType ?? this.roomType,
      originalImagePath: originalImagePath ?? this.originalImagePath,
      generatedImagePath: generatedImagePath ?? this.generatedImagePath,
      style: style ?? this.style,
      budget: budget ?? this.budget,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      furnitureRecommendations:
          furnitureRecommendations ?? this.furnitureRecommendations,
    );
  }

  factory DesignModel.fromJson(Map<String, dynamic> json) {
    // Handle style either as string or nested object from backend
    dynamic styleValue;
    if (json['style'] != null) {
      if (json['style'] is Map<String, dynamic>) {
        styleValue = StyleModel.fromJson(json['style']);
      } else {
        final styleName = json['style'] as String;
        styleValue = DesignStyle.values.firstWhere(
          (s) => s.name.toLowerCase() == styleName.toLowerCase(),
          orElse: () => DesignStyle.modern,
        );
      }
    } else {
      styleValue = DesignStyle.modern;
    }

    return DesignModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      roomName: json['room_name']?.toString() ?? 'Unnamed Room',
      roomType: json['room_type']?.toString() ?? 'Living Room',
      originalImagePath:
          (json['original_image_url'] ?? json['original_image_path'])
              ?.toString() ??
          '',
      generatedImagePath:
          (json['generated_image_url'] ?? json['generated_image_path'])
              ?.toString(),
      style: styleValue,
      budget: BudgetLevel.values.firstWhere(
        (b) =>
            b.name.toLowerCase() ==
            (json['budget']?.toString() ?? '').toLowerCase(),
        orElse: () => BudgetLevel.medium,
      ),
      status: DesignStatus.values.firstWhere(
        (s) =>
            s.name.toLowerCase() ==
            (json['status']?.toString() ?? '').toLowerCase(),
        orElse: () => DesignStatus.pending,
      ),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isFavorite:
          json['is_favorite'] == 1 ||
          json['is_favorite'] == true ||
          json['is_favorite'] == '1' ||
          json['is_favorite'] == 'true',
      furnitureRecommendations:
          ((json['furniture_recommendations'] ?? json['furniture'])
                  as List<dynamic>?)
              ?.map((f) => FurnitureItem.fromJson(f as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'room_name': roomName,
    'room_type': roomType,
    'original_image_path': originalImagePath,
    'generated_image_path': generatedImagePath,
    'style': style.name,
    'budget': budget.name,
    'status': status.name,
    'created_at': createdAt.toIso8601String(),
    'is_favorite': isFavorite,
    'furniture': furnitureRecommendations.map((f) => f.toJson()).toList(),
  };
}

class FurnitureItem {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final double price;
  final String brand;
  final String shopUrl;
  final String? affiliateUrl;
  final double rating;

  const FurnitureItem({
    required this.id,
    required this.name,
    this.category = 'General',
    this.imageUrl = '',
    required this.price,
    this.brand = '',
    this.shopUrl = '',
    this.affiliateUrl,
    this.rating = 4.0,
  });

  factory FurnitureItem.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return FurnitureItem(
      id: (json['id'] ?? '').toString(),
      name: json['name']?.toString() ?? 'Unknown',
      category: json['category']?.toString() ?? 'General',
      imageUrl: json['image_url']?.toString() ?? '',
      price: parseDouble(json['price']),
      brand: json['brand']?.toString() ?? '',
      shopUrl:
          json['purchase_link']?.toString() ??
          json['shop_url']?.toString() ??
          '',
      affiliateUrl:
          json['affiliate_url']?.toString() ??
          json['purchase_link']?.toString(),
      rating: parseDouble(json['rating']) == 0.0
          ? 4.0
          : parseDouble(json['rating']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'image_url': imageUrl,
    'price': price,
    'brand': brand,
    'shop_url': shopUrl,
    'purchase_link': affiliateUrl ?? shopUrl,
    'rating': rating,
  };
}
