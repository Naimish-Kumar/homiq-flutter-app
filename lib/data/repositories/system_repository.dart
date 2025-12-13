import 'package:homiq/exports/main_export.dart';

class SystemRepository {
  Future<Map<dynamic, dynamic>> fetchSystemSettings({
    required bool isAnonymouse,
  }) async {
    final parameters = <String, dynamic>{};
  final response = await Api.get(
      url: Api.apiGetAppSettings,
      queryParameters: parameters,
      useAuthToken: !isAnonymouse,
    );

    return response;
  }
}
