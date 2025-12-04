import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jarpay/constants/AppImages.dart';
import 'package:jarpay/constants/colors.dart';
import 'package:jarpay/constants/font.dart';

/// Widget that displays password requirements and validates them in real-time
class PasswordRequirements extends StatelessWidget {
  final String password;

  const PasswordRequirements({super.key, required this.password});

  // Password validation getters
  bool get hasMinLength => password.length >= 12;
  bool get hasUppercase => password.contains(RegExp(r'[A-Z]'));
  bool get hasLowercase => password.contains(RegExp(r'[a-z]'));
  bool get hasNumber => password.contains(RegExp(r'[0-9]'));
  bool get hasSpecialChar => password.contains(RegExp(r'[!@#\$&*~.,%^]'));

  /// Returns true if all password requirements are met
  bool get isPasswordValid {
    return hasMinLength &&
        hasUppercase &&
        hasLowercase &&
        hasNumber &&
        hasSpecialChar;
  }

  /// Returns the number of requirements that are met
  int get metRequirementsCount {
    int count = 0;
    if (hasMinLength) count++;
    if (hasUppercase) count++;
    if (hasLowercase) count++;
    if (hasNumber) count++;
    if (hasSpecialChar) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Passwords must meet these requirements:",
          style: AppTextStyles.heading14black,
        ),
        const SizedBox(height: 10),
        _buildRequirement("12 character minimum", hasMinLength),
        _buildRequirement("One uppercase character", hasUppercase),
        _buildRequirement("One lowercase character", hasLowercase),
        _buildRequirement("One number", hasNumber),
        _buildRequirement(
          "One special character (!@#\$&*~.,%^)",
          hasSpecialChar,
        ),
      ],
    );
  }

  /// Builds a single password requirement row with icon and text
  Widget _buildRequirement(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          // Checkmark icon
          SvgPicture.asset(
            isValid ? AppImages.checkmark : AppImages.checkmarkred,
            width: 16,
            height: 16,
          ),
          const SizedBox(width: 8),

          // Requirement text
          Expanded(
            child: Text(
              text,
              style:
                  const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    height: 1.2,
                  ).copyWith(
                    color:
                        isValid ? AppColors.green : AppColors.errorRed,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Alternative version with progress indicator
class PasswordRequirementsWithProgress extends StatelessWidget {
  final String password;

  const PasswordRequirementsWithProgress({super.key, required this.password});

  // Password validation getters
  bool get hasMinLength => password.length >= 12;
  bool get hasUppercase => password.contains(RegExp(r'[A-Z]'));
  bool get hasLowercase => password.contains(RegExp(r'[a-z]'));
  bool get hasNumber => password.contains(RegExp(r'[0-9]'));
  bool get hasSpecialChar => password.contains(RegExp(r'[!@#\$&*~.,%^]'));

  int get metRequirementsCount {
    int count = 0;
    if (hasMinLength) count++;
    if (hasUppercase) count++;
    if (hasLowercase) count++;
    if (hasNumber) count++;
    if (hasSpecialChar) count++;
    return count;
  }

  double get progress => metRequirementsCount / 5.0;

  Color get strengthColor {
    if (progress < 0.4) return AppColors.errorRed; // Red
    if (progress < 0.8) return AppColors.warningOrange; // Orange
    return AppColors.green; // Green
  }

  String get strengthText {
    if (progress < 0.4) return 'Weak';
    if (progress < 0.8) return 'Medium';
    return 'Strong';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with strength indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Password Strength:",
              style: AppTextStyles.heading14black,
            ),
            Text(
              strengthText,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: strengthColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
            minHeight: 6,
          ),
        ),

        const SizedBox(height: 16),

        // Requirements list
        const Text("Requirements:", style: AppTextStyles.heading14black),
        const SizedBox(height: 10),
        _buildRequirement("12 character minimum", hasMinLength),
        _buildRequirement("One uppercase character", hasUppercase),
        _buildRequirement("One lowercase character", hasLowercase),
        _buildRequirement("One number", hasNumber),
        _buildRequirement(
          "One special character (!@#\$&*~.,%^)",
          hasSpecialChar,
        ),
      ],
    );
  }

  Widget _buildRequirement(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SvgPicture.asset(
            isValid ? AppImages.checkmark : AppImages.checkmarkred,
            width: 16,
            height: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style:
                  const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    height: 1.2,
                  ).copyWith(
                    color: isValid
                        ? AppColors.green
                        : AppColors.errorRed,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
