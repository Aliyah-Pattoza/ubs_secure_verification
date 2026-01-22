import '../models/transaction_model.dart';
import '../../core/services/api_service.dart';

class TransactionRepository {
  /// Get pending transactions
  /// Menggunakan ApiService.getTransactionList() yang sudah ada
  Future<List<TransactionModel>> getPendingTransactions({String? token}) async {
    try {
      // Menggunakan static method dari ApiService
      final transactions = await ApiService.getTransactionList(token: token);
      return transactions;
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }
}
