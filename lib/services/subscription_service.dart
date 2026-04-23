import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionService {
  final Dio _dio;
  static const String _tokenKey = 'auth_token';

  SubscriptionService(this._dio);

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<Map<String, dynamic>> getSubscriptionStatus() async {
    final token = await _getToken();
    final response = await _dio.get(
      '/api/subscription/status',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  Future<List<dynamic>> getPackages() async {
    final token = await _getToken();
    final response = await _dio.get(
      '/api/packages',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data['data'];
  }
}
