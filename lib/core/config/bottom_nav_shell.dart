import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:jarpay/constants/AppImages.dart';
import 'package:jarpay/constants/colors.dart';

class BottomNavShell extends StatefulWidget {
  final Widget child;
  const BottomNavShell({super.key, required this.child});

  @override
  State<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends State<BottomNavShell> {
  int _currentIndex = 0;

  final List<String> _routes = [
    '/home',
    '/activity',
    '/payments',
    '/settings',
  ];

  void _onTap(int index) {
  if (index != _currentIndex) {
    setState(() => _currentIndex = index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go(_routes[index]);
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        backgroundColor: AppColors.background,
        type: BottomNavigationBarType.fixed,
        // showSelectedLabels: false,
        // showUnselectedLabels: false,
        selectedItemColor: AppColors.appColor, 
        unselectedItemColor: AppColors.neutralLightGrey,

        items: [
          /// 🏠 HOME
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AppImages.homedeactive,
              width: 26,
              height: 26,
            ),
            activeIcon: SvgPicture.asset(
              AppImages.homeactive,
              width: 26,
              height: 26,
            ),
            label: 'Home',
          ),

          /// 📊 ACTIVITY
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AppImages.activitydeactive,
              width: 26,
              height: 26,
            ),
            activeIcon: SvgPicture.asset(
              AppImages.activityactive,
              width: 26,
              height: 26,
            ),
            label: 'Activity',
          ),

          /// 💳 PAYMENTS (static icon)
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AppImages.checkout,
              width: 26,
              height: 26,
            ),
            activeIcon: SvgPicture.asset(
              AppImages.checkout,
              width: 26,
              height: 26,
            ),
            label: 'Payments',
          ),

          /// ⚙️ SETTINGS (More)
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AppImages.moredeactive,
              width: 26,
              height: 26,
            ),
            activeIcon: SvgPicture.asset(
              AppImages.moreactive,
              width: 26,
              height: 26,
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
