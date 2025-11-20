import 'package:ubs_secure_verification/core/constants/api_constants.dart';
import 'package:ubs_secure_verification/core/services/face_recognition_service.dart';

import '../models/transaction_model.dart';
import '../../core/services/api_service.dart';

class TransactionRepository {
  final ApiService _apiService = ApiService();
  
  Future<List<TransactionModel>> getPendingTransactions() async {
    try {
      final response = await _apiService.get(
        ApiConstants.baseUrlList + ApiConstants.transactionList,
      );
      
      List<TransactionModel> transactions = [];
      for (var item in response.data['transactions']) {
        transactions.add(TransactionModel.fromJson(item));
      }
      
      return transactions;
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }
}

class TransactionModel {
}