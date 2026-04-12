import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homiq/data/helper/custom_exception.dart';
import 'package:homiq/data/model/notification_data.dart';
import 'package:homiq/utils/extensions/extensions.dart';
import 'package:homiq/utils/api.dart';
import 'package:homiq/utils/helper_utils.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationSetProgress extends NotificationState {}

class NotificationSetSuccess extends NotificationState {
  NotificationSetSuccess(this.notificationlist);
  List<NotificationData> notificationlist = [];
}

class NotificationSetFailure extends NotificationState {
  NotificationSetFailure(this.errmsg);
  final String errmsg;
}

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationInitial());

  void getNotification(
    BuildContext context,
  ) {
    emit(NotificationSetProgress());
    getNotificationFromDb(
      context,
    )
        .then((value) => emit(NotificationSetSuccess(value)))
        .catchError((Object e) => emit(NotificationSetFailure(e.toString())));
  }

  Future<List<NotificationData>> getNotificationFromDb(
    BuildContext context,
  ) async {
    final response = await HelperUtils.sendApiRequest(
      Api.apiGetNotificationList,
      {},
      false,
      context,
    ) as String?;
    if (response == null) {
      Future.delayed(
        Duration.zero,
        () {
          throw CustomException('nodatafound'.translate(context));
        },
      );
    }
    final getdata = json.decode(response.toString()) as Map<String, dynamic>;
    if (getdata[Api.error] as bool) {
      throw CustomException(getdata[Api.message]);
    }

    final list = (getdata['data'] as List).cast<Map<String, dynamic>>();
    return list.map(NotificationData.fromJson).toList();
  }
}
