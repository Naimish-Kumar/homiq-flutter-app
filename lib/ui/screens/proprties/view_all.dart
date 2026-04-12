import 'package:homiq/data/model/property_model.dart';

abstract class PropertySuccessStateWireframe {
  abstract bool isLoadingMore;
  abstract List<PropertyModel> properties;
}

abstract class PropertyErrorStateWireframe {
  abstract dynamic error;
}

abstract class PropertyCubitWireframe {
  Future<void> fetch({
    bool? forceRefresh,
    bool? loadWithoutDelay,
    String? cityName,
  });
  Future<void> fetchMore();
  bool hasMoreData();
}
