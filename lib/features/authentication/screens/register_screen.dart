import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarpay/constants/AppImages.dart';
import 'package:jarpay/constants/colors.dart';
import 'package:jarpay/constants/font.dart';
import 'package:jarpay/core/utils/validation_helper.dart';
import 'package:jarpay/features/authentication/controller/register_controller.dart';
import 'package:jarpay/features/authentication/providers/register_notifier.dart';
import 'package:jarpay/widgets/customHeader.dart';
import 'package:jarpay/widgets/custom_button.dart';
import 'package:jarpay/widgets/custom_input_field.dart';
import 'package:jarpay/widgets/password_requirements.dart';

class Register extends ConsumerStatefulWidget {
  const Register({super.key});

  @override
  ConsumerState<Register> createState() => _RegisterState();
}

class _RegisterState extends ConsumerState<Register> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _contact = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final Map<String, String?> _errors = {};

  @override
  void dispose() {
    // ✅ Dispose controllers to prevent memory leaks
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _contact.dispose();
    super.dispose();
  }

  void _clearError(String key) {
    if (_errors[key] != null) {
      setState(() {
        _errors.remove(key);
      });
    }
  }

  Future<void> _validateAndContinue() async {
    final registerState = ref.read(registerNotifierProvider);

    if (registerState.isLoading) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _errors.clear();

      if (_firstName.text.trim().isEmpty) {
        _errors["firstName"] = "Required field";
      }

      if (_lastName.text.trim().isEmpty) {
        _errors["lastName"] = "Required field";
      }

      final emailError = ValidationHelper.validateEmail(_email.text.trim());
      if (emailError != null) _errors["email"] = emailError;

      final passwordError = ValidationHelper.validatePassword(
        _password.text.trim(),
      );
      if (passwordError != null) _errors["password"] = passwordError;

      final confirmPasswordError = ValidationHelper.validateConfirmPassword(
        _password.text.trim(),
        _confirmPassword.text.trim(),
      );
      if (confirmPasswordError != null) {
        _errors["confirmPassword"] = confirmPasswordError;
      }

      final contactError = ValidationHelper.validateContact(
        _contact.text.trim(),
      );
      if (contactError != null) _errors["contact"] = contactError;
    });

    if (_errors.isNotEmpty) return;

    final userData = {
      "firstName": _firstName.text.trim(),
      "lastName": _lastName.text.trim(),
      "email": _email.text.trim(),
      "password": _password.text.trim(),
      "mobileNumber": _contact.text.trim(),
    };

    await ref
        .read(registerControllerProvider)
        .registerUser(userData: userData, context: context);
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(registerNotifierProvider);

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
                        const SizedBox(height: 10),
                        const Text(
                          "Create an account.",
                          style: AppTextStyles.heading28,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Personal details",
                          style: AppTextStyles.detail16,
                        ),
                        const SizedBox(height: 30),

                        CustomInputField(
                          label: "First Name*",
                          hintText: "Enter your first name",
                          controller: _firstName,
                          errorText: _errors["firstName"],
                          onChanged: (_) => _clearError("firstName"),
                        ),
                        const SizedBox(height: 20),

                        CustomInputField(
                          label: "Last Name*",
                          hintText: "Enter your last name",
                          controller: _lastName,
                          errorText: _errors["lastName"],
                          onChanged: (_) => _clearError("lastName"),
                        ),
                        const SizedBox(height: 20),

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
                          onChanged: (_) {
                            _clearError("password");
                            setState(() {});
                          },
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: SvgPicture.asset(
                                  _isPasswordVisible
                                      ? AppImages.eyeopen
                                      : AppImages.eyeclose,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        PasswordRequirements(password: _password.text),
                        const SizedBox(height: 20),

                        CustomInputField(
                          label: "Confirm Password*",
                          hintText: "Re-enter your password",
                          controller: _confirmPassword,
                          obscureText: !_isConfirmPasswordVisible,
                          errorText: _errors["confirmPassword"],
                          onChanged: (_) => _clearError("confirmPassword"),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: SvgPicture.asset(
                                  _isConfirmPasswordVisible
                                      ? AppImages.eyeopen
                                      : AppImages.eyeclose,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        CustomInputField(
                          label: "Contact number*",
                          hintText: "+44",
                          controller: _contact,
                          errorText: _errors["contact"],
                          onChanged: (_) => _clearError("contact"),
                        ),
                        const SizedBox(height: 30),

                        CustomButton(
                          text: registerState.isLoading
                              ? "Registering..."
                              : "Register",
                          onPressed: _validateAndContinue,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                  // ✅ Show loading overlay
                  if (registerState.isLoading)
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
