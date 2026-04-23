import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final Dio _dio;
  static const String _tokenKey = 'auth_token';

  NotificationService(this._dio);

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final token = await _getToken();
    if (token == null) return [];

    try {
      final response = await _dio.get(
        '/api/get_notifications',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      
      // Backend returns a list of notifications
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      return [];
    }
  }

  Future<void> markAsRead(String id) async {
    final token = await _getToken();
    await _dio.post(
      '/api/notifications/$id/read',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<void> markAllAsRead() async {
    final token = await _getToken();
    await _dio.post(
      '/api/notifications/read-all',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
