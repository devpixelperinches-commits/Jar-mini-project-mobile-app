import 'package:jarpay/core/network/api_endpoints.dart';
import 'package:jarpay/core/network/dio_client.dart';
import 'package:jarpay/core/utils/helpers/api_helper.dart';
import 'package:jarpay/core/utils/device_location_helper.dart';
import 'package:jarpay/core/storage/secure_storage_service.dart';

/// Enhanced Auth Repository with proper error handling and type safety
class AuthRepository {
  /// ✅ Login with device info and location (using ApiResponse)
  Future<ApiResponse<Map<String, dynamic>>> login(
    Map<String, dynamic> body,
  ) async {
    return ApiHelper.safeApiCall<Map<String, dynamic>>(() async {
      final deviceData = await DeviceLocationHelper.getDeviceAndLocation();

      final payload = {
        ...body,
        "deviceInfo": deviceData.deviceInfo.toJson(),
        "userCurrentLocation": deviceData.userLocation.toJson(),
      };

      return dioClient.post(ApiEndpoints.login, data: payload);
    }, defaultErrorMessage: "Login failed. Please try again.");
  }

  /// ✅ Register user with device info and location (using ApiResponse)
  Future<ApiResponse<Map<String, dynamic>>> registerUser(
    Map<String, dynamic> body,
  ) async {
    return ApiHelper.safeApiCall<Map<String, dynamic>>(() async {
      final deviceData = await DeviceLocationHelper.getDeviceAndLocation();

      final payload = {
        ...body,
        "deviceInfo": deviceData.deviceInfo.toJson(),
        "userCurrentLocation": deviceData.userLocation.toJson(),
      };

      return dioClient.post(ApiEndpoints.register, data: payload);
    }, defaultErrorMessage: "Registration failed. Please try again.");
  }

  /// ✅ Logout (using ApiResponse)
  Future<ApiResponse<Map<String, dynamic>>> logout() async {
    final response = await ApiHelper.safeApiCall<Map<String, dynamic>>(
      () => dioClient.post(ApiEndpoints.logout),
      defaultErrorMessage: "Logout failed. Please try again.",
    );

    // Clear pending requests after logout
    if (response.success) {
      ApiHelper.clearPendingRequests();
    }

    return response;
  }

