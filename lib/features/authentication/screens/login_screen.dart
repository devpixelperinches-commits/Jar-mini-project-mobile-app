import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:jarpay/constants/AppImages.dart';
import 'package:jarpay/constants/colors.dart';
import 'package:jarpay/constants/font.dart';
import 'package:jarpay/core/utils/validation_helper.dart';
import 'package:jarpay/features/authentication/controller/login_controller.dart';
import 'package:jarpay/features/authentication/providers/login_notifier.dart';
import 'package:jarpay/widgets/customHeader.dart';
import 'package:jarpay/widgets/custom_button.dart';
import 'package:jarpay/widgets/custom_input_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final Map<String, String> _errors = {};
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _clearError(String key) {
    setState(() {
      _errors.remove(key);
    });
  }

  Future<void> _validateAndLogin() async {
    _errors.clear();

    final emailError = ValidationHelper.validateEmail(_email.text.trim());
    if (emailError != null) _errors["email"] = emailError;

    if (_password.text.trim().isEmpty) {
      _errors["password"] = "Required field";
    }

    if (_errors.isNotEmpty) {
      setState(() {});
      return;
    }

    final loginController = ref.read(loginControllerProvider);
    await loginController.loginUser(
      email: _email.text.trim(),
      password: _password.text.trim(),
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          "Welcome to Jar",
                          style: AppTextStyles.heading28,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Sign in to continue",
                          style: AppTextStyles.detail16,
                        ),
                        const SizedBox(height: 40),

                        CustomInputField(
                          label: "Email address*",
                          hintText: "Enter your email",
                          controller: _email,
                          errorText: _errors["email"],
                          onChanged: (_) => _clearError("email"),
                        ),
                        const SizedBox(height: 20),

                        CustomInputField(
                          label: "Password*",
                          hintText: "Enter your password",
                          controller: _password,
                          obscureText: !_isPasswordVisible,
                          errorText: _errors["password"],
                          onChanged: (_) => _clearError("password"),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SvgPicture.asset(
                                _isPasswordVisible
                                    ? AppImages.eyeopen
                                    : AppImages.eyeclose,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        CustomButton(
                          text: "Sign In",
                          onPressed: _validateAndLogin,
                        ),
                        const SizedBox(height: 20),

                        Center(
                          child: GestureDetector(
                            onTap: () => context.push('/forgot-password'),
                            child: Text(
                              "Forgot Password?",
                              style: AppTextStyles.heading14appcolor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),

                        Center(
                          child: GestureDetector(
                            onTap: () => context.push('/register'),
                            child: Text(
                              "Create an account",
                              style: AppTextStyles.heading20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  if (loginState.isLoading)
                    Container(
                      color: Colors.black26,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
