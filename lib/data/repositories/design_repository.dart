import 'dart:io';
import 'package:dio/dio.dart';
import 'package:homiq/exports/main_export.dart';

class DesignRepository {
  Future<Map<String, dynamic>> getStyles() async {
    final response = await Api.get(url: 'styles');
    return response;
  }

  Future<Map<String, dynamic>> generateDesign({
    required File image,
    required String styleId,
    String? budget,
  }) async {
    final Map<String, dynamic> parameters = {
      'image': await MultipartFile.fromFile(image.path),
      'style_id': styleId,
      if (budget != null) 'budget': budget,
    };

    final response = await Api.post(
      url: 'designs/generate',
      parameter: parameters,
    );
    return response;
  }

  Future<Map<String, dynamic>> getMyDesigns() async {
    final response = await Api.get(url: 'designs');
    return response;
  }
}
