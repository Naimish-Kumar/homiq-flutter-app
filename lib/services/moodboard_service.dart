import 'package:dio/dio.dart';
import '../models/moodboard_model.dart';
import 'auth_service.dart';

class MoodboardService {
  final Dio _dio;
  final AuthService _authService;

  MoodboardService(this._dio, this._authService);

  Future<String?> _getToken() async {
    return _authService.getToken();
  }

  Future<List<MoodboardModel>> getMoodboards() async {
    final token = await _getToken();
    final response = await _dio.get(
      '/api/moodboards',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.data['success'] == true) {
      final List data = response.data['data'];
      return data.map((json) => MoodboardModel.fromJson(json)).toList();
    }
    throw Exception(response.data['message'] ?? 'Failed to load moodboards');
  }

  Future<MoodboardModel> createMoodboard({
    required String title,
    String? description,
    int? styleId,
    List<String>? colorPalette,
    List<String>? items,
  }) async {
    final token = await _getToken();
    final response = await _dio.post(
      '/api/moodboards',
      data: {
        'title': title,
        'description': description,
        'style_id': styleId,
        'color_palette': colorPalette,
        'items': items,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.data['success'] == true) {
      return MoodboardModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to create moodboard');
  }

  Future<MoodboardModel> updateMoodboard(
    int id, {
    String? title,
    String? description,
    int? styleId,
    List<String>? colorPalette,
    List<String>? items,
  }) async {
    final token = await _getToken();
    final response = await _dio.put(
      '/api/moodboards/$id',
      data: {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (styleId != null) 'style_id': styleId,
        if (colorPalette != null) 'color_palette': colorPalette,
        if (items != null) 'items': items,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.data['success'] == true) {
      return MoodboardModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to update moodboard');
  }

  Future<void> deleteMoodboard(int id) async {
    final token = await _getToken();
    final response = await _dio.delete(
      '/api/moodboards/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to delete moodboard');
    }
  }
}
