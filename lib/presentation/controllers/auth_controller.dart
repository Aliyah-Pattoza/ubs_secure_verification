import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/utils/device_helper.dart';
import '../../data/models/user_model.dart';
import '../../app/routes/app_routes.dart';

class AuthController extends GetxController {
  // Observable states
  final isLoading = false.obs;
  final errorMessage = RxnString();

  // User data setelah login
  UserModel? currentUser;
  String? authToken;

  /// Login dengan User ID, Password, dan IMEI
  Future<void> login(String userId, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      // Get IMEI/Device ID
      String imei = await DeviceHelper.getDeviceId();

      // Call API login (static method)
      final response = await ApiService.login(
        userId: userId,
        password: password,
        imei: imei,
      );

      if (response.success && response.user != null) {
        // Simpan user data
        currentUser = response.user;
        authToken = response.token;

        // Navigate ke face recognition
        Get.offNamed(
          AppRoutes.faceRecognition,
          arguments: {'user': currentUser, 'token': authToken},
        );
      } else {
        // Login gagal
        errorMessage.value = response.message ?? 'Login gagal';
        Get.snackbar(
          'Error',
          response.message ?? 'Login gagal',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      errorMessage.value = 'Login failed: $e';
      Get.snackbar('Error', 'Login failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout user
  void logout() {
    currentUser = null;
    authToken = null;
    Get.offAllNamed(AppRoutes.login);
  }
}
