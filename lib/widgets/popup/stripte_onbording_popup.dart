import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jarpay/constants/AppImages.dart';
import 'package:jarpay/constants/colors.dart';
import 'package:jarpay/constants/font.dart';
import 'package:jarpay/widgets/custom_button.dart';

/// A bottom sheet that prompts users to complete their Stripe onboarding
class CompleteOnboardingBottomSheet {
  /// Shows the onboarding completion bottom sheet
  ///
  /// [context] - BuildContext for displaying the bottom sheet
  /// [onComplete] - Callback triggered when user taps "Complete Onboarding"
  static void show(BuildContext context, {required VoidCallback onComplete}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _BottomSheetContent(onComplete: onComplete),
    );
  }
}

class _BottomSheetContent extends StatelessWidget {
  final VoidCallback onComplete;

  const _BottomSheetContent({required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle indicator
            _buildDragHandle(),

            const SizedBox(height: 8),

            // Close button
            _buildCloseButton(context),

            const SizedBox(height: 16),

            // Heading
            _buildHeading(),

            const SizedBox(height: 12),

            // Description
            _buildDescription(),

            const SizedBox(height: 24),

            // Illustration
            _buildIllustration(context),

            const SizedBox(height: 24),

            // Complete Onboarding Button
            CustomButton(
              text: 'Complete Onboarding',
              onPressed: () {
                if (context.mounted) {
                  onComplete();
                }
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Builds the drag handle indicator at the top
  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  /// Builds the close button
  Widget _buildCloseButton(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: InkWell(
        onTap: () {
          if (context.mounted) {
            Navigator.pop(context);
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: SvgPicture.asset(
            AppImages.close,
            width: 22,
            height: 22,
            colorFilter: ColorFilter.mode(
              Colors.grey.shade600,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the heading text
  Widget _buildHeading() {
    return Text(
      'Complete your onboarding',
      style: AppTextStyles.heading20.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: AppColors.black,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Builds the description text
  Widget _buildDescription() {
    return Text(
      "You're almost there! Just a few steps remaining to start taking payments quickly.",
      style: AppTextStyles.detail16.copyWith(
        fontSize: 14,
        color: Colors.black87,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Builds the onboarding illustration
  Widget _buildIllustration(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.25,
      child: SvgPicture.asset(AppImages.onboarding1, fit: BoxFit.contain),
    );
  }
}
