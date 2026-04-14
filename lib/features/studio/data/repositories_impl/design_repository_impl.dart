import 'package:dio/dio.dart';
import 'package:homiq/core/network/api_client.dart';
import 'package:homiq/core/network/api_endpoints.dart';
import 'package:homiq/features/studio/data/models/room_design_model.dart';
import 'package:homiq/features/studio/domain/entities/design_style.dart';
import 'package:homiq/features/studio/domain/repositories/design_repository.dart';

class DesignRepositoryImpl implements DesignRepository {
  final ApiClient _apiClient;
  DesignRepositoryImpl({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();
  
  @override
  Future<List<DesignStyle>> fetchStyles() async {
    try {
      final response = await _apiClient.get(Api.apiGetStyles);
      final List list = response is List ? response : (response['data'] as List? ?? []);
      return list.map((json) => DesignStyle.fromJson(Map<String, dynamic>.from(json))).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<RoomDesignModel>> fetchMyDesigns() async {
    try {
      final response = await _apiClient.get(Api.apiGetDesigns);
      final List list = response is List ? response : (response['data'] as List? ?? []);
      return list.map((json) => RoomDesignModel.fromJson(Map<String, dynamic>.from(json))).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<dynamic> generateDesign({required Map<String, dynamic> data}) async {
    try {
      final String imagePath = data['image'] as String;
      
      final Map<String, dynamic> params = {
        'style_id': data['style_id'],
        'budget': data['budget'] ?? 'medium',
        'image': await MultipartFile.fromFile(imagePath, filename: 'room.jpg'),
      };

      final response = await _apiClient.post(
        Api.apiGenerateDesign,
        params: params,
      );
      
      return {
        'success': true,
        'data': RoomDesignModel.fromJson(Map<String, dynamic>.from(response))
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString()
      };
    }
  }
}
