import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/design_model.dart';

class DesignService {
  final Dio _dio;
  static const String _tokenKey = 'auth_token';

  DesignService(this._dio);

  Future<List<StyleModel>> getStyles() async {
    final response = await _dio.get('/api/styles');
    final List<dynamic> data = response.data;
    return data.map((json) => StyleModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<DesignModel> generateDesign({
    required File image,
    required dynamic style, // DesignStyle or StyleModel
    required BudgetLevel budget,
    required String roomType,
    required String userId,
  }) async {
    final token = await _getToken();
    
    // 1. Get style ID from backend
    String styleId;
    if (style is StyleModel) {
      styleId = style.id;
    } else {
      styleId = _getStyleId(style as DesignStyle).toString();
    }

    final formData = FormData.fromMap({
      'style_id': styleId,
      'room_type': roomType,
      'budget': budget.name.toLowerCase(),
      'image': await MultipartFile.fromFile(image.path),
    });

    final response = await _dio.post(
      '/api/designs/generate',
      data: formData,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    DesignModel design = DesignModel.fromJson(response.data as Map<String, dynamic>);

    // 2. Poll for completion if status is processing
    if (design.status == DesignStatus.processing) {
      design = await _pollForCompletion(design.id, token!);
    }

    return design;
  }

  Future<DesignModel> _pollForCompletion(String designId, String token) async {
    int attempts = 0;
    while (attempts < 10) {
      await Future.delayed(const Duration(seconds: 3));
      final response = await _dio.get(
        '/api/designs/$designId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      
      final design = DesignModel.fromJson(response.data as Map<String, dynamic>);
      if (design.status == DesignStatus.completed) {
        return design;
      }
      attempts++;
    }
    throw Exception('Design generation timed out');
  }

  Future<List<DesignModel>> getDesignHistory(String userId) async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await _dio.get(
      '/api/designs',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final List<dynamic> data = response.data;
    return data.map((json) => DesignModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  // Helper to map DesignStyle to backend style IDs
  int _getStyleId(DesignStyle style) {
    switch (style) {
      case DesignStyle.modern: return 1;
      case DesignStyle.minimal: return 2;
      case DesignStyle.luxury: return 3;
      case DesignStyle.traditionalIndian: return 4;
      case DesignStyle.scandinavian: return 5;
    }
  }

  Future<bool> toggleFavorite(String designId) async {
    final token = await _getToken();
    final response = await _dio.put(
      '/api/designs/$designId/favorite',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data['is_favorite'] as bool;
  }

  Future<void> deleteDesign(String designId) async {
    final token = await _getToken();
    await _dio.delete(
      '/api/designs/$designId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<List<DesignModel>> getFavorites(String userId) async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await _dio.get(
      '/api/designs?favorites_only=1',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final List<dynamic> data = response.data;
    return data.map((json) => DesignModel.fromJson(json as Map<String, dynamic>)).toList();
  }
}
