import 'dart:developer';

import 'package:homiq/exports/main_export.dart';
// import 'package:homiq/ui/screens/advertisement/my_advertisment_screen.dart';
import 'package:homiq/ui/screens/auth/registration_form.dart';
import 'package:homiq/ui/screens/auth/otp_screen.dart';
import 'package:homiq/ui/screens/home/home_screen.dart';
// import 'package:homiq/ui/screens/proprties/widgets/compare_property_screen.dart';
import 'package:homiq/ui/screens/settings/faqs_screen.dart';

class Routes {
  //private constructor
  Routes._();

  static const comparePropertiesScreen = '/comparePropertiesScreen';
  static const agentVerificationForm = '/agentVerificationForm';
  static const agentDetailsScreen = '/agentDetailsScreen';
  static const agentListScreen = '/agentListScreen';
  static const splash = '/';
  static const onboarding = 'onboarding';
  static const login = 'login';
  static const otpScreen = 'otpScreen';
  static const registrationForm = 'registrationForm';
  static const editProfile = 'editProfile';
  static const main = 'main';
  static const home = 'home_screen';
  static const addProperty = 'addProperty';
  static const waitingScreen = 'waitingScreen';
  static const categories = 'Categories';
  static const cityListScreen = 'cityListScreen';
  static const addresses = 'address';
  static const chooseAdrs = 'chooseAddress';
  static const propertiesList = 'propertiesList';
  static const propertyDetails = 'PropertyDetails';
  static const contactUs = 'ContactUs';
  static const profileSettings = 'profileSettings';
  static const myEnquiry = 'MyEnquiry';
  static const filterScreen = 'filterScreen';
  static const notificationPage = 'notificationpage';
  static const notificationDetailPage = 'notificationdetailpage';
  static const addPropertyScreenRoute = 'addPropertyScreenRoute';
  static const articlesScreenRoute = 'articlesScreenRoute';
  static const subscriptionPackageListRoute = 'subscriptionPackageListRoute';
  static const maintenanceMode = '/maintenanceMode';
  static const favoritesScreen = '/favoritescreen';
  static const articleDetailsScreenRoute = '/articleDetailsScreenRoute';
  static const areaConvertorScreen = '/areaCalculatorScreen';

  // static const mortgageCalculatorScreen = '/mortgageCalculatorScreen';
  static const languageListScreenRoute = '/languageListScreenRoute';
  static const searchScreenRoute = '/searchScreenRoute';
  static const chooseLocaitonMap = '/chooseLocationMap';
  static const propertyMapScreen = '/propertyMap';
  static const dashboard = '/dashboard';

  static const myAdvertisment = '/myAdvertisment';
  static const transactionHistory = '/transactionHistory';

  // static const nearbyAllProperties = '/nearbyAllProperties';
  static const personalizedPropertyScreen = '/personalizedPropertyScreen';
  static const allProjectsScreen = '/allProjectsScreen';
  static const faqsScreen = '/faqsScreen';
  static const designStudio = '/designStudio';
  static const designResult = '/designResult';
  static const historyTab = '/historyTab';

  ///Project section routes
  static const String addProjectDetails = '/addProjectDetails';
  static const String projectMetaDataScreens = '/projectMetaDataScreens';
  static const String manageFloorPlansScreen = '/manageFloorPlansScreen';

  ///Add property screens
  static const selectPropertyTypeScreen = '/selectPropertyType';
  static const addPropertyDetailsScreen = '/addPropertyDetailsScreen';
  static const setPropertyParametersScreen = '/setPropertyParametersScreen';
  static const selectOutdoorFacility = '/selectOutdoorFacility';

  ///View project
  static const projectDetailsScreen = '/projectDetailsScreen';
  static const myProjects = '/myProjects';

  //Sandbox[test]
  static const playground = 'playground';

  static String currentRoute = '';
  static String previousCustomerRoute = '';

  static Route<dynamic>? onGenerateRouted(RouteSettings routeSettings) {
    previousCustomerRoute = currentRoute;
    currentRoute = routeSettings.name ?? '';
    log('CURRENT ROUTE $currentRoute');

    if (_isDeepLink(currentRoute)) {
      return null;
    }

    if (currentRoute.contains('/link?')) {
      return null;
    }

    switch (routeSettings.name) {
      case '':
        break;

      case splash:
        return CupertinoPageRoute(builder: (context) => const SplashScreen());
      case onboarding:
        return CupertinoPageRoute(
          builder: (context) => const OnboardingScreen(),
        );
      case home:
        return CupertinoPageRoute(
          builder: (context) => const HomeScreen(from: 'main'),
        );
      case main:
        return MainActivity.route(routeSettings);
      case login:
        return LoginScreen.route(routeSettings);
      case otpScreen:
        return OtpScreen.route(routeSettings);
      case registrationForm:
        return RegistrationForm.route(routeSettings);
      case editProfile:
        return EditProfileScreen.route(routeSettings);
      case maintenanceMode:
        return MaintenanceMode.route(routeSettings);
      case languageListScreenRoute:
        return LanguagesListScreen.route(routeSettings);
      case contactUs:
        return ContactUs.route(routeSettings);
      case profileSettings:
        return ProfileSettings.route(routeSettings);
      case notificationPage:
        return Notifications.route(routeSettings);
      case notificationDetailPage:
        return NotificationDetail.route(routeSettings);
      case favoritesScreen:
        return FavoritesScreen.route(routeSettings);
      case searchScreenRoute:
        return SearchScreen.route(routeSettings);
      case faqsScreen:
        return FaqsScreen.route(routeSettings);
      case designStudio:
        return StudioScreen.route(routeSettings);
      case designResult:
        return DesignResultScreen.route(routeSettings);
      case historyTab:
        // For now, redirect to main and we can handle tab switching logic if needed
        return MainActivity.route(routeSettings);
      default:
        return null;
    }
    return null;
  }

  static bool _isDeepLink(String route) {
    return route.contains('/property-details/') ||
        route.contains('/project-details/');
    // Add other deep link patterns here
  }
}
