import 'package:flutter/material.dart';
import 'package:homiq/features/auth/presentation/screens/login_screen.dart';
import 'package:homiq/features/auth/presentation/screens/otp_screen.dart';
import 'package:homiq/features/auth/presentation/screens/registration_form.dart';
import 'package:homiq/features/home/presentation/screens/main_activity.dart';
import 'package:homiq/features/studio/presentation/screens/studio_screen.dart';
import 'package:homiq/features/profile/presentation/screens/profile_screen.dart';
import 'package:homiq/features/profile/presentation/screens/edit_profile.dart';
import 'package:homiq/features/splash/presentation/screens/splash_screen.dart';
import 'package:homiq/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:homiq/features/history/presentation/screens/history_screen.dart';

class Routes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String registration = '/registration';
  static const String otp = '/otp';
  static const String mainActivity = '/mainActivity';
  static const String home = '/home';
  static const String studio = '/studio';
  static const String result = '/result';
  static const String profile = '/profile';
  static const String editProfile = '/editProfile';
  static const String profileSetting = '/profileSetting';
  static const String history = '/history';
  static const String chat = '/chat';
  static const String subscriptionPackageListRoute = '/subscriptionPackageList';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case login:
        return LoginScreen.route(settings);
      case registration:
        return MaterialPageRoute(
            builder: (_) => const RegistrationForm(
                  phone: '',
                ));
      case otp:
        return OtpScreen.route(settings);
      case mainActivity:
        return MainActivity.route(settings);
      case studio:
        return StudioScreen.route(settings);

      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case editProfile:
        return MaterialPageRoute(
            builder: (_) => const EditProfileScreen(
                  from: '',
                ));

      case history:
        return MaterialPageRoute(builder: (_) => const HistoryScreen());

      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
