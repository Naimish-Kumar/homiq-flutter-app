import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:homiq/data/model/system_settings_model.dart';
import 'package:homiq/data/repositories/system_repository.dart';
import 'package:homiq/exports/main_export.dart';
import 'package:homiq/utils/hive_keys.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AuthenticationState authenticationState;

  bool isSettingsLoaded = false;
  bool isLanguageLoaded = false;

  @override
  void initState() {
    locationPermission();
    checkIsUserAuthenticated();
    super.initState();
    getDefaultLanguage(() {
      isLanguageLoaded = true;
    });
    MobileAds.instance.initialize();

    Connectivity().checkConnectivity().then((value) {
      if (value.contains(ConnectivityResult.none)) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<dynamic>(
            builder: (context) {
              return NoInternet(
                onRetry: () async {
                  try {
                    await LoadAppSettings().load(initBox: true);

                    // Check internet connectivity before redirecting
                    final connectivityResult =
                        await Connectivity().checkConnectivity();
                    if (!connectivityResult.contains(ConnectivityResult.none)) {
                      // Only redirect to splash screen if internet is available
                      Future.delayed(Duration.zero, () {
                        Navigator.pushReplacementNamed(context, Routes.splash);
                      });
                    } else {
                      await HelperUtils.showSnackBarMessage(
                        context,
                        isFloating: true,
                        'noInternetErrorMsg'.translate(context),
                      );
                    }
                  } on Exception catch (_) {
                    log('no internet');
                  }
                },
              );
            },
          ),
        );
      }
    });
    //get Currency Symbol from Admin Panel
    Future.delayed(Duration.zero, () {
      context
          .read<ProfileSettingCubit>()
          .fetchProfileSetting(Api.currencySymbol);
    });
  }

  Future<void> locationPermission() async {
    if ((await Permission.location.status) == PermissionStatus.denied) {
      await Permission.location.request();
    }
  }

  Future<void> checkIsUserAuthenticated() async {
    authenticationState = context.read<AuthenticationCubit>().state;
    if (authenticationState == AuthenticationState.authenticated) {
      ///Only load sensitive details if user is authenticated
      ///This call will load sensitive details with settings
      await context.read<FetchSystemSettingsCubit>().fetchSettings(
            isAnonymous: false,
          );
    } else {
      //This call will hide sensitive details.
      await context.read<FetchSystemSettingsCubit>().fetchSettings(
            isAnonymous: true,
          );
    }
  }

  void navigateCheck() {
    ({'setting': isSettingsLoaded, 'language': isLanguageLoaded}).logg;

    if (isSettingsLoaded) {
      navigateToScreen();
    }
  }

  void navigateToScreen() {
    if (context.read<FetchSystemSettingsCubit>().getSetting(
              SystemSetting.maintenanceMode,
            ) ==
        '1') {
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pushReplacementNamed(Routes.maintenanceMode);
      });
    } else if (authenticationState == AuthenticationState.authenticated) {
      Future.delayed(Duration.zero, () {
        Navigator.of(
          context,
        ).pushReplacementNamed(Routes.main, arguments: {'from': 'main'});
      });
    } else if (authenticationState == AuthenticationState.unAuthenticated) {
      if (Hive.box<dynamic>(HiveKeys.userDetailsBox).get('isGuest') == true) {
        Future.delayed(Duration.zero, () {
          Navigator.of(
            context,
          ).pushReplacementNamed(Routes.main, arguments: {'from': 'splash'});
        });
      } else {
        Future.delayed(Duration.zero, () {
          Navigator.of(context).pushReplacementNamed(Routes.login);
        });
      }
    } else if (authenticationState == AuthenticationState.firstTime) {
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pushReplacementNamed(Routes.onboarding);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    navigateCheck();

    return BlocListener<FetchLanguageCubit, FetchLanguageState>(
      listener: (context, state) {},
      child: BlocListener<FetchSystemSettingsCubit, FetchSystemSettingsState>(
        listener: (context, state) {
          if (state is FetchSystemSettingsFailure) {
            log(
              'FetchSystemSettings Issue while load system settings ${state.errorMessage}',
            );
          }
          if (state is FetchSystemSettingsSuccess) {
            if (kDebugMode) {
              print('FetchSystemSettingsSuccess');
            }
            final setting = <dynamic>[];
            if (setting.isNotEmpty) {
              if ((setting[0] as Map).containsKey('package_id')) {
                Constant.subscriptionPackageId = '';
              }
            }

            if ((state.settings['data'].containsKey('demo_mode') as bool?) ??
                false) {
              Constant.isDemoModeOn =
                  state.settings['data']['demo_mode'] as bool? ?? false;
            }
            isSettingsLoaded = true;
            setState(() {});
          }
        },
        child: AnnotatedRegion(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: context.color.primaryColor,
          ),
          child: Scaffold(
            backgroundColor: context.color.primaryColor,
            extendBody: true,
            body: Stack(
              children: [
                // Deep Immersive Gradient Background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF0F172A), // Deep Navy
                        const Color(0xFF1E293B), // Navy Slate
                        context.color.tertiaryColor.withValues(alpha: 0.2),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
                // Premium Mesh Glow Effect
                Positioned(
                  top: -100,
                  right: -100,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.color.tertiaryColor.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Hero(
                              tag: 'splash_logo',
                              child: Container(
                                height: 180.rh(context),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.05),
                                  boxShadow: [
                                    BoxShadow(
                                      color: context.color.tertiaryColor
                                          .withValues(alpha: 0.2),
                                      blurRadius: 60,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  AppIcons.splashLogo,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(height: 32.rh(context)),
                            CustomText(
                              'HOMIQ AI',
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 8,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8.rh(context)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: context.color.tertiaryColor
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: context.color.tertiaryColor
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: CustomText(
                                'AI INTERIOR DESIGNER',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: context.color.tertiaryColor,
                                letterSpacing: 2,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 64.rh(context)),
                            SizedBox(
                              width: 140.rw(context),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.1),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    context.color.tertiaryColor,
                                  ),
                                  minHeight: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 48.rh(context)),
                      child: Column(
                        children: [
                          CustomText(
                            'POWERED BY ADVANCED AI',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.4),
                            letterSpacing: 3,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 12.rh(context)),
                          Container(
                            height: 4,
                            width: 20,
                            decoration: BoxDecoration(
                              color: context.color.accentColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<dynamic> getDefaultLanguage(VoidCallback onSuccess) async {
  try {
    // await Hive.initFlutter();v
    await Hive.openBox<dynamic>(HiveKeys.languageBox);
    await Hive.openBox<dynamic>(HiveKeys.userDetailsBox);
    await Hive.openBox<dynamic>(HiveKeys.authBox);

    if (kDebugMode) {
      print(
        'Here in SplashScreen HiveBox ${Hive.isBoxOpen(HiveKeys.languageBox)}',
      );
    }
    if (kDebugMode) {
      print('${HiveUtils.getLanguage()}');
    }
    if (HiveUtils.getLanguage() == null ||
        HiveUtils.getLanguage()?['data'] == null) {
      final result = await SystemRepository().fetchSystemSettings(
        isAnonymouse: true,
      );

      final code = result['data']['default_language'];

      await Api.get(
        url: Api.getLanguages,
        queryParameters: {Api.languageCode: code},
        useAuthToken: false,
      ).then((value) {
        HiveUtils.storeLanguage({
          'code': value['data']['code'],
          'data': value['data']['file_name'],
          'name': value['data']['name'],
          'isRTL': value['data']['rtl']?.toString() == '1',
        });
        onSuccess.call();
      });
    } else {
      onSuccess.call();
    }
  } on Exception catch (e, st) {
    log('Error while load default language $st');
  }
}
