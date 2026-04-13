import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homiq/exports/main_export.dart';
import 'package:homiq/utils/login/apple_login/apple_login.dart';
import 'package:homiq/utils/login/google_login/google_login.dart';
import 'package:homiq/utils/login/lib/login_status.dart';
import 'package:homiq/utils/login/lib/login_system.dart';
import 'package:country_picker/country_picker.dart';

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
          Widgets.hideLoder(context);
          _handleSocialLoginBackendVerify(state);
        }
        if (state is MFail) {
          Widgets.hideLoder(context);
          _handleLoginFailure(state.error.toString());
        }
      });
  }

  void _handleSocialLoginBackendVerify(MSuccess state) {
    context.read<VerifyOtpCubit>().socialLogin(
      provider: state.type,
      socialId: state.credentials.user!.uid,
      email: state.credentials.user?.email ?? '',
      name: state.credentials.user?.displayName,
    );
  }

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
            // Luxury Mesh Gradient Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: context.color.brightness == Brightness.light
                      ? [
                          const Color(0xFFFBFBF9),
                          const Color(0xFFF5F5F4),
                          context.color.tertiaryColor.withValues(alpha: 0.15),
                          const Color(0xFFFBFBF9),
                        ]
                      : [
                          const Color(0xFF0C0A09),
                          const Color(0xFF1C1917),
                          context.color.tertiaryColor.withValues(alpha: 0.25),
                          const Color(0xFF0C0A09),
                        ],
                  stops: const [0.0, 0.4, 0.8, 1.0],
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
          height: 150.rh(context),
          width: 150.rh(context),

          child: Image.asset(AppIcons.splashLogo, fit: BoxFit.contain),
        ),
        const SizedBox(height: 10),
        CustomText(
          'HOMIQ AI',
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: context.color.textColorDark,
          letterSpacing: 4,
          useSerif: true,
        ),
        const SizedBox(height: 8),
        CustomText(
          'Luxury Interior Redesigned',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: context.color.textLightColor,
          letterSpacing: 1,
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(10),

      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              'Welcome Back',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: context.color.textColorDark,
              useSerif: true,
            ),
            const SizedBox(height: 8),
            CustomText(
              'Sign in with your mobile number',
              fontSize: 13,
              color: context.color.textLightColor,
            ),
            const SizedBox(height: 32),
            _buildPhoneField(),
            const SizedBox(height: 32),
            _buildSendOtpButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.color.tertiaryColor.withValues(alpha: 0.1),
        ),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  CustomText(
                    '+${_selectedCountry.phoneCode}',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
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
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Enter Phone Number',
                hintStyle: TextStyle(
                  color: context.color.textLightColor.withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
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
              Navigator.pushNamed(
                context,
                Routes.otpScreen,
                arguments: {
                  'identifier':
                      '+${_selectedCountry.phoneCode}${identifierController.text}',
                  'type': selectedType,
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
              Navigator.pushReplacementNamed(
                context,
                Routes.main,
                arguments: {'from': 'login'},
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
