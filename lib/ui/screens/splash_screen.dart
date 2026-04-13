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

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _entranceController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 40, end: 80).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0, 0.6, curve: Curves.bounceIn),
      ),
    );

    _textFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.6, 1, curve: Curves.easeIn),
      ),
    );

    _initApp();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _initApp() async {
    _entranceController.forward();

    await locationPermission();
    await checkIsUserAuthenticated();

    await getDefaultLanguage(() {
      isLanguageLoaded = true;
      if (mounted) setState(() {});
    });

    await MobileAds.instance.initialize();

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (mounted) {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute<dynamic>(
            builder: (context) => NoInternet(
              onRetry: () async {
                try {
                  final retryConnectivity = await Connectivity()
                      .checkConnectivity();
                  if (!retryConnectivity.contains(ConnectivityResult.none)) {
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
            ),
          ),
        );
      }
    }

    // get Currency Symbol
    if (mounted) {
      context.read<ProfileSettingCubit>().fetchProfileSetting(
        Api.currencySymbol,
      );
    }
  }

  Future<void> locationPermission() async {
    if ((await Permission.location.status) == PermissionStatus.denied) {
      await Permission.location.request();
    }
  }

  Future<void> checkIsUserAuthenticated() async {
    if (!mounted) return;
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
      Future.delayed(Duration.zero, () async {
        await Navigator.of(
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
            statusBarIconBrightness:
                context.color.brightness == Brightness.light
                ? Brightness.dark
                : Brightness.light,
            systemNavigationBarColor: context.color.primaryColor,
          ),
          child: Scaffold(
            backgroundColor: context.color.primaryColor,
            extendBody: true,
            body: Stack(
              children: [
                // Adaptive Luxury Gradient Background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: context.color.brightness == Brightness.light
                          ? [
                              const Color(0xFFFBFBF9), // Warm Parchment
                              const Color(0xFFF5F5F4), // Stone 100
                              context.color.tertiaryColor.withValues(
                                alpha: 0.15,
                              ),
                            ]
                          : [
                              const Color(0xFF0C0A09), // Deep Ebony
                              const Color(0xFF1C1917), // Stone 900
                              context.color.tertiaryColor.withValues(
                                alpha: 0.25,
                              ),
                            ],
                      stops: const [0.0, 0.4, 1.0],
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
                            ScaleTransition(
                              scale: _logoScaleAnimation,
                              child: Hero(
                                tag: 'splash_logo',
                                child: AnimatedBuilder(
                                  animation: _pulseAnimation,
                                  builder: (context, child) {
                                    return Container(
                                      height: 180.rh(context),
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            context.color.brightness ==
                                                Brightness.light
                                            ? Colors.black.withValues(
                                                alpha: 0.02,
                                              )
                                            : Colors.white.withValues(
                                                alpha: 0.05,
                                              ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: context.color.tertiaryColor
                                                .withValues(alpha: 0.2),
                                            blurRadius: _pulseAnimation.value,
                                            spreadRadius: 10,
                                          ),
                                        ],
                                      ),
                                      child: child,
                                    );
                                  },
                                  child: Image.asset(
                                    AppIcons.splashLogo,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 32.rh(context)),
                            FadeTransition(
                              opacity: _textFadeAnimation,
                              child: Column(
                                children: [
                                  CustomText(
                                    'HOMIQ AI',
                                    fontSize: 36,
                                    fontWeight: FontWeight.w400,
                                    color: context.color.textColorDark,
                                    letterSpacing: 8,
                                    textAlign: TextAlign.center,
                                    useSerif: true,
                                  ),
                                  SizedBox(height: 8.rh(context)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.color.tertiaryColor
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: context.color.tertiaryColor
                                            .withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: CustomText(
                                      'AI INTERIOR DESIGNER',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
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
                                            context.color.brightness ==
                                                Brightness.light
                                            ? Colors.black.withValues(
                                                alpha: 0.05,
                                              )
                                            : Colors.white.withValues(
                                                alpha: 0.1,
                                              ),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              context.color.tertiaryColor,
                                            ),
                                        minHeight: 2,
                                      ),
                                    ),
                                  ),
                                ],
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
                            fontWeight: FontWeight.w800,
                            color: context.color.textLightColor.withValues(
                              alpha: 0.6,
                            ),
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
    await Hive.openBox<dynamic>(HiveKeys.languageBox);
    await Hive.openBox<dynamic>(HiveKeys.userDetailsBox);
    await Hive.openBox<dynamic>(HiveKeys.authBox);

    // Use English only — no remote language fetch needed
    if (HiveUtils.getLanguage() == null ||
        HiveUtils.getLanguage()?['data'] == null) {
      await HiveUtils.storeLanguage({
        'code': 'en',
        'data': null, // Will fall back to local template.json
        'name': 'English',
        'isRTL': false,
      });
    }
    onSuccess.call();
  } on Exception catch (e, st) {
    log('Error while load default language $e $st');
    onSuccess.call();
  }
}

