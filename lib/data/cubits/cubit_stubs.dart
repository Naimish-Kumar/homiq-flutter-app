import 'package:homiq/exports/main_export.dart';

class LikedPropertiesCubit extends Cubit<dynamic> {
  LikedPropertiesCubit() : super(null);
  void clear() {}
}

abstract class FetchNotificationsState {}
class FetchNotificationsInProgress extends FetchNotificationsState {}
class FetchNotificationsSuccess extends FetchNotificationsState {
  final List<NotificationData> notificationdata;
  final bool isLoadingMore;
  FetchNotificationsSuccess(this.notificationdata, {this.isLoadingMore = false});
}
class FetchNotificationsFailure extends FetchNotificationsState {
  final dynamic errorMessage;
  FetchNotificationsFailure(this.errorMessage);
}
class FetchNotificationsCubit extends Cubit<FetchNotificationsState> {
  FetchNotificationsCubit() : super(FetchNotificationsInProgress());
  void fetchNotifications() {}
  void fetchNotificationsMore() {}
  bool hasMoreData() => false;
  void clear() {}
}

class LoadChatMessagesCubit extends Cubit<dynamic> {
  LoadChatMessagesCubit() : super(null);
  void clear() {}
}
