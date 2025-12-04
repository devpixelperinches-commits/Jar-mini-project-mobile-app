// widgets/common/loader_overlay.dart
import 'package:flutter/material.dart';
import 'package:jarpay/constants/colors.dart';

class LoaderOverlay extends StatelessWidget {
  final bool isLoading;
  final Color backgroundColor;
  final Color loaderColor;

  const LoaderOverlay({
    super.key,
    required this.isLoading,
    this.backgroundColor = const Color(0x80000000),
    this.loaderColor = AppColors.appColor,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return const SizedBox.shrink();

    return Container(
      color: backgroundColor,
      child: Center(
        child: CircularProgressIndicator(
          color: loaderColor,
        ),
      ),
    );
  }
}
