import 'package:flutter/material.dart';
import 'package:jarpay/constants/colors.dart';

class ErrorTextWidget extends StatelessWidget {
  final String errorText;
  const ErrorTextWidget({super.key, required this.errorText});

  @override
  Widget build(BuildContext context) {
    return Text(
      errorText,
      style: const TextStyle(
        color: AppColors.errorRed,
        fontSize: 12,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
