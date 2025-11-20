import 'package:get/get.dart';
import 'package:ubs_secure_verification/core/services/face_recognition_service.dart';
import '../../core/services/api_service.dart';
import '../../core/utils/device_helper.dart';

class AuthController extends GetxController {
  final ApiService _apiService = ApiService();
  final isLoading = false.obs;
  
  Future<void> login(String userId, String password) async {
    try {
      isLoading.value = true;
      
      // Get IMEI device
      String imei = await DeviceHelper.getDeviceId();
      
      // Call API AUTH_user_pass_imei
      final response = await _apiService.post(
        ApiConstants.baseUrlAuth + ApiConstants.authUserPassImei,
        {
          'user_id': userId,
          'password': password,
          'imei': imei,
        },
      );
      
      if (response.statusCode == 200) {
        // Setup VPN jika berhasil
        await _setupVPN(response.data['vpn_config']);
        
        // Navigate ke face recognition
        Get.offNamed('/face-recognition');
      }
    } catch (e) {
      Get.snackbar('Error', 'Login failed: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> _setupVPN(String vpnConfig) async {
    // TODO: Implement WireGuard VPN setup
  }
}