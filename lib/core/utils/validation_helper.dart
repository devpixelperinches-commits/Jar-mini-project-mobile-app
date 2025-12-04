class ValidationHelper {
  // ----------------------------------------------------------
  // EMAIL VALIDATION
  // ----------------------------------------------------------
  static String? validateEmail(String email) {
    email = email.trim();

    if (email.isEmpty) return "Email is required";

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return "Enter a valid email address";
    }

    return null;
  }

  // ----------------------------------------------------------
  // PASSWORD VALIDATION
  // ----------------------------------------------------------
  static String? validatePassword(String password) {
    if (password.isEmpty) return "Password is required";

    if (password.length < 12) {
      return "Password must be at least 12 characters";
    }

    // Detect sequential or repeated simple numeric patterns
    const weakPatterns = [
      "1234",
      "2345",
      "3456",
      "4567",
      "5678",
      "6789",
      "7890",
      "0123",
      "0000",
      "1111",
      "2222",
      "3333",
      "4444",
      "5555",
      "6666",
      "7777",
      "8888",
      "9999",
    ];

    for (final pattern in weakPatterns) {
      if (password.contains(pattern)) {
        return "Password too weak — avoid simple numeric patterns";
      }
    }

    // Must have UPPERCASE + lowercase + number + special character
    final strongPasswordRegex = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$%^&*()_+\-=\[\]{};:"\\|,.<>\/?]).+$',
    );

    if (!strongPasswordRegex.hasMatch(password)) {
      return "Password must include uppercase, lowercase, number, and special character";
    }

    return null;
  }

  // ----------------------------------------------------------
  // CONFIRM PASSWORD VALIDATION
  // ----------------------------------------------------------
  static String? validateConfirmPassword(String password, String confirm) {
    if (confirm.isEmpty) return "Confirm password is required";
    if (confirm != password) return "Passwords do not match";
    return null;
  }

  // ----------------------------------------------------------
  // CONTACT NUMBER VALIDATION (International format)
  // ----------------------------------------------------------
  static String? validateContact(String contact) {
    if (contact.isEmpty) return "Contact number is required";

    // Remove spaces, hyphens, parentheses
    final digitsOnly = contact.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.length < 10) {
      return "Enter a valid phone number (minimum 10 digits)";
    }

    if (digitsOnly.length > 15) {
      return "Phone number too long — check your input";
    }

    // Optional: enforce "+" but not mandatory
    // if (!contact.startsWith('+')) {
    //   return "Include country code (e.g., +91XXXXXXXXXX)";
    // }

    return null;
  }
}
