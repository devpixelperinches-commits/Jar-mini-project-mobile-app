import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:jarpay/constants/AppImages.dart';
import 'package:jarpay/constants/font.dart';

class CustomHeader extends StatelessWidget {
  final String? title;
  final VoidCallback? onBack;
  final bool showBackButton;

  const CustomHeader({
    super.key,
    this.title,
    this.onBack,
    this.showBackButton = true
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: SizedBox(
        width: double.infinity, // 🔹 Makes the Stack fill the page width
        height: 40,              // optional: gives consistent height
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 🔹 Centered Title
            if (title != null && title!.isNotEmpty)
              Center(
                child: Text(
                  title!,
                  style: AppTextStyles.header,
                  textAlign: TextAlign.center,
                ),
              ),

            // 🔹 Back Button (Left)
            if (showBackButton) 
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
               onTap: onBack ?? () => context.pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBEBEB), // Neutral-Off-White
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SvgPicture.asset(
                    AppImages.backIcon,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
