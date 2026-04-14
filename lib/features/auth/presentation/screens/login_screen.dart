import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:homiq/exports/main_export.dart';
import 'package:homiq/features/auth/presentation/blocs/auth_state_cubit.dart';
import 'package:homiq/utils/app_icons.dart';
import 'package:homiq/utils/login/apple_login/apple_login.dart';
import 'package:homiq/utils/login/google_login/google_login.dart';
import 'package:homiq/utils/login/lib/login_status.dart';
import 'package:homiq/utils/login/lib/login_system.dart';
import 'package:country_picker/country_picker.dart';
import 'package:homiq/utils/responsive_size.dart';
import 'package:homiq/utils/ui_utils.dart';

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

class LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController identifierController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String selectedType = 'mobile';
  Country _selectedCountry = Country.parse('IN');

  MMultiAuthentication loginSystem = MMultiAuthentication({
    'google': GoogleLogin(),
    'apple': AppleLogin(),
  });

  late AnimationController _entranceController;
  late Animation<double> _formFadeAnimation;
  late Animation<Offset> _formSlideAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _formFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeIn),
      ),
    );

    _formSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _entranceController.forward();

    loginSystem
      ..init()
      ..setContext(context)
      ..listen((MLoginState state) {
        if (state is MProgress) unawaited(Widgets.showLoader(context));
        if (state is MSuccess) {
          _handleSocialLoginBackendVerify(state);
        }
        if (state is MFail) {
          _handleLoginFailure(state.error.toString());
        }
      });
  }

  void _handleSocialLoginBackendVerify(MSuccess state) {}

  void _handleLoginFailure(String error) {
    if (error != 'google-terminated') {
      HelperUtils.showSnackBarMessage(context, error, type: MessageType.error);
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    identifierController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: Scaffold(
        backgroundColor: context.color.primaryColor,
        body: Stack(
          children: [
            // Modern Animated Rose Gold Mesh Background
            Container(
              decoration: BoxDecoration(gradient: context.color.meshGradient),
            ),
            // Floating Decorative Glows
            Positioned(
              top: -150,
              right: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.color.tertiaryColor.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              left: -150,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.color.accentColor.withValues(alpha: 0.1),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    _buildHeader(),
                    const SizedBox(height: 48),
                    SlideTransition(
                      position: _formSlideAnimation,
                      child: FadeTransition(
                        opacity: _formFadeAnimation,
                        child: _buildLoginCard(),
                      ),
                    ),
                    const SizedBox(height: 48),
                    _buildSocialLoginSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          height: 120.rh(context),
          width: 120.rh(context),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.color.brightness == Brightness.light
                ? Colors.white
                : context.color.secondaryColor,
            boxShadow: [
              BoxShadow(
                color: context.color.tertiaryColor.withValues(alpha: 0.1),
                blurRadius: 30,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Image.asset(AppIcons.splashLogo, fit: BoxFit.contain),
        ),
        const SizedBox(height: 24),
        CustomText(
          'HOMIQ AI',
          fontSize: 36,
          fontWeight: FontWeight.w400,
          color: context.color.textColorDark,
          letterSpacing: 2,
          useSerif: true,
        ),
        const SizedBox(height: 12),
        CustomText(
          'PREMIUM INTERIOR INTELLIGENCE',
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: context.color.textLightColor,
          letterSpacing: 3,
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            'Welcome',
            fontSize: 28,
            fontWeight: FontWeight.w400,
            useSerif: true,
          ),
          const SizedBox(height: 32),
          _buildPhoneField(),
          const SizedBox(height: 32),
          _buildSendOtpButton(),
        ],
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        color: context.color.brightness == Brightness.light
            ? Colors.white
            : context.color.secondaryColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.color.tertiaryColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              showCountryPicker(
                context: context,
                showPhoneCode: true,
                useSafeArea: true,
                onSelect: (Country country) {
                  setState(() => _selectedCountry = country);
                },
                countryListTheme: CountryListThemeData(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  backgroundColor: context.color.secondaryColor,
                  textStyle: TextStyle(color: context.color.textColorDark),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: context.color.tertiaryColor.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    _selectedCountry.flagEmoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(width: 10),
                  CustomText(
                    '+${_selectedCountry.phoneCode}',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: context.color.textLightColor,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: identifierController,
              keyboardType: TextInputType.phone,
              style: TextStyle(
                color: context.color.textColorDark,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Field Required';
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Phone Number',
                hintStyle: TextStyle(
                  color: context.color.textLightColor.withOpacity(0.4),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendOtpButton() {
    return MultiBlocListener(
      listeners: [
        BlocListener<SendOtpCubit, SendOtpState>(
          listener: (context, state) {
            if (state is SendOtpSuccess) {
              HelperUtils.showSnackBarMessage(
                context,
                state.message ?? 'Verification code sent',
              );
              Navigator.pushNamed(
                context,
                Routes.otp,
                arguments: {
                  'identifier': '+${_selectedCountry.phoneCode}${identifierController.text}',
                  'type': selectedType,
                  'isDeleteAccount': widget.isDeleteAccount ?? false,
                },
              );
            }
            if (state is SendOtpFailure) {
              HelperUtils.showSnackBarMessage(
                context,
                state.errorMessage,
                type: MessageType.error,
              );
            }
          },
        ),
        BlocListener<VerifyOtpCubit, VerifyOtpState>(
          listener: (context, state) {
            if (state is VerifyOtpSuccess) {
              // Update global authentication state
              context.read<AuthenticationCubit>().setAuthenticated(
                AuthenticationState.authenticated,
              );
            }
            if (state is VerifyOtpFailure) {
              HelperUtils.showSnackBarMessage(
                context,
                state.errorMessage,
                type: MessageType.error,
              );
            }
          },
        ),
      ],
      child: BlocBuilder<SendOtpCubit, SendOtpState>(
        builder: (context, state) {
          return Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: context.color.tertiaryColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: state is SendOtpInProgress ? null : _handleSendOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.color.tertiaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: state is SendOtpInProgress
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const CustomText(
                      'SEND VERIFICATION CODE',
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
            ),
          );
        },
      ),
    );
  }

  void _handleSendOtp() {
    if (_formKey.currentState!.validate()) {
      context.read<SendOtpCubit>().sendOtp(
        identifier:
            '+${_selectedCountry.phoneCode}${identifierController.text}',
        type: selectedType,
      );
    }
  }

  Widget _buildSocialLoginSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(
                color: context.color.tertiaryColor.withValues(alpha: 0.2),
                thickness: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomText(
                'EXCLUSIVE SIGN IN',
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: context.color.textLightColor.withOpacity(0.5),
                letterSpacing: 2,
              ),
            ),
            Expanded(
              child: Divider(
                color: context.color.tertiaryColor.withValues(alpha: 0.2),
                thickness: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialIcon(AppIcons.google, () async {
              await loginSystem.setActive('google');
              await loginSystem.login();
            }),
            if (Theme.of(context).platform == TargetPlatform.iOS) ...[
              const SizedBox(width: 32),
              _socialIcon(AppIcons.apple, () async {
                await loginSystem.setActive('apple');
                await loginSystem.login();
              }),
            ],
          ],
        ),
      ],
    );
  }

  Widget _socialIcon(FaIconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.color.brightness == Brightness.light
              ? Colors.white
              : Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: Border.all(
            color: context.color.tertiaryColor.withValues(alpha: 0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FaIcon(icon, color: context.color.textColorDark, size: 28),
      ),
    );
  }
}
