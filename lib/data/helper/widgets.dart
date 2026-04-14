import 'package:flutter/material.dart';

class Widgets {
  static bool isLoaderShowing = false;

  static Future<void> showLoader(BuildContext? context) async {
    if (context == null || !context.mounted || isLoaderShowing) return;
    isLoaderShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  static void hideLoader(BuildContext? context) {
    if (context == null || !context.mounted || !isLoaderShowing) return;
    isLoaderShowing = false;
    Navigator.of(context, rootNavigator: true).pop();
  }
  
  static Widget noDataFound(String msg) => Center(child: Text(msg));
}
