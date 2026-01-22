import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../data/models/user_model.dart';
import '../../data/models/transaction_model.dart';
import '../../app/routes/app_routes.dart';
import '../../app/themes/app_colors.dart';

class TransactionController extends GetxController {
  // User data
  UserModel? user;
  String? token;

  // Observable states
  final isLoading = true.obs;
  final errorMessage = RxnString();
  final transactions = <TransactionModel>[].obs;

  @override
  void onInit() {
    super.onInit();

    // Get arguments dari navigation
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      user = args['user'] as UserModel?;
      token = args['token'] as String?;
    }

    // Load transactions
    loadTransactions();
  }

  /// Load daftar transaksi dari API
  Future<void> loadTransactions() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final result = await ApiService.getTransactionList(token: token);
      transactions.value = result;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh transactions (pull-to-refresh)
  Future<void> refreshTransactions() async {
    await loadTransactions();
  }

  /// Handle approval action (Accept/Reject)
  void handleApproval(TransactionModel transaction, String action) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          action == 'accept' ? 'Accept Transaction?' : 'Reject Transaction?',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              transaction.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              transaction.formattedAmount,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: action == 'accept' ? AppColors.success : AppColors.error,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'You will need to verify with Face Recognition',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              // Navigate ke Face Recognition untuk verifikasi
              Get.toNamed(
                AppRoutes.faceRecognition,
                arguments: {
                  'user': user,
                  'token': token,
                  'transaction': transaction,
                  'action': action,
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: action == 'accept'
                  ? AppColors.success
                  : AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(action == 'accept' ? 'Accept' : 'Reject'),
          ),
        ],
      ),
    );
  }

  /// Logout
  void logout() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Logout',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              // Clear all dan navigate ke login
              Get.offAllNamed(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
