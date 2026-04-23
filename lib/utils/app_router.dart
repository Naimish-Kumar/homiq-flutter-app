// lib/utils/app_router.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/design_model.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/upload/upload_screen.dart';
import '../screens/style/style_selection_screen.dart';
import '../screens/loading_screen.dart';
import '../screens/result/result_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/privacy_policy_screen.dart';
import '../screens/profile/help_support_screen.dart';
import '../screens/profile/pricing_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/profile/subscription_management_screen.dart';
import '../screens/moodboard/moodboard_list_screen.dart';
import '../screens/moodboard/moodboard_create_screen.dart';
import '../screens/moodboard/moodboard_detail_screen.dart';
import '../models/moodboard_model.dart';
import '../screens/furniture/furniture_catalog_screen.dart';
import '../screens/furniture/furniture_detail_screen.dart';
import '../models/furniture_model.dart';
import '../screens/layout/layout_list_screen.dart';
import '../screens/layout/layout_upload_screen.dart';
import '../screens/layout/layout_detail_screen.dart';
import '../models/layout_model.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/welcome',
      pageBuilder: (context, state) => _fadeTransition(
        state,
        const WelcomeScreen(),
      ),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => _fadeTransition(
        state,
        const LoginScreen(),
      ),
    ),
    GoRoute(
      path: '/signup',
      pageBuilder: (context, state) => _slideTransition(
        state,
        const SignupScreen(),
      ),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => _fadeTransition(
        state,
        const HomeScreen(),
      ),
    ),
    GoRoute(
      path: '/upload',
      pageBuilder: (context, state) => _slideTransition(
        state,
        const UploadScreen(),
      ),
    ),
    GoRoute(
      path: '/history',
      pageBuilder: (context, state) => _fadeTransition(
        state,
        const HomeScreen(initialIndex: 1),
      ),
    ),
    GoRoute(
      path: '/style-select',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final image = extra['image'] as File;
        final roomType = extra['roomType'] as String;
        return _slideTransition(
          state,
          StyleSelectionScreen(image: image, roomType: roomType),
        );
      },
    ),
    GoRoute(
      path: '/loading',
      pageBuilder: (context, state) => _fadeTransition(
        state,
        const LoadingScreen(),
      ),
    ),
    GoRoute(
      path: '/result',
      pageBuilder: (context, state) {
        final design = state.extra as DesignModel;
        return _slideTransition(
          state,
          ResultScreen(design: design),
        );
      },
    ),
    GoRoute(
      path: '/notifications',
      pageBuilder: (context, state) => _slideTransition(
        state,
        const NotificationsScreen(),
      ),
    ),
    GoRoute(
      path: '/edit-profile',
      pageBuilder: (context, state) => _slideTransition(
        state,
        const EditProfileScreen(),
      ),
    ),
    GoRoute(
      path: '/privacy-policy',
      pageBuilder: (context, state) => _slideTransition(
        state,
        const PrivacyPolicyScreen(),
      ),
    ),
    GoRoute(
      path: '/help-support',
      pageBuilder: (context, state) => _slideTransition(
        state,
        const HelpSupportScreen(),
      ),
    ),
    GoRoute(
      path: '/pricing',
      pageBuilder: (context, state) => _slideTransition(
        state,
        const PricingScreen(),
      ),
    ),
    GoRoute(
      path: '/verify-otp',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return _slideTransition(
          state,
          OtpVerificationScreen(
            identifier: extra['identifier'] as String,
            type: extra['type'] as String,
            verificationId: extra['verificationId'] as String?,
          ),
        );
      },
    ),
    GoRoute(
      path: '/subscription',
      pageBuilder: (context, state) => _slideTransition(
        state,
        const SubscriptionManagementScreen(),
      ),
    ),
    GoRoute(
      path: '/moodboards',
      pageBuilder: (context, state) => _slideTransition(
        state,
        const MoodboardListScreen(),
      ),
    ),
    GoRoute(
      path: '/moodboards/create',
      pageBuilder: (context, state) => _slideTransition(
        state,
        const MoodboardCreateScreen(),
      ),
    ),
    GoRoute(
      path: '/moodboards/edit',
      pageBuilder: (context, state) {
        final moodboard = state.extra as MoodboardModel;
        return _slideTransition(
          state,
          MoodboardCreateScreen(editMoodboard: moodboard),
        );
      },
    ),
    GoRoute(
      path: '/moodboards/detail',
      pageBuilder: (context, state) {
        final moodboard = state.extra as MoodboardModel;
        return _slideTransition(
          state,
          MoodboardDetailScreen(moodboard: moodboard),
        );
      },
    ),
    GoRoute(
      path: '/furniture',
      pageBuilder: (context, state) => _slideTransition(
        state,
        const FurnitureCatalogScreen(),
      ),
    ),
    GoRoute(
      path: '/furniture/detail',
      pageBuilder: (context, state) {
        final product = state.extra as FurnitureModel;
        return _slideTransition(
          state,
          FurnitureDetailScreen(product: product),
        );
      },
    ),
    GoRoute(
      path: '/layouts',
      pageBuilder: (context, state) => _slideTransition(
        state,
        const LayoutListScreen(),
      ),
    ),
    GoRoute(
      path: '/layouts/upload',
      pageBuilder: (context, state) => _slideTransition(
        state,
        const LayoutUploadScreen(),
      ),
    ),
    GoRoute(
      path: '/layouts/detail',
      pageBuilder: (context, state) {
        final layout = state.extra as LayoutModel;
        return _slideTransition(
          state,
          LayoutDetailScreen(layout: layout),
        );
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.error}'),
    ),
  ),
);

CustomTransitionPage<void> _fadeTransition(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

CustomTransitionPage<void> _slideTransition(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}
