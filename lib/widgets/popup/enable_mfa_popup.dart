import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:jarpay/widgets/custom_button.dart';
import 'package:jarpay/constants/AppImages.dart';

class EnableMfaPopup extends StatelessWidget {
  const EnableMfaPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //  Close popup when tapping outside
      onTap: () => Navigator.of(context).pop(),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: GestureDetector(
          onTap: () {}, // prevent tap inside dialog from closing
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                /// 🔹 Popup Content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      'Enable MFA',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'For better security, please enable multi-factor authentication (MFA).',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    /// ✅ Enable Now button
                    CustomButton(
                      text: 'Enable Now',
                      onPressed: () {
                        Navigator.of(context).pop(); // close popup
                        context.push('/settings'); // navigate to settings
                      },
                    ),

                    /// Always visible short message
                    const SizedBox(height: 30),
                    // const Text(
                    //   'If you wish to enable MFA later,\nplease go to Settings and turn it on.',
                    //   textAlign: TextAlign.center,
                    //   style: TextStyle(
                    //     fontSize: 13,
                    //     color: Colors.grey,
                    //   ),
                    // ),
                  ],
                ),

                ///  Close icon
                Positioned(
                  top: -5,
                  right: -5,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: SvgPicture.asset(
                      AppImages.close,
                      width: 22,
                      height: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
