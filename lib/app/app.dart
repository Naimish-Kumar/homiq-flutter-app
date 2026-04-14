import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:homiq/app/app_localization.dart';
import 'package:homiq/core/common_widgets/errors/something_went_wrong.dart' show SomethingWentWrong;
import 'package:homiq/exports/main_export.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Initialize ApiClient
    ApiClient();
    SomethingWentWrong.asGlobalErrorBuilder();

    // Data load logic
    context.read<LanguageCubit>().loadCurrentLanguage();
    NotificationService.init();
    loadInitialData(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      DeepLinkManager.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, languageState) {
        return BlocBuilder<AppThemeCubit, AppThemeState>(
          builder: (context, themeState) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Homiq AI',
              theme: appThemeData[themeState.appTheme],
              onGenerateRoute: Routes.onGenerateRoute,
              initialRoute: Routes.splash,
              localizationsDelegates: const [
                AppLocalization.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'),
              ],
              builder: (context, child) {
                return ScrollConfiguration(
                  behavior: RemoveGlow(),
                  child: child!,
                );
              },
              locale: (languageState is LanguageLoader) 
                  ? Locale(languageState.languageCode.toString()) 
                  : const Locale('en'),
            );
          },
        );
      },
    );
  }
}

void loadInitialData(BuildContext context) {
  // Load Homiq specific initial data
  context.read<FetchSystemSettingsCubit>().fetchSettings();
  context.read<GetApiKeysCubit>().fetch();

  // If authenticated, fetch user data and designs
  if (context.read<AuthenticationCubit>().state ==
      AuthenticationState.authenticated) {
    context.read<GetUserDataCubit>().getUserData();
    context.read<FetchStylesCubit>().fetch();
    context.read<FetchMyDesignsCubit>().fetch();
    context.read<FetchHomePageDataCubit>().fetch();
  }
}

// Stub classes to clear errors
class GuestChecker {
  static bool get value => false;
}

class ErrorFilter {
  static void filter(dynamic e) {}
}

class RemoveGlow extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
