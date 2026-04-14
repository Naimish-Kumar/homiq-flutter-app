import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homiq/data/cubits/system/delete_account_cubit.dart';
import 'package:homiq/exports/main_export.dart';
import 'package:homiq/features/auth/presentation/blocs/auth_state_cubit.dart';
import 'package:homiq/utils/ui_utils.dart';
import 'package:sms_autofill/sms_autofill.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    required this.identifier,
    required this.type,
    required this.isDeleteAccount,
    super.key,
  });

  final String identifier;
  final String type;
  final bool isDeleteAccount;

  @override
  State<OtpScreen> createState() => _OtpScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments! as Map;
    return CupertinoPageRoute(
      builder: (_) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => SendOtpCubit()),
            BlocProvider(create: (context) => VerifyOtpCubit()),
          ],
          child: OtpScreen(
            identifier: arguments['identifier']?.toString() ?? '',
            type: arguments['type']?.toString() ?? 'mobile',
            isDeleteAccount: arguments['isDeleteAccount'] as bool? ?? false,
          ),
        );
      },
    );
  }
}

class _OtpScreenState extends State<OtpScreen> {
  Timer? timer;
  ValueNotifier<int> otpResendTime = ValueNotifier<int>(0);
  final TextEditingController otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    otpResendTime.dispose();
    otpController.dispose();
    super.dispose();
  }

  void startTimer() {
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (otpResendTime.value == 0) {
        timer.cancel();
      } else {
        if (mounted) otpResendTime.value--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: BlocListener<VerifyOtpCubit, VerifyOtpState>(
        listener: (context, state) {
          if (state is VerifyOtpInProgress) Widgets.showLoader(context);
          if (state is VerifyOtpFailure) {
            HelperUtils.showSnackBarMessage(
              context,
              state.errorMessage,
              type: MessageType.error,
            );
          }
          if (state is VerifyOtpSuccess) {
            Widgets.hideLoader(context);
            
            // Save token and authenticate
            HiveUtils.setJWT(state.accessToken ?? '');
            HiveUtils.setIsNotGuest();
            HiveUtils.setUserIsAuthenticated();
            
            context.read<AuthenticationCubit>().setAuthenticated(
              AuthenticationState.authenticated,
            );

            if (widget.isDeleteAccount) {
              context.read<DeleteAccountCubit>().deleteUserAccount();
            } else {
              // Refresh user details then go home
              context.read<GetUserDataCubit>().getUserData();
              Future.delayed(const Duration(milliseconds: 500), () {
                Navigator.pushReplacementNamed(context, Routes.mainActivity);
              });
            }
          }
        },
        child: Scaffold(
          backgroundColor: context.color.primaryColor,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: context.color.textColorDark,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
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
                            context.color.tertiaryColor.withValues(alpha: 0.1),
                            const Color(0xFFFBFBF9),
                          ]
                        : [
                            const Color(0xFF0C0A09),
                            const Color(0xFF1C1917),
                            context.color.tertiaryColor.withValues(alpha: 0.2),
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
                      const SizedBox(height: 40),
                      _buildHeader(),
                      const SizedBox(height: 60),
                      _buildOtpInput(),
                      const SizedBox(height: 60),
                      _buildVerifyButton(),
                      const SizedBox(height: 32),
                      _buildResendSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.color.tertiaryColor.withValues(alpha: 0.05),
          ),
          child: Icon(
            Icons.mark_email_unread_rounded,
            size: 60,
            color: context.color.tertiaryColor,
          ),
        ),
        const SizedBox(height: 32),
        CustomText(
          'Verification Code',
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: context.color.textColorDark,
          letterSpacing: 1,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                color: context.color.textLightColor,
                fontSize: 15,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
              children: [
                const TextSpan(
                  text: 'We have sent a 6-digit verification code to ',
                ),
                TextSpan(
                  text: widget.identifier,
                  style: TextStyle(
                    color: context.color.textColorDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpInput() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: PinFieldAutoFill(
        controller: otpController,
        codeLength: 6,
        decoration: UnderlineDecoration(
          textStyle: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: context.color.textColorDark,
            letterSpacing: 10,
          ),
          colorBuilder: FixedColorBuilder(
            context.color.tertiaryColor.withValues(alpha: 0.5),
          ),
          lineHeight: 2.5,
          gapSpace: 12,
        ),
        currentCode: '',
        onCodeChanged: (code) {
          if (code?.length == 6) _handleVerify();
        },
      ),
    );
  }

  Widget _buildVerifyButton() {
    return BlocBuilder<VerifyOtpCubit, VerifyOtpState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: context.color.tertiaryColor.withValues(alpha: 0.2),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: state is VerifyOtpInProgress ? null : _handleVerify,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.color.tertiaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: state is VerifyOtpInProgress
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const CustomText(
                    'VERIFY & CONTINUE',
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
          ),
        );
      },
    );
  }

  Widget _buildResendSection() {
    return ValueListenableBuilder(
      valueListenable: otpResendTime,
      builder: (context, value, child) {
        return Column(
          children: [
            if (value > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    'Resend code in ',
                    color: context.color.textLightColor,
                    fontSize: 14,
                  ),
                  CustomText(
                    '${value}s',
                    color: context.color.tertiaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ],
              )
            else
              TextButton(
                onPressed: _handleResend,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: CustomText(
                  'RESEND CODE',
                  color: context.color.tertiaryColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 1,
                ),
              ),
          ],
        );
      },
    );
  }

  void _handleVerify() {
    if (otpController.text.length == 6) {
      context.read<VerifyOtpCubit>().verifyOtp(
        otp: otpController.text,
        identifier: widget.identifier,
        type: widget.type,
      );
    }
  }

  void _handleResend() {
    context.read<SendOtpCubit>().sendOtp(
      identifier: widget.identifier,
      type: 'mobile',
    );
    startTimer();
  }
}
