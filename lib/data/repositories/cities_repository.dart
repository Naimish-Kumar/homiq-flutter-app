import 'package:homiq/data/model/city_model.dart';
import 'package:homiq/data/model/data_output.dart';
import 'package:homiq/utils/api.dart';
import 'package:homiq/utils/constant.dart';

class CitiesRepository {
  Future<DataOutput<City>> fetchAllCities({
    required int offset,
  }) async {
    final response = await Api.get(
      url: Api.getCitiesData,
      queryParameters: {
        Api.limit: Constant.loadLimit,
        Api.offset: offset,
      },
    );
    final modelList = (response['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<City>(City.fromMap)
        .toList();
    return DataOutput(
      total: response['total'] as int? ?? 0,
      modelList: modelList,
    );
  }
}
