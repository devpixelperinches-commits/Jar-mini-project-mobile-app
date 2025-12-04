import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarpay/core/config/bottom_nav_shell.dart';
import 'package:jarpay/core/config/navigation_service.dart';
import 'package:jarpay/core/provider/auth_provider.dart';
import 'package:jarpay/features/otp/screen/reset_password_otp.dart';
import 'package:jarpay/features/otp/screen/reset_password_screen.dart';
import 'package:jarpay/features/profile/update_profile.dart';
import 'package:jarpay/features/password/forgot_password_screen.dart';
import 'package:jarpay/features/authentication/screens/login_screen.dart';
import 'package:jarpay/features/authentication/screens/onboaring.dart';
import 'package:jarpay/features/otp/screen/otp_verification_screen.dart';
import 'package:jarpay/features/authentication/screens/register_screen.dart';
import 'package:jarpay/features/stripe/screen/onboarding_web_view.dart';
import 'package:jarpay/features/transactions/transaction_list_screen.dart';
import 'package:jarpay/features/mfa/presentation/mfa_qr_screen.dart';
import 'package:jarpay/features/mfa/presentation/mfa_verify_screen.dart';
import 'package:jarpay/features/stripe/screen/charge_screen.dart';
import 'package:jarpay/features/tab/home.dart';
import 'package:jarpay/features/tab/setting.dart';
import 'package:jarpay/features/stripe/screen/payment_setup.dart';
import 'package:jarpay/features/stripe/screen/payment_approved.dart';

import 'package:jarpay/features/settings/reset_password_otp_verify_screen.dart';
import 'package:jarpay/features/settings/reset_password_send_otp_screen.dart';
import 'package:jarpay/features/settings/change_password_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authTokenAsync = ref.watch(authTokenProvider);

  // Default router until token check completes
  if (authTokenAsync.isLoading) {
    return GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const Onboarding(),
        ),
      ],
    );
  }

  final token = authTokenAsync.value;

  final initialRoute = (token != null && token.isNotEmpty)
      ? '/home'
      : '/onboarding';

  return GoRouter(
    initialLocation: initialRoute,
    navigatorKey: rootNavigatorKey,
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const Onboarding(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const Register()),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) => const OtpVerification(),
      ),

      GoRoute(
        path: '/profile',
        builder: (context, state) => const UpdateProfileScreen(),
      ),
      GoRoute(
        path: '/resetpassword',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/transaction',
        builder: (context, state) => const TransactionListScreen(),
      ),

      GoRoute(
        path: '/verifyotp',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          final source = data['source'] ?? '';
          final token = data['token'] ?? '';
          return ResetOtpVerification(source: source, token: token);
        },
      ),
      GoRoute(
        path: '/resetForgotPassword',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          final source = data['source'] ?? '';
          final token = data['token'] ?? '';
          return ResetNewPasswordScreen(source: source, token: token);
        },
      ),

      GoRoute(
        path: '/mfaQr',
        builder: (context, state) {
          final extra = state.extra;
          String qrUrl = '';
          String from = 'unknown';
          if (extra is Map<String, dynamic>) {
            qrUrl = (extra['qrUrl'] ?? '') as String;
            from = (extra['from'] ?? 'unknown') as String;
          }
          return MfaQrScreen(qrUrl: qrUrl, from: from);
        },
      ),

      GoRoute(
        path: '/mfaVerify',
        builder: (context, state) {
          final extra = state.extra;
          Map<String, dynamic> params = {};
          if (extra is Map<String, dynamic>) {
            params = extra;
          }
          return MfaVerifyScreen(params: params);
        },
      ),

      GoRoute(
        path: '/OtpVerificationScreen',
        builder: (context, state) {
          final token = (state.extra as Map)['token'];
          return OtpVerificationPasswordScreen(token: token);
        },
      ),

      GoRoute(
        path: '/onboarding-webview',
        builder: (context, state) {
          final url = state.extra as String;
          return OnboardingWebViewScreen(url: url);
        },
      ),

      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) => BottomNavShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeController(),
          ),
          GoRoute(
            path: '/activity',
            builder: (context, state) => const TransactionListScreen(),
          ),
          GoRoute(
            path: '/payments',
            builder: (context, state) => const ChargeControlScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),

          // ✅ Add ConnectedCardReader here
          GoRoute(
            path: '/PaymentSetupScreen',
            builder: (context, state) {
              final serialNumber =
                  state.uri.queryParameters['serialNumber'] ?? '';
              final amountInPenceString =
                  state.uri.queryParameters['amountInPence'] ?? '0';
              final amountInPence = int.tryParse(amountInPenceString) ?? 0;

              return PaymentSetupScreen(
                amountInPence: amountInPence,
                serialNumber: serialNumber,
              );
            },
          ),

          // ✅ Add ConnectedCardReader here
          GoRoute(
            path: '/PaymentApprovedScreen',
            builder: (context, state) =>
                const PaymentApprovedScreen(paymentId: '', amount: 0),
          ),
        ],
      ),
    ],
  );
});
