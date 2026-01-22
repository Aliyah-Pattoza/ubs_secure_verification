import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  // Observable untuk animasi
  final isLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initAnimation();
  }

  void _initAnimation() async {
    // Delay untuk animasi splash
    await Future.delayed(const Duration(milliseconds: 500));
    isLoaded.value = true;
  }

  /// Navigate ke halaman Login
  void goToLogin() {
    Get.offNamed(AppRoutes.login);
  }
}
