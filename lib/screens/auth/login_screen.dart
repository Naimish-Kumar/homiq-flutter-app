// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:homiq_ai/l10n/app_localizations.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.4, 1.0, curve: AppCurves.defaultCurve),
          ),
        );
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/home');
        } else if (state is AuthOtpSent) {
          context.push(
            '/verify-otp',
            extra: {'identifier': state.identifier, 'type': state.type},
          );
        } else if (state is AuthFirebaseCodeSent) {
          context.push(
            '/verify-otp',
            extra: {
              'identifier': state.phoneNumber,
              'type': 'mobile',
              'verificationId': state.verificationId,
            },
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.background
            : AppColors.backgroundLight,
        body: Stack(
          children: [
            // ── Background Layer (Top Hero)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.45,
              child: Stack(
                children: [
                  // const MeshGradient(),
                  SafeArea(
                    child: Center(
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 200,
                              height: 200,
                              child: Image.asset(
                                'assets/logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Content Layer (Sliding Form)
            Positioned.fill(
              top: MediaQuery.of(context).size.height * 0.4,
              child: SlideTransition(
                position: _slideAnim,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surface
                        : AppColors.backgroundLight,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(30, 40, 30, 30),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.welcomeBack,
                            style: AppTextStyles.displayMedium.copyWith(
                              color: isDark
                                  ? AppColors.textPrimary
                                  : AppColors.textPrimaryL,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.signInContinue,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark
                                  ? AppColors.textSecondary
                                  : AppColors.textSecondaryL,
                            ),
                          ),
                          const SizedBox(height: 35),

                          HomiqTextField(
                            label: l10n.emailOrMobile,
                            hint: 'you@example.com or mobile',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.alternate_email_rounded,
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Required' : null,
                          ),

                          const SizedBox(height: 30),

                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) => PrimaryButton(
                              label: l10n.sendOtp,
                              isLoading: state is AuthLoading,
                              onPressed: () {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  final input = _emailController.text.trim();
                                  final type = input.contains('@')
                                      ? 'email'
                                      : 'mobile';
                                  context.read<AuthBloc>().add(
                                    AuthSendOtp(identifier: input, type: type),
                                  );
                                }
                              },
                            ),
                          ),

                          const SizedBox(height: 30),

                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: isDark
                                      ? Colors.white12
                                      : Colors.black12,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'OR',
                                  style: AppTextStyles.overline.copyWith(
                                    color: isDark
                                        ? AppColors.textMuted
                                        : AppColors.textMutedL,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: isDark
                                      ? Colors.white12
                                      : Colors.black12,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: OutlinedButton(
                              onPressed: () => context.read<AuthBloc>().add(
                                AuthLoginWithGoogle(),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isDark
                                      ? AppColors.primary.withValues(alpha: 0.3)
                                      : AppColors.primary.withValues(
                                          alpha: 0.5,
                                        ),
                                  width: 1.2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset('assets/google.png', width: 20),
                                  const SizedBox(width: 12),
                                  Text(
                                    l10n.continueWithGoogle,
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: isDark
                                          ? AppColors.textPrimary
                                          : AppColors.textPrimaryL,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${l10n.dontHaveAccount} ",
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: isDark
                                        ? AppColors.textSecondary
                                        : AppColors.textSecondaryL,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => context.push('/signup'),
                                  child: Text(
                                    l10n.signUp,
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
