import 'package:homiq/data/model/languages_model.dart';
import 'package:homiq/data/model/propery_filter_model.dart';
import 'package:homiq/data/model/system_settings_model.dart';
import 'package:homiq/exports/main_export.dart';

const double sidePadding = 16;

const String svgPath = 'assets/svg/';

abstract class Constant {
  static const String appName = AppSettings.applicationName;
  static const String androidPackageName = AppSettings.androidPackageName;
  static String iOSAppId = AppSettings.iOSAppId;
  static String playstoreURLAndroid = AppSettings.playstoreURLAndroid;
  static String appstoreURLios = AppSettings.appstoreURLios;
  static List<LanguagesModel> languages = AppSettings.languages;

  static const scrollPhysics = AlwaysScrollableScrollPhysics();

  //backend url
  static String baseUrl = AppSettings.baseUrl;

  //Do not add anything here
  static String googlePlaceAPIkey = 'AIzaSyDL6vmveLaK3zRSY3cFAk2qFyLoOs_o9D4';

  ///These task IDs are for load task parallel into the isolate .
  static int? languageTaskId;
  static int? appSettingTaskId;

  ///admob
  static bool isAdmobAdsEnabled = false;
  //Banner
  static String admobBannerAndroid = '';
  static String admobBannerIos = '';
  //Interstitial
  static String admobInterstitialAndroid = '';
  static String admobInterstitialIos = '';

  //Native ads ids
  static String admobNativeAndroid = '';
  static String admobNativeIos = '';

  ////Payment gateway API keys
  static String razorpayKey = AppSettings.razorpayKey;

//paystack
  static String paystackKey = AppSettings.paystackKey;
// public key
  static String paystackCurrency = AppSettings.paystackCurrency;

  ///Paypal
  static String paypalClientId = AppSettings.paypalClientId;
  static String paypalServerKey = AppSettings.paypalServerKey; //secrete

  static bool isSandBoxMode = AppSettings.isSandBoxMode; //testing mode
  static String paypalCancelURL = AppSettings.paypalCancelURL;
  static String paypalReturnURL = AppSettings.paypalReturnURL;

  /////////////////////////////////

  // static late Session session;
  static String currencySymbol = '\u{20B9}';
  //
  static int otpTimeOutSecond = AppSettings.otpTimeOutSecond; //otp time out
  static int otpResendSecond = AppSettings.otpResendSecond; // resend otp timer
  static int otpResendSecondForEmail = AppSettings.otpResendSecondForEmail;
  //

  static String logintypeMobile = '1'; //always 1
  //
  static String maintenanceMode = '0'; //OFF
  static bool isUserDeactivated = false;
  //
  static String valSellBuy = '0';
  static String valRent = '1';
  //
  static int loadLimit = AppSettings.apiDataLoadLimit;

  static const String defaultCountryCode = AppSettings.defaultCountryCode;

  ///This maxCategoryLength is for show limited number of categories and show "More" button,
  ///You have to set less than [loadLimit] constant

  static const int maxCategoryLength =
      AppSettings.maxCategoryShowLengthInHomeScreen;

  //

  ///Lottie animation
  static const String progressLottieFile = AppSettings.progressLottieFile;
  static const String progressLottieFileWhite = AppSettings
      .progressLottieFileWhite; //When there is dark background and you want to show progress so it will be used

  static const String maintenanceModeLottieFile =
      AppSettings.maintenanceModeLottieFile;

  ///

  ///Put your loading json file in assets/lottie/ folder
  static const bool useLottieProgress = AppSettings
      .useLottieProgress; //if you don't want to use lottie progress then set it to false'

  static const String notificationChannel = AppSettings.notificationChannel;
  static int uploadImageQuality = AppSettings.uploadImageQuality; //0 to 100

  static String? subscriptionPackageId;
  static PropertyFilterModel? propertyFilter;
  static List<int>? filterFacilities;
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'navigatorKey from constants',
  );

  static void navigateTo(String routeName, {Object? arguments}) {
    navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
  }

  static String typeRent = 'rent';
  static String generalNotification = '0';
  static String enquiryNotification = '1';
  static String notificationPropertyEnquiry = 'property_inquiry';
  static String notificationDefault = 'default';

//

  //

  static List<int> interestedPropertyIds = [];

  static Map<dynamic, dynamic> addProperty = {};

  static Map<SystemSetting, String> systemSettingKeys = {
    SystemSetting.currencySymbol: 'currency_symbol',
    SystemSetting.privacyPolicy: 'privacy_policy',
    SystemSetting.contactUs: '',
    SystemSetting.maintenanceMode: 'maintenance_mode',
    SystemSetting.termsConditions: 'terms_conditions',
    SystemSetting.subscription: 'subscription',
    SystemSetting.languageType: 'languages',
    SystemSetting.defaultLanguage: 'default_language',
    SystemSetting.forceUpdate: 'force_update',
    SystemSetting.androidVersion: 'android_version',
    SystemSetting.numberWithSuffix: 'number_with_suffix',
    SystemSetting.iosVersion: 'ios_version',
    SystemSetting.language: 'default_language_name',
    SystemSetting.numberWithOtpLogin: 'number_with_otp_login',
    SystemSetting.socialLogin: 'social_login',
    SystemSetting.verificationStatus: 'verification_status',
  };

  ///This is limit of minimum chat messages load count , make sure you set it grater than 25;
  static int minChatMessages = 35;

  static bool showExperimentals = true;
  //Don't touch this settings
  static bool isUpdateAvailable = false;
  static String newVersionNumber = '';
  static bool isNumberWithSuffix = false;

  //Demo mode settings
  static bool isDemoModeOn = false;
  static String demoEmail = 'acrocoader@gmail.com';
  static String demoCountryCode = '91';
  static String demoMobileNumber = '1234567890';
  static String demoFirebaseID = '6a1Zdl2TxORQGbCazj4XDGfgBBG3';
  static String demoModeOTP = '123456';

  static const String terminalLogMode = 'debug';
  static String keysDecryptionPasswordRSA = '';
}
