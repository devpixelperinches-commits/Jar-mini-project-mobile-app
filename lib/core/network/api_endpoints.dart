class ApiEndpoints {
  // sign up & login
  static const String register = '/user/signup';
  static const String login = '/user/login';
  static const String sendOtp = '/user/send-otp';
  static const String verifyOtp = '/user/verify-otp';
  static const String verifySignupOtp = '/user/verify-signup-otp';
  static const String resendOtp = '/user/resend-otp';

  // mfa
  static const String mfaSetup = '/user/mfa/setup';
  static const String mfaVerify = '/user/mfa/verify-otp';
  static const String disableMfa = '/user/mfa/disable';

  // reset & resend password
  static const String resendSignupOtp = '/user/signup/resendOtp';
  static const String sendChangePasswordOtp = '/user/reset-password';
  static const String updatePassword = '/user/update-password';

  // forgot
  static const String forgotPassword = '/user/forgot-password';
  static const String forgotPasswordotp = '/user/verify-forgot-otp';
  static const String changePasswordotp = '/user/verify-change-password-otp';
  static const String resetPassword = '/user/reset-password';

  // stripe
  static const String createConnectedAccount = '/user/create-stripe-account';
  static const String createPaymentIntent = '/user/create-payment-intent';
  static const String createBankPayment = '/stripe/create-bank-payment';
  static const String createStripeLocation = '/user/create-stripe-location';
  static const String captureStripePayment = '/user/capture-payment';
  static const String sendPaymentReceipt = '/user/send-payment-reciept';
  static const String getConnectedAccountBalance =
      '/user/get-connected-account-balance';

  // Transactions
  static const String getAllTransactions = '/user/get-all-transactions';

  // Settings
  static const String fetchUserProfile = '/user/get-profile';
  static const String updateUserProfile = '/user/update-profile';
  static const String changePasswordSendOtp = '/user/change-password-send-otp';
  static const String changePasswordVerifyOtp =
      '/user/change-password-verify-otp';
  static const String changePassword = '/user/change-password';

  // logout
  static const String logout = '/user/logout';

  // ref
  static const String refreshToken = '/auth/refresh-token'; // Add this

  // diagnostics
  static const String deviceIp = '/device/ip';
}
