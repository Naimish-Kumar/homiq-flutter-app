import 'package:homiq/features/studio/domain/entities/design_style.dart';

abstract class DesignRepository {
  Future<List<DesignStyle>> fetchStyles();
  Future<List<dynamic>> fetchMyDesigns();
  Future<dynamic> generateDesign({required Map<String, dynamic> data});
}
