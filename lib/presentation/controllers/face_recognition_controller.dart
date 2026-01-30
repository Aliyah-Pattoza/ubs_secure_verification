import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../data/models/user_model.dart';
import '../../data/models/transaction_model.dart';
import '../../app/routes/app_routes.dart';

class FaceRecognitionController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // User data dari login
  UserModel? user;
  String? token;

  // Data untuk approval (jika ada)
  TransactionModel? pendingTransaction;
  String? approvalAction; // 'accept' atau 'reject'

  // Observable states
  final isScanning = false.obs;
  final scanComplete = false.obs;
  final statusMessage = 'Ready to Scan'.obs;
  final statusSubMessage = 'Please look at the camera'.obs;

  // Animation controller
  late AnimationController animationController;
  late Animation<double> pulseAnimation;

  @override
  void onInit() {
    super.onInit();

    // Get arguments dari navigation
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      user = args['user'] as UserModel?;
      token = args['token'] as String?;
      pendingTransaction = args['transaction'] as TransactionModel?;
      approvalAction = args['action'] as String?;
    }

    // Setup animation
    _setupAnimation();

    // Update subtitle jika untuk approval
    if (pendingTransaction != null && approvalAction != null) {
      statusSubMessage.value = 'Verify to $approvalAction transaction';
    }
  }

  void _setupAnimation() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );

    animationController.repeat(reverse: true);
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  /// Mulai proses verifikasi wajah
  Future<void> startVerification() async {
    isScanning.value = true;
    scanComplete.value = false;
    statusMessage.value = 'Scanning...';
    statusSubMessage.value = 'Hold still';

    // Simulasi proses scanning
    await Future.delayed(const Duration(seconds: 2));

    statusMessage.value = 'Processing...';
    statusSubMessage.value = 'Verifying your identity';

    try {
      // Panggil API Face Recognition (static method)
      final response = await ApiService.verifyFace(
        base64Image: 'mock_base64_image',
        userId: user?.id ?? '',
        nik: user?.nik ?? '',
      );

      if (response.success && response.isMatch == true) {
        // Verifikasi berhasil
        scanComplete.value = true;
        statusMessage.value = 'Verified!';
        statusSubMessage.value = 'Face recognition successful';

        await Future.delayed(const Duration(seconds: 1));

        // Check apakah ini untuk approval atau login biasa
        if (pendingTransaction != null && approvalAction != null) {
          await _processApproval();
        } else {
          _navigateToTransactionList();
        }
      } else {
        // Verifikasi gagal
        isScanning.value = false;
        statusMessage.value = 'Verification Failed';
        statusSubMessage.value = response.message ?? 'Please try again';

        Get.snackbar(
          'Verifikasi Gagal',
          response.message ?? 'Wajah tidak cocok',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      isScanning.value = false;
      statusMessage.value = 'Error';
      statusSubMessage.value = 'Failed to verify. Please try again.';

      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  /// Process approval setelah face recognition berhasil
  Future<void> _processApproval() async {
    try {
      final response = await ApiService.submitApproval(
        documentNumber: pendingTransaction!.documentNumber,
        status: approvalAction == 'accept' ? 'accepted' : 'rejected',
        base64Image: 'mock_base64_image',
        userId: user?.id ?? '',
        nik: user?.nik ?? '',
        token: token,
      );

      if (response.success) {
        // Navigate ke Success Screen
        Get.offNamed(
          AppRoutes.success,
          arguments: {
            'action': approvalAction,
            'transaction': pendingTransaction,
            'user': user,
            'token': token,
          },
        );
      } else {
        Get.snackbar(
          'Gagal',
          response.message ?? 'Gagal memproses approval',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        Get.back();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      Get.back();
    }
  }

  /// Navigate ke Transaction List
  void _navigateToTransactionList() {
    Get.offNamed(
      AppRoutes.transactionList,
      arguments: {'user': user, 'token': token},
    );
  }

  /// Kembali ke halaman sebelumnya
  void goBack() {
    Get.back();
  }
}
