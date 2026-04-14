import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homiq/core/common_widgets/custom_shimmer.dart';
import 'package:homiq/core/common_widgets/errors/no_data_found.dart';
import 'package:homiq/core/common_widgets/errors/no_internet.dart';
import 'package:homiq/core/common_widgets/errors/something_went_wrong.dart';
import 'package:homiq/core/theme/theme.dart';
import 'package:homiq/data/cubits/cubit_stubs.dart';
import 'package:homiq/data/helper/custom_exception.dart';
import 'package:homiq/data/model/model_stubs.dart';
import 'package:homiq/exports/main_export.dart';
import 'package:homiq/utils/custom_appbar.dart';
import 'package:homiq/utils/custom_image.dart';
import 'package:homiq/utils/extensions/lib/build_context.dart';
import 'package:homiq/utils/extensions/lib/custom_text.dart';
import 'package:homiq/utils/responsive_size.dart';
import 'package:homiq/utils/ui_utils.dart';

late NotificationData selectedNotification;

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  NotificationsState createState() => NotificationsState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(builder: (_) => const Notifications());
  }
}

class NotificationsState extends State<Notifications> {
  bool isNotificationsEnabled = true;

  late final ScrollController _pageScrollController = ScrollController();
  List<PropertyModel> propertyData = [];
  @override
  void initState() {
    super.initState();
    _pageScrollController.addListener(() {
      if (_pageScrollController.isEndReached()) {
        if (context.read<FetchNotificationsCubit>().hasMoreData()) {
          context.read<FetchNotificationsCubit>().fetchNotificationsMore();
        }
      }
    });
    context.read<FetchNotificationsCubit>().fetchNotifications();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryColor,
      appBar: CustomAppBar(
        title: CustomText(UiUtils.translate(context, 'notifications')),
      ),
      body: BlocBuilder<FetchNotificationsCubit, FetchNotificationsState>(
        builder: (context, state) {
          if (state is FetchNotificationsInProgress) {
            return buildNotificationShimmer();
          }
          if (state is FetchNotificationsFailure) {
            if (state.errorMessage is NoInternetConnectionError) {
              return NoInternet(
                onRetry: () {
                  context.read<FetchNotificationsCubit>().fetchNotifications();
                },
              );
            }
            return const SomethingWentWrong();
          }

          if (state is FetchNotificationsSuccess) {
            if (state.notificationdata.isEmpty) {
              return NoDataFound(
                onTap: () {
                  context.read<FetchNotificationsCubit>().fetchNotifications();
                },
              );
            }
            if (state.notificationdata.isNotEmpty) {
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _pageScrollController,

                      padding: const EdgeInsets.all(10),
                      itemCount: state.notificationdata.length,
                      itemBuilder: (context, index) {
                        final notificationData = state.notificationdata[index];
                        return GestureDetector(
                          onTap: () {
                            selectedNotification = notificationData;
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondaryColor,
                              border: Border.all(
                                color: context.color.borderColor,
                              ),
                            ),
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: <Widget>[
                                if (notificationData.image != null)
                                  GestureDetector(
                                    onTap: () {
                                      UiUtils.showFullScreenImage(
                                        context,
                                        provider: CachedNetworkImageProvider(
                                          notificationData.image!,
                                        ),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(4),
                                      ),
                                      child: CustomImage(
                                        imageUrl: notificationData.image!,
                                        height: 48.rh(context),
                                        width: 48.rw(context),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      CustomText(
                                        notificationData.title!
                                            .firstUpperCase(),
                                        maxLines: 1,
                                        color: context.color.textColorDark,
                                        fontSize: context.font.lg,
                                      ),
                                      CustomText(
                                        notificationData.message!
                                            .firstUpperCase(),
                                        maxLines: 2,
                                        fontSize: context.font.xs,
                                        color: context.color.textColorDark,
                                      ),
                                      CustomText(
                                        notificationData.createdAt!
                                            .formatDate(),
                                        fontSize: context.font.xs,
                                        color: context.color.textLightColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if ((context.read<FetchNotificationsCubit>().state
                          as FetchNotificationsSuccess)
                      .isLoadingMore) ...[
                    const SizedBox(height: 10),
                    Center(),
                    const SizedBox(height: 10),
                  ],
                ],
              );
            }
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget buildNotificationShimmer() {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemCount: 20,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return SizedBox(
          height: 56.rh(context),
          child: Row(
            children: <Widget>[
              CustomShimmer(
                width: 48.rw(context),
                height: 48.rh(context),
                borderRadius: 11,
              ),
              SizedBox(width: 8.rw(context)),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CustomShimmer(height: 7.rh(context), width: 200.rw(context)),
                  SizedBox(height: 4.rh(context)),
                  CustomShimmer(height: 7.rh(context), width: 100.rw(context)),
                  SizedBox(height: 4.rh(context)),
                  CustomShimmer(height: 7.rh(context), width: 150.rw(context)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
