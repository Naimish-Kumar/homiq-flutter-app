import 'dart:async';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homiq/exports/main_export.dart';
import 'package:homiq/features/auth/presentation/screens/country_picker.dart';
import 'package:homiq/utils/app_icons.dart';
import 'package:homiq/utils/custom_appbar.dart';
import 'package:homiq/utils/custom_image.dart';
import 'package:homiq/utils/responsive_size.dart';
import 'package:homiq/utils/ui_utils.dart';
import 'package:homiq/utils/validator.dart';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({required this.phone, super.key});

  final String phone;

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments! as Map;
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => SendOtpCubit()),
          BlocProvider(create: (context) => VerifyOtpCubit()),
        ],
        child: RegistrationForm(phone: arguments['phone']?.toString() ?? ''),
      ),
    );
  }
}

class _RegistrationFormState extends State<RegistrationForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  Timer? timer;
  final ValueNotifier<int> otpResendTime = ValueNotifier<int>(0);

  String countryCode = '';
  String flagEmoji = '';
  bool isFirstPasswordVisible = true;
  bool isSecondPasswordVisible = true;

  @override
  void initState() {
    super.initState();

    startTimer();
    mobileController.text = widget.phone;
  }

  @override
  void dispose() {
    timer?.cancel();
    if (mounted) otpResendTime.dispose();
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SendOtpCubit, SendOtpState>(
      listener: _handleOtpState,
      child: Scaffold(
        extendBody: true,
        backgroundColor: context.color.primaryColor,
        appBar: CustomAppBar(title: CustomText('Complete Profile')),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: _buildEmailRegistrationForm(context),
          ),
        ),
      ),
    );
  }

  void _handleOtpState(BuildContext context, SendOtpState state) {
    if (state is SendOtpInProgress) {
      Widgets.showLoader(context);
    } else if (state is SendOtpFailure) {
      HelperUtils.showSnackBarMessage(
        context,
        state.errorMessage,
        type: MessageType.error,
      );
    } else if (state is SendOtpSuccess) {
      // For now, if we still need to verify something, we go to OTP
    }
  }

  Widget _buildEmailRegistrationForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField(
              context,
              title: 'fullName'.translate(context),
              controller: nameController,
              validator: CustomTextFieldValidator.nullCheck,
              isPhoneNumber: false,
              hintText: 'fullName'.translate(context),
            ),
            _buildTextField(
              context,
              title: 'email'.translate(context),
              hintText: 'example@email.com',
              validator: CustomTextFieldValidator.email,
              controller: emailController,
              isPhoneNumber: false,
            ),
            _buildTextField(
              context,
              title: 'phoneNumber'.translate(context),
              hintText: '0000000000',
              validator: CustomTextFieldValidator.phoneNumber,
              controller: mobileController,
              keyboard: TextInputType.phone,
              isPhoneNumber: true,
            ),
            _buildPasswordField(
              context,
              title: 'password'.translate(context),
              hintText: 'password'.translate(context),
              validator: (value) => Validator.validatePassword(
                context,
                value?.toString() ?? '',
                secondFieldValue: passwordController.text,
              ),
              controller: passwordController,
              isPasswordVisible: isFirstPasswordVisible,
              onToggleVisibility: () {
                setState(
                  () => isFirstPasswordVisible = !isFirstPasswordVisible,
                );
              },
            ),
            _buildPasswordField(
              context,
              title: 'confirmPassword'.translate(context),
              hintText: 'confirmPassword'.translate(context),
              controller: confirmPasswordController,
              validator: (value) => Validator.validatePassword(
                context,
                value?.toString() ?? '',
                secondFieldValue: passwordController.text,
              ),
              isPasswordVisible: isSecondPasswordVisible,
              onToggleVisibility: () {
                setState(
                  () => isSecondPasswordVisible = !isSecondPasswordVisible,
                );
              },
            ),
            const SizedBox(height: 16),
            UiUtils.buildButton(
              context,
              buttonTitle: 'register'.translate(context),
              onPressed: _handleRegister,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      // In a phone-only flow, we might just submit the profile data
      // For now, let's assume we trigger a register API or similar
      // Since the user is already verified via phone, we might not need another OTP
      // But if the backend requires it, keep it mobile-based.
      await context.read<SendOtpCubit>().sendOtp(
        identifier: mobileController.text,
        type: 'mobile',
      );
    } else {
      await HelperUtils.showSnackBarMessage(
        context,
        'pleaseFillAllFields'.translate(context),
      );
    }
  }

  Widget _buildTextField(
    BuildContext context, {
    required String title,
    required TextEditingController controller,
    required bool isPhoneNumber,
    required String hintText,
    List<TextInputFormatter>? formaters,
    TextInputType? keyboard,
    CustomTextFieldValidator? validator,
    bool? readOnly,
    TextDirection? textDirection,
  }) {
    final requiredSymbol = CustomText(
      '*',
      color: context.color.error,
      fontWeight: FontWeight.w400,
      fontSize: context.font.md,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.rh(context)),
        Row(
          children: [
            CustomText(UiUtils.translate(context, title)),
            const SizedBox(width: 3),
            if (!isPhoneNumber) requiredSymbol,
          ],
        ),
        SizedBox(height: 10.rh(context)),
        CustomTextFormField(
          hintText: hintText,
          textDirection: textDirection,
          controller: controller,
          keyboard: keyboard,
          isReadOnly: readOnly,
          validator: isPhoneNumber ? null : validator,
          prefix: isPhoneNumber
              ? CountryPickerWidget(
                  flagEmoji: flagEmoji,
                  onTap: showCountryCode,
                )
              : null,
          formaters: formaters,
          fillColor: context.color.textLightColor.withOpacity(00.01),
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    BuildContext context, {
    required String title,
    required TextEditingController controller,
    required String hintText,
    required bool isPasswordVisible,
    required VoidCallback onToggleVisibility,
    List<TextInputFormatter>? formaters,
    TextInputType? keyboard,
    Widget? prefix,
    FormFieldValidator<dynamic>? validator,
    TextDirection? textDirection,
  }) {
    final requiredSymbol = CustomText(
      '*',
      color: context.color.error,
      fontWeight: FontWeight.w400,
      fontSize: context.font.md,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.rh(context)),
        Row(
          children: [
            CustomText(UiUtils.translate(context, title)),
            const SizedBox(width: 3),
            requiredSymbol,
          ],
        ),
        SizedBox(height: 10.rh(context)),
        TextFormField(
          textDirection: textDirection,
          controller: controller,
          obscureText: isPasswordVisible,
          inputFormatters: formaters,
          keyboardAppearance: Brightness.light,
          style: TextStyle(
            fontSize: context.font.md,
            color: context.color.textColorDark,
          ),
          validator: validator,
          keyboardType: keyboard,
          decoration: InputDecoration(
            prefix: prefix,
            hintText: hintText,
            suffixIcon: GestureDetector(
              onTap: onToggleVisibility,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: CustomImage(
                  icon: isPasswordVisible ? AppIcons.eye : AppIcons.eyeSlash,
                  color: context.color.textColorDark.withOpacity(0.5),
                  width: 24.rw(context),
                  height: 24.rh(context),
                ),
              ),
            ),
            hintStyle: TextStyle(
              color: context.color.textColorDark.withOpacity(0.7),
              fontSize: context.font.md,
            ),
            filled: true,
            fillColor: context.color.primaryColor,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                width: 1.5,
                color: context.color.tertiaryColor,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                width: 1.5,
                color: context.color.borderColor,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                width: 1.5,
                color: context.color.borderColor,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  void showCountryCode() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      countryListTheme: CountryListThemeData(
        searchTextStyle: TextStyle(color: context.color.textColorDark),
        textStyle: TextStyle(color: context.color.textColorDark),
        borderRadius: BorderRadius.circular(8),
        backgroundColor: context.color.backgroundColor,
        inputDecoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          iconColor: context.color.tertiaryColor,
          prefixIconColor: context.color.tertiaryColor,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: context.color.tertiaryColor),
          ),
          floatingLabelStyle: TextStyle(color: context.color.tertiaryColor),
          labelText: 'search'.translate(context),
          border: const OutlineInputBorder(),
        ),
      ),
      onSelect: (value) {
        setState(() {
          flagEmoji = value.flagEmoji;
          countryCode = value.phoneCode;
        });
      },
    );
  }

  Widget resendOtpTimerWidget() {
    return ValueListenableBuilder(
      valueListenable: otpResendTime,
      builder: (context, value, _) {
        if (!(timer?.isActive ?? false)) {
          return const SizedBox.shrink();
        }

        String formatSecondsToMinutes(int seconds) {
          final minutes = seconds ~/ 60;
          final remainingSeconds = seconds % 60;
          return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
        }

        final textColor = Theme.of(context).colorScheme.textColorDark;
        final tertiaryColor = Theme.of(context).colorScheme.tertiaryColor;

        return SizedBox(
          height: 70,
          child: Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                text: "${UiUtils.translate(context, "resendMessage")} ",
                style: TextStyle(color: textColor, letterSpacing: 0.5),
                children: <TextSpan>[
                  TextSpan(
                    text: formatSecondsToMinutes(value),
                    style: TextStyle(
                      color: tertiaryColor,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  TextSpan(
                    text: UiUtils.translate(context, 'resendMessageDuration'),
                    style: TextStyle(
                      color: tertiaryColor,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void resendOTP() {
    context.read<SendOtpCubit>().sendOtp(
      identifier: emailController.text.trim(),
      type: 'email',
    );
  }

  Future<void> startTimer() async {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (otpResendTime.value == 0) {
        timer.cancel();
      
        setState(() {});
      } else if (mounted) {
        otpResendTime.value--;
      }
    });
  }
}
