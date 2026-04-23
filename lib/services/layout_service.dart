import 'dart:io';
import 'package:dio/dio.dart';
import '../models/layout_model.dart';
import 'auth_service.dart';

class LayoutService {
  final Dio _dio;
  final AuthService _authService;

  LayoutService(this._dio, this._authService);

  Future<List<LayoutModel>> getLayouts() async {
    try {
      final token = await _authService.getToken();
      final response = await _dio.get(
        '/layouts',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final List data = response.data['data'];
      return data.map((j) => LayoutModel.fromJson(j)).toList();
    } catch (e) {
      throw Exception('Failed to load layouts: $e');
    }
  }

  Future<LayoutModel> createLayout(String name, File floorPlan) async {
    try {
      final token = await _authService.getToken();
      final formData = FormData.fromMap({
        'name': name,
        'floor_plan': await MultipartFile.fromFile(floorPlan.path, filename: 'floor_plan.jpg'),
      });

      final response = await _dio.post(
        '/layouts',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return LayoutModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create layout: $e');
    }
  }

  Future<void> deleteLayout(int id) async {
    try {
      final token = await _authService.getToken();
      await _dio.delete(
        '/layouts/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      throw Exception('Failed to delete layout: $e');
    }
  }
}
