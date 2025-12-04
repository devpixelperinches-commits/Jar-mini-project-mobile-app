import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:jarpay/constants/AppImages.dart';

class FilterButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const FilterButton({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF96E9C6)),
          color: const Color(0xFF96E9C6).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            // const SizedBox(width: 5),
            // SvgPicture.asset(
            //  AppImages.forward,
            //   height: 12,
            //   width: 12,
            // ),
          ],
        ),
      ),
    );
  }
}
