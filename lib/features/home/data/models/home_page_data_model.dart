import 'package:homiq/data/model/category.dart';
import 'package:homiq/data/model/home_slider.dart';

class HomePageDataModel {
  const HomePageDataModel({
    this.sliderSection,
    this.categoriesSection,
    this.recentDesigns,
  });

  HomePageDataModel.fromJson(Map<String, dynamic> json)
      : sliderSection = (json['slider_section'] as List? ?? [])
            .map((e) => HomeSlider.fromJson(e as Map<String, dynamic>))
            .toList(),
        categoriesSection = (json['categories_section'] as List? ?? [])
            .map((e) => Category.fromJson(e as Map<String, dynamic>))
            .toList(),
        recentDesigns = (json['recent_designs'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            // .map(DesignModel.fromJson) // DesignModel yet to be defined properly
            .toList();

  final List<HomeSlider>? sliderSection;
  final List<Category>? categoriesSection;
  final List<dynamic>? recentDesigns;

  HomePageDataModel copyWith({
    List<HomeSlider>? sliderSection,
    List<Category>? categoriesSection,
    List<dynamic>? recentDesigns,
  }) {
    return HomePageDataModel(
      sliderSection: sliderSection ?? this.sliderSection,
      categoriesSection: categoriesSection ?? this.categoriesSection,
      recentDesigns: recentDesigns ?? this.recentDesigns,
    );
  }
}
