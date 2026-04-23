import 'design_model.dart';

class FurnitureModel {
  final int id;
  final String name;
  final String category;
  final String? brand;
  final String? imageUrl;
  final String? affiliateLink;
  final double? lowPrice;
  final double? mediumPrice;
  final double? highPrice;
  final bool isActive;
  final List<StyleModel> styles;

  FurnitureModel({
    required this.id,
    required this.name,
    required this.category,
    this.brand,
    this.imageUrl,
    this.affiliateLink,
    this.lowPrice,
    this.mediumPrice,
    this.highPrice,
    required this.isActive,
    required this.styles,
  });

  factory FurnitureModel.fromJson(Map<String, dynamic> json) {
    return FurnitureModel(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      brand: json['brand'],
      imageUrl: json['image_url'],
      affiliateLink: json['affiliate_link'],
      lowPrice: json['low_price'] != null ? double.parse(json['low_price'].toString()) : null,
      mediumPrice: json['medium_price'] != null ? double.parse(json['medium_price'].toString()) : null,
      highPrice: json['high_price'] != null ? double.parse(json['high_price'].toString()) : null,
      isActive: json['is_active'] ?? true,
      styles: (json['styles'] as List?)?.map((s) => StyleModel.fromJson(s)).toList() ?? [],
    );
  }

  double? priceForBudget(String budget) {
    switch (budget.toLowerCase()) {
      case 'low':
        return lowPrice;
      case 'high':
        return highPrice;
      default:
        return mediumPrice;
    }
  }
}
