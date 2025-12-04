import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:jarpay/constants/AppImages.dart';
import 'package:jarpay/constants/font.dart';
import 'package:jarpay/core/utils/device_location_helper.dart';

import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> _slides = [
    {
      "text": "Accept every type of payment with Jar Pay",
      "svg": AppImages.onboarding1,
    },
    {
      "text": "Sign up and sell in minutes - no commitments or hidden fees",
      "svg": AppImages.onboarding2,
    },
    {
      "text": "Simple and useful reports to help grow your business",
      "svg": AppImages.onboarding3,
    },
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () async {
      final info = await DeviceLocationHelper.getDeviceAndLocation();
      debugPrint("📍 Device and Location Info: $info");
    });

    // Auto-slide every 3 second
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_controller.hasClients) {
        _currentPage = (_currentPage + 1) % _slides.length;
        _controller.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6C22A6),
      body: Stack(
        children: [
          /// --- Gradient background ---
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C22A6), Color(0xFF96E9C6)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          /// --- Main content ---
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemCount: _slides.length,
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              slide["text"]!,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.heading20White,
                            ),
                            const SizedBox(height: 40),
                            SvgPicture.asset(slide["svg"]!, height: 250),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // ✅ The dots are visible now (moved outside the gradient clipping)
                const SizedBox(height: 20),
                SmoothPageIndicator(
                  controller: _controller,
                  count: _slides.length,
                  effect: const ExpandingDotsEffect(
                    activeDotColor: Colors.white,
                    dotColor: Colors.white38,
                    dotHeight: 8,
                    dotWidth: 8,
                  ),
                ),
                const SizedBox(height: 130), // leaves space for white section
              ],
            ),
          ),

          /// --- Fixed Bottom Section ---
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 345,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        context.push('/register');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C22A6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                      ),
                      child: const Text(
                        "Create an account",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      text: "Already have an account? ",
                      style: AppTextStyles.smallText11,
                      children: [
                        TextSpan(
                          text: "Sign In",
                          style: AppTextStyles.heading14appcolor,
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              context.push('/login');
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
