import 'package:homiq/data/model/languages_model.dart';
import 'package:homiq/utils/helper_utils.dart';


class AppSettings {
  ///Basic Settings
  static const String applicationName = 'Homiq';
  static const String androidPackageName = 'com.homiq.acrocoder';

  ///API Setting
  static const String hostUrl = 'https://homiq.acrocoder.com/';
  // homiq.wrteam.me

  static const int apiDataLoadLimit = 10;
  static const int maxCategoryShowLengthInHomeScreen = 5;

  static final String baseUrl =
      '${HelperUtils.checkHost(hostUrl)}api/'; //Don't change this

  static const int hiddenAPIProcessDelay = 1;


  ///Set type here
  static const DeepLinkType deepLinkingType = DeepLinkType.native;

  ///Native deep link
  static const String shareNavigationWebUrl = 'com.homiq.acrocoder';
  // ebrokerweb.wrteam.me

  ///Firebase authentication OTP timer.
  static const int otpResendSecond = 120;
  static const int otpTimeOutSecond = 120;
  static const int otpResendSecondForEmail = 600;

  ///This code will show on login screen [Note: don't add  + symbol]
  static const String defaultCountryCode = '91';


  static List<HomeScreenSections> sections = [
    //[Note: We Recommend default setting you can make arrangement by
    //your choice or you can hide any section if you do not want]
    HomeScreenSections.search,
    HomeScreenSections.slider,
    HomeScreenSections.category,
    HomeScreenSections.nearbyProperties,
    HomeScreenSections.featuredProperties,
    HomeScreenSections.personalizedFeed,
    HomeScreenSections.featuredProjects,
    HomeScreenSections.mostLikedProperties,
    HomeScreenSections.agents,
    HomeScreenSections.project,
    HomeScreenSections.mostViewed,
    HomeScreenSections.popularCities,
  ]; //[Note: We Recommend default setting you can make arrangement
  //by your choice or you can hide any section if you do not want]

  static const String progressLottieFile = 'loading.json';
//When there is dark background and you want to show progress so it will be used
  static const String progressLottieFileWhite = 'loading_white.json';

  static const String maintenanceModeLottieFile = 'maintenancemode.json';

  static const bool useLottieProgress =
      true; //if you don't want to use lottie progress then set it to false'

  ///Other settings
  static const String notificationChannel = 'basic_channel'; //
  static int uploadImageQuality = 50; //0 to 100th
  static bool homePageLocatoinAlertStatus = true;

  //// Don't change these
  //// Payment gatway API keys
  ///Here is for only reference you have to change it from panel
  static String enabledPaymentGatway = '';
  static String razorpayKey = '';
  static String paystackKey = ''; // public key
  static String paystackCurrency = '';
  static String paypalClientId = '';
  static String paypalServerKey = ''; //secrete
  static bool isSandBoxMode = true; //testing mode
  static String paypalCancelURL = '';
  static String paypalReturnURL = '';
  static String stripeCurrency = '';
  static String stripePublishableKey = '';
  static String stripeSecrateKey = '';
  static String otpServiceProvider = '';

  ///Do not set here
  static String iOSAppId = '';
  static String playstoreURLAndroid = '';
  static String appstoreURLios = '';
  static List<LanguagesModel> languages = [];
  static String distanceOption = '';

  static bool isVerificationRequired = false;

  // static String currencyName = '';
  static String currencyCode = '';
  static String currencySymbol = '';

  static String latitude = '';
  static String longitude = '';
  static String minRadius = '';
  static String maxRadius = '';

  static List<Map<String, dynamic>> bankTransferDetails = [];
}

enum HomeScreenSections {
  search,
  slider,
  personalizedFeed,
  nearbyProperties,
  featuredProperties,
  mostLikedProperties,
  popularCities,
  agents,
  mostViewed,
  category,
  project,
  featuredProjects,
}

enum DeepLinkType { native }
