import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:homiq/data/repositories/auth_repository.dart';
import 'package:homiq/exports/main_export.dart';
import 'package:homiq/utils/login/apple_login/apple_login.dart';
import 'package:homiq/utils/login/google_login/google_login.dart';
import 'package:homiq/utils/login/lib/login_status.dart';
import 'package:homiq/utils/login/lib/login_system.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.isDeleteAccount, this.popToCurrent});

  final bool? isDeleteAccount;
  final bool? popToCurrent;

  @override
  State<LoginScreen> createState() => LoginScreenState();

  static CupertinoPageRoute<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map?;
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => SendOtpCubit()),
          BlocProvider(create: (context) => VerifyOtpCubit()),
        ],
        child: LoginScreen(
          isDeleteAccount: args?['isDeleteAccount'] as bool? ?? false,
          popToCurrent: args?['popToCurrent'] as bool? ?? false,
        ),
      ),
    );
  }
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;

  MMultiAuthentication loginSystem = MMultiAuthentication({
    'google': GoogleLogin(),
    'apple': AppleLogin(),
  });

  @override
  void initState() {
    super.initState();
    loginSystem
      ..init()
      ..setContext(context)
      ..listen((MLoginState state) {
        if (state is MProgress) unawaited(Widgets.showLoader(context));
        if (state is MSuccess) {
          Widgets.hideLoder(context);
          _handleSocialLoginSuccess(state);
        }
        if (state is MFail) {
          Widgets.hideLoder(context);
          _handleLoginFailure(state.error.toString());
        }
      });
  }

  void _handleSocialLoginSuccess(MSuccess state) {
    context.read<LoginCubit>().login(
          type: LoginType.values
              .firstWhere((element) => element.name == state.type),
          name: state.credentials.user?.displayName,
          email: state.credentials.user?.email,
          uniqueId: state.credentials.user!.uid,
          phoneNumber: '',
          countryCode: '',
        );
  }

  void _handleLoginFailure(String error) {
    if (error != 'google-terminated') {
      HelperUtils.showSnackBarMessage(context, error, type: MessageType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: Scaffold(
        backgroundColor: context.color.tertiaryColor,
        body: Stack(
          children: [
            // Abstract Background Decoration
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Hero(
                      tag: 'splash_logo',
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                        child: Image.asset(
                          AppIcons.splashLogo,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomText(
                      'HOMIQ AI',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: context.color.primaryColor,
                      letterSpacing: 2,
                    ),
                    CustomText(
                      'Luxury Interior Redesigned',
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: context.color.primaryColor.withOpacity(0.7),
                    ),
                    const SizedBox(height: 60),

                    // Login Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                _buildTextField(
                                  controller: emailController,
                                  hint: 'Email Address',
                                  icon: Icons.email_outlined,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: passwordController,
                                  hint: 'Password',
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  obscure: !isPasswordVisible,
                                  onSuffixTap: () => setState(() =>
                                      isPasswordVisible = !isPasswordVisible),
                                ),
                                const SizedBox(height: 32),
                                _buildLoginButton(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                    _buildSocialLoginSection(),
                    const SizedBox(height: 40),

                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(
                          "Don't have an account? ",
                          color: context.color.primaryColor.withOpacity(0.7),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                              context, Routes.emailRegistrationForm),
                          child: CustomText(
                            "Sign Up",
                            color: context.color.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onSuffixTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Please enter $hint';
          return null;
        },
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  onPressed: onSuffixTap,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) async {
        if (state is LoginSuccess) {
          await Navigator.pushReplacementNamed(context, Routes.main,
              arguments: {'from': 'login'});
        }
        if (state is LoginFailure) {
          await HelperUtils.showSnackBarMessage(context, state.errorMessage,
              type: MessageType.error);
        }
      },
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: state is LoginInProgress ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.color.accentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: state is LoginInProgress
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                        color: context.color.tertiaryColor, strokeWidth: 2))
                : const Text('Login',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<LoginCubit>().loginWithEmail(
            email: emailController.text,
            password: passwordController.text,
            type: LoginType.email,
          );
    }
  }

  Widget _buildSocialLoginSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomText('OR CONTINUE WITH',
                  fontSize: 10, color: Colors.white.withOpacity(0.5)),
            ),
            Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialIcon(AppIcons.google, () => loginSystem.login()),
            if (Theme.of(context).platform == TargetPlatform.iOS) ...[
              const SizedBox(width: 24),
              _socialIcon(AppIcons.apple, () => loginSystem.login()),
            ],
          ],
        ),
      ],
    );
  }

  Widget _socialIcon(String iconPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: CustomImage(imageUrl: iconPath, width: 24, height: 24),
      ),
    );
  }
}
