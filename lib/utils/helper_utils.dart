import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:homiq/data/helper/custom_exception.dart';
import 'package:homiq/exports/core_data.dart';
import 'package:homiq/exports/framework.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class HelperUtils {
  static void unfocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static Future<File?> compressImageFile(File file) async => file;

  static String checkHost(String url) {
    if (url.endsWith('/')) return url;
    return '$url/';
  }

  static Map<dynamic, Type> runtimeValueLog(Map<dynamic, dynamic> map) {
    return map.map((key, value) => MapEntry(key, value.runtimeType));
  }

  static Future<String?> getDownloadPath({
    dynamic Function(dynamic err)? onError,
  }) async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getDownloadsDirectory();
      }
    } on Exception catch (err) {
      onError?.call(err);
    }
    return directory?.path;
  }

  static Future<void> printServerError(
    String url, {
    required int statusCode,
    required Map<dynamic, dynamic> parameter,
    required String response,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/server_error.txt');
    final log =
        '${DateTime.now()}\nURL: $url\nStatus Code: $statusCode\nParameter: $parameter\nResponse: $response\n--------------------------------------------------\n';
    await file.writeAsString(log, mode: FileMode.append);
  }

  static Future<void> showSnackBarMessage(
    BuildContext context,
    String message, {
    MessageType? type,
    bool isFloating = false,
    int messageDuration = 3,
  }) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: messageDuration),
        behavior: isFloating
            ? SnackBarBehavior.floating
            : SnackBarBehavior.fixed,
        backgroundColor: type == MessageType.error ? Colors.red : null,
      ),
    );
  }

  static String getSelectedLanguage() => 'en';

  static Future<void> share(BuildContext context, String text) async {}

  static Future<void> goToNextPage(
    String route,
    BuildContext context,
    bool isPushReplacement, {
    Object? args,
  }) async {
    if (isPushReplacement) {
      Navigator.pushReplacementNamed(context, route, arguments: args);
    } else {
      Navigator.pushNamed(context, route, arguments: args);
    }
  }

  static void killPreviousPages(
    BuildContext context,
    String route,
    Object? args,
  ) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      route,
      (route) => false,
      arguments: args,
    );
  }

  static Future<bool> checkInternet() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  static Future<String?> sendApiRequest(
    String url,
    Map<String, dynamic> body,
    BuildContext context, [
    bool passUserid = true,
    bool isPost = true,
  ]) async {
    Map<String, String> headersData = {};
    final token = HiveUtils.getJWT().toString();
    if (token.trim().isNotEmpty) headersData['Authorization'] = 'Bearer $token';

    http.Response response;
    try {
      if (isPost) {
        response = await http.post(
          Uri.parse(Constant.baseUrl + url),
          body: body.isNotEmpty ? body : null,
          headers: headersData,
        );
      } else {
        response = await http.get(
          Uri.parse(Constant.baseUrl + url),
          headers: headersData,
        );
      }
      return await getJsonResponse(context, response: response);
    } on SocketException {
      throw FetchDataException('noInternetErrorMsg'.translate(context));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<String> getJsonResponse(
    BuildContext context, {
    bool isfromfile = false,
    http.StreamedResponse? streamedResponse,
    http.Response? response,
  }) async {
    int code = isfromfile ? streamedResponse!.statusCode : response!.statusCode;
    switch (code) {
      case 200:
        if (isfromfile) {
          final responseData = await streamedResponse!.stream.toBytes();
          return String.fromCharCodes(responseData);
        } else {
          return response!.body;
        }
      case 400:
        throw BadRequestException(response!.body);
      case 401:
        throw UnauthorisedException(response!.body);
      default:
        throw FetchDataException('Error: $code');
    }
  }
}
