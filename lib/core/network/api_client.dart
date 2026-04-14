import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:hive/hive.dart';
import 'package:homiq/utils/hive_keys.dart';
import 'package:homiq/utils/hive_utils.dart';
import 'package:homiq/utils/constant.dart';
import 'package:homiq/utils/guest_checker.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  
  late final Dio _dio;
  
  ApiClient._internal() {
    _dio = Dio();
    _initInterceptors();
  }

  void _initInterceptors() {
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        error: true,
        compact: true,
      ),
    );
  }

  Map<String, String> _headers({required bool useAuthToken}) {
    final languageCode = HiveUtils.getLanguageCode();
    
    if (!useAuthToken || GuestChecker.value) {
      return {'Content-Language': languageCode};
    }

    final token = Hive.box<dynamic>(HiveKeys.userDetailsBox)
            .get(HiveKeys.jwtToken)
            ?.toString() ?? '';

    return {
      'Authorization': 'Bearer $token',
      'Content-Language': languageCode,
      'Accept': 'application/json',
    };
  }

  Future<dynamic> _makeRequest({
    required String method,
    required String url,
    Map<String, dynamic>? parameters,
    bool useAuthToken = true,
  }) async {
    try {
      final endpoint = Constant.baseUrl + url;
      final options = Options(
        headers: _headers(useAuthToken: useAuthToken),
        contentType: method == 'POST' ? 'multipart/form-data' : null,
      );

      Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _dio.get(endpoint, queryParameters: parameters, options: options);
        case 'POST':
          final formData = parameters != null ? FormData.fromMap(parameters) : null;
          response = await _dio.post(endpoint, data: formData, options: options);
        default:
          throw Exception('Method $method not supported');
      }

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  dynamic _handleResponse(Response response) {
    if (response.data is List) {
      return response.data;
    }
    
    if (response.data is String && (response.data as String).contains('<!DOCTYPE html>')) {
      throw Exception('Server returned HTML instead of JSON. Please check API URL or Authentication.');
    }
    
    if (response.data is! Map) {
      throw Exception('Invalid response format: ${response.data.runtimeType}');
    }

    final data = Map<String, dynamic>.from(response.data);
    if (data['error'] == true) {
      throw Exception(data['message'] ?? 'API Error');
    }
    return data;
  }

  Exception _handleDioError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data.containsKey('message')) {
      return Exception(data['message']);
    }
    return Exception(e.message ?? 'Network error');
  }

  Future<dynamic> get(String url, {Map<String, dynamic>? params, bool useAuthToken = true}) =>
      _makeRequest(method: 'GET', url: url, parameters: params, useAuthToken: useAuthToken);

  Future<dynamic> post(String url, {Map<String, dynamic>? params, bool useAuthToken = true}) =>
      _makeRequest(method: 'POST', url: url, parameters: params, useAuthToken: useAuthToken);
}
