import 'package:dio/dio.dart';
import '../models/furniture_model.dart';
import 'auth_service.dart';

class FurnitureService {
  final Dio _dio;
  final AuthService _authService;

  FurnitureService(this._dio, this._authService);

  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    String? category,
    int? styleId,
    String? search,
  }) async {
    try {
      final token = await _authService.getToken();
      final response = await _dio.get(
        '/furniture',
        queryParameters: {
          'page': page,
          if (category != null && category != 'All') 'category': category,
          if (styleId != null) 'style_id': styleId,
          if (search != null && search.isNotEmpty) 'search': search,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List productsJson = response.data['data']['data'];
      final List<FurnitureModel> products = 
          productsJson.map((j) => FurnitureModel.fromJson(j)).toList();
      
      return {
        'products': products,
        'lastPage': response.data['data']['last_page'],
        'currentPage': response.data['data']['current_page'],
      };
    } catch (e) {
      throw Exception('Failed to load furniture: $e');
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final token = await _authService.getToken();
      final response = await _dio.get(
        '/furniture/categories',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return List<String>.from(response.data['data']);
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  Future<FurnitureModel> getProductDetail(int id) async {
    try {
      final token = await _authService.getToken();
      final response = await _dio.get(
        '/furniture/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return FurnitureModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to load product details: $e');
    }
  }
}
