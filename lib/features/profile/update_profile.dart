import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarpay/features/stripe/controller/setting_controller.dart';
import 'package:jarpay/widgets/customHeader.dart';
import 'package:jarpay/widgets/custom_button.dart';
import 'package:jarpay/widgets/custom_input_field.dart';
import 'package:jarpay/constants/font.dart';
import 'package:jarpay/core/utils/helpers/message_helper.dart';

class UpdateProfileScreen extends ConsumerStatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  ConsumerState<UpdateProfileScreen> createState() =>
      _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends ConsumerState<UpdateProfileScreen> {
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _number = TextEditingController();
  final TextEditingController _email = TextEditingController();

  bool isLoading = true;
  final Map<String, String> _errors = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserProfile();
    });
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _number.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _fetchUserProfile() async {
    try {
      // ✅ Updated provider name (lowercase)
      final settingsController = ref.read(settingsControllerProvider);
      final res = await settingsController.fetchUserProfile();

      debugPrint("🔍 FULL PROFILE RESPONSE: $res");

      if (res == null || res['data'] == null) return;

      final user = res['data'];
      debugPrint("fetch User Profile Control -----------: $user");

      if (!mounted) return;

      setState(() {
        _firstName.text = user['firstName']?.toString() ?? '';
        _lastName.text = user['lastName']?.toString() ?? '';
        _number.text = user['mobileNumber']?.toString() ?? '';
        _email.text = user['email']?.toString() ?? '';
      });
    } catch (e, st) {
      debugPrint("❌ Error fetching profile: $e\n$st");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _clearError(String key) {
    setState(() {
      _errors.remove(key);
    });
  }

  Future<void> _validateAndUpdate() async {
    _errors.clear();

    if (_firstName.text.trim().isEmpty) {
      _errors["firstName"] = "First name is required";
    }
    if (_lastName.text.trim().isEmpty) {
      _errors["lastName"] = "Last name is required";
    }
    if (_number.text.trim().isEmpty) {
      _errors["number"] = "Mobile number is required";
    }

    setState(() {});

    if (_errors.isNotEmpty) return;

    /// ---------------- API PAYLOAD ----------------
    final payload = {
      "firstName": _firstName.text.trim(),
      "lastName": _lastName.text.trim(),
      "mobileNumber": _number.text.trim(),
      "email": _email.text.trim(),
    };

    setState(() => isLoading = true);

    // ✅ Updated provider name (lowercase)
    final controller = ref.read(settingsControllerProvider);
    final res = await controller.updateUserProfile(payload);

    if (!mounted) return;

    setState(() => isLoading = false);

    if (res == null || res["status"] != 1) {
      if (!mounted) return;
      TopMessageHelper.showTopMessage(
        context,
        res?["message"] ?? "Something went wrong!",
        type: MessageType.error,
      );
      return;
    }

    /// ---------------- SUCCESS ----------------
    if (!mounted) return;
    TopMessageHelper.showTopMessage(
      context,
      "Profile updated successfully",
      type: MessageType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: SafeArea(
        child: Stack(
          children: [
            /// ---------- UI always builds (no freeze) ----------
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomHeader(
                  title: "Update Profile",
                  showBackButton: true,
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Edit Your Profile",
                          style: AppTextStyles.heading28,
                        ),
                        const SizedBox(height: 10),

                        Text(
                          "Update your personal information below. "
                          "Make sure all fields are correct before saving.",
                          style: AppTextStyles.detail16,
                        ),

                        const SizedBox(height: 30),

                        CustomInputField(
                          label: "First Name*",
                          hintText: "Enter your first name",
                          controller: _firstName,
                          errorText: _errors["firstName"],
                          onChanged: (_) => _clearError("firstName"),
                        ),

                        const SizedBox(height: 20),

                        CustomInputField(
                          label: "Last Name*",
                          hintText: "Enter your last name",
                          controller: _lastName,
                          errorText: _errors["lastName"],
                          onChanged: (_) => _clearError("lastName"),
                        ),

                        const SizedBox(height: 20),

                        CustomInputField(
                          label: "Mobile Number*",
                          hintText: "Enter your mobile number",
                          controller: _number,
                          errorText: _errors["number"],
                          onChanged: (_) => _clearError("number"),
                        ),

                        const SizedBox(height: 40),

                        CustomButton(
                          text: "Update Profile",
                          onPressed: _validateAndUpdate,
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            /// ---------- Loader Overlay (no freeze) ----------
            if (isLoading)
              Container(
                color: Colors.black45,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
