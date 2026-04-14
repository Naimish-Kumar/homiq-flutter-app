import 'package:homiq/core/network/api_client.dart';
import 'package:homiq/core/network/api_endpoints.dart';

class SystemRepository {
  final ApiClient _apiClient;
  
  SystemRepository([ApiClient? apiClient]) : _apiClient = apiClient ?? ApiClient();

  Future<Map<String, dynamic>> fetchSettings({bool isAnonymous = false}) async {
    try {
      final response = await _apiClient.get(
        Api.apiGetAppSettings,
        useAuthToken: !isAnonymous,
      );
      return response;
    } catch (e) {
      // Return minimum required structure if backend fails or is unreachable
      return {
        "error": true,
        "message": e.toString(),
        "data": {
          "verification_required_for_user": false,
          "languages": [
            {"id": "1", "code": "en", "name": "English"}
          ],
        }
      };
    }
  }

  Future<Map<String, dynamic>> fetchSystemSettings({bool isAnonymous = false}) async {
    return fetchSettings(isAnonymous: isAnonymous);
  }

  Future<List<dynamic>> fetchLanguages() async {
    try {
      final response = await _apiClient.get(Api.apiGetLanguages);
      return response['data'] as List<dynamic>? ?? [];
    } catch (_) {
      return [{"id": "1", "code": "en", "name": "English"}];
    }
  }
}
