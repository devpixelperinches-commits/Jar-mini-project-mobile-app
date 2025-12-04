import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarpay/constants/AppImages.dart';
import 'package:jarpay/constants/colors.dart';
import 'package:jarpay/constants/font.dart';
import 'package:jarpay/core/provider/mfa_provider.dart';
import 'package:jarpay/core/storage/secure_storage_service.dart';
import 'package:jarpay/features/authentication/providers/login_notifier.dart';
import 'package:jarpay/features/mfa/controller/mfa_controller.dart';
import 'package:jarpay/widgets/customHeader.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMfaEnabled = ref.watch(mfaEnabledProvider);
    final mfaController = ref.read(mfaControllerProvider);

    Future<void> onLogout() async {
      final notifier = ref.read(loginNotifierProvider.notifier);

      try {
        await notifier.logout();
        await SecureStorageService.clearAll();
        if (context.mounted) context.go('/login');
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Logout failed: $e")));
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomHeader(title: "Settings", showBackButton: false),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    // 🔹 Section 1 — MFA + Change Password
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          // MFA Switch
                          InkWell(
                            onTap: () => context.push('/profile'),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20,
                              ),
                              child: SizedBox(
                                height: 45,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Profile",
                                      style: AppTextStyles.settingText16,
                                    ),
                                    SvgPicture.asset(
                                      AppImages.forward,
                                      height: 20,
                                      width: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 0.5,
                            color: const Color(
                              0xFFD3D3D3,
                            ).withValues(alpha: 0.7),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20,
                            ),
                            child: SizedBox(
                              height: 45,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Enable MFA",
                                    style: AppTextStyles.settingText16,
                                  ),
                                  Switch(
                                    value: isMfaEnabled,
                                    onChanged: (v) => mfaController.toggleMfa(
                                      enable: v,
                                      context: context,
                                    ),
                                    activeTrackColor: AppColors.appColor,
                                    inactiveTrackColor:
                                        AppColors.neutralLightGrey,
                                    thumbColor: const WidgetStatePropertyAll(
                                      Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Divider
                          Container(
                            height: 0.5,
                            color: const Color(
                              0xFFD3D3D3,
                            ).withValues(alpha: 0.7),
                          ),

                          // Change Password
                          InkWell(
                            onTap: () => context.push('/resetpassword'),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20,
                              ),
                              child: SizedBox(
                                height: 45,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Change Password",
                                      style: AppTextStyles.settingText16,
                                    ),
                                    SvgPicture.asset(
                                      AppImages.forward,
                                      height: 20,
                                      width: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 🔹 Section 2 — Logout
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        onTap: onLogout,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: SizedBox(
                            height: 45,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.logout,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "Logout",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                SvgPicture.asset(
                                  AppImages.forward,
                                  height: 20,
                                  width: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
