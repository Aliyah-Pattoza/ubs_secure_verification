import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../data/models/models.dart';
import '../../routes/app_routes.dart';

class LoginController extends GetxController {
  // Form Controllers
  final userIdController = TextEditingController();
  final passwordController = TextEditingController();

  // Form Key untuk validasi
  final formKey = GlobalKey<FormState>();

  // Observable states
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final errorMessage = RxnString();

  // User data setelah login
  UserModel? currentUser;
  String? authToken;

  @override
  void onClose() {
    userIdController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// Toggle visibility password
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  /// Validasi User ID
  String? validateUserId(String? value) {
    if (value == null || value.isEmpty) {
      return 'User ID tidak boleh kosong';
    }
    return null;
  }

  /// Validasi Password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  /// Handle Login
  Future<void> handleLogin() async {
    // Validasi form
    if (!formKey.currentState!.validate()) return;

    // Reset error message
    errorMessage.value = null;
    isLoading.value = true;

    try {
      // Get device ID (IMEI/Android ID)
      final deviceId = await DeviceService.getDeviceId();

      // Call login API
      final response = await ApiService.login(
        userId: userIdController.text.trim(),
        password: passwordController.text,
        imei: deviceId,
      );

      if (response.success && response.user != null) {
        // Simpan user data
        currentUser = response.user;
        authToken = response.token;

        // Navigate ke Face Recognition
        Get.offNamed(
          AppRoutes.faceRecognition,
          arguments: {'user': currentUser, 'token': authToken},
        );
      } else {
        // Tampilkan error
        errorMessage.value = response.message ?? 'Login gagal';
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  /// Handle Forgot Password
  void handleForgotPassword() {
    Get.snackbar(
      'Info',
      'Hubungi admin untuk reset password',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.primaryColor,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: const Duration(seconds: 3),
    );
  }
}
