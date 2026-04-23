// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dio/dio.dart';
import 'package:homiq_ai/l10n/app_localizations.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/design/design_bloc.dart';
import 'bloc/subscription/subscription_bloc.dart';
import 'bloc/theme/theme_cubit.dart';
import 'bloc/language/language_cubit.dart';
import 'services/auth_service.dart';
import 'services/design_service.dart';
import 'services/notification_service.dart';
import 'services/push_notification_service.dart';
import 'services/iap_service.dart';
import 'services/ad_service.dart';
import 'services/moodboard_service.dart';
import 'bloc/moodboard/moodboard_bloc.dart';
import 'services/furniture_service.dart';
import 'bloc/furniture/furniture_bloc.dart';
import 'services/layout_service.dart';
import 'bloc/layout/layout_bloc.dart';
import 'theme/app_theme.dart';
import 'utils/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await PushNotificationService.initialize();
  await AdService.initialize();

  // Force dark status bar icons / style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Lock portrait orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const HomiqApp());
}

class HomiqApp extends StatelessWidget {
  const HomiqApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dio = Dio(BaseOptions(
      baseUrl: 'https://homiq.acrocoder.com/', // Production backend URL
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));

    dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    ));

    return RepositoryProvider(
      create: (_) => AuthService(dio),
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider(create: (_) => DesignService(dio)),
          RepositoryProvider(create: (_) => NotificationService(dio)),
          RepositoryProvider(create: (_) => IapService(dio)),
          RepositoryProvider(
            create: (context) => MoodboardService(
              dio,
              context.read<AuthService>(),
            ),
          ),
          RepositoryProvider(
            create: (context) => FurnitureService(
              dio,
              context.read<AuthService>(),
            ),
          ),
          RepositoryProvider(
            create: (context) => LayoutService(
              dio,
              context.read<AuthService>(),
            ),
          ),
        ],
        child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit()),
          BlocProvider(create: (_) => LanguageCubit()),
          BlocProvider(
            create: (context) => AuthBloc(
              authService: context.read<AuthService>(),
            ),
          ),
          BlocProvider(
            create: (context) => DesignBloc(
              designService: context.read<DesignService>(),
            ),
          ),
          BlocProvider(
            create: (context) => SubscriptionBloc(
              iapService: context.read<IapService>(),
            )..add(SubscriptionInitialize()),
          ),
          BlocProvider(
            create: (context) => MoodboardBloc(
              context.read<MoodboardService>(),
            ),
          ),
          BlocProvider(
            create: (context) => FurnitureBloc(
              context.read<FurnitureService>(),
            ),
          ),
          BlocProvider(
            create: (context) => LayoutBloc(
              context.read<LayoutService>(),
            ),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return BlocBuilder<LanguageCubit, Locale>(
              builder: (context, locale) {
                return MaterialApp.router(
                  title: 'Homiq AI',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeMode,
                  locale: locale,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [
                    Locale('en'),
                    Locale('hi'),
                    Locale('es'),
                    Locale('fr'),
                    Locale('ar'),
                  ],
                  routerConfig: appRouter,
                );
              },
            );
          },
        ),
      ),
    ),
  );
}
}