  /// ✅ Refresh token (for ApiHelper configuration)
  Future<bool> refreshToken(String refreshToken) async {
    try {
      final response = await dioClient.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final newAccessToken = response.data['access_token'] as String?;
        final newRefreshToken = response.data['refresh_token'] as String?;

        if (newAccessToken != null) {
          await SecureStorageService.saveToken(newAccessToken);
        }
        if (newRefreshToken != null) {
          await SecureStorageService.saveRefreshToken(newRefreshToken);
        }

        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}

// ============================================================================
// ALTERNATIVE: Legacy version with try-catch (if you prefer exceptions)
// ============================================================================

class AuthRepositoryLegacy {
  /// ✅ Login with device info and location (throws exceptions)
  Future<Map<String, dynamic>> login(Map<String, dynamic> body) async {
    return ApiHelper.safeApiCallLegacy(() async {
      final deviceData = await DeviceLocationHelper.getDeviceAndLocation();

      final payload = {
        ...body,
        "deviceInfo": deviceData.deviceInfo.toJson(),
        "userCurrentLocation": deviceData.userLocation.toJson(),
      };

      return dioClient.post(ApiEndpoints.login, data: payload);
    }, defaultErrorMessage: "Login failed. Please try again.");
  }

  /// ✅ Register user with device info and location (throws exceptions)
  Future<Map<String, dynamic>> registerUser(Map<String, dynamic> body) async {
    return ApiHelper.safeApiCallLegacy(() async {
      final deviceData = await DeviceLocationHelper.getDeviceAndLocation();

      final payload = {
        ...body,
        "deviceInfo": deviceData.deviceInfo.toJson(),
        "userCurrentLocation": deviceData.userLocation.toJson(),
      };

      return dioClient.post(ApiEndpoints.register, data: payload);
    }, defaultErrorMessage: "Registration failed. Please try again.");
  }

  /// ✅ Logout (throws exceptions)
  Future<Map<String, dynamic>> logout() async {
    try {
      final result = await ApiHelper.safeApiCallLegacy(
        () => dioClient.post(ApiEndpoints.logout),
        defaultErrorMessage: "Logout failed. Please try again.",
      );

      // Clear pending requests after successful logout
      ApiHelper.clearPendingRequests();

      return result;
    } catch (e) {
      rethrow;
    }
  }
}

// ============================================================================
// USAGE EXAMPLES
// ============================================================================

/// Example 1: Using ApiResponse (Recommended - Cleaner code)
/*
class AuthController {
  final AuthRepository _authRepository = AuthRepository();

  Future<void> handleLogin(String email, String password) async {
    final response = await _authRepository.login({
      'email': email,
      'password': password,
    });

    if (response.success) {
      print('✅ Login successful: ${response.data}');
      // Navigate to home screen
      // Get.offAllNamed('/home');
    } else {
      print('❌ Login failed: ${response.message}');
      // Show error message
      // Get.snackbar('Error', response.message ?? 'Login failed');
    }
  }

  Future<void> handleRegister(Map<String, dynamic> userData) async {
    final response = await _authRepository.registerUser(userData);

    if (response.success) {
      print('✅ Registration successful');
      // Navigate to login or home
    } else {
      print('❌ Registration failed: ${response.message}');
    }
  }

  Future<void> handleLogout() async {
    final response = await _authRepository.logout();

    if (response.success) {
      print('✅ Logout successful');
      // Clear user data and navigate to login
      // await UserStorage.clearAll();
      // Get.offAllNamed('/login');
    } else {
      print('❌ Logout failed: ${response.message}');
    }
  }
}
*/

/// Example 2: Using Legacy version with try-catch
/*
class AuthControllerLegacy {
  final AuthRepositoryLegacy _authRepository = AuthRepositoryLegacy();

  Future<void> handleLogin(String email, String password) async {
    try {
      final result = await _authRepository.login({
        'email': email,
        'password': password,
      });

      print('✅ Login successful: $result');
      // Navigate to home screen
    } on ApiException catch (e) {
      print('❌ Login failed: ${e.message}');
      
      if (e.isUnauthorized) {
        // Show invalid credentials message
      } else if (e.isNetworkError) {
        // Show network error message
      } else {
        // Show generic error
      }
    } catch (e) {
      print('❌ Unexpected error: $e');
    }
  }

  Future<void> handleLogout() async {
    try {
      await _authRepository.logout();
      print('✅ Logout successful');
      // Clear data and navigate
    } on ApiException catch (e) {
      print('❌ Logout failed: ${e.message}');
    }
  }
}
*/

/// Example 3: With loading state in GetX controller
/*
class AuthGetXController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';

    final response = await _authRepository.login({
      'email': email,
      'password': password,
    });

    isLoading.value = false;

    if (response.success) {
      // Save token
      final token = response.data?['token'];
      await TokenStorage.saveToken(token);
      
      // Navigate to home
      Get.offAllNamed('/home');
    } else {
      errorMessage.value = response.message ?? 'Login failed';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> logout() async {
    final response = await _authRepository.logout();

    if (response.success) {
      await TokenStorage.clearAll();
      Get.offAllNamed('/login');
    }
  }
}
*/

/// Example 4: With Bloc pattern
/*
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final response = await _authRepository.login({
      'email': event.email,
      'password': event.password,
    });

    if (response.success) {
      emit(AuthSuccess(userData: response.data!));
    } else {
      emit(AuthFailure(message: response.message ?? 'Login failed'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(AuthInitial());
  }
}
*/

/// Example 5: Setup refresh token in main.dart
/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure refresh token handler
  ApiHelper.configureRefreshToken(() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      
      if (refreshToken == null) return false;
      
      final authRepo = AuthRepository();
      final success = await authRepo.refreshToken(refreshToken);
      
      return success;
    } catch (e) {
      print('Refresh token error: $e');
      return false;
    }
  });

  runApp(MyApp());
}
*/
