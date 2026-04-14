class ApiEndpoints {
  static const String error = 'error';
  static const String message = 'message';
  static const String login = '/login';

  // Auth Endpoints
  static const String apiSendOtp = '/auth/otp/send';
  static const String apiVerifyOtp = '/auth/otp/verify';
  static const String apiGetProfile = '/profile';
  static const String apiLogout = '/logout';
  static const String apiSocialLogin = '/auth/social/login';

  // Design Studio & History Endpoints
  static const String apiGetStyles = '/styles';
  static const String apiGetDesigns = '/designs';
  static const String apiGenerateDesign = '/designs/generate';

  // System & Settings Endpoints
  static const String apiGetAppSettings = '/app-settings';
  static const String apiGetLanguages = '/get_languages';
  static const String apiGetPaymentSettings = '/get_payment_settings';

  static const String apiGetNotificationList = '/get_notifications';
  static const String baseUrl = 'https://homiq.acrocoder.com';
}

typedef Api = ApiEndpoints;
